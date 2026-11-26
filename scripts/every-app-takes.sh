#!/bin/bash
# Records the "Every app" App Store preview's takes (docs/aso/previews-2.0/directions.md, G) on the device queue's
# simulator, one language after another, after a build-for-testing into $UI_TEST_BUILD:
#
#   bun ~/.claude/scripts/device-queue/device-queue.ts submit ios-sim --form iphone --tree "$PWD" --cap 60 \
#     --cmd 'UI_TEST_BUILD=<dir> EVERY_WEB=<folder with refund.html> scripts/every-app-takes.sh en id ja'
#
# PromoEveryAppUITests/testEveryApp warms the flow, then asks for the camera through files; each language's film,
# press log and screenshots land in $DEVICE_QUEUE_OUT/<device>-<lang>.*. EVERY_TEST=testProbe runs the unfilmed probe;
# EVERY_BEATS=reply,maps films only those takes (PromoEveryAppUITests.beats). EVERY_WEB holds refund.html and reply.html.
# Prints every 20 s, since the queue ends a job whose log stays quiet for a minute.
set -u
repo="$(cd "$(dirname "$0")/.." && pwd)"
build="${UI_TEST_BUILD:?build-for-testing folder}"
web="${EVERY_WEB:?folder holding refund.html}"
xctestrun="$(ls -t "$build"/DerivedData/Build/Products/*.xctestrun | head -1)"
out="${DEVICE_QUEUE_OUT:?run as a device-queue job}"
udid="${DEVICE_QUEUE_UDID:?}"
form="${DEVICE_QUEUE_FORM:-iphone}"
test="${EVERY_TEST:-testEveryApp}"
port=8767
langs=("$@"); [ ${#langs[@]} -eq 0 ] && langs=(en)
kb=com.matsuokengo.Cutling.CutlingKeyboard
data="$HOME/Library/Developer/CoreSimulator/Devices/$udid/data"

defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool false
# The film is light; another session's job can leave the shared simulator dark.
xcrun simctl ui "$udid" appearance light
xcrun simctl spawn "$udid" defaults write com.apple.keyboard.preferences AutomaticMinimizationEnabled -bool NO
xcrun simctl spawn "$udid" defaults write com.apple.keyboard.preferences HardwareKeyboardLastSeen -bool NO
# Contacts, Calendar, Maps and Messages need services simslim turns off; the next ticket's `simslim on` restores them.
simslim enable "$udid" pim apps messaging search photos >/dev/null 2>&1 || true
xcrun simctl privacy "$udid" grant location com.apple.Maps 2>/dev/null
# Maps asks to share contacts over its first screen; Messages and Calendar read them too.
for app in com.apple.MobileSMS com.apple.Maps com.apple.mobilecal; do xcrun simctl privacy "$udid" grant contacts "$app" 2>/dev/null; done
xcrun simctl privacy "$udid" grant calendar com.apple.mobilecal 2>/dev/null

python3 -m http.server "$port" --bind 127.0.0.1 --directory "$web" >"$out/web.log" 2>&1 &
server=$!
rec=""
was_languages=($(xcrun simctl spawn "$udid" defaults read -g AppleLanguages 2>/dev/null | tr -d '()", ' | grep -v '^$'))
was_locale="$(xcrun simctl spawn "$udid" defaults read -g AppleLocale 2>/dev/null)"
finish() {
  [ -n "$rec" ] && kill -INT "$rec" 2>/dev/null; kill "$server" 2>/dev/null; xcrun simctl status_bar "$udid" clear
  [ ${#was_languages[@]} -gt 0 ] && xcrun simctl spawn "$udid" defaults write -g AppleLanguages -array "${was_languages[@]}"
  [ -n "$was_locale" ] && xcrun simctl spawn "$udid" defaults write -g AppleLocale -string "$was_locale"
  xcrun simctl spawn "$udid" launchctl stop com.apple.SpringBoard 2>/dev/null
}
trap finish EXIT

# The people the replies go to (docs/aso/previews-2.0/g-words.json, seed.contacts), added once per simulator and
# language, since a second import would list each twice. Each "family;given;family reading;given reading".
# 202-555-01xx numbers are set aside for fiction; contact n of a language gets 01<l><n> (l: en 4, id 5, ja 6), which
# PromoEveryAppUITests opens as sms: links.
contacts() {
  local lang="$1" marker="$data/every-app-contacts-v2-$lang" card="$out/contacts-$lang.vcf" digit people
  [ -f "$marker" ] && return
  case "$lang" in
    id) digit=5; people=("Wulandari;Rina;;" "Prasetyo;Dimas;;" "Handayani;Sari;;" "Saputra;Yoga;;" "Lestari;Fitri;;"
          "Setiawan;Agus;;" "Putri;Nadia;;" "Nugroho;Bayu;;" ";Yanti;;") ;;
    ja) digit=6; people=("中村;由美;なかむら;ゆみ" "小林;智也;こばやし;ともや" "松本;彩花;まつもと;あやか" "岡田;恵;おかだ;めぐみ"
          "原田;千夏;はらだ;ちなつ" "西村;翔;にしむら;しょう" "吉川;奈々;よしかわ;なな" "内田;拓也;うちだ;たくや" "池田;真理;いけだ;まり") ;;
    *) digit=4; people=(";Maya;;" ";Jonas;;" ";Aiko;;" ";Sam;;" ";Lea;;" ";Ana;;" ";Ben;;" ";Chloe;;" ";Leo;;") ;;
  esac
  : >"$card"
  local n=0 family given ff gg
  for person in "${people[@]}"; do
    n=$((n + 1))
    IFS=';' read -r family given ff gg <<<"$person"
    {
      printf 'BEGIN:VCARD\nVERSION:3.0\nN:%s;%s;;;\nFN:%s\n' "$family" "$given" "$(echo "$given $family" | xargs)"
      [ -n "$ff" ] && printf 'X-PHONETIC-LAST-NAME:%s\nX-PHONETIC-FIRST-NAME:%s\n' "$ff" "$gg"
      printf 'TEL;TYPE=CELL:+120255501%d%d\nEND:VCARD\n' "$digit" "$n"
    } >>"$card"
  done
  xcrun simctl addmedia "$udid" "$card" && touch "$marker"
}

for lang in "${langs[@]}"; do
  case "$lang" in
    id) own="id_ID@sw=QWERTY;hw=Automatic" ;;
    ja) own="ja_JP-Kana@sw=Kana;hw=Automatic" ;;
    *) own="en_US@sw=QWERTY;hw=Automatic" ;;
  esac
  # One system keyboard of the language and Cutling, so the held globe's list has two rows.
  xcrun simctl spawn "$udid" defaults write -g AppleKeyboards -array "$own" "$kb"
  # Safari starts each language with no tabs: earlier runs left a stack of them, one a "can't open page" tab, and the
  # iPad's ja take never reached its page (2026-11-23).
  xcrun simctl terminate "$udid" com.apple.mobilesafari >/dev/null 2>&1 || true
  # The tabs live in the simulator's own Library/Safari (SafariTabs.db, BrowserState.db), not in Safari's app
  # container: other jobs' tabs ("ChatGPT", 127.0.0.1) showed in the iPad's tab bar on film (2026-11-27).
  rm -f "$data"/Library/Safari/SafariTabs.db* "$data"/Library/Safari/BrowserState.db* 2>/dev/null
  # The system in the take's language and region (the status bar's 9:41, the globe list, the edit menu), as
  # directions.md asks; SpringBoard restarts to read it, and finish puts the simulator's own setting back.
  case "$lang" in id) region=id_ID ;; ja) region=ja_JP ;; *) region=en_US ;; esac
  xcrun simctl spawn "$udid" defaults write -g AppleLanguages -array "$lang"
  xcrun simctl spawn "$udid" defaults write -g AppleLocale -string "$region"
  xcrun simctl spawn "$udid" launchctl stop com.apple.SpringBoard 2>/dev/null; sleep 8
  contacts "$lang"
  xcrun simctl status_bar "$udid" override --time 9:41 --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100
  stem="$out/$form-$lang"
  rm -f "$stem".film "$stem".cut "$stem".rolling "$stem".stopped
  log="$stem.test.log"
  TEST_RUNNER_EVERY_LANG="$lang" TEST_RUNNER_EVERY_DIR="$out" TEST_RUNNER_EVERY_PORT="$port" TEST_RUNNER_EVERY_BEATS="${EVERY_BEATS:-}" \
    xcodebuild test-without-building -xctestrun "$xctestrun" -destination "id=$udid" -parallel-testing-enabled NO \
    -test-timeouts-enabled NO -only-testing:"CutlingUITests/PromoEveryAppUITests/$test" >"$log" 2>&1 &
  pid=$!; start=$SECONDS; last=$SECONDS
  # The camera: the test's .film file starts simctl's recording, its .cut file stops it.
  while kill -0 $pid 2>/dev/null; do
    if [ -f "$stem.film" ] && [ -z "$rec" ]; then
      rm -f "$stem.film"
      xcrun simctl io "$udid" recordVideo --codec=h264 --force "$stem.mov" 2>"$stem.reclog" &
      rec=$!
      for _ in $(seq 1 100); do grep -q "Recording started" "$stem.reclog" 2>/dev/null && break; sleep 0.1; done
      python3 -c 'import time; print("%.3f" % time.time())' >"$stem.t0"
      touch "$stem.rolling"; echo "$lang: camera on"
    fi
    if [ -f "$stem.cut" ] && [ -n "$rec" ]; then
      rm -f "$stem.cut"
      kill -INT "$rec" 2>/dev/null; wait "$rec" 2>/dev/null; rec=""
      touch "$stem.stopped"; echo "$lang: camera off"
    fi
    if [ $((SECONDS - last)) -ge 20 ]; then last=$SECONDS; echo "$lang: $((SECONDS - start)) s"; fi
    sleep 0.1
  done
  wait $pid; status=$?
  [ -n "$rec" ] && { kill -INT "$rec" 2>/dev/null; wait "$rec" 2>/dev/null; rec=""; }
  grep -E "error:|Test Case .* (passed|failed)" "$log" | grep -v debugger | head -8
  echo "$lang exit $status"
done
