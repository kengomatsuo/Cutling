# Kannada (kn-IN): words for the 2.0 store frames, direction C

Words: `fastlane/compose/creative/v2/words/kn-IN.json`. Written from `C-words-brief.md` and the `kn-IN` entry of
`locale-facts.json`, with no source sentence.

- **Register:** polite ನೀವು in every line (ನಿಮ್ಮ, and imperatives in -ಇ and -ಇರಿ such as ಕಳಿಸಿ, ಬರೆಯಿರಿ), the level
  Cutling's Kannada app strings and its Kannada store listing already use ("ಕಟ್ಲಿಂಗ್ ತೆರೆಯಿರಿ", "ನಿಮ್ಮ ವಿಳಾಸ"). The shop
  owner's replies address the customer as "{name} ಅವರೇ", the respectful vocative Kannada puts after a name, which fits
  a man or a woman alike.
- **Product words and loans:** ಕಟ್ಲಿಂಗ್ and ಕಟ್ಲಿಂಗ್‌ಗಳು come byte for byte from `product_terms` and name both the app
  and the item, as the app's own Kannada strings do. Apple's names stay in Latin script, and a Kannada suffix after a
  Latin word is spaced ("Mac ನಲ್ಲಿ", "iPhone ನಲ್ಲೂ") as in the app. An English loan ends in a halant with a ZWNJ before
  its suffix (ಆ್ಯಪ್‌ನಲ್ಲೂ, ಕೀಬೋರ್ಡ್‌ನಲ್ಲಿ), code point for code point as the app and the listing spell them.
- **Grammar the facts force:** ಮಂಗಳವಾರ works bare as a time adverb ("on Tuesday"), so the replies use the app's word
  with no case ending. The long date takes ರಂದು ("on") after a space, "23 ನವೆಂಬರ್ 2026 ರಂದು": Kannada news writes both
  "ನವೆಂಬರ್ 13 ರಂದು" and "13ರಂದು" (kannada.oneindia.com, one article has both), and the spaced form lets the green date
  chip end cleanly. After a numeral the noun stays plural: "5,000 ಕಟ್ಲಿಂಗ್‌ಗಳು".
- **Punctuation:** Kannada uses the Latin full stop and comma, no danda. Kickers and the slogan headlines (iPhone 4 to
  6, Mac 4 and 5) take no full stop; the replies, the delivery note and every subline end with one. No dashes.
- **No subjoined consonant (ottakshara) inside a green chip where an equally natural word exists.** In the headline
  font (Kannada Sangam MN) a full subjoined ಮ or ಯ hangs below the chip's green box onto the dark ground, so ರಶ್ಮಿ,
  ಒಮ್ಮೆ and ಖಾತೆ ಸಂಖ್ಯೆ looked cut off in the first render. ಮೇಘನಾ, ಒಂದೇ ಸಲ and ಖಾತೆ ನಂಬರ್ replaced them. ಪ್ರೀಮಿಯಂ keeps
  its ರ-ottu, a shallow hook that stays inside the green.
- **Lengths** are counted in Unicode code points, stricter than a Kannada reader's count of letters. Every limit the
  brief states holds: reply 39 of 40 filled, Mac reply 49 of 52, delivery note 23 of 28, iPhone 1 kicker 16 of 24,
  iPhone 1 subline 56 of 60, iPhone 4 kicker 25 of 34, headline 28 of 50 and subline 60 of 60, iPhone 6 headline
  13 of 18.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | ಮೇಘನಾ | Meghana | A common Kannada woman's name with no subjoined letter, so it sits whole inside frame 1's chip. |
| cseed.names[1] | ಚೇತನ್ | Chethan | A common man's name in Karnataka, no subjoined letter either. |
| cseed.names[2] | ಕಾವ್ಯಾ | Kavya | A common woman's name. It is only ever a key on the keyboard, never a chip, so its ವ್ಯ is safe. |
| cseed.mac_name | ಸಂತೋಷ್ | Santhosh | A common man's name in Karnataka. |
| cseed.reply | {name} ಅವರೇ, ಆರ್ಡರ್ {date} ಕಳಿಸುತ್ತೇವೆ. | {name}-avare, (we) will send (the) order {date}. | ಅವರೇ is the polite address after a name; bare ಮಂಗಳವಾರ means "on Tuesday"; ಕಳಿಸು is the everyday form of ಕಳುಹಿಸು. 39 filled. |
| cseed.reply_name | ಆರ್ಡರ್ ಅಪ್‌ಡೇಟ್ | Order update | The two loans a Kannada shop owner uses for this message. |
| cseed.mac_reply | {name} ಅವರೇ, {plan} ಆರ್ಡರ್ {date} ಕಳಿಸುತ್ತೇವೆ. | {name}-avare, (we) will send (the) {plan} order {date}. | The iPhone reply with the plan before ಆರ್ಡರ್, read as "your Premium order". 49 filled. |
| cseed.name_label | ಹೆಸರು | Name | The app's own string for Name. |
| cseed.plan_label | ಪ್ಲಾನ್ | Plan | Kannada tech news writes ಪ್ಲಾನ್ for a plan you buy (Kannada Gizbot, "ಪ್ರಿಪೇಡ್ ಪ್ಲಾನ್"); ಯೋಜನೆ, the app's word for its Plan preset, reads as a scheme or project. |
| cseed.plan_choices | ಬೇಸಿಕ್, ಪ್ರೀಮಿಯಂ | Basic, Premium | The loans Indian buyers see on tiers; Cutling's Kannada 2.0 release notes already name these two. |
| cseed.delivered | ಪಾರ್ಸೆಲ್ {date} ರಂದು ತಲುಪಿದೆ. | (The) parcel reached on {date}. | ರಂದು is "on" for a date, spaced after it; ತಲುಪಿದೆ (has reached) over the official ತಲುಪಿಸಲಾಗಿದೆ (has been delivered). 23 without the date. |
| cseed.delivered_name | ಡೆಲಿವರಿ ದಿನಾಂಕ | Delivery date | ಡೆಲಿವರಿ is the loan Kannada shoppers use; ದಿನಾಂಕ is the app's word for date. |
| C.iphone.1.k | ಒಂದೇ ಸಲ ಬರೆದದ್ದು | Written just one time | ಒಂದೇ ಸಲ (just once) is everyday speech; ಬರೆದದ್ದು (what was written) names the reply under it. |
| C.iphone.1.s | ಈ ಉತ್ತರ ಟ್ಯಾಪ್ ಮಾಡಿದಾಗ ಕಟ್ಲಿಂಗ್ ಗ್ರಾಹಕರ ಹೆಸರು ಕೇಳುತ್ತದೆ. | When (you) tap this reply, Cutling asks the customer's name. | ಗ್ರಾಹಕರ (the customer's) keeps "ಕಟ್ಲಿಂಗ್ ಹೆಸರು" from reading as "the cutling's name". |
| C.iphone.2.k | ಮುಂದಿನ ಗ್ರಾಹಕರಿಗೂ ಅದೇ | For the next customer too, the same | The -ಊ (too) says "again" with no second verb, and pairs with frame 1's kicker. |
| C.iphone.2.s | ಹಿಂದೆ ಬಳಸಿದ ಹೆಸರುಗಳು ಕೀಗಳಾಗಿ ಕಾಣುತ್ತವೆ, ಒಂದನ್ನು ಟ್ಯಾಪ್ ಮಾಡಿ. | Names used before show up as keys; tap one. | Names what the buyer does with the keys, the one tap included. |
| C.iphone.3.k | ಕಟ್ಲಿಂಗ್ ತಾನೇ ದಿನಾಂಕ ಹಾಕುತ್ತದೆ | Cutling puts in the date by itself | ದಿನಾಂಕ ಹಾಕು is how Kannada says writing the date on a form. |
| C.iphone.3.s | ಇಂದಿನ, ನಾಳೆಯ ಅಥವಾ ವಾರದ ನಂತರದ ದಿನಾಂಕ ಯಾವ ದಿನ ಅಂಟಿಸಿದರೂ ಸರಿಯಾಗಿರುತ್ತದೆ. | Today's, tomorrow's or a week-later date is right whichever day (you) paste (it). | The concessive -ಅರೂ (whichever day) carries "right on the day it is pasted"; ಅಂಟಿಸು is the app's Paste. |
| C.iphone.4.k | ಎಂದೂ ಬದಲಾಗದ ನಿಮ್ಮ ವಿವರಗಳೂ | Your details that never change, too | The -ಊ on ವಿವರಗಳೂ is the "and"; one ನಿಮ್ಮ (your) before the list covers all three chips, as Kannada sets a possessive once. |
| C.iphone.4.h | [ಖಾತೆ ನಂಬರ್], [ವಿಳಾಸ], [ಇಮೇಲ್ ಸಹಿ] | [account number], [address], [email signature] | ಖಾತೆ ನಂಬರ್ is the everyday form (ಸಂಖ್ಯೆ's subjoined ಯ hung out of the chip); ಸಹಿ alone is a pen signature, so ಇಮೇಲ್ ಸಹಿ. |
| C.iphone.4.s | ಯಾವ ಆ್ಯಪ್‌ನಲ್ಲೂ ಕಟ್ಲಿಂಗ್ ಕೀಬೋರ್ಡ್‌ನಲ್ಲಿ ಒಂದೊಂದೂ ಒಂದೇ ಟ್ಯಾಪ್. | In any app, on the Cutling keyboard, each one (is) a single tap. | A Kannada nominal sentence needs no "is"; ಒಂದೊಂದೂ ಒಂದೇ (each one, a single) is a deliberate echo. |
| C.iphone.5.k | ಎಲ್ಲದಕ್ಕೂ ಜಾಗವಿದೆ | There is room for everything | The plain spoken phrase. |
| C.iphone.5.h | [5,000] ಕಟ್ಲಿಂಗ್‌ಗಳು | [5,000] cutlings | `n5000` and the plural product word as given; plural after a numeral. |
| C.iphone.5.s | ಮೊದಲು 100 ಮಾತ್ರ ಇತ್ತು, ಈಗ ಇಡೀ ಇಮೇಲ್ ಕೂಡ ಒಂದರಲ್ಲೇ ಹಿಡಿಸುತ್ತದೆ. | Before, it was only 100; now even a whole email fits in just one. | ಹಿಡಿಸು is "to fit inside", the verb for what a box holds. |
| C.iphone.6.k | iPhone, iPad ಮತ್ತು Mac | iPhone, iPad and Mac | Apple's names in Latin, as in the app. |
| C.iphone.6.h | ಪಾವತಿ [ಒಂದೇ ಸಲ] | Payment: [just once] | A nominal sentence with the chip last, echoing frame 1's ಒಂದೇ ಸಲ; ಒಮ್ಮೆ's subjoined ಮ hung out of the chip. |
| C.iphone.6.s | ಒಂದು ಖರೀದಿ ಮೂರಕ್ಕೂ ಸಾಕು, ಖಾತೆ ಬೇಕಿಲ್ಲ, ಚಂದಾದಾರಿಕೆ ಇಲ್ಲ. | One purchase is enough for all three; no account needed; no subscription. | ಚಂದಾದಾರಿಕೆ is Kannada tech news' word for a subscription (Kannada Gizbot, "12 ತಿಂಗಳ ಉಚಿತ ಚಂದಾದಾರಿಕೆ"); ಖಾತೆ is the app's word for account. |
| C.mac.1.k | ಒಮ್ಮೆ ಬರೆಯಿರಿ, ಎಲ್ಲರಿಗೂ ಕಳಿಸಿ | Write once, send to everyone | Two polite imperatives; -ಇರಿ and -ಇ are the same ನೀವು level. |
| C.mac.1.s | {cmd} ಒತ್ತಿ ಉತ್ತರ ಆರಿಸಿ, ಅಂಟಿಸುವ ಮೊದಲು ಚಿಕ್ಕ ಫಾರ್ಮ್‌ನಲ್ಲಿ ಖಾಲಿಗಳನ್ನು ತುಂಬಿ. | Press ⌘⇧V and pick the reply; before it pastes, fill the blanks in a small form. | The buyer fills the blanks, since a form "asking for blanks" reads oddly in Kannada; ಖಾಲಿಗಳು is the app's word for blanks. |
| C.mac.2.k | ಎಲ್ಲಿ ಟೈಪ್ ಮಾಡುತ್ತಿದ್ದರೂ | Wherever (you) are typing | The concessive leads into the keys below. |
| C.mac.2.h | {cmd} | ⌘⇧V | Fixed by the brief. |
| C.mac.2.s | ನಿಮ್ಮ ಕಟ್ಲಿಂಗ್‌ಗಳು ಮತ್ತು ಇತ್ತೀಚೆಗೆ ನಕಲಿಸಿದವು ಯಾವುದೇ ಆ್ಯಪ್‌ನ ಮೇಲೆ ತೆರೆಯುತ್ತವೆ. | Your cutlings and the ones (you) copied recently open over any app. | ನಕಲಿಸು is the app's Copy; ಮತ್ತು joins two nouns here, its native use. |
| C.mac.3.k | ಕ್ಲಿಪ್‌ಬೋರ್ಡ್ ಇತಿಹಾಸ ಇದನ್ನು ಉಳಿಸುವುದಿಲ್ಲ | The clipboard history does not save this | Kannada puts the object before the verb, so ಇದನ್ನು (this) points at the dots below; ಕ್ಲಿಪ್‌ಬೋರ್ಡ್ ಇತಿಹಾಸ is the app's Clipboard History. |
| C.mac.3.s | ಪಾಸ್‌ವರ್ಡ್ ಮ್ಯಾನೇಜರ್ ಗೌಪ್ಯ ಎಂದು ಗುರುತಿಸಿದ್ದು ಇತಿಹಾಸಕ್ಕೆ ಸೇರುವುದೇ ಇಲ್ಲ. | What a password manager marked as confidential never gets into the history at all. | The same words as the Kannada description's line on this (ಪಾಸ್‌ವರ್ಡ್ ಮ್ಯಾನೇಜರ್, ಗೌಪ್ಯ). |
| C.mac.4.k | ನಿಮ್ಮ Mac ನಲ್ಲಿ ಏನಾದರೂ ಬದಲಾಯಿಸಿದರೆ | If (you) change anything on your Mac | A conditional that the headline completes. |
| C.mac.4.h | [iPhone] ನಲ್ಲೂ ಬದಲಾಗುತ್ತದೆ | (it) changes on [iPhone] too | Transitive ಬದಲಾಯಿಸು in the kicker, intransitive ಬದಲಾಗು here; the suffix spaced after the chip as the app writes "Mac ನಲ್ಲಿ". |
| C.mac.4.s | ನಿಮ್ಮದೇ iCloud ಮೂಲಕ ಸಿಂಕ್ ಆಗುತ್ತದೆ, ಬೇರೆ ಖಾತೆ ರಚಿಸಬೇಕಿಲ್ಲ. | (It) syncs through your own iCloud; no other account to create. | ಬೇರೆ (other) says the buyer's own iCloud is the only account; ಸಿಂಕ್ ಆಗು as in the app's "ಸಿಂಕ್ ಆಗುತ್ತಿದೆ". |
| C.mac.5.k | iPhone, iPad ಮತ್ತು Mac | iPhone, iPad and Mac | iPhone 6 reused, as the brief allows. |
| C.mac.5.h | ಪಾವತಿ [ಒಂದೇ ಸಲ] | Payment: [just once] | iPhone 6 reused. |
| C.mac.5.s | ಒಂದು ಖರೀದಿ ಮೂರಕ್ಕೂ ಸಾಕು, ಖಾತೆ ಬೇಕಿಲ್ಲ, ಚಂದಾದಾರಿಕೆ ಇಲ್ಲ. | One purchase is enough for all three; no account needed; no subscription. | iPhone 6 reused. |
