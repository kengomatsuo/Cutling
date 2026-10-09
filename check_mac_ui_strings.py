#!/usr/bin/env python3
"""
Fail when a UI string literal in Cutling/Mac/*.swift has no key in
Cutling/en.lproj/Localizable.strings.

A missing key renders in English in every locale, silently. check_localizations.py
then keeps the other 75 locales level with en. Ternary branches count: SwiftUI's
Text(String) init is @_disfavoredOverload, so `Text(c ? "A" : "B")` looks up both.

Usage:
    python3 check_mac_ui_strings.py
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
MAC = ROOT / "Cutling" / "Mac"
EN = ROOT / "Cutling" / "en.lproj" / "Localizable.strings"

# Debug-only, internal, or units only.
IGNORED = {
    "DEBUG",
    "Pasteboard generator type",
    r"\(Int(size.width)) × \(Int(size.height)) px",
}
IGNORED_PREFIXES = ("Debug build detected.",)

UI_CALL = re.compile(
    r"\b(Text|Label|Button|Toggle|Section|LabeledContent|Picker|Menu|Link|TextField|"
    r"ContentUnavailableView|Window|WindowGroup|help|navigationTitle|"
    r"confirmationDialog|alert)\s*\(|\bString\(localized:"
)
LITERAL = re.compile(r'"((?:[^"\\]|\\.)*)"')
# A literal on its own line, as a ternary branch or a wrapped argument.
BARE = re.compile(r'^\s*(?:[?:]\s*)?"((?:[^"\\]|\\.)*)"\s*,?\s*\)?\s*$')
NOT_UI_BEFORE = re.compile(r"(systemImage|id|forKey|named|image|icon):\s*$")


def en_keys() -> set:
    text = EN.read_text(encoding="utf-8")
    return {m.group(1) for m in re.finditer(r'^\s*"((?:[^"\\]|\\.)*)"\s*=', text, re.M)}


def candidates(literal: str) -> set:
    s = re.sub(r"\\u\{([0-9a-fA-F]+)\}", lambda m: chr(int(m.group(1), 16)), literal)
    return {s, re.sub(r"\\\(.*?\)", "%lld", s), re.sub(r"\\\(.*?\)", "%@", s)}


def needs_key(literal: str) -> bool:
    plain = re.sub(r"\\\(.*?\)", "", literal)
    if not re.search(r"[^\W\d_]{2}", plain):
        return False
    if " " not in literal and "." in literal:  # reverse-DNS, file names
        return False
    return literal not in IGNORED and not literal.startswith(IGNORED_PREFIXES)


def main() -> int:
    keys = en_keys()
    missing = []
    for path in sorted(MAC.glob("*.swift")):
        in_call = 0
        for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if line.lstrip().startswith("//"):
                continue
            code = line
            found = []
            for call in UI_CALL.finditer(code):
                for lit in LITERAL.finditer(code, call.end()):
                    if not NOT_UI_BEFORE.search(code[call.end():lit.start()]):
                        found.append(lit.group(1))
            if UI_CALL.search(code) and code.rstrip().endswith("("):
                in_call = 3
            elif in_call and (m := BARE.match(code)):
                found.append(m.group(1))
            in_call = max(in_call - 1, 0) if not code.rstrip().endswith(("?", ":", ",")) else in_call
            for lit in found:
                if needs_key(lit) and not candidates(lit) & keys:
                    missing.append(f"{path.relative_to(ROOT)}:{n}: {lit}")
    for m in dict.fromkeys(missing):
        print(m)
    if missing:
        print(f"\n{len(set(missing))} Mac UI string(s) missing from {EN.relative_to(ROOT)}")
        return 1
    print("All Mac UI strings have a key.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
