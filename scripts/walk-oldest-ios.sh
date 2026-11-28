#!/bin/sh
# Walks Cutling on the queue's iPhone, which must run the app's minimum iOS, from a clone already built for testing:
# a fresh install's first run with Settings and the keyboard, the keyboard typing formatted cutlings, and the text page.
# walk-oldest-ios.sh <clone> <iOS, e.g. 17.0>; submit it through the device queue with --model naming an iPhone on that iOS.
OUT=${1:?clone built for testing}; OS=${2:-17.0}
cd $OUT || exit 1
UDID=${DEVICE_QUEUE_UDID:?no queue simulator}
RT=$(xcrun simctl list devices -j | jq -r --arg u "$UDID" '.devices | to_entries[] | select(.value[] | .udid == $u) | .key')
echo "device $UDID on $RT"
case "$RT" in *iOS-$(echo $OS | tr . -)) ;; *) echo "not iOS $OS"; exit 2 ;; esac
( while sleep 30; do echo "  . $(date +%H:%M:%S)"; done ) &
BEAT=$!
trap 'kill $BEAT 2>/dev/null' EXIT
xcrun simctl ui $UDID appearance light
defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool false
xcrun simctl uninstall $UDID com.matsuokengo.Cutling 2>/dev/null
rm -rf walk-*.xcresult shots; mkdir -p shots
# The first run needs a fresh install, so it goes alone before the seeded tests.
run() { N=$1; shift
  FORMAT_TEST_SHOTS=$OUT/shots xcodebuild test-without-building -project Cutling.xcodeproj -scheme Cutling \
    -destination id=$UDID -derivedDataPath build/dd -resultBundlePath walk-$N.xcresult "$@" 2>&1 | tee walk-$N.log \
    | grep -E --line-buffered "Test Case .*(passed|failed)|error:|Executed .* tests|TEST (SUCCEEDED|FAILED)|crash" | cut -c1-300
}
run 1 -only-testing:CutlingUITests/OnboardingCaptureUITests/testFirstRun
run 2 -only-testing:CutlingUITests/FormattingUITests/testKeyboardInsertsByFormat \
  -only-testing:CutlingUITests/TextPageUITests/testTextPageLight
for N in 1 2; do mkdir -p shots/att-$N; xcrun xcresulttool export attachments --path walk-$N.xcresult --output-path shots/att-$N > /dev/null 2>&1; done
ls shots | head -80
ls -t ~/Library/Logs/DiagnosticReports 2>/dev/null | grep -i cutling | head -5
