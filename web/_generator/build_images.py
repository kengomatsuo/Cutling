#!/usr/bin/env python3
"""
Copies each locale's App Store captures into the site as small WebP files.

The iPhone shots come from fastlane/screenshots/<locale>/ (snapshot), the Mac
shots from fastlane/screenshots_mac/raw/<locale>/ (the panel without its caption). A locale without its own
captures borrows its base language's, then English. Output lands in
<output>/img/<lowercased-locale>/, the folder the {{IMG}} placeholder names.

Usage:
    python3 web/_generator/build_images.py --output-dir dist
"""

import argparse
import json
import shutil
import subprocess
import tempfile
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
REPO_ROOT = SCRIPT_DIR.parent.parent
IPHONE_DIR = REPO_ROOT / "fastlane" / "screenshots"
MAC_DIR = REPO_ROOT / "fastlane" / "screenshots_mac" / "raw"

# Site file name -> (source folder, file name, width)
SHOTS = {
    "keyboard": (IPHONE_DIR, "iPhone 14 Pro Max-01_KeyboardInMessages.png", 720),
    "grid": (IPHONE_DIR, "iPhone 14 Pro Max-02_MainGrid.png", 720),
    "editor": (IPHONE_DIR, "iPhone 14 Pro Max-03_DetailView.png", 720),
    "settings": (IPHONE_DIR, "iPhone 14 Pro Max-05_KeyboardSettings.png", 720),
    "mac-picker": (MAC_DIR, "01_Picker.png", 720),
    "mac-history": (MAC_DIR, "02_History.png", 720),
}


def source_for(folder, locale, name):
    """The locale's own capture, else its base language's, else English."""
    candidates = [locale, locale.split("-")[0], "en-US"]
    if folder.exists():
        base = locale.split("-")[0]
        candidates[2:2] = sorted(p.name for p in folder.iterdir() if p.is_dir() and p.name.split("-")[0] == base)
    for code in candidates:
        path = folder / code / name
        if path.exists():
            return path
    return None


def to_webp(src, dest, width):
    with tempfile.TemporaryDirectory() as tmp:
        resized = Path(tmp) / "resized.png"
        subprocess.run(["sips", "-Z", str(width), str(src), "--out", str(resized)], check=True, capture_output=True)
        subprocess.run(["cwebp", "-quiet", "-q", "82", str(resized), "-o", str(dest)], check=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", required=True)
    args = parser.parse_args()
    out = Path(args.output_dir) / "img"
    locales = [loc["code"] for loc in json.loads((REPO_ROOT / "locales.json").read_text())]
    cache = {}
    for locale in locales:
        dest_dir = out / locale.lower()
        dest_dir.mkdir(parents=True, exist_ok=True)
        for site_name, (folder, file_name, width) in SHOTS.items():
            src = source_for(folder, locale, file_name)
            if src is None:
                print(f"  MISSING {site_name} for {locale}")
                continue
            dest = dest_dir / f"{site_name}.webp"
            if src in cache:
                shutil.copyfile(cache[src], dest)
            else:
                to_webp(src, dest, width)
                cache[src] = dest
    print(f"  Images for {len(locales)} locales in {out}")


if __name__ == "__main__":
    main()
