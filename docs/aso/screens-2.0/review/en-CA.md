# English (Canada) (en-CA): Cutling 2.0 store frames, direction C

Words in `fastlane/compose/creative/v2/words/en-CA.json`, written from `docs/aso/screens-2.0/C-words-brief.md` and this locale’s entry in `locale-facts.json`. Register: “you”, contractions, sentence case, no long dashes. Every line was rendered on the iPhone, iPad and Mac frames on 2026-11-23: nothing clipped, no chip broken across a hyphen, no line ending on a single word.

| Key | String | Back-translation | Choice |
|---|---|---|---|
| `cseed.names` | Erin, Kyle, Sarah | Three customers’ first names (female, male, female) | Statistics Canada’s 1991 top ten has Sarah 3rd and Kyle 8th; BC’s register shows 128 Erins born in 1990; Erin and Kyle are the same width, so frames 1 and 2 wrap identically (Ashley made frame 1 wrap differently from frame 2). |
| `cseed.mac_name` | Ryan | A customer’s first name (male) | Statistics Canada 1991: Ryan 5th. Mathieu and Priya were dropped: BC’s register shows 5 and 8 births in 1990. |
| `cseed.reply` | Hi {name}, your order ships on {date}. | Hi Erin, your order is sent out on Tuesday. | “Ships” is the Canadian shop word, as in the rest of North America; “on” kept before the weekday; 37 to 38 characters filled. |
| `cseed.reply_name` | Shipping date | Shipping date | North American shop term; pairs with “Delivery date”. |
| `cseed.mac_reply` | Hi {name}, your {plan} box ships on {date}. | Hi Ryan, your Premium box is sent out on Tuesday. | Same verb as the iPhone reply; 41 to 43 characters filled. |
| `cseed.name_label` | Name | Name | The app’s own label for the blank. |
| `cseed.plan_label` | Plan | Plan | The word the app’s Variables list already uses (“Plan ▾”). |
| `cseed.plan_choices` | Basic, Premium | Basic tier, better tier | Two familiar tier names, 5 and 7 letters. |
| `cseed.delivered` | Delivered on {date}. | Delivered on November 23, 2026. | Month, day, year comes from the facts; full stop as in a pasted message. |
| `cseed.delivered_name` | Delivery date | Delivery date | Pairs with “Shipping date”. |
| `C.iphone.1.k` | Write it once. | Write it once. | Imperative, “you”, contractions allowed: the plain register of this market’s App Store copy, kept in every line. |
| `C.iphone.1.h (built)` | Hi [Erin], your order ships on [Tuesday]. | Hi Erin, your order is sent out on Tuesday. | Built from the seed above, with the chips on what Cutling types; shown so the headline can be read. |
| `C.iphone.1.s` | Tap the reply and Cutling asks who it’s for. | Tap the saved reply and Cutling asks for the customer’s name. | “Who it’s for” is how a person says it; one line on iPhone and iPad (measured). |
| `C.iphone.2.k` | Same reply, next customer. | The same reply, to the next customer. | Verbless, so it pairs with frame 1’s kicker: written once, sent again. |
| `C.iphone.2.h (built)` | Hi [Kyle], your order ships on [Tuesday]. | Hi Kyle, your order is sent out on Tuesday. | Built from the seed above, with the chips on what Cutling types; shown so the headline can be read. |
| `C.iphone.2.s` | Names you’ve used before are ready to tap. | The names you used before are waiting as keys you tap once. | “Ready to tap” carries both “waiting” and “one tap”. |
| `C.iphone.3.k` | Dates fill themselves in. | Dates are filled in automatically. | “Fill in” is the app’s own verb (“Filled in each time you use it”). |
| `C.iphone.3.h (built)` | Delivered on [November 23, 2026]. | Delivered on November 23, 2026. | Built from the seed above, with the chips on what Cutling types; shown so the headline can be read. |
| `C.iphone.3.s` | Today, tomorrow or a week from now, counted from the day you paste it. | Today, tomorrow or a week from now, worked out from the day you paste it. | “A week from now” is the North American form; “paste it” keeps the iPad’s last line from being one word (measured). |
| `C.iphone.4.k` | And the stuff that never changes: | And the things that never change: | “Stuff” is the casual Canadian word; “bits” in this sense reads British. |
| `C.iphone.4.h` | your [banking info], [address] and [signature]. | your bank transit, institution and account numbers, your home address and your email signature. | Canada.ca calls these numbers “banking information” and the app’s own en-CA seed is “Transit: 12345-001 / Account: 1234567”; “bank details” reads British; “signature” matches the Signature key in the frame’s capture and keeps the chip whole; no comma before “and” (Canadian Press style). |
| `C.iphone.4.s` | Each one’s a single tap on the Cutling keyboard, in any app. | Each of them is one tap on the Cutling keyboard, in any app. | 60 characters, the limit; on iPhone it breaks at the comma (measured); “the Cutling keyboard” is the app’s name for it. |
| `C.iphone.5.k` | Room for all of it. | Room for everything. | Plain North American; “the lot” reads British. |
| `C.iphone.5.h` | [5,000] cutlings. | 5,000 cutlings. | Number as the facts write it; “cutlings” lower case because the app writes it so in running text (“Search cutlings”, “5,000 text cutlings” in the release notes); the facts file’s capital is the title-case label. |
| `C.iphone.5.s` | Up from 100. Each one can hold a whole email. | It used to be 100. Each one is long enough for a whole email. | One line on iPhone and iPad (measured). |
| `C.iphone.6.k` | iPhone, iPad and Mac. | iPhone, iPad and Mac. | No comma before “and”, as this market writes a list. |
| `C.iphone.6.h` | [One-time] payment. | One-time payment. | “One-time” is the North American word, where “one-off” reads British; 17 of 18 characters. |
| `C.iphone.6.s` | That covers all three, with no account and nothing to renew. | That payment covers all three devices; you create no account and have no subscription to renew. | “Nothing to renew” says no subscription without the stock “No account, no subscription” pair the prose scan flags; no one-word last line on iPhone, iPad or Mac (measured). |
| `C.mac.1.k` | Write it once, send it to everyone. | Write it once, send it to everyone. | Two imperatives joined by a comma, the usual slogan form. |
| `C.mac.1.h (built)` | Hi [Ryan], your [Premium] box ships on [Tuesday]. | Hi Ryan, your Premium box is sent out on Tuesday. | Built from the seed above, with the chips on what Cutling types; shown so the headline can be read. |
| `C.mac.1.s` | Pick the reply with {cmd} and a quick form asks for the blanks before it’s pasted. | Choose the reply with ⌘⇧V and a short form asks for the blanks before the reply is pasted. | “Blanks” is the app’s word (“Blanks and dates”); “quick form” because a “short form” is also an abbreviation in Canada; “it’s pasted” makes the reply, not the form, the thing pasted. |
| `C.mac.2.k` | Wherever you’re typing. | Wherever you are typing. | Contraction as in every other line. |
| `C.mac.2.h` | {cmd} | ⌘⇧V | Fixed by the brief. |
| `C.mac.2.s` | Your cutlings and the last few things you copied pop up over any app. | Your cutlings and your most recent copies open on top of any app. | “Pop up” is how people describe a panel appearing over what they are doing. |
| `C.mac.3.k` | Your clipboard history leaves out | Your clipboard history does not keep | Ends on the verb, so the row of password dots under it reads as its object. |
| `C.mac.3.h (built)` | [••••••••••] | a row of password dots | A fixed row of password dots drawn by the build. |
| `C.mac.3.s` | Anything your password manager marks as hidden never ends up in it. | Whatever your password manager flags as hidden is never saved in the history. | “Ends up in” is plain in all three Englishes (and the en-GB store description’s own phrase). |
| `C.mac.4.k` | Change it on your Mac | Change it on your Mac | No comma: the kicker runs straight into the headline as one sentence. |
| `C.mac.4.h` | and it’s changed on your [iPhone] too. | and it is changed on your iPhone as well. | Mirrors the kicker’s verb; chip on iPhone as the brief asks. |
| `C.mac.4.s` | It syncs through your own iCloud, so there’s no account to set up. | It synchronises through your own iCloud, so you do not create an account. | “So” gives the reason there is no account. |
| `C.mac.5.k` | iPhone, iPad and Mac. | iPhone, iPad and Mac. | Same words as iPhone 6, as the brief allows. |
| `C.mac.5.h` | [One-time] payment. | One-time payment. | Same as iPhone 6. |
| `C.mac.5.s` | That covers all three, with no account and nothing to renew. | That payment covers all three devices; you create no account and have no subscription to renew. | Same as iPhone 6. |
