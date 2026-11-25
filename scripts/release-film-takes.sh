#!/bin/bash
# Records the 2.0 release film's takes (CutlingUITests/PromoReleaseUITests) on the device queue's iPhone, light, with
# the store's 9:41 status bar, after a build-for-testing into $UI_TEST_BUILD:
#
#   bun ~/.claude/scripts/device-queue/device-queue.ts submit ios-sim --form iphone --tree "$PWD" --cap 40 \
#     --cmd 'UI_TEST_BUILD=<dir> scripts/release-film-takes.sh'
#
# The film of the whole run, its MARK lines (test.log) and screenshots land in $DEVICE_QUEUE_OUT/PromoReleaseUITests.
# RELEASE_TODAY=2026-12-01 makes a date stamp type that day (debug builds), for a take filmed before its post goes out.
# Arguments pick single takes: test1Note, test2Keyboard, test3Room, test4Messages. RELEASE_LANG=ja films the Japanese cut: the system in
# Japanese with the ja_JP region and the kana keyboard beside Cutling's, the seed and the test's labels in Japanese.
set -u
udid="${DEVICE_QUEUE_UDID:?run as a device-queue job}"
# The film is for US readers: with another region the grid counts "5.000 Cutlings", a date types as "23 November 2026"
# and the clock reads 09.41. The region the simulator had is put back afterwards.
was_locale="$(xcrun simctl spawn "$udid" defaults read -g AppleLocale 2>/dev/null)"
was_languages=($(xcrun simctl spawn "$udid" defaults read -g AppleLanguages 2>/dev/null | tr -d '()", ' | grep -v '^$'))
lang="${RELEASE_LANG:-en}"
case "$lang" in ja) region=ja_JP; own="ja_JP-Kana@sw=Kana;hw=Automatic" ;; *) region=en_US; own="en_US@sw=QWERTY;hw=Automatic" ;; esac
finish() {
  xcrun simctl status_bar "$udid" clear
  if [ "$lang" != en ] || { [ -n "$was_locale" ] && [ "$was_locale" != en_US ]; }; then
    [ "$lang" != en ] && [ ${#was_languages[@]} -gt 0 ] && xcrun simctl spawn "$udid" defaults write -g AppleLanguages -array "${was_languages[@]}"
    [ -n "$was_locale" ] && xcrun simctl spawn "$udid" defaults write -g AppleLocale -string "$was_locale"
    xcrun simctl spawn "$udid" launchctl stop com.apple.SpringBoard 2>/dev/null
  fi
}
trap finish EXIT
if [ "$was_locale" != "$region" ] || [ "$lang" != en ]; then
  xcrun simctl spawn "$udid" defaults write -g AppleLanguages -array "$lang"
  xcrun simctl spawn "$udid" defaults write -g AppleLocale -string "$region"
  xcrun simctl spawn "$udid" launchctl stop com.apple.SpringBoard 2>/dev/null; sleep 10
fi
xcrun simctl status_bar "$udid" override --time 9:41 --batteryState discharging --batteryLevel 100 --cellularBars 4 --wifiBars 3 --dataNetwork wifi
tests=(PromoReleaseUITests); [ $# -gt 0 ] && { tests=(); for t in "$@"; do tests+=("PromoReleaseUITests/$t"); done; }
TEST_RUNNER_RELEASE_TODAY="${RELEASE_TODAY:-}" TEST_RUNNER_RELEASE_LANG="$lang" UI_TEST_LANG="$lang:$region:$own" UI_APPEARANCE=light "$(dirname "$0")/ui-test.sh" "${tests[@]}"
