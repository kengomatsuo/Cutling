#!/usr/bin/env python3
"""Check every website translation file against en-US for structure and markup.

Usage: python3 web/_generator/validate_translations.py [locale ...]
"""

import json
import re
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
REPO_ROOT = SCRIPT_DIR.parent.parent
TRANSLATIONS_DIR = SCRIPT_DIR / "translations"
METADATA_DIR = REPO_ROOT / "fastlane" / "metadata"

# Values allowed to stay byte-identical to English.
SAME_AS_EN_OK = {
    "nav_mac", "app_name", "nav_faq", "download_mac_title",
    # Pure Apple product names — nothing to translate.
    "download_ios_title", "feature_devices_title", "feature_icons_colors_title",
}

ENTITY = re.compile(r"&(?:[a-zA-Z][a-zA-Z0-9]*|#\d+|#x[0-9a-fA-F]+);")
TAG = re.compile(r"</?(?:a|strong)(?:\s[^<>]*)?>")

REQUIRED_HREFS = {
    "faq_a10": "../download/",
    "support_contact_text": "mailto:kenneth@matsuokengo.com",
    "support_more_help_text": "../faq/",
    "privacy_icloud_outro": "https://www.apple.com/legal/internet-services/icloud/",
    "privacy_contact_text": "mailto:kenneth@matsuokengo.com",
    "terms_contact_text": "mailto:kenneth@matsuokengo.com",
}

# Substrings that must survive untranslated.
MUST_CONTAIN = {
    "support_contact_text": ["kenneth@matsuokengo.com"],
    "privacy_contact_text": ["kenneth@matsuokengo.com"],
    "terms_contact_text": ["kenneth@matsuokengo.com"],
    "footer_copyright": ["Kenneth Johannes Fang", "2026"],
    "download_ios_meta": ["18"],
    "download_mac_meta": ["14"],
    "feature_text_snippets_desc": ["100"],
    "feature_image_cutlings_desc": ["25"],
}


def brand_form(locale):
    name_file = METADATA_DIR / locale / "name.txt"
    if not name_file.exists():
        return None
    return name_file.read_text(encoding="utf-8").strip().split(" - ")[0].strip()


def check(locale, en):
    path = TRANSLATIONS_DIR / f"{locale}.json"
    errors = []
    warnings = []

    if not path.exists():
        return [f"{locale}: file missing"], []

    raw = path.read_text(encoding="utf-8")
    try:
        data = json.loads(raw)
    except json.JSONDecodeError as e:
        return [f"{locale}: invalid JSON — {e}"], []

    missing = set(en) - set(data)
    extra = set(data) - set(en)
    if missing:
        errors.append(f"{locale}: missing keys {sorted(missing)}")
    if extra:
        errors.append(f"{locale}: extra keys {sorted(extra)}")

    if data.get("_language_code") != locale:
        errors.append(f"{locale}: _language_code is {data.get('_language_code')!r}")

    brand = brand_form(locale)
    if brand and data.get("app_name") != brand:
        errors.append(f"{locale}: app_name {data.get('app_name')!r} != brand {brand!r}")

    identical = []
    for key, value in data.items():
        if key.startswith("_"):
            continue
        if not isinstance(value, str):
            errors.append(f"{locale}.{key}: not a string")
            continue
        if "{{" in value or "}}" in value:
            errors.append(f"{locale}.{key}: leftover template placeholder")

        stripped = ENTITY.sub("", TAG.sub("", value))
        for char in "&<>":
            if char in stripped:
                errors.append(f"{locale}.{key}: bare {char!r} outside an entity or tag")

        href = REQUIRED_HREFS.get(key)
        if href and f'href="{href}"' not in value:
            errors.append(f"{locale}.{key}: lost href {href}")
        if href and (value.count("<a ") != 1 or value.count("</a>") != 1):
            errors.append(f"{locale}.{key}: link tags unbalanced")
        if key == "privacy_changes_log" and (
            "<strong>" not in value or "</strong>" not in value
        ):
            errors.append(f"{locale}.{key}: lost <strong> tags")

        for needle in MUST_CONTAIN.get(key, []):
            if needle not in value:
                errors.append(f"{locale}.{key}: lost {needle!r}")

        if value == en.get(key) and key not in SAME_AS_EN_OK:
            identical.append(key)

    if identical and not locale.startswith("en-"):
        warnings.append(
            f"{locale}: {len(identical)} values identical to English: "
            + ", ".join(sorted(identical)[:8])
        )

    return errors, warnings


def main():
    en = json.loads((TRANSLATIONS_DIR / "en-US.json").read_text(encoding="utf-8"))
    locales = sys.argv[1:] or [
        loc["code"] for loc in json.loads((REPO_ROOT / "locales.json").read_text())
    ]

    all_errors, all_warnings = [], []
    checked = 0
    for locale in locales:
        if locale == "en-US":
            continue
        checked += 1
        errors, warnings = check(locale, en)
        all_errors += errors
        all_warnings += warnings

    for warning in all_warnings:
        print(f"WARN  {warning}")
    for error in all_errors:
        print(f"ERROR {error}")

    print(f"\n{checked} locales checked, {len(all_errors)} errors, "
          f"{len(all_warnings)} warnings.")
    sys.exit(1 if all_errors else 0)


if __name__ == "__main__":
    main()
