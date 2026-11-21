#!/usr/bin/env python3
"""Renders the portrait direction-B iPhone and iPad screenshots (ASG94) for English.

    python3 fastlane/compose/tall/render.py

tall.py writes cutling/{iphone,ipad}/panel-N.html from cutling/tall.json; headless Chrome
(render_cdp.mjs, run with bun) renders them to fastlane/screenshots_tall/en-US/<device>/0N.png
at 1320x2868 and 2064x2752. The upload lanes still read the framed set in
fastlane/screenshots; this set replaces it only once the owner approves it.
"""
import json, os, subprocess, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
OUT = os.path.join(ROOT, "fastlane", "screenshots_tall", "en-US")
SIZES = {"iphone": (440, 956, 3), "ipad": (1032, 1376, 2)}


def main():
    subprocess.run([sys.executable, os.path.join(HERE, "tall.py"), os.path.join(HERE, "cutling", "tall.json")], check=True)
    jobs = []
    for dev, (w, h, scale) in SIZES.items():
        pages = os.path.join(HERE, "cutling", dev)
        os.makedirs(os.path.join(OUT, dev), exist_ok=True)
        for name in sorted(os.listdir(pages)):
            n = int(name.split("-")[1].split(".")[0])
            jobs.append(dict(page=os.path.join(pages, name), png=os.path.join(OUT, dev, "%02d.png" % n), w=w, h=h, scale=scale))
    work = tempfile.mkdtemp(prefix="cutling-tall-")
    jp, rp = os.path.join(work, "jobs.json"), os.path.join(work, "results.json")
    json.dump(jobs, open(jp, "w"))
    subprocess.run(["bun", os.path.join(HERE, "..", "render_cdp.mjs"), jp, rp, "1"], check=True, stdout=subprocess.DEVNULL)
    bad = 0
    for job, r in zip(jobs, json.load(open(rp))):
        ok = r["ok"]
        bad += not ok
        px = [c["px"] for c in r["boxes"]["copy"]] if r.get("boxes") else []
        print("OK  " if ok else "FAIL", os.path.relpath(job["png"], ROOT), px, "" if ok else r.get("error"))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
