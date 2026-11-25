#!/bin/bash
# Uploads iPhone Duo store frames (App Store Connect's APP_IPHONE_DUO set: the outer screen at 1398 x 2034 and the inner
# at 2007 x 2853, mixed in one set) to one app version, one locale at a time, replacing only that locale's Duo set.
# Apple shows its iPhone Duo badge on a product page once Duo screenshots are submitted.
#
#   fastlane/upload_duo_screenshots.sh <app-id> <version> <root> [locale ...]
#
# <root>/<locale>/duo-*.png are that locale's Duo frames, uploaded in name order (Cutling: fastlane/frames, filled by
# fastlane/compose/creative/v2/build.py --publish-duo). A locale App Store Connect does not have is skipped. Read the sets back afterwards (asc screenshots list): a retried upload can land twice.
set -u
app="$1" version="$2" root="$3"; shift 3
locales=("$@")
[ ${#locales[@]} -eq 0 ] && locales=($(cd "$root" && ls -d */ | tr -d /))
for loc in "${locales[@]}"; do
  ls "$root/$loc"/duo-*.png >/dev/null 2>&1 || continue
  dir=$(mktemp -d); cp "$root/$loc"/duo-*.png "$dir"/
  out=$(asc screenshots upload --app "$app" --version "$version" --locale "$loc" --path "$dir" \
    --device-type IPHONE_DUO --replace --confirm 2>&1)
  ok=$?; n=$(ls "$dir"/*.png | wc -l | tr -d ' '); rm -rf "$dir"
  if [ $ok -eq 0 ]; then echo "$loc: $n uploaded"
  else echo "$loc: FAILED $(echo "$out" | tail -2 | tr '\n' ' ' | cut -c1-200)"; fi
done
