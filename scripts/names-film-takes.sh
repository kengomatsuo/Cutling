#!/bin/bash
# Records the Five names and Five taps films' takes (CutlingUITests/PromoNamesFilmsUITests) on the device queue's iPhone, one
# recording per test, after a build-for-testing into $UI_TEST_BUILD:
#
#   bun ~/.claude/scripts/device-queue/device-queue.ts submit ios-sim --form iphone --tree "$PWD" --cap 60 \
#     --cmd 'UI_TEST_BUILD=<dir> NAMES_APPEARANCE=light scripts/names-film-takes.sh ja test1Typed test2Picked test3Taps'
#
# NAMES_TODAY=2026-12-01 makes the date stamps of test4Reply (the 2.0 film) read that day.
# The first argument is the language (en or ja), the rest are the tests (default: all three). Each test's screen recording
# ($DEVICE_QUEUE_OUT/<lang>-<test>.mov), the wall clock its recording started (.t0, seconds) and its log with the MARK lines
# (.log) land in $DEVICE_QUEUE_OUT, shots in $DEVICE_QUEUE_OUT/shots/<test>. The contacts are the ones every-app-takes.sh saved
# (Messages names a thread from them), plus the Japanese guest of Five taps. Prints every 20 s for the queue.
set -u
build="${UI_TEST_BUILD:?build-for-testing folder}"
xctestrun="$(ls -t "$build"/DerivedData/Build/Products/*.xctestrun | head -1)"
out="${DEVICE_QUEUE_OUT:?run as a device-queue job}"
udid="${DEVICE_QUEUE_UDID:?}"
lang="${1:-en}"; shift
tests=("$@"); [ ${#tests[@]} -eq 0 ] && tests=(test1Typed test2Picked test3Taps)
kb=com.matsuokengo.Cutling.CutlingKeyboard
data="$HOME/Library/Developer/CoreSimulator/Devices/$udid/data"
mkdir -p "$out/shots"

defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool false
xcrun simctl ui "$udid" appearance "${NAMES_APPEARANCE:-light}"
xcrun simctl spawn "$udid" defaults write com.apple.keyboard.preferences AutomaticMinimizationEnabled -bool NO
xcrun simctl spawn "$udid" defaults write com.apple.keyboard.preferences HardwareKeyboardLastSeen -bool NO
simslim enable "$udid" pim apps messaging search photos >/dev/null 2>&1 || true
# Messages' thread view asks StatusKit's daemon about the contact: with it stopped by simslim, MobileSMS loops on
# _statusDaemonDisconnectedNotification at 110 % CPU, no accessibility query of it is answered and typing lands a key a minute.
simslim enable "$udid" com.apple.StatusKitAgent >/dev/null 2>&1 || true
for app in com.apple.MobileSMS; do xcrun simctl privacy "$udid" grant contacts "$app" 2>/dev/null; done

was_languages=($(xcrun simctl spawn "$udid" defaults read -g AppleLanguages 2>/dev/null | tr -d '()", ' | grep -v '^$'))
was_locale="$(xcrun simctl spawn "$udid" defaults read -g AppleLocale 2>/dev/null)"
rec=""
finish() {
  [ -n "$rec" ] && kill -INT "$rec" 2>/dev/null
  xcrun simctl status_bar "$udid" clear
  [ ${#was_languages[@]} -gt 0 ] && xcrun simctl spawn "$udid" defaults write -g AppleLanguages -array "${was_languages[@]}"
  [ -n "$was_locale" ] && xcrun simctl spawn "$udid" defaults write -g AppleLocale -string "$was_locale"
  xcrun simctl spawn "$udid" launchctl stop com.apple.SpringBoard 2>/dev/null
}
trap finish EXIT

case "$lang" in ja) own="ja_JP-Kana@sw=Kana;hw=Automatic"; region=ja_JP ;; *) own="en_US@sw=QWERTY;hw=Automatic"; region=en_US ;; esac
xcrun simctl spawn "$udid" defaults write -g AppleKeyboards -array "$own" "$kb"
xcrun simctl spawn "$udid" defaults write -g AppleLanguages -array "$lang"
xcrun simctl spawn "$udid" defaults write -g AppleLocale -string "$region"
xcrun simctl spawn "$udid" launchctl stop com.apple.SpringBoard 2>/dev/null; sleep 8

# Five taps' Japanese guest, 高橋 美咲, as +12025550179 (the 7 in place of every-app-takes.sh's 6, so no number repeats).
if [ "$lang" = ja ] && [ ! -f "$data/names-film-contacts-v1-ja" ]; then
  printf 'BEGIN:VCARD\nVERSION:3.0\nN:高橋;美咲;;;\nFN:美咲 高橋\nX-PHONETIC-LAST-NAME:たかはし\nX-PHONETIC-FIRST-NAME:みさき\nTEL;TYPE=CELL:+12025550179\nEND:VCARD\n' >"$out/takahashi.vcf"
  xcrun simctl addmedia "$udid" "$out/takahashi.vcf" && touch "$data/names-film-contacts-v1-ja"
fi
xcrun simctl status_bar "$udid" override --time 9:41 --dataNetwork wifi --wifiMode active --wifiBars 3 \
  --cellularMode active --cellularBars 4 --batteryState discharging --batteryLevel 100

for test in "${tests[@]}"; do
  stem="$out/$lang-$test"; sd="$out/shots/$test"; mkdir -p "$sd"
  xcrun simctl terminate "$udid" com.apple.MobileSMS >/dev/null 2>&1
  xcrun simctl io "$udid" recordVideo --codec=h264 --force "$stem.mov" 2>"$stem.reclog" &
  rec=$!
  for _ in $(seq 1 100); do grep -q "Recording started" "$stem.reclog" 2>/dev/null && break; sleep 0.1; done
  python3 -c 'import time; print("%.3f" % time.time())' >"$stem.t0"
  python3 "$(dirname "$0")/names-type-helper.py" "$sd/type-request-$lang.json" "$sd/type-done-$lang" "$udid" >"$stem.keys.log" 2>&1 &
  helper=$!
  TEST_RUNNER_NAMES_LANG="$lang" TEST_RUNNER_NAMES_DIR="$sd" TEST_RUNNER_NAMES_TODAY="${NAMES_TODAY:-}" \
    xcodebuild test-without-building -xctestrun "$xctestrun" -destination "id=$udid" -parallel-testing-enabled NO \
    -test-timeouts-enabled NO -only-testing:"CutlingUITests/PromoNamesFilmsUITests/$test" >"$stem.log" 2>&1 &
  pid=$!; start=$SECONDS
  while kill -0 $pid 2>/dev/null; do sleep 20; echo "$lang $test: $((SECONDS - start)) s"; done
  wait $pid; status=$?
  kill "$helper" 2>/dev/null; cat "$stem.keys.log" >>"$stem.log"
  kill -INT "$rec" 2>/dev/null; wait "$rec" 2>/dev/null; rec=""
  grep -E "error:|Test Case .* (passed|failed)" "$stem.log" | grep -v debugger | head -6
  echo "$lang $test exit $status"
done
