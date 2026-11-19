#!/bin/bash
# Prints the one folder every build, archive, export, DMG, site build and screenshot
# build of Cutling goes to.
# It is the user's temp folder, never the repo: Spotlight does not index it, so no built
# Cutling.app shows up as a second copy, and macOS's dirhelper deletes what sits there
# untouched for three days, so nothing outlives the release it was built for.
if [ "$(uname -s)" = Darwin ]; then t="$(getconf DARWIN_USER_TEMP_DIR)"; else t="${TMPDIR:-/tmp}"; fi
printf '%s\n' "${t%/}/builds/cutling"
