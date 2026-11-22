#!/usr/bin/env python3
"""Puts each language's 2.0 words (docs/aso/events/2.0-locales/<locale>.json, written blind from
docs/aso/events/2.0-strings-brief.md) where they ship, after checking Apple's limits:

- event lines E1/E2/E3 into fastlane/events/2.0/event.json for the store languages
  (`--sale` takes E3s, and E2s where a language wrote it, in place of E3 and E2);
- N_ios into fastlane/metadata/<locale>/release_notes.txt, N_mac into fastlane/metadata_mac/<locale>/;
- the picked button words into docs/aso/events/2.0-glossary.json under "picked", for the app's own strings.

    python3 scripts/apply-2.0-words.py [--sale]

Prints a review table (locale, key, text, back-translation) to docs/aso/events/2.0-review.md."""
import glob, json, os, sys

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
events = os.path.join(root, "docs/aso/events")
spec_path = os.path.join(root, "fastlane/events/2.0/event.json")
limits = {"E1": 30, "E2": 50, "E3": 120, "E3s": 120, "E2s": 50, "N_ios": 4000, "N_mac": 4000}
sale = "--sale" in sys.argv

spec = json.load(open(spec_path, encoding="utf-8"))
glossary = json.load(open(os.path.join(events, "2.0-glossary.json"), encoding="utf-8"))
store = sorted(os.listdir(os.path.join(root, "fastlane/screenshots")))  # the folders App Store Connect holds
problems, rows = [], []
for path in sorted(glob.glob(os.path.join(events, "2.0-locales", "*.json"))):
    loc = os.path.basename(path)[:-5]
    d = json.load(open(path, encoding="utf-8"))
    for key, limit in limits.items():
        if key in d and len(d[key]["text"]) > limit:
            problems.append(f"{loc} {key} {len(d[key]['text'])} > {limit}")
        if key in d:
            rows.append(f"| {loc} | {key} | {d[key]['text'].replace(chr(10), ' / ')} | {d[key].get('back', '').replace(chr(10), ' / ')} |")
    # A button the notes quote must read as the app's own button does.
    app = glossary.get(loc, {}).get("terms", {})
    for word, key in (("Variables", "N_ios"), ("Add Variable", "N_mac")):
        if word in app and key in d and app[word] not in d[key]["text"]:
            problems.append(f"{loc} {key} does not quote the app's {word!r}: {app[word]!r}")
    if "E1" in d and loc in store:
        spec["localizations"][loc] = {
            "name": d["E1"]["text"],
            "shortDescription": d["E2s" if sale and "E2s" in d else "E2"]["text"],
            "longDescription": d["E3s" if sale else "E3"]["text"]}
    for key, tree in (("N_ios", "metadata"), ("N_mac", "metadata_mac")):
        folder = os.path.join(root, "fastlane", tree, loc)
        if key in d and os.path.isdir(folder):
            open(os.path.join(folder, "release_notes.txt"), "w", encoding="utf-8").write(d[key]["text"].strip() + "\n")
    if "glossary" in d and loc in glossary:
        glossary[loc]["picked"] = d["glossary"]

if problems:
    sys.exit("over Apple's limits, nothing written:\n" + "\n".join(problems))
json.dump(spec, open(spec_path, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
json.dump(glossary, open(os.path.join(events, "2.0-glossary.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
open(os.path.join(events, "2.0-review.md"), "w", encoding="utf-8").write(
    "# Cutling 2.0 words: review table\n\nEach line written blind from 2.0-strings-brief.md; back is the writer's literal back-translation.\n\n"
    "| Locale | Key | Text | Back |\n|---|---|---|---|\n" + "\n".join(rows) + "\n")
print(f"event localizations {len(spec['localizations'])}; review rows {len(rows)}")
