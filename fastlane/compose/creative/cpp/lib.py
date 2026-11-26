"""Shared parts for the panorama sets (ASG250, ASG252): locale data, devices, drawn 2.0 screens, and the renderer that
lays one page N frames wide and saves each frame as its own clip of it.

Every set is one HTML page as wide as all its frames (laid out by a direction module), rendered once per frame with the
page shifted by that frame's offset, so whatever crosses a seam lines up to the pixel. Right-to-left languages run the
page from the right: frame 1 is the right-hand slice, and every element is placed with `right:` instead of `left:` and
turned the other way, so the picture reads in the order the App Store shows it in."""
import html, json, os, re, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
V2 = HERE.parent / "v2"
sys.path.insert(0, str(V2))
import build as m   # noqa: E402  (the 2.0 store frames' helpers: fonts per script, status bar, fit script, captures)

REPO = m.REPO
SHOTS = m.SHOTS
EXTRA = m.EXTRA
FACTS = m.FACTS
RTL = m.RTL
SIZE = {"iphone": (1320, 2868), "ipad": (2064, 2752)}
STORE = sorted(p.stem for p in (V2 / "words").glob("*.json") if p.stem in FACTS)   # the 50 store languages
ENGLISH = ["en-US", "en-GB", "en-AU", "en-CA"]
FALLBACKS = []   # (locale, what, from) every time a capture is taken from another language


def esc(s):
    return html.escape(s, quote=False)


# ------------------------------------------------------------------ locale data

def lproj(loc):
    """The app's own strings for a store locale: the snapshot seed (Home Address, its value...) and UI words."""
    for c in (loc, loc.split("-")[0], {"no": "nb"}.get(loc, "")):
        f = REPO / "Cutling" / f"{c}.lproj" / "Localizable.strings"
        if c and f.exists():
            out = {}
            for k, v in re.findall(r'^"((?:[^"\\]|\\.)*)"\s*=\s*"((?:[^"\\]|\\.)*)";', f.read_text(), re.M):
                un = lambda s: s.replace('\\n', '\n').replace('\\"', '"').replace("\\\\", "\\")
                out[un(k)] = un(v)
            return out
    return {}


EN = lproj("en-US")


def S(loc, key):
    return lproj_cache(loc).get(key) or EN.get(key) or key


_LP = {}
def lproj_cache(loc):
    if loc not in _LP:
        _LP[loc] = lproj(loc)
    return _LP[loc]


ICONS = {"home": ("house.fill", "#0088FF"), "sig": ("envelope.fill", "#CB30E0"), "bank": ("banknote", "#34C759"),
         "wifi": ("wifi", "#FF8D28"), "social": ("person.crop.circle.fill", "#FF3B30"), "phone": ("phone.fill", "#00C3D0"),
         "booking": ("airplane", "#6155F5"), "meeting": ("video.fill", "#FF2D55"), "order": ("shippingbox.fill", "#00B8D9"),
         "date": ("calendar", "#FF8D28"), "note": ("textformat", "#CB30E0"), "email": ("at", "#00B8E6"),
         "doc": ("doc.on.doc", "#34C759"), "reply": ("text.bubble.fill", "#00B8A3")}


def seed(loc):
    """The snapshot seed as the app writes it in this language (the same cutlings the real 02 and 04 captures show)."""
    s = lambda k: S(loc, k)
    addr = s("123 Main Street, Apt 4B\nNew York, NY 10001")
    sig = s("Best regards,\nAlex Chen\nalex@example.com")
    return {
        "home": (s("Home Address"), addr),
        "sig": (s("Email Signature"), sig),
        "bank": (s("Bank Account"), s("IBAN: DE89 3704 0044 0532 0130 00")),
        "wifi": (s("Wi-Fi Password"), "c0ff33-Sh0p-2024!"),
        "social": (s("Social Bio"), s("Designer & developer. Building things that make life simpler.")),
        "phone": (s("Phone Number"), "+1 (555) 234-5678"),
        "booking": (s("Booking Ref"), "FLT-2026-XKCD42"),
        "meeting": (s("Meeting Link"), "https://meet.example.com/alex"),
    }


def words(loc):
    """Direction C's words (cseed: the reply, names, note) and this folder's words for the language."""
    w = json.loads((V2 / "words" / f"{loc}.json").read_text())
    p = HERE / "words" / f"{loc}.json"
    own = json.loads(p.read_text()) if p.exists() else {}
    return w, own


def cap(loc, key):
    """A real capture for this language; falls back to en-US and records it."""
    names = {"phone-grid": "iPhone 14 Pro Max-02_MainGrid.png", "phone-guide": "iPhone 14 Pro Max-04_KeyboardGuide.png",
             "pad-grid": "iPad Air 13-inch (M4)-02_MainGrid.png", "pad-guide": "iPad Air 13-inch (M4)-04_KeyboardGuide.png"}
    extra = {"phone-grid2": "release_room_0_grid.png", "phone-note": "release_note_3_written.png",
             "phone-formatted": "release_keyboard_4_formatted.png", "mac-form": "mac-fill-in-form.png"}
    mac = {"mac-picker": "01_Picker.png", "mac-history": "02_History.png", "mac-sync": "05_Sync.png"}
    if key in names:
        p = SHOTS / loc / names[key]; alt = SHOTS / "en-US" / names[key]
    elif key in extra:
        p = EXTRA / loc / extra[key]; alt = EXTRA / "en-US" / extra[key]
    else:
        p = m.MAC / loc / mac[key]; alt = m.MAC / "en-US" / mac[key]
    if not p.exists():
        FALLBACKS.append((loc, key, "en-US"))
        p = alt
    return p.as_uri()


def sym(name):
    p = HERE / "sym" / f"{name}.png"
    return p.as_uri()


def symbol(name, size, color, extra=""):
    return (f'<span class="sym" style="width:{size}px;height:{size}px;background:{color};'
            f'-webkit-mask-image:url({sym(name)});{extra}"></span>')


# ------------------------------------------------------------------ placement (mirrored for right-to-left)

class Pano:
    """One page N frames wide. x is measured from the left of the page in reading order: frame i spans
    [i*w, (i+1)*w). For a right-to-left language every x is measured from the right instead."""
    def __init__(self, loc, dev, n):
        self.loc, self.dev, self.n = loc, dev, n
        self.w, self.h = SIZE[dev]
        self.W = self.w * n
        self.rtl = loc in RTL
        self.pad = dev == "ipad"
        self.parts = []

    def fx(self, i):
        return i * self.w

    def pos(self, x, y, rot=0, w=None, z=None, origin=None):
        side = "right" if self.rtl else "left"
        r = -rot if self.rtl else rot
        s = f"position:absolute;{side}:{x:.1f}px;top:{y:.1f}px;"
        if w is not None:
            s += f"width:{w:.1f}px;"
        if r:
            s += f"transform:rotate({r}deg);"
        if origin:
            s += f"transform-origin:{origin};"
        if z is not None:
            s += f"z-index:{z};"
        return s

    def add(self, s):
        self.parts.append(s)

    def frame_x(self, i):
        """Where frame i's clip starts on the page as laid out on screen (left to right)."""
        return (self.n - 1 - i) * self.w if self.rtl else i * self.w


def render(pano, css, out_dir, *, lang=None, body_class="", extra_head=""):
    """Writes the page once and queues one clip per frame (01.png ...) through v2's one-Chrome batch renderer."""
    out_dir.mkdir(parents=True, exist_ok=True)
    lang = lang or pano.loc
    page = m.page(pano.W, pano.h, "".join(pano.parts), css + SHIFT_CSS, lang)
    if pano.rtl:   # the viewport of a right-to-left root opens on the page's right edge; only the stage is RTL
        page = page.replace(' dir="rtl"', "", 1).replace('<div class="stage">', '<div class="stage" dir="rtl">', 1)
    page = page.replace("<body>", f'<body class="{body_class}">', 1).replace("</head>", extra_head + SHIFT_JS + "</head>", 1)
    p = out_dir / "pano.html"
    p.write_text(page)
    only = os.environ.get("FRAMES")   # FRAMES=2,5: render just those frames again
    for i in range(pano.n):
        if only and str(i + 1) not in only.split(","):
            continue
        m.JOBS.append({"html": f"{p}?x={pano.frame_x(i)}", "png": str(out_dir / f"{i + 1:02d}.png"), "w": pano.w, "h": pano.h})
    return p


SHIFT_CSS = " html,body{overflow:hidden} .stage{position:absolute!important;left:0;top:0}"
SHIFT_JS = """<script>addEventListener('DOMContentLoaded',()=>{const x=+new URLSearchParams(location.search).get('x')||0;
const s=document.querySelector('.stage');s.style.transform=`translateX(${-x}px)`;document.body.style.width=s.style.width;});</script>"""


def run():
    m.run_jobs()
    m.JOBS.clear()


# ------------------------------------------------------------------ devices

def phone(inner, w, *, aspect=2868 / 1320, bar="#FDFDFD", dark_text=True, island=True, bezel="#0b0b0c", sbar=True):
    """An iPhone around a screen (an <img> capture or a drawn screen), poster style: the device's own box, placed by
    the caller. Status bar drawn over the capture's own (clock 9:41, no charging battery)."""
    b = w * .0245; ws = w - 2 * b; hs = ws * aspect
    R = w * .1585
    isl = (f'<div style="position:absolute;width:{ws*.265}px;height:{ws*.078}px;left:{(ws-ws*.265)/2}px;top:{ws*.027}px;'
           f'background:#000;border-radius:999px;z-index:6"></div>') if island else ""
    sb = m.sbar(ws, bar, dark_text) if sbar else ""
    return (f'<div class="pdev" style="width:{w}px;height:{hs+2*b}px;border-radius:{R}px;padding:{b}px;background:{bezel}">'
            f'<div class="pscr" style="width:{ws}px;height:{hs}px;border-radius:{R-b}px">{inner}{sb}{isl}</div></div>'), hs + 2 * b


def ipad(inner, w, *, bar="#F2F2F7", dark_text=True, sbar=True):
    b = w * .024; ws = w - 2 * b; hs = ws * 2752 / 2064
    R = w * .052
    sb = m.sbar(ws, bar, dark_text, pad=True) if sbar else ""
    return (f'<div class="pdev" style="width:{w}px;height:{hs+2*b}px;border-radius:{R}px;padding:{b}px;background:#0b0b0c">'
            f'<div class="pscr" style="width:{ws}px;height:{hs}px;border-radius:{R-b*1.1}px">{inner}{sb}</div></div>'), hs + 2 * b


def img(src):
    return f'<img src="{src}" style="position:absolute;left:0;top:0;width:100%;display:block">'


def native(inner, nw, nh, ws):
    """A drawn screen laid out at the capture's own pixels (nw x nh), scaled to the device's screen width ws."""
    return (f'<div style="position:absolute;left:0;top:0;width:{nw}px;height:{nh}px;transform:scale({ws/nw});'
            f'transform-origin:0 0;background:#fff;overflow:hidden">{inner}</div>')


def phone_drawn(inner, w, **k):
    ws = w - 2 * w * .0245
    return phone(native(inner, 1320, 2868, ws), w, **k)


def ipad_drawn(inner, w, **k):
    ws = w - 2 * w * .024
    return ipad(native(inner, 2064, 2752, ws), w, **k)


def phone_cap(src, w, aspect, bar="#F2F2F7", dark_text=True):
    return phone(img(src), w, aspect=aspect, bar=bar, dark_text=dark_text)


# ------------------------------------------------------------------ drawn 2.0 screens

def fill_panel(parts, names, F, width, k, *, pressed=None, cols=3, rtl=False, radius=None):
    """The Cutling keyboard during a fill-in (2.0's FillInPanel.swift, after the build's capture fillin_06): the
    sentence with its blank, the close button, "Type with Your Keyboard", the names used before and Paste, then globe,
    delete, the field and the green return key. k scales the capture's measures (1398 px wide phone); width can be
    wider (iPad), where the rows stretch."""
    s = []
    for kind, t in parts:
        if kind == "t":
            s.append(esc(t))
        elif kind == "blank":
            s.append(f'<span style="color:#8a8d93;text-decoration:underline;text-decoration-thickness:{3*k}px;text-underline-offset:{8*k}px">{esc(t)}</span>')
        else:
            s.append(f'<span style="color:#00be86;text-decoration:underline;text-decoration-thickness:{4*k}px;text-underline-offset:{8*k}px">{esc(t)}</span>')
    key = lambda inner, extra="": (f'<div style="background:#fff;border-radius:{28*k}px;display:flex;align-items:center;justify-content:center;'
                                   f'gap:{18*k}px;font-size:{46*k}px;color:#000;white-space:nowrap;overflow:hidden;{extra}">{inner}</div>')
    cells = [key(esc(n), "background:#c9cbd1;" if pressed == i else "") for i, n in enumerate(names[:cols * 2 - 1])]
    cells.append(key(f'{symbol("doc.on.clipboard", 50*k, "#8a8d93")}{esc(F["keyboard_paste"])}'))
    H = 940 * k
    flip = "transform:scaleX(-1);" if rtl else ""
    r = radius if radius is not None else 56 * k
    return (f'<div style="position:relative;width:{width}px;height:{H}px;border-radius:{r}px {r}px 0 0;background:#e2e3e8;overflow:hidden">'
            f'<div style="position:absolute;inset-inline-start:{60*k}px;inset-inline-end:{150*k}px;top:{30*k}px;height:{80*k}px;display:flex;align-items:center;'
            f'font-size:{46*k}px;color:#000;white-space:nowrap;overflow:hidden"><span style="white-space:pre">{"".join(s)}</span></div>'
            f'<div style="position:absolute;inset-inline-end:{70*k}px;top:{50*k}px">{symbol("xmark", 40*k, "#000")}</div>'
            f'<div style="position:absolute;left:{39*k}px;right:{39*k}px;top:{168*k}px;height:{155*k}px;background:#fff;border-radius:{28*k}px;'
            f'display:flex;align-items:center;justify-content:center;gap:{30*k}px;color:#00be86;font-weight:600;font-size:{46*k}px;white-space:nowrap">'
            f'{symbol("keyboard", 66*k, "#00be86")}{esc(F["keyboard_type_with_your_keyboard"])}</div>'
            f'<div style="position:absolute;left:{39*k}px;right:{39*k}px;top:{343*k}px;display:grid;grid-template-columns:repeat({cols},1fr);'
            f'grid-auto-rows:{130*k}px;gap:{18*k}px">{"".join(cells)}</div>'
            f'<div style="position:absolute;left:{39*k}px;right:{39*k}px;top:{726*k}px;height:{131*k}px;display:flex;gap:{18*k}px">'
            + key(symbol("globe", 58 * k, "#000"), f"width:{156*k}px;flex:none")
            + key(symbol("delete.left", 58 * k, "#000"), f"width:{156*k}px;flex:none")
            + key("", "flex:1")
            + f'<div style="width:{275*k}px;flex:none;background:#00be86;border-radius:{28*k}px;display:flex;align-items:center;justify-content:center">'
              f'<span style="display:inline-flex;{flip}">{symbol("arrow.right", 52*k, "#fff")}</span></div></div></div>'), H


def messages(pad, contact, thread, panel_html, panel_h, *, field="", rtl=False):
    """A Messages conversation drawn at the capture's pixels (iPhone 1320 x 2868, iPad 2064 x 2752): the contact at
    the top, the thread above the message field, and a keyboard (Cutling's, drawn) at the bottom.
    thread: [(mine, text)]."""
    W, H = (2064, 2752) if pad else (1320, 2868)
    u = 0.8 if pad else 1.0           # iPad UI type, drawn larger than the device's own so it reads in the frame
    fs = 52 * u * (1.25 if pad else 1)
    top = 150 if pad else 190
    av = 150 * u * 1.3
    head = (f'<div style="position:absolute;left:0;right:0;top:{top}px;display:flex;flex-direction:column;align-items:center;gap:{14*u}px">'
            f'<div style="width:{av}px;height:{av}px;border-radius:50%;background:linear-gradient(180deg,#A5ABB8,#858B98);color:#fff;'
            f'display:flex;align-items:center;justify-content:center;font-size:{av*.46}px;font-weight:600">{esc(contact[:1])}</div>'
            f'<div style="font-size:{40*u*1.2}px;color:#000;font-weight:500;background:#F1F1F3;border-radius:999px;padding:{6*u}px {22*u}px">{esc(contact)}</div></div>')
    field_h = 112 * (0.8 if pad else 1)
    fy = H - panel_h - field_h - 34
    bub = "".join(
        f'<div style="align-self:{"flex-end" if mine else "flex-start"};max-width:{W*.7}px;background:{"#0A84FF" if mine else "#E9E9EB"};'
        f'color:{"#fff" if mine else "#000"};font-size:{fs}px;line-height:1.25;padding:{fs*.42}px {fs*.68}px;border-radius:{fs*.9}px">{esc(t)}</div>'
        for mine, t in thread)
    th = (f'<div style="position:absolute;left:{36}px;right:{36}px;bottom:{H-fy+40}px;display:flex;flex-direction:column;gap:{fs*.35}px">{bub}</div>')
    fld = (f'<div style="position:absolute;left:{40}px;right:{40}px;top:{fy}px;height:{field_h}px;display:flex;align-items:center;gap:{24}px">'
           f'<div style="width:{field_h*.86}px;height:{field_h*.86}px;border-radius:50%;background:#F1F1F3;display:flex;align-items:center;justify-content:center;flex:none">'
           f'{symbol("plus", field_h*.38, "#8a8d93")}</div>'
           f'<div style="flex:1;height:{field_h}px;border-radius:{field_h/2}px;box-shadow:inset 0 0 0 3px #E1E1E4;display:flex;align-items:center;'
           f'padding:0 {fs*.6}px;font-size:{fs}px;color:#000">{esc(field)}<span style="width:4px;height:{fs*1.1}px;background:#0A84FF;margin-inline-start:2px"></span></div></div>')
    pnl = f'<div style="position:absolute;left:0;right:0;bottom:0">{panel_html}</div>'
    return f'<div dir="{"rtl" if rtl else "ltr"}" style="position:absolute;inset:0;background:#fff;font-family:inherit">{head}{th}{fld}{pnl}</div>'


def note_page(pad, lines, *, toolbar=True, rtl=False):
    """2.0's text page, drawn after captures/en-US/release_note_3_written.png at its pixels: the sheet with back,
    undo and the green check, the text with its formatting, and the formatting bar (italic, underline, strikethrough,
    highlight, code, link, list). lines: [(kind, html)] where kind is 'b' (bold), 'p', 'li'."""
    W, H = (2064, 2752) if pad else (1320, 2868)
    u = 0.8 if pad else 1.0
    fs = 50 * u * (1.5 if pad else 1)
    circ = lambda inner, bg="#F4F4F6": (f'<div style="width:{110*u}px;height:{110*u}px;border-radius:50%;background:{bg};display:flex;'
                                        f'align-items:center;justify-content:center;box-shadow:0 2px 8px rgba(0,0,0,.08)">{inner}</div>')
    flip = "transform:scaleX(-1)" if rtl else ""
    bar = (f'<div style="position:absolute;left:{50*u}px;right:{50*u}px;top:{190*u if not pad else 110}px;display:flex;justify-content:space-between;align-items:center">'
           + circ(symbol("chevron.left", 46 * u, "#000", flip))
           + f'<div style="display:flex;gap:{24*u}px">' + circ(symbol("arrow.uturn.backward", 46 * u, "#000", flip))
           + circ(symbol("checkmark", 50 * u, "#fff"), "#19C08A") + '</div></div>')
    body = []
    for kind, t in lines:
        if kind == "b":
            body.append(f'<div style="font-weight:700">{t}</div>')
        elif kind == "li":
            body.append(f'<div style="display:flex;gap:{fs*.45}px"><span>•</span><span>{t}</span></div>')
        else:
            body.append(f'<div>{t}</div>')
    txt = (f'<div style="position:absolute;left:{70*u}px;right:{70*u}px;top:{(330*u) if not pad else 280}px;font-size:{fs}px;line-height:1.42;color:#000">'
           + "".join(body) + '</div>')
    tb = ""
    if toolbar:
        icons = ["italic", "underline", "strikethrough", "highlighter", "chevron.left.forwardslash.chevron.right", "link"]
        cells = "".join(f'<div style="flex:1;display:flex;justify-content:center">{symbol(i, 60*u, "#1c1c1e")}</div>' for i in icons)
        cells += (f'<div style="width:{120*u}px;height:{120*u}px;border-radius:50%;background:#19C08A;display:flex;align-items:center;justify-content:center;flex:none">'
                  f'{symbol("list.bullet", 56*u, "#fff")}</div>')
        tb = (f'<div style="position:absolute;left:{36*u}px;right:{36*u}px;bottom:{110*u}px;height:{150*u}px;border-radius:999px;background:rgba(250,250,252,.96);'
              f'box-shadow:0 6px 30px rgba(0,0,0,.12),inset 0 0 0 2px rgba(0,0,0,.04);display:flex;align-items:center;padding:0 {16*u}px" dir="ltr">{cells}</div>')
    return (f'<div dir="{"rtl" if rtl else "ltr"}" style="position:absolute;inset:0;background:#E9E9EC">'
            f'<div style="position:absolute;left:0;right:0;top:{150*u if not pad else 80}px;bottom:0;background:#fff;border-radius:{70*u}px {70*u}px 0 0">'
            f'</div>{bar}{txt}{tb}</div>')


def chips_text(template, values):
    return re.sub(r"\{(\w+)\}", lambda mm: values[mm.group(1)], template)


def split_template(template, values, blank_key):
    return m.split_template(template, values, blank_key)


def cutling_keyboard(pad, tiles, *, pressed=None, header="Add from Clipboard", rtl=False):
    """Cutling's keyboard as the 01 capture draws it (1290 px wide: header at 140, tiles 618 x 186 on a 205 px pitch,
    the bottom row at 774, globe and mic under it), at the screen's width; iPad: five columns, as its 01 capture.
    tiles: [(icon key, name, preview)]."""
    W = 2064 if pad else 1320
    k = (W / 1290) if not pad else 1.0
    cols = 5 if pad else 2
    th, pitch, top = (150, 165, 250) if pad else (186 * k, 205 * k, 248 * k)
    H = (940 if pad else 1128 * k)
    fs_n, fs_p, ic = (36, 30, 38) if pad else (40 * k, 34 * k, 46 * k)
    cells = []
    for i, (icon, name, prev) in enumerate(tiles[:cols * 3]):
        s, col = ICONS[icon]
        bg = "#c9cbd1" if pressed == i else "#FDFDFD"
        cells.append(f'<div style="background:{bg};border-radius:{30*k}px;padding:{26*k}px {28*k}px;overflow:hidden;height:{th}px;box-sizing:border-box">'
                     f'<div style="display:flex;align-items:center;gap:{14*k}px;font-weight:600;font-size:{fs_n}px;color:#000;white-space:nowrap">{symbol(s, ic, col)}{esc(name)}</div>'
                     f'<div style="margin-top:{14*k}px;font-size:{fs_p}px;color:#8a8a8e;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{esc(prev)}</div></div>')
    grid = (f'<div style="position:absolute;left:{18*k}px;right:{18*k}px;top:{top}px;height:{(774*k if not pad else 740)-top-6}px;overflow:hidden">'
            f'<div style="display:grid;grid-template-columns:repeat({cols},1fr);gap:{18*k}px {18*k}px;grid-auto-rows:{th}px">{"".join(cells)}</div></div>')
    hdr = (f'<div style="position:absolute;left:0;right:0;top:{(140*k if not pad else 150) - 40}px;height:80px;display:flex;align-items:center;justify-content:center;'
           f'gap:{20*k}px;font-size:{46*k if not pad else 36}px;color:#000">{symbol("doc.on.clipboard", 50*k if not pad else 40, "#000")}{esc(header)}</div>'
           f'<div style="position:absolute;inset-inline-end:{58*k}px;top:{(140*k if not pad else 150) - 25}px">{symbol("arrow.up.right.square", 50*k if not pad else 40, "#000")}</div>')
    by = 774 * k if not pad else 760
    bh = 128 * k if not pad else 130
    keyb = lambda inner, w: (f'<div style="{"flex:1" if w is None else f"width:{w}px;flex:none"};height:{bh}px;background:#FDFDFD;border-radius:{30*k}px;'
                             f'display:flex;align-items:center;justify-content:center">{inner}</div>')
    row = (f'<div style="position:absolute;left:{18*k}px;right:{18*k}px;top:{by}px;display:flex;gap:{18*k}px">'
           + (keyb(symbol("globe", 50, "#000"), 140) if pad else "")
           + keyb(symbol("delete.left", 60 * k if not pad else 44, "#000"), 152 * k if not pad else 140) + keyb("", None)
           + keyb(symbol("return", 60 * k if not pad else 44, "#000"), 269 * k if not pad else 180) + '</div>')
    foot = "" if pad else (f'<div style="position:absolute;left:{85*k}px;top:{1045*k}px">{symbol("globe", 78*k, "#000")}</div>'
                           f'<div style="position:absolute;right:{85*k}px;top:{1040*k}px">{symbol("mic", 78*k, "#000")}</div>')
    return (f'<div style="position:relative;width:{W}px;height:{H}px;background:#DFE1E5;border-radius:{90*k}px {90*k}px 0 0;overflow:hidden">'
            f'{hdr}{grid}{row}{foot}</div>'), H


def form_page(pad, loc):
    """A web form (a booking page in Safari) whose address field Cutling has just filled, the Cutling keyboard under it
    with the Home Address key pressed. Labels are the app's own names for the details, values its seed."""
    W, H = (2064, 2752) if pad else (1320, 2868)
    sd = seed(loc)
    rtl = loc in RTL
    tiles = [("home", sd["home"][0], sd["home"][1].split("\n")[0]), ("bank", *sd["bank"]), ("booking", *sd["booking"]),
             ("phone", *sd["phone"]), ("sig", sd["sig"][0], sd["sig"][1].split("\n")[0]), ("wifi", *sd["wifi"]),
             ("social", *sd["social"]), ("meeting", *sd["meeting"])]
    kb, kh = cutling_keyboard(pad, tiles, pressed=0, header=S(loc, "Add from Clipboard"), rtl=rtl)
    u = 1.0 if not pad else 0.9
    fs = 48 * u
    def field(label, value, filled=False, focus=False):
        vv = (f'<span style="background:#D6F5EA;color:#08664B;border-radius:8px;padding:2px 6px">{esc(value)}</span>' if filled else
              f'<span style="color:#b0b0b5">{esc(value)}</span>')
        ring = "box-shadow:inset 0 0 0 4px #0A84FF;" if focus else "box-shadow:inset 0 0 0 2px #D8D8DC;"
        return (f'<div style="margin-top:{34*u}px"><div style="font-size:{fs*.78}px;color:#6e6e73;margin-bottom:{12*u}px">{esc(label)}</div>'
                f'<div style="{ring}border-radius:{22*u}px;padding:{24*u}px {28*u}px;font-size:{fs}px;line-height:1.3;color:#000;white-space:pre-line">{vv}</div></div>')
    addr = sd["home"][1]
    body = (field(sd["home"][0], addr, filled=True, focus=True) + field(sd["phone"][0], sd["phone"][1])
            + field(sd["booking"][0], sd["booking"][1]))
    url = (f'<div style="position:absolute;left:{40*u}px;right:{40*u}px;top:{(170 if not pad else 90)}px;height:{96*u}px;border-radius:{48*u}px;background:#EDEDF0;'
           f'display:flex;align-items:center;justify-content:center;gap:12px;font-size:{40*u}px;color:#3a3a3c" dir="ltr">{symbol("lock.fill", 34*u, "#3a3a3c")}booking.example.com</div>')
    form = (f'<div dir="{"rtl" if rtl else "ltr"}" style="position:absolute;left:{60*u}px;right:{60*u}px;top:{(330 if not pad else 230)}px">'
            f'<div style="height:{14*u}px;width:{260*u}px;border-radius:7px;background:#1c1c1e;margin-bottom:{30*u}px"></div>{body}</div>')
    return (f'<div style="position:absolute;inset:0;background:#fff">{url}{form}'
            f'<div style="position:absolute;left:0;right:0;bottom:0">{kb}</div></div>')
