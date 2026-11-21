# What Notes' bars do when the keyboard goes up and down (footage, 2026-11-21)

Notes is not on the iOS Simulator, so this is from recordings. The owner's own recording is the reference; the rest was found before it arrived and agrees with it. No footage of iPad Notes, and none of the Format panel opening or closing, was found.

## Sources

| File here | Source | Device, system | What it shows |
|---|---|---|---|
| `../owner-recording/notes-iphone-2026-11-21.mp4` | the owner's iPhone, 1180x2556, 60 fps, 12.3 s | iPhone, iOS 27, light | Keyboard up at 0.0-5.0 s, down at 5.1 s, up at 7.1 s, down at 8.4 s, up at 10.8 s |
| `owner-ios27-keyboard-down-4.9s-5.8s.jpg` | that recording, 4.9-5.8 s, a frame every 50 ms | | The Done check tapped and the keyboard leaving |
| `owner-ios27-keyboard-up-7.0s-7.9s.jpg` | that recording, 7.0-7.9 s, a frame every 50 ms | | A tap in the text and the keyboard arriving |
| `apple-support-scan-ios26-7s-17s.jpg` | Apple Support, "How to scan documents into Notes", https://www.youtube.com/watch?v=6CTIqVfD4qY (2026-03-06), 7-17 s, a frame a second | iPhone, iOS 26, light | Keyboard down: the bottom capsule and compose button; the attachment menu growing from the paperclip at 13-14 s |
| `techsimplify-ios27-keyboard-up-15.6s-18s.jpg` | TechSimplify, "iOS 27 - Notes App Top New Features Explained", https://www.youtube.com/watch?v=Btkj5KlhEpY (2026-07-15), 15.6-18.0 s, a frame every 100 ms; a camera pointed at a phone, not Apple's | iPhone, iOS 27, dark | Keyboard down, a tap in the text, keyboard up |

Looked at and not used: Apple Support "Share a note on your iPhone" (https://www.youtube.com/watch?v=42GMLWJ_0PQ, 2026-07-28: the note with the keyboard down, then the share sheet; no keyboard), zollotech "iOS 27 Notes and Reminders" (h_GVfq0ER_U, hand-held), APPLE 1-TO-1 TRAINING "How to Use Apple Notes in macOS 27, iOS 27 & iPadOS 27" (blDBVIm4_00, mostly the Mac). Apple Support's channel has no Notes formatting video for iOS 26 or 27 (its 248 newest uploads and its search for "notes" were listed).

## iPhone, iOS 27

**Keyboard up.** Top: back; undo in its own circle, only once there is something to undo; share and more in one capsule; a filled Done check in the app's tint. Above the keyboard: one glass capsule holding Aa, checklist, table, attachment, markup and more, the sixth cut off at the right edge (it scrolls sideways). Nothing at the bottom of the screen.

**Keyboard down.** Top: back, undo, share and more; no check. Bottom: a short glass capsule at the left with checklist, attachment and markup (Aa and table are gone), and a separate round compose button at the right.

**Going down** (check tapped at 5.10 s). The check shows its press, and one frame later it is gone; the top bar is already in its keyboard-down form. The keyboard slides down over about 0.3 s. The bar above it does not ride all the way down: it blurs out within about 0.1 s. The bottom capsule and compose button blur in at their resting place from about 0.2 s, while the keyboard is still leaving, and are sharp by 0.3 s.

**Going up** (text tapped at 7.05 s). The cursor shows at once. The keyboard rises over about 0.3 s. The bottom capsule and compose button lift with the keyboard's top edge for about 0.1 s and blur out; the full bar blurs in at its final place above the keyboard from 0.1 s and is sharp by 0.25 s. The check blurs in at the top right over the same 0.15 s. Nothing scales or bounces; every change is the system's glass blur.

**Attachment menu** (Apple Support clip, iOS 26, keyboard down). The paperclip shows a round press highlight, then a menu grows from it and covers the capsule: Scan Text, Scan Documents, Take Photo or Video, Choose Photo or Video, Image Playground, a rule, Record Audio, Attach File. Icon left, label right. The compose button stays.

## iPad

No footage. Apple's stills (`../shots/ipad-notes-*.png`) show the tools in the top bar's centre (Aa, checklist, table, attachment) and nothing above the keyboard; what the bar does as the iPad keyboard comes and goes is not known.

## The owner's second recording: dark mode, 58 s (2026-11-21 22:04)

Source: `~/Downloads/ScreenRecording_11-21-2026 22-04-02_1.MP4` (1180x2556, about 60 fps), the owner's iPhone, iOS 27; full-size frames in `../owner-recording/dark_<t>s.png`. Read here from: `owner-dark-bar-scrolled-30s-57s.jpg` (the bar's strip every 1.5 s, at half size), `owner-dark-bar-scrolling-28.6s-30.2s.jpg` (ten frames a second while the bar is dragged), `owner-dark-format-12s-menu-28s-link-40s-43s.png` (four whole frames).

**The bar is one long strip, not one page.** Dragged sideways it moves freely with the finger (28.6-30.2 s: Aa slides out at the left as B and I slide in at the right) and rests wherever it is let go. Its buttons, in order: Aa, checklist, table, attachment, markup; then bold, italic, underline, strikethrough, highlight, link; then outdent, indent, move up, move down, block quote, list. The inserts sit about 70 pt apart; the style glyphs, narrower, about 57 pt apart; the last group about 63 pt.

**A style that is on is a filled circle.** At 36 s, B stands on a circle in the app's tint (yellow), nearly as tall as the bar (about 42 of 48 pt), its glyph white; the others stay plain. At 55.5 s block quote is filled the same way. Nothing else marks the state.

**A button with choices opens a menu above the bar.** At 52-54 s the list button's menu (Bulleted, Dashed, Numbered: icon, then label) stands above the bar's right end, with the same dark glass and large corners; the bar stays where it is. At 28 s the attachment menu (Scan Text, Scan Documents, Take Photo or Video, Choose Photo or Video, a rule, Record Audio, Attach File) stands above the keyboard at the right and the bar is not drawn while it is open. How either menu opens and closes, frame by frame, was not read in this pass.

**Format panel, dark (12 s).** The keyboard and the bar are gone; a card stands at the bottom, about 9 pt in from each side, large corners, a shade lighter than the page: "Format" at the left, a round close button at the right; a row of style chips (Title, Heading, Subheading, Body, scrolling, the current one filled in the tint); a joined group B I U S beside a joined pen and colour dot; a joined group of three lists beside outdent and indent and a block-quote button. The check stays at the top right while it is open.

**Add Link (40.5-43 s).** A sheet covers the note to the top, the keyboard up: a round close button at the left, "Add Link" in the middle, a round check at the right, grey until something is entered. "Link To" above a tall field reading "Enter a URL or note title"; a row "Link to Section — None"; "Name" above a field reading "Optional".

**Keyboard down (0.5 s) and up (5 s).** As in the first recording, in dark: a capsule of three and a round compose button at the bottom; with the keyboard up, the full bar 10 pt above it and the check in the tint.
