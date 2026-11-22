#!/bin/bash
# Rebuilds Cutling 2.0's preview directions: every direction's stills at delivered size (iPhone 886 x 1920,
# iPad 1200 x 1600, Mac 1920 x 1080), its seam plot, its iPhone animatic on the music, and the contact sheet.
# Needs bun, Google Chrome, ImageMagick and ffmpeg.
#   src/build.sh                 everything (the six animatics take about 12 minutes on the Mac)
#   src/build.sh stills          stills, seam plots, storyboards and the contact sheet only
#   src/build.sh sheet           the contact sheet only, from the images already there
#   src/build.sh animatic <dir>  one direction's animatic
set -e
cd "$(dirname "$0")"
DIRS="a-blank b-note c-clock d-five-taps e-first-minute f-room"
# "Complicated" by Arulo, Mixkit 281 (Mixkit Stock Music Free License); the owner called it very good on 2026-11-22.
MUSIC=${MUSIC:-$HOME/Repositories/undirect-promo/monholt-samples/public/music-full/complicated.mp3}
if [ ! -f "$MUSIC" ]; then MUSIC="$(mktemp -d)/complicated.mp3"; curl -sL -o "$MUSIC" https://assets.mixkit.co/music/281/281.mp3; fi
# Where each animatic starts in the track, so the track's first drop (22.51 s) lands on the film's payoff.
music_start() { case $1 in a-blank) echo 11.18;; b-note) echo 13.44;; c-clock) echo 0;; d-five-taps) echo 11.47;; e-first-minute) echo 10.69;; f-room) echo 15.59;; esac; }

stills() {
  local d=$1
  for dev in iphone ipad mac; do bun render.mjs stills "$d" "$dev" "../$d" >/dev/null; done
  bun render.mjs seamplot "$d" iphone "../$d/seam.png" >/dev/null
  magick ../"$d"/iphone-0*.png -resize 40% -background '#f3f3f1' -splice 0x0 +append "../$d/storyboard.png"
  magick mogrify -alpha off ../"$d"/*.png
  echo "$d: stills, seam plot, storyboard"
}

animatic() {
  local d=$1 tmp; tmp=$(mktemp -d)
  bun render.mjs movie "$d" iphone "$tmp/picture.mp4" 30
  local len; len=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$tmp/picture.mp4")
  local start; start=$(music_start "$d")
  local out; out=$(python3 -c "print(max(0.0, $len - 1.2))")
  # the music fades in over 0.15 s and out over the last 1.2 s, so the loop's seam is quiet as well as still
  ffmpeg -nostdin -v error -y -i "$tmp/picture.mp4" -ss "$start" -t "$len" -i "$MUSIC" \
    -filter_complex "[1:a]afade=t=in:d=0.15,afade=t=out:st=$out:d=1.2,volume=0.9[a]" -map 0:v -map "[a]" \
    -c:v copy -c:a aac -b:a 192k -ar 48000 -ac 2 -shortest -movflags +faststart "../$d/animatic-iphone.mp4"
  rm -rf "$tmp"
  echo "../$d/animatic-iphone.mp4"
}

sheet() {
  bun render.mjs page sheet.html 2400 ../contact-sheet.png >/dev/null
  magick ../contact-sheet.png -alpha off ../contact-sheet.png
  echo "../contact-sheet.png: $(magick identify -format '%w x %h' ../contact-sheet.png)"
}

case "$1" in
  sheet) sheet ;;
  animatic) animatic "$2" ;;
  stills) for d in $DIRS; do stills "$d"; done; sheet ;;
  *) for d in $DIRS; do stills "$d"; done; sheet; for d in $DIRS; do animatic "$d"; done ;;
esac
