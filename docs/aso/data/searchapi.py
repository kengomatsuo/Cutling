#!/usr/bin/env python3
"""iTunes Search API probe (documented: https://performance-partners.apple.com/search-api).

Usage: searchapi.py APP_ID queries.json out.json
Same queries.json as rank.py. The API returns at most 200 results (limit=200) and allows
about 20 calls a minute, so this sleeps 3.3 s between calls and backs off on 403/429.
Resumable: queries already in out.json are skipped. Per query it stores the result count,
the app's rank (null = not in the top 200) and the top 15 with rating count and the first
300 characters of the description (used to judge relevance).
"""
import datetime, json, os, sys, time, urllib.parse, urllib.request

from storefronts import STOREFRONTS


def search(country, term):
    url = "https://itunes.apple.com/search?" + urllib.parse.urlencode(
        {"term": term, "country": country.lower(), "entity": "software", "limit": 200})
    for attempt in range(8):
        try:
            data = json.load(urllib.request.urlopen(url, timeout=40))
            if "results" in data:
                return data
        except Exception:
            pass
        time.sleep(65)
    return None


def record(app_id, data):
    res = data["results"]
    ids = [str(r["trackId"]) for r in res]
    return {"n": data["resultCount"], "rank": ids.index(str(app_id)) + 1 if str(app_id) in ids else None,
            "top": [{"id": str(r["trackId"]), "name": r["trackName"], "n": r.get("userRatingCount") or 0,
                     "r": r.get("averageUserRating"), "desc": (r.get("description") or "")[:300]}
                    for r in res[:15]]}


def main(app_id, queries_path, out_path):
    queries = json.load(open(queries_path))
    out = (json.load(open(out_path)) if os.path.exists(out_path)
           else {"collected": datetime.date.today().isoformat(), "app": app_id, "cap": 200, "res": {}})
    for country, terms in queries.items():
        if country not in STOREFRONTS:
            continue
        for term in terms:
            key = f"{country}|{term}"
            if key in out["res"]:
                continue
            t0 = time.time()
            data = search(country, term)
            if data is None:
                print("FAIL", key, flush=True)
                continue
            out["res"][key] = record(app_id, data)
            json.dump(out, open(out_path, "w"), ensure_ascii=False)
            time.sleep(max(0, 3.3 - (time.time() - t0)))
    print("ok", len(out["res"]))


if __name__ == "__main__":
    main(*sys.argv[1:4])
