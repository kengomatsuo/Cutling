#!/usr/bin/env python3
"""Adds the setup guide's and What's New sheet's strings, written per language from
docs/onboarding-strings-brief.md into docs/research/onboarding/strings/<language>.json, to each locale's
Cutling/<folder>.lproj/Localizable.strings. A key the locale already has is left as it is.

    python3 -I scripts/merge-onboarding-strings.py
"""
import json, pathlib, re, sys

repo = pathlib.Path(__file__).resolve().parent.parent
# Brief ID -> the key the Swift code looks up (its English literal, %@ for each interpolation).
KEYS = {
    "W1": "Welcome to Cutling", "W2": "Tap to Type",
    "W3": "Save what you type over and over, then tap it on the keyboard in any app.",
    "W4": "Images Too", "W5": "Copy a saved image with one tap and paste it anywhere.",
    "W6": "Stays on Your iPhone",
    "W7": "No account, no internet. Your cutlings sync only through your own iCloud.",
    "A1": "Add the Keyboard", "A2": "Turn on Cutling in Settings, then come back.",
    "A3": "About Full Access", "A4": "Open Settings",
    "A5": "Video of the Settings steps: tap Keyboards, turn on Cutling, then turn on Allow Full Access and tap Allow.",
    "A6": "Play the Settings steps",
    "F2": "Cutling types your text without it.", "F3": "Images and Clipboard",
    "F4": "Full Access lets the keyboard copy a saved image and add what you copied.",
    "F5": "Nothing Leaves Your iPhone",
    "F6": "Cutling has no account and never connects to the internet. It doesn't read what you type.",
    "F7": "Apple's Warning",
    "F8": "iOS shows the same warning for every keyboard that asks, whatever it does.",
    "T1": "Try It", "T2": "Type with Cutling here.", "T3": "Tap here",
    "T4": "Touch and hold %@ below, choose Cutling, then tap Try Me.",
    "T5": "Cutling typed it. You're set.", "T7": "Try Me", "T8": "Cutling typed this for me.",
    "N1": "What's New in Cutling", "N2": "Blanks to fill in, and far more room.",
    "N3": "Far more room, and every key types.", "N4": "Blanks and Dates",
    "N5": "Add a blank or today\u2019s date from the editor, and fill the blank in each time you type the cutling.",
    "N6": "Room for %@", "N7": "Save up to %@ texts and %@ images.", "N8": "Every Key Types",
    "N9": "Tap a formatted cutling and it types like the rest. Touch and hold it to copy the formatting.",
    "N10": "Welcome Back to Cutling", "N11": "Switch to Cutling",
    "N12": "Touch and hold the globe key on your keyboard, then choose Cutling.",
    "N14": "Tap a cutling and it's typed where you're writing.", "N15": "Save from Anywhere",
    "N16": "Share text, links or images to Cutling from any app.",
}

def check_keys():
    """Every key must be what the code asks for: its text, interpolations aside, is in a Swift file."""
    source = "".join(p.read_text() for p in (repo / "Cutling").glob("*.swift"))
    missing = [k for k, v in KEYS.items() if not all(part in source for part in v.split("%@") if part)]
    if missing:
        sys.exit(f"keys not found in Cutling/*.swift: {missing}")

def esc(s): return s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")

def main():
    check_keys()
    added = 0
    for path in sorted((repo / "docs/research/onboarding/strings").glob("*.json")):
        data = json.loads(path.read_text())
        strings = data["strings"]
        lost = [i for i in KEYS if i not in strings]
        if lost: sys.exit(f"{path.name}: no {lost}")
        for folder in data["folders"]:
            target = repo / "Cutling" / f"{folder}.lproj" / "Localizable.strings"
            text = target.read_text()
            have = set(re.findall(r'^"((?:[^"\\]|\\.)*)"\s*=', text, re.M))
            lines = [f'"{esc(KEYS[i])}" = "{esc(v)}";' for i, v in strings.items()
                     if i in KEYS and esc(KEYS[i]) not in have]
            if not lines: continue
            block = "\n/* MARK: - Setup guide and What's New (docs/onboarding-strings-brief.md) */\n" + "\n".join(lines) + "\n"
            target.write_text(text.rstrip("\n") + "\n" + block)
            added += len(lines)
            print(f"{folder}: {len(lines)}")
    print(f"added {added}")

main()
