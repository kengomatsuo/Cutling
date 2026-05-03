#!/usr/bin/env python3
"""
Static site generator for Cutling docs.

Generates localized HTML pages from templates + JSON translation files.
All locales (including en-US) go into subdirectories named by their
lowercased locale code. The docs root contains only blank redirect pages
that invoke locale-router.js to send users to their preferred language.

Uses the repo-root locales.json as the single source of truth for all
supported locales.

Usage:
    python3 docs/_generator/generate.py            # Build all languages
    python3 docs/_generator/generate.py ja de-DE   # Build specific locales only
"""

import argparse
import json
import os
import shutil
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
DOCS_DIR = SCRIPT_DIR.parent
TEMPLATES_DIR = SCRIPT_DIR / "templates"
TRANSLATIONS_DIR = SCRIPT_DIR / "translations"

# Find locales.json: check two levels up (web/_generator/ layout) then one level up (legacy)
_repo_root_candidates = [SCRIPT_DIR.parent.parent, SCRIPT_DIR.parent]
REPO_ROOT = next((p for p in _repo_root_candidates if (p / "locales.json").exists()), SCRIPT_DIR.parent)
LOCALES_FILE = REPO_ROOT / "locales.json"

DEFAULT_LOCALE = "en-US"

TRANSLATION_ALIASES = {
    "no": "nb",
}

TEMPLATES = [
    "index.html",
    "faq/index.html",
    "support/index.html",
    "privacy/index.html",
]


def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def load_locales():
    return load_json(LOCALES_FILE)


def web_code(locale_code):
    """Lowercase locale code for use in URL paths."""
    return locale_code.lower()


def resolve_translation(locale_code):
    """Load a translation file and report whether it came from a fallback."""
    # Exact match (e.g. en-AU.json, zh-Hans.json)
    path = TRANSLATIONS_DIR / f"{locale_code}.json"
    if path.exists():
        return load_json(path), "exact"

    # Base language fallback (e.g. ar-SA -> ar, de-DE -> de)
    base = locale_code.split("-")[0]
    fallback = TRANSLATIONS_DIR / f"{base}.json"
    if fallback.exists():
        print(f"  Fallback: {locale_code} -> {base}")
        return load_json(fallback), f"fallback:{base}"

    # Alias fallback (e.g. no -> nb)
    alias = TRANSLATION_ALIASES.get(locale_code) or TRANSLATION_ALIASES.get(base)
    if alias:
        alias_path = TRANSLATIONS_DIR / f"{alias}.json"
        if alias_path.exists():
            print(f"  Alias: {locale_code} -> {alias}")
            return load_json(alias_path), f"alias:{alias}"

    return None, None


def load_translation(locale_code):
    """Load a translation file, with fallback to base language and aliases."""
    translation, _ = resolve_translation(locale_code)
    return translation


def compute_root(template_depth, is_default):
    """Path from output file to docs root (for CSS, images)."""
    depth = template_depth if is_default else template_depth + 1
    return "/".join([".."] * depth) if depth > 0 else "."


def compute_lang_prefix(template_depth):
    """Path from output file to language root (for same-language links)."""
    return "/".join([".."] * template_depth) if template_depth > 0 else "."


def build_language_picker(locales, available_codes, current_code, root, template_rel):
    """Generate the <li> HTML for the language picker dropdown."""
    page_dir = os.path.dirname(template_rel)

    current_name = current_code
    for loc in locales:
        if loc["code"] == current_code:
            current_name = loc["name"]
            break

    links = []
    for loc in locales:
        code = loc["code"]
        if code not in available_codes:
            continue
        name = loc["name"]
        wc = web_code(code)
        is_default = code == DEFAULT_LOCALE

        if page_dir:
            href = f"{root}/{wc}/{page_dir}/"
        else:
            href = f"{root}/{wc}/"

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


def validate_translation(locale_code, translation, reference_keys):
    """Print missing and extra keys compared to en.json."""
    trans_keys = {k for k in translation if not k.startswith("_")}
    ref_keys = {k for k in reference_keys if not k.startswith("_")}

    missing = ref_keys - trans_keys
    extra = trans_keys - ref_keys

    if missing:
        print(f"  Missing keys for {locale_code} ({len(missing)}):")
        for key in sorted(missing):
            print(f"    - {key}")
    if extra:
        sample = ", ".join(sorted(extra)[:5])
        suffix = "..." if len(extra) > 5 else ""
        print(f"  WARNING: {locale_code} has {len(extra)} extra keys: {sample}{suffix}")


def report_translation_status(locale_code, translation, source):
    """Print whether a locale is missing an exact translation file."""
    exact_path = TRANSLATIONS_DIR / f"{locale_code}.json"
    if source != "exact":
        if exact_path.exists():
            return
        print(f"  MISSING TRANSLATION FILE: {locale_code}.json -> using {source}")
    elif not exact_path.exists():
        print(f"  MISSING TRANSLATION FILE: {locale_code}.json")


def generate_page(template_content, translation, en_translation, locale_code, is_rtl, root, lang_prefix, picker_html):
    """Replace all placeholders in a template with translated values."""
    html = template_content

    html = html.replace("{{ROOT}}", root)
    html = html.replace("{{LANG_PREFIX}}", lang_prefix)
    html = html.replace("{{LANG_CODE}}", locale_code)
    html = html.replace("{{DIR_ATTR}}", ' dir="rtl"' if is_rtl else "")
    html = html.replace("{{LANGUAGE_PICKER}}", picker_html)

    for key in en_translation:
        if key.startswith("_"):
            continue
        placeholder = "{{" + key + "}}"
        if placeholder in html:
            value = translation.get(key, en_translation[key])
            html = html.replace(placeholder, value)

    return html


def clean_generated(locales):
    """Remove previously generated language subdirectories."""
    for loc in locales:
        code = loc["code"]
        if code == DEFAULT_LOCALE:
            continue
        lang_dir = DOCS_DIR / web_code(code)
        if lang_dir.exists():
            shutil.rmtree(lang_dir)
            print(f"  Cleaned: {web_code(code)}/")

    # Folders that should never be deleted
    protected_names = {
        "_generator", "img", "faq", "support", "privacy",
        ".git", ".claude", "Cutling.xcodeproj"
    }

    # Also clean old-style directories (pre-migration short codes)
    for entry in DOCS_DIR.iterdir():
        if not entry.is_dir():
            continue
        name = entry.name
        if name in protected_names or name.startswith("."):
            continue
        current_web_codes = {web_code(loc["code"]) for loc in locales}
        if name not in current_web_codes:
            shutil.rmtree(entry)
            print(f"  Cleaned (legacy): {name}/")


ROOT_REDIRECT_TEMPLATE = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="color-scheme" content="dark light">
    <style>
        html, body {{ margin: 0; padding: 0; min-height: 100vh; }}
        body {{ background: #fafafa; }}
        @media (prefers-color-scheme: dark) {{ body {{ background: #1c1c1e; }} }}
    </style>
</head>
<body>
    <script src="{router_path}locale-router.js"></script>
</body>
</html>"""


def generate_root_redirect_pages():
    """Generate blank dark-mode-compatible redirect pages at the docs root for all page paths."""
    pages = [("index.html", "./")] + [
        (f"{name}/index.html", "../")
        for name in [t.split("/")[0] for t in TEMPLATES if "/" in t]
    ]
    for rel_path, router_prefix in pages:
        html = ROOT_REDIRECT_TEMPLATE.format(router_path=router_prefix)
        out_path = DOCS_DIR / rel_path
        out_path.parent.mkdir(parents=True, exist_ok=True)
        with open(out_path, "w", encoding="utf-8") as f:
            f.write(html)
        print(f"  Generated root loading page: {rel_path}")

    # 404.html: GitHub Pages serves this for any unmatched URL.
    # fuzzy-redirect.js handles typos and aliases before falling back to locale preference.
    html_404 = ROOT_REDIRECT_TEMPLATE.format(router_path="./").replace(
        "locale-router.js", "fuzzy-redirect.js"
    )
    out_path = DOCS_DIR / "404.html"
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(html_404)
    print("  Generated 404.html")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", default=None, help="Output directory (default: parent of _generator/)")
    parser.add_argument("locales", nargs="*", help="Specific locale codes to build")
    args = parser.parse_args()

    global DOCS_DIR
    if args.output_dir:
        DOCS_DIR = Path(args.output_dir).resolve()
        DOCS_DIR.mkdir(parents=True, exist_ok=True)

    specific_web_locales = {web_code(arg) for arg in args.locales} if args.locales else None

    locales = load_locales()
    en_translation = load_translation(DEFAULT_LOCALE)
    if not en_translation:
        print(f"ERROR: No translation found for default locale {DEFAULT_LOCALE}!")
        sys.exit(1)

    en_keys = {k for k in en_translation if not k.startswith("_")}

    templates = {}
    for t in TEMPLATES:
        path = TEMPLATES_DIR / t
        with open(path, "r", encoding="utf-8") as f:
            templates[t] = f.read()

    available_codes = set()
    for loc in locales:
        translation, _ = resolve_translation(loc["code"])
        if translation is not None:
            available_codes.add(loc["code"])

    if not specific_web_locales:
        print("Cleaning generated directories...")
        clean_generated(locales)

    generated_count = 0
    for loc in locales:
        code = loc["code"]
        is_rtl = loc["rtl"]
        is_default = code == DEFAULT_LOCALE

        if specific_web_locales and web_code(code) not in specific_web_locales:
            continue

        translation, source = resolve_translation(code)
        if not translation:
            continue

        print(f"Generating: {code} ({loc['name']}) -> {web_code(code)}/")
        report_translation_status(code, translation, source)
        validate_translation(code, translation, en_keys)

        for template_rel in TEMPLATES:
            template_content = templates[template_rel]
            template_depth = template_rel.count("/")

            # All locales now go into their own folders
            root = compute_root(template_depth, False)
            lang_prefix = compute_lang_prefix(template_depth)

            picker_html = build_language_picker(
                locales, available_codes, code, root, template_rel
            )

            html = generate_page(
                template_content, translation, en_translation,
                code, is_rtl, root, lang_prefix, picker_html
            )

            out_path = DOCS_DIR / web_code(code) / template_rel

            out_path.parent.mkdir(parents=True, exist_ok=True)
            with open(out_path, "w", encoding="utf-8") as f:
                f.write(html)

            generated_count += 1

    if not specific_web_locales:
        print("Generating root loading pages...")
        generate_root_redirect_pages()

    print(f"\nDone! Generated {generated_count} pages.")


if __name__ == "__main__":
    main()
