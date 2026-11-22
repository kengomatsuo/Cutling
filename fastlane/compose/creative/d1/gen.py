#!/usr/bin/env python3
"""Direction 1 "Keys": writes one still-life scene (scene-<name>.glsl.js) and its texture atlas per frame, from a
short description of what lies on the sweep: devices showing a screen, printed keys, small blank or glyph keys.
   python3 gen.py write            every scene and atlas
   python3 gen.py preview          a third-size, 16-sample look at each (previews/<name>.png)
   python3 gen.py render [names]   the full renders, one after another (renders/<name>.png)"""
import json, math, os, subprocess, sys, urllib.parse
HERE = os.path.dirname(os.path.abspath(__file__))
KH, KS = 2.3, (5.5, 3.75)
KIND = {  # half body, thickness, corner, bezel inset, bezel corner, half screen, screen corner, screen pixels
  "phone": dict(h=(3.85, 8.15), t=.8, c=1.32, bi=.1, bc=1.24, s=(3.69, 8.015), sc=1.16, px=(1320, 2868)),
  "pad":   dict(h=(5.3, 7.07), t=.6, c=.9, bi=.12, bc=.8, s=(4.95, 6.6), sc=.5, px=(2064, 2752)),
}
F = {  # key faces: icon, name, first line
  "home": ("house", "Home Address", "123 Main Street, Apt 4B…"), "sig": ("envelope", "Email Signature", "Best regards,…"),
  "email": ("at", "Work Email", "alex@example.com"), "wifi": ("wifi", "Wi-Fi Password", "c0ff33-Sh0p-2024!"),
  "booking": ("airplane", "Booking Ref", "FLT-2026-XKCD42"), "meeting": ("video", "Meeting Link", "https://meet.example…"),
  "door": ("doc", "Office door", "Code 4815, then push…"), "order": ("doc", "Order Reply", "Hi <u>Name</u>, your order…"),
  "phone": ("phone", "Phone Number", "+1 (555) 234-5678"),
}
def dev(kind, x, z, yaw, scale, screen, lift=0.): return dict(kind=kind, x=x, z=z, yaw=yaw, scale=scale, screen=screen, lift=lift)
def key(face, x, z, yaw, lift=0., tilt=0.): return dict(face=face, x=x, z=z, yaw=yaw, lift=lift, tilt=tilt)
def small(x, z, yaw, glyph=None): return dict(x=x, z=z, yaw=yaw, glyph=glyph)
LEAN_PHONE, LEAN_PAD = .17, .085     # a key whose far edge rests on the device: asin(thickness / 7.5)
SCENES = {
  # iPhone frames 4 to 8: the phone under the headline, one printed key leaning on its foot
  "ph4": dict(w=1320, h=2868, wv=13.8, atz=1.2, devices=[dev("phone", .3, 2.6, .1, 1.25, "phone/grid")],
              keys=[key("booking", 1.2, 14.0, -.1, tilt=LEAN_PHONE)], smalls=[small(-5.3, 12.9, .4)]),
  "ph5": dict(w=1320, h=2868, wv=13.8, atz=1.2, devices=[dev("phone", -.3, 2.6, -.1, 1.25, "phone/new")],
              keys=[key("door", -1.0, 14.0, .09, tilt=LEAN_PHONE)], smalls=[small(5.4, 13.1, -.3)]),
  "ph6": dict(w=1320, h=2868, wv=13.8, atz=1.2, devices=[dev("phone", .3, 2.6, .08, 1.25, "phone/fillin")],
              keys=[key("order", 1.1, 14.0, -.08, tilt=LEAN_PHONE)], smalls=[small(-5.4, 12.7, .5)]),
  "ph7": dict(w=1320, h=2868, wv=13.8, atz=1.2, devices=[dev("phone", -.2, 2.6, -.08, 1.25, "phone/suggest")],
              keys=[key("email", -.9, 14.0, .1, tilt=LEAN_PHONE)], smalls=[small(5.5, 12.9, -.4)]),
  "ph8": dict(w=1320, h=2868, wv=13.8, atz=1.2, sh=1.45, devices=[dev("pad", -1.5, .9, -.1, 1.05, "pad/grid"), dev("phone", 2.9, 9.4, .12, .9, "phone/grid", lift=.63)],
              keys=[], smalls=[small(-5.0, 10.3, .2, "⌘"), small(-4.7, 13.5, -.15, "⇧"), small(-5.1, 16.7, .1, "V")]),
  # iPad frames 1 to 3 as one picture, then 4 to 8
  "padhero": dict(w=6192, h=2752, wv=54., atz=-.7, devices=[dev("pad", .4, 1.6, -.14, 1.12, "pad/chat")],
              keys=[key("home", -13.2, -2.0, -.07), key("email", -18.0, 7.9, .15, tilt=.2), key("sig", 18.2, -1.5, .12, lift=KH),
                    key("booking", 22.0, -3.1, -.1), key("wifi", 17.2, 8.1, .2)], smalls=[small(-16.8, 2.8, .5), small(9.0, 10.9, -.3)]),
  "pd4": dict(w=2064, h=2752, wv=17., atz=-1., devices=[dev("pad", .3, 1.2, .06, .94, "pad/grid")],
              keys=[key("booking", 1.6, 9.2, -.1, tilt=LEAN_PAD)], smalls=[small(-6.7, 8.6, .4)]),
  "pd5": dict(w=2064, h=2752, wv=17., atz=-1., devices=[dev("pad", -.3, 1.2, -.06, .94, "pad/edit")],
              keys=[key("home", -1.4, 9.2, .09, tilt=LEAN_PAD)], smalls=[small(6.6, 8.8, -.3)]),
  "pd6": dict(w=2064, h=2752, wv=17., atz=-1., devices=[dev("pad", .3, 1.2, .05, .94, "pad/fillin")],
              keys=[key("order", 1.5, 9.2, -.08, tilt=LEAN_PAD)], smalls=[small(-6.8, 8.4, .5)]),
  "pd7": dict(w=2064, h=2752, wv=17., atz=-1., devices=[dev("pad", -.2, 1.2, -.05, .94, "pad/suggest")],
              keys=[key("email", -1.3, 9.2, .1, tilt=LEAN_PAD)], smalls=[small(6.7, 8.6, -.4)]),
  "pd8": dict(w=2064, h=2752, wv=17., atz=-1.7, sh=1.45, devices=[dev("pad", -1.7, -.2, -.08, .88, "pad/grid"), dev("phone", 4.6, 5.3, .14, .76, "phone/grid", lift=.53)],
              keys=[], smalls=[small(-6.7, 8.9, .15, "⌘"), small(-3.5, 9.2, -.1, "⇧"), small(-.3, 8.9, .12, "V")]),
}
v = lambda *a: "vec%d(%s)" % (len(a), ", ".join("%.4f" % x for x in a))
arr = lambda t, xs: "%s[%d](%s)" % (t, len(xs), ", ".join(xs))

def layout(sc):
    """Places the screens, key faces and glyphs on the atlas; returns the atlas spec."""
    x, screens, faces, glyphs = 0, [], [], []
    for d in sc["devices"]:
        w, h = KIND[d["kind"]]["px"]; d["rect"] = (x, 0, w, h)
        screens.append(dict(src="../assets/screens/%s.png" % d["screen"], x=x, y=0, w=w, h=h)); x += w + 40
    for i, k in enumerate(sc["keys"]):
        k["rect"] = (x + (i % 2) * 1208, (i // 2) * 824); ic, t, p = F[k["face"]]
        faces.append(dict(x=k["rect"][0], y=k["rect"][1], icon=ic, title=t, preview=p))
    gy = ((len(sc["keys"]) + 1) // 2) * 824
    for i, s in enumerate([s for s in sc["smalls"] if s["glyph"]]):
        s["rect"] = (x + i * 400, gy); glyphs.append(dict(x=x + i * 400, y=gy, text=s["glyph"]))
    W = x + 2416; H = max([s["h"] for s in screens] + [gy + 400])
    return dict(W=W, H=H, screens=screens, faces=faces, glyphs=glyphs)

def glsl(name, sc, at):
    aspect = sc["w"] / sc["h"]; fov = math.degrees(2 * math.atan(sc["wv"] / (200. * aspect)))
    keys = sc["keys"] or [dict(x=0, z=900, yaw=0, lift=0, tilt=0, rect=(0, 0))]
    smalls = sc["smalls"] or [dict(x=0, z=900, yaw=0, glyph=None)]
    D = []
    for d in sc["devices"]:
        K, s = KIND[d["kind"]], d["scale"]
        D.append((v(d["x"], d["z"], d["yaw"], d["lift"]), v(K["h"][0] * s, K["h"][1] * s, K["c"] * s, K["t"] * s), v(K["bi"] * s, K["bc"] * s, K["sc"] * s),
                  v(K["s"][0] * s, K["s"][1] * s), v(*d["rect"])))
    return f'''// "{name}": written by gen.py from its description of the frame; edit that, not this.
window.SCENE_EXPO = 0.8;
window.SCENE_GLSL = `
#define NEPS .004
#define STEP .8
#define FAR 400.
#define THICK .1
float gT;
const vec2 KS = vec2(5.5, 3.75);
const float KH = 2.3, SH = {sc.get("sh", 1.7):.3f};
const vec2 AT = vec2({at["W"]}., {at["H"]}.);
Cam camera(){{
  Cam c; c.at = vec3(0, 0, {sc["atz"]:.3f});
  c.pos = c.at + 100. * vec3(0, sin(radians(64.)), cos(radians(64.)));
  c.fov = {fov:.4f}; c.lens = .22; c.focus = 99.; return c; }}
const int NK = {len(keys)};
const vec4 KP[NK] = {arr("vec4", [v(k["x"], k["z"], k["yaw"], k["lift"]) for k in keys])};      // x, z, yaw, height off the floor
const vec3 KA[NK] = {arr("vec3", [v(k["rect"][0], k["rect"][1], k["tilt"]) for k in keys])};    // its face on the atlas, and its tilt
const int NS = {len(smalls)};
const vec3 SP[NS] = {arr("vec3", [v(s["x"], s["z"], s["yaw"]) for s in smalls])};
const vec2 SA[NS] = {arr("vec2", [v(*s["rect"]) if s.get("glyph") else v(-1, -1) for s in smalls])};   // a glyph key's face, or -1 for a blank dark key
const int ND = {len(D)};
const vec4 DP[ND] = {arr("vec4", [d[0] for d in D])};     // x, z, yaw, height off the floor
const vec4 DB[ND] = {arr("vec4", [d[1] for d in D])};     // half body, corner, thickness
const vec3 DZ[ND] = {arr("vec3", [d[2] for d in D])};     // bezel inset, bezel corner, screen corner
const vec2 DS[ND] = {arr("vec2", [d[3] for d in D])};     // half screen
const vec4 DR[ND] = {arr("vec4", [d[4] for d in D])};     // the screen on the atlas
vec3 keyQ(int i, vec3 p){{
  vec4 k = KP[i]; p -= vec3(k.x, k.w, k.y); p.xz *= rot(k.z);
  float t = KA[i].z; if(t != 0.){{ p.z -= KS.y; p.yz *= rot(-t); p.z += KS.y; }}
  return p; }}
float top(vec2 x){{ return KH - .15 * smoothstep(1., .6, max(abs(x.x) / KS.x, abs(x.y) / KS.y)); }}
float sdKey(vec3 q){{
  float h = clamp(q.y / KH, 0., 1.);
  vec2 hs = KS - .32 * h, d2 = abs(q.xz) - (hs - .95);
  float dxz = length(max(d2, 0.)) + min(max(d2.x, d2.y), 0.) - .95;
  vec2 w = vec2(dxz, abs(q.y - KH * .5) - KH * .5) + .28;
  float d = min(max(w.x, w.y), 0.) + length(max(w, 0.)) - .28;
  return max(d, (q.y - top(q.xz)) * .9); }}
vec3 smallQ(int i, vec3 p){{ p -= vec3(SP[i].x, 0, SP[i].y); p.xz *= rot(SP[i].z); return p; }}
float sdSmall(vec3 q){{
  vec2 d2 = abs(q.xz) - (vec2(SH) - .5);
  float dxz = length(max(d2, 0.)) + min(max(d2.x, d2.y), 0.) - .5;
  vec2 w = vec2(dxz, abs(q.y - .75) - .75) + .2;
  return min(max(w.x, w.y), 0.) + length(max(w, 0.)) - .2; }}
vec3 devQ(int i, vec3 p){{ p -= vec3(DP[i].x, DP[i].w, DP[i].y); p.xz *= rot(DP[i].z); return p; }}
float rrect(vec2 x, vec2 hs, float r){{ vec2 d = abs(x) - (hs - r); return length(max(d, 0.)) + min(max(d.x, d.y), 0.) - r; }}
float sdDev(int i, vec3 q){{
  float th = DB[i].w;
  vec2 w = vec2(rrect(q.xz, DB[i].xy, DB[i].z), abs(q.y - th * .5) - th * .5) + .14;
  return min(max(w.x, w.y), 0.) + length(max(w, 0.)) - .14; }}
float map(vec3 p, out int id){{
  float d = p.y; id = 0;
  if(p.y > 6.) return p.y - 4.9;      // above everything: the distance down to the tallest key, never the floor's
  for(int i = 0; i < NK; i++){{
    vec3 q = keyQ(i, p);
    float b = length(q - vec3(0, KH * .5, 0)) - 7.2;
    if(b < d){{ float e = b > 1. ? b : sdKey(q); if(e < d){{ d = e; id = 100 + i; }} }}
  }}
  for(int i = 0; i < NS; i++){{ float e = sdSmall(smallQ(i, p)); if(e < d){{ d = e; id = 200 + i; }} }}
  for(int i = 0; i < ND; i++){{ float e = sdDev(i, devQ(i, p)); if(e < d){{ d = e; id = 300 + i; }} }}
  return d; }}
Mat mat(int id, vec3 p, vec3 n){{
  if(id == 0){{
    float f = .97 + .06 * vnoise(p.xz * 26.) * vnoise(p.xz * 7.);
    return Mat(vec3(.026, .37, .215) * f, .9, .03, 0., vec3(0)); }}
  if(id >= 300){{
    int i = id - 300; vec3 q = devQ(i, p);
    if(q.y > DB[i].w - .02 && rrect(q.xz, DB[i].xy - DZ[i].x, DZ[i].y) < 0.){{
      if(rrect(q.xz, DS[i], DZ[i].z) < 0.){{
        vec2 uv = (DR[i].xy + (q.xz / DS[i] * .5 + .5) * DR[i].zw) / AT;
        return Mat(vec3(0), .03, .035, 0., texture(atlas, uv).rgb * 1.16); }}
      return Mat(vec3(.004), .03, .04, 0., vec3(0)); }}
    return Mat(vec3(.30, .30, .31), .28, .55, 0., vec3(0)); }}
  if(id >= 200){{
    int i = id - 200; vec3 q = smallQ(i, p);
    if(SA[i].x < 0.) return Mat(vec3(.006, .085, .055), .3, .045, 0., vec3(0));
    vec3 alb = vec3(.88, .88, .87); vec2 f = q.xz / (SH - .25);
    if(q.y > 1.3 && max(abs(f.x), abs(f.y)) < .9) alb *= texture(atlas, (SA[i] + (f / .9 * .5 + .5) * 400.) / AT).rgb;
    return Mat(alb, .34, .045, 0., vec3(0)); }}
  int i = id - 100; vec3 q = keyQ(i, p);
  vec3 alb = vec3(.88, .88, .87);
  vec2 f = q.xz / (KS - .32);                            // the printed face is the top, inside the taper
  if(q.y > KH - .4 && max(abs(f.x), abs(f.y)) < .93)
    alb *= texture(atlas, (KA[i].xy + (f / .93 * .5 + .5) * vec2(1208., 824.)) / AT).rgb;
  return Mat(alb, .34, .045, 0., vec3(0)); }}
const int NL = 2;
void lightDef(int i, out vec3 c, out vec3 at, out vec2 hs, out vec3 Le){{
  if(i == 0){{ c = vec3(-92, 76, -28); at = vec3(0, 0, 4); hs = vec2(36, 28); Le = vec3(41., 39.6, 37.5); }}
  else {{ c = vec3(80, 64, 60); at = vec3(0, 0, 4); hs = vec2(52, 40); Le = vec3(3.0, 3.4, 3.8); }} }}
vec3 sky(vec3 d){{ return vec3(.035, .05, .045); }}
`;
'''
def bun(*a, limit=None):
    cmd = ["bun", os.path.join(HERE, "..", "render.mjs"), *map(str, a)]
    if limit: cmd = ["bun", os.path.expanduser("~/.claude/scripts/limit.ts"), str(limit)] + cmd
    r = subprocess.run(cmd, cwd=HERE, capture_output=True, text=True); print((r.stdout + r.stderr).strip().splitlines()[-1] if (r.stdout + r.stderr).strip() else "", flush=True)
def write(names):
    for n in names:
        sc = SCENES[n]; at = layout(sc)
        open(os.path.join(HERE, f"scene-{n}.glsl.js"), "w").write(glsl(n, sc, at))
        bun("atlas-set.html?spec=" + urllib.parse.quote(json.dumps(at)), f"atlas-{n}.png", at["W"], at["H"], "page", 1, limit=120)
def trace(names, scale, spp, folder):
    os.makedirs(os.path.join(HERE, folder), exist_ok=True)
    for n in names:
        sc = SCENES[n]; bun(f"pt.html?scene={n}&spp={spp}&atlas=atlas-{n}.png", f"{folder}/{n}.png", round(sc["w"] * scale), round(sc["h"] * scale))
if __name__ == "__main__":
    step, names = sys.argv[1], sys.argv[2:] or list(SCENES)
    if step == "write": write(names)
    if step == "preview": trace(names, 1 / 3 if SCENES[names[0]]["w"] < 3000 else 1 / 4, 16, "previews")
    if step == "render": trace(names, 1, int(os.environ.get("SPP", "128")), "renders")
