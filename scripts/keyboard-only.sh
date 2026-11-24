# ASG88: ui-test.sh with the hardware keyboard connected and no software keyboard, and Full Keyboard Access by FKA=1.
#!/bin/bash
# Runs CutlingUITests classes or single tests (Class/test, several allowed) on the shared device queue's simulator, after
# `scripts/keyboard-memory.sh build` has built the UI tests:
#
#   bun ~/.claude/scripts/device-queue/device-queue.ts submit ios-sim --form iphone --tree "$PWD" \
#     --cap 30 --cmd 'scripts/ui-test.sh FillInUITests'
#
# Results, log, screenshots and a screen recording (run.mp4) land in $DEVICE_QUEUE_OUT/<class>/.
# Prints every 20 s, since the queue ends a job whose log stays quiet for a minute.
set -u
name="${1:?UI test class, e.g. FillInUITests}"; name="${name%%/*}"
only=(); for t in "$@"; do only+=(-only-testing:"CutlingUITests/$t"); done
repo="$(cd "$(dirname "$0")/.." && pwd)"
# $UI_TEST_BUILD picks another build-for-testing folder, so one session's rebuild never swaps the bundle under another's run.
build="${UI_TEST_BUILD:-$("$repo/build-dir.sh")/keyboard-memory}"
# The newest build's run file; an older one for another architecture set can sit beside it.
xctestrun="$(ls -t "$build"/DerivedData/Build/Products/*.xctestrun | head -1)"
out="${DEVICE_QUEUE_OUT:?run as a device-queue job}/$name"; mkdir -p "$out/shots"
# The Cutling keyboard only shows with the software keyboard up.
defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool true
# Inside iOS too: once another job has attached a hardware keyboard, iOS minimises the software keyboard
# below the screen unless this is off (a focused field then shows no keyboard at all).
# iOS 27 keeps these in com.apple.keyboard.preferences, not com.apple.Preferences: XCUITest's typeText arrives as
# hardware key events, which set HardwareKeyboardLastSeen, and with minimisation on every later field shows no keyboard.
xcrun simctl spawn "${DEVICE_QUEUE_UDID:?}" defaults write com.apple.keyboard.preferences AutomaticMinimizationEnabled -bool YES
xcrun simctl spawn "${DEVICE_QUEUE_UDID:?}" defaults write com.apple.keyboard.preferences HardwareKeyboardLastSeen -bool YES
# The tests read English labels (Settings > General, the edit menu); a shared simulator can be left in another
# language by a film job, so English is put back and SpringBoard restarted to read it.
lang=$(xcrun simctl spawn "$DEVICE_QUEUE_UDID" defaults read -g AppleLanguages 2>/dev/null | tr -d '()", \n' | cut -c1-2)
if [ "$lang" != "en" ]; then
  xcrun simctl spawn "$DEVICE_QUEUE_UDID" defaults write -g AppleLanguages -array en
  xcrun simctl spawn "$DEVICE_QUEUE_UDID" defaults write -g AppleLocale -string en_US
  xcrun simctl spawn "$DEVICE_QUEUE_UDID" launchctl stop com.apple.SpringBoard 2>/dev/null; sleep 8
fi
# The keyboards too: a promo film job leaves the system keyboard of its language (the iPad stood on Japanese kana, which
# has no "a" key, so the keyboard tests cycled Cutling and Emoji and never found letters). One US keyboard and Cutling.
# A setup test meets the keyboard as a new buyer does, not yet added: scripts/without-cutling-keyboard.sh
# sets CUTLING_KEYBOARD=off, and the list is then the US keyboard alone.
kb=com.matsuokengo.Cutling.CutlingKeyboard
[ "${CUTLING_KEYBOARD:-on}" = off ] && kb=""
keyboards="$(xcrun simctl spawn "$DEVICE_QUEUE_UDID" defaults read -g AppleKeyboards 2>/dev/null | tr -d '()", \n')"
if [ "$keyboards" != "en_US@sw=QWERTY;hw=Automatic$kb" ]; then
  xcrun simctl spawn "$DEVICE_QUEUE_UDID" defaults write -g AppleKeyboards -array "en_US@sw=QWERTY;hw=Automatic" ${kb:+"$kb"}
fi
# Full Keyboard Access: FKA=1 turns it on, anything else off (ASG88 walk).
if [ "${FKA:-0}" = 1 ]; then
  xcrun simctl spawn "$DEVICE_QUEUE_UDID" defaults write com.apple.Accessibility FullKeyboardAccessEnabled -bool YES
else
  xcrun simctl spawn "$DEVICE_QUEUE_UDID" defaults write com.apple.Accessibility FullKeyboardAccessEnabled -bool NO
fi
xcrun simctl spawn "$DEVICE_QUEUE_UDID" launchctl stop com.apple.SpringBoard 2>/dev/null; sleep 8
# Safari opens its test pages in a fresh tab stack: tabs left by film jobs (one a can't-open-page tab) kept pages from loading.
xcrun simctl terminate "$DEVICE_QUEUE_UDID" com.apple.mobilesafari >/dev/null 2>&1
sdata="$(xcrun simctl get_app_container "$DEVICE_QUEUE_UDID" com.apple.mobilesafari data 2>/dev/null)"
[ -n "$sdata" ] && rm -f "$sdata"/Library/Safari/SafariTabs.db* 2>/dev/null
# LongInsertUITests opens scripts/fixtures/long-insert.html from the Mac on port 8765; its server runs for this job only.
server=""
case " $* " in *LongInsertUITests*)
  if ! curl -s -m 2 -o /dev/null http://127.0.0.1:8765/long-insert.html; then
    python3 -m http.server 8765 --bind 127.0.0.1 --directory "$repo/scripts/fixtures" >/dev/null 2>&1 &
    server=$!
  fi ;;
esac
trap '[ -n "$server" ] && kill "$server" 2>/dev/null' EXIT
# UI_APPEARANCE=light|dark pins the look, since the shared simulator keeps whatever the last job left.
[ -n "${UI_APPEARANCE:-}" ] && xcrun simctl ui "$DEVICE_QUEUE_UDID" appearance "$UI_APPEARANCE"
# Serial: parallel testing runs on clones of the queue's simulator, and the device queue allows no clones.
TEST_RUNNER_FORMAT_TEST_SHOTS="$out/shots" xcodebuild test-without-building -xctestrun "$xctestrun" -destination "id=${DEVICE_QUEUE_UDID:?}" \
  -parallel-testing-enabled NO "${only[@]}" -resultBundlePath "$out/result.xcresult" >"$out/test.log" 2>&1 &
pid=$!; start=$SECONDS
# The simulator's screen for the whole run, for a clip of what the test did.
# A device with two screens (iPhone Duo) refuses without --display and lists them; take its primary.
record() { xcrun simctl io "$DEVICE_QUEUE_UDID" recordVideo $display --codec h264 --force "$out/run.mp4" >"$out/record.log" 2>&1 & rec=$!; }
display=""; record; sleep 2
if ! kill -0 $rec 2>/dev/null; then
  display="$(grep -E -- '--display=[0-9]+ +[A-Za-z]+ \(primary\)' "$out/record.log" | grep -oE -- '--display=[0-9]+' | head -1)"
  [ -n "$display" ] && record
fi
while kill -0 $pid 2>/dev/null; do sleep 20; echo "$name: $((SECONDS - start)) s"; done
wait $pid; status=$?
kill -INT $rec 2>/dev/null; wait $rec 2>/dev/null
grep -E "Test Case|error:|failed|passed" "$out/test.log" | tail -20
echo "$name exit $status"
exit $status
