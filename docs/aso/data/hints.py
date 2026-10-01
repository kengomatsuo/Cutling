#!/usr/bin/env python3
"""What people type: App Store type-ahead suggestions per storefront.

Usage: hints.py seeds.json out.json
seeds.json = {"US": ["pop up", "clipboard"], "DE": ["werbe", ...], ...}
Suggestions come back in Apple's own order, which signals popularity but gives
no volume. The run date is stored in the output.
"""
import concurrent.futures as cf
import datetime
import json
import re
import sys
import time
import urllib.parse
import urllib.request

from storefronts import STOREFRONTS


def hint(storefront, term, tries=3):
    url = ("https://search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints"
           "?clientApplication=Software&term=" + urllib.parse.quote(term))
    req = urllib.request.Request(url, headers={
        "X-Apple-Store-Front": f"{storefront}-1,29", "User-Agent": "AppStore/3.0 iOS/17.0"})
    for i in range(tries):
        try:
            text = urllib.request.urlopen(req, timeout=20).read().decode("utf8")
            return re.findall(r"<key>term</key>\s*<string>(.*?)</string>", text, flags=re.S)
        except Exception:
            time.sleep(1 + i)
    return None


def main(seeds_path, out_path):
    seeds = json.load(open(seeds_path))
    out = {"collected": datetime.date.today().isoformat(), "hints": {}}
    jobs = [(country, term) for country, terms in seeds.items() for term in terms]

    def run(job):
        country, term = job
        return country, term, hint(STOREFRONTS[country], term)

    with cf.ThreadPoolExecutor(6) as pool:
        for country, term, found in pool.map(run, jobs):
            out["hints"].setdefault(country, {})[term] = found
    json.dump(out, open(out_path, "w"), ensure_ascii=False, indent=1)
    print(f"{len(jobs)} seeds, {sum(1 for c in out['hints'].values() for v in c.values() if v)} answered")


if __name__ == "__main__":
    main(*sys.argv[1:3])
