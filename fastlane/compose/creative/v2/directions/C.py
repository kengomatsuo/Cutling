"""C. The blank: ink black, the buyer's own sentence set large in a serif, and every part Cutling types for you a green
chip, the way 2.0 shows a blank. Leads with 2.0's fill-ins: frames 1 and 2 are the same reply sent to two people, so
the pair beside the preview reads as "written once, sent again".

Words: words/<locale>.json, keys "cseed" (the demo shop owner's reply, names, plan, note) and "C" (kicker, headline,
subline per frame; the headlines of iPhone 1 to 3 and Mac 1 are built here from the seed so they say exactly what the
drawn keyboard and form type). App strings, dates and numbers: docs/aso/screens-2.0/locale-facts.json."""

CSS = """
.stage{background:radial-gradient(130% 90% at 30% 0%,#1A1E1C 0%,#0E100F 55%,#090A0A 100%)}
.kick{position:absolute;color:#34D3A2;font-weight:600;letter-spacing:-.01em}
.h{position:absolute;font-family:NY,serif;color:#F3F0E8;font-weight:500;letter-spacing:-.012em;line-height:1.14}
.h .chip{display:inline;white-space:nowrap;font-family:NY,serif;position:relative;background:none;color:#03241A;padding:0 .16em;margin:0 .02em}
/* A chip's green sits under every letter of the text block (z-index -1 in its stacking context), so a chip on the next
   line never hides a mark that hangs below this one, such as the u-sign of Devanagari "तु" or a Latin "j". */
.h .chip::before{content:"";position:absolute;inset:0;z-index:-1;background:#1DBB8A;border-radius:.2em}
.s{position:absolute;color:#A3AAA6;font-weight:500;letter-spacing:-.005em;line-height:1.25;text-wrap:pretty}
.h{text-wrap:pretty}
.note{line-height:1.5} .bubble{line-height:1.25}
.cmd{display:inline-flex;gap:.14em;direction:ltr}
.cmd b{display:inline-flex;align-items:center;justify-content:center;width:1.25em;height:1.25em;border-radius:.2em;font-family:SF;font-weight:500;
  font-size:.8em;background:linear-gradient(180deg,#2B2F2D,#1B1E1D);color:#F3F0E8;box-shadow:0 .05em 0 #000,inset 0 1px 0 rgba(255,255,255,.12),0 0 0 .012em #3a3f3c}
"""

def text(m, t, x, y, w, kfs, hfs, sfs, maxh, gap=0.55):
    s = f'<div class="s" style="position:static;margin-top:{hfs*gap*0.6}px;font-size:{sfs}px;width:{w*0.9}px">{m.rich(t["s"])}</div>' if t.get("s") else ""
    return (f'<div class="abs" data-fit="{maxh}" style="left:{x}px;top:{y}px;width:{w}px;z-index:30">'
            f'<div class="kick" style="position:static;font-size:{kfs}px;margin-bottom:{kfs*0.55}px">{m.esc(t["k"])}</div>'
            f'<div class="h" style="position:static;font-size:{hfs}px">{head(m, t["h"])}</div>{s}</div>')

def join_date(date):
    """A long date in a message bubble may break only before its last part (the year, or the day where the year
    leads), so "23 de novembro de / 2026" never splits the day from its month."""
    head_, sep, tail = date.rpartition(" ")
    return head_.replace(" ", "\u00a0") + sep + tail if sep else "\u2060".join(date)   # no spaces (CJK): keep it whole

def head(m, h):
    """Every chip stays on one line (CSS nowrap), so a blank never reads as two pieces; a long one, such as a full
    date, makes the fit script shrink the headline instead of breaking."""
    return m.rich(h)

def build(m, loc, words, only):
    W = words["C"]; cs = words["cseed"]; F = m.FACTS[loc]
    out = m.HERE / "out" / loc / "C"
    for dev in ("iphone", "ipad", "mac"):
        if only and dev != only:
            continue
        (out / dev).mkdir(parents=True, exist_ok=True)
        if dev == "mac":
            mac_set(m, loc, W, cs, F, out / dev)
        else:
            touch_set(m, loc, W, cs, F, out / dev, dev)

def touch_set(m, loc, W, cs, F, out, dev):
    T = {k: dict(v) for k, v in W["iphone"].items()}
    for k, v in W.get(dev, {}).items():
        T.setdefault(k, {}).update(v)
    w, h = m.SIZE[dev]; pad = dev == "ipad"; rtl = loc in m.RTL
    X, Y, TW = (150, 200, 1700) if pad else (96, 200, 1140)
    KF, HF, SF = (60, 150, 54) if pad else (54, 138, 50)
    day = F["weekday_tue_nov24"]
    for n, name in (("1", cs["names"][0]), ("2", cs["names"][1])):
        T[n]["h"] = m.chips(cs["reply"], {"name": name, "date": day})
    T["3"]["h"] = m.chips(cs["delivered"], {"date": F["long_date_nov23"]})

    # 1 + 2: the same reply, two names; below each, the keyboard asking for the name with that name's key pressed
    pw = 1700 if pad else 1240
    bar = m.split_template(cs["reply"], {"name": cs["name_label"], "date": day}, blank_key="name")
    py = h - 110 - 940 * pw / 1398
    p1, _ = m.fillbar(bar, cs["names"], F, (w - pw) / 2, py, pw, pressed=0, radius=pw * .06, rtl=rtl)
    p2, _ = m.fillbar(bar, cs["names"], F, w + (w - pw) / 2, py, pw, pressed=1, radius=pw * .06, rtl=rtl)
    big = HF * (1.32 if pad else 1.42)
    room = py - Y - 60
    body = (text(m, T["1"], X, Y, TW, KF, big, SF, room) + p1
            + text(m, T["2"], w + X, Y, TW, KF, big, SF, room) + p2)
    pair = m.write_render(out / "pair-12.html", m.page(2 * w, h, body, CSS, loc), 2 * w, h)
    m.split_pair(pair, out / "01.png", out / "02.png", w)

    # 3: the saved note whose blank is a date, and what it typed today
    fs = 86 if not pad else 92
    cy = 1500 if not pad else 1400
    pill = (f'<span style="background:#D6F5EA;color:#08664B;border-radius:.25em;padding:0 .2em;font-weight:600;white-space:nowrap">'
            f'{m.esc(F["long_date_nov23"])}</span>')
    before, _, after = cs["delivered"].partition("{date}")
    card = (f'<div class="note" style="padding:{fs*.9}px;border-radius:{fs*.8}px;'
            f'background:#1A1D1C;box-shadow:inset 0 0 0 2px #2A2F2D;color:#F3F0E8;font-size:{fs*.8}px">'
            f'<div style="color:#7F8783;font-size:{fs*.62}px;margin-bottom:{fs*.4}px">{m.esc(cs["delivered_name"])}</div>'
            f'{m.esc(before)}{pill}{m.esc(after)}</div>')
    bub = (f'<div class="bubble" style="align-self:flex-end;max-width:{w-2*X}px;background:#0A84FF;color:#fff;'
           f'font-size:{fs}px;padding:{fs*.42}px {fs*.7}px;border-radius:{fs*.9}px">'
           f'{m.esc(before)}{m.esc(join_date(F["long_date_nov23"]))}{m.esc(after)}</div>')
    # the saved note, then the message it typed today, stacked so a long date never makes them overlap
    card = (f'<div class="abs" style="left:{X}px;top:{cy}px;width:{w-2*X}px;display:flex;flex-direction:column;'
            f'gap:{fs*.7}px;z-index:5">{card}{bub}</div>')
    bub = ""
    body = text(m, T["3"], X, Y, TW, KF, HF * 1.15, SF, cy - Y - 80) + card + bub
    m.write_render(out / "03.html", m.page(w, h, body, CSS, loc), w, h)

    # 4, 5, 6: real captures of this language under the line. 4: the 2.0 setup guide's Try It page, the keyboard
    # typing the saved address (the Messages captures are English in most languages, so they are not used);
    # 5: the app's grid; 6: the same cutlings on Mac, iPad and iPhone.
    top = 1060 if pad else 1130
    mx = (lambda x, width: w - x - width) if rtl else (lambda x, width: x)
    if pad:
        devs = {"04": m.ipad(m.cap(loc, "pad-guide"), 420, top, 1220, bar="#000", dark_text=False)[0],
                "05": m.ipad(m.cap(loc, "pad-grid"), 420, top, 1220)[0],
                "06": m.win(m.cap(loc, "mac-picker"), mx(150, 760), top + 40, 760, z=1)
                      + m.ipad(m.cap(loc, "pad-grid"), mx(560, 1150), top + 220, 1150, z=2)[0]
                      + m.phone(m.cap(loc, "phone-grid"), mx(1400, 560), top + 640, 560, bar="#F2F2F7", z=3)[0]}
    else:
        devs = {"04": m.phone(m.cap(loc, "phone-guide"), 300, top, 720, bar="#000", dark_text=False, aspect=2868 / 1320)[0],
                "05": m.phone(m.cap(loc, "phone-grid"), 300, top, 720, bar="#F2F2F7")[0],
                "06": m.win(m.cap(loc, "mac-picker"), mx(70, 520), top + 30, 520, z=1)
                      + m.ipad(m.cap(loc, "pad-grid"), mx(300, 860), top + 170, 860, z=2)[0]
                      + m.phone(m.cap(loc, "phone-grid"), mx(840, 420), top + 520, 420, bar="#F2F2F7", z=3)[0]}
    for n, key in (("04", "4"), ("05", "5"), ("06", "6")):
        hf = HF * (1.5 if n in ("05", "06") else 1.0)   # 4 is a list of three; 5 and 6 are a number and two words
        body = text(m, T[key], X, Y, TW, KF, hf, SF, top - Y - 70) + devs[n]
        m.write_render(out / f"{n}.html", m.page(w, h, body, CSS, loc), w, h)

def mac_set(m, loc, W, cs, F, out):
    T = {k: dict(v) for k, v in W["mac"].items()}
    w, h = m.SIZE["mac"]; rtl = loc in m.RTL
    X, Y, TW = 170, 240, 1300
    KF, HF, SF = 64, 168, 56
    vals = {"name": cs["mac_name"], "plan": cs["plan_choices"][1], "date": F["weekday_tue_nov24"]}
    T["1"]["h"] = m.chips(cs["mac_reply"], vals)
    T["3"]["h"] = "[••••••••••]"
    T["2"]["h"] = "{cmd}"
    mx = lambda x, width: (w - x - width) if rtl else x   # mirrored for right-to-left languages
    icon = (m.REPO / "Cutling/Assets.xcassets/AppIcon-Default.imageset/AppIcon-Default.png").as_uri()
    room = h - Y - 160
    form, _ = m.macform(cs, F, vals, mx(1560, 1200), 260, 1200, dark=False, rtl=rtl)   # light, as every other window in the set
    pages = {
        "01": text(m, T["1"], mx(X, TW), Y, TW, KF, HF, SF, room) + form,
        "02": text(m, T["2"], mx(X, TW), Y, TW, KF, HF * 1.75, SF, room) + m.win(m.cap(loc, "mac-picker"), mx(1640, 1100), 110, 1100),
        "03": text(m, T["3"], mx(X, TW), Y, TW, KF, HF * 1.1, SF, room) + m.win(m.cap(loc, "mac-history"), mx(1640, 1100), 110, 1100, extra=m.history_label(loc, 1100)),
        "04": text(m, T["4"], mx(X, TW), Y, TW, KF, HF, SF, room) + m.win(m.cap(loc, "mac-sync"), mx(1480, 1250), 300, 1250, z=5)
              + m.phone(m.cap(loc, "phone-grid"), mx(2240, 520), 560, 520, bar="#F2F2F7", z=20)[0],
        "05": text(m, T["5"], mx(X, 1350), Y + 380, 1350, KF, HF * 1.5, SF, room - 380)
              + f'<img src="{icon}" style="position:absolute;left:{mx(X, 300)}px;top:{Y}px;width:300px;border-radius:66px">'
              + m.win(m.cap(loc, "mac-picker"), mx(1640, 1100), 110, 1100),
    }
    for n, body in pages.items():
        m.write_render(out / f"{n}.html", m.page(w, h, body, CSS, loc), w, h)
