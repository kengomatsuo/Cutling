#!/usr/bin/env python3
"""
Translate release_notes.txt from en-US to all App Store Connect languages.

Reads locales.json as the single source of truth for supported languages,
translates the English release notes via Google Translate, and writes
each translation to fastlane/metadata/<locale>/release_notes.txt.

Requires: source docs/_generator/.venv/bin/activate && pip install deep-translator

Usage:
    python3 translate_release_notes.py            # iOS notes, all languages
    python3 translate_release_notes.py ja de-DE   # iOS notes, specific locales
    python3 translate_release_notes.py --mac      # macOS notes (fastlane/metadata_mac)
    python3 translate_release_notes.py --mac ja   # macOS notes, specific locales
    python3 translate_release_notes.py --mac --file promotional_text.txt   # any metadata file
"""

import json
import re
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from deep_translator import GoogleTranslator

REPO_ROOT = Path(__file__).parent
LOCALES_FILE = REPO_ROOT / "locales.json"
METADATA_DIR = REPO_ROOT / "fastlane" / "metadata"
SOURCE_LOCALE = "en-US"

GOOGLE_LANG_MAP = {
    "ar-SA": "ar",
    "bn-BD": "bn",
    "de-DE": "de",
    "es-ES": "es",
    "es-MX": "es",
    "fil": "tl",
    "fr-CA": "fr",
    "fr-FR": "fr",
    "gu-IN": "gu",
    "he": "iw",
    "kn-IN": "kn",
    "ml-IN": "ml",
    "mr-IN": "mr",
    "nl-NL": "nl",
    "no": "no",
    "or-IN": "or",
    "pa-IN": "pa",
    "pt-BR": "pt",
    "sl-SI": "sl",
    "ta-IN": "ta",
    "te-IN": "te",
    "ur-PK": "ur",
    "zh-Hans": "zh-CN",
    "zh-Hant": "zh-TW",
}

WORKERS = 5


def load_locales():
    with open(LOCALES_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def google_code(locale):
    return GOOGLE_LANG_MAP.get(locale, locale.split("-")[0])


# Google renders the product noun however it likes — Japanese came back
# "カトリング" where the app itself ships "カットリング", and Chinese turned it into
# 切割 ("cutting"). The noun is swapped for a sentinel before translating (it
# survives every language intact) and replaced afterwards with the term the app
# actually uses on screen, read straight out of Localizable.strings.
#
# Only LOWERCASE "cutling"/"cutlings" is protected — that's the item. A
# capitalized "Cutling" is the app name and must stay Latin, which is the same
# convention the English sources already follow.
BRAND_SENTINEL = "ZQXBRANDZQX"
LPROJ_ROOT = REPO_ROOT / "Cutling"


def canonical_brand(locale):
    """The on-screen product noun for this locale, or None to leave it alone."""
    for candidate in (locale, locale.split("-")[0]):
        path = LPROJ_ROOT / f"{candidate}.lproj" / "Localizable.strings"
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        match = re.search(r'^"Cutlings"\s*=\s*"([^"]+)";', text, re.M)
        if match:
            return match.group(1)
    return None


def protect_brand(text):
    return re.sub(r"\bcutlings?\b", BRAND_SENTINEL, text)


# Japanese and Chinese don't put spaces between words, but Google surrounds the
# Latin sentinel with them ("キーワード ZQXBRANDZQX の名前"). Drop a space that sits
# between the sentinel and an adjacent CJK character before substituting.
_CJK = r"[　-〿぀-ヿ㐀-䶿一-鿿＀-￯]"


def restore_brand(text, locale):
    term = canonical_brand(locale) or "Cutling"
    text = re.sub(rf"(?<={_CJK})\s+{BRAND_SENTINEL}", BRAND_SENTINEL, text)
    text = re.sub(rf"{BRAND_SENTINEL}\s+(?={_CJK})", BRAND_SENTINEL, text)
    return text.replace(BRAND_SENTINEL, term)


def translate_locale(locale, source_text, metadata_dir, filename="release_notes.txt"):
    target = google_code(locale)
    try:
        translator = GoogleTranslator(source="en", target=target)
        # Translate one line at a time rather than posting the whole block.
        # Handing Google a multi-line blob made it return SIMPLIFIED Chinese
        # for most of a zh-TW request (only the last line came back
        # Traditional), which shipped the wrong script to the zh-Hant
        # listing. Per-line requests return correct Traditional output, and
        # keeping the split here also preserves the bullet layout exactly.
        out_lines = []
        for line in source_text.split("\n"):
            if not line.strip():
                out_lines.append("")
                continue
            out_lines.append(restore_brand(translator.translate(protect_brand(line)), locale))
        translated = "\n".join(out_lines)
        out_dir = metadata_dir / locale
        out_dir.mkdir(parents=True, exist_ok=True)
        (out_dir / filename).write_text(translated + "\n", encoding="utf-8")
        return locale, True, None
    except Exception as e:
        return locale, False, str(e)


def main():
    # `--mac` targets the macOS App Store metadata tree (fastlane/metadata_mac);
    # without it we translate the iOS tree (fastlane/metadata). The two stores
    # carry different copy, so they live in separate trees. `--file <name>`
    # picks which metadata file to translate (default release_notes.txt), so
    # the same flow works for promotional_text.txt etc.
    args = [a for a in sys.argv[1:] if a != "--mac"]
    is_mac = "--mac" in sys.argv[1:]
    metadata_dir = REPO_ROOT / "fastlane" / ("metadata_mac" if is_mac else "metadata")

    filename = "release_notes.txt"
    if "--file" in args:
        i = args.index("--file")
        filename = args[i + 1]
        del args[i:i + 2]

    locales = load_locales()
    all_codes = [l["code"] for l in locales]

    source_path = metadata_dir / SOURCE_LOCALE / filename
    source_text = source_path.read_text(encoding="utf-8").strip()

    # English variants get a direct copy
    english_variants = [c for c in all_codes if c.startswith("en-") and c != SOURCE_LOCALE]
    for code in english_variants:
        out_dir = metadata_dir / code
        out_dir.mkdir(parents=True, exist_ok=True)
        (out_dir / filename).write_text(source_text + "\n", encoding="utf-8")
        print(f"  = {code} (copy)")

    non_english = [c for c in all_codes if not c.startswith("en")]

    if args:
        requested = set(args)
        non_english = [c for c in non_english if c in requested]

    print(f"\n{'macOS' if is_mac else 'iOS'} {filename} source ({SOURCE_LOCALE}) -> {metadata_dir.name}:\n{source_text}\n")
    print(f"Translating to {len(non_english)} languages...\n")

    with ThreadPoolExecutor(max_workers=WORKERS) as pool:
        futures = {
            pool.submit(translate_locale, locale, source_text, metadata_dir, filename): locale
            for locale in non_english
        }
        for future in as_completed(futures):
            locale, ok, err = future.result()
            if ok:
                print(f"  ✓ {locale}")
            else:
                print(f"  ✗ {locale}: {err}")

    print(f"\nDone! Translated release notes to {len(non_english)} languages.")


if __name__ == "__main__":
    main()
