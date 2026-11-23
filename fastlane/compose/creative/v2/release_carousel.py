#!/usr/bin/env python3
"""The 2.0 release carousel for Instagram and Facebook: seven 1080 x 1350 slides in the store frames' look (direction C,
"The blank"), so the post and the App Store page it leads to read as one. Built with build.py's own parts.

  python3 release_carousel.py [out-dir]        # default ~/Downloads/cutling-2-release-posts/carousel

What each slide shows, real or drawn: the cover and the end card are type; "asks for the name" is the keyboard's
fill-in screen drawn after the 2.0 build as on store frame 1; the date slide is the saved note and its message drawn
as on store frame 3; the note, the 5,000 and the formatted key are real captures of the 2.0 build from
CutlingUITests/PromoReleaseUITests (captures/en-US/release_*.png), each shown through a window onto the part of the
screen the line is about."""
import sys
from pathlib import Path

import build as m

W, H = 1080, 1350
X = 78
OUT = Path(sys.argv[1]).expanduser() if len(sys.argv) > 1 else Path.home() / "Downloads/cutling-2-release-posts/carousel"
CAP = m.EXTRA / "en-US"
ICON = (m.HERE / "assets" / "cutling-icon.png")
F = m.FACTS["en-US"]

CSS = """
.stage{background:radial-gradient(130% 90% at 30% 0%,#1A1E1C 0%,#0E100F 55%,#090A0A 100%)}
.kick{color:#34D3A2;font-weight:600;letter-spacing:-.01em;font-size:44px;display:flex;align-items:center;gap:16px}
.kick i{font-style:normal;color:#5E6662}
.h{font-family:NY,serif;color:#F3F0E8;font-weight:500;letter-spacing:-.012em;line-height:1.12;text-wrap:balance}
.h .chip{display:inline;white-space:nowrap;font-family:NY,serif;position:relative;background:none;color:#03241A;padding:0 .16em;margin:0 .02em}
.h .chip::before{content:"";position:absolute;inset:0;z-index:-1;background:#1DBB8A;border-radius:.2em}
.s{color:#A3AAA6;font-weight:500;letter-spacing:-.005em;line-height:1.28;font-size:44px;text-wrap:pretty}
.txt{position:absolute;left:78px;top:92px;width:924px;z-index:30}
.foot{position:absolute;left:78px;right:78px;bottom:64px;display:flex;align-items:center;justify-content:space-between;color:#5E6662;font-size:34px;font-weight:600;z-index:40}
.foot .brand{display:flex;align-items:center;gap:14px;color:#A3AAA6}
.foot img{width:52px;height:52px;border-radius:12px}
.note{line-height:1.5}
"""


def text(kick, head, sub, hfs, top=92):
    return (f'<div class="txt" style="top:{top}px"><div class="kick">{kick}</div>'
            f'<div class="h" style="font-size:{hfs}px;margin-top:22px">{m.rich(head)}</div>'
            f'<div class="s" style="margin-top:{hfs * .28}px">{m.esc(sub)}</div></div>')


def mark():
    """The app's mark, top right on every inside slide, level with the kicker."""
    return (f'<div class="abs" style="right:{X}px;top:86px;display:flex;align-items:center;gap:14px;color:#A3AAA6;'
            f'font-size:36px;font-weight:600;z-index:40"><img src="{ICON.as_uri()}" style="width:56px;height:56px;border-radius:13px">Cutling 2.0</div>')


def shot(name):
    p = CAP / name
    if not p.exists():
        raise SystemExit(f"missing capture: {p} (CutlingUITests/PromoReleaseUITests writes it)")
    return p.as_uri()


def window(src, crop, x, y, w, radius=56):
    """A rounded window onto part of a 1320 px wide capture: crop is (x, y, w, h) in the capture's pixels."""
    cx, cy, cw, ch = crop
    k = w / cw
    return (f'<div class="abs" style="left:{x}px;top:{y}px;width:{w}px;height:{ch * k}px;border-radius:{radius}px;overflow:hidden;background:#fff;'
            f'box-shadow:0 40px 90px rgba(0,0,0,.5),0 0 0 1.5px rgba(255,255,255,.08);z-index:5">'
            f'<img src="{src}" style="position:absolute;left:{-cx * k}px;top:{-cy * k}px;width:{1320 * k}px;max-width:none;display:block"></div>')


def slide(n, body):
    return m.write_render(OUT / "src" / f"{n:02d}.html", m.page(W, H, body, CSS, "en-US"), W, H)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    names = ["Maya", "Jonas", "Aiko"]

    # 1 cover
    body = (f'<div class="abs" style="left:{X}px;top:120px;display:flex;align-items:center;gap:22px;z-index:30">'
            f'<img src="{ICON.as_uri()}" style="width:96px;height:96px;border-radius:22px">'
            f'<span style="color:#F3F0E8;font-size:52px;font-weight:600;letter-spacing:-.015em">Cutling</span></div>'
            f'<div class="abs" style="left:{X}px;top:360px;width:924px;z-index:30">'
            f'<div class="h" style="font-size:176px;line-height:1.02">{m.rich("What’s new in [2.0]")}</div>'
            f'<div class="s" style="margin-top:56px;font-size:50px">Five things your saved replies can do now.</div></div>'
            f'<div class="abs" style="left:{X}px;right:{X}px;bottom:150px;display:flex;flex-wrap:wrap;gap:16px;z-index:30">'
            + "".join(f'<span style="border:2px solid #2F3633;color:#C9CEC9;border-radius:999px;padding:12px 26px;font-size:36px;font-weight:500">{t}</span>'
                      for t in ("A blank for the name", "Dates", "Bold and lists", "Room for 5,000", "Every key types"))
            + f'</div><div class="foot" style="color:#34D3A2;font-size:40px"><span></span>'
            f'<span style="display:flex;align-items:center;gap:14px">Swipe {m.symbol("arrow.right", 40, "#34D3A2")}</span></div>')
    slide(1, body)

    # 2 the reply asks for the name: the keyboard's fill-in screen, as on store frame 1
    pw = 940
    bar = m.split_template("Hi {name}, your order ships {date}.", {"name": "Name", "date": "Tuesday"}, blank_key="name")
    panel, ph = m.fillbar(bar, names, F, (W - pw) / 2, H - 70 - 940 * pw / 1398, pw, pressed=0, radius=pw * .06)
    body = text("<span>1</span><i>of 5</i>", "Hi [Maya], your order ships [Tuesday].",
                "Put a blank in a saved reply. Tap the reply and the keyboard asks for the name.", 104) + panel + mark()
    slide(2, body)

    # 3 dates fill themselves in: the saved note, then the message it typed that day
    fs = 62
    pill = ('<span style="background:#D6F5EA;color:#08664B;border-radius:.25em;padding:0 .2em;font-weight:600;white-space:nowrap">Today’s Date</span>')
    card = (f'<div class="note" style="padding:{fs * .8}px;border-radius:{fs * .7}px;background:#1A1D1C;box-shadow:inset 0 0 0 2px #2A2F2D;'
            f'color:#F3F0E8;font-size:{fs * .84}px"><div style="color:#7F8783;font-size:{fs * .6}px;margin-bottom:{fs * .3}px">Delivery note</div>'
            f'Delivered on {pill}.</div>')
    bub = (f'<div style="align-self:flex-end;background:#0A84FF;color:#fff;font-size:{fs}px;line-height:1.25;'
           f'padding:{fs * .42}px {fs * .7}px;border-radius:{fs * .9}px">Delivered on December&nbsp;1,&nbsp;2026.</div>')
    stack = (f'<div class="abs" style="left:{X}px;top:800px;width:{W - 2 * X}px;display:flex;flex-direction:column;gap:{fs * .6}px;z-index:5">{card}{bub}</div>')
    body = text("<span>2</span><i>of 5</i>", "Dates fill [themselves] in.",
                "Today, tomorrow, a week from now or the time: saved once, right on the day you send it.", 124) + stack + mark()
    slide(3, body)

    # 4, 5, 6: real captures of the 2.0 build under the line, through the same windows as the release film
    # (cutling-promo src/release/plan.ts): the part of the screen the line is about, at reading size.
    top = 640
    note = window(shot("release_note_3_written.png"), (24, 205, 920, 790), X, top, W - 2 * X)
    body = text("<span>3</span><i>of 5</i>", "Write it like a [note].", "The text opens as a page of its own, with bold, highlight, links and lists.", 124) + note + mark()
    slide(4, body)

    room = window(shot("release_room_0_grid.png"), (0, 330, 700, 560), X, top, W - 2 * X)
    body = text("<span>4</span><i>of 5</i>", "Room for [5,000].", "Up from 100 texts, and from 25 images to 500. One text can run to 10,000 characters, so a whole email fits.", 124) + room + mark()
    slide(5, body)

    k = (W - 2 * X) / 940
    typed = window(shot("release_keyboard_4_formatted.png"), (60, 716, 940, 376), X, top, W - 2 * X, radius=44)
    keys = window(shot("release_keyboard_4_formatted.png"), (0, 1960, 1320, 520), X, top + 376 * k + 20, W - 2 * X, radius=44)
    body = text("<span>5</span><i>of 5</i>", "Every key [types].", "A formatted cutling used to copy when you tapped it. Now it types like the rest; touch and hold to copy its formatting.", 124) + typed + keys + mark()
    slide(6, body)

    # 7 the end card asks the reader
    body = (f'<div class="abs" style="left:{X}px;top:130px;width:924px;z-index:30">'
            f'<img src="{ICON.as_uri()}" style="width:176px;height:176px;border-radius:40px;display:block">'
            f'<div class="h" style="font-size:128px;margin-top:64px">{m.rich("Which one would you use [first]?")}</div>'
            f'<div class="s" style="margin-top:44px;font-size:48px">Tell us in the comments.</div></div>'
            f'<div class="abs" style="left:{X}px;bottom:96px;width:924px;z-index:30;border-top:2px solid #262B29;padding-top:40px">'
            f'<div style="color:#F3F0E8;font-size:50px;font-weight:600;letter-spacing:-.015em">Cutling 2.0 is on the App Store.</div>'
            f'<div class="s" style="margin-top:10px">A free update if you already have it.</div></div>')
    slide(7, body)

    m.run_jobs()
    for n in range(1, 8):
        src = OUT / "src" / f"{n:02d}.png"
        if src.exists():
            (OUT / f"cutling-2-whats-new-{n:02d}.png").write_bytes(src.read_bytes())
    print(OUT)


if __name__ == "__main__":
    main()
