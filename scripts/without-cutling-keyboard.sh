#!/bin/bash
# Runs a command on the queue simulator with the Cutling keyboard taken out of iOS's keyboard
# list, then puts the list back as it was, so a setup test meets the keyboard as a new buyer
# does. Uninstalling Cutling alone leaves its entry in the global AppleKeyboards list, and
# the app then reads the keyboard as added.
#
#   scripts/without-cutling-keyboard.sh scripts/ui-test.sh SetupMockAUITests
set -u
udid="${DEVICE_QUEUE_UDID:?run as a device-queue job}"
list() { xcrun simctl spawn "$udid" defaults read -g AppleKeyboards 2>/dev/null | sed -n 's/^ *"\{0,1\}\([^",()]*\)"\{0,1\},\{0,1\}$/\1/p' | grep -v '^$'; }
original=(); while IFS= read -r k; do original+=("$k"); done < <(list)
without=(); for k in "${original[@]}"; do [[ "$k" == com.matsuokengo.Cutling* ]] || without+=("$k"); done
[ ${#without[@]} -gt 0 ] && xcrun simctl spawn "$udid" defaults write -g AppleKeyboards -array "${without[@]}"
# scripts/ui-test.sh puts the Cutling keyboard back unless told not to.
CUTLING_KEYBOARD=off "$@"; status=$?
[ ${#original[@]} -gt 0 ] && xcrun simctl spawn "$udid" defaults write -g AppleKeyboards -array "${original[@]}"
exit $status
