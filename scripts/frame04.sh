#!/bin/bash
# Shoots store frame 04 (the setup guide's Try It page, dark, Cutling keyboard up) in every store
# language on the device queue's simulator, after a build-for-testing into $UI_TEST_BUILD:
#
#   bun ~/.claude/scripts/device-queue/device-queue.ts submit ios-sim --form iphone --tree "$PWD" --cap 120 \
#     --cmd 'UI_TEST_BUILD=<dir> scripts/frame04.sh [locale ...]'
#
# Shots land in $DEVICE_QUEUE_OUT/<locale>.png; copy them to fastlane/screenshots/<locale>/<Device>-04_KeyboardGuide.png
# and run ./deploy.sh frame. Store sizes need a 6.9-inch iPhone and a 13-inch iPad in the pool
# (docs/aso/frame04.md). Prints every 20 s, since the queue ends a job whose log stays quiet for a minute.
set -u
repo="$(cd "$(dirname "$0")/.." && pwd)"
build="${UI_TEST_BUILD:?build-for-testing folder}"
xctestrun="$(ls -t "$build"/DerivedData/Build/Products/*.xctestrun | head -1)"
out="${DEVICE_QUEUE_OUT:?run as a device-queue job}"
udid="${DEVICE_QUEUE_UDID:?}"
# The 50 store languages App Store Connect holds: fastlane/screenshots' folders (the Snapfile also lists 10 it lacks).
locales=("$@")
[ ${#locales[@]} -eq 0 ] && locales=($(cd "$repo/fastlane/screenshots" && ls -d */ | tr -d /))

defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool false
xcrun simctl spawn "$udid" defaults write com.apple.keyboard.preferences AutomaticMinimizationEnabled -bool NO
xcrun simctl spawn "$udid" defaults write com.apple.keyboard.preferences HardwareKeyboardLastSeen -bool NO
# Writing Cutling into iOS's keyboard list directly left the store simulators with only the Emoji key, and General >
# Keyboard > Add New Keyboard did not list it (2026-11-22); the buyer's own path through the guide does.
kb=com.matsuokengo.Cutling.CutlingKeyboard
# A fresh install with Cutling out of iOS's keyboard list, then the guide's own way into Settings (testAddKeyboard).
xcrun simctl uninstall "$udid" com.matsuokengo.Cutling 2>/dev/null
keep=($(xcrun simctl spawn "$udid" defaults read -g AppleKeyboards 2>/dev/null | sed -n 's/^ *"\{0,1\}\([^",()]*\)"\{0,1\},\{0,1\}$/\1/p' | grep -v '^$' | grep -v "^$kb"))
[ ${#keep[@]} -gt 0 ] && xcrun simctl spawn "$udid" defaults write -g AppleKeyboards -array "${keep[@]}"
TEST_RUNNER_FORMAT_TEST_SHOTS="$out" xcodebuild test-without-building -xctestrun "$xctestrun" -destination "id=$udid" -parallel-testing-enabled NO \
  -only-testing:CutlingUITests/TryItFrameUITests/testAddKeyboard >"$out/add-keyboard.log" 2>&1 &
pid=$!; while kill -0 $pid 2>/dev/null; do sleep 20; echo "adding keyboard: $(grep -c 't = ' "$out/add-keyboard.log") steps"; done
wait $pid && echo "keyboard added" || { echo "adding the keyboard FAILED"; grep -E 'error:' "$out/add-keyboard.log" | grep -v debugger | head -3; }
# Other keyboards put Cutling beyond the globe test's taps (kana, romaji, Indonesian on the iPad; English variants and Emoji
# still on the iPhone, 2026-11-22): keep US English and Cutling, so each globe tap flips between the two.
xcrun simctl spawn "$udid" defaults write -g AppleKeyboards -array "en_US@sw=QWERTY;hw=Automatic" "$kb"
echo "keyboards: $(xcrun simctl spawn "$udid" defaults read -g AppleKeyboards 2>/dev/null | tr -d '\n ')"
# Apple's marketing status bar, as fastlane snapshot's override_status_bar sets it.
xcrun simctl status_bar "$udid" override --time 9:41 --dataNetwork wifi --wifiMode active --wifiBars 3 \
  --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100
xcrun simctl io "$udid" screenshot "$out/screen-size.png" >/dev/null 2>&1 && sips -g pixelWidth -g pixelHeight "$out/screen-size.png" | tail -2

failed=()
for loc in "${locales[@]}"; do
  log="$out/$loc.log"
  TEST_RUNNER_FRAME_LANGUAGE="$loc" TEST_RUNNER_FRAME_SHOTS="$out" xcodebuild test-without-building -xctestrun "$xctestrun" \
    -destination "id=$udid" -parallel-testing-enabled NO -only-testing:CutlingUITests/TryItFrameUITests/testTryItFrame \
    >"$log" 2>&1 &
  pid=$!; start=$SECONDS
  while kill -0 $pid 2>/dev/null; do sleep 20; echo "$loc: $((SECONDS - start)) s"; done
  wait $pid; status=$?
  if [ $status -eq 0 ] && [ -f "$out/$loc.png" ]; then echo "$loc ok $((SECONDS - start)) s"; else failed+=("$loc"); echo "$loc FAILED"; grep -E "error:|failed" "$log" | head -3; fi
done
xcrun simctl status_bar "$udid" clear
echo "done: $(( ${#locales[@]} - ${#failed[@]} ))/${#locales[@]}; failed: ${failed[*]:-none}"
[ ${#failed[@]} -eq 0 ]
