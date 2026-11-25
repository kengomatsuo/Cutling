#!/usr/bin/env python3
"""names-type-helper.py <request.json> <done file> <udid>   types the keys a UI test hands over, at the speed it names.

XCUITest's touch costs 0.43 s, more than the 0.33 s a key gets at the 36.2 words a minute English typists average (Palin et al.
2019), so PromoNamesFilmsUITests writes the points of the keys it found ({"slot": s, "keys": [{"label", "x", "y"}]}) and waits for the
done file; this touches them with axe, one every `slot` seconds from a fixed start (a touch that takes longer than a slot would show),
and prints a `MARK <wall clock> key <label> at <x>,<y>` line for each, as the test's own typing did."""
import json, os, subprocess, sys, time
req, done, udid = sys.argv[1:4]
while not os.path.exists(req): time.sleep(0.05)
time.sleep(0.2)
plan = json.load(open(req)); os.remove(req)
start = time.time() + 0.3
for i, k in enumerate(plan["keys"]):
    time.sleep(max(0, start + i * plan["slot"] - time.time()))
    print(f"MARK {time.time():.6f} key {k['label']} at {int(k['x'])},{int(k['y'])}", flush=True)
    subprocess.run(["axe", "tap", "-x", str(k["x"]), "-y", str(k["y"]), "--udid", udid], capture_output=True)
open(done, "w").write("done")
