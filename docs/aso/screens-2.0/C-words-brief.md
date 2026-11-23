# Words for Cutling 2.0's App Store screenshots, one language (card ASG167)

No language is the source the others are translated from. You write your language's words from what each frame
must make a buyer understand. There is no source sentence to ask for.

## The product

Cutling keeps the text a person otherwise types again and again (their address, bank account number, email sign-off,
a reply they send customers) as "cutlings". On iPhone and iPad, Cutling is a keyboard: one tap on a cutling types it
into whatever app is open. On the Mac, pressing ⌘⇧V opens a picker over any app. One purchase covers iPhone, iPad and
Mac; there is no account and no subscription; cutlings sync through the person's own iCloud.

Version 2.0 (December 1) adds blanks: a reply is written once with a blank where the customer's name goes. Tapping it,
the keyboard asks for the name and offers the names used before as one-tap keys, then types the whole reply. Dates
fill themselves in (today, tomorrow, a week from now), right on the day it is pasted. Room grew from 100 cutlings to
5,000, and each can hold a whole email.

## The frames

Ink-black screenshots. Each frame has three lines of words above a picture:
- **kicker**: a short green line on top;
- **headline**: very large serif type in the buyer's own words, where each piece Cutling types for them is
  highlighted as a green block (a "chip");
- **subline**: one plain grey sentence under it.

Under the words sits a drawn Cutling keyboard or a real screenshot of the app in your language. The App Store shows
the first frames side by side in search results at thumbnail size, so the headline is what is read; it decides in
about two seconds whether a person opens the page.

Who reads: someone browsing the App Store in your language. Speak to them the way good App Store listings in your
market speak to buyers (pick the usual level of formality and keep it in every line). Say what the buyer gets in
their own life, never how the product is built.

## Markup

- `[x]` marks a green chip. Use it only where the brief says.
- `{name}`, `{date}`, `{plan}` are placeholders the build fills in from your own seed values (see below).
- `{cmd}` draws the three keys ⌘ ⇧ V. Keep it exactly as written where the brief uses it.
- Write numbers, dates and the product word exactly as `locale-facts.json` gives them for your language.

## Your facts

`docs/aso/screens-2.0/locale-facts.json`, your language's entry:
- `weekday_tue_nov24`: the weekday Cutling types for "tomorrow" on Monday November 23, 2026, exactly as the app
  writes it. It replaces `{date}` in your replies. Build the sentence around this exact word so it reads as correct
  grammar; do not inflect or change the word itself.
- `long_date_nov23`: the full date Cutling types for "today". It replaces `{date}` in the delivery note.
- `n5000`, `n100`: the two numbers as your language writes them.
- `product_terms`: the words the app already uses in your language (the product word for one cutling and many
  cutlings, and others). Use these, not your own synonyms.
- `keyboard_*`, `mac_*`: app button labels that appear in the drawn interface. You do not write these.

## The demo data (key `cseed`)

A small online shop owner uses Cutling. Write their data as it would be in your market.

| Key | What it is | Length |
|---|---|---|
| `names` | Three first names, the customer names this shop owner has used before. Common in your market, short, a mix of genders. The first is the customer in frame 1, the second in frame 2. | each 2 to 8 letters |
| `mac_name` | One more customer first name, used on the Mac. | 2 to 8 letters |
| `reply` | The reply the shop owner sends a customer whose order is about to be sent out, with `{name}` where the customer's name goes and `{date}` where the day it ships goes. One short, warm sentence, ending as a sentence ends in your language. | at most 40 characters once `{name}` and `{date}` are filled |
| `reply_name` | What the shop owner calls this saved reply in the app. | 1 or 2 words, at most 16 characters |
| `mac_reply` | The same kind of reply on the Mac, with a third blank `{plan}` for which of two plans the customer ordered, plus `{name}` and `{date}`. | at most 52 characters filled |
| `name_label` | The label of the name blank in the form (the word for a person's name). | at most 12 characters |
| `plan_label` | The label of the plan blank (the word your market uses for a plan or tier you buy). | at most 12 characters |
| `plan_choices` | Two plan names, a basic one and a better one. Loanwords are fine where your market uses them. | each at most 8 characters |
| `delivered` | A saved note the owner pastes to say when something was delivered, with `{date}` where the date goes. | at most 28 characters without the date |
| `delivered_name` | What the owner calls that saved note. | at most 16 characters |

## The words (key `C`)

iPhone and iPad show the same six frames; the Mac has five. "k" is the kicker, "h" the headline, "s" the subline.
Headlines marked *built* are made by the build from your seed (the chips go on the name, plan and date); you write
only their kicker and subline. Lengths are what fits; the type shrinks a little to fit, but shorter reads better.

**iphone 1** (first frame of all, next to the app's video in search).
k: this reply is written only one time. s: tapping the saved reply makes Cutling ask for the name.
h: *built* from `reply` with names[0] and the weekday.
k at most 24 characters; s at most 60.

**iphone 2** (beside frame 1; the two read as a pair).
k: the very same reply goes out again, to the next customer. s: names used before are waiting as one-tap keys.
h: *built* from `reply` with names[1].

**iphone 3**
k: Cutling writes dates in by itself. s: today, tomorrow or a week from now; the date is right on the day it is pasted.
h: *built* from `delivered` with the long date as a chip.

**iphone 4**
k and h together say: and the things about you that never change. h is a short list of three of them, each one a
chip: the person's own bank account number, their home address, and the way they sign off a message. Make each chip
the shortest natural name of the thing (possessive where your language does that). k may lead into h as one sentence.
s: each one is a single tap, in any app, from Cutling's keyboard.
k at most 34; h at most 50 including chips; s at most 60.

**iphone 5**
k: there is room for all of it. h: the number 5,000 as a chip (`n5000`) followed by the product's plural word for
cutlings. s: it used to be 100 (`n100`), and each one is long enough to hold a whole email.

**iphone 6**
k: names the three devices it works on: iPhone, iPad and Mac. h: you pay a single time; the chip goes on the word that
means "once" (or your language's equivalent of a one-time payment). s: one purchase covers all three; there is no
account to create and no subscription to keep paying.
h at most 18 characters.

**mac 1**
k: write it once and send it to everyone. s: you pick the reply with `{cmd}` and a short form asks for the blanks
before it pastes. h: *built* from `mac_reply` with `mac_name`, the better plan, and the weekday.

**mac 2**
k: wherever you are typing. h: exactly `{cmd}`. s: your cutlings and the last things you copied open over any app.

**mac 3**
k leads into the headline, a row of password dots (fixed; you do not write it): the Mac's clipboard history leaves
something out. Write k so a row of password dots under it reads as what is left out (for example as the object of
the sentence). s: anything a password manager marks as hidden never gets into the history.

**mac 4**
k and h together: change something on your Mac and it is changed on your iPhone. The chip goes on "iPhone" in h.
s: it syncs through your own iCloud, with no account to create.

**mac 5**: the same meanings as iphone 6, written again (you may reuse the same words).

## What you write

1. `fastlane/compose/creative/v2/words/<locale>.json`, exactly this shape (keys as shown, values in your language):

```json
{
 "cseed": {"names": ["", "", ""], "mac_name": "", "reply": "", "reply_name": "", "mac_reply": "",
           "name_label": "", "plan_label": "", "plan_choices": ["", ""], "delivered": "", "delivered_name": ""},
 "C": {
  "iphone": {"1": {"k": "", "s": ""}, "2": {"k": "", "s": ""}, "3": {"k": "", "s": ""},
             "4": {"k": "", "h": "", "s": ""}, "5": {"k": "", "h": "", "s": ""}, "6": {"k": "", "h": "", "s": ""}},
  "mac": {"1": {"k": "", "s": ""}, "2": {"k": "", "h": "{cmd}", "s": ""}, "3": {"k": "", "s": ""},
          "4": {"k": "", "h": "", "s": ""}, "5": {"k": "", "h": "", "s": ""}}
 }
}
```

2. `docs/aso/screens-2.0/review/<locale>.md`: a table with one row per string: key, your string, a literal
   back-translation into English, and one line on the choice you made (register, grammar around the weekday, a word
   you picked over another).

Write it as a person from your market would, with your language's own punctuation, quotation marks and spacing rules
(no long dashes where your language does not use them).
