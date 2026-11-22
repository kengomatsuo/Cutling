# Paste-style store frames (ASG148)

The iPhone App Store frames redrawn the way Paste draws its own: a calm light ground, one big
headline in plain words, and the whole iPhone with its bezel. Frames 1 to 3 are one strip: a
tile lifted from the library crosses each seam, so the three read as one picture where search
shows them side by side. No frame is a keyboard panel cut out of a capture.

Frames 1 to 3 exist. The owner judges them before the other frames and the locales are made.
What the rivals do, and what was taken from each, is in `TECHNIQUES.md`.

## Files

| File | What it holds |
|---|---|
| `spec.json` | Every value the frames draw: geometry, colour, type, copy, the clock, the bubble, the patches, the lifted tiles, the two strip designs, and the source ledger |
| `paste_style.css` | The drawing. It reads custom properties only and holds no number of its own |
| `build.py` | Writes one page per frame and renders `out/<design>-<locale>-<frame>.png` and `out/<design>-<locale>-strip.png`, with `../render_cdp.mjs`, `../tall/fit.js` and `magick` |
| `check.py` | Prints any number outside `spec.json`, any page or measured box that differs from it, any broken geometry rule, any unmapped ledger row |
| `TECHNIQUES.md` | The rival audit and Apple's words on how many frames search shows |

```
python3 fastlane/compose/paste_style/build.py                      # the recommended design, en-US
python3 fastlane/compose/paste_style/build.py --design S1 --design S2
python3 fastlane/compose/paste_style/build.py --locale de-DE --strings de.json
python3 fastlane/compose/paste_style/check.py
```

`pages/` and `out/` are generated. Nothing here is read by the upload lanes, which still take
`fastlane/screenshots`.

## The two strips

| | S1: whole phones, tiles cross | S2: Paste to the letter |
|---|---|---|
| Pull | Keep what the owner asked for (the whole phone) and join the frames with the product's own tiles | Copy Paste's effect exactly: one device far larger than the rest runs over both seams |
| What crosses seam 1 and 2 | The Home Address tile, 342 px into frame 1 and 252 px into frame 2 | The left 94 px of a phone 1.6 times the size |
| What crosses seam 2 and 3 | The Email Signature tile, 374 px into frame 2 and 220 px into frame 3 | Its right 93 px |
| Phones | Three, each whole inside its own frame | Two whole; the middle one cut on both sides and at the foot |
| At search size | Reads as one strip; the tiles are the largest things after the headlines | The library is easy to read; the crossing is two thin slivers |
| Each frame alone | Frames 1 and 3 keep a whole phone and a piece of a tile at the edge; frame 2 shows a piece of both | Frame 2 is a cropped phone, which is the fault the owner named |
| Story | The tiles are the two things pasted, each heading for the place it landed | None between frames |
| Risk | A word on a tile is cut by the frame edge, as on Paste's Link card | A capture drawn at 107% of its size is slightly soft |

**Recommended: S1.** It gives the joined strip without giving up the whole phone, and the thing
that crosses each seam is the product: the tile for the address goes towards the chat, the tile
for the sign-off towards the mail.

## What is drawn over the captures

Everything below is in `spec.json` under `frames` and `designs`; coordinates are capture pixels.

- All three frames: the status-bar clock is redrawn as `9:41` over the capture's `09.41`, same
  place, same glyph height (59 px semibold on a 168 by 70 patch of the bar's own colour).
- Frame 1: one incoming Messages bubble, "What's your address?", grey `#E9E9EB` with black 51 px
  text and a tail, 108 px tall, in the empty chat above the field. It is drawn, not captured.
  A green touch mark sits on the Home Address key.
- Frame 3: the capture is a test page laid out as a mail composer. Its "localhost" pill is
  covered with the page's own white; its charging battery and its Bank Account key are replaced
  by the same boxes of the chat capture (plain battery, Phone Number key).
- The two lifted tiles are cut from the library capture at capture size and turned 5 and 4
  degrees. Their top 44 px lie under the library's header in the capture, so the same strip of
  the tile below takes their place.

## Acceptance criteria

Contexts: search results, where up to three portrait frames sit side by side at about 300 px
each and only when no app preview is ahead of them (the strip must read as one picture there,
headlines at least 32 px); the product page, where frames sit apart (each frame keeps a whole
phone, a headline and a second line); every locale in `locales.json` (a headline longer than the
phone's column shrinks to no less than 96 px, the run fails rather than clip it, and the three
headlines of a locale may then differ in size, which is open); right-to-left locales (copy starts
at the phone's right edge; whether the strip's order and the tiles mirror is open and decided
with the first one captured); a locale whose captures differ (the clock text, the bubble text
and every patch box are per frame in `spec.json`); a store in dark mode (the frames keep their
own light ground); iPad is n/a: this card is the iPhone set; plan, role, money, offline are
n/a: a flat image.

Neighbours: `fastlane/screenshots` and the `tall` set are not written, so nothing ships until a
later card promotes this set; `../render_cdp.mjs` and `../tall/fit.js` are shared with the `tall`
set and used unchanged, so a change to either must re-run both; the captures in
`../tall/cutling/cap` are read and never written; a re-render overwrites the same file names and
nothing else; frames 1 to 3 must be uploaded together and in order, since any one replaced alone
breaks the strip; exits, locks, replays and old clients are n/a: no record is written.

1. `out/S1-en-US-f1.png`, `-f2.png` and `-f3.png` are each 1320x2868, and `-strip.png` is 3960x2868.
2. Each screen is the whole capture at one scale on both axes: 880x1912 from 1320x2868.
3. In S1 every phone lies wholly inside its own frame, below its copy and 140 px above the foot.
4. Something crosses the seam at x 1320 and the seam at x 2640.
5. The three headlines are two set lines each, all 156 px, in a column as wide as the phone.
6. The clock in every frame reads `9:41`.
7. The bubble lies inside the capture's empty chat area and the touch mark inside the Home Address key.
8. Every patch and every lifted tile is cut from inside a capture.
9. `check.py` prints `misses: 0`.
10. A further frame adds one entry to `frames`, a phone and, to carry the strip on, a lift to the
    design, and its copy keys to `copy`; no value is added to `paste_style.css` or `build.py`.

Mock: `out/S1-en-US-strip.png`. Proof is `check.py`'s measured boxes against `spec.json`, plus
the strip looked at at full size and at 300 px a frame. There is no text field and no motion.

## Open before the set is remade

- Frame 3 needs a real capture in Mail. The one on disk is a test page; its host pill is covered.
- Frame 1's bubble is drawn. A capture with a real incoming message would replace it.
- The captures' clock reads `09.41`; a recapture in a US-format simulator removes the redrawn clock.
- Copy is English only. The other locales go through the blind translation the house uses.
- Cutling has no Core Brand file. No mark was drawn here; one should exist before a logo or kit.
