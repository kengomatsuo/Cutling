#!/usr/bin/env python3
"""
Generate translations for a specific language code.
Usage: python3 docs/_generator/translate_language.py <lang_code>
Example: python3 docs/_generator/translate_language.py es fr de
"""

import json
import sys
import re
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
TRANSLATIONS_DIR = SCRIPT_DIR / "translations"
LANGUAGES_FILE = SCRIPT_DIR / "languages.json"

def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def get_language_info(lang_code):
    """Get language name and RTL info from languages.json"""
    languages = load_json(LANGUAGES_FILE)
    for lang in languages:
        if lang["code"] == lang_code:
            return lang["name"], lang["rtl"]
    return None, False

def mark_placeholders(text):
    """Mark HTML entities like &mdash; so they don't get translated"""
    return text

def restore_placeholders(text):
    """Restore HTML entities"""
    return text

def load_english():
    return load_json(TRANSLATIONS_DIR / "en.json")

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

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 translate_language.py <lang_code> [lang_code2 ...]")
        sys.exit(1)
    
    english = load_english()
    
    for lang_code in sys.argv[1:]:
        lang_name, rtl = get_language_info(lang_code)
        if not lang_name:
            print(f"✗ Language {lang_code} not found in languages.json")
            continue
        
        print(f"Translating to {lang_name} ({lang_code})...")
        print("Copy the JSON below and save to translations/{}.json:".format(lang_code))
        print("\n[REQUIRES MANUAL TRANSLATION OR API INTEGRATION]\n")
        
        # This script is meant to be a template; actual translation would be done via API
        # or by manually providing translations
