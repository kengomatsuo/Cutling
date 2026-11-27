"""Direction "Keys" (ASG148's d1: the app's tiles as chunky printed keycaps on a green sweep, path-traced) brought to
2.0 and laid out as one picture across every frame, for Personal details (50 languages) and Notes you paste (English).

A path trace costs minutes per frame, so it runs once per page and device, never per language:
  beauty  the still life with every key face printed blank and every screen dark (glyph keys printed: ⌘ ⇧ V)
  u, v    one sample per pixel at twice the size: which key face or screen each pixel shows, and where on it
Each language then prints its own faces and screens into an atlas (HTML) and a composite page lays them onto the
beauty, face by face (a face multiplies the lit white key; a screen adds its light), with the headline on top.

The camera slides along x per column (keys/pt.html), so each frame is traced on its own and meets its neighbours at the
seams; keys lie across every seam, devices never do.

    python3 keys.py scenes                     write keys/scenes/<set>.glsl.js
    python3 keys.py preview <set> [frame]      third-size, 24-sample look (keys/previews/)
    python3 keys.py trace <set> [--remote]     beauty + u + v per frame (keys/renders/<set>/), on the PC with --remote
    (frames per language: build.py personal-details / notes-you-paste)"""
import json, math, os, subprocess, sys
from pathlib import Path

import lib
from lib import esc

K = lib.HERE / "keys"
RENDER = lib.HERE.parent / "render.mjs"
KH = 2.3
KS = (5.5, 3.75)
KIND = {
    "phone": dict(h=(3.85, 8.15), t=.8, c=1.32, bi=.1, bc=1.24, s=(3.69, 8.015), sc=1.16, px=(1320, 2868)),
    "pad": dict(h=(5.3, 7.07), t=.6, c=.9, bi=.12, bc=.8, s=(4.95, 6.6), sc=.5, px=(2064, 2752)),
}
FACE = (1208, 824)
DEV = {"iphone": dict(w=1320, h=2868, wv=13.8, atz=1.2), "ipad": dict(w=2064, h=2752, wv=17., atz=-1.),
       # the App Store banner (ASG253): one 5244 x 2950 picture, its face passes at 1x (2x would not fit the GPU)
       "banner": dict(w=5244, h=2950, wv=78., atz=0., uv=1)}


def key(face, x, z, yaw, lift=0., tilt=0.):
    return dict(face=face, x=x, z=z, yaw=yaw, lift=lift, tilt=tilt)


def dev(kind, x, z, yaw, scale, screen, lift=0.):
    return dict(kind=kind, x=x, z=z, yaw=yaw, scale=scale, screen=screen, lift=lift)


def small(x, z, yaw, glyph=None):
    return dict(x=x, z=z, yaw=yaw, glyph=glyph)


# Each set: frames, then per frame (x measured from that frame's centre, in world units; a frame is wv wide) its
# devices, keys and small keys. A key whose |x| passes wv/2 lies across a seam.
W2 = 6.9   # half an iPhone frame
P2 = 8.5   # half an iPad frame
SETS = {
    # Personal details: 1 the address key | 2 a form filled by the keyboard | 3 the bank, booking and phone keys
    # | 4 the grid | 5 any app (Try It) | 6 iPhone, iPad and Mac
    "pd-iphone": dict(dev="iphone", n=6, frames=[
        dict(keys=[key("home", -.6, 3.2, -.12)], smalls=[small(4.4, -2.6, .4), small(-4.6, 10.8, -.3)],
             cross=key("bank", W2, 14.0, .2)),
        dict(devs=[dev("phone", .8, .6, .07, 1.05, "form")], cross=key("booking", W2, 14.2, -.16)),
        dict(keys=[key("phone", .2, -.6, .08), key("wifi", -.6, 6.6, -.12)], smalls=[small(4.2, -5.6, -.2)],
             cross=key("social", W2 + .2, 14.0, .18)),
        dict(devs=[dev("phone", -.7, .6, -.07, 1.05, "grid")], cross=key("meeting", W2, 14.2, -.14)),
        dict(devs=[dev("phone", .7, .6, .06, 1.05, "guide")], cross=key("sig", W2 - .2, 14.1, .16)),
        dict(devs=[dev("pad", -1.6, 1.6, -.1, .92, "pad-grid"), dev("phone", 3.0, 7.2, .12, .72, "grid2", lift=.55)],
             smalls=[small(-.2, 15.4, .2, "⌘"), small(2.8, 15.7, -.15, "⇧"), small(5.6, 15.3, .1, "V")]),
    ]),
    "pd-ipad": dict(dev="ipad", n=6, frames=[
        dict(keys=[key("home", -1.2, 1.0, -.12)], smalls=[small(5.4, -3.6, .4), small(-6.4, 6.6, -.3)],
             cross=key("bank", P2 + .4, 9.6, .2)),
        dict(devs=[dev("pad", .9, -.6, .06, .9, "pad-form")], cross=key("booking", P2, 9.7, -.16)),
        dict(keys=[key("phone", -.8, 1.0, .08)], smalls=[small(-6.2, -3.2, -.2), small(5.8, -2.6, .3)],
             cross=key("social", P2 + .2, 9.6, .18)),
        dict(devs=[dev("pad", -.9, -.6, -.06, .9, "pad-grid")], cross=key("meeting", P2, 9.7, -.14)),
        dict(devs=[dev("pad", .9, -.6, .05, .9, "pad-guide")], cross=key("sig", P2 - .2, 9.8, .16)),
        dict(devs=[dev("pad", -2.0, .4, -.08, .84, "pad-grid"), dev("phone", 5.0, 3.6, .14, .64, "grid2", lift=.5)],
             smalls=[small(-1.4, 9.8, .15, "⌘"), small(1.3, 10.1, -.1, "⇧"), small(4.0, 9.9, .12, "V")]),
    ]),
    # Notes you paste (English): 1 the note key | 2 the note being written | 3 pasted as written | 4 address and
    # account keys | 5 room for 5,000 | 6 iPhone, iPad and Mac
    "np-iphone": dict(dev="iphone", n=6, frames=[
        dict(keys=[key("n_welcome", -.6, 3.2, -.12)], smalls=[small(4.4, -2.6, .4), small(-4.6, 10.8, -.3)],
             cross=key("n_account", W2, 14.0, .2)),
        dict(devs=[dev("phone", .8, .6, .07, 1.05, "note")], cross=key("n_thanks", W2, 14.2, -.16)),
        dict(devs=[dev("phone", -.7, .6, -.07, 1.05, "formatted")], cross=key("n_home", W2, 14.2, .14)),
        dict(keys=[key("n_directions", .2, -.6, .08), key("n_account2", -.6, 6.6, -.12)], smalls=[small(4.2, -5.6, -.2)],
             cross=key("n_booking", W2 + .2, 14.0, .18)),
        dict(devs=[dev("phone", .7, .6, .06, 1.05, "grid2")], cross=key("n_order", W2 - .2, 14.1, .16)),
        dict(devs=[dev("pad", -1.6, 1.6, -.1, .92, "pad-grid"), dev("phone", 3.0, 7.2, .12, .72, "grid2", lift=.55)],
             smalls=[small(-.2, 15.4, .2, "⌘"), small(2.8, 15.7, -.15, "⇧"), small(5.6, 15.3, .1, "V")]),
    ]),
    "np-ipad": dict(dev="ipad", n=6, frames=[
        dict(keys=[key("n_welcome", -1.2, 1.0, -.12)], smalls=[small(5.4, -3.6, .4), small(-6.4, 6.6, -.3)],
             cross=key("n_account", P2 + .4, 9.6, .2)),
        dict(devs=[dev("pad", .9, -.6, .06, .9, "pad-note")], cross=key("n_thanks", P2, 9.7, -.16)),
        dict(devs=[dev("phone", -.4, .7, -.07, .88, "formatted")], cross=key("n_home", P2, 9.7, .14)),
        dict(keys=[key("n_account2", -.8, 1.0, .08)], smalls=[small(-6.2, -3.2, -.2), small(5.8, -2.6, .3)],
             cross=key("n_booking", P2 + .2, 9.6, .18)),
        dict(devs=[dev("phone", .5, .7, .06, .88, "grid2")], cross=key("n_order", P2 - .2, 9.8, .16)),
        dict(devs=[dev("pad", -2.0, .4, -.08, .84, "pad-grid"), dev("phone", 5.0, 3.6, .14, .64, "grid2", lift=.5)],
             smalls=[small(-1.4, 9.8, .15, "⌘"), small(1.3, 10.1, -.1, "⇧"), small(4.0, 9.9, .12, "V")]),
    ]),
    # Banners (ASG253): the key sits in Apple's safe area under the headline; devices and keys lie around it as backdrop
    "pd-banner": dict(dev="banner", n=1, frames=[
        dict(keys=[key("home", 0., -.5, -.07), key("bank", -14.0, 10.6, .18), key("sig", 14.4, 10.8, -.14),
                   key("wifi", -17.2, -8.2, -.2), key("booking", 17.4, -8.8, .16)],
             devs=[dev("phone", -30.0, -.6, .12, 1.05, "form"), dev("phone", 30.0, -.6, -.12, 1.05, "grid")],
             smalls=[small(-10.0, -13.2, .3), small(10.6, -14.4, -.25), small(-5.6, 15.2, .4),
                     small(0.5, 16.2, .2, "⌘"), small(4.4, 16.6, -.1, "⇧"), small(8.3, 16.3, .12, "V")]),
    ]),
    "np-banner": dict(dev="banner", n=1, frames=[
        dict(keys=[key("n_welcome", 0., -.5, -.07), key("n_account", -14.0, 10.6, .18), key("n_home", 14.4, 10.8, -.14),
                   key("n_directions", -17.2, -8.2, -.2), key("n_thanks", 17.4, -8.8, .16)],
             devs=[dev("phone", -30.0, -.6, .12, 1.05, "note"), dev("phone", 30.0, -.6, -.12, 1.05, "grid2")],
             smalls=[small(-10.0, -13.2, .3), small(10.6, -14.4, -.25), small(-5.6, 15.2, .4),
                     small(0.5, 16.2, .2, "⌘"), small(4.4, 16.6, -.1, "⇧"), small(8.3, 16.3, .12, "V")]),
    ]),
}


def world(name):
    """The set's devices, keys and small keys in world coordinates, the page's x running left to right."""
    S = SETS[name]; D = DEV[S["dev"]]; n = S["n"]; wv = D["wv"]
    devs, keys, smalls = [], [], []
    for i, f in enumerate(S["frames"]):
        cx = (i - (n - 1) / 2) * wv
        for d in f.get("devs", []):
            devs.append(dict(d, x=cx + d["x"]))
        for k in f.get("keys", []):
            keys.append(dict(k, x=cx + k["x"]))
        if f.get("cross") and i < n - 1:
            keys.append(dict(f["cross"], x=cx + f["cross"]["x"]))
        for s in f.get("smalls", []):
            smalls.append(dict(s, x=cx + s["x"]))
    return devs, keys, smalls


def layout(name):
    """Where each screen, key face and glyph sits on the atlas (the same for every language)."""
    devs, keys, smalls = world(name)
    x = 0; screens = []
    for d in devs:
        w, h = KIND[d["kind"]]["px"]
        d["rect"] = (x, 0, w, h); screens.append(dict(screen=d["screen"], kind=d["kind"], x=x, y=0, w=w, h=h)); x += w + 40
    faces = []
    per = 4
    for i, k in enumerate(keys):
        k["rect"] = (x + (i % per) * (FACE[0] + 8), (i // per) * (FACE[1] + 8))
        faces.append(dict(face=k["face"], x=k["rect"][0], y=k["rect"][1]))
    gy = ((len(keys) + per - 1) // per) * (FACE[1] + 8)
    glyphs = []
    for i, s in enumerate([s for s in smalls if s["glyph"]]):
        s["rect"] = (x + i * 408, gy); glyphs.append(dict(x=s["rect"][0], y=gy, text=s["glyph"]))
    Wd = x + per * (FACE[0] + 8)
    Ht = max([s["h"] for s in screens] + [gy + 400])
    return dict(W=Wd, H=Ht, screens=screens, faces=faces, glyphs=glyphs), devs, keys, smalls


v = lambda *a: "vec%d(%s)" % (len(a), ", ".join("%.4f" % x for x in a))
arr = lambda t, xs: "%s[%d](%s)" % (t, len(xs), ", ".join(xs))


def glsl(name):
    at, devs, keys, smalls = layout(name)
    S = SETS[name]; D = DEV[S["dev"]]
    aspect = D["w"] / D["h"]
    fov = math.degrees(2 * math.atan(D["wv"] / (200. * aspect)))
    keys_ = keys or [dict(x=0, z=900, yaw=0, lift=0, tilt=0, rect=(0, 0))]
    smalls_ = smalls or [dict(x=0, z=900, yaw=0, glyph=None)]
    Dd = []
    for d in devs:
        Kd, s = KIND[d["kind"]], d["scale"]
        Dd.append((v(d["x"], d["z"], d["yaw"], d["lift"]), v(Kd["h"][0] * s, Kd["h"][1] * s, Kd["c"] * s, Kd["t"] * s),
                   v(Kd["bi"] * s, Kd["bc"] * s, Kd["sc"] * s), v(Kd["s"][0] * s, Kd["s"][1] * s), v(*d["rect"])))
    src = (lib.HERE.parent / "d1" / "gen.py").read_text()
    # the scene body is d1/gen.py's own, so the keys, devices, floor and light are the candidate's
    import importlib.util
    spec = importlib.util.spec_from_file_location("gen", lib.HERE.parent / "d1" / "gen.py")
    gen = importlib.util.module_from_spec(spec); spec.loader.exec_module(gen)
    sc = dict(w=D["w"], h=D["h"], wv=D["wv"], atz=D["atz"], devices=[dict(d) for d in devs], keys=keys, smalls=smalls)
    for d, dd in zip(sc["devices"], devs):
        d["rect"] = dd["rect"]
    body = gen.glsl(name, sc, at)
    face_uv = f'''
vec3 faceUV(int id, vec3 p){{
  if(id >= 300){{
    int i = id - 300; vec3 q = devQ(i, p);
    if(q.y > DB[i].w - .02 && rrect(q.xz, DS[i], DZ[i].z) < 0.) return vec3(float(200 + i), q.x / DS[i].x * .5 + .5, q.z / DS[i].y * .5 + .5);
    return vec3(0); }}
  if(id >= 100 && id < 200){{
    int i = id - 100; vec3 q = keyQ(i, p); vec2 f = q.xz / (KS - .32);
    if(q.y > KH - .4 && max(abs(f.x), abs(f.y)) < .93) return vec3(float(1 + i), f.x / .93 * .5 + .5, f.y / .93 * .5 + .5);
  }}
  return vec3(0); }}
'''
    body = body.replace("const int NL = 2;", face_uv + "const int NL = 2;")
    return body, at


def write_scenes():
    (K / "scenes").mkdir(parents=True, exist_ok=True)
    for name in SETS:
        body, at = glsl(name)
        (K / "scenes" / f"{name}.glsl.js").write_text(body)
        (K / "scenes" / f"{name}.layout.json").write_text(json.dumps(at, indent=1))
        print(name, at["W"], at["H"])


# ------------------------------------------------------------------ atlas (per language)

def faces(loc):
    sd = lib.seed(loc)
    first = lambda s: s.split("\n")[0]
    f = {k: (lib.ICONS[k][0], lib.ICONS[k][1], n, first(val) + ("…" if "\n" in val or len(val) > 26 else ""))
         for k, (n, val) in sd.items()}
    f["n_welcome"] = ("textformat", "#CB30E0", "Welcome note", "Welcome to the studio!…")
    f["n_directions"] = ("map.fill", "#34C759", "Directions", "Upstairs from the flower shop…")
    f["n_account"] = ("banknote", "#34C759", "Account number", "0441 2290 18")
    f["n_account2"] = f["n_account"]
    f["n_thanks"] = ("text.bubble.fill", "#FF2D55", "Thank you", "Thank you so much for…")
    f["n_home"] = ("house.fill", "#0088FF", "Home address", "14 Linden Road, Flat 3")
    f["n_home2"] = f["n_home"]
    f["n_booking"] = ("calendar", "#FF8D28", "Booking", "Your table is booked…")
    f["n_order"] = ("shippingbox.fill", "#00B8D9", "Order update", 'Hi <u>Name</u>, your order…')
    return f


def screen_html(loc, scr, kind, own, W):
    """One screen at its capture's pixels: a real capture with the status bar redrawn, or a drawn 2.0 screen."""
    pad = kind == "pad"
    nw, nh = KIND[kind]["px"]
    sb = lambda col, dark=True: m_sbar(nw, col, dark, pad)
    isl = "" if pad else (f'<div style="position:absolute;width:{nw*.265}px;height:{nw*.078}px;left:{(nw-nw*.265)/2}px;top:{nw*.027}px;'
                          f'background:#000;border-radius:999px"></div>')
    cap = lambda key, col="#F2F2F7", dark=True: f'<img src="{lib.cap(loc, key)}" style="position:absolute;left:0;top:0;width:100%">{sb(col, dark)}{isl}'
    if scr == "grid":
        inner = cap("phone-grid")
    elif scr == "grid2":
        inner = cap("phone-grid2") if loc in lib.ENGLISH else cap("phone-grid")
    elif scr == "guide":
        inner = cap("phone-guide", "#000", False)
    elif scr == "note":
        inner = cap("phone-note", "#E9E9EC")
    elif scr == "formatted":
        inner = cap("phone-formatted", "#C7C7CC")
    elif scr == "pad-grid":
        inner = cap("pad-grid")
    elif scr == "pad-guide":
        inner = cap("pad-guide", "#000", False)
    elif scr in ("form", "pad-form"):
        inner = lib.form_page(pad, loc) + sb("#F2F2F7") + isl
    elif scr == "pad-note":
        n = own["demo"]["note"]
        lines = [("b", esc(n[0])), ("p", esc(n[1]))] + [("li", esc(t)) for t in n[2:]]
        inner = lib.note_page(True, lines) + sb("#E9E9EC")
    return f'<div style="position:absolute;width:{nw}px;height:{nh}px;overflow:hidden;background:#fff">{inner}</div>'


def m_sbar(nw, col, dark, pad):
    return lib.m.sbar(nw, col, dark, pad=pad)


ATLAS_CSS = """
.face{position:absolute;width:1208px;height:824px;background:#fff;box-sizing:border-box;padding:96px 92px 0 104px;overflow:hidden}
.face .ic{height:170px;display:flex;align-items:center}
.face b{display:block;font-weight:650;font-size:124px;line-height:1.05;letter-spacing:-.02em;margin-top:80px;color:#000;white-space:nowrap}
.face i{display:block;font-weight:400;font-size:82px;line-height:1.1;font-style:normal;letter-spacing:-.01em;margin-top:40px;color:#8A8A8E;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.face i u{text-decoration:none;color:#00A878;font-weight:600}
.glyph{position:absolute;width:400px;height:400px;background:#fff;font:500 250px/400px SF;text-align:center;color:#111}
"""
ATLAS_FIT = """<script>addEventListener('load',async()=>{await document.fonts.ready;for(const b of document.querySelectorAll('.face b')){let fs=124;
while(b.scrollWidth>b.clientWidth+1&&fs>60){fs-=3;b.style.fontSize=fs+'px';}}});</script>"""


def atlas(loc, name, own, path, mode="print"):
    """mode print: the language's faces and screens. mode blank: white faces, black screens, glyphs printed (the beauty pass)."""
    at = json.loads((K / "scenes" / f"{name}.layout.json").read_text())
    F = faces(loc)
    parts = []
    for s in at["screens"]:
        if mode == "blank":
            parts.append(f'<div style="position:absolute;left:{s["x"]}px;top:{s["y"]}px;width:{s["w"]}px;height:{s["h"]}px;background:#000"></div>')
        else:
            parts.append(f'<div style="position:absolute;left:{s["x"]}px;top:{s["y"]}px">{screen_html(loc, s["screen"], s["kind"], own, s["w"])}</div>')
    for f in at["faces"]:
        if mode == "blank":
            parts.append(f'<div class="face" style="left:{f["x"]}px;top:{f["y"]}px"></div>')
            continue
        icon, col, title, prev = F[f["face"]]
        parts.append(f'<div class="face" style="left:{f["x"]}px;top:{f["y"]}px"><div class="ic">{lib.symbol(icon, 150, col)}</div>'
                     f'<b>{esc(title)}</b><i>{prev if "<u>" in prev else esc(prev)}</i></div>')
    # the glyph keys are traced into the beauty pass; mirrored for a right-to-left language they read ⌘ ⇧ V from the right
    for g in at["glyphs"]:
        parts.append(f'<div class="glyph" style="left:{g["x"]}px;top:{g["y"]}px">{g["text"]}</div>')
    page = lib.m.page(at["W"], at["H"], "".join(parts), ATLAS_CSS, loc).replace("</head>", ATLAS_FIT + "</head>", 1)
    if loc in lib.RTL:   # faces and drawn screens read right to left; the atlas itself is a plain picture
        page = page.replace(' dir="rtl"', "", 1)
        page = page.replace('class="face"', 'class="face" dir="rtl"')
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(page)
    lib.m.JOBS.append({"html": str(path), "png": str(path.with_suffix(".png")), "w": at["W"], "h": at["H"]})
    return path.with_suffix(".png")


# ------------------------------------------------------------------ tracing

def trace_jobs(name, spp=160, frames=None):
    """The beauty, u and v passes per frame: (query, out, width, height)."""
    S = SETS[name]; D = DEV[S["dev"]]; n = S["n"]
    w, h = D["w"], D["h"]
    jobs = []
    for i in range(n):
        if frames and i + 1 not in frames:
            continue
        jobs.append((f"pt.html?scene={name}&spp={spp}&atlas=renders/{name}/blank.png&fw={w*n}&fh={h}&ox={i*w}", f"renders/{name}/{i+1:02d}-beauty.png", w, h))
        s = D.get("uv", 2)
        for p in ("u", "v"):
            jobs.append((f"pt.html?scene={name}&pass={p}&atlas=renders/{name}/blank.png&fw={s*w*n}&fh={s*h}&ox={s*i*w}", f"renders/{name}/{i+1:02d}-{p}.png", s * w, s * h))
    return jobs


def preview(name, frames=None):
    S = SETS[name]; D = DEV[S["dev"]]; n = S["n"]
    w, h = D["w"] // (6 if D["w"] > 3000 else 3), D["h"] // (6 if D["w"] > 3000 else 3)
    (K / "previews").mkdir(exist_ok=True)
    blank_atlas(name)
    outs = []
    for i in range(n):
        if frames and i + 1 not in frames:
            continue
        out = f"previews/{name}-{i+1:02d}.png"
        q = f"pt.html?scene={name}&spp=24&atlas=renders/{name}/blank.png&fw={w*n}&fh={h}&ox={i*w}"
        subprocess.run(["bun", str(RENDER), q, out, str(w), str(h)], cwd=K, check=True)
        outs.append(str(K / out))
    return outs


def blank_atlas(name):
    p = K / "renders" / name / "blank.html"
    if not p.with_suffix(".png").exists():
        atlas("en-US", name, {}, p, mode="blank")
        lib.run()


def trace(name, remote=False, spp=160, frames=None):
    blank_atlas(name)
    jobs = trace_jobs(name, spp, frames)
    if not remote:
        for q, out, w, h in jobs:
            subprocess.run(["bun", str(RENDER), q, out, str(w), str(h)], cwd=K, check=True)
        return
    # the PC: copy the tracer, the scene and the blank atlas, run there, copy the passes back
    R = "C:/Users/kenne/cutling-keys"
    files = ["pt.html", f"scenes/{name}.glsl.js", f"renders/{name}/blank.png"]
    subprocess.run(["ssh", "win-pc", f"New-Item -ItemType Directory -Force -Path {R}/scenes,{R}/renders/{name} | Out-Null"], check=True)
    for f in files:
        subprocess.run(["scp", "-q", str(K / f), f"win-pc:{R}/{f}"], check=True)
    subprocess.run(["scp", "-q", str(K / "render-win.mjs"), f"win-pc:{R}/render-win.mjs"], check=True)
    script = "; ".join(f'bun render-win.mjs "{q}" {out} {w} {h}' for q, out, w, h in jobs)
    subprocess.run(["ssh", "win-pc", f"cd {R}; {script}"], check=True)
    for q, out, w, h in jobs:
        subprocess.run(["scp", "-q", f"win-pc:{R}/{out}", str(K / out)], check=True)


def black(path):
    if not Path(path).exists():
        return True
    r = subprocess.run(["magick", str(path), "-format", "%[fx:maxima]", "info:"], capture_output=True, text=True)
    return float(r.stdout or 0) == 0


def fix(name, spp=160, tries=4):
    """The PC's GPU drops some runs and returns a black picture. Every pass is checked; a black face pass (one sample
    a pixel) is traced again here on the Mac, a black beauty pass again on the PC, up to `tries` times."""
    jobs = trace_jobs(name, spp)
    R = "C:/Users/kenne/cutling-keys"
    for t in range(tries):
        bad = [j for j in jobs if black(K / j[1])]
        if not bad:
            print(name, "all passes good"); return True
        print(name, "try", t + 1, "redo", [b[1] for b in bad])
        for q, out, w, h in bad:
            if "beauty" in out and t < tries - 1:
                subprocess.run(["ssh", "win-pc", f'cd {R}; bun render-win.mjs "{q}" {out} {w} {h}'])
                subprocess.run(["scp", "-q", f"win-pc:{R}/{out}", str(K / out)])
            else:
                subprocess.run(["bun", str(RENDER), q, out, str(w), str(h)], cwd=K)
    return not any(black(K / j[1]) for j in jobs)


if __name__ == "__main__":
    a = sys.argv[1:]
    if a[0] == "scenes":
        write_scenes()
    elif a[0] == "preview":
        fr = [int(x) for x in a[2:]] or None
        print("\n".join(preview(a[1], fr)))
    elif a[0] == "fix":
        for n in a[1:]:
            fix(n)
    elif a[0] == "trace":
        fr = [int(x) for x in a[2:] if x.isdigit()] or None
        trace(a[1], "--remote" in a, int(os.environ.get("SPP", "160")), fr)


# ------------------------------------------------------------------ composite (per language, per frame)

COMP_JS = r"""<script>
(async()=>{try{
const C=window.COMP,cv=document.getElementById('cv'),gl=cv.getContext('webgl2',{preserveDrawingBuffer:true,antialias:false});
const load=s=>new Promise((r,j)=>{const i=new Image();i.onload=()=>r(i);i.onerror=()=>j(new Error('missing '+s));i.src=s;});
const [B,U,V,A]=await Promise.all([C.beauty,C.u,C.v,C.atlas].map(load));
gl.pixelStorei(gl.UNPACK_COLORSPACE_CONVERSION_WEBGL,gl.NONE);
const tex=(img,unit,lin)=>{const t=gl.createTexture();gl.activeTexture(gl.TEXTURE0+unit);gl.bindTexture(gl.TEXTURE_2D,t);
 gl.texImage2D(gl.TEXTURE_2D,0,gl.RGBA8,gl.RGBA,gl.UNSIGNED_BYTE,img);
 const f=lin?gl.LINEAR:gl.NEAREST;gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,f);gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,f);
 gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE);gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE);};
tex(B,0,true);tex(U,1,false);tex(V,2,false);tex(A,3,true);
const vs=`#version 300 es
void main(){gl_Position=vec4(vec2(gl_VertexID==1?3:-1,gl_VertexID==2?3:-1),0,1);}`;
const fs=`#version 300 es
precision highp float;uniform sampler2D B,U,V,A;uniform vec2 S,AS;uniform vec4 KR[64];uniform vec4 SR[8];uniform int FLIP;out vec4 o;
vec3 lin(vec3 c){return mix(c/12.92,pow((c+.055)/1.055,vec3(2.4)),step(.04045,c));}
vec3 srgb(vec3 c){return mix(c*12.92,1.055*pow(max(c,0.),vec3(1./2.4))-.055,step(.0031308,c));}
vec3 neutral(vec3 c){float x=min(c.r,min(c.g,c.b));float off=x<.08?x-6.25*x*x:.04;c-=off;float pk=max(c.r,max(c.g,c.b));if(pk<.76)return c;
 float d=.24;float np=1.-d*d/(pk+d-.76);c*=np/pk;float g=1.-1./(.15*(pk-np)+1.);return mix(c,np*vec3(1),g);}
void main(){ivec2 p=ivec2(FLIP==1?S.x-1.-gl_FragCoord.x:gl_FragCoord.x,S.y-1.-gl_FragCoord.y);vec2 uv=(vec2(p)+.5)/S;
 vec3 b=lin(texture(B,uv).rgb);vec4 u=texelFetch(U,p,0)*255.,v=texelFetch(V,p,0)*255.;int code=int(u.r+.5);
 float s=(u.g*256.+u.b)/65535.,t=(v.g*256.+v.b)/65535.;if(FLIP==1)s=1.-s;vec3 c=b;
 if(code>=1&&code<200){vec4 r=KR[code-1];c=b*lin(texture(A,(r.xy+vec2(s,t)*r.zw)/AS).rgb);}
 else if(code>=200){vec4 r=SR[code-200];c=neutral(lin(texture(A,(r.xy+vec2(s,t)*r.zw)/AS).rgb)*.928)+b;}
 o=vec4(srgb(c),1);}`;
const sh=(t,s)=>{const x=gl.createShader(t);gl.shaderSource(x,s);gl.compileShader(x);if(!gl.getShaderParameter(x,gl.COMPILE_STATUS))throw new Error(gl.getShaderInfoLog(x));return x;};
const P=gl.createProgram();gl.attachShader(P,sh(gl.VERTEX_SHADER,vs));gl.attachShader(P,sh(gl.FRAGMENT_SHADER,fs));gl.linkProgram(P);gl.useProgram(P);
['B','U','V','A'].forEach((n,i)=>gl.uniform1i(gl.getUniformLocation(P,n),i));
gl.uniform2f(gl.getUniformLocation(P,'S'),cv.width,cv.height);gl.uniform2f(gl.getUniformLocation(P,'AS'),A.width,A.height);
const kr=new Float32Array(256);C.keys.forEach((r,i)=>kr.set(r,i*4));gl.uniform4fv(gl.getUniformLocation(P,'KR'),kr);
const sr=new Float32Array(32);C.screens.forEach((r,i)=>sr.set(r,i*4));gl.uniform4fv(gl.getUniformLocation(P,'SR'),sr);
gl.uniform1i(gl.getUniformLocation(P,'FLIP'),C.flip?1:0);gl.viewport(0,0,cv.width,cv.height);gl.drawArrays(gl.TRIANGLES,0,3);gl.finish();
await document.fonts.ready;
for(const h of document.querySelectorAll('.kh')){let fs=parseFloat(h.style.fontSize);const max=+h.dataset.w;
 const wide=()=>[...h.querySelectorAll('.ln')].reduce((a,l)=>Math.max(a,l.getBoundingClientRect().width),0);
 while(wide()>max+1&&fs>50){fs*=.97;h.style.fontSize=fs+'px';}}
for(const f of document.querySelectorAll('.kf')){let s=parseFloat(f.style.fontSize);const max=+document.querySelector('.kh').dataset.w;while(f.scrollWidth>max+1&&s>30){s*=.97;f.style.fontSize=s+'px';}}
await new Promise(r=>setTimeout(r,400));window.__done=true;
}catch(e){window.__error='ERR '+e.message;throw e;}})();
</script>"""

KEYS_CSS = """
html,body{margin:0;overflow:hidden;background:#17a37a}
#cv{position:absolute;left:0;top:0}
.kh{position:absolute;margin:0;font-family:-apple-system,"SF Pro Display",system-ui;font-weight:800;letter-spacing:-.025em;color:#04261C;white-space:nowrap;z-index:5}
.kh em{font-style:normal;color:#fff}
.kf{position:absolute;font-family:-apple-system,"SF Pro Display",system-ui;font-weight:700;letter-spacing:-.01em;color:#04261C;opacity:.8;white-space:nowrap;z-index:5}
"""


def head_html(t, dev, rtl, loc):
    """A Keys headline: *x* is the white phrase, | a line break."""
    import re as _re
    size, left, top = (178, 92, 132) if dev == "iphone" else (236, 120, 150)
    if loc == "ur-PK":   # Nastaliq needs nearly twice Latin's line height, so its lines are set smaller to keep clear of the devices
        size *= .78
    w = (1320 if dev == "iphone" else 2064) - 2 * left
    lines = []
    for ln in t["h"].split("|"):
        ln = _re.sub(r"\*(.+?)\*", lambda mm: f"<em>{esc(mm.group(1))}</em>", esc(ln).replace("&lt;", "<").replace("&gt;", ">")) if "*" in ln else esc(ln)
        lines.append(f'<span class="ln">{ln}</span>')
    lh = {"th": 1.3, "ar-SA": 1.25, "ur-PK": 1.7, "he": 1.1, **{l: 1.28 for l in ("hi", "mr-IN", "bn-BD", "gu-IN", "pa-IN", "or-IN", "kn-IN", "te-IN", "ml-IN", "ta-IN")}}.get(loc, 1.04)
    side = "right" if rtl else "left"
    out = (f'<h1 class="kh" data-w="{w}" style="{side}:{left}px;top:{top}px;font-size:{size}px;line-height:{lh}">' + "<br>".join(lines) + '</h1>')
    if t.get("f"):
        out += (f'<div class="kf" style="{side}:{left+4}px;top:{top + size*lh*len(lines) + 40}px;font-size:{size*.4}px">{esc(t["f"])}</div>')
    return out


def build(loc, dev, out_dir, page):
    """One language's frames for a Keys page: the atlas (queued and rendered first), then a composite page per frame."""
    name = f"{page}-{dev}"
    W, own = lib.words(loc)
    T = own[{"pd": "keys_pd", "np": "keys_np"}[page]]
    at = json.loads((K / "scenes" / f"{name}.layout.json").read_text())
    S = SETS[name]; D = DEV[S["dev"]]; n = S["n"]; w, h = D["w"], D["h"]
    out_dir.mkdir(parents=True, exist_ok=True)
    apng = atlas(loc, name, own, out_dir / "atlas.html")
    keys_r = [[f["x"], f["y"], FACE[0], FACE[1]] for f in at["faces"]]
    scr_r = [[s["x"], s["y"], s["w"], s["h"]] for s in at["screens"]]
    rtl = loc in lib.RTL
    pages = []
    for i in range(n):
        rd = K / "renders" / name
        # a right-to-left language runs the mirrored picture from the right: its frame i is traced frame i mirrored, so
        # laid out right to left the frames meet (geometry and light only: the faces are printed after, the right way round)
        j = i
        comp = dict(beauty=(rd / f"{j+1:02d}-beauty.png").as_uri(), u=(rd / f"{j+1:02d}-u.png").as_uri(), v=(rd / f"{j+1:02d}-v.png").as_uri(),
                    atlas=apng.as_uri(), keys=keys_r, screens=scr_r, flip=rtl)
        body = (f'<canvas id="cv" width="{2*w}" height="{2*h}" style="width:{w}px;height:{h}px"></canvas>'
                + head_html(T[str(i + 1)], dev, rtl, loc))
        fonts = lib.m.locale_css(loc)
        html_ = (f'<!doctype html><html lang="{loc}"><head><meta charset="utf-8"><link rel="stylesheet" href="{(lib.V2 / "lib.css").as_uri()}">'
                 f'<style>{KEYS_CSS} body{{width:{w}px;height:{h}px}} {fonts} .kh,.kf{{font-family:-apple-system,"SF Pro Display",system-ui{"," + _head_font(loc) if _head_font(loc) else ""}}}</style>'
                 f'<script>window.COMP={json.dumps(comp)}</script></head><body{" dir=rtl" if rtl else ""}>{body}{COMP_JS}</body></html>')
        p = out_dir / f"{i+1:02d}.html"
        p.write_text(html_)
        pages.append({"html": str(p), "png": str(out_dir / f"{i+1:02d}.png"), "w": w, "h": h})
    return pages


def _head_font(loc):
    import poster
    return poster.HEAD_FONT.get(loc, "")
