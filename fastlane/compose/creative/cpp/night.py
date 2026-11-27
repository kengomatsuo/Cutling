"""Direction "Night flight" (ASG148's d3: devices lying tilted in the dark, pieces of the screen lifted off with a mint
glow, trails of light carrying them to where they land) as one picture across every frame, for Quick replies (50
languages, its words about answering the same question again) and Clipboard history (English).

Each set is one page N frames wide (night/frame.html with the spec written in), saved frame by frame with the page
shifted. A trail or a card crosses every seam; devices stay inside their frame. Chrome paints a tilted device only where
its flat box lies inside the window, so each frame renders 1800 px taller and is cropped (as build_sets.py did).

Drawn screens (Messages with Cutling's keyboard, a page with copied text) are rendered first, per language, from the
app's own strings; real captures: 02_MainGrid per language, and on the English page the 2.0 grid and the Mac history."""
import json, re, subprocess
from pathlib import Path

import lib
from lib import esc, symbol

N = lib.HERE / "night"
CROPS = []   # run once the frames are rendered (build.py)
TALL = 1800

CSS_CARDS = """
.kc{position:absolute;inset:0;background:#fff;border-radius:calc(var(--w)*.0694)}
.kc .ic{position:absolute;inset-inline-start:calc(var(--w)*.05);top:calc(var(--w)*.052)}
.kc b{position:absolute;inset-inline-start:calc(var(--w)*.152);inset-inline-end:calc(var(--w)*.04);top:calc(var(--w)*.05);font:650 calc(var(--w)*.073)/1.1 var(--sf);letter-spacing:-.02em;white-space:nowrap;overflow:hidden;color:#000}
.kc i{position:absolute;inset-inline-start:calc(var(--w)*.052);inset-inline-end:calc(var(--w)*.05);top:calc(var(--w)*.165);font:400 calc(var(--w)*.0612)/1.2 var(--sf);font-style:normal;letter-spacing:-.01em;color:#8A8A8E;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.tok{background:#D6F5EA;color:#08664B;border-radius:.25em;padding:0 .2em;font-weight:600;white-space:nowrap;display:inline-flex;align-items:center;gap:.2em}
.card.raw{padding:0;overflow:hidden}
.val{background:#00A878;color:#fff;border-radius:.2em;padding:0 .14em;font-weight:650;white-space:nowrap}
"""

HEAD_FONT = {"ja": '"Hiragino Sans"', "zh-Hans": '"PingFang SC"', "zh-Hant": '"PingFang TC"', "ko": '"Apple SD Gothic Neo"',
             "th": '"Thonburi"', "hi": '"Kohinoor Devanagari"', "mr-IN": '"Kohinoor Devanagari"', "bn-BD": '"Kohinoor Bangla"',
             "gu-IN": '"Kohinoor Gujarati"', "te-IN": '"Kohinoor Telugu"', "ta-IN": '"Tamil Sangam MN"', "kn-IN": '"Kannada Sangam MN"',
             "ml-IN": '"Malayalam Sangam MN"', "pa-IN": '"Gurmukhi Sangam MN"', "or-IN": '"Oriya Sangam MN"', "ur-PK": '"Noto Nastaliq Urdu"',
             "ar-SA": '"SF Arabic"', "he": '"SF Hebrew"'}
HEAD_LH = {"th": 1.32, "ar-SA": 1.2, "ur-PK": 1.75, "he": 1.08, "ja": 1.12, "zh-Hans": 1.12, "zh-Hant": 1.12, "ko": 1.12,
           **{l: 1.3 for l in ("hi", "mr-IN", "bn-BD", "gu-IN", "pa-IN", "or-IN", "kn-IN", "te-IN", "ml-IN", "ta-IN")}}


def heading(s):
    """*x* is the mint phrase, | a line break; a phrase may run across a break, so each line closes and reopens it."""
    out, on = [], False
    for ln in esc(s).split("|"):
        parts = ln.split("*")
        h = ""
        for i, part in enumerate(parts):
            if i:
                on = not on
            h += f"<em>{part}</em>" if on and part else part
        out.append(h)
    return "<br>".join(out)


def keycard(icon, title, prev_html, w):
    s, col = lib.ICONS[icon]
    return f'<div class="kc"><span class="ic">{symbol(s, w*.08, col)}</span><b>{esc(title)}</b><i>{prev_html}</i></div>'


# ------------------------------------------------------------------ drawn screens

def screen_jobs(loc, dev, page, out_dir, own):
    """Drawn screens this set shows, rendered at the capture's pixels. Returns {name: png path}."""
    pad = dev == "ipad"
    W, H = (2064, 2752) if pad else (1320, 2868)
    rtl = loc in lib.RTL
    sd = lib.seed(loc)
    wv, _ = lib.words(loc)
    cs = wv["cseed"]
    out = {}
    def job(name, inner):
        p = out_dir / f"screen-{name}.html"
        sb = lib.m.sbar(W, "#FDFDFD", True, pad=pad)
        isl = "" if pad else (f'<div style="position:absolute;width:{W*.265}px;height:{W*.078}px;left:{(W-W*.265)/2}px;top:{W*.027}px;'
                              f'background:#000;border-radius:999px;z-index:9"></div>')
        p.write_text(lib.m.page(W, H, f'<div style="position:absolute;inset:0;overflow:hidden">{inner}{sb}{isl}</div>', "", loc))
        lib.m.JOBS.append({"html": str(p), "png": str(p.with_suffix(".png")), "w": W, "h": H})
        out[name] = p.with_suffix(".png")
    def capjob(name, key, kind):
        cw, chh = (2064, 2752) if kind == "pad" else (1320, 2868)
        p = out_dir / f"screen-{name}.html"
        sb = lib.m.sbar(cw, "#F2F2F7", True, pad=kind == "pad")
        p.write_text(lib.m.page(cw, chh, f'<img src="{lib.cap(loc, key)}" style="position:absolute;left:0;top:0;width:100%">{sb}', "", loc))
        lib.m.JOBS.append({"html": str(p), "png": str(p.with_suffix(".png")), "w": cw, "h": chh})
        out[name] = p.with_suffix(".png")
    capjob("grid", "phone-grid", "phone")
    capjob("padgrid", "pad-grid", "pad")
    if loc in lib.ENGLISH:
        capjob("grid2", "phone-grid2", "phone")
    if page == "qr":
        prev = lambda t: t.split("{name}")[0] + cs["name_label"] + "…"
        tiles = [("reply", cs["reply_name"], prev(cs["reply"])), ("date", cs["delivered_name"], cs["delivered"].split("{date}")[0] + "…"),
                 ("home", sd["home"][0], sd["home"][1].split("\n")[0]), ("bank", *sd["bank"]),
                 ("sig", sd["sig"][0], sd["sig"][1].split("\n")[0]), ("phone", *sd["phone"])]
        kb, kh = lib.cutling_keyboard(pad, tiles, header=lib.S(loc, "Add from Clipboard"), rtl=rtl)
        job("chat", lib.messages(pad, cs["names"][0], [(False, own["demo"]["ask"])], kb, kh, rtl=rtl))
    if page == "ch":
        job("copy", copy_page(pad))
        tiles = [("wifi", "Cabin Wi-Fi", "pinecone-2026"), ("home", sd["home"][0], sd["home"][1].split("\n")[0]),
                 ("bank", *sd["bank"]), ("sig", sd["sig"][0], sd["sig"][1].split("\n")[0]), ("phone", *sd["phone"]), ("booking", *sd["booking"])]
        kb, kh = lib.cutling_keyboard(pad, tiles, header=lib.S(loc, "Add from Clipboard"), rtl=rtl)
        job("kb", lib.messages(pad, "Sam", [(False, "What’s the Wi-Fi at the cabin?")], kb, kh, field="", rtl=rtl))
    return out


def copy_page(pad):
    """A page in Safari (a holiday cabin's check-in notes) with one line selected and the edit menu over it."""
    W, H = (2064, 2752) if pad else (1320, 2868)
    u = .9 if pad else 1.0
    fs = 50 * u
    sel = '<span style="background:rgba(10,132,255,.25);box-shadow:-6px 0 0 #0A84FF,6px 0 0 #0A84FF">Wi-Fi: pinecone-2026</span>'
    menu = (f'<div style="position:absolute;left:{70*u}px;top:{(670 if not pad else 480)}px;height:{110*u}px;border-radius:{30*u}px;background:#1c1c1e;'
            f'display:flex;align-items:center;color:#fff;font-size:{44*u}px;box-shadow:0 10px 40px rgba(0,0,0,.25)">'
            + "".join(f'<div style="padding:0 {34*u}px;{"border-left:2px solid #3a3a3c;" if i else ""}">{t}</div>' for i, t in enumerate(["Copy", "Look Up", "Translate", "Share…"]))
            + '</div>')
    txt = (f'<div style="position:absolute;left:{70*u}px;right:{70*u}px;top:{(380 if not pad else 300)}px;font-size:{fs}px;line-height:1.5;color:#1c1c1e">'
           f'<div style="font-size:{fs*1.5}px;font-weight:700;margin-bottom:{30*u}px">Pinecone Cabin</div>'
           f'<div style="color:#6e6e73;margin-bottom:{40*u}px">Check-in from 3 pm. The key is in the lockbox by the door, code 1904.</div>'
           f'<div style="margin-top:{110*u}px">{sel}</div>'
           f'<div style="margin-top:{30*u}px;color:#6e6e73">Firewood is in the shed. Please leave the boots by the stove.</div></div>')
    url = (f'<div style="position:absolute;left:{40*u}px;right:{40*u}px;bottom:{90*u}px;height:{110*u}px;border-radius:{55*u}px;background:#EDEDF0;'
           f'display:flex;align-items:center;justify-content:center;gap:12px;font-size:{40*u}px;color:#3a3a3c">{symbol("lock.fill", 34*u, "#3a3a3c")}pinecone-cabin.example</div>')
    return f'<div style="position:absolute;inset:0;background:#fff">{txt}{menu}{url}</div>'


# ------------------------------------------------------------------ the sets

def spec_qr(P, loc, scr, T, own):
    """Quick replies: 1 the same question again | 2 the keyboard asks for the name | 3 the same reply, every name
    | 4 the date fills itself | 5 every reply in one place | 6 iPhone, iPad and Mac."""
    wv, _ = lib.words(loc); cs = wv["cseed"]; F = lib.FACTS[loc]
    w, pad = P.w, P.pad
    day = F["weekday_tue_nov24"]
    names = cs["names"]
    hs = 250 if pad else 196
    heads = [dict(left=i * w + (128 if pad else 96), w=w - 2 * (128 if pad else 96), html=heading(T[str(i + 1)]["h"]), fine=T[str(i + 1)].get("f")) for i in range(6)]
    cz = 1.45 if pad else 1.0
    X = lambda i, x: i * w + x * (w / 1320)        # place by the iPhone frame's measures, stretched on the iPad
    Y = (lambda y: 700 + (y - 600) * .95) if pad else (lambda y: y)
    bar = lib.split_template(cs["reply"], {"name": cs["name_label"], "date": day}, "name")
    pw = 1080
    panel, ph = lib.fill_panel(bar, names, F, pw, pw / 1398, pressed=1, rtl=loc in lib.RTL, radius=56)
    bub = lambda n: esc(lib.chips_text(cs["reply"], {"name": n, "date": day}))
    before, _, after = cs["delivered"].partition("{date}")
    tok = f'<span class="tok">{symbol("calendar", 60, "#08664B")}{esc(F["product_terms"].get("Today’s Date", "Today’s Date"))}</span>'
    note = (f'<div style="padding:50px 58px;font:400 72px/1.3 var(--sf);color:#000;letter-spacing:-.02em;white-space:normal">'
            f'<div style="font-size:48px;color:#8A8A8E;margin-bottom:14px;display:flex;gap:14px;align-items:center">{symbol("calendar", 46, "#FF8D28")}{esc(cs["delivered_name"])}</div>'
            f'{esc(before)}{tok}{esc(after)}</div>')
    phone_dev = lambda i, x, top, rz, src, lifts, zoom=.67: dict(kind="phone", rx=44, rz=rz, zoom=zoom * (1.45 if pad else 1), left=X(i, x), top=Y(top), grid=1, src=src, lifts=lifts)
    L = lambda id_, x, y, w_, h_, z, r=44, k=1.08: dict(id=id_, x=x, y=y, w=w_, h=h_, z=z, c="#5CF2C0", r=r, k=k)
    S = 1320 / 1290 if not pad else 1.0
    tile0 = L("t0", 18 * S, 2868 - 1128 * S + 248 * S, 633, 186 * S, 460) if not pad else L("t0", 18, 2752 - 940 + 250, 400, 150, 460)
    pad_dev = lambda i, x, top, rz, src, lifts, zoom=.62: dict(kind="pad", rx=44, rz=rz, zoom=zoom, left=X(i, x), top=Y(top), grid=1, src=src, lifts=lifts)
    grid = scr["grid"].as_uri()
    # the 02 capture is 1290 px wide, drawn 1320 wide: its first row of tiles sits at (53, 602) and (664, 602), 574 x 420;
    # the iPad's (2064 wide) at (36, 350) and (440, 350), 374 x 274
    g = 1320 / 1290
    if pad:
        devs = [pad_dev(0, 60, 640, -14, scr["chat"].as_uri(), [tile0]),
                pad_dev(4, 0, 640, 12, scr["padgrid"].as_uri(), [L("g1", 36, 350, 374, 274, 460, 56, 1.2), L("g2", 440, 350, 374, 274, 300, 56, 1.2)])]
    else:
        devs = [phone_dev(0, 30, 640, -16, scr["chat"].as_uri(), [tile0]),
                phone_dev(4, -60, 640, 14, grid, [L("g1", 53 * g, 602 * g, 574 * g, 420 * g, 460, 56), L("g2", 664 * g, 602 * g, 574 * g, 420 * g, 300, 56)])]
    pad_grid = scr["padgrid"].as_uri()
    devs.append(dict(kind="pad", rx=44, rz=-14, zoom=.44 * (1.45 if pad else 1), left=X(5, 330), top=Y(1130), grid=1, src=pad_grid,
                     lifts=[L("p", 36, 350, 374, 274, 320, 56, 1.2)]))
    devs.append(phone_dev(5, 60, 1640, -14, grid, [L("q", 53 * g, 602 * g, 574 * g, 420 * g, 320, 56)], zoom=.42))
    cards = [
        dict(id="panel", type="raw", w=pw, left=X(1, 110) / 1, top=Y(1540), rot=-3, inner=f'<div style="border-radius:56px;overflow:hidden">{panel}</div>'),
        dict(id="b1", type="bubble", w=1000, left=X(2, 140), top=Y(1180), rot=-2, inner=f"<p>{bub(names[0])}</p>"),
        dict(id="b2", type="bubble", w=1000, left=X(2, 230), top=Y(1700), rot=2, inner=f"<p>{bub(names[1])}</p>"),
        dict(id="b3", type="bubble", w=1000, left=X(2, 700), top=Y(2280), rot=-3, inner=f"<p>{bub(names[2])}</p>"),
        dict(id="note", type="raw", w=1000, left=X(3, 300), top=Y(1150), rot=2, inner=note),
        dict(id="dated", type="bubble", w=1000, left=X(3, 200), top=Y(1800), rot=-2,
             inner=f'<p>{esc(before)}<span class="val">{esc(F["long_date_nov23"])}</span>{esc(after)}</p>'),
        dict(id="m", type="raw", w=600, left=X(5, 650), top=Y(2420), rot=3, label="⌘⇧V",
             inner=f'<div style="overflow:hidden;border-radius:44px;height:{600*1028/720*.42}px"><img src="{lib.cap(loc, "mac-picker")}" style="width:100%;display:block"></div>'),
    ]
    links = [dict(a="t0:mR", b="panel:L", bend=[600, -300, -500, -100]), dict(a="panel:R", b="b1:L", bend=[300, -300, -300, 60]),
             dict(a="panel:R", b="b2:L", bend=[260, 120, -260, -40]), dict(a="b3:R", b="note:B", bend=[300, 60, 40, 300]),
             dict(a="dated:R", b="g1:mL", bend=[500, 100, -400, 200]), dict(a="g2:mR", b="p:mB", bend=[400, 300, -60, 300])]
    glows = [[X(i, 700), 2000, 1500, 1100] for i in range(6)]
    return dict(W=P.W, H=P.h, h1size=hs, heads=heads, devices=devs, cards=cards, links=links, glows=glows, cz=cz if pad else None)


def spec_ch(P, loc, scr, T, own):
    """Clipboard history: 1 copied something worth keeping | 2 Add from Clipboard | 3 now a cutling | 4 paste it
    anywhere | 5 the Mac keeps a history | 6 iPhone, iPad and Mac."""
    w, pad = P.w, P.pad
    hs = 250 if pad else 196
    heads = [dict(left=i * w + (128 if pad else 96), w=w - 2 * (128 if pad else 96), html=heading(T[str(i + 1)]["h"]), fine=T[str(i + 1)].get("f")) for i in range(6)]
    X = lambda i, x: i * w + x * (w / 1320)
    Y = (lambda y: 700 + (y - 600) * .95) if pad else (lambda y: y)
    L = lambda id_, x, y, w_, h_, z, r=44, k=1.08: dict(id=id_, x=x, y=y, w=w_, h=h_, z=z, c="#5CF2C0", r=r, k=k)
    zf = 1.45 if pad else 1
    phone_dev = lambda i, x, top, rz, src, lifts, zoom=.67: dict(kind="phone", rx=44, rz=rz, zoom=zoom * zf, left=X(i, x), top=Y(top), grid=1, src=src, lifts=lifts)
    S = 1320 / 1290
    sel = L("sel", 50, 800, 640, 110, 420, 24, 1.1) if not pad else L("sel", 50, 612, 560, 100, 420, 24, 1.1)
    hdr = L("hdr", 310, 2868 - 1128 * S + 143 * S - 55, 700, 110, 460, 40) if not pad else L("hdr", 640, 2752 - 940 + 150 - 50, 780, 100, 460, 40)
    if pad:
        pd_ = lambda i, x, top, rz, src, lifts: dict(kind="pad", rx=44, rz=rz, zoom=.62, left=X(i, x), top=Y(top), grid=1, src=src, lifts=lifts)
        devs = [pd_(0, 60, 640, -14, scr["copy"].as_uri(), [sel]), pd_(1, 0, 640, 12, scr["kb"].as_uri(), [hdr])]
    else:
        devs = [phone_dev(0, 30, 640, -16, scr["copy"].as_uri(), [sel]),
                phone_dev(1, -150, 640, 14, scr["kb"].as_uri(), [hdr])]
    grid2 = scr["grid2"].as_uri()
    devs.append(dict(kind="pad", rx=44, rz=-14, zoom=.44 * zf, left=X(5, 330), top=Y(1130), grid=1, src=scr["padgrid"].as_uri(),
                     lifts=[L("p", 36, 350, 374, 274, 320, 56, 1.2)]))
    # the 2.0 grid capture (1320 wide): its first row of tiles at (43, 322) and (673, 322), 604 x 412
    devs.append(phone_dev(5, 60, 1640, -14, grid2, [L("q", 43, 322, 604, 412, 320, 80)], zoom=.42))
    kw = 1100
    cards = [
        dict(id="new", type="key", w=kw, left=X(2, 120), top=Y(1500), rot=-4, label="Cabin Wi-Fi", inner=keycard("wifi", "Cabin Wi-Fi", "pinecone-2026", kw)),
        dict(id="cA", type="field", w=None, left=X(3, 140), top=Y(1180), rot=-3, label="A message", inner='<p>Wi-Fi: pinecone-2026<span class="caret"></span></p><u></u>'),
        dict(id="cB", type="text", w=None, left=X(3, 260), top=Y(1720), rot=2.5, label="An email", inner='<p>The cabin’s Wi-Fi is<br>pinecone-2026<span class="caret"></span></p>'),
        dict(id="cC", type="text", w=None, left=X(3, 600), top=Y(2400), rot=-2, label="A note", inner='<p><s>Wi-Fi</s> pinecone-2026<span class="caret"></span></p>'),
        dict(id="mh", type="raw", w=900, left=X(4, 200), top=Y(1250), rot=-3, label="⌘⇧V on Mac",
             inner=f'<div style="overflow:hidden;border-radius:44px">{lib.m.history_label("en-US", 900) if False else ""}<img src="{lib.cap(loc, "mac-history")}" style="width:100%;display:block"></div>'),
    ]
    links = [dict(a="sel:mR", b="hdr:mL", bend=[500, -200, -400, -200]), dict(a="hdr:mR", b="new:L", bend=[500, 100, -400, -100]),
             dict(a="new:R", b="cA:L", bend=[300, -300, -300, 60]), dict(a="new:R", b="cB:L", bend=[260, 120, -260, -40]),
             dict(a="cC:R", b="mh:B", bend=[300, 100, 60, 300]), dict(a="mh:R", b="p:mB", bend=[500, 400, -60, 300])]
    glows = [[X(i, 700), 2000, 1500, 1100] for i in range(6)]
    return dict(W=P.W, H=P.h, h1size=hs, heads=heads, devices=devs, cards=cards, links=links, glows=glows, cz=1.45 if pad else None)


def mirror(spec, P):
    """Right to left: the picture mirrored, frame 1 on the right. Places and turns flip; screens and words do not."""
    W = spec["W"]
    D = {"phone": (1400, 3040), "pad": (2160, 2848)}
    for d in spec["devices"]:
        d["left"] = W - d["left"] - D[d["kind"]][0] * d["zoom"]
        d["rz"] = -d["rz"]
    for c in spec["cards"]:
        cz = spec.get("cz") or 1
        if c.get("w"):
            c["left"] = W - c["left"] - c["w"] * cz
        else:
            c["left"] = W - c["left"] - 900 * cz
        c["rot"] = -c.get("rot", 0)
    for h in spec["heads"]:      # frame i's words sit as far from the page's right edge as they sat from its left
        h["right"] = h.pop("left")
    flip = {"L": "R", "R": "L", "mR": "mL", "mL": "mR"}
    for l in spec["links"]:
        for k in ("a", "b"):
            id_, side = l[k].split(":"); l[k] = f"{id_}:{flip.get(side, side)}"
        b = l["bend"]; l["bend"] = [-b[0], b[1], -b[2], b[3]]
    for g in spec["glows"]:
        g[0] = W - g[0]
    return spec


def build(loc, dev, out_dir, page):
    """Queues the drawn screens; returns the frame jobs (run after the screens are rendered)."""
    _, own = lib.words(loc)
    T = own[{"qr": "night_qr", "ch": "night_ch"}[page]]
    out_dir.mkdir(parents=True, exist_ok=True)
    scr = screen_jobs(loc, dev, page, out_dir, own)
    P = lib.Pano(loc, dev, 6)
    spec = (spec_qr if page == "qr" else spec_ch)(P, loc, scr, T, own)
    if spec.get("cz") is None:
        spec.pop("cz")
    if P.rtl:
        spec = mirror(spec, P)
    spec["lh"] = HEAD_LH.get(loc)
    if loc == "ur-PK":
        spec["h1size"] = round(spec["h1size"] * .8)
    src = (N / "frame.html").read_text()
    font = HEAD_FONT.get(loc, "")
    style = (f'<link rel="stylesheet" href="{(lib.V2 / "lib.css").as_uri()}"><style>{CSS_CARDS} h1{{font-family:Rounded,var(--sf){"," + font if font else ""}}}'
             f' {lib.m.locale_css(loc)} .card .lab{{font-family:Rounded,var(--sf){"," + font if font else ""}}}</style>')
    html_ = (src.replace("<script>/*SPEC*/</script>", f"<script>window.SPEC={json.dumps(spec, ensure_ascii=False)}</script>")
             .replace('<script src="READY">', f'<script src="{(lib.HERE.parent / "ready.js").as_uri()}">')
             .replace("<body>", "<body>" + style + ("<style>h1,.fine,.card,.chip{direction:rtl}</style>" if P.rtl else ""), 1).replace('<meta charset="utf-8">', f'<meta charset="utf-8"><html lang="{loc}">', 1))
    p = out_dir / "pano.html"
    p.write_text(html_)
    jobs = []
    for i in range(P.n):
        tmp = out_dir / f".tall-{i+1:02d}.png"
        jobs.append({"html": f"{p}?x={P.frame_x(i)}", "png": str(tmp), "w": P.w, "h": P.h + TALL})
        CROPS.append(["magick", str(tmp), "-crop", f"{P.w}x{P.h}+0+0", "+repage", str(out_dir / f"{i+1:02d}.png")])
    return jobs
