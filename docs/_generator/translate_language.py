#!/usr/bin/env python3
"""
Generate translations for a specific language code using DeepL API.
Usage: python3 docs/_generator/translate_language.py <lang_code>
Example: python3 docs/_generator/translate_language.py es fr de

Requires: source docs/_generator/.venv/bin/activate && pip install -r docs/_generator/requirements.txt
"""

import json
import sys
import re
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from deep_translator import GoogleTranslator
from tqdm import tqdm

WORKERS = 5

SCRIPT_DIR = Path(__file__).parent
REPO_ROOT = SCRIPT_DIR.parent.parent
TRANSLATIONS_DIR = SCRIPT_DIR / "translations"
LOCALES_FILE = REPO_ROOT / "locales.json"

# Map locale codes to Google Translate language codes
# Note: Google Translate uses different codes than standard ISO codes
GOOGLE_LANG_MAP = {
    "ar-SA": "ar",
    "bg": "bg",
    "bn-BD": "bn",
    "bn-IN": "bn",
    "ca": "ca",
    "cs": "cs",
    "da": "da",
    "de-DE": "de",
    "el": "el",
    "en-AU": "en",
    "en-CA": "en",
    "en-GB": "en",
    "en-IN": "en",
    "en-US": "en",
    "es-ES": "es",
    "es-MX": "es",
    "et": "et",
    "fa": "fa",
    "fi": "fi",
    "fil": "tl",
    "fr-CA": "fr",
    "fr-FR": "fr",
    "gu-IN": "gu",
    "he": "iw",  # Google uses 'iw' for Hebrew
    "hi": "hi",
    "hr": "hr",
    "hu": "hu",
    "id": "id",
    "it": "it",
    "ja": "ja",
    "kn-IN": "kn",
    "ko": "ko",
    "lt": "lt",
    "lv": "lv",
    "ml-IN": "ml",
    "mr-IN": "mr",
    "ms": "ms",
    "nl-NL": "nl",
    "no": "no",
    "or-IN": "or",
    "pa-IN": "pa",
    "pl": "pl",
    "pt-BR": "pt",
    "pt-PT": "pt",
    "ro": "ro",
    "ru": "ru",
    "sk": "sk",
    "sl-SI": "sl",
    "sr": "sr",
    "sv": "sv",
    "sw": "sw",
    "ta-IN": "ta",
    "te-IN": "te",
    "th": "th",
    "tr": "tr",
    "uk": "uk",
    "ur-PK": "ur",
    "vi": "vi",
    "zh-Hans": "zh-CN",
    "zh-Hant": "zh-TW",
}

# HTML entities to preserve
HTML_ENTITIES = ["&mdash;", "&ldquo;", "&rdquo;", "&lsquo;", "&rsquo;", "&amp;", "&lt;", "&gt;", "&copy;"]
PLACEHOLDER_PREFIX = "___HTML_ENTITY_"

def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def get_language_info(lang_code):
    """Get language name and RTL info from locales.json"""
    locales = load_json(LOCALES_FILE)
    for lang in locales:
        if lang["code"] == lang_code:
            return lang["name"], lang["rtl"]
    return None, False

def mark_placeholders(text):
    """Mark HTML entities so they don't get translated"""
    result = text
    for i, entity in enumerate(HTML_ENTITIES):
        result = result.replace(entity, f"{PLACEHOLDER_PREFIX}{i}___")
    return result

def restore_placeholders(text):
    """Restore HTML entities"""
    result = text
    for i, entity in enumerate(HTML_ENTITIES):
        result = result.replace(f"{PLACEHOLDER_PREFIX}{i}___", entity)
    return result

def load_english():
    return load_json(TRANSLATIONS_DIR / "en-US.json")

def get_google_code(lang_code):
    """Get Google Translate language code"""
    return GOOGLE_LANG_MAP.get(lang_code, lang_code.split("-")[0])

def translate_text(text, target_lang, translator_cache):
    """Translate a single text string"""
    if not text or not text.strip():
        return text

    # Mark placeholders
    marked = mark_placeholders(text)

    # Use cached translator
    if target_lang not in translator_cache:
        translator_cache[target_lang] = GoogleTranslator(source='en', target=target_lang)

    translator = translator_cache[target_lang]

    try:
        translated = translator.translate(marked)
        return restore_placeholders(translated)
    except Exception as e:
        print(f"  Warning: Translation error for '{text[:50]}...': {e}")
        return marked  # Return marked version if translation fails

def save_translation(lang_code, lang_name, translation_dict, rtl=False):
    """Save translation to file"""
    output = {
        "_language_code": lang_code,
        "_language_name": lang_name,
    }
    output.update(translation_dict)

    output_path = TRANSLATIONS_DIR / f"{lang_code}.json"
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=4)
    print(f"✓ Saved {lang_code}.json")

def is_english_variant(translation_dict):
    """Return True if this translation file is an English regional variant (en-*)."""
    lang_code = translation_dict.get("_language_code", "")
    return lang_code.startswith("en-")

def check_english_pollution(translation_dict):
    """Return True if the file is substantially untranslated (mostly identical to English)."""
    if is_english_variant(translation_dict):
        return False

    english = load_english()

    # Keys whose values are legitimately identical to English in all languages
    ENGLISH_OK_KEYS = {
        "footer_copyright",    # proper name
        "cta_button",          # App Store button text is standardised per platform
        "privacy_effective",   # date string often stays in English
        "feature_devices_title",  # "iPhone, iPad & Mac" — all brand names, never translates
    }

    matches = sum(
        1 for key, en_value in english.items()
        if not key.startswith("_")
        and key not in ENGLISH_OK_KEYS
        and len(en_value) > 20
        and translation_dict.get(key) == en_value
    )
    # Require at least 5 identical substantial keys before declaring pollution,
    # so a couple of untranslatable technical terms don't nuke a good file.
    return matches >= 5

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 translate_language.py <lang_code> [lang_code2 ...]")
        print("       python3 translate_language.py --all    # Translate all missing/polluted")
        print("       python3 translate_language.py --clean  # Remove polluted files")
        sys.exit(1)

    english = load_english()
    all_keys = [(k, v) for k, v in english.items() if not k.startswith("_")]

    if sys.argv[1] == "--clean":
        print("Checking for English pollution...")
        deleted_count = 0
        for lang_file in TRANSLATIONS_DIR.glob("*.json"):
            if lang_file.stem == "en-US":
                continue
            try:
                translation = load_json(lang_file)
                if check_english_pollution(translation):
                    print(f"  Deleting polluted file: {lang_file.name}")
                    lang_file.unlink()
                    deleted_count += 1
            except Exception as e:
                print(f"  Error checking {lang_file.name}: {e}")
        print(f"\nDeleted {deleted_count} polluted files.")
        sys.exit(0)

    if sys.argv[1] == "--all":
        locales = load_json(LOCALES_FILE)
        lang_codes = [l["code"] for l in locales if not l["code"].startswith("en-") and l["code"] != "en-US"]
    else:
        lang_codes = sys.argv[1:]

    # Scan phase — check everything before translating anything
    print("Scanning translations...\n")
    to_translate = []
    for code in lang_codes:
        lang_name, rtl = get_language_info(code)
        if not lang_name:
            print(f"  ✗  {code} — not found in locales.json")
            continue
        output_path = TRANSLATIONS_DIR / f"{code}.json"
        if not output_path.exists():
            print(f"  +  {lang_name} ({code}) — missing")
            to_translate.append((code, lang_name, rtl))
        else:
            try:
                existing = load_json(output_path)
            except Exception:
                print(f"  !  {lang_name} ({code}) — malformed JSON, will regenerate")
                output_path.unlink()
                to_translate.append((code, lang_name, rtl))
                continue
            if check_english_pollution(existing):
                print(f"  ~  {lang_name} ({code}) — polluted")
                to_translate.append((code, lang_name, rtl))
            else:
                print(f"  ✓  {lang_name} ({code})")

    if not to_translate:
        print("\nAll translations are up to date.")
        sys.exit(0)

    skipped = len(lang_codes) - len(to_translate)
    print(f"\n{len(to_translate)} to translate" + (f", {skipped} already up to date" if skipped else "") + "\n")

    def translate_one(code, lang_name, rtl):
        google_code = get_google_code(code)
        local_cache = {}
        translation_dict = {}
        for key, en_value in all_keys:
            translation_dict[key] = translate_text(en_value, google_code, local_cache)
            time.sleep(0.1)
        save_translation(code, lang_name, translation_dict, rtl)

    with tqdm(total=len(to_translate), desc="Translating", unit="lang") as bar:
        with ThreadPoolExecutor(max_workers=WORKERS) as executor:
            futures = {
                executor.submit(translate_one, code, name, rtl): (code, name)
                for code, name, rtl in to_translate
            }
            for f in futures:
                f.result()
                _, name = futures[f]
                bar.set_postfix_str(name)
                bar.update(1)

    print(f"\nDone! Translated {len(to_translate)} languages.")
