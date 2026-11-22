# Paste-style store frames (ASG148)

The iPhone App Store frames redrawn the way Paste draws its own: a calm light ground, one big
headline in plain words, and the whole iPhone with its bezel. The capture fills the phone's
screen uncropped; no frame is a keyboard panel cut out of a capture.

Only frame 1 exists. The owner judges it before the other frames and the locales are made.

## Files

| File | What it holds |
|---|---|
| `spec.json` | Every value the frames draw (geometry, colour, type, copy, the tap mark), the three variants, and the source ledger |
| `paste_style.css` | The drawing. It reads custom properties only and holds no number of its own |
| `build.py` | Writes `pages/<variant>-<locale>-<frame>.html` and renders `out/<same>.png` with `../render_cdp.mjs` and `../tall/fit.js` |
| `check.py` | Prints any number outside `spec.json`, any measured box that differs from it, any broken geometry rule, any unmapped ledger row |

```
python3 fastlane/compose/paste_style/build.py                      # the recommended variant, en-US
python3 fastlane/compose/paste_style/build.py --variant A --variant B --variant C
python3 fastlane/compose/paste_style/build.py --locale de-DE --strings de.json
python3 fastlane/compose/paste_style/check.py
```

`pages/` and `out/` are generated. Nothing here is read by the upload lanes, which still take
`fastlane/screenshots`.

## The three designs

| | A: Paste's calm | B: the tap, in mint | C: calm, with the tap marked |
|---|---|---|---|
| Pull | Copy the rival's restraint exactly | Carry the brand colour and show the gesture | A's restraint plus one accent |
| Ground | Near-white, a trace of mint at the foot | Pale mint, top to bottom | As A |
| Headline | Black, flush with the phone's left edge | Centred, "one tap" in green | As A, "one tap" in green |
| Second line | Grey: how it works | None | As A |
| On the phone | Nothing | Green touch mark on the Home Address key | As B |
| At store-card width | Reads; nothing says which key did it | Reads; the mint ground is the nearest to the rejected green set | Reads; the green words and the green mark find each other |
| Beside Paste | Closest match, and anonymous: could be any app | Looks like a different family from Paste | Same family as Paste, recognisably Cutling |
| Risk | The blank chat has nothing to hold the eye | Centred copy over a centred phone is the layout every rival's later frames use | The mark sits on a real capture; it must stay inside the key in every locale |

**Recommended: C.** It is A's layout, so it passes the test the owner set (whole phone, big
plain headline, air), and it spends its one accent on the thing the headline promises: the
green of "one tap" is the green on the key that was tapped.

## Acceptance criteria

Contexts: the store search card, about 300 px wide (headline at least 32 px there, checked by
`check.py`); the product page at full size (capture drawn at 2/3 scale, never upscaled); every
locale in `locales.json` (a headline longer than the phone's column shrinks to no less than
96 px, and the run fails rather than clip it); right-to-left locales (copy starts at the phone's
right edge; whether the tap mark's key is mirrored in those captures is open and decided when
the first one is captured); a store in dark mode (the frame keeps its own light ground); iPad
is n/a: this card is the iPhone set; plan, role, money, offline are n/a: a flat image.

Neighbours: `fastlane/screenshots` and the `tall` set are not written, so nothing ships until a
later card promotes this set; `../render_cdp.mjs` and `../tall/fit.js` are shared with the `tall`
set and are used unchanged, so a change to either must re-run both; a re-render overwrites the
same file names and nothing else; exits, locks, replays and old clients are n/a: no record is
written.

1. `out/C-en-US-f1.png` is 1320x2868.
2. The screen is the whole capture at one scale on both axes: 880x1912 from 1320x2868.
3. The phone is whole: its top is below the copy and its bottom is 140 px above the canvas foot.
4. The headline is two set lines, 162 px, and its column is the phone's column (x 189, width 942).
5. The phone, bezel and screen corners are concentric (155, 146, 124 px).
6. The tap mark lies wholly inside the Home Address key.
7. `check.py` prints `misses: 0`.
8. Each new frame adds one entry to `frames` and its copy keys to `copy`; no value is added to
   `paste_style.css` or `build.py`.

Mock: `out/C-en-US-f1.png`. Proof is `check.py`'s measured boxes against `spec.json`, plus the
frame looked at at full size and at 300 px wide. There is no text field and no motion.

## Open before the set is remade

- The chat in `iphone-address-chat-clean.png` is empty, so four tenths of the screen is blank.
  A capture with one incoming message asking for the address would tell the story without a
  second line of copy. It has to be a new capture; nothing is drawn over this one.
- The capture's clock reads `09.41`. A US listing wants `9:41`.
- The headline and second line are English only. The other locales go through the blind
  translation the house uses; the German and Arabic used to test the fit were not kept.
