#!/bin/bash
# Records the 2.0 release film's takes (CutlingUITests/PromoReleaseUITests) on the device queue's iPhone, light, with
# the store's 9:41 status bar, after a build-for-testing into $UI_TEST_BUILD:
#
#   bun ~/.claude/scripts/device-queue/device-queue.ts submit ios-sim --form iphone --tree "$PWD" --cap 40 \
#     --cmd 'UI_TEST_BUILD=<dir> scripts/release-film-takes.sh'
#
# The film of the whole run, its MARK lines (test.log) and screenshots land in $DEVICE_QUEUE_OUT/PromoReleaseUITests.
# Arguments pick single takes: test1Note, test2Keyboard, test3Room.
set -u
udid="${DEVICE_QUEUE_UDID:?run as a device-queue job}"
xcrun simctl status_bar "$udid" override --time 9:41 --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3 --dataNetwork wifi
trap 'xcrun simctl status_bar "$udid" clear' EXIT
tests=(PromoReleaseUITests); [ $# -gt 0 ] && { tests=(); for t in "$@"; do tests+=("PromoReleaseUITests/$t"); done; }
UI_APPEARANCE=light "$(dirname "$0")/ui-test.sh" "${tests[@]}"
