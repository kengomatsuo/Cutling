# Keyword probes (Cutling, App Store id 6759476314)

Three probes, all standard library Python 3, all run from this folder. Every run goes into a
new dated file so two runs can be compared. `queries.json` and `seeds.json` are the term lists
(storefront code to list of terms); `storefronts.py` maps codes to App Store storefront ids.

| file | what it holds | endpoint |
|---|---|---|
| `hints-<date>.json` | type-ahead suggestions per term, in Apple's order | `https://search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints` |
| `ranks-<date>.json` | live App Store search: result count (cap 250), Cutling rank, top 15 with rating counts | `https://search.itunes.apple.com/WebObjects/MZStore.woa/wa/search` |
| `searchapi-<date>.json` | iTunes Search API: result count (cap 200), Cutling rank, top 15 with description snippet | `https://itunes.apple.com/search` |
| `keyword-measurements.json` | the three merged per storefront and term (built by the analysis step, not a probe) | |

## Rerun at 48 hours and at 3 to 4 weeks after a keyword change

```bash
cd docs/aso/data
D=$(date +%F)                                   # e.g. 2026-10-03
python3 hints.py seeds.json hints-$D.json       # about 3 minutes
python3 rank.py 6759476314 queries.json ranks-$D.json     # about 1 to 2 hours, one process only
python3 searchapi.py 6759476314 queries.json searchapi-$D.json   # 3.3 s per query, about 1.3 hours
```

`rank.py` and `searchapi.py` skip queries already in the output file, so an interrupted run is
resumed by repeating the same command. Compare `cutlingRank` per `storefront|term` between dated files.

## Rate limits (hit on 2026-10-01)

- Search API: Apple documents about 20 calls a minute; the scripts pace at 3.3 s.
- The two `search.itunes.apple.com` endpoints (hints and live search) are not documented. Three
  `rank.py` processes in parallel plus a type-ahead run drew `403` on the live search and `429`
  with a `retry-after` of about 26 minutes on hints. Run `rank.py` as one process, and wait out
  the `retry-after` before retrying.
- Storefront ids in `storefronts.py` were each checked live: the live search answers with
  `meta.storefront.cc` and the id, and both matched. Bangladesh (143490) answered with an empty
  page and the Search API returns 0 results for `country=bd`, so BD has no live search and is
  left out. Iran has no storefront.
