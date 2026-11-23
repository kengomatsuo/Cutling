# Czech (cs) words for the 2.0 store frames, direction C (card ASG167)

Written from `docs/aso/screens-2.0/C-words-brief.md` and the `cs` entry of `locale-facts.json`
(`úterý`, `23. listopadu 2026`, `5 000`, `100`). File: `fastlane/compose/creative/v2/words/cs.json`.

**Register.** The captions speak to the buyer with formal *vy* (vykání), the way Czech App Store listings speak:
the Czech listings of Apple's Pages, Mapy.com and Zásilkovna use it, and so do Cutling's Czech site, store
description and promotional text; of the four listings read, only Spotify's, a youth brand, uses *ty*. The demo reply is the shop owner
writing to a customer by first name, so it uses *ty* with "Ahoj", the usual Czech pairing; that is the shop
owner's voice, not the listing's. Note for the page as a whole: the Czech 2.0 What's New and the in-app event
card were written in *ty*, so they differ from these captions and the description.

**Names.** Czech addresses people in the vocative (Petr becomes Petře, Jana becomes Jano), and "Ahoj Jana" reads
as machine-made. All four names have a vocative identical to the name (Lucie, Jiří, Marie, Julie; checked in the
Internetová jazyková příručka), so the greeting is correct whichever key is tapped and the keys still show plain
names.

**Spacing.** Every one-letter preposition or conjunction (a, i, v, z) is joined to the next word by a no-break
space (U+00A0), as ČSN 01 6910 asks, so the big headline (about 11 characters a line on iPhone) never ends a line
on one. Three short prepositions the first render left alone at a line end are held to their nouns the same way
("na iPhonu", "bez registrace", "do historie"), and "e‑mail" has a non-breaking hyphen (U+2011). The table shows
these as plain spaces and hyphens.

**Render check.** All 17 cs frames (iPhone, iPad, Mac) were built with `build.py` and looked at. Two things on
them are not from this file: iPhone frame 3 breaks the facts' date "23. listopadu 2026" as "23." / "listopadu 2026"
in the headline and the bubble (Czech typesetting keeps the day with its month; the date string has plain
spaces), and the cs folder's iPhone and iPad `01_KeyboardInMessages` captures behind frame 4 are English screens,
like the "Clear History" button in the cs Mac `02_History` capture (the app's cs string is "Vymazat historii").

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | `Lucie` | Lucie | Frame 1's customer; one of the commonest names of Czech women of shopping age. Its vocative is also 'Lucie' (IJP), so 'Ahoj Lucie' is correct with no case change. |
| cseed.names[1] | `Jiří` | Jiří (George) | Frame 2's customer; the commonest man's name in Czechia. Vocative 'Jiří' is the same form (IJP), unlike Petr/Petře or Tomáš/Tomáši, so the reply reads right with the name as typed. |
| cseed.names[2] | `Marie` | Marie (Mary) | Third key; the commonest woman's name. Vocative 'Marie' is the same form, so any of the three keys gives a correct greeting. |
| cseed.mac_name | `Julie` | Julie | Same vocative-safe '-ie' type (vocative 'Julie'), a name common among younger women. |
| cseed.reply | `Ahoj {name}, balíček ti pošlu v {date}.` | Hi {name}, the parcel to-you[informal] I-will-send on {date}. | Shop owner to a customer on first-name terms, so informal 'ty' with 'Ahoj', the usual Czech pairing. 'v úterý' is the normal 'on Tuesday' and 'úterý' stays uninflected. 'balíček' (little parcel) is the warm word Czech shops use. No comma after 'Ahoj' (optional after a one-word greeting, IJP). Filled: 37 and 36 characters. |
| cseed.reply_name | `Stav objednávky` | Order status | The plain name a Czech shop would give a 'your order ships' message; 15 characters. |
| cseed.mac_reply | `Ahoj {name}, balíček {plan} ti pošlu v {date}.` | Hi {name}, the parcel {plan} to-you I-will-send on {date}. | The same reply with the tier named after 'balíček', which reads as both the bundle and the parcel. Filled: 'Ahoj Julie, balíček Premium ti pošlu v úterý.', 45 characters. |
| cseed.name_label | `Jméno` | (First) name | 'Jméno' is a person's name; 'Název' would be the name of a thing. |
| cseed.plan_label | `Balíček` | Package | A common Czech word for a tier you buy ('balíček Premium'), and right for a shop that ships what is bought; 'Tarif' reads as a phone or energy contract. |
| cseed.plan_choices[0] | `Základní` | Basic | The pair the Czech 2.0 What's New already uses as its example ('plán „Základní“ nebo „Premium“'), so the store page agrees with itself; 8 characters. |
| cseed.plan_choices[1] | `Premium` | Premium | Loanword used as is in Czech tiers; 7 characters. |
| cseed.delivered | `Doručeno {date}` | Delivered {date} | A status stamp as Czech shops write it: no formal 'dne' and no full stop. Filled: 'Doručeno 23. listopadu 2026'. |
| cseed.delivered_name | `Datum doručení` | Date of delivery | Picked over 'Doručení', which would sit right above 'Doručeno' on the card and look like a typo; 14 characters. |
| C.iphone.1.k | `Napíšete ji jen jednou.` | You-write it only once. | Formal 'vy' in every caption (see the register note). 'ji' points at the reply below (odpověď, feminine); 23 characters. |
| C.iphone.1.s | `Klepněte na uloženou odpověď a Cutling se zeptá na jméno.` | Tap on the-saved reply and Cutling asks for the-name. | 'Klepnout' is the app's own Czech verb for tap ('Klepněte na'); 57 characters. |
| C.iphone.2.k | `Stejnou pošlete dalšímu.` | The-same-one you-send to-the-next-one. | 'Stejnou' (the same, feminine, for the reply) carries 'the very same reply'; 'dalšímu' reads as the next customer because the name in the headline changed. 24 characters, like frame 1. |
| C.iphone.2.s | `Dříve použitá jména máte na jedno klepnutí.` | Earlier-used names you-have at one tap. | 'na jedno klepnutí' is the Czech idiom for 'one tap away'; the participle 'použitá' agrees with 'jména', so no verb has to show the reader's gender. |
| C.iphone.3.k | `Datum doplní Cutling sám.` | The-date fills-in Cutling by-itself. | Singular 'datum', because the plural 'data' also reads as 'data'. |
| C.iphone.3.s | `Dnes, zítra nebo za týden, vždy podle dne, kdy vkládáte.` | Today, tomorrow or in a week, always by the-day when you-paste. | 'vkládat' is the verb of the app's Paste button (Vložit); 'podle dne, kdy vkládáte' puts the date on the paste day. 56 characters. |
| C.iphone.4.k | `A to, co se nikdy nemění:` | And that, what never changes: | Leads into the headline as one sentence; a colon is how Czech opens a list. 25 characters. |
| C.iphone.4.h | `vaše [číslo účtu], [adresa] a [podpis].` | your [account number], [address] and [signature]. | The shortest everyday names: 'číslo účtu' (as the Czech promo text says it), 'adresa', 'podpis' (an email sign-off; the Czech description says 'podpisy do mailů'). One 'vaše' covers all three, as Czech lists do. 33 characters. |
| C.iphone.4.s | `Vložíte je z klávesnice Cutling jedním klepnutím, kamkoli.` | You-insert them from the-keyboard Cutling with-one tap, anywhere. | 'klávesnice Cutling' is what the app calls its keyboard; 'je' (them) avoids 'každé' (each), whose gender would clash across číslo, adresa and podpis. 58 characters. |
| C.iphone.5.k | `Místo na všechno.` | Room for everything. | The plain Czech phrase. |
| C.iphone.5.h | `[5 000] cutlingů` | [5,000] cutlings | After numbers from 5 up Czech takes the genitive plural 'cutlingů', as the app ('Až %lld textových cutlingů'), the site and the 2.0 notes write it; 'Cutlingy' would be ungrammatical here. Lowercase as in running text; the number is n5000 with its no-break space. |
| C.iphone.5.s | `Dřív se jich vešlo jen 100 a každý pojme celý e-mail.` | Before only 100 of-them fitted, and each-one holds a whole e-mail. | 'každý' agrees with 'cutling' (masculine); 'e-mail' with a hyphen, as the Czech 2.0 notes spell it, written with a non-breaking hyphen (U+2011) because the first render broke it as 'e-' / 'mail.' |
| C.iphone.6.k | `iPhone, iPad a Mac.` | iPhone, iPad and Mac. | The same heading the Czech site uses. |
| C.iphone.6.h | `Zaplatíte [jednou].` | You-will-pay [once]. | The Czech site's own promise ('Zaplatíte jednou a aplikace je vaše napořád'); 17 characters of the 18. |
| C.iphone.6.s | `Jeden nákup pro všechny tři, bez registrace a předplatného.` | One purchase for all three, without registration and subscription. | 'všechny' agrees with the three masculine device names; 'bez registrace' is the usual Czech for 'no account to create'; 'předplatné' always means paying again and again. |
| C.mac.1.k | `Napíšete jednou, pošlete všem.` | You-write once, you-send to-everyone. | Two short clauses with a comma, the Czech slogan shape; the object is left out, as Czech allows. |
| C.mac.1.s | `Odpověď vyberete přes {cmd} a krátký formulář se před vložením zeptá, co doplnit.` | The-reply you-pick via ⌘⇧V and a-short form asks before pasting what to-fill-in. | 'přes ⌘⇧V' as the Czech 2.0 Mac notes write it; 'co doplnit' (what to fill in) is how Czech asks for blanks. |
| C.mac.2.k | `Ať píšete kdekoli.` | Wherever you-type. | The usual Czech 'ať … kdekoli' (no matter where). |
| C.mac.2.h | `{cmd}` | ⌘⇧V | Fixed by the brief. |
| C.mac.2.s | `Otevře vaše cutlingy i naposledy zkopírované věci nad jakoukoli aplikací.` | [It] opens your cutlings and the-last copied things over any app. | The subject is the shortcut in the headline, which Czech may leave out; 'cutlingy' lowercase in a sentence, as the app's sentences write it. |
| C.mac.3.k | `Historie schránky přeskočí` | The-clipboard history skips | The row of dots becomes its object ('skips ••••'); 'přeskočí' is the verb the Czech description already uses. |
| C.mac.3.s | `Nic, co správce hesel označí jako skryté, se do historie nedostane.` | Nothing that a-password manager marks as hidden gets into the-history. | 'správce hesel' and 'skryté' as the Czech description has them ('hesla skrytá správcem hesel'). |
| C.mac.4.k | `Co změníte na Macu,` | What you-change on the-Mac, | Opens a 'Co …, to …' pair finished by the headline. |
| C.mac.4.h | `to se změní i na [iPhonu].` | that changes also on the-[iPhone]. | The chip carries the locative 'iPhonu', the form the Czech site uses after 'na'; 'i na iPhonu' is held on one line, since the first render left 'na' alone at a line end. |
| C.mac.4.s | `Synchronizuje se přes váš vlastní iCloud, bez registrace.` | It-syncs through your own iCloud, without registration. | 'bez registrace' as in iPhone 6. 57 characters. |
| C.mac.5.k | `iPhone, iPad a Mac.` | iPhone, iPad and Mac. | Same as iPhone 6. |
| C.mac.5.h | `Zaplatíte [jednou].` | You-will-pay [once]. | Same as iPhone 6. |
| C.mac.5.s | `Jeden nákup pro všechny tři, bez registrace a předplatného.` | One purchase for all three, without registration and subscription. | Same as iPhone 6. |

## The built headlines as the frames show them

| Frame | Headline (chips in brackets) |
|---|---|
| iPhone/iPad 1 | `Ahoj [Lucie], balíček ti pošlu v [úterý].` |
| iPhone/iPad 2 | `Ahoj [Jiří], balíček ti pošlu v [úterý].` |
| iPhone/iPad 3 | `Doručeno [23. listopadu 2026]` |
| Mac 1 | `Ahoj [Julie], balíček [Premium] ti pošlu v [úterý].` |
