#!/bin/bash
# Records the real Settings steps for the setup guide's looping video, once in light and once
# in dark, on the device queue's iPhone (ASG105):
#
#   bun ~/.claude/scripts/device-queue/device-queue.ts submit ios-sim --form iphone --tree "$PWD" \
#     --cap 20 --cmd 'UI_TEST_BUILD=<build> scripts/record-settings-demo.sh'
#
# Each look gets $DEVICE_QUEUE_OUT/settings-demo/<look>/raw.mp4, start.txt (the epoch the
# recording began) and marks.txt (each tap's epoch and place, from SettingsDemoRecordingUITests).
# scripts/render-settings-demo.sh then cuts them into the app's videos.
set -u
udid="${DEVICE_QUEUE_UDID:?run as a device-queue job}"
repo="$(cd "$(dirname "$0")/.." && pwd)"
build="${UI_TEST_BUILD:-$("$repo/build-dir.sh")/keyboard-memory}"
xctestrun="$(ls -t "$build"/DerivedData/Build/Products/*.xctestrun | head -1)"
out="${DEVICE_QUEUE_OUT:?}/settings-demo"
look_before="$(xcrun simctl ui "$udid" appearance 2>/dev/null || echo light)"
for look in light dark; do
  dir="$out/$look"; mkdir -p "$dir"
  # A buyer meets the switches off: no Cutling install and no keyboard entry left behind.
  xcrun simctl uninstall "$udid" com.matsuokengo.Cutling
  xcrun simctl ui "$udid" appearance "$look"
  # A device with two screens (iPhone Duo) refuses without --display and lists them; take the
  # one named "(primary)", the screen XCUIScreen.main shoots and the marks are measured on.
  record() { xcrun simctl io "$udid" recordVideo $display --codec h264 --force "$dir/raw.mp4" >"$dir/record.log" 2>&1 & rec=$!; }
  display=""; record; sleep 2
  if ! kill -0 $rec 2>/dev/null; then
    display="$(grep -E -- '--display=[0-9]+ +[A-Za-z]+ \(primary\)' "$dir/record.log" | grep -oE -- '--display=[0-9]+' | head -1)"
    [ -n "$display" ] && record
  fi
  for _ in $(seq 50); do grep -q "Recording started" "$dir/record.log" && break; sleep 0.1; done
  python3 -c 'import time; print(f"{time.time():.3f}")' >"$dir/start.txt"
  TEST_RUNNER_FORMAT_TEST_SHOTS="$dir" "$repo/scripts/without-cutling-keyboard.sh" \
    xcodebuild test-without-building -xctestrun "$xctestrun" -destination "id=$udid" -parallel-testing-enabled NO \
    -only-testing:CutlingUITests/SettingsDemoRecordingUITests -resultBundlePath "$dir/result.xcresult" >"$dir/test.log" 2>&1 & pid=$!
  start=$SECONDS
  while kill -0 $pid 2>/dev/null; do sleep 20; echo "settings demo $look: $((SECONDS - start)) s"; done
  wait $pid; status=$?
  kill -INT $rec 2>/dev/null; wait $rec 2>/dev/null
  echo "settings demo $look: test exit $status"; cat "$dir/marks.txt" 2>/dev/null
done
xcrun simctl ui "$udid" appearance "$look_before" 2>/dev/null
