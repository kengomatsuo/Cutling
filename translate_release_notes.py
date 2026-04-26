#!/usr/bin/env python3
"""
Translate release_notes.txt from en-US to all App Store Connect languages.

Reads locales.json as the single source of truth for supported languages,
translates the English release notes via Google Translate, and writes
each translation to fastlane/metadata/<locale>/release_notes.txt.

Requires: source docs/_generator/.venv/bin/activate && pip install deep-translator

Usage:
    python3 translate_release_notes.py            # Translate all languages
    python3 translate_release_notes.py ja de-DE   # Translate specific locales only
"""

import json
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


def translate_locale(locale, source_text):
    target = google_code(locale)
    try:
        translator = GoogleTranslator(source="en", target=target)
        translated = translator.translate(source_text)
        out_dir = METADATA_DIR / locale
        out_dir.mkdir(parents=True, exist_ok=True)
        (out_dir / "release_notes.txt").write_text(translated + "\n", encoding="utf-8")
        return locale, True, None
    except Exception as e:
        return locale, False, str(e)


def main():
    locales = load_locales()
    all_codes = [l["code"] for l in locales]

    source_path = METADATA_DIR / SOURCE_LOCALE / "release_notes.txt"
    source_text = source_path.read_text(encoding="utf-8").strip()

    # English variants get a direct copy
    english_variants = [c for c in all_codes if c.startswith("en-") and c != SOURCE_LOCALE]
    for code in english_variants:
        out_dir = METADATA_DIR / code
        out_dir.mkdir(parents=True, exist_ok=True)
        (out_dir / "release_notes.txt").write_text(source_text + "\n", encoding="utf-8")
        print(f"  = {code} (copy)")

    non_english = [c for c in all_codes if not c.startswith("en")]

    if len(sys.argv) > 1:
        requested = set(sys.argv[1:])
        non_english = [c for c in non_english if c in requested]

    print(f"\nSource ({SOURCE_LOCALE}):\n{source_text}\n")
    print(f"Translating to {len(non_english)} languages...\n")

    with ThreadPoolExecutor(max_workers=WORKERS) as pool:
        futures = {
            pool.submit(translate_locale, locale, source_text): locale
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
