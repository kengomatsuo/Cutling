# Creative store frames, three complete sets (ASG148)

Three directions for the App Store screenshots, each a full English set of 8 frames for iPhone
(1320 x 2868) and iPad (2064 x 2752). They are meant to run against each other as product page
optimization treatments and as custom product pages. Nothing here is read by the upload lanes,
and nothing has been uploaded. Where each idea came from is in `REFERENCES.md`.

`sets/<direction>/{iphone,ipad}/NN.png` are the frames. `out/set-<direction>.png` is a contact sheet.

| Direction | Folder | Idea |
|---|---|---|
| `keys` | `d1/` | Cutling's tiles as chunky physical keys, path-traced as a studio photograph around the device |
| `poster` | `d2/` | A flat type poster on neon mint: "Don't type it. Tap it. Done." |
| `night` | `d3/` | Devices lying tilted in the dark; real pieces of the screen lift off and trails of light carry them |

## The eight frames (same story in all three)

| # | Says | Screen shown |
|---|---|---|
| 1 to 3 | One picture across three frames: the pain, the tap, the result | `chat` (real) |
| 4 | Everything you retype in one place | `grid` (real) |
| 5 | Save it once | iPhone `new` (real, from the promo film's take); iPad `edit` (real) |
| 6 | Blanks you fill as you paste | `fillin` (**wireframe**) |
| 7 | The key that fits the field comes first | iPhone `suggest` (real, from the promo film's take); iPad `suggest` (**wireframe**) |
| 8 | iPhone, iPad and Mac, in sync; no account, ads or tracking | `grid` on both devices (real), the Mac picker (real) |

## Build

```
swift assets/symbols.swift assets/sym <names>          # SF Symbols as PNGs (already in assets/sym)
cd assets/wire && for p in phone-fillin:phone/fillin:1320:2868 pad-fillin:pad/fillin:2064:2752 pad-suggest:pad/suggest:2064:2752; do
  IFS=: read a b w h <<< "$p"; bun ../../render.mjs $a.html ../screens/$b.png $w $h page 1; done   # the wireframes
python3 build_sets.py screens                          # captures with their patches
cd d1 && python3 gen.py write && SPP=256 python3 gen.py render   # the still lifes, about 8 minutes on the M3
#   frames 1 to 3 on iPhone are the first look's render: bun ../render.mjs "pt.html?scene=keys&spp=240" scene-3960.png 3960 2868
#   then compose.html -> out/direction-1-strip.png; d2/strip.html and d3/strip.html -> out/direction-{2,3}-strip.png
cd d2 && bun ../render.mjs strip-pad.html ../out/poster-pad-strip.png 6192 2752 page 1
GPU=1 python3 build_sets.py night night_pad_hero       # pages with tilted devices need the GPU, and no path trace running
python3 build_sets.py poster keys cut sheets
```

`render.mjs` and `d1/pt.html` are the studio-render skill's, the second with a texture and an
emitting material added. `ready.js` tells the renderer a page is fully painted.

Two things that cost time and are now handled in the scripts: Chrome paints a tilted device only
where its flat box lies inside the window (so those pages render in a taller window and are
cropped), and a page of 3D layers rendered while a path trace holds the GPU comes out half painted.

## What is real and what is drawn

Real captures, in `assets/raw/`, each shown with its clock redrawn as 9:41:
`phone-chat` and `pad-chat` (the address pasted in Messages; one incoming bubble is added on the
phone), `phone-grid`, `pad-grid`, `pad-edit` (charging battery replaced), `phone-new` and
`phone-suggest` (frames of the promo film's simulator takes; the test page's "localhost" pill and
the charging battery are covered), `mac-history`.

Wireframes, in `assets/wire/`, drawn because no capture exists yet:
- `phone-fillin`, `pad-fillin`: the keyboard's fill-in panel, drawn from `docs/fill-ins.md` over the
  real keyboard capture's chrome. The feature is on in builds since 2026-11-21 and is not in the
  released version until that build ships.
- `pad-suggest`: an email being written on iPad with the email key suggested first, drawn after the
  real iPhone take and the real iPad keyboard.

Everything outside a screen is drawn or rendered: the 3D keys and devices, enlarged tiles, the 41
letter keys, light trails, destination cards, bezels.

The 41 in the poster is the English seed address (40 characters and the return between its two
lines); another locale's address needs its own count.
