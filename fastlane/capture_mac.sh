#!/usr/bin/env bash
# capture_mac.sh — Capture a Mac App Store screenshot.
#
# Usage:
#   ./capture_mac.sh <name> [bg_color]
#
# Args:
#   name      Output basename (e.g. "01_PickerPanel"). Produces
#             fastlane/screenshots/mac/en-US/<name>.png at 2880x1800 16:10.
#   bg_color  ImageMagick color used to pad the captured window onto a 16:10
#             canvas. Defaults to "#1a1a1a". Examples: "#f5f5f7", "white",
#             "rgb(20,20,30)".
#
# Behavior:
#   1. Prompts you to select a window or region via screencapture -i.
#      Press space inside screencapture to toggle window-pick mode.
#   2. Pads the capture onto a 16:10 background canvas.
#   3. Resizes the result to exactly 2880x1800 (Apple's required size).

set -euo pipefail

PATH="/opt/homebrew/bin:$PATH"

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <name> [bg_color]" >&2
  exit 64
fi

NAME="$1"
BG="${2:-#22a98d}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$REPO_ROOT/fastlane/screenshots_mac/en-GB"
mkdir -p "$OUT_DIR"

TMP="$(mktemp -t cutling_cap_XXXXXX).png"
trap 'rm -f "$TMP"' EXIT

echo "==> Selecting capture area (press SPACE inside the picker to switch to window mode)..."
# -i: interactive  -o: no window shadow  -t png: PNG output
/usr/sbin/screencapture -i -o -t png "$TMP"

if [[ ! -s "$TMP" ]]; then
  echo "Capture cancelled or empty." >&2
  exit 1
fi

# Force 16:10 by padding the capture onto a target-aspect canvas.
# We pick a working canvas that fully contains the source while keeping 16:10,
# then resize to 2880x1800.
W=$(magick identify -format "%w" "$TMP")
H=$(magick identify -format "%h" "$TMP")

# Compute the smallest 16:10 box that contains the capture.
# target_w = max(W, ceil(H * 16/10)), target_h = max(H, ceil(W * 10/16))
TARGET_W=$(( W * 10 < H * 16 ? (H * 16 + 9) / 10 : W ))
TARGET_H=$(( H * 16 < W * 10 ? (W * 10 + 15) / 16 : H ))

OUT="$OUT_DIR/$NAME.png"

magick "$TMP" \
  -background "$BG" -gravity center \
  -extent "${TARGET_W}x${TARGET_H}" \
  -resize 2880x1800 \
  -gravity center -extent 2880x1800 \
  -strip \
  -define png:color-type=2 \
  "$OUT"

# Verify exact dimensions (App Store rejects 1px off).
FINAL=$(magick identify -format "%wx%h" "$OUT")
if [[ "$FINAL" != "2880x1800" ]]; then
  echo "ERROR: final dimensions $FINAL != 2880x1800" >&2
  exit 2
fi

echo "==> Saved $OUT ($FINAL, 16:10, bg=$BG)"
