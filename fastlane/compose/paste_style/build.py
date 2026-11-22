#!/usr/bin/env python3
"""Writes and renders the Paste-style store frames from spec.json.

    python3 fastlane/compose/paste_style/build.py [--variant A] [--locale en-US] [--strings file.json]

One page per frame goes to pages/<variant>-<locale>-<frame>.html; headless Chrome (../render_cdp.mjs,
run with bun) renders each to out/<variant>-<locale>-<frame>.png at 1320x2868, and the boxes Chrome
measured go beside it as .json for check.py. A headline that will not fit at its floor fails the run.
--strings names a JSON object of copy keys for one locale; a key it lacks falls back to en-US.
A locale that locales.json marks rtl is set right to left, so its copy starts at the phone's right edge.
"""
import argparse, html, json, os, re, subprocess, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))


def leaves(node, path=()):
    """Every drawable leaf as (css-name, css-value). Numbers are px; strings are written as they are."""
    for k, v in node.items():
        if k in ("pull", "note", "extends"):
            continue
        if isinstance(v, dict):
            yield from leaves(v, path + (k,))
        else:
            yield "--" + "-".join(path + (k,)), ("%spx" % v if isinstance(v, (int, float)) else v)


def variant_of(spec, name):
    """A variant with the one it extends laid under it, group by group."""
    v = spec["variants"][name]
    if "extends" not in v:
        return v
    out = {k: dict(g) if isinstance(g, dict) else g for k, g in variant_of(spec, v["extends"]).items()}
    for k, g in v.items():
        out[k] = {**out.get(k, {}), **g} if isinstance(g, dict) else g
    return out


def css_vars(spec, variant, frame):
    out = dict(leaves(spec["base"]))
    out.update(leaves(variant_of(spec, variant)))
    if "tap" in frame and "tap" in variant_of(spec, variant):
        out.update(leaves(frame["tap"], ("tap",)))
    return out


def line(text):
    """Copy to markup: a newline is a set line break, *words* take the accent colour."""
    return re.sub(r"\*(.+?)\*", r"<em>\1</em>", html.escape(text)).replace("\n", "<br>")


def page(spec, variant, frame, copy, locale, rtl):
    v = variant_of(spec, variant)
    head = copy[frame["copy"]["headline"]]
    nowrap = ' data-nowrap="1"' if "\n" in head else ""
    sub = ""
    if "sub" in v and "sub" in frame["copy"]:
        sub = '<div class="sub" data-fit data-fit-floor="%s" data-i18n="%s">%s</div>' % (
            v["sub"]["floor"], frame["copy"]["sub"], line(copy[frame["copy"]["sub"]]))
    tap = '<i class="tap"></i>' if "tap" in v and "tap" in frame else ""
    root = ":root{%s}" % ";".join("%s:%s" % kv for kv in css_vars(spec, variant, frame).items())
    return """<!doctype html><html lang="%s" dir="%s"><head><meta charset="utf-8">
<link rel="stylesheet" href="../paste_style.css">
<style>%s</style>
</head><body><div class="panel">
<div class="wrap" data-protect="copy"><div class="headline" data-fit data-fit-floor="%s" data-i18n="%s"%s>%s</div>%s</div>
<div class="phone" data-protect="device">
<i class="btn left action"></i><i class="btn left up"></i><i class="btn left down"></i><i class="btn right power"></i>
<div class="bezel"></div>
<div class="screen" data-protect="screen"><img src="%s" alt="">%s</div>
</div>
</div><script src="../../tall/fit.js"></script></body></html>
""" % (locale, "rtl" if rtl else "ltr", root, spec["base"]["headline"]["floor"], frame["copy"]["headline"], nowrap, line(head), sub, frame["capture"], tap)


def main():
    spec = json.load(open(os.path.join(HERE, "spec.json")))
    ap = argparse.ArgumentParser()
    ap.add_argument("--variant", action="append", choices=sorted(spec["variants"]))
    ap.add_argument("--locale", default="en-US")
    ap.add_argument("--strings")
    a = ap.parse_args()
    copy = dict(spec["copy"]["en-US"])
    copy.update(spec["copy"].get(a.locale, {}))
    if a.strings:
        copy.update(json.load(open(a.strings)))
    rtl = any(l["code"] == a.locale and l["rtl"] for l in json.load(open(os.path.join(HERE, "..", "..", "..", "locales.json"))))
    c = spec["base"]["canvas"]
    jobs = []
    for d in ("pages", "out"):
        os.makedirs(os.path.join(HERE, d), exist_ok=True)
    for variant in a.variant or [spec["recommended"]]:
        for frame in spec["frames"]:
            stem = "%s-%s-%s" % (variant, a.locale, frame["key"])
            path = os.path.join(HERE, "pages", stem + ".html")
            open(path, "w").write(page(spec, variant, frame, copy, a.locale, rtl))
            jobs.append(dict(page=path, png=os.path.join(HERE, "out", stem + ".png"), w=c["w"], h=c["h"], scale=1))
    work = tempfile.mkdtemp(prefix="cutling-paste-style-")
    jp, rp = os.path.join(work, "jobs.json"), os.path.join(work, "results.json")
    json.dump(jobs, open(jp, "w"))
    subprocess.run(["bun", os.path.join(HERE, "..", "render_cdp.mjs"), jp, rp, "1"], check=True, stdout=subprocess.DEVNULL)
    bad = 0
    for job, r in zip(jobs, json.load(open(rp))):
        bad += not r["ok"]
        json.dump(r.get("boxes"), open(job["png"][:-4] + ".json", "w"))
        px = [(k["name"], k["px"]) for k in r["boxes"]["copy"]] if r.get("boxes") else []
        print("OK  " if r["ok"] else "FAIL", os.path.relpath(job["png"], HERE), px, "" if r["ok"] else r.get("error"))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
