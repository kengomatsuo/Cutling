#!/usr/bin/env python3
"""App Store header and search banners (ASG253): one universal 5244 x 2950 PNG, no alpha, per page and language, in
the look of that page's screenshots.

    python3 banners.py <page> [locale ...|--all]      render (out/banners/<page>/<locale>.png)
    python3 banners.py preview <page>                 en-US whole, crops marked, the two crops beside it
    python3 banners.py sheet <page>                   every language's banner on one picture

Apple's Universal template ("Art Safe Area") keeps x 1921-3323, y 660-1622 on every surface. The iPhone product-page
header puts its status bar over about y 530-840, so the headline starts at y 870, inside the safe area, and the hero
object (the key, the fill-in, the copied text) fills the safe area under it. Everything outside is backdrop from the
page's own frames: it shows where a surface is wider and may be cut anywhere.

Crops drawn on the previews, as estimates (no Apple template on disk): the iPhone header is taken as x 1494-3750,
y 530-2420 (its status bar 310 px tall, at iPhone's 393 pt width), the search card as the centred 3:2 x 1182-4062,
y 515-2435. Only the safe area is Apple's figure.

Words: each page's frames 1 and 2, already written for every language (words/<locale>.json); nothing new.
"""
import json, re, subprocess, sys
from pathlib import Path

import lib
import poster
import night
import keys
from lib import esc, symbol

W, H = 5244, 2950
SAFE = (1921, 660, 3323, 1622)
IPHONE = (1494, 530, 3750, 2420)
STATUS = 310
SEARCH = (1182, 515, 4062, 2435)
OUT = lib.HERE / "out" / "banners"
PAGES = {"main": lib.STORE, "text-expander": lib.ENGLISH, "personal-details": lib.STORE,
         "notes-you-paste": lib.ENGLISH, "quick-replies": lib.STORE, "clipboard-history": lib.ENGLISH}


class Stage:
    """Placement on the 5244-wide banner, mirrored for right-to-left languages like lib.Pano."""
    def __init__(self, loc):
        self.loc, self.rtl, self.parts = loc, loc in lib.RTL, []
        self.w, self.h, self.W, self.pad = W, H, W, False

    def fx(self, i):
        return 0

    pos = lib.Pano.pos

    def add(self, s):
        self.parts.append(s)


def write(path, body, css, loc, extra_head=""):
    path.parent.mkdir(parents=True, exist_ok=True)
    page = lib.m.page(W, H, body, css, loc)
    if loc in lib.RTL:
        page = page.replace(' dir="rtl"', "", 1).replace('<div class="stage">', '<div class="stage" dir="rtl">', 1)
    page = page.replace("</head>", extra_head + "</head>", 1)
    path.write_text(page)
    lib.m.JOBS.append({"html": str(path), "png": str(path.with_suffix(".raw.png")), "w": W, "h": H})


# ------------------------------------------------------------------ Don't type it: main page, Text expander

CENTER_FIT = """<script>addEventListener('load',async()=>{await document.fonts.ready;const c=document.getElementById('hd');
for(const el of c.querySelectorAll('.h1')){let fs=parseFloat(el.style.fontSize);const w=()=>[...el.querySelectorAll('.ln')].reduce((a,l)=>Math.max(a,l.getBoundingClientRect().width),0);
while(w()>+c.dataset.w&&fs>40){fs*=.97;el.style.fontSize=fs+'px';}}
let s=1;while(c.scrollHeight>+c.dataset.h&&s>.4){s*=.97;for(const el of c.querySelectorAll('.h1'))el.style.fontSize=parseFloat(el.style.fontSize)*.97+'px';}});</script>"""


def headline_block(lines, size, top=870, width=1340, height=330, color="var(--ink)"):
    """The headline, centred in the safe area under the iPhone status bar: each entry one line or a |-joined pair."""
    hs = "".join(f'<div class="h1" style="font-size:{size}px;color:{color}">{poster.lines(t)}</div>' for t in lines)
    return (f'<div id="hd" data-w="{width}" data-h="{height}" style="position:absolute;left:{(W-width)/2}px;top:{top}px;width:{width}px;'
            f'text-align:center;z-index:40">{hs}</div>')


def poster_banner(loc, page, out):
    Wd, own = lib.words(loc)
    cs = Wd["cseed"]; F = lib.FACTS[loc]
    S = Stage(loc); sd = lib.seed(loc)
    if page == "main":
        j = "" if loc in ("ja", "zh-Hans", "zh-Hant") else " "   # each frame's headline on one line of the banner
        t1, t2 = own["main"]["1"]["h"].replace("|", j), own["main"]["2"]["h"].replace("|", j)
        hero = poster.key(S, (W - 1060) / 2, 1330, 1060, "home", sd["home"][0], poster.first_line(sd["home"][1]) + "…", rot=-3, z=12)
        ring = poster.ring(S, (W - 1060) / 2 + 1060 - 330, 1345, 200, z=13)
        # the whole address fits x 130-1800 (left of the headline) and y 700-2780, in every language
        per, size = poster.fit_keys(sd["home"][1], 1670, 2080, 190, 232, 1.25)
        left, n, _ = poster.letter_keys(S, 0, sd["home"][1], 130, 700, per, pitch=190, row=232, size=size, hard=True)
        phone_cap, aspect, bar, dark = lib.cap(loc, "phone-guide"), 2796 / 1290, "#000", False
    else:   # Text expander: no codes to remember, one key
        t1, t2 = poster.TE["1"]["h"].replace("|", " "), poster.TE["2"]["h"].replace("|", " ")
        hero = poster.key(S, (W - 1060) / 2, 1330, 1060, "note", "Welcome note", own["demo"]["note"][0], rot=-3, z=12)
        ring = poster.ring(S, (W - 1060) / 2 + 1060 - 330, 1345, 200, z=13)
        left = poster.code_rows(S, 0, [";addr", ";sig", ";iban", ";wifi", ";hi"], 230, 900, size=1.4, pitch=215, row=300)
        phone_cap, aspect, bar, dark = lib.cap(loc, "phone-formatted"), 2868 / 1320, "#C7C7CC", True
    S.add(headline_block([t1, t2], 270, height=440))
    S.add(hero + ring)
    S.add(left)
    # right: the other keys, stacked as in frame 2
    for i, (k, x, y, r) in enumerate((("sig", 3460, 820, 3), ("wifi", 3540, 1240, -2.5), ("bank", 3420, 1660, 2), ("meeting", 3560, 2080, -3))):
        n_, v_ = sd[k]
        S.add(poster.key(S, x, y, 1420, k, n_, poster.first_line(v_) + ("…" if "\n" in v_ else ""), rot=r, z=9 - i))
    # below the hero: the phone with the text typed in, its top showing
    ph, _ = lib.phone_cap(phone_cap, 1180, aspect, bar=bar, dark_text=dark)
    S.add(f'<div style="{S.pos((W-1180)/2, 1800, z=5)}">{ph}</div>')
    css = poster.CSS + " .h1,.sub{font-family:system-ui,-apple-system%s} .h1{line-height:%s}" % (
        ("," + poster.HEAD_FONT[loc]) if loc in poster.HEAD_FONT else "", poster.HEAD_LH.get(loc, (.88, 1))[0])
    write(out.with_suffix(".html"), "".join(S.parts), css, loc, CENTER_FIT)


# ------------------------------------------------------------------ Night flight: Quick replies, Clipboard history

def night_banner(loc, page, out):
    Wd, own = lib.words(loc)
    cs = Wd["cseed"]; F = lib.FACTS[loc]
    d = out.parent / f".{loc}"
    d.mkdir(parents=True, exist_ok=True)
    scr = night.screen_jobs(loc, "iphone", "qr" if page == "quick-replies" else "ch", d, own)
    L = lambda id_, x, y, w_, h_, z, r=44, k=1.08: dict(id=id_, x=x, y=y, w=w_, h=h_, z=z, c="#5CF2C0", r=r, k=k)
    S = 1320 / 1290
    if page == "quick-replies":
        T = own["night_qr"]
        h1, h2 = T["1"]["h"], T["2"]["h"]
        day = F["weekday_tue_nov24"]; names = cs["names"]
        bar = lib.split_template(cs["reply"], {"name": cs["name_label"], "date": day}, "name")
        pw = 1180
        panel, _ = lib.fill_panel(bar, names, F, pw, pw / 1398, pressed=1, rtl=loc in lib.RTL, radius=56)
        bub = lambda n: esc(lib.chips_text(cs["reply"], {"name": n, "date": day}))
        tile0 = L("t0", 18 * S, 2868 - 1128 * S + 248 * S, 633, 186 * S, 460)
        devs = [dict(kind="phone", rx=44, rz=-16, zoom=.67, left=330, top=760, grid=1, src=scr["chat"].as_uri(), lifts=[tile0])]
        g = 1320 / 1290
        devs.append(dict(kind="phone", rx=44, rz=14, zoom=.67, left=4040, top=760, grid=1, src=scr["grid"].as_uri(),
                         lifts=[L("g1", 53 * g, 602 * g, 574 * g, 420 * g, 460, 56)]))
        cards = [dict(id="panel", type="raw", w=pw, left=(W - pw) / 2, top=1330, rot=-2, inner=f'<div style="border-radius:56px;overflow:hidden">{panel}</div>'),
                 dict(id="b1", type="bubble", w=900, left=3260, top=1350, rot=2, inner=f"<p>{bub(names[0])}</p>"),
                 dict(id="b2", type="bubble", w=900, left=3380, top=1860, rot=-2, inner=f"<p>{bub(names[1])}</p>"),
                 dict(id="b3", type="bubble", w=900, left=1120, top=2160, rot=-3, inner=f"<p>{bub(names[2])}</p>")]
        links = [dict(a="t0:mR", b="panel:L", bend=[500, -200, -400, 0]), dict(a="panel:R", b="b1:L", bend=[200, -100, -200, 0]),
                 dict(a="panel:R", b="b2:L", bend=[260, 200, -260, 0]), dict(a="panel:B", b="b3:R", bend=[0, 300, 300, 0])]
    else:
        T = own["night_ch"]
        h1, h2 = T["1"]["h"], T["2"]["h"]
        sel = L("sel", 50, 800, 640, 110, 420, 24, 1.1)
        devs = [dict(kind="phone", rx=44, rz=-16, zoom=.67, left=330, top=760, grid=1, src=scr["copy"].as_uri(), lifts=[sel])]
        g2 = lib.cap(loc, "phone-grid2")
        devs.append(dict(kind="phone", rx=44, rz=14, zoom=.67, left=4040, top=760, grid=1, src=g2,
                         lifts=[L("q", 43, 322, 604, 412, 320, 80)]))
        kw = 1180
        cards = [dict(id="new", type="key", w=kw, left=(W - kw) / 2, top=1400, rot=-3, label="Cabin Wi-Fi",
                      inner=night.keycard("wifi", "Cabin Wi-Fi", "pinecone-2026", kw)),
                 dict(id="cA", type="field", left=3250, top=1380, rot=-3, label="A message", inner='<p>Wi-Fi: pinecone-2026<span class="caret"></span></p><u></u>'),
                 dict(id="cB", type="text", left=3420, top=1960, rot=2.5, label="An email", inner='<p>The cabin’s Wi-Fi is<br>pinecone-2026<span class="caret"></span></p>'),
                 dict(id="cC", type="text", left=1150, top=2180, rot=-2, label="A note", inner='<p><s>Wi-Fi</s> pinecone-2026<span class="caret"></span></p>')]
        links = [dict(a="sel:mR", b="new:L", bend=[500, -100, -400, 0]), dict(a="new:R", b="cA:L", bend=[260, -100, -260, 0]),
                 dict(a="new:R", b="cB:L", bend=[260, 200, -260, 0]), dict(a="new:B", b="cC:R", bend=[0, 300, 300, 0])]
    heads = [dict(left=(W - 1400) / 2, w=1400, html=night.heading(h1.replace("|", " ")), top=880, align="center"),
             dict(left=(W - 1400) / 2, w=1400, html=night.heading(h2.replace("|", " ")), top=1100, align="center", small=1)]
    spec = dict(W=W, H=H, h1size=172, heads=heads, devices=devs, cards=cards, links=links,
                glows=[[2622, 1500, 2600, 1500], [700, 1700, 1500, 1100], [4500, 1700, 1500, 1100]], lh=night.HEAD_LH.get(loc))
    if loc == "ur-PK":
        spec["h1size"] = 120
    src = (night.N / "frame.html").read_text()
    font = night.HEAD_FONT.get(loc, "")
    style = (f'<link rel="stylesheet" href="{(lib.V2 / "lib.css").as_uri()}"><style>{night.CSS_CARDS} h1{{font-family:Rounded,var(--sf){"," + font if font else ""}}}'
             f' {lib.m.locale_css(loc)} .card .lab{{font-family:Rounded,var(--sf){"," + font if font else ""}}}'
             f' h1.small{{font-size:110px!important}}</style>'
             + ("<style>h1,.fine,.card,.chip{direction:rtl}</style>" if loc in lib.RTL else ""))
    html_ = (src.replace("<script>/*SPEC*/</script>", f"<script>window.SPEC={json.dumps(spec, ensure_ascii=False)}</script>")
             .replace('<script src="READY">', f'<script src="{(lib.HERE.parent / "ready.js").as_uri()}">')
             .replace("<body>", "<body>" + style, 1).replace('<meta charset="utf-8">', f'<meta charset="utf-8"><html lang="{loc}">', 1))
    # centred headlines: the frame page places a head by left/right; centre it in its box and mark the smaller line
    html_ = html_.replace('''for (const hd of spec.heads) { const e = document.createElement("h1"); e.innerHTML = hd.html; e.dataset.w = hd.w;''',
                          '''for (const hd of spec.heads) { const e = document.createElement("h1"); e.innerHTML = hd.html; e.dataset.w = hd.w; if (hd.small) e.className = "small";''')
    html_ = html_.replace('''${hd.right != null ? "text-align:right;" : ""}''', '''${hd.align ? "text-align:center;width:" + hd.w + "px;white-space:nowrap;" : (hd.right != null ? "text-align:right;" : "")}''')
    p = out.with_suffix(".html")
    p.write_text(html_)
    return [{"html": str(p), "png": str(out.parent / f".{loc}-tall.png"), "w": W, "h": H + night.TALL}]


# ------------------------------------------------------------------ Keys: Personal details, Notes you paste

def keys_banner(loc, page, out):
    name = {"personal-details": "pd-banner", "notes-you-paste": "np-banner"}[page]
    Wd, own = lib.words(loc)
    T = own["keys_pd" if page == "personal-details" else "keys_np"]["1"]["h"]
    d = out.parent / f".{loc}"
    apng = keys.atlas(loc, name, own, d / "atlas.html")
    at = json.loads((keys.K / "scenes" / f"{name}.layout.json").read_text())
    rd = keys.K / "renders" / name
    comp = dict(beauty=(rd / "01-beauty.png").as_uri(), u=(rd / "01-u.png").as_uri(), v=(rd / "01-v.png").as_uri(), atlas=apng.as_uri(),
                keys=[[f["x"], f["y"], keys.FACE[0], keys.FACE[1]] for f in at["faces"]],
                screens=[[s["x"], s["y"], s["w"], s["h"]] for s in at["screens"]], flip=False)
    lines = []
    for ln in T.split("|"):
        ln = re.sub(r"\*(.+?)\*", lambda mm: f"<em>{esc(mm.group(1))}</em>", ln) if "*" in ln else esc(ln)
        lines.append(f'<span class="ln">{ln}</span>')
    size = 170
    lh = {"th": 1.3, "ar-SA": 1.25, "ur-PK": 1.7, "he": 1.1, **{l: 1.28 for l in ("hi", "mr-IN", "bn-BD", "gu-IN", "pa-IN", "or-IN", "kn-IN", "te-IN", "ml-IN", "ta-IN")}}.get(loc, 1.04)
    head = (f'<h1 class="kh" data-w="1360" data-h="300" style="left:{(W-1400)/2}px;width:1400px;top:860px;font-size:{size}px;line-height:{lh};text-align:center">'
            + "<br>".join(lines) + '</h1>')
    fonts = lib.m.locale_css(loc)
    hf = keys._head_font(loc)
    page_ = (f'<!doctype html><html lang="{loc}"><head><meta charset="utf-8"><link rel="stylesheet" href="{(lib.V2 / "lib.css").as_uri()}">'
             f'<style>{keys.KEYS_CSS} body{{width:{W}px;height:{H}px}} {fonts} .kh{{font-family:-apple-system,"SF Pro Display",system-ui{"," + hf if hf else ""};white-space:nowrap}}</style>'
             f'<script>window.COMP={json.dumps(comp)}</script></head><body{" dir=rtl" if loc in lib.RTL else ""}>'
             f'<canvas id="cv" width="{W}" height="{H}" style="width:{W}px;height:{H}px"></canvas>{head}{COMP_JS_H}</body></html>')
    p = out.with_suffix(".html")
    p.write_text(page_)
    return [{"html": str(p), "png": str(out.with_suffix(".raw.png")), "w": W, "h": H}]


# the composite script, with the headline also kept to its height (data-h): it ends above the key face under it
COMP_JS_H = keys.COMP_JS.replace("while(wide()>max+1&&fs>50)", "while((wide()>max+1||(h.dataset.h&&h.offsetHeight>+h.dataset.h))&&fs>50)")
assert COMP_JS_H != keys.COMP_JS


# ------------------------------------------------------------------ run, finish, check

def build(page, locs):
    after = []
    for loc in locs:
        out = OUT / page / f"{loc}.png"
        out.parent.mkdir(parents=True, exist_ok=True)
        if page in ("main", "text-expander"):
            poster_banner(loc, page, out)
        elif page in ("quick-replies", "clipboard-history"):
            after += night_banner(loc, page, out)
        else:
            after += keys_banner(loc, page, out)
    lib.run()                       # pages, drawn screens and atlases
    lib.m.JOBS.extend(after)
    lib.run()                       # pages that read them
    def finish(loc):   # each banner converted to PNG24 with no alpha, six at a time
        out = OUT / page / f"{loc}.png"
        raw = out.with_suffix(".raw.png"); tall = out.parent / f".{loc}-tall.png"
        src = tall if tall.exists() else raw
        tmp = out.with_suffix(".tmp.png")
        cmd = ["magick", str(src)] + (["-crop", f"{W}x{H}+0+0", "+repage"] if src == tall else []) + ["-alpha", "off", f"PNG24:{tmp}"]
        subprocess.run(cmd, check=True)
        tmp.replace(out)       # the final file appears whole, never half written
        src.unlink()
    from concurrent.futures import ThreadPoolExecutor
    with ThreadPoolExecutor(6) as ex:
        list(ex.map(finish, locs))
    check(page, locs)


def check(page, locs):
    bad = []
    for loc in locs:
        f = OUT / page / f"{loc}.png"
        r = subprocess.run(["magick", "identify", "-format", "%w %h %[channels]", str(f)], capture_output=True, text=True).stdout.split()
        if r[:2] != [str(W), str(H)] or "a" in r[2]:
            bad.append((loc, r))
    print(page, len(locs), "banners", "all 5244x2950, no alpha" if not bad else f"BAD {bad}")


def preview(page, loc="en-US"):
    """The banner whole with the safe area (Apple's), iPhone header and search crops (estimates) marked; the two crops
    beside it, the iPhone header with its status bar drawn over."""
    src = OUT / page / f"{loc}.png"
    d = OUT / page / ".prev"; d.mkdir(exist_ok=True)
    whole = d / "whole.png"
    sx, sy, ex, ey = SAFE; ix, iy, jx, jy = IPHONE; qx, qy, rx, ry = SEARCH
    subprocess.run(["magick", str(src), "-fill", "none", "-strokewidth", "14",
                    "-stroke", "#FF3B30", "-draw", f"rectangle {sx},{sy} {ex},{ey}",
                    "-stroke", "#FFD60A", "-draw", f"rectangle {ix},{iy} {jx},{jy}",
                    "-stroke", "#0A84FF", "-draw", f"rectangle {qx},{qy} {rx},{ry}",
                    "-fill", "rgba(0,0,0,.35)", "-stroke", "none", "-draw", f"rectangle {ix},{iy} {jx},{iy+STATUS}",
                    "-resize", "2400x", str(whole)], check=True)
    ip = d / "iphone.png"
    subprocess.run(["magick", str(src), "-crop", f"{jx-ix}x{jy-iy}+{ix}+{iy}", "+repage",
                    "-fill", "rgba(0,0,0,.55)", "-draw", f"rectangle 0,0 {jx-ix},{STATUS}",
                    "-fill", "white", "-font", "/System/Library/Fonts/SFNS.ttf", "-pointsize", "110", "-annotate", "+180+215", "9:41",
                    "-resize", "x1350", str(ip)], check=True)
    se = d / "search.png"
    subprocess.run(["magick", str(src), "-crop", f"{rx-qx}x{ry-qy}+{qx}+{qy}", "+repage", "-resize", "x1350", str(se)], check=True)
    lab = lambda f, t: subprocess.run(["magick", str(f), "-background", "#111", "-gravity", "North", "-splice", "0x80",
                                       "-font", "/System/Library/Fonts/SFNS.ttf", "-pointsize", "44", "-fill", "#fff", "-annotate", "+0+16", t, str(f)], check=True)
    lab(whole, f"{page} {loc} 5244x2950   red: Apple's safe area   yellow: iPhone header crop (est.)   blue: search card crop (est.)")
    lab(ip, "iPhone product page header (est.), status bar shaded")
    lab(se, "search result card (est., 3:2)")
    out = OUT / page / "preview-en-US.png"
    subprocess.run(["magick", str(whole), "(", str(ip), str(se), "-bordercolor", "#111", "-border", "30", "-background", "#111", "-gravity", "North", "+append", ")",
                    "-background", "#111", "-gravity", "Center", "-append", "-bordercolor", "#111", "-border", "40", str(out)], check=True)
    print(out)


def sheet(page):
    locs = [l for l in PAGES[page] if (OUT / page / f"{l}.png").exists()]
    d = OUT / page / ".sheet"; d.mkdir(exist_ok=True)
    tiles = []
    for l in locs:
        t = d / f"{l}.png"
        subprocess.run(["magick", str(OUT / page / f"{l}.png"), "-resize", "900x", "-background", "#111", "-gravity", "North", "-splice", "0x54",
                        "-font", "/System/Library/Fonts/SFNS.ttf", "-pointsize", "36", "-fill", "#fff", "-annotate", "+0+8", f"{page}  {l}", str(t)], check=True)
        tiles.append(str(t))
    cols = 5 if len(tiles) > 8 else 2
    out = OUT / page / "sheet.png"
    subprocess.run(["magick", "montage", *tiles, "-tile", f"{cols}x", "-geometry", "+16+16", "-background", "#111", str(out)], check=True)
    print(out)


if __name__ == "__main__":
    a = [x for x in sys.argv[1:] if not x.startswith("--")]
    if a[0] == "preview":
        preview(a[1])
    elif a[0] == "sheet":
        sheet(a[1])
    else:
        build(a[0], PAGES[a[0]] if "--all" in sys.argv else (a[1:] or ["en-US"]))
