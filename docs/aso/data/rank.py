#!/usr/bin/env python3
"""Live App Store search per storefront: how crowded a query is and where an app ranks.

Usage: rank.py APP_ID queries.json out.json
queries.json = {"US": ["pop up blocker", ...], "DE": [...], ...}
For each query: the number of results (Apple caps near 250), the app's rank or
null, and the top 15 with name, subtitle and rating count. Resumable: queries
already in out.json are skipped, so rerun the same file at 48 hours and again
at 3 to 4 weeks after a keyword change, into a new out file.
"""
import datetime
import json
import os
import sys
import time
import urllib.parse
import urllib.request

from storefronts import STOREFRONTS


def search(storefront, term):
    url = ("https://search.itunes.apple.com/WebObjects/MZStore.woa/wa/search"
           "?clientApplication=Software&media=software&term=" + urllib.parse.quote(term))
    for attempt in range(4):
        for header in (f"{storefront},29", f"{storefront}-2,29", f"{storefront}-1,29"):
            req = urllib.request.Request(url, headers={
                "X-Apple-Store-Front": header,
                "User-Agent": "iTunes/12.9 (Macintosh; OS X 10.15) AppleWebKit/605"})
            try:
                return json.load(urllib.request.urlopen(req, timeout=30))
            except Exception:
                time.sleep(1)
        time.sleep(4 * (attempt + 1))
    return None


def main(app_id, queries_path, out_path):
    queries = json.load(open(queries_path))
    out = (json.load(open(out_path)) if os.path.exists(out_path)
           else {"collected": datetime.date.today().isoformat(), "app": app_id, "res": {}})
    for country, terms in queries.items():
        for term in terms:
            key = f"{country}|{term}"
            if out["res"].get(key):
                continue
            data = search(STOREFRONTS[country], term)
            if not data:
                print("FAIL", key, flush=True)
                continue
            bubbles = data.get("pageData", {}).get("bubbles") or []
            ids = [r["id"] for r in bubbles[0]["results"]] if bubbles else []
            lockups = data.get("storePlatformData", {}).get("native-search-lockup", {}).get("results", {})
            top = []
            for i in ids[:15]:
                x = lockups.get(i, {})
                rating = x.get("userRating") or {}
                top.append({"id": i, "name": x.get("name"), "sub": x.get("subtitle"),
                            "n": rating.get("ratingCount"), "r": rating.get("value")})
            out["res"][key] = {"n": len(ids), "rank": ids.index(app_id) + 1 if app_id in ids else None,
                               "top": top}
            json.dump(out, open(out_path, "w"), ensure_ascii=False, indent=1)
            time.sleep(1.2)
    print("ok", len(out["res"]))


if __name__ == "__main__":
    main(*sys.argv[1:4])
