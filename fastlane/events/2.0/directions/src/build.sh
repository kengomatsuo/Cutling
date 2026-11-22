#!/bin/bash
# Rebuilds the directions for Cutling 2.0's In-App Event: each one's card (2880x1620) and details image
# (1620x2880), the calendar's two loops, each direction's App Store preview, and the contact sheet.
# Needs bun, Google Chrome, ImageMagick and ffmpeg, and the studio-render skill for the path-traced one.
#   src/build.sh                 everything except the path trace (about 12 minutes, two images, on an M3)
#   src/build.sh one-key         the path trace too
#   src/build.sh sheet           only the previews and the contact sheet, from the images already there
set -e
cd "$(dirname "$0")/.."
R="$HOME/.claude/skills/studio-render/scripts"
still() { mkdir -p "$1"
  bun "$R/render.mjs" "src/$1.html" "$1/card.png" 1920 1080 page 1.5
  bun "$R/render.mjs" "src/$1.html" "$1/details.png" 1080 1920 page 1.5
  magick mogrify -alpha off "$1/card.png" "$1/details.png"; }   # App Store Connect can refuse a PNG with an alpha channel
if [ "$1" != sheet ]; then
  if [ "$1" = one-key ]; then mkdir -p one-key
    bun "$R/render.mjs" "$R/pt.html?scene=$PWD/src/scene-one-key.glsl.js&spp=700" one-key/card.png 2880 1620
    bun "$R/render.mjs" "$R/pt.html?scene=$PWD/src/scene-one-key.glsl.js&spp=700" one-key/details.png 1620 2880
    magick mogrify -alpha off one-key/card.png one-key/details.png
  fi
  for d in todays-date it-asks bold-the-price room-to-grow same-question; do [ -f "src/$d.html" ] && still "$d"; done
  bun src/frames.mjs src/todays-date.html todays-date/card.mp4 1920 1080 30
  bun src/frames.mjs src/todays-date.html todays-date/details.mp4 1080 1920 30
  bun src/frames.mjs src/todays-date.html todays-date/loop-frames.png 1920 1080 strip 4
fi
for d in one-key todays-date it-asks bold-the-price room-to-grow same-question; do
  [ -f "$d/card.png" ] && bun "$R/render.mjs" "src/contact.html?only=$d" "$d/app-store-preview.png" 820 700 page 2
done
bun "$R/render.mjs" src/contact.html contact-sheet.png 1600 900 page 2
