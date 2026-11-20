#!/bin/bash
# Runs one CutlingUITests class on the shared device queue's simulator, after
# `scripts/keyboard-memory.sh build` has built the UI tests:
#
#   bun ~/.claude/scripts/device-queue/device-queue.ts submit ios-sim --form iphone --tree "$PWD" \
#     --cap 30 --cmd 'scripts/ui-test.sh FillInUITests'
#
# Results, log, screenshots and a screen recording (run.mp4) land in $DEVICE_QUEUE_OUT/<class>/.
# Prints every 20 s, since the queue ends a job whose log stays quiet for a minute.
set -u
name="${1:?UI test class, e.g. FillInUITests}"
repo="$(cd "$(dirname "$0")/.." && pwd)"
build="$("$repo/build-dir.sh")/keyboard-memory"
# The newest build's run file; an older one for another architecture set can sit beside it.
xctestrun="$(ls -t "$build"/DerivedData/Build/Products/*.xctestrun | head -1)"
out="${DEVICE_QUEUE_OUT:?run as a device-queue job}/$name"; mkdir -p "$out/shots"
# The Cutling keyboard only shows with the software keyboard up.
defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool false
# Serial: parallel testing runs on clones of the queue's simulator, and the device queue allows no clones.
TEST_RUNNER_FORMAT_TEST_SHOTS="$out/shots" xcodebuild test-without-building -xctestrun "$xctestrun" -destination "id=${DEVICE_QUEUE_UDID:?}" \
  -parallel-testing-enabled NO -only-testing:"CutlingUITests/$name" -resultBundlePath "$out/result.xcresult" >"$out/test.log" 2>&1 &
pid=$!; start=$SECONDS
# The simulator's screen for the whole run, for a clip of what the test did.
xcrun simctl io "$DEVICE_QUEUE_UDID" recordVideo --codec h264 --force "$out/run.mp4" >/dev/null 2>&1 &
rec=$!
while kill -0 $pid 2>/dev/null; do sleep 20; echo "$name: $((SECONDS - start)) s"; done
wait $pid; status=$?
kill -INT $rec 2>/dev/null; wait $rec 2>/dev/null
grep -E "Test Case|error:|failed|passed" "$out/test.log" | tail -20
echo "$name exit $status"
exit $status
