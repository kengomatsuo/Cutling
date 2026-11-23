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
# The film is for US readers: with another region the grid counts "5.000 Cutlings", a date types as "23 November 2026"
# and the clock reads 09.41. The region the simulator had is put back afterwards.
was_locale="$(xcrun simctl spawn "$udid" defaults read -g AppleLocale 2>/dev/null)"
finish() {
  xcrun simctl status_bar "$udid" clear
  if [ -n "$was_locale" ] && [ "$was_locale" != en_US ]; then
    xcrun simctl spawn "$udid" defaults write -g AppleLocale -string "$was_locale"
    xcrun simctl spawn "$udid" launchctl stop com.apple.SpringBoard 2>/dev/null
  fi
}
trap finish EXIT
if [ "$was_locale" != en_US ]; then
  xcrun simctl spawn "$udid" defaults write -g AppleLocale -string en_US
  xcrun simctl spawn "$udid" launchctl stop com.apple.SpringBoard 2>/dev/null; sleep 10
fi
xcrun simctl status_bar "$udid" override --time 9:41 --batteryState discharging --batteryLevel 100 --cellularBars 4 --wifiBars 3 --dataNetwork wifi
tests=(PromoReleaseUITests); [ $# -gt 0 ] && { tests=(); for t in "$@"; do tests+=("PromoReleaseUITests/$t"); done; }
UI_APPEARANCE=light "$(dirname "$0")/ui-test.sh" "${tests[@]}"
