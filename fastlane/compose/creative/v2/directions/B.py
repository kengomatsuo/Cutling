"""B. Every app: the screenshots carry on from the "Every app" preview. White like the captures, one black line and one
green line of type, and the real Cutling keyboard as a band at the same height in every iPhone and iPad frame, edge to
edge, so the row reads as one keyboard under a changing app. On the Mac the constant is the menu bar and the picker that
drops from Cutling's icon in it."""

GREEN_INK = "#0A8A63"
CSS = f"""
.stage{{background:#FDFDFD}}
.hl{{position:absolute;color:#111;font-weight:700;letter-spacing:-.03em;line-height:1.03}}
.gl{{color:{GREEN_INK};font-weight:600;letter-spacing:-.02em;line-height:1.12}}
.cmd{{display:inline-flex;gap:.1em;vertical-align:.04em}}
.cmd b{{display:inline-flex;align-items:center;justify-content:center;min-width:.95em;height:.95em;padding:0 .1em;border-radius:.16em;
  background:#EEF7F3;color:{GREEN_INK};font-weight:600;font-size:.86em;box-shadow:inset 0 0 0 .04em #BFE3D5}}
.band{{position:absolute;left:0;overflow:hidden}}
.band img{{position:absolute;left:0;display:block}}
.map{{position:absolute;overflow:hidden;background:#F1EEE7}}
.road{{position:absolute;background:#fff;box-shadow:0 0 0 2px #E4DFD4}}
.field{{position:absolute;background:#fff;display:flex;align-items:center;color:#111;letter-spacing:-.01em}}
.caret{{display:inline-block;width:.09em;height:1.15em;background:#0A84FF;margin-left:.04em;vertical-align:-.2em}}
.mbar{{position:absolute;left:0;top:0;right:0;background:rgba(246,246,246,.92);border-bottom:1px solid #d9d9d9;display:flex;align-items:center;justify-content:flex-end;color:#111}}
.mbar .it{{display:flex;align-items:center;justify-content:center;border-radius:10px}}
.mbar .on{{background:rgba(0,0,0,.12)}}
"""

def head(m, t, x, y, w, fs, gfs, gap=None):
    g = t.get("g", "")
    return (f'<div class="hl" style="left:{x}px;top:{y}px;width:{w}px;font-size:{fs}px;z-index:30">{m.rich(t["h"])}'
            f'<div class="gl" style="font-size:{gfs}px;margin-top:{gap if gap is not None else fs*.1}px">{m.rich(g)}</div></div>')

def build(m, loc, words, only):
    W = words["B"]; seed = words["seed"]
    out = m.HERE / "out" / loc / "B"
    for dev in ("iphone", "ipad", "mac"):
        if only and dev != only:
            continue
        (out / dev).mkdir(parents=True, exist_ok=True)
        {"iphone": lambda *a: touch_set(*a, "iphone"), "ipad": lambda *a: touch_set(*a, "ipad"), "mac": mac_set}[dev](m, loc, W, seed, out / dev)

# geometry of the real keyboard inside each chat capture (capture px): where the band starts, where its tiles sit
GEO = {
    "iphone": {"cap": "phone-chat", "cw": 1290, "ch": 2796, "kb": 1668, "tiles": (1902, 2578), "chat": 900},
    "ipad": {"cap": "pad-chat", "cw": 2064, "ch": 2752, "kb": 1772, "tiles": (2030, 2548), "chat": 1180},
}

def band(m, loc, dev, top_cap, w, h, *, z=10):
    """The capture from top_cap (capture px) to its bottom, scaled to the frame's width and sat on the frame's bottom."""
    g = GEO[dev]; k = w / g["cw"]
    bh = (g["ch"] - top_cap) * k
    return (f'<div class="band" style="top:{h-bh}px;width:{w}px;height:{bh}px;z-index:{z}">'
            f'<img src="{m.cap(loc, g["cap"])}" style="width:{w}px;top:{-top_cap*k}px"></div>'), h - bh, k

def touch_set(m, loc, W, seed, out, dev):
    T = dict(W["iphone"]); T.update(W.get(dev, {}))
    w, h = m.SIZE[dev]; g = GEO[dev]; k = w / g["cw"]
    pad = dev == "ipad"
    X, Y, HW, FS, GFS = (150, 180, 1760, 190, 112) if pad else (96, 180, 1140, 142, 84)
    sc = 1.35 if pad else 1.0
    kb_top = h - (g["ch"] - g["kb"]) * k           # where the keyboard band begins in the frame
    t0, t1 = g["tiles"]

    # 1: the real chat capture: the question, the pasted bank number, the keyboard
    b1, _, _ = band(m, loc, dev, g["chat"], w, h)
    p1 = head(m, T["1"], X, Y, HW, FS, GFS) + b1
    # 2: the same keyboard with its fill-in screen over the tiles
    b2, _, _ = band(m, loc, dev, g["kb"], w, h)
    inset = 14 * k
    pnl, _ = m.fillpanel(seed, w + inset, h - (g["ch"] - t0) * k, w - 2 * inset, chosen=1, keys=False, radius=0, z=20, unit=(2.15 if pad else None))
    pnl = pnl.replace("panel shadow-soft", "panel")
    ask = m.bubble(seed["ask_order"], w + X, kb_top - 520 * (1.25 if pad else 1), 64 if not pad else 70, mine=False)
    fld = (f'<div class="field" style="left:{w + X}px;width:{w - 2*X}px;top:{kb_top - 230*(1.2 if pad else 1)}px;height:{120*(1.15 if pad else 1)}px;'
           f'border-radius:999px;box-shadow:inset 0 0 0 3px #E2E2E6;padding:0 46px;font-size:{56 if not pad else 60}px;color:#9a9aa0">'
           f'<span class="caret" style="margin:0 0 0 -.1em"></span></div>')
    p2 = head(m, T["2"], w + X, Y, HW, FS, GFS) + b2.replace('style="top:', f'style="left:{w}px;top:', 1) + pnl + ask + fld
    body = p1 + p2
    pair = m.write_render(out / "pair-12.html", m.page(2 * w, h, body, CSS), 2 * w, h)
    m.split_pair(pair, out / "01.png", out / "02.png", w)

    # 3: Maps, the search field filled with the address (drawn stand-in until the "Every app" take G2 exists)
    b3, _, _ = band(m, loc, dev, g["kb"], w, h)
    top = 720 if not pad else 900
    mp = (f'<div class="map" style="left:0;top:{top}px;width:{w}px;height:{kb_top-top+40}px">'
          f'<div class="road" style="left:-100px;top:38%;width:{w+200}px;height:70px;transform:rotate(-8deg)"></div>'
          f'<div class="road" style="left:34%;top:-10%;width:60px;height:130%;transform:rotate(12deg)"></div>'
          f'<div class="road" style="left:70%;top:-10%;width:44px;height:130%;transform:rotate(-4deg)"></div>'
          f'<div class="abs" style="left:6%;top:6%;width:24%;height:26%;background:#CFE8C4;border-radius:40px"></div>'
          f'<div class="abs" style="left:76%;top:56%;width:30%;height:40%;background:#BFDDF2;border-radius:60px"></div>'
          f'<div class="abs" style="left:47%;top:22%">{m.symbol("mappin.circle.fill", 150 if pad else 120, "#FF3B30")}</div></div>')
    sheet_h = 430 * sc
    sh = (f'<div class="abs" style="left:0;top:{kb_top-sheet_h+40}px;width:{w}px;height:{sheet_h}px;background:#fff;'
          f'border-radius:60px 60px 0 0;box-shadow:0 -10px 40px rgba(0,0,0,.08);z-index:5"></div>'
          f'<div class="field" style="left:{X*0.7}px;top:{kb_top-sheet_h+110}px;width:{w-1.4*X}px;height:{130*sc}px;background:#EEEEF0;border-radius:40px;'
          f'padding:0 40px;font-size:{62*sc}px;gap:24px;z-index:6">{m.symbol("magnifyingglass", 56*sc, "#8a8a8e")}{m.esc(seed["maps_field"])}<span class="caret"></span></div>'
          f'<div class="abs" style="left:{X*0.7+40}px;top:{kb_top-sheet_h+290*sc}px;display:flex;gap:30px;align-items:center;z-index:6">'
          f'{m.symbol("mappin.circle.fill", 90*sc, "#FF3B30")}<div><div style="font-size:{56*sc}px;font-weight:600">{m.esc(seed["maps_result"])}</div>'
          f'<div style="font-size:{44*sc}px;color:#8a8a8e">{m.esc(seed["maps_sub"])}</div></div></div>')
    body = head(m, T["3"], X, Y, HW, FS, GFS) + mp + sh + b3
    m.flatten(m.write_render(out / "03.html", m.page(w, h, body, CSS), w, h))

    # 4: Mail, the signature typed at the end of a message (drawn stand-in until a take exists)
    b4, _, _ = band(m, loc, dev, g["kb"], w, h)
    fs = 58 * sc
    y0 = 760 if not pad else 720
    rows = [(seed["mail_to"], "maya@example.com"), (seed["mail_subject"], seed["mail_subject_v"])]
    mail = ""
    for i, (a, b) in enumerate(rows):
        mail += (f'<div class="abs" style="left:{X}px;right:{X}px;top:{y0+i*120*sc}px;height:{120*sc}px;border-bottom:2px solid #E5E5EA;'
                 f'display:flex;align-items:center;gap:20px;font-size:{fs}px"><span style="color:#8a8a8e">{m.esc(a)}</span>{m.esc(b)}</div>')
    sig = "<br>".join(m.esc(x) for x in seed["sig_lines"])
    mail += (f'<div class="abs" style="left:{X}px;right:{X}px;top:{y0+300*sc}px;font-size:{fs+6}px;line-height:1.4">{m.esc(seed["mail_body"])}<br><br>'
             f'<span style="background:#DDF3EA;border-radius:12px;box-shadow:0 0 0 12px #DDF3EA">{sig}</span><span class="caret"></span></div>')
    body = head(m, T["4"], X, Y, HW, FS, GFS) + mail + b4
    m.flatten(m.write_render(out / "04.html", m.page(w, h, body, CSS), w, h))

    # 5: the app's own list, above the keyboard that shows the same cutlings
    b5, _, _ = band(m, loc, dev, g["kb"], w, h)
    gcap = m.cap(loc, "phone-grid" if not pad else "pad-grid")
    gw = w; gk = gw / (1290 if not pad else 2048)
    cut_top = 300 if not pad else 110
    gh = kb_top - (760 if not pad else 900)
    grid = (f'<div class="band" style="top:{kb_top-gh}px;width:{w}px;height:{gh}px;z-index:4;background:#F2F2F7">'
            f'<img src="{gcap}" style="width:{gw}px;top:{-cut_top*gk}px"></div>')
    body = head(m, T["5"], X, Y, HW, FS, GFS) + grid + b5
    m.flatten(m.write_render(out / "05.html", m.page(w, h, body, CSS), w, h))

    # 6: the closing line, the icon, the keyboard
    b6, _, _ = band(m, loc, dev, g["kb"], w, h)
    icon = (m.REPO / "Cutling/Assets.xcassets/AppIcon-Default.imageset/AppIcon-Default.png").as_uri()
    isz = 300 if not pad else 340
    body = (head(m, T["6"], X, Y + isz + 90, HW, FS * 1.08, GFS * 0.9)
            + f'<img src="{icon}" style="position:absolute;left:{X-8}px;top:{Y}px;width:{isz}px;border-radius:{isz*.225}px;'
              f'box-shadow:0 20px 50px rgba(0,0,0,.15)">' + b6)
    m.flatten(m.write_render(out / "06.html", m.page(w, h, body, CSS), w, h))

# ------------------------------------------------------------------ Mac 2880 x 1800

def menubar(m, H=150, on=True):
    """macOS's menu bar at 2.5 times its size, only its right end: Cutling's glyph, Wi-Fi, Spotlight, the clock."""
    glyph = (m.REPO / "fastlane/compose/mac/menubar.png").as_uri()
    it = lambda inner, cls="": f'<div class="it {cls}" style="height:{H*.74}px;padding:0 {H*.26}px;border-radius:{H*.16}px">{inner}</div>'
    return (f'<div class="mbar" style="height:{H}px;padding-right:{H*.35}px;gap:{H*.06}px;font-size:{H*.36}px;z-index:50">'
            + it(f'<img src="{glyph}" style="height:{H*.5}px">', "on" if on else "")
            + it(m.symbol("wifi", H * .40, "#111")) + it(m.symbol("magnifyingglass", H * .38, "#111"))
            + it(f'<span style="font-weight:500">{m.esc(MENU_DAY)}&nbsp;&nbsp;9:41</span>') + '</div>')

MENU_DAY = "Mon 23 Nov"

def mac_set(m, loc, W, seed, out):
    global MENU_DAY
    MENU_DAY = seed.get("menu_day", MENU_DAY)
    T = W["mac"]; w, h = m.SIZE["mac"]
    X, Y, HW, FS, GFS = 170, 400, 1250, 150, 88
    GX = 1958             # the Cutling glyph's centre in the menu bar, where the picker hangs from
    drop = lambda key, width: m.win(m.cap(loc, key), GX - width * 0.22, 168, width, z=40)

    pages = {
        "01": head(m, T["1"], X, Y, HW, FS, GFS) + menubar(m) + drop("mac-picker", 1060),
        "02": head(m, T["2"], X, Y, HW, FS, GFS) + menubar(m) + drop("mac-form", 1120),
        "03": head(m, T["3"], X, Y, HW, FS, GFS) + menubar(m) + drop("mac-history", 1060),
    }
    d, _ = m.phone(m.cap(loc, "phone-grid"), 2250, 420, 560, bar="#F2F2F7", z=30)
    pages["04"] = (head(m, T["4"], X, Y, HW, FS, GFS) + menubar(m, on=False)
                   + m.win(m.cap(loc, "mac-sync"), 1500, 330, 1080, z=20) + d)
    icon = (m.REPO / "Cutling/Assets.xcassets/AppIcon-Default.imageset/AppIcon-Default.png").as_uri()
    pages["05"] = (menubar(m) + f'<img src="{icon}" style="position:absolute;left:{X}px;top:{Y-120}px;width:300px;border-radius:66px;box-shadow:0 20px 50px rgba(0,0,0,.15)">'
                   + head(m, T["5"], X, Y + 280, 1300, FS, GFS * 0.9) + drop("mac-picker", 1060))
    for n, body in pages.items():
        m.flatten(m.write_render(out / f"{n}.html", m.page(w, h, body, CSS), w, h))
