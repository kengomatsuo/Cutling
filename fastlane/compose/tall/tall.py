#!/usr/bin/env python3
"""Writes the portrait direction-B pages (iPhone and iPad) from one spec, so every frame keeps
the same safe zones: nothing above SAFE_TOP and nothing below SAFE_BOTTOM, measured in CSS px.

    python3 tall.py <spec.json>     # writes <spec dir>/<device>/panel-N.html

The spec names the wallpaper, the icon, the app name and per frame its headline (with the
data-i18n key the locale renderer swaps) and, per device, the cards: crops of real captures,
[x0, y0, x1, y1] in the capture's own pixels, placed at x, y with width w in CSS px.
Undirect keeps the source of this file, tall.css and fit.js in Support/AppStore/listing-design; Cutling keeps copies in fastlane/compose/tall.
"""
import html, json, os, sys

# CSS canvas, render scale, and the safe band. iPip's iPhone frame puts the island over
# y 89-215 of a 2796-tall shot (screen 247x523 CSS, object-fit cover); SAFE_TOP keeps 85 px
# of air below that at 3x. SAFE_BOTTOM clears the home indicator and the rounded corners.
DEVICES = {
    "iphone": dict(w=440, h=956, scale=3, top=100, bottom=64, gutter=28,
                   headline=56, floor=34, icon=104, name=30, gap=26, radius=26),
    "ipad": dict(w=1032, h=1376, scale=2, top=120, bottom=96, gutter=96,
                 headline=84, floor=48, icon=150, name=44, gap=40, radius=24),
}


def card(c, d):
    x0, y0, x1, y1 = c["crop"]
    k = c["w"] / (x1 - x0)
    h = round((y1 - y0) * k, 1)
    x = c.get("x", (d["w"] - c["w"]) / 2)
    y = c["y"]
    assert y >= d["top"] and y + h <= d["h"] - d["bottom"], (c["src"], y, y + h)
    assert x >= 0 and x + c["w"] <= d["w"], (c["src"], x)
    src = c["src"]
    natural = c.get("natural")  # capture width in px; tall.py does not read images
    img_w = round(natural * k, 2)
    z = c.get("z", 2)
    return (h, '<div class="card" data-protect="device" style="left:%.1fpx;top:%.1fpx;width:%spx;height:%spx;border-radius:%spx;z-index:%d">'
            '<img src="%s" style="width:%spx;left:%.2fpx;top:%.2fpx" alt=""></div>'
            % (x, y, c["w"], h, c.get("r", d["radius"]), z, src, img_w, -x0 * k, -y0 * k))


def page(spec, frame, dev):
    d = DEVICES[dev]
    cards = frame["cards"][dev]
    built = [card(c, d) for c in cards]
    first = min(c["y"] for c in cards)
    text_at = frame.get("text", "top")
    if text_at == "top":
        wtop, wbot = d["top"], first - d["gap"]
    else:  # the copy sits under the last card
        last = max(c["y"] + h for c, (h, _) in zip(cards, built))
        wtop, wbot = last + d["gap"], d["h"] - d["bottom"]
    assert wbot - wtop > 80, (frame["n"], dev, wtop, wbot)
    hl = frame["headline"]
    lines = "<br>".join(html.escape(l) for l in hl.split("\n"))
    nowrap = ' data-nowrap="1"' if "\n" in hl else ""
    size = frame.get("size", {}).get(dev, d["headline"])
    cover = ""
    if frame.get("cover"):
        cover = ('<img class="icon" src="%s" style="width:%dpx;height:%dpx;margin-bottom:%dpx">'
                 '<div class="name" style="font-size:%dpx;margin-bottom:%dpx">%s</div>'
                 % (spec["icon"], d["icon"], d["icon"], round(d["icon"] * .16), d["name"], round(d["name"] * .62), html.escape(spec["name"])))
    return """<!doctype html><html class="%s"><head><meta charset="utf-8">
<link rel="stylesheet" href="../../tall.css">
<style>.headline{font-size:%dpx%s}</style>
</head><body><div class="panel %s">
<img class="wall" src="%s">
%s
<div class="wrap" data-protect="copy" style="left:%dpx;right:%dpx;top:%dpx;height:%dpx">%s
<div class="headline" data-fit data-fit-floor="%d" data-i18n="p%d.headline"%s>%s</div></div>
</div><script src="../../fit.js"></script></body></html>
""" % (dev, size, ";white-space:nowrap" if nowrap else "", spec.get("theme", ""), spec["wall"], "\n".join(b for _, b in built),
       d["gutter"], d["gutter"], wtop, wbot - wtop, cover, d["floor"], frame["n"], nowrap, lines)


def main():
    path = os.path.abspath(sys.argv[1])
    spec = json.load(open(path))
    root = os.path.dirname(path)
    for dev in DEVICES:
        out = os.path.join(root, dev)
        os.makedirs(out, exist_ok=True)
        # a frame a device lacks is skipped, and the device's panels stay numbered 1..N
        for i, f in enumerate([f for f in spec["frames"] if dev in f["cards"]], 1):
            open(os.path.join(out, "panel-%d.html" % i), "w").write(page(spec, f, dev))
        print("wrote", out)


if __name__ == "__main__":
    main()
