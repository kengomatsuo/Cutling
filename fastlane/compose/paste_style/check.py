#!/usr/bin/env python3
"""Checks the Paste-style frames against spec.json and prints every miss.

    python3 fastlane/compose/paste_style/check.py        # after build.py

It prints any number the stylesheet or build.py holds that spec.json lacks, any custom property drawn
but not in the spec (or in the spec but never drawn), any page that differs from what the spec builds,
any box Chrome measured that differs from the spec, any geometry rule the spec breaks (whole capture,
concentric corners, every seam crossed, whole phones in the recommended design, patches inside their
capture) and any ledger row with neither a spec key nor a written reason for dropping it.
It exits 1 when anything was printed as a miss.
"""
import glob, io, json, os, re, struct, sys, tokenize

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import build  # noqa: E402

STRUCTURAL = {"0", "100%", "100vw", "100vh", "-1"}  # fill the page, inset 0, buttons and tails behind their body
CODE = {"0", "1"}  # exit codes and Chrome's device scale
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


def near(a, b):
    return all(abs(x - y) < 0.01 for x, y in zip(a, b))


# 1. no number lives in the stylesheet or in the drawing code
css = re.sub(r"/\*.*?\*/", "", open(os.path.join(HERE, "paste_style.css")).read(), flags=re.S)
drawn = set(re.findall(r"var\((--[a-z-]+)\)", css))
loose = [n for n in re.findall(r"(?<![\w#-])-?\d*\.?\d+%?[a-z]*", re.sub(r"var\(--[a-z-]+\)", "", css)) if n not in STRUCTURAL]
for n in loose:
    miss("stylesheet holds %s, which spec.json lacks" % n)
code = [t.string for t in tokenize.generate_tokens(io.StringIO(open(os.path.join(HERE, "build.py")).read()).readline)
        if t.type == tokenize.NUMBER and t.string not in CODE]
for n in code:
    miss("build.py holds %s, which spec.json lacks" % n)

# 2. every custom property is in the spec and is drawn
shared = build.root_vars(spec, 0)
each = {"--x", "--y", "--w", "--h", "--k", "--r", "--i", "--bx", "--by", "--fill"}  # set per element by build.py
for name in sorted(drawn - set(shared) - each):
    miss("the stylesheet draws %s, which spec.json lacks" % name)
for name in sorted(set(shared) - drawn):
    if not name.endswith("-floor"):  # a floor is read by fit.js from the page, not by the stylesheet
        miss("spec.json holds %s, which nothing draws" % name)

# 3. every built page is what the spec builds, at the sizes the spec says
cv, wrap, ph = spec["base"]["canvas"], spec["base"]["wrap"], spec["base"]["phone"]
keys = [f["key"] for f in spec["frames"]]
pages = sorted(glob.glob(os.path.join(HERE, "pages", "*.html")))
boxes_checked = 0
for path in pages:
    stem = os.path.splitext(os.path.basename(path))[0]
    design, rest = stem.split("-", 1)
    locale, key = rest.rsplit("-", 1)
    shift, d = keys.index(key), spec["designs"][design]
    if locale == "en-US" and open(path).read() != build.page(spec, design, shift, build.copy_for(spec, locale, None), locale, build.is_rtl(locale)):
        miss("%s: the page differs from what spec.json builds; rebuild" % stem)
    png = os.path.join(HERE, "out", stem + ".png")
    if not os.path.exists(png):
        miss("%s: not rendered" % stem)
        continue
    if struct.unpack(">II", open(png, "rb").read(24)[16:24]) != (cv["w"], cv["h"]):
        miss("%s: the PNG is not %sx%s" % (stem, cv["w"], cv["h"]))
    m = json.load(open(os.path.splitext(png)[0] + ".json"))
    left = -cv["w"] * shift
    expect = {"copy": [(left + cv["w"] * i + wrap["x"], wrap["y"], wrap["w"], wrap["h"]) for i in range(len(keys))],
              "device": [(left + p["x"], p["y"], ph["w"] * float(p["k"]), ph["h"] * float(p["k"])) for p in d["phones"]]}
    for b in m["boxes"]:
        want = expect[b["name"]].pop(0)
        if not near((b["x"], b["y"], b["w"], b["h"]), want):
            miss("%s: %s measures %s, spec.json says %s" % (stem, b["name"], (b["x"], b["y"], b["w"], b["h"]), want))
        boxes_checked += 1
    for t in m["copy"]:
        part = t["name"].split(".")[-1]
        size, floor = spec["base"][part]["size"], spec["base"][part].get("floor", spec["base"][part]["size"])
        if locale == "en-US" and t["px"] != size:
            miss("%s: %s is drawn at %s px, spec.json says %s" % (stem, t["name"], t["px"], size))
        if t["px"] < floor:
            miss("%s: %s fell under its floor" % (stem, t["name"]))
    if m["fitFailures"]:
        miss("%s: copy does not fit: %s" % (stem, m["fitFailures"]))
for strip in sorted(glob.glob(os.path.join(HERE, "out", "*-strip.png"))):
    if struct.unpack(">II", open(strip, "rb").read(24)[16:24]) != (cv["w"] * len(keys), cv["h"]):
        miss("%s: the strip is not %sx%s" % (os.path.basename(strip), cv["w"] * len(keys), cv["h"]))

# 4. the geometry the drawing rests on
cap, b = spec["capture"], spec["base"]
bz, sc = b["bezel"], b["screen"]
num, den = (int(n) for n in re.findall(r"\d+", sc["scale"]))
inside = lambda box, w, h: box["x"] >= 0 and box["y"] >= 0 and box["x"] + box["w"] <= w and box["y"] + box["h"] <= h
source = lambda p: p["sx"] >= 0 and p["sy"] >= 0 and p["sx"] + p["w"] <= cap["w"] and p["sy"] + p["h"] <= cap["h"]
rules = [
    ("the screen is the whole capture, undistorted", sc["w"] * den == cap["w"] * num and sc["h"] * den == cap["h"] * num),
    ("the screen corner is the capture's corner at scale", sc["radius"] == round(cap["corner_radius"] * num / den)),
    ("phone = screen + bezel on every side", ph["w"] == sc["w"] + sc["inset"] + sc["inset"] and ph["h"] == sc["h"] + sc["inset"] + sc["inset"]),
    ("the corners are concentric", ph["radius"] == sc["radius"] + sc["inset"] and bz["radius"] == sc["radius"] + sc["inset"] - bz["inset"]),
    ("the copy column is the phone's width", wrap["w"] == ph["w"]),
    ("the headline reads at store-card width", b["headline"]["size"] * spec["card"]["w"] / cv["w"] >= spec["card"]["headline_min"]),
    ("a shrunk headline still reads at store-card width", b["headline"]["floor"] * spec["card"]["w"] / cv["w"] >= spec["card"]["floor_min"]),
]
for f in spec["frames"]:
    if "tap" in f:
        k, t, dia = f["key_box"], f["tap"], b["tap"]["d"]
        rules.append(("%s: the tap mark sits inside the tapped key" % f["key"], inside({"x": t["x"] - k["x"], "y": t["y"] - k["y"], "w": dia, "h": dia}, k["w"], k["h"])))
    if "bubble" in f:
        free, bub = f["free_box"], f["bubble"]
        tall = int(re.findall(r"\d+", b["bubble"]["leading"])[0]) + b["bubble"]["pad"]["y"] + b["bubble"]["pad"]["y"]
        rules.append(("%s: the drawn bubble stays in the capture's empty chat area" % f["key"], free["y"] <= bub["y"] and bub["y"] + tall <= free["y"] + free["h"]))
    for p in f.get("patches", []):
        rules.append(("%s: a patch lies inside the capture" % f["key"], inside(p, cap["w"], cap["h"]) and ("fill" in p or source(p))))
for name, d in spec["designs"].items():
    spans = [(p["x"], p["x"] + ph["w"] * float(p["k"])) for p in d["phones"]]
    for t in d["lifts"]:
        half, mid = t["w"] * float(t["k"]) / 2, t["x"] + t["w"] / 2  # a tile turns and scales about its centre
        spans.append((mid - half, mid + half))
        rules.append(("%s: a lifted tile is cut from inside its capture" % name, source(t) and all(source(p) for p in t.get("patches", []))))
        rules.append(("%s: a lifted tile stays on the strip" % name, mid - half >= 0 and mid + half <= cv["w"] * len(keys)))
    for i in range(1, len(keys)):
        seam = cv["w"] * i
        rules.append(("%s: something crosses the seam at x %s" % (name, seam), any(a < seam < z for a, z in spans)))
    for p in d["phones"]:
        rules.append(("%s: the copy ends above the phone in %s" % (name, p["frame"]), wrap["y"] + wrap["h"] <= p["y"]))
    if name == spec["recommended"]:
        for p in d["phones"]:
            lo = cv["w"] * keys.index(p["frame"])
            rules.append(("%s: the phone in %s is whole inside its own frame" % (name, p["frame"]),
                          lo <= p["x"] and p["x"] + ph["w"] * float(p["k"]) <= lo + cv["w"] and p["y"] + ph["h"] * float(p["k"]) <= cv["h"]))
for name, ok in rules:
    if not ok:
        miss("rule broken: " + name)

# 5. the source ledger: every row is honoured by a spec key or dropped with a reason
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

print("numbers outside spec.json: stylesheet %d, build.py %d" % (len(loose), len(code)))
print("pages checked: %d, measured boxes checked: %d, rules checked: %d" % (len(pages), boxes_checked, len(rules)))
print("ledger rows: %d, mapped: %d, dropped: %d, unmapped: %d" % (len(spec["ledger"]), mapped, dropped, len(spec["ledger"]) - mapped - dropped))
print("misses: %d" % len(misses))
sys.exit(1 if misses else 0)
