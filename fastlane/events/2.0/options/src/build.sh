#!/bin/bash
# Rebuilds every option's card and details image, each option's App Store preview, and the preview sheet.
# Needs bun, Google Chrome and ImageMagick. About 30 minutes on an M3; pass option names to rebuild only those (closeup, three-names, whole-tag),
# or "sheet" to redraw only the previews from the images already there.
#   fastlane/events/2.0/options/src/build.sh [closeup] [three-names] [whole-tag] [sheet]
set -e
cd "$(dirname "$0")/.."
ALL="closeup three-names whole-tag"
WANT="${*:-$ALL}"
for o in $WANT; do
  [ "$o" = sheet ] && continue
  mkdir -p "$o"
  bun src/render.mjs "src/pt.html?scene=$o&spp=700" "$o/card.png" 2880 1620
  bun src/render.mjs "src/pt.html?scene=$o&spp=700" "$o/details.png" 1620 2880
  # a canvas saves with an alpha channel, which App Store Connect can refuse; the art is opaque, so drop it
  magick mogrify -alpha off "$o/card.png" "$o/details.png"
done
for o in $ALL; do bun src/render.mjs "src/contact.html?only=$o" "$o/app-store-preview.png" 465 900 page 2; done
bun src/render.mjs src/contact.html contact-sheet.png 1340 900 page 2
