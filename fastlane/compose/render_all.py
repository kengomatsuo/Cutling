#!/usr/bin/env python3
"""Builds compositor jobs for every device, locale and store page, then runs them.

Usage: render_all.py <compose-binary> [locale ...]

Captions come from docs/aso/data/writers/*.json and writers-en.json.
- iPhone and iPad: fastlane/screenshots/<loc>/<Device>-0N_<frame>.png becomes
  <Device>-0N_<frame>_framed.png beside it, which the upload lanes already read.
- Mac: fastlane/screenshots_mac/raw/<loc>/0N_*.png becomes fastlane/screenshots_mac/<loc>/0N_*.png.
- Custom product pages: fastlane/screenshots_cpp/<page>/<loc>/<Device>-0N.png.
"""
import glob
import json
import os
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SHOTS = os.path.join(ROOT, "fastlane", "screenshots")
MAC = os.path.join(ROOT, "fastlane", "screenshots_mac")
CPP = os.path.join(ROOT, "fastlane", "screenshots_cpp")
WRITERS = os.path.join(ROOT, "docs", "aso", "data")

FRAMES = ["01_KeyboardInMessages", "02_MainGrid", "03_DetailView", "04_KeyboardGuide", "05_KeyboardSettings"]
CAPTION_KEYS = ["f1", "f2", "f3", "f4", "f5"]
DEVICES = {"iPhone 14 Pro Max": "iphone", "iPad Air 13-inch (M4)": "ipad"}
MAC_FRAMES = ["01_Picker", "02_History", "03_Editor", "04_Dark", "05_Sync"]
# Each page leads with its own caption, then the frames that serve its intent
CPP_ORDER = {"replies": [0, 4, 1, 2, 3], "details": [0, 1, 4, 2, 3]}


def copy_for():
    out = json.load(open(os.path.join(WRITERS, "writers-en.json")))
    for f in sorted(glob.glob(os.path.join(WRITERS, "writers", "*.json"))):
        out.update(json.load(open(f)))
    return out


def jobs(locales):
    text = copy_for()
    out = []
    for loc in locales:
        c = text.get(loc)
        if not c:
            print(f"skip {loc}: no copy", file=sys.stderr)
            continue
        for device, kind in DEVICES.items():
            for i, frame in enumerate(FRAMES):
                raw = os.path.join(SHOTS, loc, f"{device}-{frame}.png")
                if not os.path.exists(raw):
                    continue
                title, sub = c["captions"][CAPTION_KEYS[i]]
                out.append(dict(input=raw, output=raw.replace(".png", "_framed.png"),
                                device=kind, title=title, subtitle=sub, lang=loc))
            for page, order in CPP_ORDER.items():
                for slot, i in enumerate(order):
                    raw = os.path.join(SHOTS, loc, f"{device}-{FRAMES[i]}.png")
                    if not os.path.exists(raw):
                        continue
                    title, sub = c[f"cpp_{page}"]["f1"] if slot == 0 else c["captions"][CAPTION_KEYS[i]]
                    out.append(dict(input=raw, output=os.path.join(CPP, page, loc, f"{device}-0{slot + 1}.png"),
                                    device=kind, title=title, subtitle=sub, lang=loc))
        for i, frame in enumerate(MAC_FRAMES):
            raw = os.path.join(MAC, "raw", loc, f"{frame}.png")
            if not os.path.exists(raw):
                continue
            title, sub = c["mac"][f"m{i + 1}"]
            out.append(dict(input=raw, output=os.path.join(MAC, loc, f"{frame}.png"),
                            device="mac", title=title, subtitle=sub, lang=loc))
    return out


if __name__ == "__main__":
    binary = sys.argv[1]
    locales = sys.argv[2:] or sorted(d for d in os.listdir(os.path.join(ROOT, "fastlane", "metadata"))
                                     if not d.startswith("."))
    todo = jobs(locales)
    with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as f:
        json.dump(todo, f, ensure_ascii=False)
    subprocess.run([binary, f.name], check=True)
