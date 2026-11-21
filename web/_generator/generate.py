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
import datetime
import html as html_lib
import json
import os
import re
import shutil
import unicodedata
import sys
from pathlib import Path

import ai_facts
import ai_files
import live
from live import LIVE_CAPS

SCRIPT_DIR = Path(__file__).parent
DOCS_DIR = SCRIPT_DIR.parent
TEMPLATES_DIR = SCRIPT_DIR / "templates"
TRANSLATIONS_DIR = SCRIPT_DIR / "translations"

# Find locales.json: check two levels up (web/_generator/ layout) then one level up (legacy)
_repo_root_candidates = [SCRIPT_DIR.parent.parent, SCRIPT_DIR.parent]
REPO_ROOT = next((p for p in _repo_root_candidates if (p / "locales.json").exists()), SCRIPT_DIR.parent)
LOCALES_FILE = REPO_ROOT / "locales.json"

DEFAULT_LOCALE = "en-US"

# Directory badges in every page footer. Each listing site checks for its own badge on the live site
# to keep a free listing or launch, so one is never dropped without checking that site's rules.
DIRECTORY_BADGES = [
    '<a href="https://www.producthunt.com/products/cutling?embed=true&amp;utm_source=badge-featured&amp;utm_medium=badge&amp;utm_campaign=badge-cutling" target="_blank" rel="noopener noreferrer"><img alt="Cutling on Product Hunt" width="250" height="54" src="https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=1310871&amp;theme=light"></a>',
    '<a href="https://nativeshelf.com/cutling?ref=badge" target="_blank" title="Featured on NativeShelf.com"><img src="https://nativeshelf.com/badge/dark.png?v=6" alt="Featured on NativeShelf.com" width="232" height="68" /></a>',
    '<a href="https://macpip.com/apps/cutling?ref=badge"><img src="https://macpip.com/badge/cutling.svg" height="44" alt="Listed on MacPip"></a>',
    '<a href="https://macbase.app/apps/cutling?ref=badge" target="_blank" rel="noopener"><img src="https://macbase.app/badge/featured-on-macbase.svg" alt="Cutling is featured on MacBase" height="44" style="height:44px;width:auto"></a>',
    '<a href="https://macbrowse.com"><img src="https://macbrowse.com/badge/listed-light.svg" alt="Listed on Mac Browse" height="44"></a>',
    '<a href="https://macappindex.com/apps/cutling?ref=badge" target="_blank" title="Cutling on Mac App Index"><img src="https://macappindex.com/apps/cutling/badge.svg?theme=light&height=56" alt="Cutling on Mac App Index" width="224" height="56" /></a>',
    '<a href="https://macnative.io/apps/cutling?utm_source=macnative-badge&utm_medium=referral" target="_blank" rel="noopener"><img src="https://macnative.io/badge?kind=listed&theme=light&slug=cutling" alt="Listed on MacNative" width="212" height="58" /></a>',
    '<a href="https://ipip.fyi/apps/cutling?ref=badge"><img src="https://ipip.fyi/badge/cutling.svg" alt="Cutling on iPip" width="220" height="56"></a>',
    '<a href="https://postyourstartup.com/startup/cutling?ref=badge" target="_blank"><img src="https://postyourstartup.com/api/badge/cutling?theme=light" alt="Featured on PostYourStartup" width="212" height="55" /></a>',
    '<a href="https://launchigniter.com/product/cutling?ref=badge-cutling" target="_blank"><img src="https://launchigniter.com/api/badge/cutling?theme=light" alt="Featured on LaunchIgniter" width="212" height="55" /></a>',
    '<a href="https://ailaun.ch/projects/cutling?utm_source=badge" target="_blank" rel="noopener noreferrer"><img src="https://ailaun.ch/ailaunch/images/badges/featured-on-light.svg" alt="Featured on AI Launch" style="height:44px;width:auto"/></a>',
    '<a href="https://www.nxgntools.com/tools/cutling?utm_source=cutling" target="_blank" rel="noopener" style="display: inline-block; width: auto;"><img src="https://www.nxgntools.com/api/embed/cutling?type=FIND_US_ON" alt="Find us on NxGn Tools" style="height: 48px; width: auto;" /></a>',
    '<a href="https://dodolaunch.com/p/cutling?ref=badge" target="_blank"><img src="https://dodolaunch.com/badge/cutling?theme=light" alt="Cutling on DodoLaunch" width="200" height="54" /></a>',
    '<a href="https://alternativeto.net/software/cutling/about/?utm_source=badge&utm_medium=referral" target="_blank"><img src="https://alternativeto.net/static/badges/badge-compact-color.svg" alt="Cutling | AlternativeTo" width="173" height="56" style="width:173px;height:56px" /></a>',
    '<a href="https://indieappcatalog.com/app/5527"><img src="https://indieappcatalog.com/badge/listed-on-indie-app-catalog-black.svg" alt="Listed on Indie App Catalog" width="183" height="40"></a>',
    '<a href="https://twelve.tools" target="_blank"><img src="https://twelve.tools/badge1-light.svg" alt="Featured on Twelve Tools" width="148" height="40"></a>',
    '<a href="https://hauntboard.com/products/cutling" target="_blank"><img src="https://hauntboard.com/badges/cutling.svg?style=found&theme=light" alt="Found on Hauntboard" width="245" height="54" /></a>',
    '<a href="https://neeed.directory/products/cutling?utm_source=cutling" target="_blank" rel="noopener"><img src="https://neeed.directory/badges/neeed-badge-light.svg" alt="Featured on neeed.directory" width="139" height="20" /></a>',
    '<a href="https://productwatch.io/products/cutling?utm_source=badge" target="_blank"><img src="https://productwatch.io/backend/api/v1/badge/featured?productId=15e303a6-81c2-41a0-ada6-def70408f32a&darkMode=false" alt="Cutling on ProductWatch" style="max-width:250px;height:auto" /></a>',
    '<a href="https://startupfa.me/s/cutling?utm_source=cutling.matsuokengo.com" target="_blank"><img src="https://startupfa.me/badges/featured-badge-small.webp" alt="Cutling - Featured on Startup Fame" width="224" height="36" /></a>',
    '<a href="https://findly.tools/cutling?utm_source=cutling" target="_blank" rel="noopener noreferrer"><img src="https://findly.tools/badges/findly-tools-badge-light.svg" alt="Featured on Findly.tools" width="175" height="55" /></a>',
    '<a href="https://www.scrolllaunch.com/products/cutling?ref=badge" target="_blank" rel="noopener"><img src="https://www.scrolllaunch.com/api/badge/cutling?variant=launched&theme=light" alt="Cutling - Featured on ScrollLaunch" width="220" height="48" /></a>',
    '<a href="https://queststack.io/" title="Featured on QuestStack" target="_blank" rel="noopener"><img src="https://queststack.io/badge/queststack-ember.svg" alt="Featured on QuestStack" width="226" height="57" /></a>',
    '<a href="https://bricklaun.ch/productivity/cutling" target="_blank" rel="noopener"><img src="https://bricklaun.ch/badge/brick-launch-badge-a-light.svg" alt="Featured on Brick Launch" width="140" height="54" /></a>',
    '<a href="https://daniellaunches.com" target="_blank"><img src="https://daniellaunches.com/badge.svg" alt="Featured on DanielLaunches" width="220" height="48" /></a>',
    '<a href="https://swipetolaunch.com/p/cutling?ref=badge" target="_blank" rel="noopener"><img src="https://swipetolaunch.com/api/badge/cutling" alt="Featured on SwipeToLaunch" width="220" height="48" loading="lazy" /></a>',
    '<a href="https://saasbison.com" target="_blank" rel="dofollow"><img src="https://saasbison.com/badge.png" alt="Featured on SaaSBison" width="200" height="54" /></a>',
    '<a href="https://dododirectory.com" target="_blank" rel="dofollow"><img src="https://dododirectory.com/badge-light.png" alt="Featured on DodoDirectory" width="200" height="54" /></a>',
    '<a href="https://sumodir.com" target="_blank" rel="dofollow"><img src="https://sumodir.com/badge.png" alt="Featured on SumoDir" width="200" height="54" /></a>',
]

# The caps and features of the Cutling version live on the App Store: live.py, shared with ai_facts.py.

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


def fill_caps(translation):
    """Writes LIVE_CAPS into a locale's copy, grouped the way that locale writes 1,000 (1,000, 1.000, 1 000 or 1000)."""
    written = re.search(r"1(\D?)000", translation.get("faq_a6", ""))
    separator = written.group(1) if written else ","
    filled = {}
    for key, value in translation.items():
        if isinstance(value, str):
            for token, cap in LIVE_CAPS.items():
                value = value.replace("{{" + token + "}}", f"{cap:,}".replace(",", separator))
        filled[key] = value
    return filled


def load_translation_file(path):
    return live.apply_keys(fill_caps(load_json(path)))


def resolve_translation(locale_code):
    """Load a translation file and report whether it came from a fallback."""
    # Exact match (e.g. en-AU.json, zh-Hans.json)
    path = TRANSLATIONS_DIR / f"{locale_code}.json"
    if path.exists():
        return load_translation_file(path), "exact"

    # Base language fallback (e.g. ar-SA -> ar, de-DE -> de)
    base = locale_code.split("-")[0]
    fallback = TRANSLATIONS_DIR / f"{base}.json"
    if fallback.exists():
        print(f"  Fallback: {locale_code} -> {base}")
        return load_translation_file(fallback), f"fallback:{base}"

    # Alias fallback (e.g. no -> nb)
    alias = TRANSLATION_ALIASES.get(locale_code) or TRANSLATION_ALIASES.get(base)
    if alias:
        alias_path = TRANSLATIONS_DIR / f"{alias}.json"
        if alias_path.exists():
            print(f"  Alias: {locale_code} -> {alias}")
            return load_translation_file(alias_path), f"alias:{alias}"

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


# The stylesheet is inlined into every page's head: at about 5 KB gzipped it costs less than the round
# trip a <link> makes the first paint wait for. style.css still ships for 404.html and older caches.
INLINE_CSS = re.sub(r"\s*\n\s*", "\n", re.sub(r"/\*.*?\*/", "", (DOCS_DIR / "style.css").read_text(encoding="utf-8"), flags=re.S)).strip()


def speed_up(html, root):
    """Head and image delivery shared by every generated page: the stylesheet inline, the app icon at
    192 px instead of the 512 px PNG, and third-party footer badges loaded only when scrolled near."""
    html = re.sub(r'<link rel="stylesheet" href="[^"]*/style\.css">', lambda _: f"<style>{INLINE_CSS}</style>", html, count=1)
    html = re.sub(r'(<img [^>]*src=")' + re.escape(root) + r'/icon\.png"', r"\1" + root + '/icon-192.webp"', html)
    return html


def lazy(markup):
    """Below-the-fold images from other sites never compete with the first paint."""
    return markup.replace("<img ", '<img loading="lazy" decoding="async" ')


def film_html(locale_code, translation, root):
    """The explainer film for a locale whose language has its own voice read, else nothing."""
    language = locale_code.split("-")[0]
    if language not in ("en", "id", "ja"):
        return ""
    label = esc_attr(translation["hero_title"])
    return (
        '    <section class="film">\n'
        f'        <video class="film-video" controls playsinline preload="none" aria-label="{label}" '
        f'poster="{root}/film/poster-{language}.avif" width="1920" height="1080" '
        f'src="{root}/film/cutling-{language}.mp4"></video>\n'
        "    </section>\n"
    )


def generate_page(template_content, translation, en_translation, locale_code, is_rtl, root, lang_prefix, picker_html, template_rel):
    """Replace all placeholders in a template with translated values."""
    html = live.apply_blocks(template_content)

    campaign = page_campaign(template_rel)
    html = html.replace("{{STORE_IOS}}", esc_attr(store_url(campaign)))
    html = html.replace("{{STORE_MAC}}", esc_attr(store_url(campaign if campaign == "web-mac" else campaign + "-mac", mac=True)))

    html = html.replace("{{IMG}}", f"{root}/img/{web_code(locale_code)}")
    html = html.replace("{{ROOT}}", root)
    html = html.replace("{{LANG_PREFIX}}", lang_prefix)
    html = html.replace("{{LANG_CODE}}", locale_code)
    html = html.replace("{{DIR_ATTR}}", ' dir="rtl"' if is_rtl else "")
    html = html.replace("{{LANGUAGE_PICKER}}", picker_html)
    html = html.replace("{{FILM}}", film_html(locale_code, translation, root))
    html = html.replace("</head>", f'    <script src="{root}/store-source.js" defer></script>\n</head>', 1)
    html = html.replace("{{DIRECTORY_BADGES}}", lazy('<div class="directory-badges">' + "".join(DIRECTORY_BADGES) + "</div>"))

    for key in en_translation:
        if key.startswith("_"):
            continue
        placeholder = "{{" + key + "}}"
        if placeholder in html:
            value = translation.get(key, en_translation[key])
            html = html.replace(placeholder, value)

    return speed_up(html, root)


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
# IndexNow keys are public by design: <key>.txt at the site root proves ownership.
INDEXNOW_KEY = "c27785c94a2066218caa0af8c11655f9"
INDEXNOW_ENDPOINT = "https://api.indexnow.org/indexnow"
# English-only pages: not translated, hreflang "en" and x-default only, each linked from every English
# footer. One per search intent; each template is templates/<slug>/index.html, and every rival fact in
# it names the page it was read from and the date (the HTML comment at the top of the template).
# campaign is the App Store ct= of the page's buttons (30 characters at most, "-mac" added for the Mac).
EN_ONLY_PAGES = [
    {"slug": "compare", "link": "Compare", "campaign": "web-compare", "type": "WebPage",
     "published": "2026-11-07", "crumb": "Compare",
     "title": "Cutling vs Paste, Clipboard++ and iOS text replacement",
     "description": ("How Cutling compares with Paste, Clipboard++, iOS text replacement and Universal Clipboard: "
                     "price model, keyboard, Mac, sync and what each privacy label says.")},
    {"slug": "paste-alternative", "link": "Paste alternative", "campaign": "web-paste-alt", "type": "Article",
     "published": "2026-11-20", "crumb": "Paste alternative",
     "title": "Paste alternative you pay for once: Cutling vs Paste",
     "description": ("Paste costs $3.99 a month, $29.99 a year or $89.99 once. Cutling is a one-time purchase for "
                     "iPhone, iPad and Mac. What each does, where Paste is better, and other one-time options.")},
    {"slug": "iphone-keyboard-address-bank-details", "link": "Address and bank details keyboard",
     "campaign": "web-keyboard-howto", "type": "Article", "published": "2026-11-20",
     "crumb": "Address and bank details keyboard",
     "title": "Paste your address and bank details from the iPhone keyboard",
     "description": ("How to put your address, bank details and email signature one tap away in any iPhone app: "
                     "what Safari AutoFill and text replacement cover, and a keyboard set up in four steps.")},
    {"slug": "best-snippet-keyboards-iphone", "link": "Snippet keyboards compared",
     "campaign": "web-snippet-keyboards", "type": "Article", "published": "2026-11-20",
     "crumb": "Snippet keyboards compared",
     "title": "Best snippet keyboards for iPhone without a subscription",
     "description": ("Eight snippet keyboards and text expanders for iPhone and iPad you can use without "
                     "subscribing, with prices, free limits, Full Access and sync read from each App Store listing.")},
    {"slug": "best-clipboard-managers-mac-iphone", "link": "Mac clipboard managers",
     "campaign": "web-mac-clipboards", "type": "Article", "published": "2026-11-20",
     "crumb": "Mac clipboard managers",
     "title": "Best clipboard managers for Mac that sync with iPhone",
     "description": ("Paste, PastePal, Cutling, Raycast, Maccy and ClipBook: which keep your clipboard history "
                     "or snippets in step with an iPhone, what each costs, and what macOS does on its own.")},
]
# Layout the English-only pages need beyond style.css: numbered steps, smaller tables, sub-headings.
EN_ONLY_CSS = """<style>
        .section ol { padding-inline-start: 22px; margin-bottom: 16px; }
        .section ol li { font-size: 15px; color: var(--ink-2); margin-bottom: 8px; padding-inline-start: 4px; }
        .section h3 { font-size: 16px; font-weight: 600; color: var(--ink); margin: 24px 0 8px; }
        .compare.compare-narrow { min-width: 620px; }
        .container-compare .faq-item { max-width: 640px; margin-inline: auto; }
    </style>"""
APP_ID = "6759476314"
PROVIDER_TOKEN = "127609326"  # the developer account's pt=, the same on every campaign link


def store_url(campaign, mac=False):
    """Apple's campaign link, so App Store Connect counts views and downloads per campaign (ct, 30 chars at most).
    mt=12 and platform=mac open the Mac listing; mt=8 the iPhone and iPad one."""
    assert len(campaign) <= 30, campaign
    tail = "&mt=12&platform=mac" if mac else "&mt=8"
    return f"https://apps.apple.com/app/apple-store/id{APP_ID}?pt={PROVIDER_TOKEN}&ct={campaign}{tail}"


def page_campaign(template_rel):
    """One campaign per page: web-home, web-download, web-mac; an English-only page names its own."""
    slug = template_rel.removesuffix("index.html").strip("/")
    page = next((p for p in EN_ONLY_PAGES if p["slug"] == slug), None)
    return page["campaign"] if page else "web-" + (slug or "home")


def en_only_links(indent):
    """The footer links to every English-only page, one <li> each."""
    return "\n".join(f'{indent}<li><a href="/en-us/{p["slug"]}/">{p["link"]}</a></li>' for p in EN_ONLY_PAGES)
METADATA_DIR = REPO_ROOT / "fastlane" / "metadata"

# hreflang takes ISO 639-1 language codes (Google: localized-versions). Filipino has
# no 639-1 code of its own; Tagalog's "tl" is the one Google accepts.
HREFLANG_OVERRIDES = {"fil": "tl"}

# Each page's description is built from that page's own translated text, so every
# language gets a unique one (Google's snippet guidelines; Bing flags pages without).
DESCRIPTION_KEYS = {
    "mac/index.html": ["mac_hero_subtitle"],
    "support/index.html": ["support_subtitle", "faq_q2", "faq_q3", "faq_q5"],
    "faq/index.html": ["faq_a1", "faq_q7", "faq_q8", "faq_q6"],
    "download/index.html": ["download_subtitle", "download_ios_desc", "download_mac_desc"],
    "privacy/index.html": ["privacy_summary", "privacy_collection_text"],
    "terms/index.html": ["terms_intro", "terms_payment_text"],
}
TITLE_KEYS = {  # sub-page titles carry the store subtitle, so they say what Cutling is
    "mac/index.html": "page_title_mac", "support/index.html": "page_title_support",
    "faq/index.html": "page_title_faq", "download/index.html": "page_title_download",
    "privacy/index.html": "page_title_privacy", "terms/index.html": "page_title_terms",
}
FAQ_PAIRS = [f"faq_{n}" for n in (1, 2, 3, 4, 5, 6, 7, 10, 12, 13, 14, 15, 11, 8, 9)]


def plain(value):
    """Translated HTML as plain text, with Cutling's caps filled."""
    text = html_lib.unescape(re.sub(r"<[^>]+>", "", value or ""))
    return re.sub(r"\s+", " ", text).strip()


def text_width(text):
    """Characters as a results page lays them out: CJK and full-width count twice."""
    return sum(2 if unicodedata.east_asian_width(c) in "WF" else 1 for c in text)


def page_description(translation, keys, limit=160, most=200):
    """Whole sentences from the given keys: as many as fit in limit, and a short
    first pass may take one more sentence up to most (widths, CJK counted twice)."""
    sentences = [x for key in keys
                 for x in re.split(r"(?<=[.!?。！？])\s*", plain(translation.get(key, ""))) if x]
    out = ""
    for sentence in sentences:
        cjk = re.match(r"[\u3000-\u9fff]", sentence)
        joined = out + sentence if cjk or not out else f"{out} {sentence}"
        if out and text_width(joined) > (most if text_width(out) < 100 else limit):
            break
        out = joined
    return out


def sub_page_title(code, template_rel, translation):
    title = plain(translation.get(TITLE_KEYS[template_rel], ""))
    subtitle = store_text(code, "subtitle") or store_text(DEFAULT_LOCALE, "subtitle")
    return f"{title} - {subtitle}" if subtitle and subtitle not in title else title


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
        keys = DESCRIPTION_KEYS.get(template_rel)
        description = page_description(translation, keys) if keys else ""
    if description:
        tags.append(f'<meta name="description" content="{esc_attr(description)}">')

    tags += [
        '<meta property="og:type" content="website">',
        f'<meta property="og:url" content="{page_url(code, template_rel)}">',
        f'<meta property="og:image" content="{SITE}/og.png">',
        '<meta property="og:image:width" content="1200">',
        '<meta property="og:image:height" content="630">',
        '<meta name="twitter:card" content="summary_large_image">',
    ]
    if description:
        tags.append(f'<meta property="og:description" content="{esc_attr(description)}">')

    if is_home:
        app = {
            "@context": "https://schema.org",
            # MobileApplication with a named icon file and screenshots, so image lookups
            # tie Cutling to its own icon instead of a screenshot or another clipboard app's.
            "@type": "MobileApplication",
            "name": store_text(code, "name") or "Cutling",
            "alternateName": "Cutling",
            "applicationCategory": "UtilitiesApplication",
            "applicationSubCategory": "Keyboard and clipboard manager",
            "operatingSystem": "iOS, iPadOS, macOS",
            "url": page_url(code, template_rel),
            "image": {"@type": "ImageObject", "url": f"{SITE}/cutling-app-icon.png", "width": 512, "height": 512,
                      "caption": "Cutling app icon"},
            "sameAs": [f"https://apps.apple.com/app/id{APP_ID}"],
            "installUrl": store_url("web-schema"),
            "inLanguage": code,
            "author": {"@type": "Person", "name": "Kenneth Fang", "url": "https://matsuokengo.com"},
        }
        if description:
            app["description"] = description
        if price[0]:
            app["offers"] = {"@type": "Offer", "price": price[0], "priceCurrency": price[1]}
        tags.append('<script type="application/ld+json">' + json.dumps(app, ensure_ascii=False).replace("</", "<\\/") + "</script>")
    elif template_rel in TITLE_KEYS:
        graph = [{"@type": "BreadcrumbList", "itemListElement": [
            {"@type": "ListItem", "position": 1, "name": "Cutling", "item": page_url(code, "index.html")},
            {"@type": "ListItem", "position": 2, "name": plain(translation.get(TITLE_KEYS[template_rel], "")),
             "item": page_url(code, template_rel)}]}]
        if template_rel == "faq/index.html":
            graph.append({"@type": "FAQPage", "mainEntity": [
                {"@type": "Question", "name": plain(translation[f"faq_q{k[4:]}"]),
                 "acceptedAnswer": {"@type": "Answer", "text": plain(translation[f"faq_a{k[4:]}"])}}
                for k in FAQ_PAIRS if f"faq_q{k[4:]}" in translation and f"faq_a{k[4:]}" in translation]})
        ld = {"@context": "https://schema.org", "@graph": graph}
        tags.append('<script type="application/ld+json">' + json.dumps(ld, ensure_ascii=False).replace("</", "<\\/") + "</script>")
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


def faq_pairs(page_html):
    """The question and answer of each <details class="faq-item"> on a page, as plain text."""
    return [(plain(q), plain(a)) for q, a in re.findall(
        r'<details class="faq-item">\s*<summary>(.*?)</summary>\s*<div class="faq-answer">(.*?)</div>\s*</details>',
        page_html, re.S)]


def item_list(page_html):
    """Each <h2 data-item="url">Name</h2> of a list article, in page order, for its ItemList."""
    return [{"@type": "ListItem", "position": n, "name": plain(name), "url": url}
            for n, (url, name) in enumerate(re.findall(r'<h2 data-item="([^"]+)"[^>]*>(.*?)</h2>', page_html, re.S), 1)]


def en_only_ld(page, url, template):
    """The page's own schema.org nodes: WebPage or Article, its breadcrumb, and an ItemList or FAQPage
    when the page carries ranked items or questions."""
    modified = git_date(TEMPLATES_DIR / page["slug"] / "index.html") or datetime.date.today().isoformat()
    main = {"@context": "https://schema.org", "@type": page["type"], "url": url, "inLanguage": "en",
            "datePublished": page["published"], "dateModified": max(modified, page["published"])}
    if page["type"] == "Article":
        main.update({"headline": page["title"], "description": page["description"],
                     "image": f"{SITE}/og.png", "mainEntityOfPage": url,
                     "author": {"@type": "Person", "name": "Kenneth Johannes Fang", "url": f"{SITE}/en-us/"},
                     "about": {"@type": "SoftwareApplication", "name": "Cutling", "url": f"{SITE}/en-us/",
                               "applicationCategory": "UtilitiesApplication", "operatingSystem": "iOS, iPadOS, macOS"}})
    else:
        main["name"] = page["title"]
    ld = [main, {"@context": "https://schema.org", "@type": "BreadcrumbList", "itemListElement": [
        {"@type": "ListItem", "position": 1, "name": "Cutling", "item": f"{SITE}/en-us/"},
        {"@type": "ListItem", "position": 2, "name": page["crumb"], "item": url}]}]
    items = item_list(template)
    if items:
        ld.append({"@context": "https://schema.org", "@type": "ItemList", "name": page["title"],
                   "itemListOrder": "https://schema.org/ItemListUnordered", "itemListElement": items})
    faqs = faq_pairs(template)
    if faqs:
        ld.append({"@context": "https://schema.org", "@type": "FAQPage", "mainEntity": [
            {"@type": "Question", "name": q, "acceptedAnswer": {"@type": "Answer", "text": a}} for q, a in faqs]})
    return ld


def write_en_only_pages(en_translation, locales, available_codes, price):
    """Every page in EN_ONLY_PAGES at /en-us/<slug>/: English only, not part of the locale loop."""
    for page in EN_ONLY_PAGES:
        write_en_only_page(page, en_translation, locales, available_codes, price)


def write_en_only_page(page, en_translation, locales, available_codes, price):
    """templates/<slug>/index.html holds the page's <main>; _en_only_frame.html gives every such page
    the same head, nav and footer."""
    template = (TEMPLATES_DIR / "_en_only_frame.html").read_text(encoding="utf-8").replace(
        "{{PAGE_MAIN}}", (TEMPLATES_DIR / page["slug"] / "index.html").read_text(encoding="utf-8").rstrip())
    url = f"{SITE}/en-us/{page['slug']}/"
    title, description = page["title"], page["description"]
    usd = price[0] and price[1] == "USD"
    price_cell = (f"One-time purchase, ${price[0]} in the US store. No subscription or in-app purchases"
                  if usd else "One-time purchase. No subscription or in-app purchases")
    price_once = f"${price[0]}, paid once" if usd else "paid once"
    template = fill_caps({"faq_a6": en_translation.get("faq_a6", ""), "page": template})["page"].replace("{{SITE}}", SITE)
    ld = en_only_ld(page, url, template)
    tags = [f'<link rel="canonical" href="{url}">',
            f'<link rel="alternate" hreflang="en" href="{url}">',
            f'<link rel="alternate" hreflang="x-default" href="{url}">',
            f'<meta name="description" content="{esc_attr(description)}">',
            '<meta property="og:type" content="website">',
            f'<meta property="og:title" content="{esc_attr(title)}">',
            f'<meta property="og:description" content="{esc_attr(description)}">',
            f'<meta property="og:url" content="{url}">',
            f'<meta property="og:image" content="{SITE}/og.png">',
            '<meta property="og:image:width" content="1200">',
            '<meta property="og:image:height" content="630">',
            '<meta name="twitter:card" content="summary_large_image">']
    tags += ['<script type="application/ld+json">' + json.dumps(x, ensure_ascii=False).replace("</", "<\\/") + "</script>" for x in ld]
    tags.append(EN_ONLY_CSS)
    template = (template.replace("</head>", "    " + "\n    ".join(tags) + "\n</head>", 1)
                .replace("{{PAGE_TITLE}}", esc_attr(title))
                .replace("{{CUTLING_PRICE_CELL}}", price_cell).replace("{{CUTLING_PRICE_ONCE}}", price_once)
                .replace("{{EN_ONLY_LINKS}}", en_only_links("            ").lstrip()))
    root, prefix = compute_root(1, False), compute_lang_prefix(1)
    html = generate_page(template, en_translation, en_translation, DEFAULT_LOCALE, False, root, prefix,
                         build_language_picker(locales, available_codes, DEFAULT_LOCALE, root, "index.html"),
                         f"{page['slug']}/index.html")
    left = sorted(set(re.findall(r"\{\{[A-Za-z_]+\}\}", html)))
    assert not left, f"{page['slug']}: placeholders left unfilled: {left}"
    out = DOCS_DIR / "en-us" / page["slug"] / "index.html"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(html, encoding="utf-8")
    print(f"  Generated en-us/{page['slug']}/")


def write_indexnow_key():
    (DOCS_DIR / f"{INDEXNOW_KEY}.txt").write_text(INDEXNOW_KEY, encoding="utf-8")


def submit_indexnow():
    """Tell IndexNow about every sitemap URL. Prints the HTTP status and never raises."""
    import re
    import urllib.error
    import urllib.request
    urls = re.findall(r"<loc>([^<]+)</loc>", (DOCS_DIR / "sitemap.xml").read_text(encoding="utf-8"))
    body = json.dumps({"host": SITE.split("//", 1)[1], "key": INDEXNOW_KEY,
                       "keyLocation": f"{SITE}/{INDEXNOW_KEY}.txt", "urlList": urls}).encode()
    req = urllib.request.Request(INDEXNOW_ENDPOINT, data=body, method="POST",
                                 headers={"Content-Type": "application/json; charset=utf-8"})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            status = r.status
    except urllib.error.HTTPError as e:
        status = e.code
    except Exception as e:
        print(f"WARNING: IndexNow not reached ({e})")
        return
    print(f"IndexNow: HTTP {status} for {len(urls)} URLs" + ("" if status in (200, 202) else " (WARNING: not 200/202)"))


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
    today = datetime.date.today().isoformat()
    for page in EN_ONLY_PAGES:
        url = f"{SITE}/en-us/{page['slug']}/"
        lines += ["  <url>", f"    <loc>{url}</loc>", f"    <lastmod>{git_date(TEMPLATES_DIR / page['slug']) or today}</lastmod>",
                  f'    <xhtml:link rel="alternate" hreflang="en" href="{url}"/>',
                  f'    <xhtml:link rel="alternate" hreflang="x-default" href="{url}"/>', "  </url>"]
    lines.append("</urlset>")
    (DOCS_DIR / "sitemap.xml").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"  Generated sitemap.xml ({len(codes) * len(TEMPLATES) + len(EN_ONLY_PAGES)} URLs)")


def write_ai_files(en_translation, available_codes, price):
    """llms.txt, llms-full.txt, robots.txt, the .well-known files and a markdown copy of each English page (ai_files.py)."""
    fx = ai_facts.facts(SITE, en_translation, store_text(DEFAULT_LOCALE, "name"), store_text(DEFAULT_LOCALE, "promotional_text"),
                        price, store_url("llms"), store_url("llms", mac=True), "kenneth@matsuokengo.com",
                        len(available_codes), datetime.date.today().isoformat())
    ai_files.write(DOCS_DIR, SITE, fx, lambda rel: (DOCS_DIR / rel / "index.html", f"{SITE}/{rel}"))
    print("  Generated llms.txt, llms-full.txt, robots.txt, .well-known and English index.md pages")


def write_store_source():
    """store-source.js: gives the App Store buttons the visit's source as their campaign token (same file as Undirect's)."""
    (DOCS_DIR / "store-source.js").write_text((TEMPLATES_DIR.parent / "store-source.js").read_text(encoding="utf-8"), encoding="utf-8")


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
    parser.add_argument("--indexnow", action="store_true", help="submit the built sitemap URLs to IndexNow and exit")
    args = parser.parse_args()

    global DOCS_DIR
    if args.output_dir:
        DOCS_DIR = Path(args.output_dir).resolve()
        DOCS_DIR.mkdir(parents=True, exist_ok=True)

    if args.indexnow:
        submit_indexnow()
        return

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
            if is_default:
                page_template = page_template.replace(
                    '</ul>\n        <p class="copyright">',
                    "    " + en_only_links("            ").lstrip() + '\n        </ul>\n        <p class="copyright">')
            if template_rel == "index.html":
                page_template = page_template.replace("{{page_title_home}}", esc_attr(home_title(code, translation)))
            elif template_rel in TITLE_KEYS:
                page_template = page_template.replace("{{" + TITLE_KEYS[template_rel] + "}}",
                                                      esc_attr(sub_page_title(code, template_rel, translation)))
            page_template = page_template.replace(
                "</head>", "    " + head_tags(code, template_rel, translation, available_codes, locales, price) + "\n</head>", 1)

            html = generate_page(
                page_template, translation, en_translation,
                code, is_rtl, root, lang_prefix, picker_html, template_rel
            )

            # On a locale path locale-router.js only records the language: that one line runs inline
            # instead of a render-blocking script request.
            html = html.replace(f'<script src="{root}/locale-router.js"></script>',
                                f"<script>try{{localStorage.setItem('cutling_lang_preference','{web_code(code)}')}}catch(e){{}}</script>")
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
                                          compute_root(template_depth, True), template_rel),
                    template_rel)
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
        write_store_source()
        write_en_only_pages(en_translation, locales, available_codes, price)
        write_ai_files(en_translation, available_codes, price)
        write_indexnow_key()

    print(f"\nDone! Generated {generated_count} pages.")


if __name__ == "__main__":
    main()
