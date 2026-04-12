#!/usr/bin/env python3
"""
Static site generator for Cutling docs.

Generates localized HTML pages from templates + JSON translation files.
English pages go at the docs root; other languages go in subdirectories.

Usage:
    python3 docs/_generator/generate.py            # Build all languages
    python3 docs/_generator/generate.py ja ar       # Build specific languages only
"""

import json
import os
import shutil
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
DOCS_DIR = SCRIPT_DIR.parent
TEMPLATES_DIR = SCRIPT_DIR / "templates"
TRANSLATIONS_DIR = SCRIPT_DIR / "translations"
LANGUAGES_FILE = SCRIPT_DIR / "languages.json"

TEMPLATES = [
    "index.html",
    "faq/index.html",
    "support/index.html",
    "privacy/index.html",
]


def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def load_languages():
    return load_json(LANGUAGES_FILE)


def load_translation(lang_code):
    """Load a translation file, with fallback to base language (e.g. en-AU -> en)."""
    path = TRANSLATIONS_DIR / f"{lang_code}.json"
    if path.exists():
        return load_json(path)
    base = lang_code.split("-")[0]
    fallback = TRANSLATIONS_DIR / f"{base}.json"
    if fallback.exists():
        print(f"  Fallback: {lang_code} -> {base}")
        return load_json(fallback)
    return None


def compute_root(template_depth, is_default):
    """Path from output file to docs root (for CSS, images)."""
    depth = template_depth if is_default else template_depth + 1
    return "/".join([".."] * depth) if depth > 0 else "."


def compute_lang_prefix(template_depth):
    """Path from output file to language root (for same-language links)."""
    return "/".join([".."] * template_depth) if template_depth > 0 else "."


def build_language_picker(languages, available_codes, current_code, root, template_rel):
    """Generate the <li> HTML for the language picker dropdown."""
    page_dir = os.path.dirname(template_rel)  # "" or "faq" etc.

    current_name = current_code
    for lang in languages:
        if lang["code"] == current_code:
            current_name = lang["name"]
            break

    links = []
    for lang in languages:
        code = lang["code"]
        if code not in available_codes:
            continue
        name = lang["name"]

        if page_dir:
            href = f"{root}/{page_dir}/" if code == "en" else f"{root}/{code}/{page_dir}/"
        else:
            href = f"{root}/" if code == "en" else f"{root}/{code}/"

        active = ' class="active"' if code == current_code else ""
        links.append(f'                        <li><a href="{href}"{active}>{name}</a></li>')

    links_html = "\n".join(links)
    return (
        f'<li class="lang-picker">\n'
        f'                <details class="lang-dropdown-wrapper">\n'
        f'                    <summary>{current_name}</summary>\n'
        f'                    <ul class="lang-dropdown">\n'
        f'{links_html}\n'
        f'                    </ul>\n'
        f'                </details>\n'
        f'            </li>'
    )


def validate_translation(lang_code, translation, reference_keys):
    """Warn about missing or extra keys compared to en.json."""
    trans_keys = {k for k in translation if not k.startswith("_")}
    ref_keys = {k for k in reference_keys if not k.startswith("_")}

    missing = ref_keys - trans_keys
    extra = trans_keys - ref_keys

    if missing:
        sample = ", ".join(sorted(missing)[:5])
        suffix = "..." if len(missing) > 5 else ""
        print(f"  WARNING: {lang_code} missing {len(missing)} keys: {sample}{suffix}")
    if extra:
        sample = ", ".join(sorted(extra)[:5])
        suffix = "..." if len(extra) > 5 else ""
        print(f"  WARNING: {lang_code} has {len(extra)} extra keys: {sample}{suffix}")


def generate_page(template_content, translation, en_translation, lang_code, is_rtl, root, lang_prefix, picker_html):
    """Replace all placeholders in a template with translated values."""
    html = template_content

    # System placeholders
    html = html.replace("{{ROOT}}", root)
    html = html.replace("{{LANG_PREFIX}}", lang_prefix)
    html = html.replace("{{LANG_CODE}}", lang_code)
    html = html.replace("{{DIR_ATTR}}", ' dir="rtl"' if is_rtl else "")
    html = html.replace("{{LANGUAGE_PICKER}}", picker_html)

    # Translation placeholders — fall back to English if key missing
    for key in en_translation:
        if key.startswith("_"):
            continue
        placeholder = "{{" + key + "}}"
        if placeholder in html:
            value = translation.get(key, en_translation[key])
            html = html.replace(placeholder, value)

    return html


def clean_generated(languages):
    """Remove previously generated language subdirectories."""
    for lang in languages:
        code = lang["code"]
        if code == "en":
            continue
        lang_dir = DOCS_DIR / code
        if lang_dir.exists():
            shutil.rmtree(lang_dir)
            print(f"  Cleaned: {code}/")


def main():
    specific_langs = set(sys.argv[1:]) if len(sys.argv) > 1 else None

    languages = load_languages()
    en_translation = load_translation("en")
    if not en_translation:
        print("ERROR: en.json not found!")
        sys.exit(1)

    en_keys = {k for k in en_translation if not k.startswith("_")}

    # Load templates
    templates = {}
    for t in TEMPLATES:
        path = TEMPLATES_DIR / t
        with open(path, "r", encoding="utf-8") as f:
            templates[t] = f.read()

    # Determine which languages have translations (explicit or fallback)
    available_codes = set()
    for lang in languages:
        code = lang["code"]
        if load_translation(code) is not None:
            available_codes.add(code)

    if not specific_langs:
        print("Cleaning generated directories...")
        clean_generated(languages)

    # Generate pages
    generated_count = 0
    for lang in languages:
        code = lang["code"]
        is_rtl = lang["rtl"]
        is_default = code == "en"

        if specific_langs and code not in specific_langs:
            continue

        translation = load_translation(code)
        if not translation:
            continue

        print(f"Generating: {code} ({lang['name']})")
        validate_translation(code, translation, en_keys)

        for template_rel in TEMPLATES:
            template_content = templates[template_rel]
            template_depth = template_rel.count("/")

            root = compute_root(template_depth, is_default)
            lang_prefix = compute_lang_prefix(template_depth)

            picker_html = build_language_picker(
                languages, available_codes, code, root, template_rel
            )

            html = generate_page(
                template_content, translation, en_translation,
                code, is_rtl, root, lang_prefix, picker_html
            )

            if is_default:
                out_path = DOCS_DIR / template_rel
            else:
                out_path = DOCS_DIR / code / template_rel

            out_path.parent.mkdir(parents=True, exist_ok=True)
            with open(out_path, "w", encoding="utf-8") as f:
                f.write(html)

            generated_count += 1

    print(f"\nDone! Generated {generated_count} pages.")


if __name__ == "__main__":
    main()
