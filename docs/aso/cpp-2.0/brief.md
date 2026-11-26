# Cutling's custom product pages, 2.0: one continuous picture per set (card ASG250)

## The owner's words (2026-11-26, relayed)

> new product pages the screenshots changed to the ones spanning several screenshots (why until now still not done? Why the custom product pages still separate screenshots? Unacceptable.)

Earlier, on the main store frames (card ASG148): the frames must use "the continuous panorama that bleeds across
frames, like Paste 2-3", every rival technique weighed. He called one strip "uncreative" because its brief limited
it to captures already on disk; drawn scenes and new captures are allowed. He rejected a phone cropped by a seam.

## Goal

Every Cutling custom product page, in every localization it has, shows an iPhone set and an iPad set whose frames
read as one continuous picture running across the frames, the way Paste's listing does, and sells what that page is
about with what Cutling 2.0 does. Done when a person opening the rendered frames side by side sees one picture
crossing every seam, in each page's own story, in its own language, at App Store sizes: iPhone 1320 x 2868
(APP_IPHONE_67) and iPad 2064 x 2752 (APP_IPAD_PRO_3GEN_129), 3 to 10 frames per set.

Why it matters now: the current custom pages still show 1.x screens as five separate phones ("8 / 100" cutlings,
"1,000 chars"), and 2.0 (5,000 cutlings, fill-ins, dates that fill themselves in, the Notes-like text page) is
scheduled for release on 1 December 2026 00:00 UTC. Page changes ride in the same review submission as 2.0.0.

## The pages (read back from App Store Connect, 2026-11-26)

| Page | Live state | Localizations | Promo text (en-US) |
|---|---|---|---|
| Quick replies | APPROVED | 50 store languages | Answer the same questions faster. Save your canned responses and quick replies once, then paste them into chats, email and support tickets from the keyboard. |
| Personal details | APPROVED | 50 store languages | Stop retyping your address, IBAN, booking numbers and ID. Save them once and fill in any form with one tap from the Cutling keyboard. |
| Text expander | READY_FOR_REVIEW (never sent) | en-US, en-GB, en-AU, en-CA | Skip the shortcut codes. Save a snippet once, then tap it in the Cutling keyboard to insert the whole text in any app. |
| Clipboard history | READY_FOR_REVIEW | en-US, en-GB, en-AU, en-CA | Keep the text you copy. Save it with the keyboard's Add from Clipboard button, then paste it again in any app whenever you need it. |
| Notes you paste | READY_FOR_REVIEW | en-US, en-GB, en-AU, en-CA | Keep the addresses, account numbers and notes you paste most in one place, one tap away in the Cutling keyboard. |

Every page's per-locale promo text and keywords are in `docs/aso/cpp.json`; the 50 store locales are the folders of
`fastlane/compose/creative/v2/words/`. Today's images: `fastlane/screenshots_cpp/{replies,details}/<locale>/` and,
for the three English pages, the plain shots in `fastlane/screenshots/en-US/`.

## What exists to build from

- `fastlane/compose/creative/v2/` (README.md first): the 2.0 store frames. `build.py` turns per-frame HTML into PNGs
  through one headless Chrome (`render-batch.mjs`); helpers draw phones, iPads, Mac windows, tags (the icon's punched
  tags), the fill-in panel and message bubbles; `split_pair` cuts one double-width page into two frames.
  Directions: A Fan deck (green, tags on a ring), B Every app (white, one keyboard band), C The blank (ink black,
  green chips). C is the main 2.0 page in all 50 languages; A and B exist in en-US only.
- Words: `words/<locale>.json` holds direction C's lines (`C`, `cseed` = that locale's demo data) in all 50 languages,
  blind-written; A and B's lines exist in en-US only. New lines in other languages are written blind from the meaning
  (blind-translation skill), never translated from the English.
- Captures per locale: iPhone and iPad `01_KeyboardInMessages`, `02_MainGrid`, `04_KeyboardGuide` (2.0 Try It) in
  `fastlane/screenshots/<locale>/`; Mac `01_Picker`, `02_History`, `05_Sync` in `fastlane/screenshots_mac/raw/<locale>/`;
  2.0 extras in `v2/captures/en-US/` (formatted text page, written note, Duo grid). `03_DetailView` and
  `05_KeyboardSettings` show 1.x and are wrong for 2.0. The grid captures in hu, it, hr, no, he, ru, sl-SI, uk and
  ur-PK carry an older plural in their title (card ASG192).
- Today's custom page images come from the old plain green frames in `fastlane/compose` (`./deploy.sh frame_cpp`);
  `.claude/rules/aso-screenshots.md` describes the store frame folders.
- `fastlane/compose/paste_style/TECHNIQUES.md`: what Paste and 20 rival listings do across frames and what Cutling took.
- `fastlane/compose/creative/REFERENCES.md`: references gathered for the store frames.

## Hand back

Frames at `fastlane/compose/creative/cpp/out/<page-slug>/<locale>/{iphone,ipad}/NN.png` and a contact sheet per page
and device (one picture each, frames side by side, labelled), plus the build script beside them so a locale can be
re-rendered. Write progress and decisions to `fastlane/compose/creative/cpp/STATUS.md` as they land. The session that
briefed you uploads the sets to App Store Connect and reads them back; sending any page to Apple's review waits for
the owner's yes.
