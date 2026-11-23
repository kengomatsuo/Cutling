# Setup guide and What's New strings: meaning brief (ASG103, ASG105)

What each new on-screen string of the remade setup guide and the What's New sheet must mean. Every
locale, English included, is written from this brief through the `blind-translation` skill; no locale
is translated from another. Reuse each locale's own words from `Cutling/<locale>.lproj/Localizable.strings`
(its word for a cutling, keyboard, Settings, Full Access, clipboard, Continue, Done, Next), and match
how that locale's Settings app names "Keyboards" and "Allow Full Access", since the person goes there.

Background: Cutling keeps snippets of text and images ("cutlings") and types them into any app
through its own iPhone keyboard. After buying it, a person must add the keyboard in Settings. Full
Access is optional: without it the keyboard still types text; with it, it can also copy images and
save what was copied. Register: the app speaking plainly, short, no exclamation marks. Titles follow
the locale's title convention (English uses title case in these sheets, as Apple's own do).

## Welcome sheet (first page of setup)

Apple's own "Welcome to" sheet: a large title, three rows of an icon, a bold title and one grey line,
one Continue button.

| Key | Role | Must say | Budget |
|---|---|---|---|
| W1 | title | welcome to Cutling | 28 |
| W2 | row title | you tap a saved text to type it | 22 |
| W3 | row line | save what you type again and again, then tap it on the keyboard in any app | 90 |
| W4 | row title | images work too | 22 |
| W5 | row line | copy a saved image with one tap and paste it anywhere | 70 |
| W6 | row title | it stays on your iPhone | 26 |
| W7 | row line | no account and no internet; cutlings sync only through the person's own iCloud | 90 |

## Add the Keyboard page

A looping video of the real Settings steps, the three numbered steps under it (existing strings),
a link to the Full Access sheet, and one button that opens Settings.

| Key | Role | Must say | Budget |
|---|---|---|---|
| A1 | title | add the keyboard | 26 |
| A2 | subtitle | turn on Cutling in Settings, then come back to this app | 60 |
| A3 | link, and the title of the sheet it opens (one string serves both) | about Full Access | 26 |
| A4 | button | open Settings (uses the locale's own name for the Settings app) | 24 |
| A5 | VoiceOver label of the video | a video of the Settings steps: tap Keyboards, turn on Cutling, turn on Allow Full Access and tap Allow | spoken |
| A6 | VoiceOver label of the play button (shown when videos don't play by themselves) | play the Settings steps | 30 |

## About Full Access sheet

Same layout as the welcome sheet; a Done button closes it.

| Key | Role | Must say | Budget |
|---|---|---|---|
| F2 | subtitle | Cutling types your text without it | 50 |
| F3 | row title | images and clipboard | 26 |
| F4 | row line | Full Access lets the keyboard copy a saved image and add what you copied | 90 |
| F5 | row title | nothing leaves your iPhone | 30 |
| F6 | row line | Cutling has no account and never connects to the internet; it doesn't read what you type | 100 |
| F7 | row title | Apple's warning | 22 |
| F8 | row line | iOS shows the same warning for every keyboard that asks, whatever it does | 90 |

## Try It page

A text field with the keyboard up; the person switches to Cutling and taps the starter cutling.

| Key | Role | Must say | Budget |
|---|---|---|---|
| T1 | title | try it | 16 |
| T2 | subtitle | type with Cutling here | 36 |
| T3 | field placeholder | tap here | 18 |
| T4 | instruction (a globe icon sits where "%@" is) | touch and hold the globe key below, choose Cutling, then tap Try Me (Try Me is T7's name) | 90 |
| T5 | success line | Cutling typed it, the person is set | 40 |
| T7 | starter cutling's name (seed data) | an invitation to try this cutling | 14 |
| T8 | starter cutling's text (seed data) | a sentence the person sees typed by Cutling, as if they wrote it: Cutling typed this for me | 40 |

Rows N11, N12, N14, N15 and N16 sit under the Welcome Back title; its "tap to type" row reuses W2.

## What's New and Welcome Back

Apple's iOS 27 "What's New in Calendar" layout. Shown once after an update, or after 30 days away.

| Key | Role | Must say | Budget |
|---|---|---|---|
| N1 | title | what's new in Cutling | 28 |
| N2 | subtitle while fill-ins are on | blanks to fill in, and far more room | 50 |
| N3 | subtitle while fill-ins are off | far more room, and every key types | 50 |
| N4 | row title | blanks and dates | 24 |
| N5 | row line | add a blank or today's date from the editor, and fill the blank in each time you type the cutling | 110 |
| N6 | row title (`%@` is a number, e.g. 5,000) | room for %@ | 24 |
| N7 | row line (`%1$@` texts, `%2$@` images) | save up to %1$@ texts and %2$@ images | 60 |
| N8 | row title | every key types | 24 |
| N9 | row line | tap a formatted cutling and it types like the rest; touch and hold it to copy the formatting | 110 |
| N10 | title | welcome back to Cutling | 30 |
| N11 | row title | switch to Cutling | 24 |
| N12 | row line | touch and hold the globe key on your keyboard, then choose Cutling | 80 |
| N14 | row line | tap a cutling and it is typed where you are writing | 70 |
| N15 | row title | save from anywhere | 24 |
| N16 | row line | share text, links or images to Cutling from any app | 70 |

## How writers hand back

One JSON file per language at `docs/research/onboarding/strings/<language>.json`:
`{"folders": ["de", "de-DE"], "strings": {"W1": "...", ...}, "back": {"W1": "literal back-translation", ...}, "notes": "register and grammar choices"}`.
Keys are the IDs above (W1-W7, A1-A6, F2-F8, T1-T5, T7-T8, N1-N12, N14-N16). Keep `%@` where the table
shows it (N6 one number; N7 two numbers, written `%1$@` and `%2$@` when the order changes; T4 the
globe icon). If the locale's `Localizable.strings` already holds a string that says exactly the same
thing (N1 "What's New in Cutling", N15 "Save from Anywhere", the Settings app's name), reuse it.

## Tutorial: the fill-in step (TU1)

The interactive tutorial (replayed from How to Use Cutling) is in the snippet editor, creating
the first cutling. A tip bubble points at the text box. On iPhone, a bar above the keyboard holds
small buttons, one of them a curly-braces icon that puts a blank into the text. The tip may be
read out by VoiceOver too. The person can skip with the tutorial's Next button.

| Key | Role | Must say | Budget |
|---|---|---|---|
| TU1 | tip text | while you type the text, tap the braces button to leave a blank you fill in each time you use the cutling; or tap Next to skip | 110 |

## 2.0 corrections (ASG162, ASG195)

Six strings above said what is no longer true, and the What's New rows named an older editor.
These rows replace W6, W7, F5, F6, N2, N4 and N5, and add a row for the new text page. Written
the same way: from the meaning, in the locale's own words.

What is true, read from the code on 2026-11-23: Cutling has no account and collects nothing (its
privacy manifest lists no data and no tracking). Cutlings sync through the person's own iCloud
only when they turn on iCloud Sync. Saving a link fetches that page's title. The keyboard reads
the text just before the cursor to fill a blank, and never sends what is typed anywhere. So no
line may say Cutling never goes online, has no internet, or does not read what you type.

The editor now has a Variables button (each locale's `Localizable.strings` already holds its word
for "Variables"), which puts in a blank asked for each time the cutling is typed (the editor calls
it "Ask Each Time"), today's date, a choice, and more. A cutling's text now opens on a page of its
own, laid out like Apple's Notes, with bold, underline, highlight and lists.

| Key | Role | Must say | Budget |
|---|---|---|---|
| P1 | welcome row title (replaces W6) | what you save is private to you | 26 |
| P2 | welcome row line (replaces W7) | no account, nothing collected; cutlings sync only through the person's own iCloud, if they turn sync on | 90 |
| P3 | Full Access row title (replaces F5) | what you type stays private | 30 |
| P4 | Full Access row line (replaces F6) | Cutling has no account and collects nothing; what you type is never sent anywhere | 100 |
| N2b | What's New subtitle (replaces N2) | variables, writing like in Notes, and far more room | 50 |
| N4b | row title (replaces N4) | the editor's own word for Variables, exactly as the locale's `Localizable.strings` has it | 24 |
| N5b | row line (replaces N5) | edit a cutling and open Variables to put in a blank you fill in each time, today's date, a choice and more | 110 |
| N17 | row title | write the way you do in Notes (the locale's name for Apple's Notes app) | 24 |
| N18 | row line | a cutling's text opens on a page of its own, with bold, underline, highlight and lists | 110 |
| TU2 | the walkthrough's fill-in tip (replaces TU1). The person is typing the first cutling's text in the form's box; the bar above the keyboard shows icon-only buttons, and the tip shows the blank button's icon (a small text box) beside its words. VoiceOver reads the same words. | while you type the text, tap Ask Each Time above the keyboard to leave a blank you fill in each time; or tap Next to skip. "Ask Each Time" is the button's own name, exactly as the locale's `Localizable.strings` has it | 110 |

TU1 said "the braces button", and the walkthrough's bar has no braces: its blank button is a small
text box named Ask Each Time.
