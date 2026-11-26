#!/bin/bash
# Compares the Swift port of the unlock celebration's motion (Cutling/UnlockCelebrationMotion.swift) with the design's
# fixtures.json (docs/plans/unlock/celebration, local only). Compiles for the Mac and runs in a second; prints one line.
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
out="$("$repo/build-dir.sh")/celebration-check"; mkdir -p "$out"
swiftc -O -o "$out/check" "$repo/Cutling/UnlockCelebrationMotion.swift" "$repo/scripts/celebration-check/main.swift"
"$out/check" "$repo/docs/plans/unlock/celebration/fixtures.json"
