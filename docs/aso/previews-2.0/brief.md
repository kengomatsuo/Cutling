# Brief: Cutling 2.0's App Store preview videos

card: ASG155 (board ~/Repositories/undirect/docs/plans/app-store-growth/BOARD.md; session cutling-2-previews owns the
card, records the takes, builds, commits and uploads)

## The owner's ask, word for word (2026-11-22)

> Where's the new previews and screenshots?

He expects Cutling 2.0's App Store listing to carry new preview videos. None exist yet: on December 1 the 2.0 product
page would still play 1.6.2's previews, which show nothing 2.0 brings.

## Goal

Ideas for Cutling 2.0's App Store preview videos on iPhone, iPad and Mac: a range of directions that are different
ideas, so the owner can pick from pictures. Each direction says its idea in a line, shows itself the way you judge best
(frames at the delivered size, a storyboard, an animatic, a draft cut), carries the words a viewer reads, and lists
the recordings of the real app it needs (device, screen, what happens, how long). You decide everything else: how many
directions, how many previews per device (Apple allows three per language), whether the three devices share an idea,
the story, pace, type, colour, music, sound, overlays, transitions, and what of 2.0 each one shows.

## Why it matters

2.0 releases on December 1 (both 2.0.0 versions are scheduled for 2026-12-01 00:00 UTC). It is Cutling's biggest
update. Previews autoplay muted on the product page and in search results, and they are the first thing a buyer
watches before deciding to buy.

## The product

Cutling is a clipboard manager and custom keyboard for iPhone, iPad and Mac (one purchase, iCloud sync): you save text
and images as "cutlings" and put them into any app from the Cutling keyboard on iOS, or from a picker (⌘⇧V) on the
Mac. The code is in this repo (`Cutling/`, `CutlingKeyboard/`); the icon is `Cutling/AppIcon.icon`.

What 2.0 brings, read from the code and commits since 1.6.2 (full list `docs/aso/events/changes-since-1.6.2.txt`):

- **Variables.** A cutling can hold a blank filled in each time it is used ("Ask Each Time", for a name or an order
  number), a choice between options, today's date, a time, tomorrow, yesterday, a week from now, the text last copied,
  and where the cursor ends. They show as pills in the text. On iPhone and iPad the Cutling keyboard asks for each
  blank before it types, with values used before one tap away; a word typed first fills the first blank. On the Mac,
  ⌘⇧V opens a short form for the blanks before it pastes. Commit c98f32ab (2026-11-22) added nine more: week
  number, time zone, a greeting by the hour, language, country, currency, the link or email on the clipboard, and
  counters (named or not) that go up by one each use, shared by the keyboard, app and Mac. The variable list is in
  `Cutling/FillInKinds.swift` and `Cutling/Placeholders.swift`.
- **Writing like Notes.** A cutling's text opens as a page that works like Apple Notes: bold, italic, underline,
  strikethrough, highlight, monospace, links, and bulleted, dashed and numbered lists.
- **Far more room.** 5,000 text cutlings and 500 images, up to 10,000 characters each (was 100, 25 and 1,000).
- **Every key types.** On the keyboard a formatted cutling types when tapped; touching and holding it copies it with
  its formatting.
- **A remade setup guide** with a short video of the Settings steps, and a What's New sheet.

The English What's New text: `fastlane/metadata/en-US/release_notes.txt` (iOS) and
`fastlane/metadata_mac/en-US/release_notes.txt` (Mac). What buyers say they want, in their own words:
`~/Repositories/undirect/docs/research/cutling-voice-of-customer.md`.

Recorded 2.0 screens (low-resolution drafts on non-store simulators, for seeing the real app):
`~/Downloads/cutling-text-page/`, `~/Downloads/cutling-fill-ins/`, `~/Downloads/cutling-onboarding/`.

## Facts that bind every direction

Apple's own text, with sources: `docs/aso/previews-2.0/apple-rules.md`. In short, previews may only use screen
captures of the app itself, with narration and video or text overlays allowed; Apple rejected Cutling 1.6.1 because
its previews drew a device bezel around the recording. 15-30 s, 30 fps, iPhone 886x1920 or 1920x886, iPad 1200x1600 or
1600x1200, Mac 1920x1080 landscape. Text stays long enough to read; no prices, no dates or seasonal references.

Recordings: this session records every take you list, on the store-size simulators (iPhone 18 Pro Max, iPad Air
13-inch M4, through the shared device queue) and on this Mac, in any language, light or dark, with any seed content
you write. Previews go up per store language; 1.6.x carried them in en-US, id and ja.

Music the owner has judged by ear (`~/.claude/projects/-Users-hafang-Repositories-undirect/memory/film-music-picks.md`):
on 2026-11-22 he called Mixkit 281 "Complicated" (Arulo) and Unminus "Hangtime" (WOWA) very good, with the reel and
licences in `~/Repositories/undirect/docs/research/pro-film-refs/music/`. On 2026-11-18 he ruled Cutling's music comes
from Mixkit, after a Pixabay track drew a YouTube copyright claim on every Cutling film.

What rivals' live App Store previews show, read 2026-11-22: `docs/aso/previews-2.0/rivals.md` (with frame sheets).
None of them promotes only its newest feature; each shows what the app is for as a whole, and Apple's guidance puts
an overview first. The owner asked of the first round: "You didnt see competitors did you? Did the promote the new
feature only?" On music he picked Mixkit 281 "Complicated" for these previews.

Reference material already gathered (use it, add to it from the best work in any category):
`~/Repositories/undirect/docs/research/pro-film-refs/` (notes on Apple, Samsung and app launch films with measured cut
times) and the `product-video` skill's `research/` folder (`appstore-previews.md` among them).

## What to hand back

Write `docs/aso/previews-2.0/directions.md` as each direction lands, with its files under
`docs/aso/previews-2.0/directions/<name>/`: per direction its idea, its pictures or clip, its words with what each
says to a buyer, and its take list. One contact sheet of all directions side by side, at the size the owner sees
them in a chat, so he can pick. Done is when the owner can open that sheet and tell the directions apart as different
ideas.

Do not commit; this session commits. Leave `fastlane/compose/creative/`, `fastlane/screenshots/` and
`fastlane/events/` as they are (other sessions' work in progress).
