#!/usr/bin/env python3
"""Writes and renders the Paste-style store frames from spec.json.

    python3 fastlane/compose/paste_style/build.py [--design S1] [--locale en-US] [--strings file.json]

The frames of a design are one strip: build.py writes the strip once per frame, slid so that frame
fills the page (pages/<design>-<locale>-<frame>.html), and headless Chrome (../render_cdp.mjs, run
with bun) renders each to out/<design>-<locale>-<frame>.png at 1320x2868. The frames joined side by
side go to out/<design>-<locale>-strip.png, and the boxes Chrome measured go beside each frame as
.json for check.py. Copy that will not fit at its floor fails the run.
--strings names a JSON object of copy keys for one locale; a key it lacks falls back to en-US.
A locale that locales.json marks rtl is set right to left, so its copy starts at the phone's right edge.
"""
import argparse, html, json, os, re, subprocess, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
WORDS = ("pull", "note", "what")  # prose in the spec, never drawn


def px(v):
    """A spec number is pixels; a spec string is a CSS value as written."""
    return "%spx" % v if isinstance(v, (int, float)) else v


def leaves(node, path=()):
    """Every drawable leaf of the spec's base as (custom property, CSS value)."""
    for k, v in node.items():
        if k in WORDS:
            continue
        if isinstance(v, dict):
            yield from leaves(v, path + (k,))
        else:
            yield "--" + "-".join(path + (k,)), px(v)


def root_vars(spec, shift):
    """The custom properties every element shares, plus where the strip sits for this page."""
    out = dict(leaves(spec["base"]))
    c = spec["base"]["canvas"]
    out["--strip-w"] = px(c["w"] * len(spec["frames"]))
    out["--strip-shift"] = px(-c["w"] * shift)
    out["--capture-w"] = px(spec["capture"]["w"])
    return out


def own(**values):
    """Custom properties set on one element."""
    return ' style="%s"' % ";".join("--%s:%s" % (k, px(v)) for k, v in values.items())


def line(text):
    """Copy to markup: a newline is a set line break, *words* take the accent colour."""
    return re.sub(r"\*(.+?)\*", r"<em>\1</em>", html.escape(text, quote=False)).replace("\n", "<br>")


def patch(p):
    if "fill" in p:
        return '<i class="patch"%s></i>' % own(x=p["x"], y=p["y"], w=p["w"], h=p["h"], fill=p["fill"])
    return '<i class="patch src-%s"%s></i>' % (p["from"], own(x=p["x"], y=p["y"], w=p["w"], h=p["h"], bx=-p["sx"], by=-p["sy"]))


def surface(src, sx, sy, w, h, inner):
    return '<div class="surface src-%s"%s>%s</div>' % (src, own(w=w, h=h, bx=-sx, by=-sy), inner)


def screen(spec, frame, copy):
    """What sits on a capture inside a phone: patches, the redrawn clock, the bubble, the tap mark."""
    parts = [patch(p) for p in frame.get("patches", [])]
    parts.append('<span class="clock"%s>%s</span>' % (own(fill=frame["clock"]["fill"]), html.escape(copy["clock"])))
    if "bubble" in frame:
        b = frame["bubble"]
        parts.append('<div class="bubble" data-i18n="%s"%s>%s</div>' % (b["text"], own(x=b["x"], y=b["y"]), html.escape(copy[b["text"]], quote=False)))
    if "tap" in frame:
        parts.append('<i class="tap"%s></i>' % own(x=frame["tap"]["x"], y=frame["tap"]["y"]))
    cap = spec["capture"]
    return surface(frame["key"], cap["w"] - cap["w"], cap["h"] - cap["h"], cap["w"], cap["h"], "".join(parts))


def phone(spec, p, frames, copy):
    return ('<div class="phone" data-protect="device"%s>'
            '<i class="btn left action"></i><i class="btn left up"></i><i class="btn left down"></i><i class="btn right power"></i>'
            '<div class="bezel"></div><div class="screen">%s</div></div>'
            % (own(x=p["x"], y=p["y"], k=p["k"]), screen(spec, frames[p["frame"]], copy)))


def lift(t):
    inner = "".join(patch(p) for p in t.get("patches", []))
    return '<div class="lift"%s>%s</div>' % (own(x=t["x"], y=t["y"], w=t["w"], h=t["h"], r=t["r"], k=t["k"]),
                                              surface(t["from"], t["sx"], t["sy"], t["w"], t["h"], inner))


def words(spec, i, frame, copy):
    head = copy[frame["copy"]["headline"]]
    nowrap = ' data-nowrap="1"' if "\n" in head else ""
    sub = '<div class="sub" data-fit data-fit-floor="%s" data-i18n="%s">%s</div>' % (
        spec["base"]["sub"]["floor"], frame["copy"]["sub"], line(copy[frame["copy"]["sub"]]))
    return ('<div class="frame"%s><div class="wrap" data-protect="copy"><div class="headline" data-fit data-fit-floor="%s" data-i18n="%s"%s>%s</div>%s</div></div>'
            % (own(i=str(i)), spec["base"]["headline"]["floor"], frame["copy"]["headline"], nowrap, line(head), sub))


def page(spec, design, shift, copy, locale, rtl):
    d = spec["designs"][design]
    frames = {f["key"]: f for f in spec["frames"]}
    root = ":root{%s}" % ";".join("%s:%s" % kv for kv in root_vars(spec, shift).items())
    srcs = "".join('.src-%s{background-image:url("%s")}' % (f["key"], f["capture"]) for f in spec["frames"])
    body = "\n".join([words(spec, i, f, copy) for i, f in enumerate(spec["frames"])]
                     + [phone(spec, p, frames, copy) for p in d["phones"]]
                     + [lift(t) for t in d["lifts"]])
    return """<!doctype html><html lang="%s" dir="%s"><head><meta charset="utf-8">
<link rel="stylesheet" href="../paste_style.css">
<style>%s
%s</style>
</head><body><div class="strip">
%s
</div><script src="../../tall/fit.js"></script></body></html>
""" % (locale, "rtl" if rtl else "ltr", root, srcs, body)


def copy_for(spec, locale, strings):
    copy = dict(spec["copy"]["en-US"])
    copy.update(spec["copy"].get(locale, {}))
    if strings:
        copy.update(json.load(open(strings)))
    return copy


def is_rtl(locale):
    return any(l["code"] == locale and l["rtl"] for l in json.load(open(os.path.join(HERE, "..", "..", "..", "locales.json"))))


def main():
    spec = json.load(open(os.path.join(HERE, "spec.json")))
    ap = argparse.ArgumentParser()
    ap.add_argument("--design", action="append", choices=sorted(spec["designs"]))
    ap.add_argument("--locale", default="en-US")
    ap.add_argument("--strings")
    a = ap.parse_args()
    copy, rtl, c = copy_for(spec, a.locale, a.strings), is_rtl(a.locale), spec["base"]["canvas"]
    jobs, strips = [], []
    for d in ("pages", "out"):
        os.makedirs(os.path.join(HERE, d), exist_ok=True)
    for design in a.design or [spec["recommended"]]:
        stem = os.path.join(HERE, "%s", "%s-%s-" % (design, a.locale))
        pngs = []
        for shift, frame in enumerate(spec["frames"]):
            path = stem % "pages" + frame["key"] + ".html"
            open(path, "w").write(page(spec, design, shift, copy, a.locale, rtl))
            pngs.append(stem % "out" + frame["key"] + ".png")
            jobs.append(dict(page=path, png=pngs[-1], w=c["w"], h=c["h"], scale=1))
        strips.append((pngs, stem % "out" + "strip.png"))
    work = tempfile.mkdtemp(prefix="cutling-paste-style-")
    jp, rp = os.path.join(work, "jobs.json"), os.path.join(work, "results.json")
    json.dump(jobs, open(jp, "w"))
    subprocess.run(["bun", os.path.join(HERE, "..", "render_cdp.mjs"), jp, rp, "1"], check=True, stdout=subprocess.DEVNULL)
    bad = 0
    for job, r in zip(jobs, json.load(open(rp))):
        bad += not r["ok"]
        json.dump(r.get("boxes"), open(os.path.splitext(job["png"])[0] + ".json", "w"))
        sizes = [(k["name"], k["px"]) for k in r["boxes"]["copy"]] if r.get("boxes") else []
        print("OK  " if r["ok"] else "FAIL", os.path.relpath(job["png"], HERE), sizes, "" if r["ok"] else r.get("error"))
    if not bad:
        for pngs, strip in strips:
            subprocess.run(["magick", *pngs, "+append", strip], check=True)
            print("OK  ", os.path.relpath(strip, HERE))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
