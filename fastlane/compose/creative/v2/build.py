#!/usr/bin/env python3
"""Cutling 2.0 store frames, three directions, iPhone + iPad + Mac (ASG167).

    python3 build.py [locale] [A|B|C ...] [--only iphone|ipad|mac] [--no-render]

Every frame is an HTML page written to out/<locale>/<dir>/<device>/NN.html and rendered by ../render.mjs to NN.png at
an App Store Connect size (iPhone 1320x2868, iPad 2064x2752, Mac 2880x1800). Frames 1 and 2 on iPhone and iPad are one
page twice as wide, cut in two, so the thing that crosses their seam lines up. Words come from words/<locale>.json and
the captures from that locale's folders (cap()), so a language is a words file plus its captures.
"""
import html, json, os, re, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[3]
SHOTS = REPO / "fastlane/screenshots"
MAC = REPO / "fastlane/screenshots_mac/raw"
EXTRA = HERE / "captures"                       # 2.0 captures that are not in the snapshot folders yet
RENDER = HERE.parent / "render.mjs"
SIZE = {"iphone": (1320, 2868), "ipad": (2064, 2752), "mac": (2880, 1800)}
# The iPhone Duo's two screens, which App Store Connect takes in one set (APP_IPHONE_DUO): each is laid out like the iPad,
# on a page 2064 CSS px wide and as tall as the screen's shape gives, then saved at the screen's own pixels.
DUO = {"duo-inner": (2007, 2853), "duo-outer": (1398, 2034)}
SCALE = {}
for _d, (_w, _h) in DUO.items():
    SIZE[_d] = (2064, round(2064 * _h / _w))
    SCALE[_d] = _w / 2064
GREEN = "#17B98A"

def cap(loc, key):
    """The real capture for a frame, per locale. Falls back to en-US only where a 2.0 capture does not exist yet."""
    m = {
        "phone-chat": SHOTS / loc / "iPhone 14 Pro Max-01_KeyboardInMessages.png",
        "phone-grid": SHOTS / loc / "iPhone 14 Pro Max-02_MainGrid.png",
        "phone-guide": SHOTS / loc / "iPhone 14 Pro Max-04_KeyboardGuide.png",
        "pad-chat": SHOTS / loc / "iPad Air 13-inch (M4)-01_KeyboardInMessages.png",
        "pad-grid": SHOTS / loc / "iPad Air 13-inch (M4)-02_MainGrid.png",
        "pad-guide": SHOTS / loc / "iPad Air 13-inch (M4)-04_KeyboardGuide.png",
        "duo-inner-guide": EXTRA / loc / "duo-inner-guide.png",
        "duo-inner-grid": EXTRA / loc / "duo-inner-grid.png",
        "duo-outer-guide": EXTRA / loc / "duo-outer-guide.png",
        "duo-outer-grid": EXTRA / loc / "duo-outer-grid.png",
        "mac-picker": MAC / loc / "01_Picker.png",
        "mac-history": MAC / loc / "02_History.png",
        "mac-sync": MAC / loc / "05_Sync.png",
        "mac-form": EXTRA / loc / "mac-fill-in-form.png",
    }
    p = m[key]
    if not p.exists():
        p = Path(str(p).replace(f"/{loc}/", "/en-US/"))
    return p.as_uri()

def sym(name):
    return (HERE / "sym" / f"{name}.png").as_uri()

def esc(s):
    return html.escape(s, quote=False)

def rich(s, chip_cls="chip", accent=None):
    """*x* accent, [x] chip, | line break, {cmd} keycaps. A hyphenated word (e-mail, Cutling-tastaturet, să-ți) is
    kept on one line, since Chrome would otherwise break after its hyphen."""
    out = esc(s)
    out = re.sub(r"[^\s\[\]|{}*<>]*\w-\w[^\s\[\]|{}*<>]*", lambda m: f'\x00{m.group(0)}\x01', out)
    out = re.sub(r"\*(.+?)\*", lambda m: f'<span class="acc">{m.group(1)}</span>', out)
    out = re.sub(r"\[(.+?)\]", lambda m: f'<span class="{chip_cls}">{m.group(1)}</span>', out)
    out = out.replace("{cmd}", '<span class="cmd"><b>⌘</b><b>⇧</b><b>V</b></span>').replace("|", "<br>")
    return out.replace("\x00", '<span style="white-space:nowrap">').replace("\x01", "</span>")

FACTS = json.loads((REPO / "docs/aso/screens-2.0/locale-facts.json").read_text())
RTL = {"ar-SA", "he", "ur-PK"}

# Per script: the serif the headline falls back to where New York has no glyphs, and the sans for everything else.
# New York covers Latin (Vietnamese, Turkish, Romanian included), Greek and Cyrillic.
SCRIPT_FONTS = {
    "ja": ('"Hiragino Mincho ProN"', '"Hiragino Sans"'), "zh-Hans": ('"Songti SC"', '"PingFang SC"'),
    "zh-Hant": ('"Songti TC"', '"PingFang TC"'), "ko": ("AppleMyungjo", '"Apple SD Gothic Neo"'),
    "ar-SA": ('"Al Nile"', '"Geeza Pro"'), "ur-PK": ('"Noto Nastaliq Urdu"', '"Noto Nastaliq Urdu"'),
    "he": ('"Times New Roman"', '"Arial Hebrew"'), "th": ("Sathu", "Thonburi"),
    "hi": ('"Devanagari Sangam MN"', '"Kohinoor Devanagari"'), "mr-IN": ('"Devanagari Sangam MN"', '"Kohinoor Devanagari"'),
    "bn-BD": ('"Bangla Sangam MN"', '"Kohinoor Bangla"'), "gu-IN": ('"Gujarati Sangam MN"', '"Kohinoor Gujarati"'),
    "pa-IN": ('"Gurmukhi Sangam MN"', '"Mukta Mahee"'), "kn-IN": ('"Kannada Sangam MN"', '"Noto Sans Kannada"'),
    "ml-IN": ('"Malayalam Sangam MN"', '"Malayalam MN"'), "or-IN": ('"Oriya Sangam MN"', '"Noto Sans Oriya"'),
    "ta-IN": ('"Tamil Sangam MN"', '"Tamil MN"'), "te-IN": ('"Telugu Sangam MN"', '"Kohinoor Telugu"'),
}

# Scripts whose marks reach far past New York's line box (Indic subjoined consonants and below-vowels, Thai below
# vowels, Odia's reph above): at New York's line-height a subjoined letter drops out of its chip, dark on the black
# ground, and touches the next line. Per locale: (headline line-height, chip padding below). A Thai chip in Sathu is
# 1.36 em tall with its padding, so Thai lines sit 1.42 em apart: at 1.3 a chip ran 7 to 9 px into the chip under it
# and a tone mark (ร้, ให้) met the chip above.
DEEP_MARKS = {"or-IN": (1.34, ".18em"), "kn-IN": (1.32, ".2em"), "te-IN": (1.32, ".2em"), "ml-IN": (1.3, ".16em"),
              "ta-IN": (1.28, ".12em"), "bn-BD": (1.3, ".16em"), "gu-IN": (1.28, ".14em"), "pa-IN": (1.28, ".14em"),
              "hi": (1.28, ".14em"), "mr-IN": (1.28, ".14em"), "th": (1.42, ".16em")}

def locale_css(loc):
    serif, sans = SCRIPT_FONTS.get(loc, ("", ""))
    s = f",{serif}" if serif else ""; ss = f",{sans}" if sans else ""
    css = (f'body{{font-family:SF{ss},-apple-system,sans-serif}} '
           f'.h,.h .chip{{font-family:NY{s},"Times New Roman",serif !important}}')
    if loc == "ko":
        # Korean wraps between words; Chrome's default breaks between any two syllables ("날|짜가", "없|어요",
        # "완료됐|어요"), so every line on the frame keeps its words whole: headline, subline, the note card and bubble.
        css += " body{word-break:keep-all}"
    if loc == "ja":
        # Japanese has no spaces, so Chrome breaks it between any two characters ("カットリン|グ", "発|送いたしま|す。");
        # auto-phrase breaks every line on the frame between phrases instead, and FIT_JS shrinks a headline whose widest
        # phrase is wider than it.
        css += " body{word-break:auto-phrase}"
    if loc in ("zh-Hans", "zh-Hant"):
        # Chrome breaks Chinese between any two characters and its auto-phrase covers Japanese only, so headlines keep
        # runs whole and ZH_WBR_JS opens a break at each chip's edge: lines break between phrases ("怡君您好，/您的訂單").
        css += " .h{word-break:keep-all}"
    if loc in DEEP_MARKS:
        lh, below = DEEP_MARKS[loc]
        css += f" .h{{line-height:{lh}}} .h .chip{{padding-bottom:{below}}}"
    if loc == "ur-PK":
        # Nastaliq sets each word on a slope, its letters reaching about half an em past New York's line box above and
        # below, so at the Latin line heights one line's descenders run into the chip under it. Headline, chips,
        # subline, note and bubble take the spacing Urdu print uses; headline and subline balance their lines, since
        # at that spacing a lone last word stands out; the drawn Mac form keeps a compact line box, so each label sits
        # above its field instead of behind it.
        css += (" .h{line-height:2;text-wrap:balance} .h .chip{padding:.22em .16em .38em}"
                " .s{line-height:1.9;text-wrap:balance} .note,.bubble{line-height:1.9} .win div{line-height:1.2}")
    return css

# Shrinks a text block's headline until the block fits its height and no word runs past its width. Under
# word-break:auto-phrase (Japanese) Chrome splits a phrase wider than the line instead of letting it overflow, so there
# the headline also shrinks until its min-content width, which is its widest phrase, fits the line.
FIT_JS = """<script>addEventListener('load',async()=>{await document.fonts.ready;
for(const el of document.querySelectorAll('[data-fit]')){const max=+el.dataset.fit,h=el.querySelector('.h');if(!h)continue;
const phrased=getComputedStyle(h).wordBreak==='auto-phrase',widest=()=>{h.style.width='min-content';const w=h.offsetWidth;h.style.width='';return w;};
let fs=parseFloat(h.style.fontSize);const over=()=>el.scrollHeight>max+1||h.scrollWidth>h.clientWidth+1||(phrased&&widest()>h.clientWidth+1);
while(over()&&fs>36){fs*=0.96;h.style.fontSize=fs+'px';}
const s=el.querySelector('.s');if(s){let ss=parseFloat(s.style.fontSize);while(el.scrollHeight>max+1&&ss>28){ss*=0.96;s.style.fontSize=ss+'px';}}}});</script>"""

ZH_WBR_JS = r"""<script>if(document.documentElement.lang.startsWith('zh'))for(const c of document.querySelectorAll('.h .chip')){const p=c.previousSibling,n=c.nextSibling,pc=p&&p.nodeType===3?p.data.slice(-1):'',nc=n&&n.nodeType===3?n.data[0]:'';if(p&&!/[「『（《〈【〔“‘(\[\s]/.test(pc))c.before(document.createElement('wbr'));if(n&&!/[，。、；：！？」』）》〉】〕”’)\],.!?:;…\s]/.test(nc))c.after(document.createElement('wbr'));}</script>"""

def page(w, h, body, css="", lang="en"):
    rtl = ' dir="rtl"' if lang in RTL else ""
    return f"""<!doctype html><html lang="{lang}"{rtl}><head><meta charset="utf-8">
<link rel="stylesheet" href="{(HERE / 'lib.css').as_uri()}"><style>
html,body{{width:{w}px;height:{h}px}} .stage{{width:{w}px;height:{h}px}} {css} {locale_css(lang)}</style></head>
<body><div class="stage">{body}</div>{ZH_WBR_JS}{FIT_JS}<script src="{(HERE.parent / 'ready.js').as_uri()}"></script></body></html>"""

# ---------------------------------------------------------------- devices

def sbar(w_s, color, dark_text, pad=False):
    """Status bar drawn over the capture's own (its clock reads 09.41 in some locales and its battery charges)."""
    fg = "#000" if dark_text else "#fff"
    if pad:
        h = w_s * 0.034; fs = w_s * 0.0125
        icons = icons_svg(fs * 4.2, fg)
        return (f'<div class="sb" style="height:{h}px;background:{color};padding:0 {w_s*.02}px">'
                f'<span class="t" style="font-size:{fs}px;color:{fg}">9:41</span>{icons}</div>')
    h = w_s * 0.118; fs = w_s * 0.041
    icons = icons_svg(fs * 3.0, fg)
    return (f'<div class="sb" style="height:{h}px;background:{color};padding:{h*.12}px {w_s*.075}px 0 {w_s*.115}px">'
            f'<span class="t" style="font-size:{fs}px;color:{fg};width:{w_s*.16}px">9:41</span>{icons}</div>')

def icons_svg(width, fg):
    h = width * 0.26
    return f'''<svg width="{width}" height="{h}" viewBox="0 0 78 20" fill="{fg}">
<rect x="0" y="13" width="4" height="7" rx="1.2"/><rect x="6" y="9" width="4" height="11" rx="1.2"/><rect x="12" y="5" width="4" height="15" rx="1.2"/><rect x="18" y="1" width="4" height="19" rx="1.2"/>
<path d="M37 4.2c3.6 0 6.9 1.4 9.3 3.7l1.6-1.7C45 3.4 41.2 1.8 37 1.8S29 3.4 26.1 6.2l1.6 1.7C30.1 5.6 33.4 4.2 37 4.2zm0 5c2.2 0 4.2.8 5.7 2.2l1.6-1.7C42.4 8 39.8 6.8 37 6.8s-5.4 1.2-7.3 2.9l1.6 1.7c1.5-1.4 3.5-2.2 5.7-2.2zm0 5c.9 0 1.7.3 2.3.9L37 17.5l-2.3-2.4c.6-.6 1.4-.9 2.3-.9z"/>
<rect x="53.5" y="3.5" width="21" height="13" rx="4" fill="none" stroke="{fg}" stroke-opacity=".4" stroke-width="1.6"/><rect x="56" y="6" width="16" height="8" rx="2.2"/><path d="M76.5 8v4c.9-.3 1.5-1.1 1.5-2s-.6-1.7-1.5-2z" fill-opacity=".45"/></svg>'''

def phone(src, x, y, w, *, bar="#FDFDFD", dark_text=True, aspect=2796/1290, rot=0, z=2, extra=""):
    b = w * 0.026; ws = w - 2 * b; hs = ws * aspect; h = hs + 2 * b
    R = w * 0.152
    isl = f'<div class="island" style="width:{ws*.265}px;height:{ws*.078}px;left:{(ws-ws*.265)/2}px;top:{ws*.027}px"></div>'
    t = f"transform:rotate({rot}deg);" if rot else ""
    return (f'<div class="dev shadow-soft" style="--w:{w}px;left:{x}px;top:{y}px;width:{w}px;height:{h}px;border-radius:{R}px;z-index:{z};{t}">'
            f'<div class="scr" style="left:{b}px;top:{b}px;width:{ws}px;height:{hs}px;border-radius:{R-b}px">'
            f'<img class="cap" src="{src}">{sbar(ws, bar, dark_text)}{isl}{extra}</div></div>'), h

def ipad(src, x, y, w, *, bar="#F2F2F7", dark_text=True, z=2, rot=0):
    b = w * 0.024; ws = w - 2 * b; hs = ws * 2752 / 2064; h = hs + 2 * b
    R = w * 0.05
    t = f"transform:rotate({rot}deg);" if rot else ""
    return (f'<div class="dev shadow-soft" style="--w:{w}px;left:{x}px;top:{y}px;width:{w}px;height:{h}px;border-radius:{R}px;z-index:{z};{t}">'
            f'<div class="scr" style="left:{b}px;top:{b}px;width:{ws}px;height:{hs}px;border-radius:{R-b}px">'
            f'<img class="cap" src="{src}">{sbar(ws, bar, dark_text, pad=True)}</div></div>'), h

def duo(src, x, y, w, *, screen="inner", z=2, rot=0):
    """An iPhone Duo around a capture of one screen: the inner one open like a book (a 2853 x 2007 capture, its fold
    down the middle) or the outer one (1398 x 2034), whose hinge edge has the squarer corners, as the device does."""
    inner = screen == "inner"
    aspect = 2007 / 2853 if inner else 2034 / 1398
    b = w * (0.016 if inner else 0.026); ws = w - 2 * b; hs = ws * aspect; h = hs + 2 * b
    if inner:
        R = w * 0.03
        outer_r, screen_r = f"{R}px", f"{R - b}px"
    else:
        R, r = w * 0.152, w * 0.045
        outer_r, screen_r = f"{r}px {R}px {R}px {r}px", f"{max(r - b, 2)}px {R - b}px {R - b}px {max(r - b, 2)}px"
    fold = ('<div style="position:absolute;left:50%;top:0;bottom:0;width:3px;margin-left:-1.5px;z-index:3;'
            'background:linear-gradient(90deg,rgba(0,0,0,.05),rgba(255,255,255,.08),rgba(0,0,0,.05))"></div>') if inner else ""
    t = f"transform:rotate({rot}deg);" if rot else ""
    return (f'<div class="dev shadow-soft" style="--w:{w}px;left:{x}px;top:{y}px;width:{w}px;height:{h}px;border-radius:{outer_r};z-index:{z};{t}">'
            f'<div class="scr" style="left:{b}px;top:{b}px;width:{ws}px;height:{hs}px;border-radius:{screen_r}">'
            f'<img class="cap" src="{src}">{fold}</div></div>'), h

def win(src, x, y, w, z=3, rot=0, extra=""):
    t = f"transform:rotate({rot}deg);" if rot else ""
    return f'<div class="win" style="left:{x}px;top:{y}px;width:{w}px;z-index:{z};{t}"><img src="{src}">{extra}</div>'

def history_label(loc, w):
    """The Mac history captures (720 x 1028) predate the localised "Clear History" button: every language's capture
    reads it in English. This paints the app's own string for that language over it, right-aligned where it sits."""
    strings = {}
    for c in (loc, loc.split("-")[0], {"no": "nb"}.get(loc, "")):
        f = REPO / "Cutling" / f"{c}.lproj" / "Localizable.strings"
        if c and f.exists():
            for m_ in re.finditer(r'^"Clear History"\s*=\s*"((?:[^"\\]|\\.)*)";', f.read_text(), re.M):
                strings["v"] = m_.group(1)
            break
    label = strings.get("v", "Clear History")
    k = w / 720.0
    return (f'<div style="position:absolute;left:{230*k}px;width:{412*k}px;top:{978*k}px;height:{36*k}px;background:#f8f8f8;'
            f'display:flex;align-items:center;justify-content:flex-end;font-family:SF;font-size:{21*k}px;color:#1d1d1f;'
            f'direction:ltr;white-space:nowrap">{esc(label)}</div>')

# ---------------------------------------------------------------- shared drawn parts

def symbol(name, size, color):
    return (f'<span class="sym" style="width:{size}px;height:{size}px;background:{color};'
            f'-webkit-mask-image:url({sym(name)})"></span>')

ICON = {"bank": ("banknote", "#34C759"), "home": ("house.fill", "#0088FF"), "sig": ("envelope.fill", "#CB30E0"),
        "wifi": ("wifi", "#FF8D28"), "booking": ("airplane", "#6155F5"), "phone": ("phone.fill", "#00C3D0"),
        "order": ("text.bubble.fill", "#00B8A3")}

def tag(seed, key, L, *, px, py, angle, z=1, dark=False, chips=False, fan=False, blank=False):
    """One punched tag whose hole sits on (px, py), turned about it like a fan deck on its rivet."""
    H = L * 0.34; hx = L * 0.08; hy = H / 2
    name, val = seed[key]
    s, col = ICON[key]
    fn = L * 0.066; fv = L * 0.046
    v = rich(val, "chip") if chips else esc(val)
    if blank:
        body = ""
    else:
        box = (f'left:{L*.37}px;right:{L*.04}px;top:{L*.028}px;justify-content:flex-start;gap:{L*.008}px' if fan
               else f'left:{L*.165}px;right:{L*.05}px;top:0;bottom:0;gap:{L*.014}px')
        body = (f'<div class="body" style="{box}">'
                f'<div class="nm" style="font-size:{fn}px;gap:{fn*.35}px">{symbol(s, fn*1.05, col)}{esc(name)}</div>'
                f'<div class="pv" style="font-size:{fv}px">{v}</div></div>')
    return (f'<div class="tag{" dark" if dark else ""}" style="--L:{L}px;--hx:{hx}px;--hy:{hy}px;left:{px-hx}px;top:{py-hy}px;width:{L}px;height:{H}px;'
            f'transform-origin:{hx}px {hy}px;transform:rotate({angle}deg);z-index:{z}">'
            f'<div class="ring" style="left:{hx-L*.036}px;top:{hy-L*.036}px;width:{L*.072}px;height:{L*.072}px"></div>{body}</div>')

def fillbar(parts, names, strings, x, y, w, *, pressed=None, chosen=None, z=4, radius=None, rtl=False, paste=True):
    """The Cutling keyboard during a fill-in, as 2.0 ships it (CutlingKeyboard/FillInPanel.swift, drawn after the 2.0
    capture ~/Downloads/cutling-2-walk/iphone/fillin_06): the sentence with its blank underlined and a close button,
    the "Type with Your Keyboard" key, the names used before and Paste in a three-column grid, then globe, delete,
    the field and the green return key. Measures are the 1398 px wide capture's, scaled to w.
    parts: [("t", text) | ("blank", label) | ("value", chosen value)]."""
    k = w / 1398.0
    H = 940 * k
    r = radius if radius is not None else 56 * k
    s = []
    for kind, t in parts:
        if kind == "t":
            s.append(esc(t))
        elif kind == "blank":
            s.append(f'<span style="color:#8a8d93;text-decoration:underline;text-decoration-thickness:{3*k}px;text-underline-offset:{8*k}px">{esc(t)}</span>')
        else:
            s.append(f'<span style="color:#00be86;text-decoration:underline;text-decoration-thickness:{4*k}px;text-underline-offset:{8*k}px">{esc(t)}</span>')
    flip = "transform:scaleX(-1);" if rtl else ""
    key = lambda inner, extra="": (f'<div style="background:#fff;border-radius:{28*k}px;display:flex;align-items:center;justify-content:center;'
                                   f'gap:{18*k}px;font-size:{46*k}px;color:#000;white-space:nowrap;overflow:hidden;{extra}">{inner}</div>')
    cells = []
    for i, n in enumerate(names[:3]):
        bg = "background:#c9cbd1;" if pressed == i else ""
        chk = symbol("checkmark", 40 * k, "#00be86") if chosen == i else ""
        cells.append(key(f"{esc(n)}{chk}", bg))
    if paste:
        cells.append(key(f'{symbol("doc.on.clipboard", 50*k, "#8a8d93")}{esc(strings["keyboard_paste"])}'))
    grid = (f'<div style="position:absolute;left:{39*k}px;right:{39*k}px;top:{343*k}px;display:grid;'
            f'grid-template-columns:repeat(3,1fr);grid-auto-rows:{130*k}px;gap:{18*k}px">{"".join(cells)}</div>')
    bottom = (f'<div style="position:absolute;left:{39*k}px;right:{39*k}px;top:{726*k}px;height:{131*k}px;display:flex;gap:{18*k}px">'
              + key(symbol("globe", 58 * k, "#000"), f"width:{156*k}px;flex:none")
              + key(symbol("delete.left", 58 * k, "#000"), f"width:{156*k}px;flex:none")
              + key("", "flex:1")
              + f'<div style="width:{275*k}px;flex:none;background:#00be86;border-radius:{28*k}px;display:flex;align-items:center;justify-content:center">'
                f'<span style="display:inline-flex;{flip}">{symbol("arrow.right", 52*k, "#fff")}</span></div></div>')
    return (f'<div class="abs shadow-soft" style="left:{x}px;top:{y}px;width:{w}px;height:{H}px;border-radius:{r}px;background:#e2e3e8;overflow:hidden;z-index:{z}">'
            f'<div style="position:absolute;left:{60*k}px;right:{150*k}px;top:{30*k}px;height:{80*k}px;display:flex;align-items:center;'
            f'font-size:{46*k}px;color:#000;white-space:nowrap;overflow:hidden"><span style="white-space:pre">{"".join(s)}</span></div>'
            f'<div style="position:absolute;{"left" if rtl else "right"}:{70*k}px;top:{50*k}px">{symbol("xmark", 40*k, "#000")}</div>'
            f'<div style="position:absolute;left:{39*k}px;right:{39*k}px;top:{168*k}px;height:{155*k}px;background:#fff;border-radius:{28*k}px;'
            f'display:flex;align-items:center;justify-content:center;gap:{30*k}px;color:#00be86;font-weight:600;font-size:{46*k}px;white-space:nowrap">'
            f'{symbol("keyboard", 66*k, "#00be86")}{esc(strings["keyboard_type_with_your_keyboard"])}</div>'
            f'{grid}{bottom}</div>'), H

def split_template(template, values, blank_key=None):
    """'Hi {name}, your order ships {date}.' -> parts for fillbar; {blank_key} stays a blank showing its label."""
    parts = []
    for i, piece in enumerate(re.split(r"(\{\w+\})", template)):
        if not piece:
            continue
        m = re.fullmatch(r"\{(\w+)\}", piece)
        if not m:
            parts.append(("t", piece))
        elif m.group(1) == blank_key:
            parts.append(("blank", values[m.group(1)]))
        else:
            parts.append(("t", values[m.group(1)]))
    return parts

def chips(template, values):
    """The headline: the template with every placeholder filled and turned into a green chip."""
    return re.sub(r"\{(\w+)\}", lambda m: f"[{values[m.group(1)]}]", template)

def filled(template, values):
    return re.sub(r"\{(\w+)\}", lambda m: values[m.group(1)], template)

def macform(cseed, strings, values, x, y, w, *, z=3, dark=True, rtl=False):
    """The Mac picker's fill-in form (Cutling/Mac/MacPickerView.swift), drawn after the 2.0 capture
    captures/en-US/mac-fill-in-form.png at its 1070 x 1026 px (2x) measures, scaled to w."""
    k = w / 1070.0; H = 1026 * k
    P = (dict(bg="#2a2928", field="#191919", fb="#3a3938", text="#ffffff", sub="#9e9d9d", lab="#dcdcdc", chip="#3a3938",
              prev="#302f2e", line="#3f3e3d", icon="#c8c8c8", sel="#3f6e5e")
         if dark else
         dict(bg="#ececec", field="#ffffff", fb="#d4d4d4", text="#1d1d1f", sub="#6e6e73", lab="#3a3a3c", chip="#dedede",
              prev="#e2e2e2", line="#d0d0d0", icon="#5a5a5e", sel="#b9e6d6"))
    side = "right" if rtl else "left"; other = "left" if rtl else "right"
    def field(top, inner):
        return (f'<div style="position:absolute;left:{24*k}px;right:{24*k}px;top:{top*k}px;height:{50*k}px;background:{P["field"]};'
                f'border-radius:{10*k}px;box-shadow:inset 0 0 0 {1.5*k}px {P["fb"]};display:flex;align-items:center;padding:0 {12*k}px;'
                f'font-size:{26*k}px;color:{P["text"]}">{inner}</div>')
    def label(top, t):
        return (f'<div style="position:absolute;{side}:{24*k}px;top:{(top-14)*k}px;font-size:{22*k}px;font-weight:600;color:{P["lab"]}">{esc(t)}</div>')
    ch = cseed["plan_choices"]
    chips_ = "".join(
        f'<div style="height:{46*k}px;padding:0 {20*k}px;border-radius:{23*k}px;display:flex;align-items:center;font-size:{26*k}px;'
        f'background:{"#19b98a" if i == 1 else P["chip"]};color:{"#fff" if i == 1 else P["text"]}">{esc(c)}</div>' for i, c in enumerate(ch))
    btn = lambda t, bg, fg: (f'<div style="height:{48*k}px;padding:0 {24*k}px;border-radius:{10*k}px;background:{bg};color:{fg};'
                             f'display:flex;align-items:center;font-size:{26*k}px">{esc(t)}</div>')
    tools = "".join(symbol(n, 28 * k, P["icon"]) for n in ("plus", "gear", "trash", "questionmark.circle"))
    return (f'<div class="win" style="left:{x}px;top:{y}px;width:{w}px;height:{H}px;z-index:{z}">'
            f'<div style="position:absolute;inset:0;background:{P["bg"]};border-radius:{20*k}px;overflow:hidden;box-shadow:inset 0 0 0 {1*k}px rgba(255,255,255,.08)">'
            f'<div style="position:absolute;left:{27*k}px;right:{27*k}px;top:0;height:{73*k}px;display:flex;align-items:center;gap:{16*k}px;font-size:{26*k}px;color:{P["sub"]}">'
            f'{symbol("magnifyingglass", 26*k, P["sub"])}{esc(strings["mac_search_cutlings"])}</div>'
            f'<div style="position:absolute;left:0;right:0;top:{73*k}px;height:{1.5*k}px;background:{P["line"]}"></div>'
            f'<div style="position:absolute;{side}:{27*k}px;top:{96*k}px;display:flex;align-items:center;gap:{18*k}px;font-size:{28*k}px;font-weight:700;color:{P["text"]}">'
            f'{symbol("envelope", 32*k, "#19b98a")}{esc(cseed["reply_name"])}</div>'
            + label(164, cseed["name_label"])
            + field(185, f'<span style="background:{P["sel"]};padding:0 {2*k}px">{esc(values["name"])}</span>')
            + label(268, cseed["plan_label"])
            + field(289, esc(values["plan"]))
            + f'<div style="position:absolute;{side}:{24*k}px;top:{347*k}px;display:flex;gap:{12*k}px">{chips_}</div>'
            f'<div style="position:absolute;left:{24*k}px;right:{24*k}px;top:{414*k}px;min-height:{62*k}px;background:{P["prev"]};border-radius:{10*k}px;'
            f'padding:{14*k}px {16*k}px;font-size:{24*k}px;line-height:1.35;color:{P["sub"]}">{esc(filled(cseed["mac_reply"], values))}</div>'
            f'<div style="position:absolute;{other}:{24*k}px;top:{894*k}px;display:flex;gap:{16*k}px">'
            + btn(strings["mac_cancel"], P["chip"], P["text"]) + btn(strings["mac_paste_button"], "#19b98a", "#fff") + '</div>'
            f'<div style="position:absolute;left:0;right:0;top:{966*k}px;height:{1.5*k}px;background:{P["line"]}"></div>'
            f'<div style="position:absolute;{side}:{30*k}px;top:{984*k}px;display:flex;gap:{30*k}px">{tools}</div>'
            f'<div style="position:absolute;{other}:{28*k}px;top:{984*k}px">{symbol("power", 28*k, P["icon"])}</div>'
            f'</div></div>'), H

def fillpanel(seed, x, y, w, *, chosen=0, z=4, radius=None, keys=True, unit=None):
    """Directions A and B (English only): the 2.0 fill-in bar for the English seed's reply."""
    strings = FACTS["en-US"]
    names = seed["names"]
    sent = seed["sent"]
    before, _, after = sent.partition(names[0])
    parts = [("t", before), ("blank", seed["blank"]), ("t", after)]
    return fillbar(parts, names, strings, x, y, w, pressed=chosen, z=z, radius=radius)

def bubble(text, x, y, fs, *, mine=True, maxw=None, z=4):
    bg, fg = ("#0A84FF", "#fff") if mine else ("#E9E9EB", "#000")
    mw = f"max-width:{maxw}px;" if maxw else ""
    return (f'<div class="abs" style="left:{x}px;top:{y}px;{mw}background:{bg};color:{fg};font-size:{fs}px;line-height:1.25;'
            f'padding:{fs*.42}px {fs*.7}px;border-radius:{fs*.9}px;z-index:{z};letter-spacing:-.01em">{esc(text)}</div>')

JOBS, POST = [], []

def write_render(path_html, html_text, w, h, scale=1):
    """Writes the page and queues it; run_jobs() renders the queue through one Chrome. A page laid out at (w, h) is
    saved at (w, h) * scale pixels."""
    path_html.parent.mkdir(parents=True, exist_ok=True)
    path_html.write_text(html_text)
    png = path_html.with_suffix(".png")
    JOBS.append({"html": str(path_html), "png": str(png), "w": round(w * scale), "h": round(h * scale), "scale": scale})
    return png

def split_pair(png, out1, out2, w):
    """Frames 1 and 2 are two clips of the same double-width page (Chrome's PNGs are RGB, no alpha to flatten)."""
    job = next(j for j in JOBS if j["png"] == str(png))
    k = job.get("scale", 1)
    job["crops"] = [[str(out1), 0, round(w * k)], [str(out2), round(w * k), round(w * k)]]

def flatten(png):
    return png

def run_jobs():
    if "--no-render" in sys.argv or not JOBS:
        return
    jf = HERE / "out" / f"jobs-{os.getpid()}.json"   # one queue per build, so builds running side by side never share one
    jf.write_text(json.dumps(JOBS))
    r = subprocess.run(["bun", str(HERE / "render-batch.mjs"), str(jf)], cwd=HERE)
    for c in POST:
        subprocess.run(c, check=True)
    if r.returncode:
        raise SystemExit("some frames failed to render")

# ---------------------------------------------------------------- directions
import importlib  # noqa: E402

def main():
    """python3 build.py [locale ...|--store] [A|B|C ...] [--only iphone|ipad|mac] [--no-render] [--publish]
    --store: every store language that has a words file (the 50 App Store Connect locales)."""
    args = [a for a in sys.argv[1:] if not a.startswith("--") and a not in ("iphone", "ipad", "mac", *DUO)]
    dirs = [a for a in args if a in ("A", "B", "C")] or ["A", "B", "C"]
    locs = [a for a in args if a not in ("A", "B", "C")]
    if "--store" in sys.argv:
        locs = sorted(p.stem for p in (HERE / "words").glob("*.json") if p.stem in FACTS)
    locs = locs or ["en-US"]
    only = sys.argv[sys.argv.index("--only") + 1] if "--only" in sys.argv else None
    mod = sys.modules[__name__]
    for loc in locs:
        words = json.loads((HERE / "words" / f"{loc}.json").read_text())
        for d in dirs:
            if d in words:
                importlib.import_module(f"directions.{d}").build(mod, loc, words, only)
    run_jobs()
    if "--publish" in sys.argv:
        for loc in locs:
            publish(loc)


# The direction on the store pages. Its frames are copied to fastlane/frames/<locale>/<device>-NN.png, the one folder
# the upload lanes (Fastfile upload_screenshots, upload_screenshots_mac) and fastlane/readback.rb read.
STORE_DIRECTION = "C"

def publish(loc):
    import shutil
    dst = REPO / "fastlane/frames" / loc
    dst.mkdir(parents=True, exist_ok=True)
    for old in dst.glob("*.png"):
        old.unlink()
    for dev in ("iphone", "ipad", "mac", *DUO):
        for f in sorted((HERE / "out" / loc / STORE_DIRECTION / dev).glob("[0-9][0-9].png")):
            shutil.copy(f, dst / f"{dev}-{f.name}")

def publish_duo(loc):
    """Copies this language's iPhone Duo frames to fastlane/frames/<locale>/duo-<screen>-NN.png, at most 10 (App Store
    Connect's limit for the one APP_IPHONE_DUO set both screens share). Frames 4 to 6 show captures of the app, and a
    language without its own Duo captures would show English ones, so it gets only frames 1 to 3, which are drawn in its
    words, on both screens; a language with them gets the inner screen's six and the outer screen's 4 to 6."""
    import shutil
    dst = REPO / "fastlane/frames" / loc
    dst.mkdir(parents=True, exist_ok=True)
    for old in dst.glob("duo-*.png"):
        old.unlink()
    own = all((EXTRA / loc / f"duo-{s}-{k}.png").exists() for s in ("inner", "outer") for k in ("grid", "guide"))
    pick = {"duo-inner": ["01", "02", "03", "04", "05", "06"], "duo-outer": ["04", "05", "06"]} if own \
        else {"duo-inner": ["01", "02", "03"], "duo-outer": ["01", "02", "03"]}
    for dev, frames in pick.items():
        for n in frames:
            f = HERE / "out" / loc / STORE_DIRECTION / dev / f"{n}.png"
            if f.exists():
                shutil.copy(f, dst / f"{dev}-{n}.png")

if __name__ == "__main__":
    if "--publish-duo" in sys.argv:
        locs = [a for a in sys.argv[1:] if not a.startswith("--")] or sorted(p.name for p in (HERE / "out").iterdir() if (p / STORE_DIRECTION / "duo-inner").is_dir())
        for loc in locs:
            publish_duo(loc)
        sys.exit(0)
    main()
