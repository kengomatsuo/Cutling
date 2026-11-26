#!/usr/bin/env python3
"""Panorama store sets (ASG250 custom product pages, ASG252 main page): one picture across every frame.

    python3 build.py <page> [locale ...|--all] [--only iphone|ipad] [--no-render]
    python3 build.py sheet <page> [--only iphone|ipad]       contact sheets, one per device
    python3 build.py publish main [locale ...|--all]          main page frames -> fastlane/frames/<locale>/{iphone,ipad}-NN.png

Pages and the candidate each is built from:
    main               Don't type it (poster)       50 store languages   frames 8 + 8
    text-expander      Don't type it, own words     en-US en-GB en-AU en-CA   frames 6 + 6
    personal-details   Keys (path-traced, keys.py)  50 store languages   frames 6 + 6
    notes-you-paste    Keys                         en-US en-GB en-AU en-CA   frames 6 + 6
    quick-replies      Night flight (night.py)      50 store languages   frames 6 + 6
    clipboard-history  Night flight                 en-US en-GB en-AU en-CA   frames 6 + 6
Frames: out/<page>/<locale>/{iphone,ipad}/NN.png. Each set is one page N frames wide (pano.html beside its frames)."""
import json, shutil, subprocess, sys
from pathlib import Path

import lib
import poster
import keys
import night

PAGES = {
    "main": dict(module=poster, locales=lib.STORE),
    "text-expander": dict(module=poster, fn="build_te", locales=lib.ENGLISH),
    "personal-details": dict(keys="pd", locales=lib.STORE),
    "notes-you-paste": dict(keys="np", locales=lib.ENGLISH),
    "quick-replies": dict(night="qr", locales=lib.STORE),
    "clipboard-history": dict(night="ch", locales=lib.ENGLISH),
}


def main():
    a = [x for x in sys.argv[1:] if not x.startswith("--") and x not in ("iphone", "ipad")]
    only = sys.argv[sys.argv.index("--only") + 1] if "--only" in sys.argv else None
    cmd = a[0]
    if cmd == "sheet":
        for page in a[1:]:
            sheet(page, only)
        return
    if cmd == "publish":
        publish(a[1], a[2:] or (PAGES[a[1]]["locales"] if "--all" in sys.argv else ["en-US"]))
        return
    page = PAGES[cmd]
    locs = page["locales"] if "--all" in sys.argv else (a[1:] or ["en-US"])
    if "keys" in page or "night" in page:   # atlases or drawn screens first (one batch), then the frames that read them
        comps = []
        for loc in locs:
            for dev in ("iphone", "ipad"):
                if not only or dev == only:
                    if "keys" in page:
                        comps += keys.build(loc, dev, lib.HERE / "out" / cmd / loc / dev, page["keys"])
                    else:
                        comps += night.build(loc, dev, lib.HERE / "out" / cmd / loc / dev, page["night"])
        lib.run()
        lib.m.JOBS.extend(comps)
        lib.run()
        for c in night.CROPS:
            subprocess.run(c, check=True)
            Path(c[1]).unlink()
        return
    for loc in locs:
        for dev in ("iphone", "ipad"):
            if only and dev != only:
                continue
            getattr(page["module"], page.get("fn", "build"))(loc, dev, lib.HERE / "out" / cmd / loc / dev)
    if "--no-render" not in sys.argv:
        lib.run()
    fb = sorted(set(lib.FALLBACKS))
    if fb:
        (lib.HERE / "out" / cmd / "fallbacks.json").write_text(json.dumps(fb, indent=1))
        print(f"{len(fb)} captures from another language: out/{cmd}/fallbacks.json")


def sheet(page, only=None):
    """One picture per device: each language a row of its frames edge to edge (so every seam can be judged), labelled."""
    root = lib.HERE / "out" / page
    locs = [p.name for p in sorted(root.iterdir()) if p.is_dir()]
    for dev in ("iphone", "ipad"):
        if only and dev != only:
            continue
        rows = []
        for loc in locs:
            fr = sorted((root / loc / dev).glob("[0-9][0-9].png"))
            if loc in lib.RTL:   # the store lays these out from the right: frame 1 on the right, so the seams meet
                fr = fr[::-1]
            if fr:
                rows.append((loc, fr))
        if not rows:
            continue
        th = (300 if dev == "iphone" else 360) if len(rows) <= 8 else (220 if dev == "iphone" else 260)
        tmp = root / f".sheet-{dev}"
        tmp.mkdir(exist_ok=True)
        row_pngs = []
        for loc, fr in rows:
            rp = tmp / f"{loc}.png"
            subprocess.run(["magick", *map(str, fr), "-resize", f"{th}x", "+append",
                            "-gravity", "NorthWest", "-background", "#111", "-splice", "0x54",
                            "-font", "/System/Library/Fonts/SFNS.ttf", "-pointsize", "34", "-fill", "#fff", "-annotate", "+14+8",
                            f"{page}  {loc}  {dev}  " + ("frames in store order, right to left: " + " ".join(f"{len(fr)-i}" for i in range(len(fr))) if loc in lib.RTL else "frames " + " ".join(f"{i+1}" for i in range(len(fr)))), str(rp)], check=True)
            row_pngs.append(str(rp))
        out = root / f"sheet-{dev}.png"
        if len(row_pngs) > 8:   # many languages: two columns of rows, so the sheet stays a picture one can open
            h = (len(row_pngs) + 1) // 2
            cols = []
            for c, part in enumerate((row_pngs[:h], row_pngs[h:])):
                cp = tmp / f"col{c}.png"
                subprocess.run(["magick", *part, "-background", "#111", "-append", "-gravity", "East", "-splice", "40x0", str(cp)], check=True)
                cols.append(str(cp))
            subprocess.run(["magick", *cols, "-background", "#111", "-gravity", "North", "+append", str(out)], check=True)
        else:
            subprocess.run(["magick", *row_pngs, "-background", "#111", "-gravity", "West", "-splice", "0x0", "-append", str(out)], check=True)
        shutil.rmtree(tmp)
        print(out)


def publish(page, locs):
    """The main page's frames into fastlane/frames/<locale>/, the folder the upload lanes read; the Mac keeps C's."""
    assert page == "main"
    for loc in locs:
        dst = lib.REPO / "fastlane/frames" / loc
        dst.mkdir(parents=True, exist_ok=True)
        for dev in ("iphone", "ipad"):
            for old in dst.glob(f"{dev}-*.png"):
                old.unlink()
            for f in sorted((lib.HERE / "out" / page / loc / dev).glob("[0-9][0-9].png")):
                shutil.copy(f, dst / f"{dev}-{f.name}")


if __name__ == "__main__":
    main()
