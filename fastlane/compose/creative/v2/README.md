# Cutling 2.0 store frames, iPhone + iPad + Mac (ASG167)

Three directions for the 2.0.0 store pages, each a whole set: 6 iPhone frames (1320 x 2868), 6 iPad frames
(2064 x 2752) and 5 Mac frames (2880 x 1800), sizes App Store Connect accepts for IPHONE_67, IPAD_PRO_3GEN_129 and
DESKTOP. The owner picks one from `~/Downloads/Claude/cutling-screens-redesign/en-US-direction-*.png`. Nothing here is
read by the upload lanes. The earlier sets in `../sets/` (Keys, Poster, Night flight) have no Mac frames and are
built on a three-frame panorama, which 2.0's preview breaks (see `../REFERENCES.md`, "What search shows").

| Dir | Name | Idea | Leads with |
|---|---|---|---|
| A | Fan deck | The app icon's punched tags made real, riveted on one ring, on the icon's green | Everything you keep retyping |
| B | Every app | Carries on from the "Every app" preview: white, a black line and a green line, the real keyboard at the same height in every frame; on Mac the menu bar | Where it works |
| C | The blank | Ink black, the buyer's sentence in New York, every part Cutling types a green chip | 2.0's fill-ins |

## Build

```
python3 build.py en-US            # all three; or: python3 build.py en-US B --only mac
python3 sheet.py en-US            # one picture per direction into ~/Downloads/Claude/cutling-screens-redesign/
```

`build.py` writes one HTML page per frame to `out/<locale>/<dir>/<device>/NN.html` and renders the lot through one
headless Chrome (`render-batch.mjs`); frames 1 and 2 of iPhone and iPad are one double-width page cut in two, so what
crosses their seam lines up. Words: `words/<locale>.json`. Captures: `cap()` in `build.py`, read from each locale's
`fastlane/screenshots/<locale>/`, `fastlane/screenshots_mac/raw/<locale>/` and `captures/<locale>/` (2.0 captures not
yet in the snapshot folders). A capture missing for a locale falls back to en-US, so check the list below before
calling a language done.

Two costs that are already handled: a page-wide grain layer made each frame take 30 to 77 s (the grain is now the
ground's own background image, `noise.png`), and starting Chrome costs 15 to 35 s, hence one Chrome per batch.

## A new language

1. `words/<locale>.json`: the same keys as `en-US.json`, written blind from the meanings (blind-translation skill),
   never translated from the English. Markup: `*x*` accent phrase, `[x]` a green chip (a blank, or text Cutling types),
   `{cmd}` the ⌘⇧V keys. `seed` holds the demo data and must match what that locale's captures show.
2. The captures in the table below, for that locale.
3. `python3 build.py <locale> <dir>` for the picked direction, then look at every frame.

## What each frame shows: real capture or drawn

Real = that locale's own capture, shown whole or cropped, with only the status bar redrawn (clock 9:41, no charging
battery). Drawn = HTML built here from a real 2.0 capture, standing in until the capture below exists.

| Frame | A Fan deck | B Every app | C The blank |
|---|---|---|---|
| iPhone/iPad 1 | Tags drawn (seed words); phone/iPad 01 Messages real | 01 Messages real, cropped full width | Sentence drawn; fill-in screen drawn |
| iPhone/iPad 2 | 01 Messages real, the bank tag drawn | Keyboard band real (01); fill-in screen drawn over its tiles; message field drawn | Sentence drawn; fill-in screen drawn |
| iPhone/iPad 3 | Tag, fill-in screen, sent bubble drawn | Keyboard band real; Maps search drawn | Date card and bubble drawn |
| iPhone/iPad 4 | 02 Main grid real; deck drawn | Keyboard band real; Mail with signature drawn | 01 Messages real |
| iPhone/iPad 5 | iPad 02 grid, iPhone 02 grid, Mac 01 picker real | Keyboard band real; 02 grid real, cropped | 02 Main grid real |
| iPhone/iPad 6 | 04 Keyboard Setup Try It real | Keyboard band real; icon | 04 Keyboard Setup Try It real |
| Mac 1 | 01 Picker real; tags drawn | 01 Picker real; menu bar drawn | Fill-in form real (en only) |
| Mac 2 | Fill-in form real (en only, dark); tag drawn | Fill-in form real (en only, dark); menu bar drawn | 01 Picker real; ⌘⇧V keys drawn |
| Mac 3 | 02 History real; tag drawn | 02 History real; menu bar drawn | 02 History real |
| Mac 4 | 05 iCloud settings, iPad and iPhone grids real | 05 iCloud settings, iPhone grid real | 05 iCloud settings, iPhone grid real |
| Mac 5 | Tags and icon drawn | 01 Picker real; icon | 01 Picker real; icon |

The fill-in screen is drawn from the 2.0 build's own captures (`~/Downloads/cutling-fill-ins/iphone/fillin_02` and
`fillin_06`): those were taken on a device in an odd layout with rows ghosting through the panel, so they cannot be
shown as they are.

## Captures each language needs

Already in every store language's folder and used as they are: iPhone and iPad `01_KeyboardInMessages`,
`02_MainGrid`, `04_KeyboardGuide`; Mac `01_Picker`, `02_History`, `05_Sync`. Not used, because they show 1.x:
`03_DetailView` (the old text box, "42 / 1,000") and `05_KeyboardSettings` ("8 / 100", "1,000 chars"); Mac
`03_Editor` (no Add Variable) and `04_Hotkey`.

New, per language, for whichever direction is picked:

| Capture | Devices | For | How |
|---|---|---|---|
| The keyboard's fill-in screen asking for Name, the recent names offered, over a Messages thread | iPhone 1320 x 2868, iPad 2064 x 2752 | A 3, B 2, C 1 and 2 | The "Every app" take G4 at store size (seed: `EveryAppSeedCopy`, names Maya, Jonas, Aiko), a still at the moment the names show; or a UI test on the store simulators (`scripts/frame04-store.sh` shows the device queue) |
| The Mac picker's fill-in form for the reply | Mac, at 2x | A 2, B 2, C 1 | `-PROMO_EVERY`-style seed on the Mac; light appearance for A and B, dark for C (en exists only in dark: `captures/en-US/mac-fill-in-form.png`) |
| Maps search field with the address typed by the Cutling keyboard | iPhone, iPad | B 3 | "Every app" take G2, a still after the tap |
| Mail (or Calendar, take G3) with the signature or studio address typed | iPhone, iPad | B 4 | take G3, or a new take in Mail |

One seed for all of them: the 1.x seed (IBAN, 123 Main Street) is in today's 01 and 02 captures, the "Every app"
seed (14 Linden Road, Order update, Maya) in the preview takes. Whichever direction is picked should be shot again
on one seed so the keyboard, the drawn tags and the fill-in names agree; `EveryAppSeedCopy` exists for en, id and ja
only, so the other 47 languages need its words written blind first.
