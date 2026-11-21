#!/bin/bash
# Measures the Cutling keyboard extension's memory in a simulator, once per store size.
#
#   scripts/keyboard-memory.sh <simulator-udid|queue> <text>x<images> [<text>x<images> ...]
#   scripts/keyboard-memory.sh build        # build once; needs no simulator
#   bun ~/.claude/scripts/device-queue/device-queue.ts submit ios-sim --tree "$PWD" --cap 60 \
#     --cmd 'scripts/keyboard-memory.sh queue 0x0 100x25 1000x0 0x100'
#
# Simulators boot only through the shared device queue, so the runs go in as a queue job
# ("queue" takes its simulator, $DEVICE_QUEUE_UDID) after a separate build.
#
# Builds the UI tests once (Debug, simulator), then for each size runs
# KeyboardMemoryUITests/testKeyboardMemory, which seeds that many full-length
# text and full-size image cutlings, opens the keyboard, flings through the
# grid and copies an image. Meanwhile it samples phys_footprint, the number
# jetsam compares with an extension's limit, of every CutlingKeyboard process
# in that simulator. Prints one line per size: launch footprint, footprint
# after the scroll, and the peak. Samples and phase shots stay in the output folder.
#
# Simulator numbers run a little above a device's for the same work; read the
# growth between sizes, and compare peaks with the device limit with headroom.
set -euo pipefail

udid="${1:?simulator udid, queue or build}"; shift
repo="$(cd "$(dirname "$0")/.." && pwd)"
build="$("$repo/build-dir.sh")/keyboard-memory"
out="${MEMTEST_OUT:-${DEVICE_QUEUE_OUT:-$build/runs-$(date +%Y%m%d-%H%M%S)}}"
mkdir -p "$out"

if [ "$udid" = build ]; then
  xcodebuild build-for-testing -project "$repo/Cutling.xcodeproj" -scheme Cutling \
    -destination "generic/platform=iOS Simulator" -derivedDataPath "$build/DerivedData" -quiet \
    >"$out/build.log" 2>&1 || { tail -30 "$out/build.log"; exit 1; }
  echo "built: $build/DerivedData"
  exit 0
fi
[ "$udid" = queue ] && udid="${DEVICE_QUEUE_UDID:?not inside a device-queue job}"
[ $# -gt 0 ] || { echo "give at least one <text>x<images> size" >&2; exit 2; }
# The Cutling keyboard only shows with the software keyboard up.
defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool false
# Inside iOS too: with a hardware keyboard seen (another job can attach one), iOS minimises the software
# keyboard below the screen unless this is off.
# iOS 27 keeps these in com.apple.keyboard.preferences, not com.apple.Preferences: XCUITest's typeText arrives as
# hardware key events, which set HardwareKeyboardLastSeen, and with minimisation on every later field shows no keyboard.
xcrun simctl spawn "$udid" defaults write com.apple.keyboard.preferences AutomaticMinimizationEnabled -bool NO
xcrun simctl spawn "$udid" defaults write com.apple.keyboard.preferences HardwareKeyboardLastSeen -bool NO
keyboard="Devices/$udid/.*CutlingKeyboard.appex/CutlingKeyboard"
# The newest build's run file; an older one for another architecture set can sit beside it.
xctestrun="$(ls -t "$build"/DerivedData/Build/Products/*.xctestrun | head -1)"

# Max footprint and peak of the simulator's CutlingKeyboard processes, in MB.
sample() {
  local pids t
  pids="$(pgrep -f "$keyboard" || true)"
  t="$(perl -MTime::HiRes=time -e 'printf "%.3f", time')"
  for pid in $pids; do
    footprint --pid "$pid" --noCategories -f bytes 2>/dev/null \
      | awk -v pid="$pid" -v t="$t" '
          /phys_footprint:/ { now = $2 }
          /phys_footprint_peak:/ { peak = $2 }
          END { if (now) printf "%s %s %.1f %.1f\n", t, pid, now / 1048576, peak / 1048576 }'
  done
}

printf '%-12s %10s %12s %8s\n' size launch_MB scrolled_MB peak_MB
for size in "$@"; do
  text="${size%x*}"; images="${size#*x}"
  run="$out/$size"; mkdir -p "$run/shots"; : >"$run/phases.txt"; : >"$run/samples.txt"
  # Each size starts with a fresh keyboard process.
  for pid in $(pgrep -f "$keyboard" || true); do kill "$pid" 2>/dev/null || true; done
  # Serial: parallel testing runs on a clone of the queue's simulator, which the queue forbids and this sampler never sees.
  # No comment may sit inside this continued command: bash ends the command at it and runs xcodebuild without the variables.
  TEST_RUNNER_MEMTEST_TEXT="$text" TEST_RUNNER_MEMTEST_IMAGES="$images" \
  TEST_RUNNER_MEMTEST_LOG="$run/phases.txt" TEST_RUNNER_MEMTEST_SHOTS="$run/shots" \
  TEST_RUNNER_MEMTEST_FLINGS="${MEMTEST_FLINGS:-40}" \
    xcodebuild test-without-building -xctestrun "$xctestrun" -destination "id=$udid" -parallel-testing-enabled NO \
      -only-testing:CutlingUITests/KeyboardMemoryUITests/testKeyboardMemory \
      -resultBundlePath "$run/result.xcresult" >"$run/test.log" 2>&1 &
  test_pid=$!
  # The device queue ends a job whose log stays quiet for a minute, and on a loaded Mac one footprint call
  # can take longer than that, so the progress line runs on its own.
  ( started=$SECONDS
    while kill -0 "$test_pid" 2>/dev/null; do
      sleep 20; echo "  $size: $(tail -1 "$run/phases.txt" | cut -d' ' -f1) after $((SECONDS - started)) s"
    done ) &
  progress_pid=$!
  while kill -0 "$test_pid" 2>/dev/null; do
    sample >>"$run/samples.txt"; sleep 0.5
  done
  status=0; wait "$test_pid" || status=$?
  kill "$progress_pid" 2>/dev/null || true

  # Footprint 3 s after the keyboard came up, the last sample before copy_image/end, and the peak.
  python3 -I - "$run" "$size" "$status" <<'PY'
import sys, pathlib
run, size, status = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
phases = {}
for line in (run / "phases.txt").read_text().split("\n"):
    if line.strip():
        name, t = line.split(); phases[name] = float(t)
samples = []
for line in (run / "samples.txt").read_text().split("\n"):
    if line.strip():
        t, pid, now, peak = line.split(); samples.append((float(t), float(now), float(peak)))
def at(t):
    before = [s for s in samples if s[0] <= t]
    return f"{before[-1][1]:.1f}" if before else "-"
up = phases.get("keyboard_up"); done = phases.get("copy_image", phases.get("end"))
peak = max((s[2] for s in samples), default=0)
note = "" if status == "0" else f"  (test failed, see {run}/test.log)"
print(f"{size:<12} {at(up + 3) if up else '-':>10} {at(done) if done else '-':>12} {peak:>8.1f}{note}")
PY
done
echo "runs: $out"
# The seeded store holds hundreds of full-size images: leave the shared simulator without them.
xcrun simctl uninstall "$udid" com.matsuokengo.Cutling 2>/dev/null || true
