#!/usr/bin/env python3
"""Writes the free-limit and unlock strings from scripts/unlock-l10n/drafts/<language>.json into every locale's
Localizable.strings (the keyboard's message into CutlingKeyboard/, the rest into Cutling/).

Each draft was written blind from scripts/unlock-l10n/brief.md (no locale is the source of another); keys.json maps the
brief's key IDs to the keys the code looks up. A key the file already has is replaced in place; a new one is added
under one MARK section. "Close" is left alone where a locale already has it, because other screens use that label.

  python3 scripts/unlock-l10n/merge.py [--dry]
"""
import json
import pathlib
import re
import sys

repo = pathlib.Path(__file__).resolve().parents[2]
keys = json.loads((repo / "scripts/unlock-l10n/keys.json").read_text())
KEEP_EXISTING = {"S17"}
KEYBOARD = {"K1"}
MARK = "/* MARK: - Free limit and unlock (scripts/unlock-l10n, written blind per locale) */"
LINE = re.compile(r'^"((?:[^"\\]|\\.)*)"\s*=\s*"((?:[^"\\]|\\.)*)";\s*$')


def escape(s: str) -> str:
    return s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")


def write(path: pathlib.Path, entries: dict[str, str], keep: set[str], dry: bool) -> int:
    lines = path.read_text(encoding="utf-8").split("\n")
    index = {}
    for n, line in enumerate(lines):
        m = LINE.match(line)
        if m:
            index[m.group(1)] = n
    added = []
    changed = 0
    for key, value in entries.items():
        k = escape(key)
        new = f'"{k}" = "{escape(value)}";'
        if k in index:
            if key in keep:
                continue
            if lines[index[k]] != new:
                lines[index[k]] = new
                changed += 1
        else:
            added.append(new)
    if added:
        if MARK not in lines:
            while lines and lines[-1] == "":
                lines.pop()
            lines += ["", MARK]
        at = lines.index(MARK) + 1
        while at < len(lines) and LINE.match(lines[at]):
            at += 1
        lines[at:at] = added
    if not dry and (added or changed):
        text = "\n".join(lines)
        path.write_text(text if text.endswith("\n") else text + "\n", encoding="utf-8")
    return len(added) + changed


def main() -> None:
    dry = "--dry" in sys.argv
    total = 0
    seen = set()
    for draft in sorted((repo / "scripts/unlock-l10n/drafts").glob("*.json")):
        for folder, strings in json.loads(draft.read_text(encoding="utf-8")).items():
            seen.add(folder)
            app = {keys[i]: v["s"] for i, v in strings.items() if i in keys and i not in KEYBOARD}
            kb = {keys[i]: v["s"] for i, v in strings.items() if i in KEYBOARD}
            keep = {keys[i] for i in KEEP_EXISTING}
            for target, entries in ((repo / f"Cutling/{folder}.lproj/Localizable.strings", app),
                                    (repo / f"CutlingKeyboard/{folder}.lproj/Localizable.strings", kb)):
                if not target.exists():
                    print(f"missing {target.relative_to(repo)}")
                    continue
                total += write(target, entries, keep, dry)
    # Second batch: keys2.json gives each key its target (Cutling, CutlingKeyboard or CutlingShare) and its code key.
    keys2 = json.loads((repo / "scripts/unlock-l10n/keys2.json").read_text())
    for draft in sorted((repo / "scripts/unlock-l10n/drafts2").glob("*.json")):
        for folder, strings in json.loads(draft.read_text(encoding="utf-8")).items():
            by_target: dict[str, dict[str, str]] = {}
            for i, v in strings.items():
                if i in keys2:
                    target, key = keys2[i]
                    by_target.setdefault(target, {})[key] = v["s"]
            for target, entries in by_target.items():
                path = repo / f"{target}/{folder}.lproj/Localizable.strings"
                if not path.exists():
                    print(f"missing {path.relative_to(repo)}")
                    continue
                total += write(path, entries, set(), dry)
    missing = sorted(p.parent.name[:-6] for p in (repo / "Cutling").glob("*.lproj/Localizable.strings"))
    print(f"{'would change' if dry else 'changed'} {total} entries; locale folders without a draft: {[m for m in missing if m not in seen]}")


main()
