#!/usr/bin/env python3
"""Checks the Paste-style frames against spec.json and prints every miss.

    python3 fastlane/compose/paste_style/check.py        # after build.py

It prints any number the stylesheet or a built page holds that spec.json lacks, any custom property
drawn but not in the spec (or in the spec but never drawn), any box Chrome measured that differs
from the spec, any geometry rule the spec breaks, and any ledger row with neither a spec key nor a
written reason for dropping it. It exits 1 when anything was printed as a miss.
"""
import glob, json, os, re, struct, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from build import css_vars, variant_of  # noqa: E402

STRUCTURAL = {"0", "100%", "-1"}  # inset 0, fill the screen box, buttons behind the body
spec = json.load(open(os.path.join(HERE, "spec.json")))
misses = []


def miss(text):
    misses.append(text)
    print("MISS", text)


def at(path):
    node = spec
    for part in path.split("/"):
        node = node[int(part)] if isinstance(node, list) else node[part]
    return node


# 1. no number lives in the stylesheet
css = re.sub(r"/\*.*?\*/", "", open(os.path.join(HERE, "paste_style.css")).read(), flags=re.S)
drawn = set(re.findall(r"var\((--[a-z-]+)\)", css))
loose = [n for n in re.findall(r"(?<![\w#-])-?\d*\.?\d+%?[a-z]*", re.sub(r"var\(--[a-z-]+\)", "", css)) if n not in STRUCTURAL]
for n in loose:
    miss("stylesheet holds %s, which spec.json lacks" % n)

# 2. every built page draws from the spec and nothing else, at the size the spec says
pages = sorted(glob.glob(os.path.join(HERE, "pages", "*.html")))
boxes_checked = 0
for path in pages:
    stem = os.path.basename(path)[:-5]
    variant, locale, key = stem.split("-", 1)[0], stem.split("-", 1)[1].rsplit("-", 1)[0], stem.rsplit("-", 1)[1]
    frame = next(f for f in spec["frames"] if f["key"] == key)
    v, want = variant_of(spec, variant), css_vars(spec, variant, frame)
    text = open(path).read()
    got = dict(d.split(":", 1) for d in re.search(r":root\{(.*?)\}</style>", text, re.S).group(1).split(";"))
    if got != want:
        miss("%s: its custom properties differ from spec.json; rebuild" % stem)
    if "style=" in text:
        miss("%s: an inline style holds values outside spec.json" % stem)
    for name in sorted(drawn - set(want)):
        if name.split("-")[2] in v or name.split("-")[2] in spec["base"]:
            miss("%s: the stylesheet draws %s, which spec.json lacks" % (stem, name))
    for name in sorted(set(want) - drawn):
        if not name.endswith("-floor"):  # a floor is read by fit.js from the page, not by the stylesheet
            miss("%s: spec.json holds %s, which nothing draws" % (stem, name))
    png = os.path.join(HERE, "out", stem + ".png")
    c = spec["base"]["canvas"]
    if not os.path.exists(png):
        miss("%s: not rendered" % stem)
        continue
    if struct.unpack(">II", open(png, "rb").read(24)[16:24]) != (c["w"], c["h"]):
        miss("%s: the PNG is not %sx%s" % (stem, c["w"], c["h"]))
    m = json.load(open(png[:-4] + ".json"))
    ph, sc = {**spec["base"]["phone"], **v["phone"]}, spec["base"]["screen"]
    expect = {"device": (ph["x"], ph["y"], ph["w"], ph["h"]),
              "screen": (ph["x"] + sc["inset"], ph["y"] + sc["inset"], sc["w"], sc["h"]),
              "copy": tuple(v["wrap"][k] for k in "xywh")}
    for b in m["boxes"]:
        if (b["x"], b["y"], b["w"], b["h"]) != expect[b["name"]]:
            miss("%s: %s measures %s, spec.json says %s" % (stem, b["name"], (b["x"], b["y"], b["w"], b["h"]), expect[b["name"]]))
        boxes_checked += 1
    for t in m["copy"]:
        part = t["name"].split(".")[-1]
        size, floor = ({**spec["base"].get(part, {}), **v.get(part, {})}[k] for k in ("size", "floor"))
        if locale == "en-US" and t["px"] != size:
            miss("%s: %s is drawn at %s px, spec.json says %s" % (stem, t["name"], t["px"], size))
        if t["px"] < floor:
            miss("%s: %s fell under its floor" % (stem, t["name"]))
    if m["fitFailures"]:
        miss("%s: copy does not fit: %s" % (stem, m["fitFailures"]))

# 3. the geometry the drawing rests on
cap, b = spec["capture"], spec["base"]
ph, bz, sc, cv = b["phone"], b["bezel"], b["screen"], b["canvas"]
num, den = (int(n) for n in cap["scale"].split("/"))
rules = [
    ("the screen is the whole capture, undistorted", sc["w"] * den == cap["w"] * num and sc["h"] * den == cap["h"] * num),
    ("the screen corner is the capture's corner at scale", sc["radius"] == round(cap["corner_radius"] * num / den)),
    ("phone = screen + bezel on every side", ph["w"] == sc["w"] + 2 * sc["inset"] and ph["h"] == sc["h"] + 2 * sc["inset"]),
    ("the corners are concentric", ph["radius"] == sc["radius"] + sc["inset"] and bz["radius"] == sc["radius"] + sc["inset"] - bz["inset"]),
    ("the phone is centred", ph["x"] * 2 + ph["w"] == cv["w"]),
    ("the headline reads at store-card width", b["headline"]["size"] * spec["card"]["w"] / cv["w"] >= spec["card"]["headline_min"]),
    ("a shrunk headline still reads at store-card width", b["headline"]["floor"] * spec["card"]["w"] / cv["w"] >= spec["card"]["floor_min"]),
]
for name in spec["variants"]:
    v = variant_of(spec, name)
    rules.append(("%s: the whole phone is on the canvas" % name, v["phone"]["y"] > 0 and v["phone"]["y"] + ph["h"] < cv["h"]))
    rules.append(("%s: the copy ends above the phone" % name, v["wrap"]["y"] + v["wrap"]["h"] <= v["phone"]["y"]))
    if "tap" in v:
        for f in spec["frames"]:
            k, t, d = f["key_box"], f["tap"], v["tap"]["d"]
            rules.append(("%s %s: the tap mark sits inside the tapped key" % (name, f["key"]),
                          k["x"] <= t["x"] and t["x"] + d <= k["x"] + k["w"] and k["y"] <= t["y"] and t["y"] + d <= k["y"] + k["h"]))
for name, ok in rules:
    if not ok:
        miss("rule broken: " + name)

# 4. the source ledger: every row is honoured by a spec key or dropped with a reason
mapped = dropped = 0
for row in spec["ledger"]:
    if row.get("dropped"):
        dropped += 1
    elif row.get("spec"):
        try:
            for path in row["spec"]:
                at(path)
            mapped += 1
        except (KeyError, IndexError, ValueError):
            miss("ledger: '%s' names a spec key that is not there: %s" % (row["item"], row["spec"]))
    else:
        miss("ledger: '%s' is unmapped" % row["item"])

print("stylesheet numbers outside spec.json: %d" % len(loose))
print("pages checked: %d, measured boxes checked: %d, rules checked: %d" % (len(pages), boxes_checked, len(rules)))
print("ledger rows: %d, mapped: %d, dropped: %d, unmapped: %d" % (len(spec["ledger"]), mapped, dropped, len(spec["ledger"]) - mapped - dropped))
print("misses: %d" % len(misses))
sys.exit(1 if misses else 0)
