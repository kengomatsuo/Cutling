#!/usr/bin/env python3
"""Builds the three complete store sets (ASG148): python3 build_sets.py <step> [...]
   screens          the clean screen every frame shows (captures with their patches), into assets/screens
   poster           direction 2, frames 4 to 8, both devices
   night [n ...]    direction 3, frames 4 to 8, both devices (GPU=1: it has tilted devices)
   night_pad_hero   direction 3, the iPad's frames 1 to 3 as one picture (GPU=1)
   keys             direction 1, headlines over the still lifes d1/gen.py rendered
   cut              frames 1 to 3 of all six sets, from each one's strip in out/
   sheets           a contact sheet per direction, into out/ and ~/Downloads
Wireframe screens (assets/wire/*.html) are rendered by the commands in README.md before `screens`."""
import json, os, subprocess, sys, urllib.parse
HERE = os.path.dirname(os.path.abspath(__file__))

def render(page, out, w, h, query="", cwd=HERE, limit=180, tall=0):
    """tall: extra window height. Chrome paints a tilted device only where its flat box lies inside the window, so
    pages with one get a taller window; the picture saved is still the page's own height."""
    url = page + ("?" + query if query else "")
    r = subprocess.run(["bun", os.path.expanduser("~/.claude/scripts/limit.ts"), str(limit), "bun", os.path.join(HERE, "render.mjs"), url, out, str(w), str(h + tall), "page", "1"],
                       cwd=cwd, capture_output=True, text=True, env=os.environ if os.environ.get("GPU") else dict(os.environ, CPU="1"))   # pages draw on the CPU so a path trace can hold the GPU; GPU=1 for pages with two 3D devices, which the CPU leaves half painted
    if not os.path.exists(out): raise SystemExit(f"render failed: {page}\n{r.stdout}\n{r.stderr}")
    if tall: subprocess.run(["magick", out, "-crop", f"{w}x{h}+0+0", "+repage", out], check=True)
    print(os.path.relpath(out, HERE))

PHONE_CLOCK = lambda fill: {"x": 188, "y": 62, "w": 168, "h": 70, "fill": fill, "text": "9:41", "size": 59}
PAD_CLOCK = lambda fill, x=40: {"x": x - 14, "y": 10, "w": 96, "h": 44, "fill": fill, "text": "9:41", "size": 27, "weight": 500, "align": "right"}
SCREENS = {
  "phone/chat": dict(src="raw/phone-chat.png", w=1320, h=2868, patches=[PHONE_CLOCK("#FDFDFD"),
      {"x": 48, "y": 1302, "w": 520, "h": 108, "fill": "#E9E9EB", "radius": 54, "text": "What’s your address?", "size": 51, "weight": 400, "track": -.6}]),
  "phone/grid": dict(src="raw/phone-grid.png", w=1320, h=2868, patches=[PHONE_CLOCK("#F9F9FC")]),
  "phone/new": dict(src="raw/phone-new.png", w=1320, h=2868, patches=[PHONE_CLOCK("#C1C1C4")]),
  "phone/suggest": dict(src="raw/phone-suggest.png", w=1320, h=2868, patches=[PHONE_CLOCK("#FDFDFD"),
      {"x": 896, "y": 60, "w": 300, "h": 72, "from": "raw/phone-chat.png"},          # the charging battery
      {"x": 500, "y": 1392, "w": 320, "h": 128, "fill": "#FDFDFD"}]),                  # the test page's localhost pill
  "pad/chat": dict(src="raw/pad-chat.png", w=2064, h=2752, patches=[PAD_CLOCK("#E5E9ED")]),
  "pad/grid": dict(src="raw/pad-grid.png", w=2064, h=2752, patches=[PAD_CLOCK("#F2F2F6")]),
  "pad/edit": dict(src="raw/pad-edit.png", w=2064, h=2752, patches=[PAD_CLOCK("#F2F2F7", 24),
      {"x": 1744, "y": 0, "w": 320, "h": 60, "from": "raw/pad-grid.png"}]),            # the charging battery
}
def screens():
    for name, spec in SCREENS.items():
        out = os.path.join(HERE, "assets/screens", name + ".png")
        os.makedirs(os.path.dirname(out), exist_ok=True)
        render("screen.html", out, spec["w"], spec["h"], "spec=" + urllib.parse.quote(json.dumps(spec)), cwd=os.path.join(HERE, "assets"))


KEYS = {"home": ("house", "Home Address", "123 Main Street, Apt 4B…"), "sig": ("envelope", "Email Signature", "Best regards,…"),
        "email": ("at", "Work Email", "alex@example.com"), "wifi": ("wifi", "Wi-Fi Password", "c0ff33-Sh0p-2024!"),
        "booking": ("airplane", "Booking Ref", "FLT-2026-XKCD42"), "meeting": ("video", "Meeting Link", "https://meet.example…"),
        "door": ("doc", "Office door", "Code 4815, then push twice")}
def K(name, **o): ic, t, p = KEYS[name]; return dict(type="key", icon=ic, title=t, preview=p, **o)
FILL = "Hi <u>Name</u>, your order ships Tue,&nbsp;Nov&nbsp;24. <s>Thanks!</s>"
def out_path(direction, device, n):
    d = os.path.join(HERE, "sets", direction, device); os.makedirs(d, exist_ok=True); return os.path.join(d, "%02d.png" % n)

# Direction 2, frames 4 to 8. Frames 1 to 3 are cut from the strips (d2/strip.html, d2/strip-pad.html).
POSTER = {
  "iphone": dict(W=1320, H=2868, margin=92, top=150, h1size=520, gap=64, subsize=118, frames={
    4: dict(h1=["Keep", "it all."], sub="All you retype, in one place.", items=[dict(type="phone", screen="phone/grid", w=1000, left=160, top=1250), K("booking", w=1040, left=420, top=2380, rot=-5)]),
    5: dict(h1=["Type it", "once."], sub="Save it now. Tap it forever.", items=[dict(type="phone", screen="phone/new", w=1000, left=160, top=1250), K("door", w=1060, left=50, top=2340, rot=4)]),
    6: dict(h1=["Leave a", "blank."], sub="Fill it in as you paste.", items=[dict(type="phone", screen="phone/fillin", w=1000, left=160, top=1250), dict(type="card", html=FILL, w=1150, left=110, top=1660, rot=-3)]),
    7: dict(h1=["It reads", "the field."], sub="Email field? Email key first.", items=[dict(type="phone", screen="phone/suggest", w=1000, left=160, top=1250), K("email", w=1100, left=150, top=1900, rot=-4), dict(type="tag", text="Suggested here", w=560, left=640, top=1790, rot=-4)]),
    8: dict(bg="ink", h1=["Every", "device."], sub="iPhone, iPad and Mac, in sync.", fine="No account. No ads. No tracking.", items=[dict(type="pad", screen="pad/grid", w=1060, left=420, top=1420, rot=4), dict(type="phone", screen="phone/grid", w=560, left=70, top=1760, rot=-5), dict(type="mac", w=560, left=560, top=2250, rot=2, cut=560), dict(type="tag", text="⌘⇧V on Mac", w=420, left=640, top=2140, rot=2)]),
  }),
  "ipad": dict(W=2064, H=2752, margin=120, top=140, h1size=420, gap=50, subsize=124, frames={
    4: dict(h1=["Keep it all."], sub="All you retype, in one place.", items=[dict(type="pad", screen="pad/grid", w=1640, left=212, top=800), K("booking", w=1400, left=820, top=2240, rot=-4)]),
    5: dict(h1=["Type it once."], sub="Save it now. Tap it forever.", items=[dict(type="pad", screen="pad/edit", w=1640, left=212, top=800), K("home", w=1380, left=70, top=2240, rot=4)]),
    6: dict(h1=["Leave a blank."], sub="Fill it in as you paste.", items=[dict(type="pad", screen="pad/fillin", w=1640, left=212, top=800), dict(type="card", html=FILL, w=1500, left=420, top=1220, rot=-3)]),
    7: dict(h1=["It reads the field."], sub="Email field? Email key first.", items=[dict(type="pad", screen="pad/suggest", w=1640, left=212, top=800), K("email", w=1400, left=330, top=1500, rot=-4), dict(type="tag", text="Suggested here", w=700, left=1000, top=1370, rot=-4)]),
    8: dict(bg="ink", h1=["Every device."], sub="iPhone, iPad and Mac, in sync.", fine="No account. No ads. No tracking.", items=[dict(type="pad", screen="pad/grid", w=1300, left=690, top=960, rot=4), dict(type="phone", screen="phone/grid", w=640, left=150, top=1330, rot=-5), dict(type="mac", w=680, left=560, top=2130, rot=2, cut=560), dict(type="tag", text="⌘⇧V on Mac", w=500, left=660, top=2010, rot=2)]),
  }),
}
def poster():
    for device, D in POSTER.items():
        for n, f in D["frames"].items():
            spec = {k: D[k] for k in ("W", "H", "margin", "top", "h1size", "gap", "subsize")}; spec.update(f)
            render("frame.html", out_path("poster", device, n), D["W"], D["H"], "spec=" + urllib.parse.quote(json.dumps(spec)), cwd=os.path.join(HERE, "d2"))


# Direction 3. Lifted pieces are boxes of the screen in its own pixels: x, y, w, h, how high (z), corner (r), glow (c).
BLUE, PINK, CYAN, GREEN, ORANGE, RED, VIOLET = "#0088FF", "#CB30E0", "#00B8E6", "#00C08A", "#FF8D28", "#FF2D55", "#6155F5"
def L(id, x, y, w, h, z, c, r=44, k=1.08): return dict(id=id, x=x, y=y, w=w, h=h, z=z, c=c, r=r, k=k)
GLOW = lambda x, y: [[x, y, 1500, 1100, "rgba(46,230,167,.34)"], [x + 700, y - 500, 1100, 900, "rgba(60,120,255,.18)"], [x + 300, y + 700, 900, 800, "rgba(203,48,224,.14)"]]
PH = dict(kind="phone", rx=44, scale=.67)
NIGHT = {
  "iphone": dict(W=1320, H=2868, h1size=196, origin="660px 500px", hx=96, frames={
    4: dict(h="Everything<br>you retype,<br><em>one place.</em>", glows=GLOW(700, 2000),
            devices=[dict(PH, screen="phone/grid", left=30, top=600, rz=-16, grid=1, lifts=[L("a", 43, 322, 604, 412, 460, BLUE, 80), L("b", 673, 778, 604, 412, 330, ORANGE, 80), L("c", 43, 1234, 604, 412, 220, RED, 80), L("d", 673, 1690, 604, 412, 130, RED, 80)])]),
    5: dict(h="Type it<br><em>one last</em><br>time.", glows=GLOW(620, 2000),
            devices=[dict(PH, screen="phone/new", left=-150, top=600, rz=14, grid=1, lifts=[L("name", 60, 530, 1200, 154, 300, GREEN, 77, 1.04), L("txt", 60, 1410, 1200, 190, 200, GREEN, 60, 1.04), L("chk", 1126, 246, 136, 136, 300, GREEN, 68, 1.0)])],
            cards=[dict(id="k", type="key", icon="doc", title="Office door", preview="Code 4815, then push twice", w=900, left=330, top=2420, rot=-4, c=GREEN, label="Your new key")],
            links=[dict(a="chk:mC", b="k:T", c="#37E0A8", bend=[420, 300, 120, -420])]),
    6: dict(h="Leave<br><em>a blank</em><br>to fill in.", glows=GLOW(700, 2000),
            devices=[dict(PH, screen="phone/fillin", left=30, top=600, rz=-16, grid=1, lifts=[L("strip", 150, 1770, 1150, 180, 440, GREEN, 40, 1.05), L("maya", 669, 1966, 633, 192, 240, GREEN, 44)])],
            cards=[dict(id="b", type="bubble", html="Hi Maya, your order ships Tue, Nov 24. Thanks!", w=800, left=300, top=1500, rot=-3, c="#0A84FF", label="What gets pasted")],
            links=[dict(a="maya:mT", b="b:B", c="#37E0A8", bend=[40, -200, 60, 240])]),
    7: dict(h="The right<br>key shows<br><em>up first.</em>", glows=GLOW(620, 2000),
            devices=[dict(PH, screen="phone/suggest", left=10, top=600, rz=14, grid=1, lifts=[L("to", 0, 350, 1320, 160, 200, CYAN, 30, 1.0), L("we", 20, 2020, 630, 186, 440, CYAN, 44)])],
            links=[dict(a="we:mT", b="to:mC", c="#37D2F5", bend=[-120, -500, 320, 460])]),
    8: dict(h="On iPhone,<br>iPad and<br><em>your Mac.</em>", glows=GLOW(700, 2000), fines=[dict(text="No account. No ads. No tracking.", left=100, top=830)],
            devices=[dict(kind="pad", screen="pad/grid", rx=44, rz=-14, zoom=.44, left=330, top=1130, grid=1, lifts=[L("p", 36, 350, 374, 274, 320, BLUE, 56, 1.2)]),
                     dict(kind="phone", screen="phone/grid", rx=44, rz=-14, zoom=.42, left=60, top=1640, under="rgba(60,120,255,.4)", lifts=[L("q", 43, 322, 604, 412, 320, BLUE, 80)])],
            cards=[dict(id="m", type="mac", w=600, cut=560, left=650, top=2420, rot=3, c=BLUE, label="⌘⇧V on Mac")],
            links=[dict(a="q:mT", b="p:mB", c="#2F9BFF", bend=[60, -260, -40, 260]), dict(a="p:mR", b="m:T", c="#2F9BFF", bend=[520, 200, 80, -520])]),
  }),
}
PD = dict(kind="pad", rx=44, zoom=.64)
NIGHT["ipad"] = dict(W=2064, H=2752, h1size=250, origin="1032px 500px", hx=120, cz=1.5, frames={
    4: dict(h="Everything<br>you retype,<br><em>one place.</em>", glows=GLOW(1100, 2000),
            devices=[dict(PD, screen="pad/grid", left=400, top=1000, rz=-14, grid=1, lifts=[L("a", 36, 350, 374, 274, 460, BLUE, 56), L("b", 1250, 350, 374, 274, 330, ORANGE, 56), L("c", 440, 652, 374, 274, 240, VIOLET, 56), L("d", 845, 652, 374, 274, 150, RED, 56)])]),
    5: dict(h="Type it<br><em>one last</em><br>time.", glows=GLOW(1000, 2000),
            devices=[dict(PD, screen="pad/edit", left=260, top=1000, rz=12, grid=1, lifts=[L("name", 40, 256, 1984, 104, 300, GREEN, 40, 1.03), L("txt", 40, 860, 1984, 220, 200, GREEN, 50, 1.03)])],
            cards=[dict(id="k", type="key", icon="house", title="Home Address", preview="123 Main Street, Apt 4B…", w=900, left=600, top=2330, rot=-4, c=BLUE, label="Your new key")],
            links=[dict(a="txt:mB", b="k:T", c="#37E0A8", bend=[120, 260, 60, -300])]),
    6: dict(h="Leave<br><em>a blank</em><br>to fill in.", glows=GLOW(1100, 2000),
            devices=[dict(PD, screen="pad/fillin", left=400, top=1000, rz=-14, grid=1, lifts=[L("strip", 126, 1876, 1040, 124, 440, GREEN, 30, 1.06), L("maya", 422, 2099, 395, 160, 240, GREEN, 26)])],
            cards=[dict(id="b", type="bubble", html="Hi Maya, your order ships Tue, Nov 24. Thanks!", w=780, left=820, top=1230, rot=-3, c="#0A84FF", label="What gets pasted")],
            links=[dict(a="maya:mT", b="b:B", c="#37E0A8", bend=[40, -260, 40, 300])]),
    7: dict(h="The right<br>key shows<br><em>up first.</em>", glows=GLOW(1000, 2000),
            devices=[dict(PD, screen="pad/suggest", left=420, top=1000, rz=12, grid=1, lifts=[L("to", 0, 190, 2064, 112, 200, CYAN, 20, 1.0), L("we", 11, 2108, 395, 160, 440, CYAN, 26)])],
            links=[dict(a="we:mT", b="to:mC", c="#37D2F5", bend=[-160, -620, 420, 560])]),
    8: dict(h="On iPhone,<br>iPad and<br><em>your Mac.</em>", glows=GLOW(1100, 2000), fines=[dict(text="No account. No ads. No tracking.", left=128, top=1010, size=96)],
            devices=[dict(kind="pad", screen="pad/grid", rx=44, rz=-14, zoom=.62, left=620, top=1060, grid=1, lifts=[L("p", 36, 350, 374, 274, 320, BLUE, 56, 1.2)]),
                     dict(kind="phone", screen="phone/grid", rx=44, rz=-14, zoom=.56, left=150, top=1640, under="rgba(60,120,255,.4)", lifts=[L("q", 43, 322, 604, 412, 320, BLUE, 80)])],
            cards=[dict(id="m", type="mac", w=600, cut=560, left=1060, top=2230, rot=3, c=BLUE, label="⌘⇧V on Mac")],
            links=[dict(a="q:mT", b="p:mB", c="#2F9BFF", bend=[80, -300, -60, 300]), dict(a="p:mR", b="m:T", c="#2F9BFF", bend=[620, 240, 100, -620])]),
})
# iPad frames 1 to 3: one picture 6192 wide, the iPad lying over the first seam, each key's text landing in frame 3
NIGHT_PAD_HERO = dict(W=6192, H=2752, h1size=250, origin="2700px 300px", cz=1.35,
    glows=[[2700, 2000, 2300, 1300, "rgba(46,230,167,.34)"], [5500, 1700, 1700, 1200, "rgba(60,120,255,.20)"], [5200, 2650, 1300, 900, "rgba(203,48,224,.16)"]],
    heads=[dict(left=120, html="Asked for<br>your address<br><em>again?</em>"), dict(left=2184, html="It’s <em>one tap</em><br>on your<br>keyboard."), dict(left=4248, html="Pasted into<br><em>any app</em><br>you use.")],
    devices=[dict(kind="pad", screen="pad/chat", rx=52, rz=-33, zoom=.68, left=1620, top=740, grid=1,
                  lifts=[L("ins", 11, 2099, 396, 158, 330, BLUE, 26, 1.1), L("sig", 422, 2099, 396, 158, 520, PINK, 26, 1.1), L("tel", 11, 2277, 396, 158, 200, CYAN, 26, 1.1)])],
    cards=[dict(id="cA", type="field", html='123 Main Street, Apt 4B<br>New York, NY 10001<span class="caret"></span>', left=4420, top=1160, rot=-3, c=BLUE, label="A message"),
           dict(id="cB", type="text", html='Best regards,<br>Alex Chen<br>alex@example.com<span class="caret"></span>', left=4560, top=1700, rot=2.5, c=PINK, label="An email"),
           dict(id="cC", type="text", html='<s>Phone</s> +1 (555) 234-5678<span class="caret"></span>', left=4440, top=2440, rot=-2, c=CYAN, label="A sign-up form")],
    links=[dict(a="ins:mT", b="cA:L", c="#2F9BFF", bend=[300, -900, -900, 60]), dict(a="sig:mR", b="cB:L", c="#E05CF5", bend=[700, -80, -700, 40]), dict(a="tel:mB", b="cC:L", c="#37D2F5", bend=[500, 420, -700, 300])])
def night_pad_hero():
    out = os.path.join(HERE, "out", "night-pad-strip.png")
    render("frame.html", out, 6192, 2752, "spec=" + urllib.parse.quote(json.dumps(NIGHT_PAD_HERO)), cwd=os.path.join(HERE, "d3"), tall=1800)

def night(only=None):
    for device, D in NIGHT.items():
        for n, f in D["frames"].items():
            if only and str(n) not in only: continue
            spec = dict(W=D["W"], H=D["H"], h1size=D["h1size"], origin=D["origin"], heads=[dict(left=D["hx"], html=f["h"])], **{k: v for k, v in f.items() if k != "h"})
            if "cz" in D: spec["cz"] = D["cz"]
            render("frame.html", out_path("night", device, n), D["W"], D["H"], "spec=" + urllib.parse.quote(json.dumps(spec)), cwd=os.path.join(HERE, "d3"), tall=1800)


# Direction 1: headlines over the still lifes d1/gen.py renders. Frames 1 to 3 are cut from one picture per device.
KEYS_HEADS = {4: "All your keys<br><em>in one place</em>", 5: "Make a key<br><em>in seconds</em>", 6: "Keys with<br><em>blanks to fill</em>",
              7: "The right key<br><em>comes first</em>", 8: "iPhone, iPad<br><em>and Mac</em>"}
KEYS_HERO = ["<em>One key</em> types<br>your address", "Tap it in<br><em>any app</em>", "<em>Keys</em> for all<br>you retype"]
def keys():
    cwd = os.path.join(HERE, "d1")
    for device, pre, W, H, top, size, left in (("iphone", "ph", 1320, 2868, 132, 178, 92), ("ipad", "pd", 2064, 2752, 150, 236, 120)):
        for n, h in KEYS_HEADS.items():
            spec = dict(W=W, H=H, bg=f"{pre}{n}", top=top, size=size, heads=[dict(left=left, html=h)])
            if n == 8: spec["fine"] = dict(text="No account. No ads. No tracking.", left=left + 4, top=top + size * 2.08 + 44, size=size * .4)
            render("compose-set.html", out_path("keys", device, n), W, H, "spec=" + urllib.parse.quote(json.dumps(spec)), cwd=cwd)
    spec = dict(W=6192, H=2752, bg="padhero", top=150, size=236, heads=[dict(left=120 + i * 2064, html=h) for i, h in enumerate(KEYS_HERO)])
    render("compose-set.html", os.path.join(HERE, "out", "keys-pad-strip.png"), 6192, 2752, "spec=" + urllib.parse.quote(json.dumps(spec)), cwd=cwd)

def cut():
    """Frames 1 to 3 of every set, cut from each direction's one picture."""
    strips = {("keys", "iphone"): "direction-1-strip", ("poster", "iphone"): "direction-2-strip", ("night", "iphone"): "direction-3-strip",
              ("keys", "ipad"): "keys-pad-strip", ("poster", "ipad"): "poster-pad-strip", ("night", "ipad"): "night-pad-strip"}
    for (direction, device), strip in strips.items():
        w, h = (1320, 2868) if device == "iphone" else (2064, 2752)
        for i in range(3):
            subprocess.run(["magick", os.path.join(HERE, "out", strip + ".png"), "-crop", f"{w}x{h}+{i * w}+0", "+repage", out_path(direction, device, i + 1)], check=True)

def sheets():
    """One contact sheet per direction: the iPhone set over the iPad set, as the store lays frames out."""
    for direction, title in (("keys", "Direction 1 · Keys"), ("poster", "Direction 2 · Don’t type it"), ("night", "Direction 3 · Night flight")):
        out = os.path.join(HERE, "out", f"set-{direction}.png")
        render("sheet-set.html", out, 3400, 900, "spec=" + urllib.parse.quote(json.dumps(dict(direction=direction, title=title, n=8))), cwd=HERE)
        subprocess.run(["cp", out, os.path.expanduser(f"~/Downloads/cutling-set-{direction}.png")], check=True)

STEPS = {"screens": screens, "poster": poster, "night": night, "night_pad_hero": night_pad_hero, "keys": keys, "cut": cut, "sheets": sheets}



if __name__ == "__main__":
    a = sys.argv[1:] or ["screens"]
    if a[0] == "night" and len(a) > 1: night(a[1:])
    else:
        for step in a: STEPS[step]()
