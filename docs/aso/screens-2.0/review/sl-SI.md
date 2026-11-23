# sl-SI (Slovenian): words for the 2.0 store frames (ASG167)

Written from `C-words-brief.md` and the `sl-SI` entry of `locale-facts.json` (weekday `torek`, long date
`23. november 2026`, `5000`, `100`); the file is `fastlane/compose/creative/v2/words/sl-SI.json`. Every line speaks to the
buyer with formal "vi" (napišete, tapnete, plačate, vaš), the register of Slovenian App Store listings read on 2026-11-23:
Vinted, mimovrste=), Petrol, bolha.com and NLB Klik all use "vi"; only the fashion and beauty shops Zalando and Notino
use "ti". Microsoft's Slovenian style guide also addresses the user as "vi", and so do Cutling's own sl description,
promotional text and 1.x frame titles. The demo shop also writes to its customers with "vi" (vaše naročilo), as Slovenian
shops do even when they use a first name. Product words come from the app's sl strings and its sl captures: cutling,
cutlingi, cutlingov (Iskanje cutlingov), prazna mesta, lepljenje, bližnjica, zgodovina odložišča, tipkovnica, tapniti,
dotik, Ime, and the seed tiles Domači naslov, E-poštni podpis, Bančni račun (IBAN: SI56 …). No dashes and no quotation
marks are used. A no-break space (U+00A0, written `\u00a0` in the JSON) ties each one-letter preposition to the next
word so it never ends a line, as Slovenian typesetting does: "v\u00a0{date}" in both replies, "v\u00a0vsaki" (iPhone 4),
"V\u00a0vsakega" (iPhone 5), "z\u00a0bližnjico" (Mac 1) and "v\u00a0zgodovino" (Mac 3). Two more keep a phrase whole at
the iPhone width: "le\u00a0še" (iPhone 1) and "na\u00a0en\u00a0dotik" (iPhone 2). "e-poštno" in iPhone 5 has a
non-breaking hyphen (U+2011, written `\u2011`), because Pravopis does not divide a compound that starts with a single
letter at its hyphen, and the browser had split it as "e- / poštno". The table shows these strings with plain spaces
and hyphens. Rows marked *built* are put together by the build from the seed and are shown so the whole sentence can be
checked.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names | Maja, Luka, Nina | (first names) | SURS counts: Maja is the 3rd most common women's name, Nina the 7th, and Luka is in the men's top 10 and was the top boys' name of 2020; two women, one man, four letters each. |
| cseed.mac_name | Marko | (first name) | One of the six most common names in Slovenia (SURS, December 2025). Rok was avoided because rok is also the noun "deadline", which would read oddly in a shipping message. |
| cseed.reply | {name}, vaše naročilo gre na pot v {date}. | {name}, your order goes on the way on {date}. | "Gre na pot" is how a Slovenian shop says an order sets off. "V torek" uses torek as given (its accusative is the same form). 39 characters filled. |
| cseed.reply_name | Odprema | Dispatch | The shop's own word for sending goods out (odprema naročila), shorter than Pošiljanje. |
| cseed.mac_reply | {name}, vaš paket {plan} gre na pot v {date}. | {name}, your package {plan} goes on the way on {date}. | Same reply as on iPhone. The tier is a paket named after it, in Slovenian word order (paket Premium), as in the app's sl 2.0 What's New. 44 characters filled. |
| cseed.name_label | Ime | Name | The app's own sl string for Name. |
| cseed.plan_label | Paket | Package | What Slovenian telcos and shops call a tier you buy (paket Osnovni, paket Premium). Načrt would be a calque of "plan". |
| cseed.plan_choices | Osnovni, Premium | Basic, Premium | Osnovni is the native base-tier word, and Premium is the loanword Slovenian price lists use. Both match the example in the app's 2.0 What's New. |
| cseed.delivered | Dostavljeno: {date} | Delivered: {date} | The app types the date in the nominative (23. november 2026). That reads right only as a value after a colon, as on a delivery note; inside a sentence, Slovenian would need the genitive "23. novembra". |
| cseed.delivered_name | Dostava | Delivery | A short title for the saved note. |
| C.iphone.1.k | Odgovor napišete enkrat. | Reply you-write once. | Formal vi. 24 characters, exactly the limit. |
| C.iphone.1.h *built* | [Maja], vaše naročilo gre na pot v [torek]. | Maja, your order goes on the way on Tuesday. | Built from the reply. |
| C.iphone.1.s | Ko tapnete shranjeni odgovor, Cutling vpraša le še za ime. | When you-tap the-saved reply, Cutling asks only still for name. | Tapniti is the tap verb of the app's sl strings. "Le še" says the name is the one thing left to give. 58 characters. |
| C.iphone.2.k | Isti odgovor dobi naslednja stranka. | Same reply gets next customer. | Object first, so the pair reads "Odgovor …" / "Isti odgovor …". Stranka is the plain word for a shop's customer. |
| C.iphone.2.h *built* | [Luka], vaše naročilo gre na pot v [torek]. | Luka, your order goes on the way on Tuesday. | Built from the reply. |
| C.iphone.2.s | Imena, ki ste jih že vpisali, čakajo kot tipke na en dotik. | Names that you-have them already entered wait as keys at one touch. | "Na en dotik" is the touch form of the everyday "na en klik". Dotik is the noun Cutling's sl listing already uses (z dotikom). |
| C.iphone.3.k | Datume Cutling vpiše sam. | Dates Cutling writes-in itself. | Dates first, and sam (by itself) last, where Slovenian puts the weight. |
| C.iphone.3.h *built* | Dostavljeno: [23. november 2026] | Delivered: 23 November 2026 | Built from delivered with the long date. |
| C.iphone.3.s | Datum za danes, jutri ali čez teden dni je točen na dan, ko ga prilepite. | Date for today, tomorrow or in a week of days is exact on the day when it you-paste. | "Čez teden dni" is the everyday "a week from now". Ga points back to datum. |
| C.iphone.4.k | In vse, kar je vedno enako | And everything that is always the same | Leads into the list without a colon, so the headline keeps its capital. |
| C.iphone.4.h | Vaš [IBAN], [naslov] in [podpis]. | Your IBAN, address and signature. | One vaš covers all three because all three nouns are masculine. IBAN over TRR, because the keyboard capture under it shows "IBAN: SI56 …"; naslov and podpis are the app's tile words. 27 characters. |
| C.iphone.4.s | Vsak je ena tipka na tipkovnici Cutling, v vsaki aplikaciji. | Each is one key on keyboard Cutling, in every app. | The name follows the noun, as Slovenian names products (tipkovnica Cutling). 60 characters. |
| C.iphone.5.k | Prostora je za vse. | Of-room there-is for all. | A set Slovenian phrase. |
| C.iphone.5.h | [5000] cutlingov | 5000 cutlings | 5000 as locale-facts writes it. Numbers from five up take the genitive plural cutlingov, the form the app shows in "Iskanje cutlingov"; lowercase, as in the app's running text. |
| C.iphone.5.s | Prej jih je bilo največ 100. V vsakega gre celo e-poštno sporočilo. | Before of-them there-was at-most 100. Into each goes a whole e-mail message. | "Največ" makes 100 the old cap, not a count. "Gre v" is everyday "fits into". |
| C.iphone.6.k | Za iPhone, iPad in Mac | For iPhone, iPad and Mac | After za, the device names keep their base form. |
| C.iphone.6.h | Plačate le [enkrat]. | You-pay only once. | 18 characters, with the chip on enkrat (once). |
| C.iphone.6.s | En nakup velja za vse tri, brez registracije in naročnine. | One purchase is-valid for all three, without registration and subscription. | Not "brez računa": račun is also an invoice, and "without an invoice" beside a purchase reads as off the books. Registracija is unambiguous, and naročnina is the recurring fee. |
| C.mac.1.k | Napišete enkrat, pošljete vsem. | You-write once, you-send to-all. | The same vi verbs as iPhone 1. |
| C.mac.1.h *built* | [Marko], vaš paket [Premium] gre na pot v [torek]. | Marko, your package Premium goes on the way on Tuesday. | Built from mac_reply with the better plan. |
| C.mac.1.s | Odgovor izberete z bližnjico {cmd}, obrazec pa pred lepljenjem vpraša za prazna mesta. | Reply you-choose with shortcut ⌘⇧V, form and before pasting asks for blank places. | Bližnjica, lepljenje and prazna mesta are the app's own sl words. "Z bližnjico" avoids picking s or z directly before the ⌘ key. "Kratek" was cut so the line ends on two full lines, not on a lone "mesta". |
| C.mac.2.k | Kjer koli pišete | Wherever you-write | Spelled apart, as the Pravopis headword "kjer koli" is. |
| C.mac.2.h | {cmd} | ⌘⇧V | Fixed. |
| C.mac.2.s | Vaši cutlingi in to, kar ste nazadnje kopirali, se odprejo nad vsako aplikacijo. | Your cutlings and that which you-have last copied open over every app. | Plural verb for the two subjects. |
| C.mac.3.k | Zgodovina odložišča preskoči | History of-clipboard skips | The dots below are the object of preskoči. Zgodovina odložišča is the app's sl name for the history. |
| C.mac.3.h *built* | [••••••••••] | (password dots) | Fixed by the build. |
| C.mac.3.s | Kar upravitelj gesel označi kot skrito, nikoli ne pride v zgodovino. | What manager of-passwords marks as hidden never not comes into history. | The wording of Cutling's sl Mac description ("upravitelj gesel označi kot skrito"). The double negative is standard Slovenian. |
| C.mac.4.k | Spremenite nekaj na Macu. | Change something on Mac. | Two short sentences, not one split across k and h: a Slovenian sentence cannot open with the clitic se, so the headline needs its verb first. |
| C.mac.4.h | Spremeni se tudi na [iPhonu]. | Changes itself also on iPhone. | iPhone takes the locative, iPhonu, and the chip is on it. |
| C.mac.4.s | Cutlingi se sinhronizirajo prek vašega iClouda, brez registracije. | Cutlings sync via your iCloud, without registration. | Matches the app's own iCloud settings line, in vi. |
| C.mac.5.k | Za iPhone, iPad in Mac | For iPhone, iPad and Mac | Reused from iPhone 6. |
| C.mac.5.h | Plačate le [enkrat]. | You-pay only once. | Reused from iPhone 6. |
| C.mac.5.s | En nakup velja za vse tri, brez registracije in naročnine. | One purchase is-valid for all three, without registration and subscription. | Reused from iPhone 6. |

Rendered on 2026-11-23 with `build.py sl-SI C` (iPhone, iPad, Mac): every string fits without clipping, each one-letter
preposition stays on the line of its word, and the drawn keyboard reads "Ime, vaše naročilo gre na pot v torek." with the keys Maja, Luka, Nina
and Prilepi; the Mac form shows Odprema, Ime, Paket with Osnovni and Premium, Prekliči and Prilepi. The sl-SI
02_MainGrid captures under iPhone and iPad frames 5 and 6 date from 2026-10-01 and still show "8 Cutlingi" and the
search field "Išči cutlings"; the app's strings now read "Cutlingov: %lld" and "Iskanje cutlingov", so a new grid
capture would show correct Slovenian. Cutling's sl 2.0 What's New (iOS and Mac) speaks with "ti", while the description,
promotional text and these frames use "vi".
