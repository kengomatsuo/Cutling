#!/bin/bash
# Runs scripts/frame04.sh for every store language on store-size simulators (iPhone 18 Pro Max for the 6.9-inch
# set, iPad Air 13-inch (M4) for the 13-inch set), then hands the device queue back its usual pool.
#
#   UI_TEST_BUILD=<build-for-testing dir> scripts/frame04-store.sh
#
# The queue keeps one iPhone and one iPad booted (~/claude-house-rules/docs/device-queue.md) and refuses a third,
# and its pool (an iPhone Duo and an iPad Pro 11-inch) is no App Store screenshot size. A runner picks its pool
# once, from DEVICE_QUEUE_SIM_SOURCE and DEVICE_QUEUE_IPAD, when it starts with tickets queued and none running.
# So this waits until no runner is alive, submits with the store simulators named, and once those tickets are
# done and the runner has left, submits a no-op with the usual pool named. Each wait polls once a minute.
set -u
repo="$(cd "$(dirname "$0")/.." && pwd)"
build="${UI_TEST_BUILD:?build-for-testing folder}"
dq() { bun ~/.claude/scripts/device-queue/device-queue.ts "$@"; }
runner_alive() { dq status ios-sim 2>/dev/null | head -1 | grep -q 'runner pid'; }
STORE_IPHONE=626CECA3-66AF-4284-921F-C7A8FD05FA08 STORE_IPAD=178ED08A-840F-43D6-8261-D3C4D641E295
POOL_IPHONE="${POOL_IPHONE:-$(python3 -c 'import json,os;print(json.load(open(os.path.expanduser("~/Shared/device-queue/ios-sim/pool.json")))[0])')}"
POOL_IPAD="${POOL_IPAD:-$(python3 -c 'import json,os;print(json.load(open(os.path.expanduser("~/Shared/device-queue/ios-sim/pool.json")))[1])')}"
locales=($(sed -n '/^languages(\[/,/^\])/p' "$repo/fastlane/Snapfile" | grep -oE '"[^"]+"' | tr -d '"'))
half=$(( ${#locales[@]} / 2 ))

until ! runner_alive; do echo "$(date +%H:%M) waiting for the queue runner to leave"; sleep 60; done
tickets=()
for form in iphone ipad; do
  for part in "${locales[*]:0:$half}" "${locales[*]:$half}"; do
    t=$(DEVICE_QUEUE_SIM_SOURCE=$STORE_IPHONE DEVICE_QUEUE_IPAD=$STORE_IPAD dq submit ios-sim --form $form --tree "$repo" \
      --who cutling-2-release --cap 120 --cmd "UI_TEST_BUILD=$build scripts/frame04.sh $part" | awk 'NR==1{print $1}')
    echo "submitted $form $t: $part"; tickets+=("$t")
  done
done
for t in "${tickets[@]}"; do dq wait "$t" --timeout 300 >/dev/null 2>&1; echo "$t: $(dq status "$t" | head -1)"; done

until ! runner_alive; do echo "$(date +%H:%M) waiting to hand the pool back"; sleep 60; done
t=$(DEVICE_QUEUE_SIM_SOURCE=$POOL_IPHONE DEVICE_QUEUE_IPAD=$POOL_IPAD dq submit ios-sim --tree "$repo" --who cutling-2-release --cap 5 --cmd true | awk 'NR==1{print $1}')
dq wait "$t" --timeout 30 >/dev/null 2>&1
echo "pool now: $(cat ~/Shared/device-queue/ios-sim/pool.json)"
for t in "${tickets[@]}"; do echo "$t -> ~/Shared/device-queue/ios-sim/$t/out"; done
