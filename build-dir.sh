#!/bin/bash
# Prints the one folder every build, archive, export, DMG, site build and screenshot
# build of Cutling goes to.
# It is the user's temp folder, never the repo: Spotlight does not index it, so no built
# Cutling.app shows up as a second copy.
# Builds older than a day are deleted here on every call: sessions made 28-40 GB of builds a
# day (1-6 GB each), and macOS's three-day dirhelper sweep let 130 GB pile up and fill the
# disk. Every build is made again from git, and app builds run on Xcode Cloud.
if [ "$(uname -s)" = Darwin ]; then t="$(getconf DARWIN_USER_TEMP_DIR)"; else t="${TMPDIR:-/tmp}"; fi
dir="${t%/}/builds/cutling"
if [ -d "$dir" ]; then
  find "$dir" -mindepth 1 -maxdepth 1 -mtime +0 -exec rm -rf {} + 2>/dev/null
fi
printf '%s\n' "$dir"
