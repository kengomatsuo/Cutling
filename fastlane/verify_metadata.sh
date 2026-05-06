#!/bin/bash
# Verify App Store metadata character limits across all locales.
#
# Limits (Apple App Store):
#   name.txt     — 30 characters
#   subtitle.txt — 30 characters
#   keywords.txt — 100 characters
#
# Usage: ./fastlane/verify_metadata.sh

set -uo pipefail

METADATA_DIR="fastlane/metadata"

python3 - "$METADATA_DIR" <<'PYEOF'
import os, sys

metadata_dir = sys.argv[1]
limits = {"name.txt": 30, "subtitle.txt": 30, "keywords.txt": 100}
errors = 0
locales = 0

RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
NC = "\033[0m"

for locale in sorted(os.listdir(metadata_dir)):
    locale_dir = os.path.join(metadata_dir, locale)
    if not os.path.isdir(locale_dir):
        continue
    locales += 1

    # Check character limits
    for fname, max_len in limits.items():
        fpath = os.path.join(locale_dir, fname)
        if not os.path.isfile(fpath):
            continue
        with open(fpath, encoding="utf-8") as f:
            content = f.readline().rstrip("\n")
        length = len(content)
        if length > max_len:
            print(f"{RED}FAIL{NC} {locale}/{fname.replace('.txt','')} — {length}/{max_len} chars: {content}")
            errors += 1
        elif length == 0:
            print(f"{YELLOW}WARN{NC} {locale}/{fname.replace('.txt','')} — empty")

    # Check for Latin-word duplication between name/subtitle and keywords
    def read_first_line(fname):
        fpath = os.path.join(locale_dir, fname)
        if not os.path.isfile(fpath):
            return ""
        with open(fpath, encoding="utf-8") as f:
            return f.readline().rstrip("\n").lower()

    import re
    name_text = read_first_line("name.txt")
    sub_text = read_first_line("subtitle.txt")
    kw_text = read_first_line("keywords.txt")

    name_words = set(w for w in re.findall(r'[a-z]{3,}', name_text))
    sub_words = set(w for w in re.findall(r'[a-z]{3,}', sub_text))
    kw_list = [kw.strip() for kw in kw_text.split(",") if kw.strip()]

    for kw in kw_list:
        kw_lower = kw.lower()
        if re.fullmatch(r'[a-z]+', kw_lower):
            if kw_lower in name_words:
                print(f"{YELLOW}DUPE{NC} {locale} — '{kw}' in both keywords and name")
            if kw_lower in sub_words:
                print(f"{YELLOW}DUPE{NC} {locale} — '{kw}' in both keywords and subtitle")

print()
if errors > 0:
    print(f"{RED}{errors} error(s) found across {locales} locales.{NC}")
    sys.exit(1)
else:
    print(f"{GREEN}All {locales} locales pass character limits.{NC}")
PYEOF
