#!/usr/bin/env python3
"""Checks a language's words file for direction C before it is rendered: the shape the brief asks for, every
placeholder the build fills, the chips each headline needs, and the lengths the frames hold.

    python3 check_words.py <locale> [...]      exit 1 and one line per problem
"""
import json, re, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
FACTS = json.loads((HERE.parents[3] / "docs/aso/screens-2.0/locale-facts.json").read_text())

def problems(loc):
    p = HERE / "words" / f"{loc}.json"
    if not p.exists():
        return ["no words file"]
    try:
        w = json.loads(p.read_text())
    except json.JSONDecodeError as e:
        return [f"not JSON: {e}"]
    out = []
    cs, C = w.get("cseed", {}), w.get("C", {})
    need = {"reply": {"{name}", "{date}"}, "mac_reply": {"{name}", "{plan}", "{date}"}, "delivered": {"{date}"}}
    for key, ph in need.items():
        got = set(re.findall(r"\{\w+\}", cs.get(key, "")))
        if got != ph:
            out.append(f"cseed.{key} has {sorted(got)}, needs {sorted(ph)}")
    if len(cs.get("names", [])) < 3:
        out.append("cseed.names needs three names")
    if len(cs.get("plan_choices", [])) != 2:
        out.append("cseed.plan_choices needs two plans")
    for key in ("mac_name", "reply_name", "name_label", "plan_label", "delivered_name"):
        if not cs.get(key):
            out.append(f"cseed.{key} is empty")
    f = FACTS[loc]
    if cs.get("reply") and len(cs["reply"].replace("{name}", cs["names"][0] if cs.get("names") else "").replace("{date}", f["weekday_tue_nov24"])) > 60:
        out.append("cseed.reply runs past 60 characters filled")
    frames = {"iphone": {"1": "ks", "2": "ks", "3": "ks", "4": "khs", "5": "khs", "6": "khs"},
              "mac": {"1": "ks", "2": "khs", "3": "ks", "4": "khs", "5": "khs"}}
    for dev, fr in frames.items():
        for n, keys in fr.items():
            t = C.get(dev, {}).get(n, {})
            for k in keys:
                if not t.get(k):
                    out.append(f"C.{dev}.{n}.{k} is empty")
    ip = C.get("iphone", {})
    if ip.get("4", {}).get("h", "").count("[") < 3:
        out.append("C.iphone.4.h needs three chips")
    for dev, n in (("iphone", "5"), ("iphone", "6"), ("mac", "4"), ("mac", "5")):
        if "[" not in C.get(dev, {}).get(n, {}).get("h", ""):
            out.append(f"C.{dev}.{n}.h has no chip")
    if f["n5000"] not in ip.get("5", {}).get("h", ""):
        out.append(f"C.iphone.5.h does not write 5000 as {f['n5000']!r}")
    if C.get("mac", {}).get("2", {}).get("h") != "{cmd}":
        out.append("C.mac.2.h must be {cmd}")
    for dev, fr in ((d, f) for d, f in C.items() if isinstance(f, dict)):
        for n, t in fr.items():
            for k, v in t.items():
                if v.count("[") != v.count("]"):
                    out.append(f"C.{dev}.{n}.{k} has unbalanced chip brackets")
    return out

if __name__ == "__main__":
    bad = 0
    for loc in sys.argv[1:]:
        for pr in problems(loc):
            print(f"{loc}: {pr}"); bad += 1
    sys.exit(1 if bad else 0)
