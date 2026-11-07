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
    "mac/index.html",
    "download/index.html",
    "faq/index.html",
    "support/index.html",
    "privacy/index.html",
    "terms/index.html",
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

    html = html.replace("{{IMG}}", f"{root}/img/{web_code(locale_code)}")
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
        "_generator", "img", "faq", "support", "privacy", "mac", "download", "terms",
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
    <link rel="icon" type="image/x-icon" href="{router_path}favicon.ico">
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
    """Generate 404.html; the root pages themselves are the English pages (see main)."""
    # 404.html: GitHub Pages serves this for any unmatched URL.
    # fuzzy-redirect.js handles typos and aliases before falling back to locale preference.
    html_404 = ROOT_REDIRECT_TEMPLATE.format(router_path="./").replace(
        "locale-router.js", "fuzzy-redirect.js"
    )
    out_path = DOCS_DIR / "404.html"
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(html_404)
    print("  Generated 404.html")


SITE = "https://cutling.matsuokengo.com"
APP_ID = "6759476314"
APP_URL = f"https://apps.apple.com/app/cutling/id{APP_ID}"
METADATA_DIR = REPO_ROOT / "fastlane" / "metadata"

# hreflang takes ISO 639-1 language codes (Google: localized-versions). Filipino has
# no 639-1 code of its own; Tagalog's "tl" is the one Google accepts.
HREFLANG_OVERRIDES = {"fil": "tl"}

# Page description keys per template. Pages without one get no description rather
# than a copy of another page's (Google: snippet guidelines want them unique).
DESCRIPTION_KEYS = {
    "mac/index.html": "mac_hero_subtitle",
    "support/index.html": "support_subtitle",
}


def hreflang(code):
    return HREFLANG_OVERRIDES.get(code, code)


def page_url(code, template_rel):
    page_dir = os.path.dirname(template_rel)
    return f"{SITE}/{web_code(code)}/" + (f"{page_dir}/" if page_dir else "")


def store_text(code, field):
    """A field of the App Store listing for this locale, already written per language."""
    path = METADATA_DIR / code / f"{field}.txt"
    return path.read_text(encoding="utf-8").strip() if path.exists() else ""


def live_price():
    """The US App Store price, read at build time so the structured data never goes stale."""
    import urllib.request
    try:
        with urllib.request.urlopen(f"https://itunes.apple.com/lookup?id={APP_ID}&country=us", timeout=15) as r:
            result = json.load(r)["results"][0]
        return f'{result["price"]:.2f}', result["currency"]
    except Exception as e:  # offline build: leave the offer out instead of guessing a price
        print(f"  WARNING: no live price ({e}); structured data ships without an offer")
        return None, None


def esc_attr(value):
    return (value.replace("&", "&amp;").replace('"', "&quot;")
            .replace("<", "&lt;").replace(">", "&gt;"))


def head_tags(code, template_rel, translation, available_codes, locales, price):
    """Canonical, hreflang set, description, Open Graph and, on home pages, JSON-LD."""
    tags = [f'<link rel="canonical" href="{page_url(code, template_rel)}">']
    for loc in locales:
        if loc["code"] in available_codes:
            tags.append(f'<link rel="alternate" hreflang="{hreflang(loc["code"])}" href="{page_url(loc["code"], template_rel)}">')
    tags.append(f'<link rel="alternate" hreflang="x-default" href="{page_url(DEFAULT_LOCALE, template_rel)}">')

    is_home = template_rel == "index.html"
    if is_home:
        description = store_text(code, "promotional_text") or store_text(DEFAULT_LOCALE, "promotional_text")
    else:
        key = DESCRIPTION_KEYS.get(template_rel)
        description = translation.get(key, "") if key else ""
    if description:
        tags.append(f'<meta name="description" content="{esc_attr(description)}">')

    tags += [
        '<meta property="og:type" content="website">',
        f'<meta property="og:url" content="{page_url(code, template_rel)}">',
        f'<meta property="og:image" content="{SITE}/icon.png">',
        '<meta name="twitter:card" content="summary">',
    ]
    if description:
        tags.append(f'<meta property="og:description" content="{esc_attr(description)}">')

    if is_home:
        app = {
            "@context": "https://schema.org",
            "@type": "SoftwareApplication",
            "name": store_text(code, "name") or "Cutling",
            "applicationCategory": "UtilitiesApplication",
            "operatingSystem": "iOS, iPadOS, macOS",
            "url": page_url(code, template_rel),
            "image": f"{SITE}/icon.png",
            "installUrl": APP_URL,
            "inLanguage": code,
            "author": {"@type": "Person", "name": "Kenneth Johannes Fang"},
        }
        if description:
            app["description"] = description
        if price[0]:
            app["offers"] = {"@type": "Offer", "price": price[0], "priceCurrency": price[1]}
        tags.append('<script type="application/ld+json">' + json.dumps(app, ensure_ascii=False).replace("</", "<\\/") + "</script>")
    return "\n    ".join(tags)


def home_title(code, translation):
    """The store name and subtitle carry the searched words; the slogan does not."""
    name, subtitle = store_text(code, "name"), store_text(code, "subtitle")
    return f"{name} | {subtitle}" if name and subtitle else translation.get("page_title_home")


def git_date(*paths):
    import subprocess
    dates = []
    for p in paths:
        out = subprocess.run(["git", "-C", str(REPO_ROOT), "log", "-1", "--format=%cs", "--", str(p)],
                             capture_output=True, text=True).stdout.strip()
        if out:
            dates.append(out)
    return max(dates) if dates else None


def write_sitemap_and_robots(locales, available_codes):
    template_dates = {t: git_date(TEMPLATES_DIR / t) for t in TEMPLATES}
    lines = ['<?xml version="1.0" encoding="UTF-8"?>',
             '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">']
    codes = [l["code"] for l in locales if l["code"] in available_codes]
    for code in codes:
        trans_date = git_date(TRANSLATIONS_DIR / f"{code}.json", METADATA_DIR / code)
        for t in TEMPLATES:
            lines.append("  <url>")
            lines.append(f"    <loc>{page_url(code, t)}</loc>")
            lastmod = max(d for d in (template_dates[t], trans_date) if d) if (template_dates[t] or trans_date) else None
            if lastmod:
                lines.append(f"    <lastmod>{lastmod}</lastmod>")
            for alt in codes:
                lines.append(f'    <xhtml:link rel="alternate" hreflang="{hreflang(alt)}" href="{page_url(alt, t)}"/>')
            lines.append(f'    <xhtml:link rel="alternate" hreflang="x-default" href="{page_url(DEFAULT_LOCALE, t)}"/>')
            lines.append("  </url>")
    lines.append("</urlset>")
    (DOCS_DIR / "sitemap.xml").write_text("\n".join(lines) + "\n", encoding="utf-8")
    (DOCS_DIR / "robots.txt").write_text(f"User-agent: *\nAllow: /\n\nSitemap: {SITE}/sitemap.xml\n", encoding="utf-8")
    print(f"  Generated sitemap.xml ({len(codes) * len(TEMPLATES)} URLs) and robots.txt")


def write_lang_suggest(locales, available_codes):
    """lang-suggest.js: offers the visitor's language on the English root pages, never redirects."""
    names = {web_code(l["code"]): l["name"] for l in locales if l["code"] in available_codes}
    src = (TEMPLATES_DIR.parent / "lang-suggest.src.js").read_text(encoding="utf-8")
    (DOCS_DIR / "lang-suggest.js").write_text(
        src.replace("/*LANG_NAMES*/{}", json.dumps(names, ensure_ascii=False)), encoding="utf-8")


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

    price = live_price()
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

            page_template = template_content
            if template_rel == "index.html":
                page_template = page_template.replace("{{page_title_home}}", esc_attr(home_title(code, translation)))
            page_template = page_template.replace(
                "</head>", "    " + head_tags(code, template_rel, translation, available_codes, locales, price) + "\n</head>", 1)

            html = generate_page(
                page_template, translation, en_translation,
                code, is_rtl, root, lang_prefix, picker_html
            )

            out_path = DOCS_DIR / web_code(code) / template_rel

            out_path.parent.mkdir(parents=True, exist_ok=True)
            with open(out_path, "w", encoding="utf-8") as f:
                f.write(html)

            # The site root carries the English pages themselves, so crawlers and
            # first visitors get content. Their canonical points at /en-us/, and
            # lang-suggest.js offers the visitor's language instead of redirecting.
            if is_default and not specific_web_locales:
                root_html = generate_page(
                    page_template, translation, en_translation, code, is_rtl,
                    compute_root(template_depth, True), compute_lang_prefix(template_depth),
                    build_language_picker(locales, available_codes, code,
                                          compute_root(template_depth, True), template_rel))
                root_html = root_html.replace(
                    f'<script src="{compute_root(template_depth, True)}/locale-router.js"></script>',
                    f'<script src="{compute_root(template_depth, True)}/lang-suggest.js" defer></script>')
                root_out = DOCS_DIR / template_rel
                root_out.parent.mkdir(parents=True, exist_ok=True)
                root_out.write_text(root_html, encoding="utf-8")

            generated_count += 1

    if not specific_web_locales:
        print("Generating 404, sitemap, robots.txt and lang-suggest.js...")
        generate_root_redirect_pages()
        write_sitemap_and_robots(locales, available_codes)
        write_lang_suggest(locales, available_codes)

    print(f"\nDone! Generated {generated_count} pages.")


if __name__ == "__main__":
    main()
