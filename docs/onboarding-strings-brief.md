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
| A3 | link | about Full Access (opens an explanation) | 26 |
| A4 | button | open Settings (uses the locale's own name for the Settings app) | 24 |
| A5 | VoiceOver label of the video | a video of the Settings steps: tap Keyboards, turn on Cutling, turn on Allow Full Access and tap Allow | spoken |
| A6 | VoiceOver label of the play button (shown when videos don't play by themselves) | play the Settings steps | 30 |

## About Full Access sheet

Same layout as the welcome sheet; a Done button closes it.

| Key | Role | Must say | Budget |
|---|---|---|---|
| F1 | title | about Full Access | 26 |
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
| T6 | bar button | next (go on to the next page) | 12 |
| T7 | starter cutling's name (seed data) | an invitation to try this cutling | 14 |
| T8 | starter cutling's text (seed data) | a sentence the person sees typed by Cutling, as if they wrote it: Cutling typed this for me | 40 |

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
| N13 | row title | tap to type | 20 |
| N14 | row line | tap a cutling and it is typed where you are writing | 70 |
| N15 | row title | save from anywhere | 24 |
| N16 | row line | share text, links or images to Cutling from any app | 70 |
