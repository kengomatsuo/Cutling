#!/bin/bash
# Runs CutlingUITests/FormattingUITests on the shared device queue's simulator, after
# `scripts/keyboard-memory.sh build` has built the UI tests:
#
#   bun ~/.claude/scripts/device-queue/device-queue.ts submit ios-sim --form iphone --tree "$PWD" \
#     --cap 30 --cmd scripts/formatting-test.sh
#
# Prints every 20 s, since the queue ends a job whose log stays quiet for a minute.
set -u
repo="$(cd "$(dirname "$0")/.." && pwd)"
build="$("$repo/build-dir.sh")/keyboard-memory"
# The newest build's run file; an older one for another architecture set can sit beside it.
xctestrun="$(ls -t "$build"/DerivedData/Build/Products/*.xctestrun | head -1)"
out="${DEVICE_QUEUE_OUT:?run as a device-queue job}/formatting"; mkdir -p "$out"
# The Cutling keyboard only shows with the software keyboard up.
defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool false
# Inside iOS too: with a hardware keyboard seen (another job can attach one), iOS minimises the software
# keyboard below the screen unless this is off.
xcrun simctl spawn "${DEVICE_QUEUE_UDID:?}" defaults write com.apple.Preferences AutomaticMinimizationEnabled -bool NO
# Serial: parallel testing runs on clones of the queue's simulator, and the device queue allows no clones.
xcodebuild test-without-building -xctestrun "$xctestrun" -destination "id=${DEVICE_QUEUE_UDID:?}" \
  -parallel-testing-enabled NO -only-testing:CutlingUITests/FormattingUITests -resultBundlePath "$out/result.xcresult" >"$out/test.log" 2>&1 &
pid=$!; start=$SECONDS
while kill -0 $pid 2>/dev/null; do sleep 20; echo "formatting: $((SECONDS - start)) s"; done
wait $pid; status=$?
grep -E "Test Case|error:|failed|passed" "$out/test.log" | tail -20
echo "formatting exit $status"
exit $status
