# Cutling 2.0 App Store previews

Card ASG155. Nothing here is uploaded or committed. The owner picks from a contact sheet; this file is for the
session that records, builds and uploads the picked direction. Round two (below) replaces round one, which is kept
further down because its films are the right material for the second and third previews.

# Round two: six overviews (2026-11-22)

The owner saw round one and asked: "You didnt see competitors did you? Did the promote the new feature only?" He was
right on both counts. Every round-one direction led with something 2.0 adds, and direction A's idea and words were the
pitch Fast Reply's own preview already runs ("Write a reply once", "Leave blanks for what changes", "Fill in the
blanks"). `rivals.md` read the rivals' live previews: none promotes only its newest feature; each shows what the app
is for. Apple's own page says the same: "your first preview might share an overview of your app experience, and then
use subsequent previews to highlight additional content or features."

So each round-two direction is an overview of what Cutling is: a keyboard of the things you type again and again, a
place to keep them, a picker on the Mac, one purchase for iPhone, iPad and Mac. Each shows that through one idea and
puts what 2.0 adds inside the story. Each idea was checked against the nearest rival preview.

**The contact sheet: `directions/round-2/contact-sheet.png`.** Each direction's files are in
`directions/round-2/<key>/`: `iphone-01.png` to `iphone-07.png` at 886 x 1920, `ipad-01.png` at 1200 x 1600,
`mac-01.png` at 1920 x 1080, `storyboard.png`, `animatic-iphone.mp4` on "Complicated", `seam.png` and `seam.json`.
`directions/round-2/src/build.sh` rebuilds them from round one's kit in `directions/src/` plus `round-2/src/kit2.js`.
The screens are drawn to the app's measurements as stand-ins until the store-simulator takes exist, and every frame
says so.

| | Direction | The idea in a line | 2.0 inside it | Nearest rival, and the difference |
|---|---|---|---|---|
| G | Every app | The keyboard holds still while Apple's own apps change above it, one a bar: your address in Maps, the studio in Calendar, a reply in Messages that asks for the name, your account number in Safari, a photo. | The reply asks for the name | ClipboardKeyboard and Clip Keyboard stay in one chat; G goes through four of Apple's apps. |
| H | Save, keep, send | The whole loop in three chapters, each with its real control: share an address from Safari into Cutling, shape a reply like a note with a blank for the name, send it with one tap. | The Notes-like page, its Ask Each Time button, the keyboard asking | ClipboardKeyboard's second preview saves and pastes; H adds the middle step, the page where a reply is shaped. |
| I | Who it's for | Three people, three Cutlings: someone who sells online, someone who works for themselves, someone who runs a busy home, each with their own keyboard doing their everyday job. | The seller's reply asks for the name; the freelancer's brief types a whole list | No rival says who it is for; Todoist and Structured open that way, outside the category. |
| J | The first week | The library fills day by day: your address on Day 1, your bank details on Day 2, a reply that asks for the name on Day 3, a photo shared in from Photos on Day 5, thirty things on Day 7. | The reply that asks; room for a growing library | Every rival shows a finished set; J shows the set growing. |
| K | Every key, a whole sentence | Whatever the last key typed is set huge above the real keyboard, from an address to a reply that asks for the name to a welcome note with its list, then room for 5,000. | The ask, a list typed whole, 5,000 | Paste Keyboard for iPhone writes its captions into its own text field; K's big type is only ever what a key typed. |
| L | By hand | The same message in two lanes: typed on the iPhone's own keyboard above, put in by Cutling below, all five things in before the hand has finished the second. | The reply that asks, inside the race | Quick Paste opens on a problem set in words; L shows the problem as a second lane, typed by hand. |

## The set of previews

The pick is the first preview on every device. Apple asks that each further preview show something new, so the
second iPhone preview is what 2.0 adds to a reply (a blank Cutling asks for, a date and greeting that fill
themselves: round one's A or C, re-cut so its words are not Fast Reply's), and the third is writing a cutling like a
note with room for 5,000 (round one's B or F). The iPad and Mac carry the overview, then the same second preview if
there is time before December 1.

My pick for the first preview: **G**. It answers the first question a stranger has about a keyboard app (where does
it work?) with four of Apple's own apps, each bar carries two short lines that read at search size, and no rival's
preview looks like it. **I** is the strongest second choice: it shows the range of uses in the buyers' own
situations (VoC: sellers, freelancers, people answering the same questions), and its keyboards differ person to
person.

## What binds round two

Everything in round one's "What binds every direction" still holds: only the app's own screens with type and touch
marks, no device frame, loops, no dates or prices, the globe shown once, the brand and the sound. Round two adds:

- **The overview covers the whole app.** Each direction shows the keyboard working in other apps and at least one
  other part of Cutling (saving, the grid, the page, the share sheet, the Mac's History). Each end card says Cutling
  is on iPad and Mac with one purchase, which the listing states ("One purchase includes Cutling for Mac",
  `fastlane/metadata/en-US/description.txt`); "any app" is the listing's own claim too (`promotional_text.txt`).
- **What the app really does, frame by frame.** Read in the code on 2026-11-22:
  - The keyboard's Add from Clipboard names a new key "Clip:" with today's date and time
    (`KeyboardViewController.swift`, `timestampString`), which a preview must not show. So no take saves that way on
    camera: H and J save through the share sheet, where you type the name.
  - A new cutling goes to the end of the list (`CutlingStore.add` appends), so J's new keys appear last.
  - A keyboard types plain text. A formatted cutling arrives with its list's bullets and without its bold
    (`RichText.plainText`), and K and I show exactly that. Long press copies the styled version (round one's B).
  - The text page's own bar has Ask Each Time, which opens a half-height sheet (✕, Ask Each Time, ✓; the name already
    "Name"). H uses that bar button. The Variables list would add the blank too, but its Dates group shows today's
    date.
  - The Mac's History rows are one line each, and a row's menu has Copy, Save as Cutling and Remove from History
    (`MacPickerView.swift`).
- **No rival's words.** The lines were checked against every rival caption in `rivals.md`. None uses "write a reply
  once", "leave blanks", "fill in the blanks", "save it once", "copy it anytime", "paste in one tap" or "type less".
- **Music.** "Complicated" (Mixkit 281), the owner's pick. Each animatic starts the track where its first drop
  (22.51 s) lands on the film's turn:

| Direction | Film | Track starts at | The drop lands on |
|---|---|---|---|
| G | 10 bars, 22.7 s | 15.71 s | Messages, the reply that asks for the name (6.8 s) |
| H | 10 bars, 22.7 s | 11.18 s | Send (11.3 s) |
| I | 13 bars, 29.5 s | 19.0 s | the seller's reply filling with Maya (3.5 s); the second drop (43.04 s) lands at 24.0 s, before the end card |
| J | 12 bars, 27.2 s | 4.38 s | Day 7 (18.1 s); the quiet intro plays under Day 1 |
| K | 12 bars, 27.2 s | 13.44 s | Order update asking for the name (9.1 s) |
| L | 11 bars, 24.9 s | 12.5 s | Cutling's fifth thing going in (9.8 s) |

The music fades in over 0.15 s and out over the last 1.2 s. Every film dissolves into its first frame over its last
0.6 s, a rest at the seam; each `seam.png` plots value, speed and acceleration across it, and all six read continuous.

---

## G. Every app

**Idea.** The Cutling keyboard holds still at the bottom while Apple's own apps change above it, one a bar. Each bar
says two things in words: what went in, and where.

**From references, and its own.** Apple's own films show one control used in many places, and Things shows real
interface one feature per shot. G's own move: the keyboard is the constant and the world above it changes, so the
viewer learns that Cutling is a keyboard and that it works in the apps they use, without being told either.

**Look.** Paper, two lines of type over the screen (what, then where, in the brand's accent), the whole screen floating
below at 1.5 px a point so each app is recognisable.

**Beats (iPhone, 10 bars, 22.7 s; poster at 3.4 s).**

| Time | On screen | Words |
|---|---|---|
| 0.0 | Messages to Maya, your own keyboard | What you keep typing, one tap away |
| 0.5 to 1.55 | Hold the globe, slide to Cutling | |
| 2.27 | Maps, the search field up: tap Home address; the address fills the search and shows on the map | Your address · in Maps |
| 4.53 | Calendar, New Event "Pottery class": tap Studio address into Location | The studio · in Calendar |
| 6.8 | Messages to Maya: tap Order update, it asks the name, tap Maya; then tap Thank you | A reply that asks for the name · in Messages |
| 11.33 | Safari, a refund form: tap Account number into its Account number field | Your account number · in Safari |
| 13.6 | Messages to Lea: tap Size chart (it copies), paste: the photo | A photo · in Messages |
| 15.87 | End card | Any app on your iPhone. Also on iPad and Mac, one purchase for all three. + icon, Cutling |
| 22.07 to 22.67 | Dissolve into frame 0 | |

**Words and what each says to a buyer.**

| Line | Says |
|---|---|
| What you keep typing, one tap away | What Cutling is, in the buyer's own terms (VoC A1: "type out the same info over and over"). |
| Your address · in Maps (and the four like it) | Each bar is a real everyday job, in an app the buyer already uses. |
| A reply that asks for the name · in Messages | 2.0's biggest addition, inside the overview as one of the jobs. |
| Any app on your iPhone. | The point of the film: it works where you already type. |
| Also on iPad and Mac, one purchase for all three. | What rivals cannot match: one purchase across devices, with no subscription named or priced. |

**iPad.** The same keyboard under Calendar on the iPad. **Mac.** ⌘⇧V's picker at the cursor in Calendar: "Any app on
your Mac".

**Takes (per language; the shared setup is round one's "Recording" plus the notes below).** The keyboard must look the
same in every iPhone take (the same keys in the same order, Full Access on), because the cut keeps it still while only
the app above it dissolves.

| Take | Device | Screen and settings | What happens | Record / used |
|---|---|---|---|---|
| G1 | iPhone | Messages, new message to Maya, your own keyboard up | Hold the globe 1 s, slide to Cutling, let go | 5 s / 2 s |
| G2 | iPhone | Maps, the search field focused, Cutling up | Tap Home address; the search fills | 6 s / 2.3 s |
| G3 | iPhone | Calendar, New Event "Pottery class", Location focused | Tap Studio address | 6 s / 2.3 s |
| G4 | iPhone | Messages to Maya, Cutling up | Tap Order update; the fill-in screen; tap Maya; tap Thank you | 10 s / 4.5 s |
| G5 | iPhone | Safari, a plain local page with a refund form (no business named), Account number focused | Tap Account number | 6 s / 2.3 s |
| G6 | iPhone | Messages to Lea | Tap Size chart (it copies); touch and hold the field, Paste; the photo | 8 s / 2.3 s |
| G7 | iPad | Calendar, New Event, Location focused | Tap Studio address | 8 s / 3 s |
| G8 | Mac | Calendar, an event's Location field | ⌘⇧V, pick Studio address, it pastes | 10 s / 4 s |

---

## H. Save, keep, send

**Idea.** The whole loop in three chapters, each with its real control. Save: share the studio's address from a page
in Safari into Cutling and name it. Keep: Cutling's grid, and a reply shaped like a note, given a blank for the name
with the page's own Ask Each Time button. Send: one tap in Messages, the keyboard asking the name. The chapter words
are set huge on the brand's three grounds.

**From references, and its own.** Things' "Meet the all-new Things" sets chapter names alone on colour, and CleanShot
alternates a caption card with the product on the bar. H's own move: three verbs that are the whole product, each
proved by the control that does it, and a poster that is just the three words.

**Beats (iPhone, 10 bars, 22.7 s; poster at 0 s).**

| Time | On screen | Words |
|---|---|---|
| 0.0 | Save, Keep, Send on the tint | Save · Keep · Send · Everything you type twice, kept in Cutling |
| 2.27 | Safari, a "Pottery class" page: hold the address, Share… | Save · Share it to Cutling wherever you find it |
| 3.52 to 5.9 | The share sheet; Cutling; Cutling's own sheet, named Studio address; Done | |
| 6.8 | Cutling's grid (Studio address now last): tap Order update; its page | Keep · Shape it like a note, with a blank for the name |
| 8.5 to 9.85 | Ask Each Time in the page's bar; its sheet; ✓; the Name pill after "Hi " | |
| 11.33 | Messages to Maya: Order update asks the name; Maya | Send · One tap puts it in any app |
| 15.87 | End card on the dark band | Save · Keep · Send. On iPhone, iPad and Mac, with one purchase. + icon, Cutling |

**Words and what each says to a buyer.**

| Line | Says |
|---|---|
| Save · Keep · Send | The whole product in three verbs the buyer can repeat. |
| Share it to Cutling wherever you find it | Saving takes a moment, from the app you are in. |
| Shape it like a note, with a blank for the name | Keeping is writing, the way Notes works (2.0), with a gap for what changes. |
| One tap puts it in any app | Sending is one tap, in the apps the buyer uses. |

**iPad.** Keep: the reply as a page at full width with its blank. **Mac.** Save from the clipboard history: what you
copy on the Mac waits in History, and a row's Save as Cutling keeps it.

**Takes.**

| Take | Device | Screen and settings | What happens | Record / used |
|---|---|---|---|---|
| H1 | iPhone | Safari, a plain local page: "Pottery class", "Where: 22 Mill Lane, Studio 4" (no business named) | Touch and hold the address; Share…; Cutling; in Cutling's sheet type the name Studio address; Done | 14 s / 4.5 s, the typing cut out |
| H2 | iPhone | Cutling's grid; Order update seeded as "Hi , your order ships {weekday tomorrow}." | Tap Order update; put the cursor after "Hi "; Ask Each Time in the bar; ✓ | 12 s / 4.5 s |
| H3 | iPhone | Messages to Maya, Cutling up | Tap Order update; the fill-in screen; tap Maya | 6 s / 4.5 s with a hold |
| H4 | iPad | Order update's page with its Name pill | Hold on the page | 6 s / 4 s |
| H5 | Mac | Safari, then the picker | Copy the address in Safari; ⌘⇧V; History; right-click it, Save as Cutling | 12 s / 5 s |

---

## I. Who it's for

**Idea.** Three people, three Cutlings. Above the real screen, the person ("If you sell online") and the names of what
they keep, as chips; below, the lower half of the screen at its own resolution, that person's own keyboard doing their
everyday job.

**From references, and its own.** Todoist opens on "Simple enough for personal use" and Structured on a day in
people's lives: both say who the app is for before showing it. I's own move: the keyboard itself changes person to
person, which proves that Cutling holds whatever a person sends. No person is filmed, because Apple allows only the
app.

**Beats (iPhone, 13 bars, 29.5 s; poster at 3.0 s).**

| Time | On screen | Words |
|---|---|---|
| 0.0 | Paper. The seller's chips; Messages to Maya, your own keyboard | If you sell online · Order update, Size chart, Returns, Shipping times |
| 0.5 to 1.55 | Globe to Cutling | |
| 2.4 to 3.6 | Order update asks the name; Maya | |
| 5.6 to 6.8 | Size chart, copied and pasted | |
| 9.07 | Tint. The freelancer; Messages to Ben | If you work for yourself · Bank details, Project brief, When I'm free, Portfolio |
| 10.07, 12.17 | Bank details; Project brief, its list typed as text with the bullets kept | |
| 18.13 | The dark band. The home; Messages to Lea | If you run a busy home · Home address, Wi-Fi, House notes, School office |
| 19.13 | House notes: the Wi-Fi, the door code, bedtime | |
| 24.93 | End card | For whatever you type twice. On iPhone, iPad and Mac, with one purchase. + icon, Cutling |

**Words and what each says to a buyer.**

| Line | Says |
|---|---|
| If you sell online / If you work for yourself / If you run a busy home | This is for someone like me. |
| The chips (Order update, Size chart, Returns, Shipping times …) | Here is what someone like me would keep in it. |
| For whatever you type twice. | And for anything else you repeat. |

**iPad.** The freelancer's brief at the iPad's width. **Mac.** The seller's reply from ⌘⇧V's form, asking the buyer's
name.

**Takes.** Each person has its own seed (below), recorded as its own take.

| Take | Device | Screen and settings | What happens | Record / used |
|---|---|---|---|---|
| I1 | iPhone | Seller's seed; Messages to Maya, your own keyboard | Globe to Cutling; Order update, Maya; Size chart, then touch and hold the field, Paste | 14 s / 9 s |
| I2 | iPhone | Freelancer's seed; Messages to Ben, Cutling up | Bank details; Project brief | 8 s / 9 s with holds |
| I3 | iPhone | Home's seed; Messages to Lea, Cutling up | House notes | 6 s / 6.8 s with a hold |
| I4 | iPad | Freelancer's seed; Messages to Ben | Bank details; Project brief | 8 s / 4 s |
| I5 | Mac | Seller's seed; Notes | ⌘⇧V, Order update, the form, Maya, Paste | 10 s / 4 s |

---

## J. The first week

**Idea.** What Cutling becomes. Day 1 it holds your address; Day 2 your bank details too; Day 3 a reply that asks for
the name; Day 5 a photo, shared in from Photos; Day 7 thirty things, one tap each. The keyboard itself counts the days:
one key on Day 1, more each day, each new one last as the app adds it.

**From references, and its own.** A diary's day headings, and a row of seven marks filling up. J's own move: the
library grows on screen, which no rival shows, and the ending tells the buyer how to start (save a thing the first time
you type it).

**Beats (iPhone, 12 bars, 27.2 s; poster at 9.9 s).**

| Time | On screen | Words |
|---|---|---|
| 0.0 | Day 1; Maps, your own keyboard | Day 1 · Your address |
| 0.5 to 1.55 | Globe to Cutling: one key | |
| 2.6 | Home address into Maps | |
| 4.53 | Day 2; Messages to Jonas, two keys: tap Bank details | Day 2 · Your bank details |
| 9.07 | Day 3; Messages to Maya, three keys: Order update asks the name; Maya | Day 3 · A reply that asks for the name |
| 13.6 | Day 5; Photos: Share; Cutling; Cutling's sheet, named Size chart; Done | Day 5 · A photo you send a lot |
| 18.13 | Day 7; Cutling's grid: 30 Cutlings, scrolling | Day 7 · Thirty things, one tap each |
| 22.67 | End card | Save it the first time. Tap it every time after. On iPhone, iPad and Mac, with one purchase. + icon, Cutling |

**Words and what each says to a buyer.**

| Line | Says |
|---|---|
| Day 1 · Your address | Start with one thing; it is useful at once. |
| Day 2 · Your bank details | The keyboard grows a key at a time. |
| Day 3 · A reply that asks for the name | It handles replies to people, not only fixed text. |
| Day 5 · A photo you send a lot | Images too, saved from Photos. |
| Day 7 · Thirty things, one tap each | Where a week of use gets you. |
| Save it the first time. Tap it every time after. | How to use it, in one line. |

**iPad.** Day 7 on the iPad, a full keyboard. **Mac.** Day 2 on the Mac: the account number in History, kept with
Save as Cutling.

**Takes.**

| Take | Device | Screen and settings | What happens | Record / used |
|---|---|---|---|---|
| J1 | iPhone | Seeded with only Home address; Maps, search focused, your own keyboard | Globe to Cutling (one key); tap it | 8 s / 4.5 s |
| J2 | iPhone | Home address, then Bank details; Messages to Jonas, Cutling up | Tap Bank details | 5 s / 4.5 s with a hold |
| J3 | iPhone | Home address, Bank details, Order update; Messages to Maya | Order update; Maya | 6 s / 4.5 s |
| J4 | iPhone | Photos with the size chart image (added with `simctl addmedia`) | Share; Cutling in the row of apps; in Cutling's sheet type the name Size chart; Done | 12 s / 4.5 s, the typing cut out |
| J5 | iPhone | Cutling's grid seeded with 30 cutlings | A slow scroll | 6 s / 4.5 s |
| J6 | iPad | Messages, Cutling up, about fifteen keys | Hold | 4 s / 4 s |
| J7 | Mac | Notes; the account number copied | ⌘⇧V; History; right-click, Save as Cutling | 8 s / 4 s |

---

## K. Every key, a whole sentence

**Idea.** One key, one whole thing. Dark; the lower half is the real keyboard in Messages at its own resolution;
above it, whatever the last key typed is set huge: an address, bank details, the Wi-Fi, a reply that asks for the name,
a photo, a welcome note with its list; then a fast scroll through a keyboard with room for 5,000.

**From references, and its own.** Apple's iOS 26 film pushes in until one control fills the frame, and Halide works in
black, white and one accent. K's own move: the type is never a slogan, only the text a key just put in, so the film's
words and the product's output are the same thing. The welcome note arrives as the keyboard types it: plain text, its
bullets kept.

**Beats (iPhone, 12 bars, 27.2 s; poster at 3.2 s).**

| Time | On screen | Words |
|---|---|---|
| 0.0 | Dark; Messages to Maya, your own keyboard | Each key types a whole thing |
| 0.5 to 1.55 | Globe to Cutling | |
| 2.3, 4.55, 6.8 | Home address; Bank details; Wi-Fi | 14 Linden Road, Flat 3 · Account 0441 2290 18 · studio-guest fern2291, each with its key's name |
| 9.07 to 10.2 | Order update asks; Maya | Hi Name, your order ships Friday. · Order update asks for the name |
| 12.4 | Size chart, copied and pasted | (the photo, large) · Size chart, a photo |
| 14.7 | Studio welcome, its list typed whole | Welcome to the studio! • Door code 4815 … · Studio welcome, a whole list in one tap |
| 16.2 to 20.2 | A long fling through a full keyboard | 5,000 keys, if you need them |
| 20.4 | End card | One key for each thing you retype. On iPhone, iPad and Mac, with one purchase. + icon, Cutling |

**Words and what each says to a buyer.**

| Line | Says |
|---|---|
| Each key types a whole thing | What a Cutling key is: a whole thing you would otherwise type out. |
| The typed texts, set large | Proof, at search size, of what one key holds. |
| 5,000 keys, if you need them | It will not run out (2.0). |
| One key for each thing you retype. | The promise. |

**iPad.** One key, a whole address, with the iPad keyboard below. **Mac.** One row of ⌘⇧V's picker, a whole account
number.

**Takes.** The big type is set in the cut from each take's own typed text; it never shows words the take did not type.

| Take | Device | Screen and settings | What happens | Record / used |
|---|---|---|---|---|
| K1 | iPhone | Dark; Messages to Maya, your own keyboard | Globe to Cutling | 5 s / 2 s |
| K2 | iPhone | Dark; Messages to Maya, Cutling up | Home address; Bank details; Wi-Fi (a fresh message between) | 12 s / 6.8 s |
| K3 | iPhone | Dark | Order update; Maya | 5 s / 3.3 s |
| K4 | iPhone | Dark | Size chart; touch and hold the field, Paste | 6 s / 2.3 s |
| K5 | iPhone | Dark; Studio welcome written on its page as a list | Tap Studio welcome; it types as text, bullets kept | 4 s / 2.3 s |
| K6 | iPhone | Dark; seeded with 5,000 texts | One long fling down the keyboard | 6 s / 4 s |
| K7 | iPad | Dark; Messages | Home address | 4 s / 3 s |
| K8 | Mac | Dark; Notes; 5,000 texts | ⌘⇧V; Bank details | 8 s / 4 s |

---

## L. By hand

**Idea.** The same message in two lanes. Above, someone types it on the iPhone's own keyboard at an ordinary pace;
below, Cutling puts in the address, the bank details, a reply that asks for the name, the Wi-Fi and a thank-you, and
is done at 9.8 s, while the hand is still on the second of them (it finishes the bank details at 13.8 s). No timer or
counter is laid over it; the two fields say it.

**From references, and its own.** The house's approved address race (cutling-promo, "typed-versus-tap"), made whole
and honest for the store: both lanes are real takes at real speed. L's own move: the hand lane is the problem, so the
film needs no caption for the problem.

**Beats (iPhone, 11 bars, 24.9 s; poster at 6.0 s).**

| Time | On screen | Words |
|---|---|---|
| 0.0 | Two lanes: Messages to Maya in each | Typing it · With Cutling |
| 0.3 to 1.35 | Lower lane: globe to Cutling | |
| 0.6 on | Upper lane: the message typed key by key at about 3.4 characters a second | |
| 1.9 to 9.8 | Lower lane: Home address, Bank details, Order update (asks; Maya), Wi-Fi, Thank you | |
| 9.8 to 18.1 | The lower lane is done; the upper lane finishes the bank details and starts "Hi Maya, your" | |
| 18.13 | End card | Stop typing the same things. On iPhone, iPad and Mac, with one purchase. + icon, Cutling |

**Words and what each says to a buyer.**

| Line | Says |
|---|---|
| Typing it · With Cutling | Two ways to send the same message; watch the difference. |
| Stop typing the same things. | The buyer's own complaint turned into the promise (VoC A1). |

**iPad.** The two lanes at the iPad's width. **Mac.** The address typed by hand beside ⌘⇧V pasting four things.

**Takes.**

| Take | Device | Screen and settings | What happens | Record / used |
|---|---|---|---|---|
| L1 | iPhone | Messages to Maya, your own keyboard, autocorrect off | A UI test taps the on-screen keys at 3.4 a second through the whole message | 45 s / 18 s |
| L2 | iPhone | Messages to Maya | Globe to Cutling; Home address; Bank details; Order update, Maya; Wi-Fi; Thank you | 14 s / 18 s with a hold |
| L3 | iPad | The same two takes on the iPad | As L1 and L2 | 45 s and 14 s / 18 s |
| L4 | Mac | Notes, two windows | The address typed by hand; ⌘⇧V four times | 30 s / 10 s |

---

## Recording notes for round two

- Apps on the store iPhone simulator (`xcrun simctl listapps`, read 2026-11-22): Messages, Maps, Calendar, Reminders,
  Safari, Photos and Contacts are there; Notes and Mail are not, so no iPhone take uses them.
- Saving on camera goes through the share sheet (H1, J4). Cutling's sheet suggests a name; type the one the film uses.
  The keyboard's Add from Clipboard would name the key with today's date and time.
- Maps: keep the take on the search field and its first result. If Maps resolves the made-up address to a real home,
  cut before the result list.
- Calendar: New Event's date rows sit under the keyboard; check no date is in frame.
- Photos: add the size chart image with `xcrun simctl addmedia` before J4.
- Safari (G5, H1): plain local pages; no business named on them.
- The typing lane (L1, L3): a UI test taps the on-screen keys one by one at a fixed rate, so the keys can be seen
  pressing; a person typing also works if the pace is ordinary.

## Seed for round two (English)

| Set | Cutlings, in the keyboard's order |
|---|---|
| Everyday (G, K, L) | Home address `14 Linden Road, Flat 3`; Order update `Hi {Name}, your order ships {weekday tomorrow}.` (Name's recent values Maya, Jonas, Aiko, Sam, Lea); Bank details `Account 0441 2290 18` (G: Account number `0441 2290 18`); Studio address `22 Mill Lane, Studio 4`; Size chart (an image) or Wi-Fi `studio-guest · fern2291`; Thank you `Thank you so much for your order!` |
| H | Home address; Order update (`Hi , your order ships {weekday tomorrow}.` before H2, the Name pill added on camera); Bank details; Wi-Fi; Thank you; then Studio address, added in H1 |
| Seller (I) | Order update; Size chart (image); Returns; Shipping times; Thank you; Bank details |
| Freelancer (I) | Bank details `Account 0441 2290 18 · Sort code 20-14-55`; Project brief (a heading and a three-item bulleted list); When I'm free `I can start on {weekday}`; Portfolio; Invoice note; Signature |
| Home (I) | House notes (Wi-Fi, door code 4815, bedtime, as three lines); Home address; Wi-Fi; School office; Swimming; Allergies |
| K's extra | Studio welcome (a heading line and a three-item bulleted list); 5,000 generated texts for K6 |
| J's days | Home address; then Bank details; then Order update; then the size chart, shared in on camera; then 30 |

## Round two in Indonesian and Japanese

Written blind from these meanings, never translated from the English lines.

| Line | Meaning to write from |
|---|---|
| What you keep typing, one tap away | The things you type again and again, each one tap away. |
| Your address · in Maps (and the others) | What went in, then the app it went into. App names as each language's iPhone shows them. |
| A reply that asks for the name | A saved reply that asks you who it is for before it types. |
| Any app on your iPhone. | It works in any app on your iPhone. |
| Also on iPad and Mac, one purchase for all three. | It is on iPad and Mac too, and one purchase covers all three. |
| Save · Keep · Send | Three verbs: put it in Cutling, keep it there, send it into an app. |
| Share it to Cutling wherever you find it | When you come across something worth keeping, share it to Cutling from that app. |
| Shape it like a note, with a blank for the name | Write the cutling as you would a note, leaving a gap for the name. |
| One tap puts it in any app | One tap types it into whatever app you are in. |
| If you sell online / If you work for yourself / If you run a busy home | Three kinds of people, addressed directly: someone who sells online, someone self-employed, someone running a busy household. |
| For whatever you type twice. | For anything you find yourself typing more than once. |
| Day 1 … Day 7 lines | The day number, then what was saved that day (as in the English). |
| Save it the first time. Tap it every time after. | The first time you type something, save it; after that, tap it. |
| Each key types a whole thing | Every key on this keyboard types a whole piece of text, not a letter. |
| Studio welcome, a whole list in one tap | The key's name, then: one tap types the whole list. |
| 5,000 keys, if you need them | It can hold up to 5,000 of them. |
| One key for each thing you retype. | A key for every piece of text you would otherwise type again. |
| Typing it · With Cutling | The two lanes: typing by hand, and using Cutling. |
| Stop typing the same things. | You no longer have to type the same things again and again. |

## For the owner (round two)

1. Pick one overview for the first preview (my pick: G, then I).
2. The second preview: round one's A or C, re-cut so its words are not Fast Reply's.
3. The Mac cuts paste into Notes or Calendar, which a fresh macOS user can use; Mail would need an account there.

---

# Round one: six feature-led directions (shown 2026-11-22, not picked)

The owner's answer to these is quoted under round two. Each leads with something 2.0 adds, which is why none is a
first preview; A and C (blanks and dates) and B and F (writing like a note, room for 5,000) are the material for the
second and third previews. Their contact sheet is `directions/contact-sheet.png`.

Card ASG155. Written 2026-11-22 from `brief.md` and `apple-rules.md` beside this file. Nothing here is uploaded
or committed. The owner picks from **`directions/contact-sheet.png`**; this file is for the session that records,
builds and uploads the picked direction.

Every picture in `directions/` is drawn to the app's measurements (the store iPhone's 440 x 956 pt screen,
the keyboard's 44 pt keys, 64 pt cards and 6 pt spacing from `KeyboardViewController.swift`, the fill-in screen
from `FillInPanel.swift`, the guide's own words from `SetupFlows.swift`) and says on itself that it is a stand-in.
The films are cut from store-simulator recordings of the real app once a direction is picked; the take list for
each direction is at the end of its section.

| | Direction | The idea in a line | What of 2.0 it shows |
|---|---|---|---|
| A | Fill in the blank | One saved reply goes to five people, and each time Cutling asks only for the name. | Ask Each Time, values used before, a weekday stamp; the Mac's ⌘⇧V form |
| B | Like a note | Write a cutling the way you write a note, and one tap types all of it. | The Text page and Format card, every key types, hold to copy formatted |
| C | Around the clock | The same saved reply typed at 9:12, 2:20 and 9:40 comes out right for the hour every time. | Greeting by Hour, Time, Counter, a weekday stamp |
| D | Five taps | One uncut take: a long, warm reply built from five taps, with nothing laid over it until the end. | Ask Each Time, Choice, Greeting by Hour, Weekday, Cursor Position, long text |
| E | First minute | From the first page of the new setup guide to the first typed reply, with Apple's Full Access warning answered on the spot. | The remade setup guide and its Settings video; a reply with a blank |
| F | Room for everything | The numbers 2.0 raised (5,000 texts, 10,000 characters each, 500 images), each proved on the next screen. | 5,000 texts, 10,000 characters, 500 images |

## Files

Per direction, in `directions/<key>/`:

- `iphone-01.png` to `iphone-07.png`: frames at the delivered 886 x 1920, `ipad-01.png` at 1200 x 1600, `mac-01.png` (and A's `mac-02.png`) at 1920 x 1080.
- `storyboard.png`: the seven iPhone frames in a row.
- `animatic-iphone.mp4`: the iPhone cut at its real length and pace, on the music, from the drawn stand-ins.
- `seam.png` and `seam.json`: speed and acceleration of everything that moves, 1.5 s either side of the loop's seam, with the verdict.

`directions/src/` rebuilds all of it: `bash src/build.sh` (stills, seam plots, storyboards, contact sheet, then
the six animatics, about ten minutes), `bash src/build.sh stills`, `bash src/build.sh animatic <key>`. The
drawings are `kit.js` (screens), `stage.js` (placing them, type, the seed) and one script per direction.

## What binds every direction

- **Only the app's own screens, plus type and touch marks.** Guideline 2.3.4 and Apple's preview page allow
  captures of the app with text overlays and touch hotspots. No device frame anywhere: 1.6.1 was rejected for
  one. The Mac cuts show no MacBook, only the screen. The keyboard is shown working in Apple's Messages on
  the iPhone and iPad and in Notes on the Mac, as a keyboard has to be.
- **They sell Cutling, not the update.** Apple's search page says people who downloaded an app before see its
  In-App Event card in search, and everyone else sees its screenshots or previews. The previews are for people
  who have never had Cutling, so each one shows what Cutling is (a keyboard of saved replies) through what 2.0
  adds. The event card already speaks to existing owners.
- **They loop.** Apple's asset guidance: "Videos autoplay and repeat, so people may see the loop multiple
  times. Ensure your video is polished and loops smoothly without visible jumps or breaks." A ends exactly where
  it starts; B, D, E and F dissolve into their first frame over their last 0.6 s; C runs on through its seam.
  Each folder's `seam.png` plots speed and acceleration across the seam: all six are continuous. The music fades
  out over the last 1.2 s and in over the first 0.15 s, so the seam is quiet too.
- **Words read at search size.** In search a portrait preview is one of three tiles across the result, about a
  third of the phone's width. The line that carries each idea is set at 80 px or more on the 886 px frame (A's
  sentence, C's clock and F's numbers at 112 to 300 px), about 12 pt on the phone in search and 23 pt on the
  product page. The smaller lines (A's 48 px caption, C's 40 px line) are for the product page, where they come
  out at about 14 pt.
- **Nothing on screen dates the film or names a price.** Seeds use Weekday, Time, Greeting by Hour and Counter, never
  Today's Date with a year (a card shows a date pill's value, so a dated seed would put a date on screen). The
  iPad's status bar date is overridden or kept under the cut's top band.
- **The control that turns Cutling on is shown.** Every iPhone and iPad cut holds the globe and picks Cutling
  once, long enough to read, as the product-video rules ask; the Mac cuts show ⌘⇧V as keycaps.
- **Transitions and sound.** Dissolves between takes, as Apple advises, and cuts only inside a take to remove
  waiting; nothing moves in a way the app does not. Under the music, each key the film presses plays Apple's own
  key press sound, which the Cutling keyboard itself plays (the approved Cutling films use
  `cutling-promo/public/sfx/ios-key_press_click.wav`); no whooshes or pops.
- **Brand.** Cutling green `#00be86`, the site's dark band `#0b3b2e` to `#0d5c45`, mint `#3ad6a6` on dark,
  tint `#e8f6f0`; SF Pro, as the app uses; the Icon Composer render of the icon on end cards; touch marks are a
  green ring.
- **Music.** "Complicated" by Arulo (Mixkit 281, Mixkit's free licence), which the owner called very good on
  2026-11-22. A fit to its 191 measured beats gives 105.9 BPM, a bar every 2.267 s; its first drop is at 22.51 s.
  Each animatic starts the track where that drop lands on the film's payoff (table below). "Hangtime" (Unminus),
  the other track he liked, is left out because Cutling's music comes from Mixkit (his ruling of 2026-11-18); the
  App Store runs no Content ID, so it is his call whether that ruling covers previews.

| Direction | Film | Track starts at | The drop lands on |
|---|---|---|---|
| A | 13 bars, 29.5 s | 11.18 s | the five replies stacking up (11.3 s) |
| B | 11 bars, 24.9 s | 13.44 s | the one tap that types the whole note (9.1 s) |
| C | 13 bars, 29.5 s | 0 s | the end card, Right at any hour (22.5 s); the quiet intro plays under the morning |
| D | 12 bars, 27.2 s | 11.47 s | the read-back of the finished message (11.0 s) |
| E | 11 bars, 24.9 s | 10.69 s | 3, Tap to type (11.8 s) |
| F | 13 bars, 29.5 s | 15.59 s | one key typing a whole refund policy (6.9 s) |

## How many previews, and which I would ship

Each direction is one preview per device (iPhone, iPad, Mac), recorded in en-US, id and ja as 1.6.x was, so a
pick is one set of three to six takes per language (listed under each direction). Apple allows three previews per
device and asks that each one show something new; if a second iPhone preview is made, it comes from a different
direction.

My pick: **A on all three devices**, and **E as the second iPhone preview** if there is time. A is the most
legible at search size (the sentence is the picture) and shows Cutling's job and 2.0's biggest addition in one
move; E shows what A takes for granted, how a keyboard app is switched on, and answers Apple's Full Access
warning where it appears (`cutling-voice-of-customer.md` ranks the fear of a keyboard logging what you type
fourth among buyers' complaints).
C is the most beautiful film of the six and the most work to record (three times of day).

---

## A. Fill in the blank

**Idea.** One saved reply goes to five people. Each time, Cutling asks only for the name: two taps a reply. Above
the real screen, the reply's own sentence is set large, and its blank is drawn the way the keyboard's fill-in bar
draws it (the waiting blank in green, underlined), so the picture and the app say the same thing.

**From references, and its own.** Mad Libs (a sentence with labelled blank lines) and Cutling's own fill-in bar
give the blank; Things' "Meet the all-new Things" gives the chorus (a fixed phrase with one changing word,
`pro-film-refs/app-things.md`); Apple's iPhone 17 and 18 Pro ads give type of two to five words. Its own: the
sentence is the keyboard's bar magnified, the rounds speed up from one a bar to one every half bar, and the film
ends by tapping back to the person's own keyboard, which is also its first frame.

**Look.** The site's dark green band over the top 880 px, white type, mint blank; below it the lower half of the
real screen (the message field and the keyboard) at its own resolution, with rounded top corners.

**Beats (iPhone, 13 bars, 29.5 s; poster at 3.1 s).**

| Time | On screen | Words |
|---|---|---|
| 0.0 | Messages to Maya, your own keyboard up; the sentence with its empty blank labelled NAME | One saved reply. A different name every time. |
| 0.55 to 1.6 | Hold the globe; the list of keyboards; slide to Cutling; Cutling's cards | |
| 2.27 | Tap Order update: the keyboard asks for the name, Maya, Jonas, Aiko, Sam, Lea and Paste as keys | Cutling asks for the name (from 2.6) |
| 3.4 | Tap Maya: the reply is typed; the big blank fills with Maya | |
| 4.5 to 9.6 | A fresh message each round: Jonas, Aiko, Sam, Lea, each faster | |
| 11.3 | The five replies stack up in the type zone, names in mint | Two taps for each reply |
| 18.1 | End card in the type zone, the keyboard below at rest | Write it once. + icon, Cutling |
| 26.1 | Tap the globe: back to your own keyboard; a fresh message | |
| 26.6 to 29.5 | The sentence with its empty blank again: frame 0 | One saved reply. A different name every time. |

**Words and what each says to a buyer.**

| Line | Says |
|---|---|
| One saved reply. A different name every time. | You write the reply once and still address each person. It is the 2.0 In-App Event's approved card line, so a buyer who sees both sees one promise. |
| Hi ____, your order ships Friday. | This is a real reply with a gap in it, the gap is for a name, and Cutling knows which day "Friday" is. |
| Cutling asks for the name | The keyboard does the asking; you only answer. |
| Two taps for each reply | The cost, counted: tap the reply, tap the name. |
| Write it once. | The promise, in the event's own name (The Write-It-Once Update). |

**iPad.** The same sentence over the iPad's lower screen: Messages with the conversation list, the iPad keyboard's
fill-in screen across the full width. **Mac.** The sentence in a dark green column at the left; on the right, Notes
with ⌘⇧V's picker turned into its short form: Name, with Maya, Jonas, Aiko, Sam and Lea as chips; then the reply
pasted with the name in.

**Seam.** A rest: the film's last 2.6 s are its first frame. `seam.png`: first line, end card, message reset and
blank fill all continuous.

**Takes (per language; the shared setup is under "Recording").**

| Take | Device | Screen and settings | What happens | Record / used |
|---|---|---|---|---|
| A1 | iPhone | Messages, new message to Maya, light, your own keyboard up, field focused | Hold the globe 1 s, slide to Cutling, let go; tap Order update; the fill-in screen shows; tap Maya; the reply is typed | 10 s / 4 s |
| A2 | iPhone | Messages, a new message to each of Jonas, Aiko, Sam and Lea, Cutling up | In each: tap Order update, tap the name. Four rounds in one take, one new message between rounds | 30 s / 6 s |
| A3 | iPhone | Messages to Lea after A2 | Tap the globe once: your own keyboard comes back | 4 s / 1 s |
| A4 | iPad | Messages, new message to Maya, light | Globe to Cutling, Order update, Maya; then Jonas in a new message | 16 s / 5 s |
| A5 | Mac | Notes (On My Mac), a new note, cursor in it | Press ⌘⇧V; the picker opens at the cursor; pick Order update; the form asks Name; click Maya; Paste; the reply lands. Again with Jonas | 20 s / 8 s |

---

## B. Like a note

**Idea.** A cutling is written the way a note is: a bold title, a bulleted list, a highlighted door code, on 2.0's
new Text page. Then one tap on the keyboard types all of it, and holding the key copies it with the formatting.

**From references, and its own.** Apple's iOS 26 film shows a single control carrying a shot when the camera goes
close enough (`pro-film-refs/apple-ios-26-liquid-glass.md`); Things shows real interface large and close, one
feature per shot; Notes' own Format card is what Cutling's copies. Its own: the white page is the frame, the
camera pushes onto the real bar and Format card and back, and the closest push (2.3 px a point) stays under the
recording's 3 px a point, so nothing is enlarged past the capture.

**Look.** Paper white `#fbfbfa`, black type set left, small; the screen floats with a soft shadow; no colour but
the app's own green.

**Beats (iPhone, 11 bars, 24.9 s; poster at 6.2 s).**

| Time | On screen | Words |
|---|---|---|
| 0.0 | The Text page of Studio welcome, plain text, keyboard up | Write it like a note |
| 0.6 to 1.3 | Camera in; select the title; tap B: it turns bold | |
| 2.6 to 4.7 | Select the three lines; Aa; the Format card; bulleted list; close | Bold the title, list the details |
| 5.2 to 5.9 | Select 4815; the highlighter | |
| 7.2 | Done; to Messages, Cutling up | Then one tap types all of it (from 8.2) |
| 9.1 | Tap Studio welcome: the whole note is typed, its list as lines; camera on the field | |
| 12.7 to 14.3 | Touch and hold the key; Copy; Copied with formatting | Hold it to copy the formatting too |
| 18.1 | End card over the finished page | Written like a note. Typed in one tap. + icon, Cutling |
| 24.3 to 24.9 | Dissolve into frame 0 | |

**Words and what each says to a buyer.**

| Line | Says |
|---|---|
| Write it like a note | Making a cutling feels like Apple Notes, which you already know. |
| Bold the title, list the details | Real formatting, done the way you would do it anywhere. |
| Then one tap types all of it | However long the cutling, the keyboard puts it all in at once. |
| Hold it to copy the formatting too | Where bold and lists matter, such as an email, they come along. |
| Written like a note. Typed in one tap. | Both halves at once: easy to write, quick to use. |

**iPad.** The page at full size with the Format card open as the iPad's popover. **Mac.** Notes after ⌘⇧V: the
same cutling pasted with its bold title, bullets and highlight. The Mac has no Text page, so its cut shows the
paste, which is where the formatting pays off; the line is "⌘⇧V pastes it with the formatting".

**Seam.** Dissolve into frame 0 over the last 0.6 s. `seam.png`: camera scale and position, end card, dissolve
all continuous.

**Takes.**

| Take | Device | Screen and settings | What happens | Record / used |
|---|---|---|---|---|
| B1 | iPhone | Cutling, the editor's Text page of a new cutling Studio welcome, its text already in as plain text, light | Select the first line, tap B; select the three item lines, tap Aa, bulleted list, close the card; select 4815, tap the highlighter; tap Done | 25 s / 7 s |
| B2 | iPhone | Messages to Maya, Cutling up | Tap Studio welcome: all of it is typed | 6 s / 3 s |
| B3 | iPhone | Same | Touch and hold Studio welcome; Copy; the key shows Copied | 6 s / 2 s |
| B4 | iPad | Text page of Studio welcome | The same three formats from the iPad's Format popover | 20 s / 6 s |
| B5 | Mac | Notes, a new note | ⌘⇧V, pick Studio welcome; it pastes with bold, bullets and highlight (direct paste on) | 10 s / 4 s |

Check during B3: if pasting into Messages keeps the bold, add the paste to the take.

---

## C. Around the clock

**Idea.** The same two saved replies, typed at 9:12 in the morning, 2:20 in the afternoon and 9:40 at night. Each
time the clock above turns into the greeting Cutling typed (Good morning, Good afternoon, Good evening), the
order number goes up by one (1041, 1042, 1043), and the ground moves from morning to night and loops back.

**From references, and its own.** macOS's Dynamic Desktop (a picture that follows the time of day) and the iPhone
Lock Screen's clock give the time as the picture; Raycast Focus lets a ticking clock carry time passing. Its own:
the time causes the words, as Greeting by Hour does; the app goes from light to dark appearance for the night
take; and the loop never stops, night turning into morning.

**Look.** A ground in the brand's greens that changes with the hour: pale tint in the morning, the brand green in
the afternoon, the dark band at night. The screen floats on one slow sine whose period is the film.

**Beats (iPhone, 13 bars, 29.5 s; poster at 4.6 s).**

| Time | On screen | Words |
|---|---|---|
| 0.0 | 9:12; Messages to Ana, your own keyboard | 9:12 AM · The same saved reply, three times a day |
| 0.45 to 1.5 | Globe to Cutling | |
| 2.0 | Tap Hello: "Good morning! Thanks for your message." The clock turns into the words | Good morning |
| 3.6 | Tap Order shipped: "Your order #1041 went out at 9:12 AM and arrives Friday." | #1041 · 9:12 AM · Friday |
| 8.75 | 2:20, the afternoon take, the ground turns brand green | 2:20 PM |
| 10.2, 11.6 | Hello, Order shipped | Good afternoon · #1042 · 2:20 PM · Friday |
| 17.8 | 9:40, the night take in dark appearance | 9:40 PM |
| 19.3, 20.7 | Hello, Order shipped | Good evening · #1043 · 9:40 PM · Friday |
| 22.5 | End card | Right at any hour. + icon, Cutling |
| 27.05 to 29.5 | Night turns into morning; the screen dissolves into the morning's first frame | 9:12 AM |

**Words and what each says to a buyer.**

| Line | Says |
|---|---|
| 9:12 AM, then Good morning | Cutling read the clock and wrote the greeting; you did not change it. |
| #1041 · 9:12 AM · Friday | It also filled in the next order number, the time and tomorrow's weekday. |
| The same saved reply, three times a day | You saved it once; what changed was done for you. |
| Right at any hour. | The promise: the reply is correct whenever you send it. |

**iPad.** The afternoon take floating under the clock and greeting. **Mac.** At night in dark appearance: the real
menu bar clock reads the hour, and the greeting is pasted into Notes with ⌘⇧V.

**Seam.** It never rests: the screen's float and the ground's colour run through the seam with continuous speed
and acceleration (`seam.png`).

**Takes.** Greeting by Hour reads the real clock, so each take is recorded in its part of the day, all three on
the same day so "tomorrow" is the same weekday. The counter is seeded to 1041 after the warm-up run.

| Take | Device | Screen and settings | What happens | Record / used |
|---|---|---|---|---|
| C1 | iPhone | Before noon, light; status bar set to the real minute; Messages to Ana, your own keyboard | Globe to Cutling; tap Hello; tap Order shipped | 10 s / 6 s |
| C2 | iPhone | 12:00 to 17:59, light; Messages to Ben, Cutling up | Tap Hello; tap Order shipped | 8 s / 4 s |
| C3 | iPhone | After 18:00, dark appearance; Messages to Chloe, Cutling up | Tap Hello; tap Order shipped | 8 s / 4 s |
| C4 | iPad | Afternoon, light; Messages to Ben | Hello, Order shipped | 8 s / 4 s |
| C5 | Mac | After 18:00, dark appearance; Notes | ⌘⇧V, Hello, paste; ⌘⇧V, Order shipped, paste; the menu bar clock in frame | 12 s / 6 s |

---

## D. Five taps

**Idea.** One uncut take of Messages at Larger Text. A long, warm reply to a restaurant guest is built from three
saved cutlings in five taps (Hello, Maya, Booking, 4, Sign-off). No words are laid over the take until the end;
then the camera reads down the finished message, and what Cutling filled in glows once (the evening greeting,
Maya, 4, Saturday, and the cursor waiting for a line of your own).

**From references, and its own.** Google's "Parisian Love" (2010) told a whole story only through what was typed
into the product; Craft's launch film trusts long takes of real use. Its own: the iPhone's own Larger Text setting
makes the interface the typography, so the take needs no captions to be read at search size, and the count in the
last line ("That was five taps.") is the one thing the viewer could not see alone.

**Look.** The real screen full-bleed at its own resolution, white; one caption before the first tap, one end card.

**Beats (iPhone, 12 bars, 27.2 s; poster at 9.6 s).**

| Time | On screen | Words |
|---|---|---|
| 0.0 | Messages to Maya, empty, your own keyboard | A long reply in five taps |
| 0.5 to 1.55 | Globe to Cutling | |
| 2.3, 3.4 | Tap Hello: it asks the name; tap Maya: "Good evening, Maya!" | |
| 5.2, 6.4 | Tap Booking: it asks Guests (2, 4, 6); tap 4: "Your table for 4 is booked for Saturday at 7:30. We're upstairs from the flower shop on the corner; ring 4 at the green door and we'll buzz you in." | |
| 8.6 | Tap Sign-off: "See you then! Sam", the cursor left above it for a line of your own | |
| 11.0 to 18.4 | The camera reads down the message; Good evening, Maya, 4, Saturday and the cursor glow in turn | |
| 20.4 | End card drops in over the top | That was five taps. + icon, Cutling |
| 26.6 to 27.2 | Dissolve into frame 0 | |

**Words and what each says to a buyer.**

| Line | Says |
|---|---|
| A long reply in five taps | Watch: something long and personal, almost no typing. |
| That was five taps. | You just saw it; count them yourself. |

The message itself is the rest of the copy: it reads like a person wrote it, which is the point of a saved reply
with blanks.

**iPad.** The same five taps in Messages on the iPad, the finished message across the wide field. **Mac.** Notes
with the message already built and ⌘⇧V's picker open for the fifth pick, Sign-off found by typing "sign".

**Seam.** Dissolve into frame 0 over the last 0.6 s. `seam.png`: camera scale and position, end card, dissolve
all continuous.

**Takes.**

| Take | Device | Screen and settings | What happens | Record / used |
|---|---|---|---|---|
| D1 | iPhone | After 18:00 (so Hello says Good evening); Settings > Accessibility > Display & Text Size > Larger Text, two steps up; Messages to Maya, your own keyboard | One uncut take: globe to Cutling; Hello, Maya; Booking, 4; Sign-off | 20 s / 11 s |
| D2 | iPad | Same settings; Messages to Maya | The same five taps | 20 s / 11 s |
| D3 | Mac | After 18:00; Notes | ⌘⇧V Hello, the form, Maya; ⌘⇧V Booking, the form, 4; ⌘⇧V, type "sign", Sign-off | 25 s / 10 s |

Check during D1: that the Cutling keyboard's cards stay legible at Larger Text, and that Messages' field holds the
whole message without hiding the first line.

---

## E. First minute

**Idea.** For people who have never used a keyboard app. The remade setup guide from its first page to the first
typed cutling: three steps numbered large in the brand green, and Apple's Full Access warning answered at the
moment it appears, with the fact the guide itself states: iOS shows the same warning for every keyboard.

**From references, and its own.** Apple's own setup and What's New sheets (which the remade guide follows); Halide
Mark II's grammar of a type card and the phone, one accent colour; Things' chapter names set alone on colour.
Its own: the numerals; the warning answered on the spot; the guide's own Settings video inside the film.

**Look.** The site's tint `#e8f6f0`; numerals 220 px in the brand green; the screen floats below.

**Beats (iPhone, 11 bars, 24.9 s; poster at 10.3 s).**

| Time | On screen | Words |
|---|---|---|
| 0.0 | Welcome to Cutling: Tap to Type, Images Too, Stays on Your iPhone | Set up in three steps |
| 1.9 | Continue: Add the Keyboard, the guide's Settings video playing | 1 Turn on the keyboard in Settings |
| 3.45 to 5.05 | Open Settings; Keyboards; Cutling on; Allow Full Access | |
| 5.2 to 7.4 | Apple's alert, held long enough to read; Allow | iOS shows this warning for every keyboard |
| 7.9 | ◀ Cutling: back to the guide's Try It page | |
| 9.3 to 10.8 | Tap the field; hold the globe; Cutling | 2 Hold the globe, pick Cutling |
| 11.7 | Tap Try Me: "Cutling typed this for me", the guide's tick | 3 Tap to type |
| 13.6 to 15.4 | Messages to Maya: Order update, Maya, typed | Then tap to type in any app |
| 19.3 | End card | Set up once. Use it anywhere. + icon, Cutling |
| 24.3 to 24.9 | Dissolve into frame 0 | |

**Words and what each says to a buyer.**

| Line | Says |
|---|---|
| Set up in three steps | This is quick, and here is all of it. |
| 1 Turn on the keyboard in Settings | Step one happens in Settings, and the app takes you there. |
| iOS shows this warning for every keyboard | The scary alert is Apple's standard text, not something Cutling chose to show. |
| 2 Hold the globe, pick Cutling | How you switch to it in any app. |
| 3 Tap to type | And how you use it. |
| Then tap to type in any app | It works wherever you type. |
| Set up once. Use it anywhere. | The setup is a one-time cost. |

Why not "Cutling never connects to the internet", which the guide's About Full Access sheet says: the keyboard
extension uploads a new cutling to the person's own iCloud when iCloud Sync is on
(`CutlingKeyboard/KeyboardSyncHelper.swift`), so the preview says only what is true for every buyer.

**iPad.** The Full Access alert answered, on the iPad. **Mac.** The Mac's own first run is a menu bar icon and one
shortcut: the welcome window's "Summon Cutling from anywhere" page with ⌘⇧V, and the line "One shortcut opens
Cutling in any app".

**Seam.** Dissolve into frame 0 over the last 0.6 s. `seam.png`: end card, first line, dissolve all continuous.

**Takes.**

| Take | Device | Screen and settings | What happens | Record / used |
|---|---|---|---|---|
| E1 | iPhone | Fresh install: Cutling's keyboard removed from the keyboard list and its entry deleted; launch Cutling | The guide's Welcome page; Continue; Add the Keyboard with its Settings video; Open Settings | 12 s / 4 s |
| E2 | iPhone | Settings, opened by the guide | Keyboards; Cutling on; Allow Full Access on; Apple's alert held 2 s; Allow; ◀ Cutling | 15 s / 5 s |
| E3 | iPhone | The guide's Try It page | Tap the field; hold the globe; Cutling; tap Try Me; the tick | 10 s / 4 s |
| E4 | iPhone | Messages to Maya | Order update; Maya (A1's round can serve) | 6 s / 2 s |
| E5 | iPad | The guide and Settings on the iPad | Allow Full Access; Apple's alert; Allow | 12 s / 4 s |
| E6 | Mac | First launch of Cutling in a fresh macOS user | The welcome window to "Summon Cutling from anywhere"; press ⌘⇧V; the picker | 12 s / 5 s |

---

## F. Room for everything

**Idea.** The numbers 2.0 raised, each proved on the screen after it. Black cards with one green word (5,000 texts
in one keyboard; 10,000 characters in each one; 500 images too), and between them the real app in dark mode: the
grid's own count under its title reading 5,000 Cutlings, one key typing a whole refund policy, a photo copied
from the keyboard into a message.

**From references, and its own.** Halide Mark II's black, white and one accent; Apple's keynote spec cards (one
number, a few words); CleanShot 5's caption card, product shot rhythm on the bar. Its own: every number is
followed by the screen that proves it, and the proof is the app's own count, not an overlay.

**Look.** Black `#050505`; numerals 240 to 300 px white; the accent word in mint; the app in dark appearance.

**Beats (iPhone, 13 bars, 29.5 s; poster at 0 s).**

| Time | On screen | Words |
|---|---|---|
| 0.0 | Card | 5,000 texts in one keyboard |
| 2.3 | The grid: Cutlings, 5,000 Cutlings; hold, then a long scroll that slows to a stop | |
| 6.8 | Messages to Leo, Cutling up: tap Refund policy; the whole policy is typed; the field scrolls back up through it | |
| 11.3 | Card | 10,000 characters in each one |
| 13.6 | The policy as its own Text page, scrolled top to bottom | |
| 18.1 | Card | 500 images too |
| 20.4 | The keyboard's image keys; tap Size chart; Copied; paste; the photo is in the message | |
| 24.9 | End card | Keep every reply you send. + icon, Cutling |
| 28.9 to 29.5 | Dissolve into frame 0 | |

**Words and what each says to a buyer.**

| Line | Says |
|---|---|
| 5,000 texts in one keyboard | You will not run out of room (1.6 held 100). |
| 10,000 characters in each one | A whole email or policy fits in one key (1.6 held 1,000 characters). |
| 500 images too | Photos and charts live in the keyboard as well (1.6 held 25). |
| Keep every reply you send. | The library can hold everything you write more than once. |

**iPad.** Fifteen texts across the iPad keyboard under "5,000". **Mac.** The picker reading Saved 5,000, and "ref"
finding the refund policy among them.

**Seam.** Dissolve into frame 0 over the last 0.6 s. `seam.png`: end card, first card, dissolve all continuous.

**Takes.** The grid's count shows every cutling, so F1 is seeded with exactly 5,000 text cutlings and no images,
and F4 with 500 images.

| Take | Device | Screen and settings | What happens | Record / used |
|---|---|---|---|---|
| F1 | iPhone | Dark; Cutling's grid seeded with 5,000 text cutlings | Hold 1 s on the title and count; one long fling that slows to a stop | 10 s / 4.5 s |
| F2 | iPhone | Dark; Messages to Leo, Cutling up; Refund policy is about 9,000 characters | Tap Refund policy; the text lands; scroll the field back to its top | 10 s / 4.5 s |
| F3 | iPhone | Dark; the Text page of Refund policy | Scroll from top to bottom | 6 s / 4.5 s |
| F4 | iPhone | Dark; seeded with 500 images (the first six named Size chart, Shop front, Gift wrap, Fabric swatch, Map, QR for Wi-Fi) | Tap Size chart; Copied; in the field, touch and hold, Paste; the photo appears | 10 s / 4.5 s |
| F5 | iPad | Dark; Messages, Cutling up, fifteen texts showing | Hold, then a short scroll | 6 s / 3 s |
| F6 | Mac | Dark; 5,000 text cutlings; Notes | ⌘⇧V; the picker shows Saved 5,000; type "ref"; pick Refund policy; it pastes | 12 s / 5 s |

---

## Recording (every take)

- Build from HEAD and install on the store simulators through the device queue: iPhone 18 Pro Max and iPad Air
  13-inch (M4), iOS 27.2. Record at 60 fps (RocketSim, or simctl and conform) with no touch indicator; the cut
  draws its own touch marks from the take's tap times. Warm up each flow, reset the data in the same process, then
  record (`product-video/references/capture.md`).
- Each language's takes run in that language: system language and region set, the system keyboard of that
  language and Cutling, and nothing else in the keyboard list (frame 04's rule), Full Access on so no banner shows.
- Status bar: 9:41, full battery and Wi-Fi; direction C sets it to the real minute of each take. On the iPad the
  date in the status bar is overridden or kept under the cut's top band.
- Contacts for Messages' To: field: Maya, Jonas, Aiko, Sam, Lea, Ana, Ben, Chloe, Leo (English; Indonesian and
  Japanese names in the seed below). Nothing is sent; every take ends with the text in the field.
- What's New marked seen, tips off, the walkthrough not running.
- Mac takes run in a separate macOS user (or a build with its own bundle id), as `capture.md` requires, with
  Cutling's direct paste turned on so the picker pastes. They paste into Notes (On My Mac), which a fresh user can
  use without an account; Mail needs an account on that user.
- No take shows a date with a year, a price, a real business or a real person's data.

## Seed (English)

Fill-ins are inserted from the editor's Variables, so they carry Cutling's marker and draw as pills.

| Cutling | Text |
|---|---|
| Order update (A, E) | `Hi {Name}, your order ships {day +1d}.` with Name's recent values Maya, Jonas, Aiko, Sam, Lea |
| Home address, Bank details, Booking, Wi-Fi, Thank you (A, E: the rest of the grid) | `14 Linden Road, Flat 3`; `Account 0441 2290 18`; `Your table for {Guests: 2 \| 4 \| 6} is booked`; `studio-guest · fern2291`; `Thank you so much for your order!` |
| Studio welcome (B) | **Welcome to the studio!** / Everything for your first visit: / Door code 4815 / Wi-Fi: studio-guest / Parking behind the bakery / See you soon! (typed plain; the take formats it) |
| Hello (C) | `{greeting}! Thanks for your message.` |
| Order shipped (C) | `Your order #{counter:Order} went out at {time} and arrives {day +1d}.` with the Order counter at 1041 |
| Hello (D) | `{greeting}, {Name}!` followed by a blank line |
| Booking (D) | `Your table for {Guests: 2 \| 4 \| 6} is booked for {day +2d} at 7:30. We're upstairs from the flower shop on the corner; ring 4 at the green door and we'll buzz you in.` |
| Sign-off (D) | `{cursor}` then a blank line, `See you then!`, `Sam` |
| Refund policy (F) | About 9,000 characters: refunds within 30 days, return labels, when the money arrives, what can't be refunded, damaged items, sale items |
| 5,000 texts (F1) and 500 images (F4) | Generated names such as Shipping times, Size guide, Care instructions, Opening hours; images as named in F4 |

## Indonesian and Japanese

The words on screen and the seed are written blind in each language from these meanings (the house's
`blind-translation` rule), never translated from the English lines. Names are the ones a buyer there would type:
five short given names in Indonesian (for example Rina, Budi, Sari, Dimas, Ayu); in Japanese business replies a
family name with 様 reads more natural than a given name (for example 田中様). Weekdays, times and counters are
filled by Cutling in each language on its own.

| Line | Meaning to write from |
|---|---|
| One saved reply. A different name every time. | The 2.0 event's card line, already written in 50 languages in `docs/aso/events/2.0-words.md` (key E2). |
| Cutling asks for the name | The keyboard itself asks you who the reply is for. |
| Two taps for each reply | Each reply costs you two taps: the reply, then the name. |
| Write it once. | The event's name, The Write-It-Once Update, as a short promise. |
| Write it like a note | You write a cutling the way you write in Apple's Notes. |
| Bold the title, list the details | You make the title bold and turn the details into a list. |
| Then one tap types all of it | After that, one tap on the keyboard types the whole thing. |
| Hold it to copy the formatting too | Holding the key copies it with its bold and lists. |
| Written like a note. Typed in one tap. | It is as easy to write as a note and as quick as one tap to use. |
| The same saved reply, three times a day | One reply you saved, typed at three different times of the same day. |
| Right at any hour. | Whenever you send it, it says the right thing for that time. |
| A long reply in five taps | Watch a long message get written with only five taps. |
| That was five taps. | Count them: what you just saw took five taps. |
| Set up in three steps | Getting started takes three steps. |
| Turn on the keyboard in Settings | Step one: switch Cutling's keyboard on in the Settings app. |
| iOS shows this warning for every keyboard | Apple's system shows this same alert for any keyboard app. |
| Hold the globe, pick Cutling | Press and hold the globe key, then choose Cutling. |
| Tap to type | Tap a cutling and it is typed. (The guide's own row title; use the guide's word in each language.) |
| Then tap to type in any app | From then on it works in every app where you type. |
| Set up once. Use it anywhere. | You set it up one time and use it everywhere. |
| 5,000 texts in one keyboard / 10,000 characters in each one / 500 images too | The keyboard holds 5,000 texts, each up to 10,000 characters, and 500 images. Number formats follow each language. |
| Keep every reply you send. | You can keep everything you send more than once. |

## For the owner

1. Pick one direction, or two for the iPhone's first and second preview.
2. The Mac cuts paste into Notes, which works in a fresh macOS user; Mail would need an account there. Notes, or
   Mail with an address on your own domain?
3. Music: "Complicated" under all six. "Hangtime" stays out under your Mixkit ruling unless you lift it for the
   App Store, which runs no Content ID.
4. Outside this card: on iOS 27 and iPadOS 27 a product page can carry its own image or video in search results in
   place of the screenshots and previews (WWDC26 session 205, "creative assets", approved through the new Asset
   Library). A picked direction's iPhone cut could be reused there later.
