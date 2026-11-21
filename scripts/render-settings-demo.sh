#!/bin/bash
# Cuts the raw Settings recordings from scripts/record-settings-demo.sh into the setup guide's
# looping videos, Cutling/settings-demo-light.mp4 and -dark.mp4: from Cutling's Settings page
# to two seconds after Allow, cropped to the top of the screen where every step happens,
# with a grey touch mark on each tap (as the Simulator's own touch indicator looks).
#
#   scripts/render-settings-demo.sh ~/Shared/device-queue/ios-sim/<ticket>/out/settings-demo
#
# Needs ffmpeg and ImageMagick (magick). Runs on the Mac, not in a queue job.
set -euo pipefail
src="${1:?folder holding light/ and dark/ from record-settings-demo.sh}"
repo="$(cd "$(dirname "$0")/.." && pwd)"
crop_h_frac=0.79   # the alert sits lowest, its buttons near 70% of the screen height
out_w=700
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
# One touch mark: a translucent grey disc with a light ring, 120 px across on the raw frame.
magick -size 120x120 xc:none -fill 'rgba(120,120,120,0.45)' -stroke 'rgba(255,255,255,0.85)' -strokewidth 5 \
  -draw 'circle 60,60 60,6' "$work/touch.png"
for look in light dark; do
  dir="$src/$look"
  [ -s "$dir/raw.mp4" ] || { echo "no $dir/raw.mp4" >&2; exit 1; }
  start=$(cat "$dir/start.txt")
  size=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$dir/raw.mp4")
  w=${size%,*}; h=${size#*,}
  crop_h=$(python3 -c "print(int($h*$crop_h_frac)//2*2)")
  t() { python3 -c "print(round(float('$1') - $start, 3))"; }
  begin=$(t "$(awk '$1=="begin"{print $2}' "$dir/marks.txt")")
  allow=$(t "$(awk '$1=="allow"{print $2}' "$dir/marks.txt")")
  end=$(python3 -c "print($allow + 2.0)")
  # One overlay per tap, shown from 0.6 s before it lands to 0.25 s after.
  filters="[0:v]crop=$w:$crop_h:0:0[base]"; inputs=(-i "$dir/raw.mp4"); last="base"; n=1
  while read -r name epoch x y; do
    [ "$name" = begin ] || [ "$name" = end ] && continue
    tap=$(t "$epoch")
    px=$(python3 -c "print(int($x*$w) - 60)"); py=$(python3 -c "print(int($y*$h) - 60)")
    inputs+=(-loop 1 -i "$work/touch.png")
    filters="$filters;[$last][$n:v]overlay=$px:$py:enable='between(t,$(python3 -c "print($tap-0.6)"),$(python3 -c "print($tap+0.25)"))':shortest=1[v$n]"
    last="v$n"; n=$((n+1))
  done <"$dir/marks.txt"
  filters="$filters;[$last]trim=start=$begin:end=$end,setpts=PTS-STARTPTS,scale=$out_w:-2,format=yuv420p[out]"
  ffmpeg -v error -y "${inputs[@]}" -filter_complex "$filters" -map "[out]" -an -c:v libx264 -preset slow -crf 26 \
    -movflags +faststart "$repo/Cutling/settings-demo-$look.mp4"
  echo "$look: $(ffprobe -v error -show_entries format=duration -of csv=p=0 "$repo/Cutling/settings-demo-$look.mp4") s, $(wc -c <"$repo/Cutling/settings-demo-$look.mp4") bytes, aspect $(python3 -c "print(round($w/$crop_h, 3))")"
done
