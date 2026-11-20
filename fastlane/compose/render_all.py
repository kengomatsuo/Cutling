#!/usr/bin/env python3
"""Builds compositor jobs for every device, locale and store page, then runs them.

Usage: render_all.py <compose-binary> [--mac-only] [locale ...]

Captions come from docs/aso/data/writers/*.json and writers-en.json.
- iPhone and iPad: fastlane/screenshots/<loc>/<Device>-0N_<frame>.png becomes
  <Device>-0N_<frame>_framed.png beside it, which the upload lanes already read.
- Mac: the pages in fastlane/compose/mac (direction B, the app on a desktop) are filled
  with fastlane/screenshots_mac/raw/<loc>/0N_*.png and that locale's iPhone grid, and
  headless Chrome renders them to fastlane/screenshots_mac/<loc>/0N_*.png at 2880x1800.
- Custom product pages: fastlane/screenshots_cpp/<page>/<loc>/<Device>-0N.png.
"""
import glob
import html
import json
import os
import subprocess
import sys
import tempfile
from urllib.parse import quote

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SHOTS = os.path.join(ROOT, "fastlane", "screenshots")
MAC = os.path.join(ROOT, "fastlane", "screenshots_mac")
CPP = os.path.join(ROOT, "fastlane", "screenshots_cpp")
WRITERS = os.path.join(ROOT, "docs", "aso", "data")

FRAMES = ["01_KeyboardInMessages", "02_MainGrid", "03_DetailView", "04_KeyboardGuide", "05_KeyboardSettings"]
CAPTION_KEYS = ["f1", "f2", "f3", "f4", "f5"]
DEVICES = {"iPhone 14 Pro Max": "iphone", "iPad Air 13-inch (M4)": "ipad"}
MAC_FRAMES = ["01_Picker", "02_History", "03_Editor", "04_Dark", "05_Sync"]
MAC_PAGES = os.path.join(ROOT, "fastlane", "compose", "mac")
MAC_PHONE = "iPhone 14 Pro Max-02_MainGrid.png"  # frame 5 shows the same cutlings on iPhone
RTL = ("ar", "he", "fa", "ur")
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
    return out


def url(path):
    return "file://" + quote(path)


def mac_jobs(locales, work):
    """One filled page per Mac frame, for render_cdp.mjs."""
    text = copy_for()
    out = []
    for loc in locales:
        c, raw = text.get(loc), os.path.join(MAC, "raw", loc)
        if not c or not os.path.isdir(raw):
            continue
        phone = os.path.join(SHOTS, loc, MAC_PHONE)
        if not os.path.exists(phone):
            phone = os.path.join(SHOTS, "en-US", MAC_PHONE)
        os.makedirs(os.path.join(MAC, loc), exist_ok=True)
        for i, frame in enumerate(MAC_FRAMES):
            title, sub = c["mac"][f"m{i + 1}"]
            page = open(os.path.join(MAC_PAGES, f"panel-{i + 1}.html"), encoding="utf-8").read()
            fill = {"{{BASE}}": url(MAC_PAGES + "/"), "{{RAW}}": url(raw), "{{PHONE}}": url(phone),
                    "{{LANG}}": loc, "{{TITLE}}": html.escape(title), "{{SUB}}": html.escape(sub)}
            for k, v in fill.items():
                page = page.replace(k, v)
            if loc.split("-")[0] in RTL:
                page = page.replace('class="wrap"', 'class="wrap" dir="rtl"')
            path = os.path.join(work, f"{loc}-{i + 1}.html")
            open(path, "w", encoding="utf-8").write(page)
            out.append(dict(page=path, png=os.path.join(MAC, loc, f"{frame}.png"), w=1440, h=900, scale=2))
    return out


def render_mac(locales):
    work = tempfile.mkdtemp(prefix="cutling-mac-")
    todo = mac_jobs(locales, work)
    jobs_path, results_path = os.path.join(work, "jobs.json"), os.path.join(work, "results.json")
    json.dump(todo, open(jobs_path, "w"))
    subprocess.run(["node", os.path.join(ROOT, "fastlane", "compose", "render_cdp.mjs"), jobs_path, results_path, "3"],
                   check=True)
    bad = [r for r in json.load(open(results_path)) if not r["ok"]]
    for r in bad:
        print("FAIL", r["page"], r.get("error"), (r.get("boxes") or {}).get("fitFailures"), file=sys.stderr)
    print(f"mac: {len(todo) - len(bad)} rendered, {len(bad)} failed")
    if "en-US" in locales and not render_cover(os.path.join(work, "en-US-1.html")):
        return False
    return not bad


COVER = os.path.join(ROOT, "fastlane", "listing-cover.png")  # 2880x1512, directories crop it to their own ratio
OG = os.path.join(ROOT, "web", "og.png")  # 1200x630 link preview


def render_cover(page):
    """Mac frame 01 rendered 1440x756 (#wide in mac/fit.js): the directory cover and the site's og:image."""
    jp, rp = page.replace(".html", "-cover.json"), page.replace(".html", "-cover-results.json")
    json.dump([dict(page=page + "#wide", png=COVER, w=1440, h=756, scale=2)], open(jp, "w"))
    subprocess.run(["node", os.path.join(ROOT, "fastlane", "compose", "render_cdp.mjs"), jp, rp, "1"], check=True)
    if not json.load(open(rp))[0]["ok"]:
        print("cover FAIL", json.load(open(rp))[0].get("error"), file=sys.stderr)
        return False
    subprocess.run(["sips", "-z", "630", "1200", COVER, "--out", OG], stdout=subprocess.DEVNULL, check=True)
    print("cover:", COVER, OG)
    return True


if __name__ == "__main__":
    binary, args = sys.argv[1], sys.argv[2:]
    mac_only = "--mac-only" in args
    locales = [a for a in args if a != "--mac-only"] or sorted(
        d for d in os.listdir(os.path.join(ROOT, "fastlane", "metadata")) if not d.startswith("."))
    if not mac_only:
        todo = jobs(locales)
        with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as f:
            json.dump(todo, f, ensure_ascii=False)
        subprocess.run([binary, f.name], check=True)
    sys.exit(0 if render_mac(locales) else 1)
