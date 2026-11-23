#!/usr/bin/env python3
"""One picture per direction for the owner's pick: how it shows in search, then every frame on iPhone, iPad and Mac.

    python3 sheet.py [locale] [A B C]     -> ~/Downloads/Claude/cutling-screens-redesign/<locale>-<dir>-<name>.png
"""
import html, json, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[3]
DL = Path.home() / "Downloads/Claude/cutling-screens-redesign"
ICON = (REPO / "Cutling/Assets.xcassets/AppIcon-Default.imageset/AppIcon-Default.png").as_uri()
POSTER = (HERE / "assets/preview-poster-G-iphone.png").as_uri()
IDEA = {
    "A": "The icon's punched tags made real, riveted on one ring. Leads with everything you keep; the top tag runs from frame 1 into the phone in frame 2.",
    "B": "Carries on from the \"Every app\" preview: white, one black and one green line, and the real keyboard at the same height in every frame. On Mac the menu bar is the constant.",
    "C": "Ink black, the buyer's sentence in a serif, every part Cutling types a green chip. Leads with 2.0's fill-ins: frames 1 and 2 are one reply sent to two people.",
}

def esc(s): return html.escape(s)

def search_card(title, shots, *, w=1170, kind="phone", note=""):
    """An App Store search result: icon, name, subtitle, Get, then the images search shows."""
    pad = 48; gap = 24
    if kind == "mac":
        sh = "".join(f'<img src="{s}" style="width:{w-2*pad}px;border-radius:18px;display:block;box-shadow:0 0 0 1px #e3e3e3">' for s in shots)
    else:
        n = len(shots); sw = (w - 2 * pad - (n - 1) * gap) / n
        sh = "".join(f'<img src="{s}" style="width:{sw}px;border-radius:{sw*.06}px;display:block;box-shadow:0 0 0 1px #e3e3e3">' for s in shots)
    z = 0.665 if kind != "mac" else 0.70
    return f'''<div class="card" style="width:{w}px;zoom:{z}">
<div class="cap">{esc(title)}</div>
<div class="res" style="padding:{pad}px">
 <div class="top"><img src="{ICON}" class="ic"><div class="nm"><b>Cutling - Clipboard Keyboard</b><span>Paste Text Snippets &amp; Replies</span></div><div class="get">Get</div></div>
 <div class="shots" style="gap:{gap}px">{sh}</div></div>
<div class="note">{esc(note)}</div></div>'''

def main():
    args = sys.argv[1:]
    loc = args[0] if args and args[0] not in ("A", "B", "C") else "en-US"
    dirs = [a for a in args if a in ("A", "B", "C")] or ["A", "B", "C"]
    words = json.loads((HERE / "words" / f"{loc}.json").read_text())
    DL.mkdir(parents=True, exist_ok=True)
    jobs = []
    for d in dirs:
        o = HERE / "out" / loc / d
        f = lambda dev, n: (o / dev / f"{n:02d}.png").as_uri()
        name = words[d]["name"]
        ph = [f("iphone", i) for i in range(1, 7)]
        pd = [f("ipad", i) for i in range(1, 7)]
        mc = [f("mac", i) for i in range(1, 6)]
        search = (search_card("iPhone search, with the \"Every app\" preview in front", [POSTER, ph[0], ph[1]],
                              note="The preview's poster frame (draft G, UI drawn as a stand-in) takes the first place; frames 1 and 2 follow.")
                  + search_card("iPhone search, with no preview", ph[:3], note="Frames 1 to 3, as search shows them today.")
                  + search_card("iPad search, with no preview", pd[:3], note="The iPad preview is not made yet; with it, frames 1 and 2 follow it as on iPhone.")
                  + search_card("Mac App Store search", mc[:1], w=1300, kind="mac", note="Landscape: one frame shows."))
        row = lambda imgs, wd, label: (f'<div class="lbl">{label}</div><div class="row">'
                                       + "".join(f'<figure><img src="{s}" style="width:{wd}px"><figcaption>{i+1}</figcaption></figure>' for i, s in enumerate(imgs))
                                       + '</div>')
        body = f'''<header><h1>Direction {d} · {esc(name)}</h1><p>{esc(IDEA[d])}</p></header>
<div class="search">{search}</div>
{row(ph, 520, "iPhone · 1320 × 2868 · 6 frames")}
{row(pd, 540, "iPad · 2064 × 2752 · 6 frames")}
{row(mc, 640, "Mac · 2880 × 1800 · 5 frames")}'''
        page = f'''<!doctype html><html><head><meta charset="utf-8"><link rel="stylesheet" href="{(HERE/'lib.css').as_uri()}"><style>
html,body{{width:3600px;background:#F4F4F2}} body{{padding:90px 100px;font-family:SF;color:#111}}
header h1{{font-size:84px;letter-spacing:-.03em;font-weight:700}} header p{{font-size:38px;color:#555;margin-top:14px;max-width:2900px;line-height:1.3}}
.search{{display:flex;gap:44px;margin:70px 0 30px;align-items:flex-start}}
.card{{background:#fff;border-radius:40px;box-shadow:0 2px 10px rgba(0,0,0,.06);overflow:hidden}}
.card .cap{{font-size:30px;font-weight:600;color:#444;padding:28px 48px 0}}
.card .note{{font-size:24px;color:#888;padding:0 48px 34px;line-height:1.3}}
.top{{display:flex;align-items:center;gap:30px;margin-bottom:34px}} .ic{{width:150px;border-radius:34px;box-shadow:0 0 0 1px #e5e5e5}}
.nm{{display:flex;flex-direction:column;gap:6px;flex:1}} .nm b{{font-size:44px;letter-spacing:-.01em}} .nm span{{font-size:34px;color:#8a8a8e}}
.get{{background:#EEF0F3;color:#0A84FF;font-weight:700;font-size:38px;border-radius:999px;padding:14px 50px}}
.shots{{display:flex}}
.lbl{{font-size:40px;font-weight:600;margin:80px 0 26px;color:#333}}
.row{{display:flex;gap:28px;flex-wrap:nowrap}}
figure{{display:flex;flex-direction:column;align-items:center;gap:12px}} figure img{{border-radius:22px;box-shadow:0 0 0 1px rgba(0,0,0,.08),0 6px 20px rgba(0,0,0,.08)}}
figcaption{{font-size:28px;color:#888}}
</style></head><body>{body}<script src="{(HERE.parent/'ready.js').as_uri()}"></script></body></html>'''
        hp = HERE / "out" / loc / f"sheet-{d}.html"
        hp.write_text(page)
        png = DL / f"{loc}-direction-{d}-{name.lower().replace(' ', '-')}.png"
        jobs.append({"html": str(hp), "png": str(png), "w": 3600, "h": 0})
    jf = HERE / "out" / "sheet-jobs.json"; jf.write_text(json.dumps(jobs))
    subprocess.run(["bun", str(HERE / "render-batch.mjs"), str(jf)], check=True)

if __name__ == "__main__":
    main()
