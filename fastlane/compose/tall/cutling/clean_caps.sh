#!/bin/bash
# Takes the seed's bank card and IBAN out of the captures the store frames show, by moving the app's
# own real tiles and rows, never by drawing text: the frames sell saving your email, address and replies.
#   bash fastlane/compose/tall/cutling/clean_caps.sh    (writes cap/*-clean.png; boxes measured on the takes)
set -euo pipefail
cd "$(dirname "$0")/cap"
# iPhone grid: the real Office door tile (row 5, left) takes the Bank Account slot (row 2, left);
# tall.json crops the grid after row 4, so Office door shows once. Tiles are 456 px apart.
magick iphone-grid.png \( iphone-grid.png -crop 604x412+43+2146 +repage \) -geometry +43+778 -composite iphone-grid-clean.png
# iPhone keyboard in Messages: the real Work Email tile from the email take, same keyboard and box,
# takes the Bank Account slot (row 2, left).
magick iphone-address-chat.png \( iphone-email-body.png -crop 641x200+14+2171 +repage \) -geometry +14+2171 -composite iphone-address-chat-clean.png
# iPad grid: the real Office door tile (row 2, column 4, from the end of the same take) takes the
# Bank Account slot (row 1, column 3).
magick ipad-grid.png \( ipad-grid-office.png -crop 405x286+1234+648 +repage \) -geometry +830+344 -composite ipad-grid-clean.png
# iPad keyboard: the real Meeting Link tile moves up from row 2, column 3 into the Bank Account slot,
# and its old slot takes the keyboard's own empty background from column 4.
for f in ipad-keyboard ipad-address-chat; do
  magick $f.png \( $f.png -crop 405x174+829+2269 +repage \) -geometry +829+2093 -composite \
    \( $f.png -crop 405x174+1241+2269 +repage \) -geometry +829+2269 -composite $f-clean.png
done
# Mac History: the IBAN row (y 128-196) goes; the four real rows under it move up one row and the
# list's own empty background fills the gap they leave.
magick mac-history.png \( mac-history.png -crop 720x280+0+198 +repage \) -geometry +0+128 -composite \
  \( mac-history.png -crop 720x70+0+520 +repage \) -geometry +0+408 -composite mac-history-clean.png
