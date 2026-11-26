# Free limit and unlock: what each string must do

Board ASG243 (parent ASG240). This brief is the only thing a locale's writer receives, with its own locale's
vocabulary file (`vocab/<locale>.json`). No locale is the source the others are translated from: English is one more
locale written from this same brief. There is no source string, and a writer never asks for one.

## The product and the moment

Cutling keeps short pieces of text and images (its own word for one is in the vocabulary file: use that word) and types
them into any app from its own iPhone keyboard, or pastes them on a Mac. From 10 December 2026 the app is free to
download. A free copy holds 5 items. One in-app purchase, paid once, lets it hold up to 5,000 text items and 500
images, on every iPhone, iPad and Mac signed in to the same Apple Account. There is no subscription, no advertising and
no sign-up. The person's first five items never stop working and nothing is taken away from them.

Who speaks: the app, plainly, to the one person using it (the app never says "we": one person makes it), in the form of address the vocabulary file already uses for
that person. Short and warm. No exclamation marks, no sales pressure, no urgency. This is the moment the app asks for
money, so it must read as if a person from that market wrote it for this screen. The app's name, Cutling, stays a
name; write it the way the vocabulary file does.

Numbers in examples are already formatted for the locale when they arrive as `%@`. `%lld` is a whole number the app
fills in; where the language orders two numbers differently, use positional forms (`%1$lld`, `%2$lld`). Keep every
placeholder exactly once. Use the locale's own typographic quotes, list conjunction and ellipsis character.

## The unlock sheet (iPhone and iPad)

The person has just tried to add a sixth item (from the + button, the keyboard's message, or Settings). A sheet rises
from the bottom, card coloured. Top left a round close button. Under it a row of the person's own five items as small
coloured tiles, then a sixth tile drawn with a dashed green outline and a plus, waiting. Under the five tiles a thin
bracket with a small grey label (S1). Then a large bold title (S2), a grey subtitle under it (S3, S4 or S5), three rows
(each a green icon, a bold line and a grey line), a small green link (S12 or S13), and at the bottom a wide green
capsule button (S14 or S15).

| Key | Role | What it must do | Variables | Budget |
|---|---|---|---|---|
| S1 | small grey label under the bracket that spans the five tiles | mark these five slots as the free ones | %lld = 5 | 12 Latin, 6 CJK |
| S2 | the sheet's title, 28 pt bold | invite the person to carry on saving beyond the free ones. Not a warning, not a limit message, not a sales line | none | one line: 20 Latin, 10 CJK, 16 Indic, Thai or Arabic script |
| S3 | subtitle when all five are used | say that the person has used all their free items, and that those items stay free and keep working | %lld = 5 | up to three lines: 90 Latin, 45 CJK |
| S4 | subtitle when nothing is saved yet | say that the person can save this many items for free | %lld = 5 | 45 Latin, 22 CJK |
| S5 | subtitle when some are used | say how many of the free items are used | first %lld = 3 (used), second %lld = 5 (free total) | 55 Latin, 28 CJK |
| S6 | first row, bold line, next to a stack icon | after unlocking there is space for this many items | %@ = 5,000, formatted for the locale | one line: 24 Latin, 12 CJK |
| S7 | first row, grey line | the person can save up to this many text items and this many images | %@ = 5,000 (formatted), %lld = 500 | two lines: 70 Latin, 35 CJK |
| S8 | second row, bold line, next to a laptop-and-phone icon | name the three kinds of Apple device, iPhone, iPad and Mac, joined the way the language lists three things | none | one line |
| S9 | second row, grey line | one purchase covers all three, on the person's Apple Account | none | two lines: 70 Latin, 35 CJK |
| S10 | third row, bold line, next to a seal with a check | the person pays a single time, nothing recurring | none | one line: 22 Latin, 11 CJK |
| S11 | third row, grey line | three things the purchase does not bring: no subscription, no advertising, no account to sign up for | none | two lines: 60 Latin, 30 CJK |
| S12 | small green link above the button | get back a purchase made earlier, in the exact wording iOS apps in this language use for that App Store action | none | 24 Latin, 12 CJK |
| S13 | the same link while it works | restoring is under way, ending with the ellipsis character | none | 24 Latin |
| S14 | the wide green button | pay once and unlock the app, with the price | %@ = the App Store price: $4.99, Rp 79.000, ¥800 | one line on the narrowest iPhone: 26 Latin, 13 CJK, plus the price |
| S15 | the same button before the price has loaded | the same action, no price | none | 14 Latin |
| S16 | what VoiceOver says for the round close button | close the sheet without buying, politely: putting it off, not refusing | none | spoken |
| S17 | the round close button's own system label | the plain verb for shutting a sheet or window, as iOS labels its close buttons | none | spoken |

## After the purchase

The purchase went through. In about two seconds the five tiles become the top corner of a large grid of empty slots
that fills the sheet, showing how much room there is now. The button's words change to the locale's existing done or
continue word (already in the vocabulary file). A large bold title rises in (S18) with a grey line under it (S19 or S20).

| Key | Role | What it must do | Variables | Budget |
|---|---|---|---|---|
| S18 | the title that rises in, 28 pt bold | warm and a little proud. The point is ownership, not capacity: it now belongs to the person, all of it, the room included. A line about how much they can save misses it | none | one line: 20 Latin, 10 CJK |
| S19 | grey line under it after buying | thank the person for buying, which supports the app and the one person who makes it | none | two lines |
| S20 | grey line under it after a restore worked | greet a returning buyer: their earlier purchase is back | none | two lines |
| S21 | what VoiceOver says for the tile row before buying | how many of the free items are used | first %lld = 3 (used), second %lld = 5 | spoken |
| S22 | what VoiceOver says for the grid after buying | how many items the person has, and that there is now room for this many | %lld = 5 (any number: write a form that works for 1, 2, 5 and 21), %@ = 5,000 | spoken |
| S23 | what VoiceOver announces the moment the unlock happens | the app is now unlocked, with room for this many items | %@ = 5,000 | spoken |

## When the purchase fails

An alert over the sheet, with the locale's existing OK button.

| Key | Role | What it must do | Variables | Budget |
|---|---|---|---|---|
| S24 | alert title | the purchase did not complete. Calm, no blame | none | 30 Latin, 15 CJK |
| S25 | alert message | the App Store cannot be reached at the moment; try again shortly | none | 90 Latin |
| S26 | alert message | the App Store did not confirm this purchase | none | 70 Latin |
| S27 | alert message after the person tapped S12 | no earlier Cutling purchase exists on the Apple Account signed in on this device | none | 80 Latin |

## Outside the sheet

| Key | Role | What it must do | Variables | Budget |
|---|---|---|---|---|
| S28 | the reason Siri or a Shortcut gives when a save is refused at the free limit | the free version holds this many items; unlocking Cutling once lets the person save as many as they like | %lld = 5 | spoken or a dialog: 100 Latin |
| S29 | small grey subtitle under the list title on the main screen of a free copy | how many free slots are used | first %lld = 4 (used), second %lld = 5 | 18 Latin, 9 CJK |
| K1 | the Cutling keyboard's message, a capsule one key tall across the keyboard, shown for four seconds when the person tries to save a sixth item from the keyboard | all the free items are used; tapping this message opens Cutling to unlock | %lld = 5 | one line: 38 Latin, 18 CJK, 30 Indic, Thai or Arabic script |

## The Mac

The Mac App Store build opens its own small window when the person at 5 of 5 tries to add another item, and has a
Cutling section at the top of its Settings.

| Key | Role | What it must do | Variables | Budget |
|---|---|---|---|---|
| M1 | the window's title, also listed in the Window menu | name the window where Cutling is unlocked (a verb-led command name, like other Mac window titles in this language) | none | 24 Latin |
| M2 | a button in Mac Settings that opens that window; ends with the ellipsis character because it opens a window | the same command as M1, as a Mac button | none | 26 Latin |
| M3 | the label of a Settings row on a free copy | the free items, as a row label; its value is M4 | none | 22 Latin |
| M4 | the value next to M3 | how many of the free items are used, as a compact number pair | first %lld = 3, second %lld = 5 | 10 Latin |
| M5 | the Settings row's status once bought | Cutling is unlocked | none | 22 Latin |
| M6 | small grey line under the Settings section on a free copy | one purchase unlocks Cutling on iPhone, iPad and Mac | none | 80 Latin |
| M7 | small grey line under the Settings section once bought | unlocked on iPhone, iPad and Mac with this Apple Account | none | 80 Latin |
| M8 | small grey line for someone who bought Cutling before it became free | they bought it before it went free, so it stays unlocked; thank them | none | 100 Latin |

## What a writer returns

For every key: the string, a literal back-translation into English word for word (not a polished one), and one line on
the choice made (register, grammar, a word picked from the vocabulary file, a plural form). For a language with several
locale folders, one string per folder where the regions write it differently, and say why.

## Second batch: when a cutling is added from outside the app

These come from the keyboard, the Share sheet and Shortcuts, when a free copy already holds its 5 items. The writer
returns them in a second file, `drafts2/<language>.json`, in the same shape.

| Key | Role | What it must do | Variables | Budget |
|---|---|---|---|---|
| N1 | the system's prompt when a Shortcut or Siri tries to save an item at the limit, on iOS 26 and later; the person can choose to continue in the app | the free items are all used; continuing in Cutling lets them unlock and this item gets saved | %lld = 5 | 110 Latin |
| N2 | the reply from that Shortcut on older iOS and on the Mac, where it cannot continue in the app | the free items are all used; opening Cutling is where they unlock to save more | %lld = 5 | 90 Latin |
| N3 | the keyboard's short message, a capsule one key tall, after saving the fourth item from the keyboard | it was saved, and one free place is left | none | one line: 30 Latin, 15 CJK |
| N4 | the same capsule after saving the fifth item | it was saved, and this fills the free places | first %lld = 5 (used), second %lld = 5 (free total) | one line: 30 Latin, 15 CJK |
| N5 | a bar across the keyboard, one row tall, that stays when the person tries to save a sixth item; tapping it opens Cutling to unlock, and the item they were saving is kept | the free places are full; unlocking saves this item | first %lld = 5, second %lld = 5 | one line: 40 Latin, 20 CJK, 32 Indic, Thai or Arabic script |
| N6 | the small green capsule button at the top right of the Share sheet's form, where the save button usually is, when the person is at the limit | unlock (a short button verb) | none | 10 Latin, 5 CJK |
| N7 | a notice row at the top of that Share form | the free items are all used; unlocking Cutling saves this one for them | %lld = 5 | two lines: 90 Latin, 45 CJK |
| N8 | the same notice when the app could not be opened from the Share sheet | the item has been kept for them; opening Cutling and unlocking will save it | none | two lines: 80 Latin, 40 CJK |
