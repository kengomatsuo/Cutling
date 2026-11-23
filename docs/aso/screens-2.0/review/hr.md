# hr (Croatian): words for the 2.0 store frames (ASG167)

Written from `C-words-brief.md` and the `hr` entry of `locale-facts.json` (weekday `utorak`, long date
`23. studenoga 2026.`, `5.000`, `100`); the file is `fastlane/compose/creative/v2/words/hr.json`. Every line speaks to the
buyer with informal "ti", as Cutling's own hr description and 2.0 What's New already do and as Croatian consumer listings
such as KEKS Pay do. "Vi" appears nowhere. Product words come from the app's hr strings and its hr listing
(cutling/cutlinzi/cutlinga, Cutling tipkovnica, praznine, Danas/Sutra/Za tjedan dana, preko tvog iClouda, upravitelj
zaporki). No dashes and no quotation marks are used. Rows marked *built* are put together by the build from the seed and
are shown here so the whole sentence can be checked.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | Ana | Ana | Very common woman's name whose vocative is the same as the nominative, so "Ana," opens the reply correctly. |
| cseed.names[1] | Luka | Luka | Common man's name; names ending in -a, -o and -e keep the nominative when addressed ("Bok, Luka!"). |
| cseed.names[2] | Hrvoje | Hrvoje | Clearly Croatian man's name, ending in -e, so its vocative is unchanged. Chosen over Maja, which some grammars address as "Majo". |
| cseed.mac_name | Lana | Lana | Woman's name that stays "Lana" when addressed, which keeps the four names at two women and two men. |
| cseed.reply | {name}, narudžbu ti šaljemo u {date}. | {name}, the order to-you we-send on {date}. | The name opens the sentence as a vocative with its comma ("Bok, Ana, ..." would need two commas). "u utorak" is "on Tuesday", and its accusative is the bare form, so the weekday is not inflected. The clitic "ti" sits second, and nothing agrees with the customer's gender, so it reads right for Ana and Luka alike. |
| cseed.reply_name | Slanje narudžbe | Sending of-the-order | Two words, 15 characters: what a shop owner would call the saved reply. It is also the Mac form's title. |
| cseed.mac_reply | {name}, paket {plan} ti šaljemo u {date}. | {name}, the package {plan} to-you we-send on {date}. | Same shape as the phone reply. "paket Premium" follows the hr What's New ("paket Osnovni ili Premium"). |
| cseed.name_label | Ime | Name (first name) | A person's name. The app's "Naziv" is the title of a thing, so it is not used here. |
| cseed.plan_label | Paket | Package | The word Croatian shops and operators use for a tier you buy, and the word the hr What's New already uses. |
| cseed.plan_choices[0] | Osnovni | Basic | Native adjective, 7 characters. |
| cseed.plan_choices[1] | Premium | Premium | Used as-is in Croatia. |
| cseed.delivered | Paket je dostavljen {date} | The parcel is delivered {date} | No full stop after {date}: the long date ends in its own period ("23. studenoga 2026."), which also ends the sentence. |
| cseed.delivered_name | Potvrda dostave | Confirmation of-delivery | A plain name for a saved note, 15 characters. |
| C.iphone.1.k | Odgovor napišeš jednom. | The reply you-write once. | The same words that open the hr What's New, so the frame and the release notes say it alike. |
| C.iphone.1.h *built* | [Ana], narudžbu ti šaljemo u [utorak]. | Ana, the order to-you we-send on Tuesday. | Built from the reply with names[0] and the weekday. |
| C.iphone.1.s | Dodirneš ga i Cutling pita za ime kupca. | You-tap it and Cutling asks for the name of-the-customer. | "ime kupca" rather than "te pita za ime", which could be read as asking for the buyer's own name. "ga" is the reply above it. |
| C.iphone.2.k | Isti odgovor, sljedeći kupac. | Same reply, next customer. | Answers frame 1's kicker as a pair. "sljedeći" not "novi", because Luka's name was used before. |
| C.iphone.2.h *built* | [Luka], narudžbu ti šaljemo u [utorak]. | Luka, the order to-you we-send on Tuesday. | Built from the reply with names[1]. |
| C.iphone.2.s | Prijašnja imena čekaju na tipkovnici, svako na jedan dodir. | Previous names wait on the keyboard, each at one touch. | "prijašnja imena" as in the hr What's New. "na jedan dodir" is the listing's own idiom for one tap, and "svako" agrees with "ime". |
| C.iphone.3.k | Datumi se upisuju sami. | Dates write-themselves-in on-their-own. | Reflexive. "Cutling sam upisuje..." was avoided because "Cutling sam" first reads as "I am Cutling". |
| C.iphone.3.h *built* | Paket je dostavljen [23. studenoga 2026.] | The parcel is delivered 23 November 2026. | Built from `delivered` with the long date as the chip. |
| C.iphone.3.s | Danas, sutra ili za tjedan dana, prema danu kad lijepiš. | Today, tomorrow or in a week of-days, according-to the day when you-paste. | The three are the app's own labels (Danas, Sutra, Za tjedan dana), and "lijepiš" is the app's Zalijepi. |
| C.iphone.4.k | I ono što se nikad ne mijenja: | And that which never doesn't change: | Croatian double negation. The colon leads into the headline as one sentence. |
| C.iphone.4.h | tvoj [IBAN], tvoja [adresa], tvoj [potpis]. | your IBAN, your address, your signature. | IBAN is what people in Croatia call their account number: it has been the mandatory format for all payments there since 1 June 2013 (HNB), and the hr seed shows "IBAN: HR12...". The possessive is repeated because it changes with gender (tvoj, tvoja). "potpis" is the listing's word for an email sign-off. |
| C.iphone.4.s | Po jedan dodir na Cutling tipkovnici u svakoj aplikaciji. | One touch each on the Cutling keyboard in every app. | "po" is the Croatian distributive "each". "Cutling tipkovnica" is the app's own name for the keyboard. |
| C.iphone.5.k | Ima mjesta za sve. | There-is room for everything. | Set phrase. |
| C.iphone.5.h | [5.000] cutlinga | 5,000 cutlings | Numbers from 5 up take the genitive plural, so the product word is "cutlinga", the form the hr What's New and the app use ("5.000 tekstualnih cutlinga"). Lowercase, as in the app's sentences. |
| C.iphone.5.s | Dosad ih je stalo 100, a u svaki stane cijeli e-mail. | Until-now of-them has fit 100, and into each fits a whole e-mail. | "dosad je stalo 100" comes from the hr What's New. "stati" (to fit) is used twice on purpose. "e-mail" is spelled as in the listing. |
| C.iphone.6.k | iPhone, iPad i Mac. | iPhone, iPad and Mac. | Croatian has no comma before "i". |
| C.iphone.6.h | Plaćaš [jednom]. | You-pay once. | Imperfective "plaćaš" states the rule. Perfective "Platiš jednom." on its own sounds unfinished, as if "i gotovo" should follow. |
| C.iphone.6.s | Jedna kupnja za sva tri, bez registracije i bez pretplate. | One purchase for all three, without registration and without subscription. | "bez registracije" is the everyday way to say no account. "bez računa" was avoided because beside "kupnja" it reads as "without a receipt". |
| C.mac.1.k | Napišeš jednom, šalješ svima. | You-write once, you-send to-everyone. | Perfective "napišeš" (once, done) against imperfective "šalješ" (again and again). |
| C.mac.1.h *built* | [Lana], paket [Premium] ti šaljemo u [utorak]. | Lana, the package Premium to-you we-send on Tuesday. | Built from mac_reply with mac_name, the better plan and the weekday. |
| C.mac.1.s | Odgovor odabereš s {cmd} i prije lijepljenja popuniš kratki obrazac. | The reply you-pick with ⌘⇧V and before pasting you-fill-in a short form. | "popuniti obrazac" is the everyday phrase for filling in a form. "s ⌘⇧V" as in the Mac What's New. |
| C.mac.2.k | Gdje god tipkaš. | Wherever you-type. | Natural fragment for a kicker. |
| C.mac.2.h | {cmd} | ⌘⇧V | Fixed by the brief. |
| C.mac.2.s | Tvoji cutlinzi i nedavno kopirano otvaraju se iznad bilo koje aplikacije. | Your cutlings and the recently copied open above any app. | "nedavno kopirano" avoids "što si kopirao/kopirala", which would force a gender on the reader. |
| C.mac.3.k | Povijest kopiranja preskače | The history of-copying skips | The dots below become the object of "preskače". "povijest kopiranja" is the hr description's phrase, plainer than the settings' "povijest međuspremnika". |
| C.mac.3.h *fixed* | [••••••••••] | (password dots) | Not written by the language. |
| C.mac.3.s | Sve što upravitelj zaporki označi kao skriveno nikad ne uđe u povijest. | Everything that a manager of-passwords marks as hidden never enters into the history. | "upravitelj zaporki ... označi kao skriveno" matches the hr description and the app's Mac setting word for word. |
| C.mac.4.k | Promijeniš nešto na Macu, | You-change something on the Mac, | Leads into the headline as one sentence. |
| C.mac.4.h | promijeni se i na [iPhoneu]. | it-changes also on the iPhone. | "iPhoneu" is the locative the app writes ("na tvom iPhoneu"), and the chip covers the inflected word. |
| C.mac.4.s | Cutlinzi se sinkroniziraju preko tvog iClouda, bez registracije. | Cutlings sync via your iCloud, without registration. | The subject is named as "Cutlinzi" because clipboard history stays on the Mac, so "sve" (everything) would be untrue. "preko tvog iClouda" is the app's phrase. |
| C.mac.5.k | iPhone, iPad i Mac. | iPhone, iPad and Mac. | Same as iPhone 6. |
| C.mac.5.h | Plaćaš [jednom]. | You-pay once. | Same as iPhone 6. |
| C.mac.5.s | Jedna kupnja za sva tri, bez registracije i bez pretplate. | One purchase for all three, without registration and without subscription. | Same as iPhone 6. |

Rendered on 2026-11-23 with `build.py` direction C for hr (iPhone, iPad, Mac): every string fits without clipping, and the
drawn keyboard reads "Ime, narudžbu ti šaljemo u utorak." with the keys Ana, Luka, Hrvoje and Zalijepi. Three of the
hr captures under the words are not Croatian yet: iPhone and iPad 01 Messages are entirely English (Maya, "Bank
Account"), the 02 grid's title is the old plural "Cutlingovi" where the app now says "Cutlinzi", and the Mac 02 History
capture still shows "Clear History".
