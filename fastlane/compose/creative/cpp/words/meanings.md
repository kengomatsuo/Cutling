# Words for the panorama store sets, one language (ASG252 main page; custom pages below as they are added)

No language is the source the others are translated from. Each line is written from what the frame must make a buyer
understand, in the words good App Store listings in that market use. Register: the buyer, browsing the store; the
usual level of formality for listings in that language, the same in every line. The product word is the app's own
(`product_terms` in `docs/aso/screens-2.0/locale-facts.json`); numbers as `n5000` writes them.

## Main page, "Don't type it" (8 frames, flat mint, a giant condensed headline per frame)

The headline (`h`) is set enormous, one to three short words per line; `|` marks where the line breaks on iPhone
(the iPad sets it on one line). It must read in a second at thumbnail size. The line under it (`s`) is one short
sentence, at most about 32 characters on iPhone; `f` is a fine line in frame 8.

| Key | The frame | What the words must say |
|---|---|---|
| 1.h | The person's home address shown as the loose keys it takes to type it | A blunt command: stop typing this out by hand. Two to three words. |
| 1.s | under it | How many key presses that address costs, every single time. `{n}` is the number (it is counted from your language's own address). If your script is typed through an input method, say characters or letters instead of keys, whichever is true. |
| 2.h | Cutling's one key with that address on it, a finger ring pressing it | A command: press it (one tap). As short as the language allows. Frames 1 and 2 are seen together in search: "don't type it" then "tap it" must read as one thought. |
| 2.s | | The app turns all those keys into a single one. Use the app's name. |
| 3.h | The address typed into the field, with "Cutling typed it" | One word: finished, done. |
| 3.s | | It was typed for you, and there are no typos. |
| 4.h | The app's grid of saved texts | Keep everything (everything you would otherwise retype). |
| 4.s | | There is room for 5,000 of them. Use `n5000`. |
| 5.h | A saved text written like a note: bold title, bullet list, a highlight | Write it one time only. |
| 5.s | | It can have bold, lists and links, like a note in Notes. |
| 6.h | The keyboard asking for a name, the names used before offered as keys | Leave a gap (a blank) in the text. |
| 6.s | | You fill in the name at the moment you paste it. |
| 7.h | A saved note whose date is a placeholder, and the message it typed with today's date | The app knows (fills in) the date. |
| 7.s | | Today's date, typed on whatever day you paste. |
| 8.h | An iPad, an iPhone and a Mac showing the same saved texts | On every device. |
| 8.s | | iPhone, iPad and Mac, kept in sync. |
| 8.f | | You pay once. No account, no subscription. |

Demo data inside the drawn screens (written as the person in the picture would write them):

| Key | What it is |
|---|---|
| demo.ask | A customer's message to a small shop owner asking when their order will be sent. It must fit the shop owner's saved reply in your language's `cseed.reply` (same shop, same thing being sent). |
| demo.note | A short welcome note a small studio (pottery, yoga, a workshop) sends new visitors: a bold first line welcoming them, a line introducing what they need for the first visit, then three short bullet items: the door code 4815, the Wi-Fi network name studio-guest, and where to park (behind a local shop). |
| demo.note_hi | The exact text inside one bullet that is highlighted (the door code's digits). |
| digits | Only for languages whose addresses in the app use non-Latin digits: the ten digits 0 to 9 as written there. |

## Personal details, "Keys" (6 frames; keycaps on a green sweep, each printed with one saved detail)

Headline in two lines, the second line set in white: `first line|*second line*`. Heavy sans, about 14 characters a
line on iPhone. The fine line in frame 6 reuses `main.8.f`.

| Key | The frame | What the words must say |
|---|---|---|
| keys_pd.1 | One keycap printed with the person's home address | Your address is now a single key. |
| keys_pd.2 | A web form in Safari, the address field just filled by the keyboard | Any form: one tap per field. |
| keys_pd.3 | Keys for the bank account, phone number, booking reference | Each personal detail gets a key of its own. |
| keys_pd.4 | The app's grid of saved details | All your details, together in one place. |
| keys_pd.5 | The address typed into a text field by Cutling's keyboard | It types them into whatever app you use. |
| keys_pd.6 | An iPad, an iPhone and the Mac's ⌘⇧V keys | On iPhone, iPad and Mac. |

## Quick replies, "Night flight" (6 frames; devices tilted in the dark, glowing trails carry the reply)

Headline in up to three short lines, `|` between them; `*x*` is the phrase set in mint. The page is for people who
answer the same customer questions over and over (shops, support). Fine line in frame 6: `main.8.f`.

| Key | The frame | What the words must say |
|---|---|---|
| night_qr.1 | A customer's question arrives in Messages | Being asked the same question yet again? (the mint phrase: the same question) |
| night_qr.2 | The keyboard asking which name to fill in | Answer it with one tap. (mint: one tap) |
| night_qr.3 | The same reply sent to three customers, each with their own name | One reply, each customer's own name in it. (mint: each name) |
| night_qr.4 | A saved note whose date fills in on the day it is pasted | The date fills itself in. (mint: the date) |
| night_qr.5 | The app's grid of saved replies | All your replies in one place. (mint: one place) |
| night_qr.6 | An iPad, an iPhone and the Mac picker | On iPhone, iPad and your Mac. (mint: your Mac) |
