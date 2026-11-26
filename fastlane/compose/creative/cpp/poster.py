"""Direction "Don't type it" (ASG148's poster, d2/) brought to 2.0 and laid out as one picture across every frame.

The main store page (ASG252): eight frames, flat mint, a giant condensed headline per frame, and the app's own keys at
poster size. Frames 1 and 2 are a picture on their own (search shows the preview, then only those two): the address
as the loose keys it costs to type, and Cutling's one key for it lying across their seam. From there a piece of the
app lies across every seam, so the eight read as one sheet: the big key (1|2, 2|3), then a key, a key, the reply key,
the sent message, the date card and the Mac's three keys.

What is real and what is drawn, per language:
  3 Done.          04_KeyboardGuide, real (2.0's Try It page with the address Cutling typed)
  4 Keep it all.   02_MainGrid, real; en-US uses the 2.0 grid that reads 5,000 Cutlings (captures/en-US)
  5 Write it once. en-US: 2.0's text page, real (release_note_3_written); other languages: that page drawn with the
                   language's own note, since the capture exists in English only
  6 Leave a blank. drawn: Messages and the fill-in keyboard, from the app's own strings for the language
  8 Every device.  02_MainGrid on iPad and iPhone and the Mac picker, real
Keys, cards and the message bubble are drawn from the app's seed strings (Cutling/<lproj>/Localizable.strings)."""
import re
import lib
from lib import esc, symbol

CSS = """
:root{--mint:#2FE6A7;--side:#0A9469;--ink:#06140F}
.stage{background:var(--mint);color:var(--ink)}
.col{position:absolute;z-index:40}
.h1{font-family:system-ui,-apple-system;font-weight:900;font-variation-settings:"wdth" 50;letter-spacing:-.008em;line-height:.84;white-space:nowrap;color:var(--ink)}
.sub{font-family:system-ui,-apple-system;font-weight:700;letter-spacing:-.017em;line-height:1.08;color:var(--ink)}
.fine{font-family:system-ui,-apple-system;font-weight:600;letter-spacing:-.01em;line-height:1.15;color:var(--ink);opacity:.72}
.pdev{position:absolute;box-sizing:border-box;box-shadow:0 0 0 5px #2a2d2c,0 0 0 9px #8f9694,0 60px 120px rgba(0,60,40,.45)}
.pscr{position:relative;overflow:hidden;background:#fff}
.key{position:absolute;background:#fff;border-radius:calc(var(--w)*.0694);width:var(--w);height:calc(var(--w)*.3035);color:#000;
  box-shadow:0 calc(var(--w)*.0153) 0 var(--side),0 calc(var(--w)*.04) calc(var(--w)*.053) rgba(0,70,48,.36)}
.key .ic{position:absolute;inset-inline-start:calc(var(--w)*.05);top:calc(var(--w)*.052)}
.key b{position:absolute;inset-inline-start:calc(var(--w)*.152);inset-inline-end:calc(var(--w)*.05);top:calc(var(--w)*.05);font-weight:650;font-size:calc(var(--w)*.073);line-height:1.1;letter-spacing:-.02em;white-space:nowrap;overflow:hidden}
.key i{position:absolute;inset-inline-start:calc(var(--w)*.052);inset-inline-end:calc(var(--w)*.05);top:calc(var(--w)*.165);font-size:calc(var(--w)*.0612);line-height:1.2;font-style:normal;letter-spacing:-.01em;color:#8A8A8E;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.key i u{text-decoration:none;background:#D6F5EA;color:#08664B;border-radius:.3em;padding:0 .25em}
.lk{position:absolute;width:140px;height:172px;border-radius:23px;background:#fff;box-shadow:0 8px 0 var(--side),0 20px 24px rgba(0,80,54,.28);
  font-family:system-ui;font-weight:400;font-size:96px;line-height:164px;text-align:center;color:#000;direction:ltr}
.ring{position:absolute;border-radius:50%;background:rgba(6,20,15,.14);box-shadow:0 0 0 calc(var(--d)*.052) rgba(6,20,15,.92),0 0 0 calc(var(--d)*.26) rgba(6,20,15,.09)}
.card{position:absolute;background:#fff;color:#000;box-sizing:border-box;letter-spacing:-.02em;
  box-shadow:0 calc(var(--w)*.0153) 0 var(--side),0 calc(var(--w)*.04) calc(var(--w)*.053) rgba(0,70,48,.36)}
.card .tok{background:#D6F5EA;color:#08664B;border-radius:.25em;padding:0 .2em;font-weight:600;white-space:nowrap;display:inline-flex;align-items:center;gap:.2em}
.card .val{background:#00A878;color:#fff;border-radius:.2em;padding:0 .16em;font-weight:650}
.bub{position:absolute;background:#0A84FF;color:#fff;letter-spacing:-.01em;line-height:1.22;box-shadow:0 40px 70px rgba(0,70,48,.32)}
.win{position:absolute;filter:drop-shadow(0 40px 60px rgba(0,60,40,.35)) drop-shadow(0 0 1px rgba(0,0,0,.3))}
.win img{display:block;width:100%}
.mk{position:absolute;width:var(--s);height:var(--s);border-radius:calc(var(--s)*.18);background:#fff;display:flex;align-items:center;justify-content:center;
  font-family:system-ui;font-size:calc(var(--s)*.5);color:#000;box-shadow:0 calc(var(--s)*.05) 0 var(--side),0 calc(var(--s)*.12) calc(var(--s)*.14) rgba(0,70,48,.3)}
"""

# Per script: the heavy face the headline falls back to where SF has no glyphs (SF's width axis covers Latin, Greek and
# Cyrillic only, so other scripts set wide and the fit script shrinks them to the frame).
HEAD_FONT = {
    "ja": '"Hiragino Sans"', "zh-Hans": '"PingFang SC"', "zh-Hant": '"PingFang TC"', "ko": '"Apple SD Gothic Neo"',
    "th": '"Thonburi"', "hi": '"Kohinoor Devanagari"', "mr-IN": '"Kohinoor Devanagari"', "bn-BD": '"Kohinoor Bangla"',
    "gu-IN": '"Kohinoor Gujarati"', "te-IN": '"Kohinoor Telugu"', "ta-IN": '"Tamil Sangam MN"', "kn-IN": '"Kannada Sangam MN"',
    "ml-IN": '"Malayalam Sangam MN"', "pa-IN": '"Gurmukhi Sangam MN"', "or-IN": '"Oriya Sangam MN"', "ur-PK": '"Noto Nastaliq Urdu"',
    "ar-SA": '"SF Arabic"', "he": '"SF Hebrew"'}

# Line heights where a script's marks reach past SF's condensed line box (Indic subjoined letters and vowel signs,
# Thai tone marks, Arabic and Urdu letters on a slope); Latin, Greek and Cyrillic keep the poster's tight .84.
HEAD_LH = {**{l: (1.22, 1.3) for l in ("hi", "mr-IN", "bn-BD", "gu-IN", "pa-IN", "or-IN", "kn-IN", "te-IN", "ml-IN", "ta-IN")},
           "th": (1.3, 1.35), "ar-SA": (1.12, 1.3), "he": (.98, 1.15), "ur-PK": (1.7, 1.8),
           "ja": (1.08, 1.2), "zh-Hans": (1.08, 1.2), "zh-Hant": (1.08, 1.2), "ko": (1.08, 1.2), "vi": (1.0, 1.15)}

FIT = """<script>addEventListener('load',async()=>{await document.fonts.ready;
for(const c of document.querySelectorAll('.col')){const max=+c.dataset.w,maxh=+c.dataset.h;
for(const el of c.querySelectorAll('.h1,.sub,.fine')){let fs=parseFloat(el.style.fontSize);const min=fs*.18;
const wide=()=>[...el.querySelectorAll('.ln')].reduce((a,l)=>Math.max(a,l.getBoundingClientRect().width),0)||el.scrollWidth;
while((wide()>max+1)&&fs>min){fs*=.97;el.style.fontSize=fs+'px';}}
const h=c.querySelector('.h1');let fs=parseFloat(h.style.fontSize);while(c.scrollHeight>maxh&&fs>60){fs*=.97;h.style.fontSize=fs+'px';}}});</script>"""


def lines(s):
    return "<br>".join(f'<span class="ln">{esc(x)}</span>' for x in s.split("|"))


def head(P, i, t, *, size, top, sub=118, maxh=1100, fine=None):
    """The headline column of frame i: the giant line, the line under it, and an optional fine line."""
    M = 120 if P.pad else 92
    col = (f'<div class="h1" style="font-size:{size}px">{lines(t["h"])}</div>'
           f'<div class="sub" style="font-size:{sub}px;margin-top:{size*.12}px;white-space:nowrap">{lines(t["s"])}</div>')
    if fine:
        col += f'<div class="fine" style="font-size:{sub*.64}px;margin-top:{sub*.3}px;white-space:nowrap">{lines(fine)}</div>'
    return f'<div class="col" data-w="{P.w-2*M}" data-h="{maxh}" style="{P.pos(P.fx(i)+M-8, top, w=P.w-2*M)}">{col}</div>'


def key(P, x, y, w, icon, title, preview, rot=0, z=10, preview_html=None):
    s, col = lib.ICONS[icon]
    return (f'<div class="key" style="--w:{w}px;{P.pos(x, y, rot, z=z)}">'
            f'<span class="ic">{symbol(s, w*.08, col)}</span><b>{esc(title)}</b><i>{preview_html or esc(preview)}</i></div>')


def first_line(v):
    return v.split("\n")[0]


def ring(P, x, y, d, z=30):
    return f'<div class="ring" style="--d:{d}px;width:{d}px;height:{d}px;{P.pos(x, y, z=z)}"></div>'


def letter_keys(P, i, text, x0, y0, per_row, pitch=152, row=204, size=1.0):
    """The address as the loose keys it costs to type, one per character and one for the return, set by hand."""
    seed = 7
    def rnd():
        nonlocal seed
        seed = (seed * 16807) % 2147483647
        return seed / 2147483647
    rows = []
    for part in text.split("\n"):
        cur = ""
        for word in re.split(r"(\s+)", part):
            if len(cur) + len(word.rstrip()) > per_row and cur.strip():
                rows.append(cur)
                cur = word.lstrip()
            else:
                cur += word
        rows.append(cur + "\n")
    rows[-1] = rows[-1].rstrip("\n")
    out, n = [], 0
    for j, r in enumerate(rows):
        for c, ch in enumerate(r):
            x = x0 + c * pitch * size + (rnd() - .5) * 10
            y = y0 + j * row * size + (rnd() - .5) * 12
            rot = (rnd() - .5) * 9
            inner = symbol("return", 66 * size, "#000", "margin-top:%dpx" % (52 * size)) if ch == "\n" else esc("" if ch == " " else ch)
            out.append(f'<div class="lk" style="{P.pos(P.fx(i)+x, y, rot)};width:{140*size}px;height:{172*size}px;font-size:{96*size}px;'
                       f'line-height:{164*size}px;border-radius:{23*size}px">{inner}</div>')
            n += 1
    return "".join(out), n, len(rows)


def num(n, own):
    """The key count in the digits the language writes its address with (Arabic, Bengali... set "digits")."""
    d = own.get("digits", "0123456789")
    return "".join(d[int(c)] for c in str(n))


def key_count(addr):
    return len(addr)   # every character, and one key for the return between the two lines


def screens(loc, w, cs, F, own, seedv):
    """The drawn and real screens this set shows, per device."""
    rtl = loc in lib.RTL
    names = cs["names"]
    day = F["weekday_tue_nov24"]
    bar = lib.split_template(cs["reply"], {"name": cs["name_label"], "date": day}, "name")
    ask = own["demo"]["ask"]
    note = own["demo"]["note"]
    hi = own["demo"].get("note_hi", "")
    def mark(t):
        return esc(t).replace(esc(hi), f'<span style="background:#F7C8F0;border-radius:6px;padding:0 4px">{esc(hi)}</span>', 1) if hi else esc(t)
    note_lines = [("b", esc(note[0])), ("p", esc(note[1]))] + [("li", mark(t)) for t in note[2:]]
    return dict(bar=bar, names=names, ask=ask, note_lines=note_lines, rtl=rtl)


def build(loc, dev, out_dir):
    W, own = lib.words(loc)
    cs = W["cseed"]; F = lib.FACTS[loc]; T = own["main"]
    P = lib.Pano(loc, dev, 8)
    pad = P.pad
    sd = lib.seed(loc)
    sc = screens(loc, P.w, cs, F, own, sd)
    addr = sd["home"][1]
    n = key_count(addr)
    t = {k: dict(v) for k, v in T.items()}
    t["1"]["s"] = t["1"]["s"].replace("{n}", own.get("digits", "0123456789") and num(n, own))
    names = cs["names"]
    day = F["weekday_tue_nov24"]
    reply_filled = lib.chips_text(cs["reply"], {"name": names[0], "date": day})
    reply_preview = (esc(cs["reply"].split("{name}")[0]) + f'<u>{esc(cs["name_label"])}</u>'
                     + esc(lib.chips_text(cs["reply"].split("{name}", 1)[1], {"date": "…"}).split("…")[0]) + "…")
    today_tok = F["product_terms"].get("Today’s Date", "Today’s Date")
    before, _, after = cs["delivered"].partition("{date}")

    if not pad:
        HS, HS1 = 520, 520
        # 1 | 2: the address as keys; Cutling's one key for it lies across the seam
        P.add(head(P, 0, t["1"], size=HS, top=150))
        per = 10
        keys_html, nk, nrows = letter_keys(P, 0, addr, 88, 1600, per, size=1.0 if len(addr) <= 44 else .9)
        P.add(keys_html)
        P.add(head(P, 1, t["2"], size=HS1, top=150, maxh=860))
        hn, hv = sd["home"]
        P.add(key(P, 1262, 1040, 1580, "home", hn, first_line(hv) + "…", rot=-5, z=12))
        P.add(ring(P, 2380, 1090, 250, z=13))
        P.add(key(P, 1690, 1730, 1220, "sig", sd["sig"][0], first_line(sd["sig"][1]) + "…", rot=2, z=9))
        P.add(key(P, 1630, 2100, 1220, "wifi", sd["wifi"][0], sd["wifi"][1], rot=-2.5, z=8))
        P.add(key(P, 1700, 2470, 1220, "meeting", sd["meeting"][0], sd["meeting"][1], rot=3, z=7))
        # 3: Done. The setup guide's Try It page, the address Cutling typed (real, this language)
        P.add(head(P, 2, t["3"], size=HS1, top=150, maxh=820))
        ph, _ = lib.phone_cap(lib.cap(loc, "phone-guide"), 1060, 2796 / 1290, bar="#000", dark_text=False)
        P.add(f'<div style="{P.pos(2770, 1010, z=5)}">{ph}</div>')
        # 3 | 4: a key on the floor
        P.add(key(P, 3420, 2330, 1100, "bank", sd["bank"][0], sd["bank"][1], rot=4, z=11))
        # 4: Keep it all. The grid (en-US: the 2.0 grid at 5,000)
        P.add(head(P, 3, t["4"], size=HS, top=150, maxh=1080))
        if loc == "en-US":
            g, _ = lib.phone_cap(lib.cap(loc, "phone-grid2"), 1000, 2868 / 1320)
        else:
            g, _ = lib.phone_cap(lib.cap(loc, "phone-grid"), 1000, 2796 / 1290)
        P.add(f'<div style="{P.pos(3960+160, 1290, z=5)}">{g}</div>')
        # 4 | 5
        P.add(key(P, 4760, 2420, 1060, "booking", sd["booking"][0], sd["booking"][1], rot=-4, z=11))
        # 5: Write it once. 2.0's text page
        P.add(head(P, 4, t["5"], size=HS, top=150, maxh=1080))
        if loc == "en-US":
            np_, _ = lib.phone_cap(lib.cap(loc, "phone-note"), 1000, 2868 / 1320, bar="#E9E9EC")
        else:
            np_, _ = lib.phone_drawn(lib.note_page(False, sc["note_lines"], rtl=sc["rtl"]), 1000, bar="#E9E9EC")
        P.add(f'<div style="{P.pos(5280+160, 1290, z=5)}">{np_}</div>')
        # 5 | 6: the reply with its blank, as a key
        P.add(key(P, 5940, 2440, 1040, "reply", cs["reply_name"], "", rot=4, z=11, preview_html=reply_preview))
        # 6: Leave a blank. Messages with the fill-in keyboard, the first name pressed (the whole phone, so the
        # keyboard asking for the name is in the frame)
        P.add(head(P, 5, t["6"], size=HS, top=150, maxh=980))
        k = 1320 / 1398
        panel, ph_ = lib.fill_panel(sc["bar"], names, F, 1320, k, pressed=0, rtl=sc["rtl"], radius=60)
        scr = lib.messages(False, names[0], [(False, sc["ask"])], panel, ph_, rtl=sc["rtl"])
        PW6, PX6, PY6 = 800, 6600 + 440, 1170
        fp, _ = lib.phone_drawn(scr, PW6)
        P.add(f'<div style="{P.pos(PX6, PY6, z=5)}">{fp}</div>')
        b6 = PW6 * .0245; s6 = (PW6 - 2 * b6) / 1320
        cell = (1320 - 2 * 39 * k - 2 * 18 * k) / 3
        cx, cy = 39 * k + cell / 2, 2868 - ph_ + 343 * k + 65 * k
        P.add(ring(P, PX6 + b6 + cx * s6 - 90, PY6 + b6 + cy * s6 - 90, 180, z=13))
        # 6 | 7: what it sent
        P.add(f'<div class="bub" style="{P.pos(7480, 1640, -3, w=1180, z=14)};font-size:84px;padding:36px 58px;border-radius:76px">{esc(reply_filled)}</div>')
        # 7: It knows the date. The saved note with its date blank, and what it types today
        P.add(head(P, 6, t["7"], size=HS, top=150, maxh=1160))
        fs = 82
        tok = f'<span class="tok">{symbol("calendar", fs*.8, "#08664B")}{esc(today_tok)}</span>'
        c1 = (f'<div class="card" style="--w:1080px;position:relative;transform:rotate({-2.5 if P.rtl else 2.5}deg);padding:56px 64px;border-radius:64px;font-size:{fs}px;line-height:1.3">'
              f'<div style="font-size:{fs*.6}px;color:#8A8A8E;margin-bottom:14px;display:flex;align-items:center;gap:14px">{symbol("calendar", fs*.62, "#FF8D28")}{esc(cs["delivered_name"])}</div>'
              f'{esc(before)}{tok}{esc(after)}</div>')
        c2 = (f'<div class="bub" style="position:relative;transform:rotate({2 if P.rtl else -2}deg);margin-inline-start:140px;width:980px;box-sizing:border-box;font-size:80px;padding:34px 54px;border-radius:72px;background:#fff;color:#000">'
              f'{esc(before)}<span class="val" style="background:#00A878;color:#fff;border-radius:.2em;padding:0 .14em;white-space:nowrap">{esc(F["long_date_nov23"])}</span>{esc(after)}</div>')
        P.add(f'<div style="{P.pos(7920+120, 1950, w=1100, z=12)};display:flex;flex-direction:column;gap:44px">{c1}{c2}</div>')
        # 7 | 8: the Mac's three keys
        for j, (g_, x, y, r) in enumerate((("⌘", 9070, 1480, -8), ("⇧", 9290, 1790, 6), ("V", 9110, 2090, -3))):
            P.add(f'<div class="mk" style="--s:300px;{P.pos(x, y, r, z=15)}">{g_}</div>')
        # 8: Every device.
        P.add(head(P, 7, t["8"], size=HS, top=150, fine=t["8"].get("f")))
        X8 = 9240
        pg, _ = lib.ipad(lib.img(lib.cap(loc, "pad-grid")), 1060)
        P.add(f'<div style="{P.pos(X8+420, 1480, 4, z=4)}">{pg}</div>')
        pp, _ = lib.phone_cap(lib.cap(loc, "phone-grid"), 560, 2796 / 1290)
        P.add(f'<div style="{P.pos(X8+300, 1900, -5, z=6)}">{pp}</div>')
        P.add(f'<div class="win" style="{P.pos(X8+760, 2280, 2, w=520, z=7)}"><img src="{lib.cap(loc, "mac-picker")}"></div>')
    else:
        HS = 420
        for v in t.values():
            v["h"] = v["h"].replace("|", "" if loc in ("ja", "zh-Hans", "zh-Hant") else " ")   # no spaces between words there
        P.add(head(P, 0, t["1"], size=HS, top=140, sub=124, maxh=900))
        keys_html, nk, nrows = letter_keys(P, 0, addr, 70, 1100, 10, pitch=176, row=230, size=1.12)
        P.add(keys_html)
        P.add(head(P, 1, t["2"], size=HS, top=140, sub=124, maxh=600))
        hn, hv = sd["home"]
        P.add(key(P, 1980, 760, 2300, "home", hn, first_line(hv) + "…", rot=-5, z=12))
        P.add(ring(P, 3520, 790, 330, z=13))
        P.add(key(P, 2500, 1640, 1500, "sig", sd["sig"][0], first_line(sd["sig"][1]) + "…", rot=2, z=9))
        P.add(key(P, 2420, 2120, 1500, "wifi", sd["wifi"][0], sd["wifi"][1], rot=-2.5, z=8))
        P.add(head(P, 2, t["3"], size=HS, top=140, sub=124, maxh=640))
        pg, _ = lib.ipad(lib.img(lib.cap(loc, "pad-guide")), 1640, bar="#000", dark_text=False)
        P.add(f'<div style="{P.pos(4128+330, 800, z=5)}">{pg}</div>')
        P.add(key(P, 5700, 2250, 1400, "bank", sd["bank"][0], sd["bank"][1], rot=4, z=11))
        P.add(head(P, 3, t["4"], size=HS, top=140, sub=124, maxh=640))
        g, _ = lib.ipad(lib.img(lib.cap(loc, "pad-grid")), 1640)
        P.add(f'<div style="{P.pos(6192+212, 800, z=5)}">{g}</div>')
        P.add(key(P, 7600, 2280, 1400, "booking", sd["booking"][0], sd["booking"][1], rot=-4, z=11))
        P.add(head(P, 4, t["5"], size=HS, top=140, sub=124, maxh=640))
        npg, _ = lib.ipad_drawn(lib.note_page(True, sc["note_lines"], rtl=sc["rtl"]), 1640, bar="#E9E9EC")
        P.add(f'<div style="{P.pos(8256+212, 800, z=5)}">{npg}</div>')
        P.add(key(P, 9700, 2230, 1500, "reply", cs["reply_name"], "", rot=4, z=11, preview_html=reply_preview))
        P.add(head(P, 5, t["6"], size=HS, top=140, sub=124, maxh=640))
        k = 0.95
        panel, ph_ = lib.fill_panel(sc["bar"], names, F, 2064, k, pressed=0, cols=4, rtl=sc["rtl"], radius=40)
        scr = lib.messages(True, names[0], [(False, sc["ask"])], panel, ph_, rtl=sc["rtl"])
        fp, _ = lib.ipad_drawn(scr, 1420)
        P.add(f'<div style="{P.pos(10320+322, 820, z=5)}">{fp}</div>')
        P.add(f'<div class="bub" style="{P.pos(11640, 1120, -3, w=1500, z=14)};font-size:104px;padding:44px 72px;border-radius:96px">{esc(reply_filled)}</div>')
        P.add(head(P, 6, t["7"], size=HS, top=140, sub=124, maxh=640))
        fs = 100
        tok = f'<span class="tok">{symbol("calendar", fs*.8, "#08664B")}{esc(today_tok)}</span>'
        P.add(f'<div class="card" style="--w:1500px;{P.pos(12384+300, 1780, 2.5, w=1500, z=12)};padding:70px 80px;border-radius:80px;font-size:{fs}px;line-height:1.3">'
              f'<div style="font-size:{fs*.6}px;color:#8A8A8E;margin-bottom:18px;display:flex;align-items:center;gap:18px">{symbol("calendar", fs*.62, "#FF8D28")}{esc(cs["delivered_name"])}</div>'
              f'{esc(before)}{tok}{esc(after)}</div>')
        P.add(f'<div class="bub" style="{P.pos(12384+420, 2330, -2, w=1400, z=13)};font-size:98px;padding:42px 66px;border-radius:90px;background:#fff;color:#000">'
              f'{esc(before)}<span style="background:#00A878;color:#fff;border-radius:.2em;padding:0 .14em;white-space:nowrap">{esc(F["long_date_nov23"])}</span>{esc(after)}</div>')
        for g_, x, y, r in (("⌘", 14200, 1300, -8), ("⇧", 14420, 1640, 6), ("V", 14250, 1980, -3)):
            P.add(f'<div class="mk" style="--s:340px;{P.pos(x, y, r, z=15)}">{g_}</div>')
        P.add(head(P, 7, t["8"], size=HS, top=140, sub=124, maxh=1000, fine=t["8"].get("f")))
        X8 = 14448
        pg, _ = lib.ipad(lib.img(lib.cap(loc, "pad-grid")), 1300)
        P.add(f'<div style="{P.pos(X8+690, 1180, 4, z=4)}">{pg}</div>')
        pp, _ = lib.phone_cap(lib.cap(loc, "phone-grid"), 640, 2796 / 1290)
        P.add(f'<div style="{P.pos(X8+330, 1480, -5, z=6)}">{pp}</div>')
        P.add(f'<div class="win" style="{P.pos(X8+1040, 1900, 2, w=640, z=7)}"><img src="{lib.cap(loc, "mac-picker")}"></div>')

    css = CSS + " .h1,.sub,.fine{font-family:system-ui,-apple-system%s}" % ("," + HEAD_FONT[loc] if loc in HEAD_FONT else "")
    css += " .h1{line-height:%s} .sub,.fine{line-height:%s}" % HEAD_LH.get(loc, (.84, 1.08))
    return lib.render(P, css, out_dir, extra_head=FIT)


# ---------------------------------------------------------------- Text expander (custom page, English only)
# Its own words, not the main page's: the rival's way is a shortcut code you must remember (;addr, ;sig), Cutling's is
# a key you tap. Six frames: 1 the codes, struck through | 2 the one key | 3 the whole text, formatted (2.0 capture)
# | 4 blanks it asks for | 5 dates it fills | 6 paid once, every device.

TE = {
    "1": {"h": "No|codes.", "s": "Nothing to memorise."},
    "2": {"h": "Just|tap.", "s": "One key types the whole text."},
    "3": {"h": "All of it.", "s": "Lists, bold and links, in one go."},
    "4": {"h": "Blanks|too.", "s": "It asks for the name, then types."},
    "5": {"h": "Dates|too.", "s": "Today’s date, on the day you paste."},
    "6": {"h": "Paid|once.", "s": "No subscription. iPhone, iPad, Mac."},
}
TE_US = {"1": {"s": "Nothing to memorize."}}


def code_rows(P, i, codes, x0, y0, size=1.0, pitch=152, row=230):
    out = []
    seed = 11
    def rnd():
        nonlocal seed
        seed = (seed * 16807) % 2147483647
        return seed / 2147483647
    for j, code in enumerate(codes):
        for c, ch in enumerate(code):
            x = x0 + c * pitch + (rnd() - .5) * 8
            y = y0 + j * row + (rnd() - .5) * 10
            out.append(f'<div class="lk" style="{P.pos(P.fx(i)+x, y, (rnd()-.5)*8)};width:{140*size}px;height:{172*size}px;font-size:{96*size}px;'
                       f'line-height:{164*size}px;border-radius:{23*size}px;color:#5a6b64">{esc(ch)}</div>')
        w = len(code) * pitch + 40
        out.append(f'<div style="{P.pos(P.fx(i)+x0-20, y0 + j*row + 80*size, -2, w=w, z=20)};height:{14*size}px;border-radius:{7*size}px;background:var(--ink)"></div>')
    return "".join(out)


def build_te(loc, dev, out_dir):
    W, own = lib.words(loc)
    cs = W["cseed"]; F = lib.FACTS[loc]
    t = {k: dict(v) for k, v in TE.items()}
    if loc in ("en-US",):
        for k, v in TE_US.items():
            t[k].update(v)
    P = lib.Pano(loc, dev, 6)
    sd = lib.seed(loc)
    sc = screens(loc, P.w, cs, F, own, sd)
    names = cs["names"]; day = F["weekday_tue_nov24"]
    reply_filled = lib.chips_text(cs["reply"], {"name": names[0], "date": day})
    reply_preview = (esc(cs["reply"].split("{name}")[0]) + f'<u>{esc(cs["name_label"])}</u>'
                     + esc(cs["reply"].split("{name}", 1)[1].split("{date}")[0]) + "…")
    today_tok = F["product_terms"].get("Today’s Date", "Today’s Date")
    before, _, after = cs["delivered"].partition("{date}")
    welcome = own["demo"]["note"]
    codes = [";addr", ";sig", ";iban", ";wifi"]
    if not P.pad:
        HS = 520
        P.add(head(P, 0, t["1"], size=HS, top=150))
        P.add(code_rows(P, 0, codes, 100, 1440, size=1.22, pitch=190, row=250))
        P.add(head(P, 1, t["2"], size=HS, top=150))
        P.add(key(P, 1180, 1330, 1640, "note", "Welcome note", welcome[0], rot=-5, z=12))
        P.add(ring(P, 2230, 1395, 250, z=13))
        P.add(key(P, 1600, 2000, 1180, "home", sd["home"][0], first_line(sd["home"][1]) + "…", rot=2, z=9))
        P.add(key(P, 1560, 2380, 1180, "sig", sd["sig"][0], first_line(sd["sig"][1]) + "…", rot=-2.5, z=8))
        # 3: the whole text, typed formatted (2.0 capture, English)
        P.add(head(P, 2, t["3"], size=HS, top=150))
        ph, _ = lib.phone_cap(lib.cap(loc, "phone-formatted"), 1000, 2868 / 1320, bar="#C7C7CC")
        P.add(f'<div style="{P.pos(2640+170, 1000, z=5)}">{ph}</div>')
        P.add(key(P, 3260, 2400, 1100, "bank", sd["bank"][0], sd["bank"][1], rot=4, z=11))
        # 4: blanks
        P.add(head(P, 3, t["4"], size=HS, top=150))
        k = 1320 / 1398
        panel, ph_ = lib.fill_panel(sc["bar"], names, F, 1320, k, pressed=0, radius=60)
        scr = lib.messages(False, names[0], [(False, sc["ask"])], panel, ph_)
        PW6, PX6, PY6 = 800, 3960 + 440, 1170
        fp, _ = lib.phone_drawn(scr, PW6)
        P.add(f'<div style="{P.pos(PX6, PY6, z=5)}">{fp}</div>')
        b6 = PW6 * .0245; s6 = (PW6 - 2 * b6) / 1320
        cell = (1320 - 2 * 39 * k - 2 * 18 * k) / 3
        P.add(ring(P, PX6 + b6 + (39 * k + cell / 2) * s6 - 90, PY6 + b6 + (2868 - ph_ + 343 * k + 65 * k) * s6 - 90, 180, z=13))
        P.add(f'<div class="bub" style="{P.pos(4840, 1640, -3, w=1180, z=14)};font-size:84px;padding:36px 58px;border-radius:76px">{esc(reply_filled)}</div>')
        # 5: dates
        P.add(head(P, 4, t["5"], size=HS, top=150))
        fs = 82
        tok = f'<span class="tok">{symbol("calendar", fs*.8, "#08664B")}{esc(today_tok)}</span>'
        P.add(f'<div class="card" style="--w:1080px;{P.pos(5280+120, 2160, 2.5, w=1080, z=12)};padding:56px 64px;border-radius:64px;font-size:{fs}px;line-height:1.3">'
              f'<div style="font-size:{fs*.6}px;color:#8A8A8E;margin-bottom:14px;display:flex;align-items:center;gap:14px">{symbol("calendar", fs*.62, "#FF8D28")}{esc(cs["delivered_name"])}</div>'
              f'{esc(before)}{tok}{esc(after)}</div>')
        P.add(f'<div class="bub" style="{P.pos(5280+260, 2560, -2, w=980, z=13)};font-size:80px;padding:34px 54px;border-radius:72px;background:#fff;color:#000">'
              f'{esc(before)}<span style="background:#00A878;color:#fff;border-radius:.2em;padding:0 .14em;white-space:nowrap">{esc(F["long_date_nov23"])}</span>{esc(after)}</div>')
        for g_, x, y, r in (("⌘", 6340, 1520, -8), ("⇧", 6540, 1820, 6), ("V", 6360, 2100, -3)):
            P.add(f'<div class="mk" style="--s:300px;{P.pos(x, y, r, z=15)}">{g_}</div>')
        # 6: paid once
        P.add(head(P, 5, t["6"], size=HS, top=150))
        X8 = 6600
        pg, _ = lib.ipad(lib.img(lib.cap(loc, "pad-grid")), 1060)
        P.add(f'<div style="{P.pos(X8+420, 1480, 4, z=4)}">{pg}</div>')
        pp, _ = lib.phone_cap(lib.cap(loc, "phone-grid2"), 560, 2868 / 1320)
        P.add(f'<div style="{P.pos(X8+300, 1900, -5, z=6)}">{pp}</div>')
        P.add(f'<div class="win" style="{P.pos(X8+760, 2280, 2, w=520, z=7)}"><img src="{lib.cap(loc, "mac-picker")}"></div>')
    else:
        HS = 420
        for v in t.values():
            v["h"] = v["h"].replace("|", "" if loc in ("ja", "zh-Hans", "zh-Hant") else " ")   # no spaces between words there
        P.add(head(P, 0, t["1"], size=HS, top=140, sub=124, maxh=900))
        P.add(code_rows(P, 0, codes, 130, 1040, size=1.4, pitch=215, row=290))
        P.add(head(P, 1, t["2"], size=HS, top=140, sub=124, maxh=900))
        P.add(key(P, 1900, 900, 2300, "note", "Welcome note", welcome[0], rot=-5, z=12))
        P.add(ring(P, 3380, 950, 330, z=13))
        P.add(key(P, 2500, 1760, 1500, "home", sd["home"][0], first_line(sd["home"][1]) + "…", rot=2, z=9))
        P.add(key(P, 2420, 2240, 1500, "sig", sd["sig"][0], first_line(sd["sig"][1]) + "…", rot=-2.5, z=8))
        P.add(head(P, 2, t["3"], size=HS, top=140, sub=124, maxh=640))
        # no iPad capture of the formatted text: the 2.0 iPhone capture, standing on the iPad's frame
        ph, _ = lib.phone_cap(lib.cap(loc, "phone-formatted"), 900, 2868 / 1320, bar="#C7C7CC")
        P.add(f'<div style="{P.pos(4128+580, 800, z=5)}">{ph}</div>')
        P.add(key(P, 5700, 2250, 1400, "bank", sd["bank"][0], sd["bank"][1], rot=4, z=11))
        P.add(head(P, 3, t["4"], size=HS, top=140, sub=124, maxh=640))
        panel, ph_ = lib.fill_panel(sc["bar"], names, F, 2064, .95, pressed=0, cols=4, radius=40)
        scr = lib.messages(True, names[0], [(False, sc["ask"])], panel, ph_)
        fp, _ = lib.ipad_drawn(scr, 1420)
        P.add(f'<div style="{P.pos(6192+322, 820, z=5)}">{fp}</div>')
        P.add(f'<div class="bub" style="{P.pos(7400, 1120, -3, w=1500, z=14)};font-size:104px;padding:44px 72px;border-radius:96px">{esc(reply_filled)}</div>')
        P.add(head(P, 4, t["5"], size=HS, top=140, sub=124, maxh=640))
        fs = 100
        tok = f'<span class="tok">{symbol("calendar", fs*.8, "#08664B")}{esc(today_tok)}</span>'
        P.add(f'<div class="card" style="--w:1500px;{P.pos(8256+300, 1780, 2.5, w=1500, z=12)};padding:70px 80px;border-radius:80px;font-size:{fs}px;line-height:1.3">'
              f'<div style="font-size:{fs*.6}px;color:#8A8A8E;margin-bottom:18px;display:flex;align-items:center;gap:18px">{symbol("calendar", fs*.62, "#FF8D28")}{esc(cs["delivered_name"])}</div>'
              f'{esc(before)}{tok}{esc(after)}</div>')
        P.add(f'<div class="bub" style="{P.pos(8256+420, 2330, -2, w=1400, z=13)};font-size:98px;padding:42px 66px;border-radius:90px;background:#fff;color:#000">'
              f'{esc(before)}<span style="background:#00A878;color:#fff;border-radius:.2em;padding:0 .14em;white-space:nowrap">{esc(F["long_date_nov23"])}</span>{esc(after)}</div>')
        for g_, x, y, r in (("⌘", 10070, 1300, -8), ("⇧", 10290, 1640, 6), ("V", 10120, 1980, -3)):
            P.add(f'<div class="mk" style="--s:340px;{P.pos(x, y, r, z=15)}">{g_}</div>')
        P.add(head(P, 5, t["6"], size=HS, top=140, sub=124, maxh=1000))
        X8 = 10320
        pg, _ = lib.ipad(lib.img(lib.cap(loc, "pad-grid")), 1300)
        P.add(f'<div style="{P.pos(X8+690, 1180, 4, z=4)}">{pg}</div>')
        pp, _ = lib.phone_cap(lib.cap(loc, "phone-grid2"), 640, 2868 / 1320)
        P.add(f'<div style="{P.pos(X8+330, 1480, -5, z=6)}">{pp}</div>')
        P.add(f'<div class="win" style="{P.pos(X8+1040, 1900, 2, w=640, z=7)}"><img src="{lib.cap(loc, "mac-picker")}"></div>')
    css = CSS + " .h1{line-height:.84} .sub,.fine{line-height:1.08}"
    return lib.render(P, css, out_dir, extra_head=FIT)
