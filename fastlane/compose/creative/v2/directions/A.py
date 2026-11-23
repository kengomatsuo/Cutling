"""A. Fan deck: the app icon's punched tags made real, riveted on one ring, on the icon's green.
Leads with everything you keep; frames 1 and 2 share one fan whose top tag runs across the seam into the phone."""

INK = "#05291F"
from pathlib import Path
NOISE = (Path(__file__).resolve().parents[1] / "noise.png").as_uri()
CSS = f"""
.stage{{background:url({NOISE}),radial-gradient(120% 85% at 22% 8%,#46A88A 0%,#38977A 45%,#26785F 100%)}}
.hl{{position:absolute;color:{INK};font-weight:800;letter-spacing:-.028em;line-height:1.02}}
.hl .acc{{color:#fff}}
.sub{{position:absolute;color:{INK};opacity:.78;font-weight:500;letter-spacing:-.01em;line-height:1.22}}
.cmd{{display:inline-flex;gap:.12em;vertical-align:.04em}}
.cmd b{{display:inline-flex;align-items:center;justify-content:center;min-width:.95em;height:.95em;padding:0 .12em;border-radius:.16em;
  background:#fff;color:{INK};font-weight:600;font-size:.82em;box-shadow:0 .05em 0 rgba(0,0,0,.18)}}
.chip{{display:inline-block;border-radius:.25em;padding:0 .18em;background:#D6F5EA;color:#08664B;font-weight:600}}
.grain{{position:absolute;inset:0;z-index:50;pointer-events:none;opacity:.9;background-image:url({NOISE})}}
"""

def head(m, t, x, y, w, fs, sfs, gap=None):
    gap = gap if gap is not None else fs * 0.36
    sub = f'<div class="sub" style="position:static;margin-top:{gap}px;width:{w*0.92}px;font-size:{sfs}px">{m.esc(t["s"])}</div>' if t.get("s") else ""
    return (f'<div class="abs" style="left:{x}px;top:{y}px;width:{w}px;z-index:60">'
            f'<div class="hl" style="position:static;font-size:{fs}px">{m.rich(t["h"])}</div>{sub}</div>')

def fan(m, seed, keys, L, px, py, angles, *, chips_key="order", blank=False):
    parts = []
    for i, (k, a) in enumerate(zip(keys, angles)):
        parts.append(m.tag(seed, k, L, px=px, py=py, angle=a, z=10 + i, chips=(k == chips_key), dark=(k == "booking"), fan=(i < len(keys) - 1), blank=blank and i < len(keys) - 1))
    R = L * 0.05
    parts.append(f'<div class="rivet" style="left:{px-R/2}px;top:{py-R/2}px;width:{R}px;height:{R}px;z-index:40"></div>')
    return "".join(parts)

def build(m, loc, words, only):
    W = words["A"]; seed = words["seed"]
    out = m.HERE / "out" / loc / "A"
    for dev in ("iphone", "ipad", "mac"):
        if only and dev != only:
            continue
        (out / dev).mkdir(parents=True, exist_ok=True)
        {"iphone": phone_set, "ipad": pad_set, "mac": mac_set}[dev](m, loc, W, seed, out / dev)

# ------------------------------------------------------------------ iPhone 1320 x 2868

def phone_set(m, loc, W, seed, out):
    T = W["iphone"]; w, h = m.SIZE["iphone"]
    X, Y, HW, FS, SFS = 96, 190, 1130, 128, 50

    # 1 + 2: one fan; the top tag (the bank number) crosses into frame 2 and under the phone that typed it
    keys = ["booking", "wifi", "order", "sig", "home", "bank"]
    body = head(m, T["1"], X, Y, HW, FS, SFS)
    body += fan(m, seed, keys, 1700, 150, 2700, [-84, -70, -56, -41, -25, -9])
    dev, _ = m.phone(m.cap(loc, "phone-chat"), w + 250, 700, 980, z=30)
    body += dev + head(m, T["2"], w + X, Y, HW, FS, SFS)
    pair = m.write_render(out / "pair-12.html", m.page(2 * w, h, body, CSS), 2 * w, h)
    m.split_pair(pair, out / "01.png", out / "02.png", w)

    # 3: the reply with a blank, the fill-in screen, the message it sent
    body = head(m, T["3"], X, Y, HW, FS, SFS)
    body += m.tag(seed, "order", 1260, px=170, py=1020, angle=-4, z=5, chips=True)
    body += f'<div class="rivet" style="left:{170-31}px;top:{1020-31}px;width:62px;height:62px;z-index:41"></div>'
    p, ph = m.fillpanel(seed, 70, 1360, 1180, chosen=0, radius=70)
    body += p
    body += m.bubble(seed["sent"], 330, 1360 + ph + 90, 66, maxw=900)
    m.flatten(m.write_render(out / "03.html", m.page(w, h, body, CSS), w, h))

    # 4: the library, with a thick deck behind it
    body = head(m, T["4"], X, Y, HW, FS, SFS)
    deck = ["home", "bank", "sig", "wifi", "booking", "phone", "home", "bank", "sig", "wifi", "booking", "phone"]
    body += fan(m, seed, deck, 1300, 120, 2760, [-90 + i * 6.2 for i in range(len(deck))], blank=True)
    dev, _ = m.phone(m.cap(loc, "phone-grid"), 420, 760, 860, bar="#F2F2F7", z=30)
    body += dev
    m.flatten(m.write_render(out / "04.html", m.page(w, h, body, CSS), w, h))

    # 5: the same cutlings on iPad and Mac
    body = head(m, T["5"], X, Y, HW, FS, SFS)
    d1, _ = m.ipad(m.cap(loc, "pad-grid"), 330, 760, 1180, z=10)
    body += d1 + m.win(m.cap(loc, "mac-picker"), 60, 1330, 640, z=20)
    d2, _ = m.phone(m.cap(loc, "phone-grid"), 700, 1560, 560, bar="#F2F2F7", z=30)
    body += d2
    m.flatten(m.write_render(out / "05.html", m.page(w, h, body, CSS), w, h))

    # 6: paid once; the setup guide's Try It page, where the keyboard types the saved address
    body = head(m, T["6"], X, Y, HW, FS, SFS)
    dev, _ = m.phone(m.cap(loc, "phone-guide"), 200, 820, 920, bar="#000", dark_text=False, aspect=2868 / 1320, z=30)
    body += dev
    body += m.tag(seed, "home", 760, px=-40, py=2440, angle=-12, z=40)
    m.flatten(m.write_render(out / "06.html", m.page(w, h, body, CSS), w, h))

# ------------------------------------------------------------------ iPad 2064 x 2752

def pad_set(m, loc, W, seed, out):
    T = W.get("ipad", W["iphone"]); w, h = m.SIZE["ipad"]
    X, Y, HW, FS, SFS = 140, 170, 1700, 132, 54

    keys = ["booking", "wifi", "order", "sig", "home", "bank"]
    body = head(m, T["1"], X, Y, 1500, FS, SFS)
    body += fan(m, seed, keys, 2100, 200, 2640, [-70, -58, -46, -34, -22, -9])
    dev, _ = m.ipad(m.cap(loc, "pad-chat"), w + 300, 620, 1640, bar="#F7F6F9", z=30)
    body += dev + head(m, T["2"], w + X, Y, HW, FS, SFS)
    pair = m.write_render(out / "pair-12.html", m.page(2 * w, h, body, CSS), 2 * w, h)
    m.split_pair(pair, out / "01.png", out / "02.png", w)

    body = head(m, T["3"], X, Y, HW, FS, SFS)
    body += m.tag(seed, "order", 1700, px=260, py=1000, angle=-3, z=5, chips=True)
    body += f'<div class="rivet" style="left:{260-42}px;top:{1000-42}px;width:84px;height:84px;z-index:41"></div>'
    p, ph = m.fillpanel(seed, 160, 1400, 1520, chosen=0, radius=80)
    body += p + m.bubble(seed["sent"], 760, 1400 + ph + 100, 78, maxw=1200)
    m.flatten(m.write_render(out / "03.html", m.page(w, h, body, CSS), w, h))

    body = head(m, T["4"], X, Y, HW, FS, SFS)
    deck = ["home", "bank", "sig", "wifi", "booking", "phone", "home", "bank", "sig", "wifi", "booking", "phone"]
    body += fan(m, seed, deck, 1700, 120, 2700, [-90 + i * 6.2 for i in range(len(deck))], blank=True)
    dev, _ = m.ipad(m.cap(loc, "pad-grid"), 560, 700, 1420, z=30)
    body += dev
    m.flatten(m.write_render(out / "04.html", m.page(w, h, body, CSS), w, h))

    body = head(m, T["5"], X, Y, HW, FS, SFS)
    d1, _ = m.ipad(m.cap(loc, "pad-grid"), 500, 700, 1460, z=10)
    body += d1 + m.win(m.cap(loc, "mac-picker"), 110, 1150, 760, z=20)
    d2, _ = m.phone(m.cap(loc, "phone-grid"), 1310, 1460, 600, bar="#F2F2F7", z=30)
    body += d2
    m.flatten(m.write_render(out / "05.html", m.page(w, h, body, CSS), w, h))

    body = head(m, T["6"], X, Y, HW, FS, SFS)
    dev, _ = m.ipad(m.cap(loc, "pad-guide"), 330, 720, 1400, bar="#000", dark_text=False, z=30)
    body += dev + m.tag(seed, "home", 1000, px=-60, py=2420, angle=-12, z=40)
    m.flatten(m.write_render(out / "06.html", m.page(w, h, body, CSS), w, h))

# ------------------------------------------------------------------ Mac 2880 x 1800

def mac_set(m, loc, W, seed, out):
    T = W["mac"]; w, h = m.SIZE["mac"]
    X, Y, HW, FS, SFS = 170, 180, 1300, 140, 54

    body = head(m, T["1"], X, Y, HW, FS, SFS)
    body += fan(m, seed, ["booking", "wifi", "order", "sig", "home", "bank"], 1300, 160, 1990, [-44, -36, -28, -20, -12, -4])
    body += m.win(m.cap(loc, "mac-picker"), 1700, 120, 1040)
    m.flatten(m.write_render(out / "01.html", m.page(w, h, body, CSS), w, h))

    body = head(m, T["2"], X, Y, HW, FS, SFS)
    body += m.tag(seed, "order", 1250, px=300, py=1360, angle=-5, z=5, chips=True)
    body += f'<div class="rivet" style="left:{300-31}px;top:{1360-31}px;width:62px;height:62px;z-index:41"></div>'
    body += m.win(m.cap(loc, "mac-form"), 1520, 180, 1240)
    m.flatten(m.write_render(out / "02.html", m.page(w, h, body, CSS), w, h))

    body = head(m, T["3"], X, Y, HW, FS, SFS)
    body += m.tag(seed, "wifi", 1150, px=300, py=1330, angle=-6, z=5)
    body += m.win(m.cap(loc, "mac-history"), 1700, 120, 1040)
    m.flatten(m.write_render(out / "03.html", m.page(w, h, body, CSS), w, h))

    body = head(m, T["4"], X, Y, HW, FS, SFS)
    body += m.win(m.cap(loc, "mac-sync"), 1560, 160, 1180, z=5)
    d1, _ = m.ipad(m.cap(loc, "pad-grid"), 170, 760, 1080, z=10)
    d2, _ = m.phone(m.cap(loc, "phone-grid"), 1120, 900, 470, bar="#F2F2F7", z=20)
    body += d1 + d2
    m.flatten(m.write_render(out / "04.html", m.page(w, h, body, CSS), w, h))

    body = head(m, T["5"], X, Y, HW, FS, SFS)
    body += fan(m, seed, ["booking", "wifi", "order", "sig", "home", "bank"], 1600, 1350, 2000, [-86, -73, -60, -47, -33, -19])
    body += f'<img src="{(m.REPO / "fastlane/compose/mac/icon.png").as_uri()}" style="position:absolute;left:{X-20}px;top:1180px;width:300px">'
    m.flatten(m.write_render(out / "05.html", m.page(w, h, body, CSS), w, h))
