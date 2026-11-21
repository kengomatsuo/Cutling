#!/bin/bash
# Cuts the raw Settings recordings from scripts/record-settings-demo.sh into the setup guide's
# looping videos, Cutling/settings-demo-light.mp4 and -dark.mp4: from Cutling's Settings page
# to two seconds after Allow, cropped to the top of the screen where every step happens,
# with a grey touch mark on each tap (as the Simulator's own touch indicator looks).
#
#   scripts/render-settings-demo.sh ~/Shared/device-queue/ios-sim/<ticket>/out/settings-demo
#
# simctl's recordings carry an edit list and frames only where the screen changed, and their
# timestamps do not map to the test's clock the same way in every ffmpeg path. So the video
# is first rewritten at a constant 30 fps, and the test's tap times are placed on it from
# one thing seen in the picture: the screen dims when Apple's Full Access alert appears,
# about 0.35 s after the Full Access tap.
#
# Needs ffmpeg and ImageMagick (magick). Runs on the Mac, not in a queue job.
set -euo pipefail
src="${1:?folder holding light/ and dark/ from record-settings-demo.sh}"
repo="$(cd "$(dirname "$0")/.." && pwd)"
crop_h_frac=0.79   # the alert sits lowest, its buttons near 70% of the screen height
crop_w_frac=0.88   # the queue's iPhone Duo keeps its clock and camera in a strip on the right
out_w=700
alert_delay=0.35
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
# One touch mark: a translucent grey disc with a light ring, 120 px across on the raw frame.
magick -size 120x120 xc:none -fill 'rgba(120,120,120,0.45)' -stroke 'rgba(255,255,255,0.85)' -strokewidth 5 \
  -draw 'circle 60,60 60,6' "$work/touch.png"
for look in ${LOOKS:-light dark}; do
  dir="$src/$look"
  [ -s "$dir/raw.mp4" ] || { echo "no $dir/raw.mp4" >&2; exit 1; }
  ffmpeg -v error -y -i "$dir/raw.mp4" -fps_mode cfr -r 30 -an -c:v libx264 -crf 12 -preset veryfast "$work/cfr.mp4"
  ffmpeg -v error -i "$work/cfr.mp4" -vf "signalstats,metadata=print:key=lavfi.signalstats.YAVG:file=$work/yavg.txt" -f null -
  # The first moment the frame's mean brightness drops well below its median after having been
  # above it: the alert. (The recording opens on the darker home screen, which is skipped.)
  dim=$(python3 - "$work/yavg.txt" <<'EOF'
import re, sys
rows, t = [], None
for line in open(sys.argv[1]):
    m = re.search(r'pts_time:([\d.]+)', line)
    if m: t = float(m.group(1)); continue
    m = re.search(r'YAVG=([\d.]+)', line)
    if m and t is not None: rows.append((t, float(m.group(1))))
median = sorted(y for _, y in rows)[len(rows) // 2]
# A drop of 20 levels on a light screen, or of 30% on a dark one, where the alert's dimming
# moves the mean less.
dim = [y < median - min(20, median * 0.3) for _, y in rows]
print(next(rows[i][0] for i in range(1, len(rows)) if dim[i] and not dim[i - 1]))
EOF
)
  full=$(awk '$1=="fullAccess"{print $2}' "$dir/marks.txt")
  at() { python3 -c "print(round(float('$1') - $full + $dim - $alert_delay, 3))"; }
  size=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$work/cfr.mp4")
  w=${size%,*}; h=${size#*,}
  crop_h=$(python3 -c "print(int($h*$crop_h_frac)//2*2)")
  crop_w=$(python3 -c "print(int($w*$crop_w_frac)//2*2)")
  begin=$(at "$(awk '$1=="begin"{print $2}' "$dir/marks.txt")")
  end=$(python3 -c "print($(at "$(awk '$1=="allow"{print $2}' "$dir/marks.txt")") + 2.0)")
  # One overlay per tap, shown from 0.6 s before it lands to 0.25 s after.
  filters="[0:v]crop=$crop_w:$crop_h:0:0[base]"; inputs=(-i "$work/cfr.mp4"); last="base"; n=1
  while read -r name epoch x y; do
    [ "$name" = begin ] || [ "$name" = end ] && continue
    tap=$(at "$epoch")
    px=$(python3 -c "print(int($x*$w) - 60)"); py=$(python3 -c "print(int($y*$h) - 60)")
    inputs+=(-loop 1 -i "$work/touch.png")
    filters="$filters;[$last][$n:v]overlay=$px:$py:enable='between(t,$(python3 -c "print($tap-0.6)"),$(python3 -c "print($tap+0.25)"))':shortest=1[v$n]"
    last="v$n"; n=$((n+1))
  done <"$dir/marks.txt"
  filters="$filters;[$last]trim=start=$begin:end=$end,setpts=PTS-STARTPTS,scale=$out_w:-2,format=yuv420p[out]"
  ffmpeg -v error -y "${inputs[@]}" -filter_complex "$filters" -map "[out]" -an -c:v libx264 -preset slow -crf 26 \
    -movflags +faststart "$repo/Cutling/settings-demo-$look.mp4"
  echo "$look: alert at ${dim}s, $(ffprobe -v error -show_entries format=duration -of csv=p=0 "$repo/Cutling/settings-demo-$look.mp4") s, $(wc -c <"$repo/Cutling/settings-demo-$look.mp4") bytes, aspect $(python3 -c "print(round($crop_w/$crop_h, 3))")"
done
