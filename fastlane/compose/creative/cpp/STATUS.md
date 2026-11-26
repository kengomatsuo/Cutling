# Panorama store sets: main page (ASG252) and custom product pages (ASG250): status

Brief: `docs/aso/cpp-2.0/brief.md`, then two changes from the owner relayed by the coordinator (2026-11-26):
build from ASG148's candidates (`../sets`, `../d1..d3`), not a new design; and make "Don't type it" the main 2.0 page.

| Page | Candidate | Languages | Frames | State |
|---|---|---|---|---|
| main (store page, ASG252) | Don't type it (poster, d2) | 50 | 8 iPhone + 8 iPad | en-US done; 49 rendering, words written |
| Personal details | Keys (d1), `keys.py` | 50 | 6 + 6 | traced on the PC; en-US composited; words written for all 50 |
| Notes you paste | Keys (d1) | en-US, en-GB, en-AU, en-CA | 6 + 6 | traced on the PC; compositing next |
| Quick replies | Night flight (d3), `night.py`, words around answering the same question again | 50 | 6 + 6 | en-US rendered; words written for all 50 |
| Clipboard history | Night flight (d3) | 4 English | 6 + 6 | en-US rendered |
| Text expander | Don't type it (`poster.build_te`), its own words | 4 English | 6 + 6 | en-US rendered |

Build: `python3 build.py <page> [locales|--all]`, `python3 build.py sheet <page>`. Frames:
`out/<page>/<locale>/{iphone,ipad}/NN.png`, with the page they are cut from (`pano.html`) beside them.

## Decisions

- **Every seam is crossed, not only 1 to 3.** ASG148's sets joined frames 1 to 3 and left 4 to 8 as separate
  frames; the owner's ask is one picture across the set. Each set is now one HTML page N frames wide, rendered once
  per frame with the page shifted, so whatever crosses a seam lines up to the pixel.
- **No device crosses a seam** (the owner rejected a phone cropped by a seam, ASG148). Seams are crossed by the app's
  pieces at poster size: keys, the reply key, the sent message, the date card, the Mac's three keys.
- **Main page, frames 1 and 2 read alone**: search shows the preview and then only two frames. Frame 1 is the address
  as the loose keys it costs to type ("42 keys. Every time."), frame 2 "Tap it." with Cutling's one key for it lying
  across the seam, so the pair is a whole thought.
- **Main page, 2.0 content**: 4 Keep it all, room for 5,000 (en-US: the 2.0 grid capture reading 5,000 Cutlings);
  5 Write it once, the Notes-like text page (en-US real capture; other languages drawn after it with their own note);
  6 Leave a blank, Messages and the fill-in keyboard asking for the name, the names used before as keys; 7 It knows
  the date, the saved note with Today's Date beside what it typed; 8 Every device, paid once. ASG148's 1.x editor
  (frame 5) and "It reads the field" (frame 7) are gone.
- **The ink closing frame is mint now**: a ground that changes colour at a seam shows the seam.
- **Frame 3 "Done." shows the 04 Try It capture**, real 2.0 and in every language, the address Cutling typed; the
  Messages capture (01) is English in every language folder (de-DE and ar-SA both read "Dinner was so good last
  night"), so it cannot carry a localized page.
- **Drawn screens use the app's own strings per language**: the keys' names and values are the snapshot seed in
  `Cutling/<lproj>/Localizable.strings` (the same cutlings the real 02 and 04 captures show), the fill-in keyboard's
  labels come from `docs/aso/screens-2.0/locale-facts.json`, and the reply, names and delivery note from direction C's
  `cseed` (already written blind in all 50 languages).
- **Right-to-left languages (ar-SA, he, ur-PK) run the page from the right**: frame 1 is the right-hand slice, every
  element is placed from the right and turned the other way, so the picture reads in the order the store shows it.
- **Words**: new lines are in `words/<locale>.json`, written from `words/meanings.md`. No agent tool was available to
  this session, so one writer (this session) wrote every language from the meanings, one language at a time, never
  from the English lines; each words file carries a back-translation of its lines under `_bt` for a native check.
- **Publishing**: `python3 build.py publish main <locales>` copies the main page into `fastlane/frames/<locale>/`
  (iPhone and iPad only; the Mac keeps direction C). Not run: the coordinator uploads.

- **Keys is traced once per page and device, never per language.** A path-traced frame costs minutes; 50 languages
  would be days. `keys.py` traces the still life with blank key faces and dark screens (beauty) plus two passes at
  twice the size recording which face or screen each pixel shows and where on it (u, v); each language then prints its
  own faces and screens into an atlas and `comp.html`-style pages lay them onto the beauty (a face multiplies the lit
  white key, a screen adds its light). The camera slides along x per column, so frames traced one at a time meet at
  the seams. Right-to-left languages take each traced frame mirrored (frame 1 stays frame 1), with the faces printed after
  the mirror so they read the right way. Traces run on the PC (RTX 4060, about 100 s a frame at 160 samples); the
  PC's GPU returns some passes black, so every pass is checked and redone (`python3 keys.py fix <set>`).
- **Night flight**: d3's renderer (`night/frame.html`) with the spec written into the page; trails and cards cross every
  seam; iPad frames carry iPads; drawn screens (Messages with Cutling's keyboard, a Safari page with copied text) are
  rendered per language first, and the real grids get their status bar redrawn.
- **Main page seams 7|8**: the closing frame keeps the mint ground (a colour change at a seam shows the seam).
- **Captures from another language**: listed in `out/<page>/fallbacks.json` after each build. Known: the English pages'
  2.0 captures (grid at 5,000, the text page, the formatted Try It) exist for en-US only, so en-GB, en-AU and en-CA show
  the en-US capture there; the Mac picker and history fall back to en-US where a language has none.

## Log

- 2026-11-26: main page en-US rendered, 8 + 8 frames. Told the coordinator.

## Main page published to fastlane/frames (iPhone 8 + iPad 8 each; Mac untouched)

- 2026-11-27: en-US, ar-SA, bn-BD, ca, cs
- 2026-11-27: da, de-DE, el, en-AU, en-CA
- 2026-11-27: en-GB, es-ES, es-MX, fi, fr-CA
- 2026-11-27: fr-FR, gu-IN, he, hi, hr
- 2026-11-27: hu, id, it, ja, kn-IN
- 2026-11-27: ko, ml-IN, mr-IN, ms, nl-NL
- 2026-11-27: no, or-IN, pa-IN, pl, pt-BR
- 2026-11-27: pt-PT, ro, ru, sk, sl-SI
- 2026-11-27: sv, ta-IN, te-IN, th, tr
- 2026-11-27: uk, ur-PK, vi, zh-Hans, zh-Hant; ja again (its iPad headlines now join without a space). All 50 published.
