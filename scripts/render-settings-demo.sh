#!/bin/bash
# Cuts the raw Settings recordings from scripts/record-settings-demo.sh into the setup guide's
# looping videos, Cutling/settings-demo-light.mp4 and -dark.mp4: from Cutling's Settings page
# to two seconds after Allow, cropped to where every step happens, with a grey touch mark on
# each tap (as the Simulator's own touch indicator looks).
#
#   scripts/render-settings-demo.sh ~/Shared/device-queue/ios-sim/<ticket>/out/settings-demo
#
# simctl's recordings hold frames only where the screen changed, behind an edit list and a
# large B-frame delay; decoding them straight through (fps filter, -fps_mode cfr) put the
# frames seconds away from the test's clock. Seeking (-ss) lands where the test's marks say,
# so every output frame is taken by its own seek, 15 a second, then joined.
#
# Needs ffmpeg and ImageMagick (magick). Runs on the Mac, not in a queue job.
set -euo pipefail
src="${1:?folder holding light/ and dark/ from record-settings-demo.sh}"
repo="$(cd "$(dirname "$0")/.." && pwd)"
crop_h_frac=0.79   # the alert sits lowest, its buttons near 70% of the screen height
crop_w_frac=0.88   # the queue's iPhone Duo keeps its clock and camera in a strip on the right
fps=15
out_w=700
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
# One touch mark: a translucent grey disc with a light ring, 120 px across on the raw frame.
magick -size 120x120 xc:none -fill 'rgba(120,120,120,0.45)' -stroke 'rgba(255,255,255,0.85)' -strokewidth 5 \
  -draw 'circle 60,60 60,6' "$work/touch.png"
for look in ${LOOKS:-light dark}; do
  dir="$src/$look"
  [ -s "$dir/raw.mp4" ] || { echo "no $dir/raw.mp4" >&2; exit 1; }
  start=$(cat "$dir/start.txt")
  size=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$dir/raw.mp4")
  w=${size%,*}; h=${size#*,}
  crop_w=$(python3 -c "print(int($w*$crop_w_frac)//2*2)"); crop_h=$(python3 -c "print(int($h*$crop_h_frac)//2*2)")
  # The recorder starts a moment after it says so, by a different amount each run. Measure it:
  # seek around the Cutling tap and find when the switch's left half turns green (the white
  # knob sits there while it is off), about 0.15 s after the tap lands.
  read -r cx cy < <(awk '$1=="cutling"{print $3, $4}' "$dir/marks.txt")
  tap0=$(python3 -c "print(float('$(awk '$1=="cutling"{print $2}' "$dir/marks.txt")') - $start)")
  shift=$(python3 - "$dir/raw.mp4" "$tap0" "$(python3 -c "print(int($cx*$w) - 80)")" "$(python3 -c "print(int($cy*$h) - 12)")" <<'EOF'
import subprocess, sys
raw, tap, bx, by = sys.argv[1], float(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4])
def state(t):
    px = subprocess.run(["ffmpeg", "-v", "error", "-ss", f"{t:.3f}", "-i", raw, "-frames:v", "1",
                         "-vf", f"crop=40:24:{bx}:{by}", "-f", "rawvideo", "-pix_fmt", "rgb24", "-"],
                        capture_output=True).stdout
    if not px: return None
    r = sum(px[0::3]) / (len(px) / 3); g = sum(px[1::3]) / (len(px) / 3)
    if g - r > 80: return "on"        # the green track
    if g - r < 20 and g > 150: return "off"   # the white knob, in light and dark
    return None                       # anything else: another page, or the alert's dimming
times = [tap - 6 + i * 0.1 for i in range(121)]
seen = [state(t) for t in times]
# On, where the last clear state before it was off: the switch turning on, not the green
# coming back from under the alert's dimming.
flips, last = [], None
for t, st in zip(times, seen):
    if st == "on" and last == "off": flips.append(t)
    if st: last = st
# The flip nearest the tap; none means the clock already fits.
print(round(min(flips, key=lambda f: abs(f - tap - 0.15)) - tap - 0.15, 3) if flips else 0)
EOF
)
  at() { python3 -c "print(round(float('$1') - $start + $shift, 3))"; }
  begin=$(at "$(awk '$1=="begin"{print $2}' "$dir/marks.txt")")
  end=$(python3 -c "print($(at "$(awk '$1=="allow"{print $2}' "$dir/marks.txt")") + 2.0)")
  rm -rf "$work/frames"; mkdir -p "$work/frames"
  n=$(python3 -c "print(int(($end - $begin) * $fps))")
  for i in $(seq 0 $((n - 1))); do
    ffmpeg -v error -y -ss "$(python3 -c "print($begin + $i / $fps)")" -i "$dir/raw.mp4" -frames:v 1 \
      -vf "crop=$crop_w:$crop_h:0:0" "$work/frames/$(printf %05d "$i").png"
  done
  # One overlay per tap, on the joined frames' own clock (0 = begin), from 0.6 s before it
  # lands to 0.25 s after.
  filters="[0:v]null[base]"; inputs=(-framerate "$fps" -i "$work/frames/%05d.png"); last="base"; k=1
  while read -r name epoch x y; do
    [ "$name" = begin ] || [ "$name" = end ] && continue
    tap=$(python3 -c "print($(at "$epoch") - $begin)")
    px=$(python3 -c "print(int($x*$w) - 60)"); py=$(python3 -c "print(int($y*$h) - 60)")
    inputs+=(-loop 1 -i "$work/touch.png")
    filters="$filters;[$last][$k:v]overlay=$px:$py:enable='between(t,$(python3 -c "print($tap-0.6)"),$(python3 -c "print($tap+0.25)"))':shortest=1[v$k]"
    last="v$k"; k=$((k+1))
  done <"$dir/marks.txt"
  filters="$filters;[$last]scale=$out_w:-2,format=yuv420p[out]"
  ffmpeg -v error -y "${inputs[@]}" -filter_complex "$filters" -map "[out]" -an -c:v libx264 -preset slow -crf 26 \
    -r "$fps" -movflags +faststart "$repo/Cutling/settings-demo-$look.mp4"
  echo "$look: clock shift ${shift}s, $(ffprobe -v error -show_entries format=duration -of csv=p=0 "$repo/Cutling/settings-demo-$look.mp4") s, $(wc -c <"$repo/Cutling/settings-demo-$look.mp4") bytes, aspect $(python3 -c "print(round($crop_w/$crop_h, 3))")"
done
