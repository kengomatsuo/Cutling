#!/usr/bin/env python3
"""Lists, per page, every capture a language takes from another language's folder (the build falls back to en-US).
    python3 fallbacks.py        prints the table and writes out/fallbacks.md"""
import lib

USES = {   # which captures each page's frames show
    "main": ["phone-guide", "phone-grid", "pad-guide", "pad-grid", "mac-picker"] + [],
    "personal-details": ["phone-guide", "phone-grid", "pad-guide", "pad-grid"],
    "quick-replies": ["phone-grid", "pad-grid", "mac-picker"],
    "text-expander": ["phone-formatted", "phone-grid2", "pad-grid", "mac-picker"],
    "clipboard-history": ["phone-grid2", "pad-grid", "mac-history"],
    "notes-you-paste": ["phone-note", "phone-formatted", "phone-grid2", "pad-grid"],
}
EN_ONLY = {"main": {"en-US": ["phone-grid2", "phone-note"]}}   # 2.0 captures the en-US main page shows

def missing(loc, key):
    lib.FALLBACKS.clear(); lib.cap(loc, key); return bool(lib.FALLBACKS)

rows = []
for page, keys in USES.items():
    locs = lib.STORE if page in ("main", "personal-details", "quick-replies") else lib.ENGLISH
    for loc in locs:
        ks = keys + EN_ONLY.get(page, {}).get(loc, [])
        m = [k for k in ks if missing(loc, k)]
        if m:
            rows.append((page, loc, m))
out = ["| Page | Locale | Captures shown from en-US |", "|---|---|---|"] + [f"| {p} | {l} | {', '.join(m)} |" for p, l, m in rows]
(lib.HERE / "out" / "fallbacks.md").write_text("\n".join(out) + "\n")
print("\n".join(out))
