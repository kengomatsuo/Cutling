# da (Danish): words for the 2.0 store frames, direction C

Written from `C-words-brief.md` and the `da` entry of `locale-facts.json`; the file is
`fastlane/compose/creative/v2/words/da.json`. The buyer is addressed as "du" with imperatives, in sentence case, as Danish
App Store listings do (MobilePay's listing, No. 1 in Finance, is the reference). Every subordinate clause takes the comma
before it ("startkomma"): Dansk Sprognævn leaves that comma optional but asks for one principle held through a text, and
the app's own Danish writes it. "én" and "ét" carry the accent where they mean the number one. No dashes. Rows marked
*built* are made by the build from the seed and are shown so the finished headline can be read.

| Key | Danish | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names | Mette, Mads, Ida | Mette, Mads, Ida | Danmarks Statistik, 1 January 2026: Mette is the 2nd most common women's name (37,932), Ida the 18th, Mads the 14th men's name. Short enough for the name keys; two women, one man. |
| cseed.mac_name | Søren | Søren | 7th most common men's name (38,087); the ø tells a Danish buyer the frame was made for them. |
| cseed.reply | Hej {name}, din pakke sendes {date}. | Hi {name}, your parcel is sent {date}. | "pakke" (parcel) is warmer and more concrete than "ordre". The s-passive "sendes" with a bare weekday is how a Danish shop gives a dispatch day, so "tirsdag" stands uninflected with no preposition. 34 to 36 characters filled. |
| cseed.reply_name | Forsendelse | Shipment | The word Danish shops use for shipping (their "Forsendelse og levering" page). |
| cseed.mac_reply | Hej {name}, din {plan}-pakke sendes {date}. | Hi {name}, your {plan} package is sent {date}. | A tier you buy is a "pakke" in Danish (TV packages, hosting packages), so the plan is the box that ships. The hyphen is the Danish rule for a compound whose first part is a name (Plus-pakke). 41 characters filled. |
| cseed.name_label | Navn | Name | The app's own label for Name. |
| cseed.plan_label | Pakke | Package | The usual Danish word for a tier. The app's default label for a new choice blank is "abonnement" (subscription), which does not fit a parcel that ships. |
| cseed.plan_choices | Basis, Plus | Basic, Plus | Both are ordinary Danish tier names (Basispakke). |
| cseed.delivered | Leveret den {date} | Delivered the {date} | Danish puts "den" before a full date. |
| cseed.delivered_name | Levering | Delivery | One word, as an owner would file the note. |
| iphone.1.k | Skriv svaret én gang. | Write the reply once. | Imperative, du-register; the accent marks "én" as the number. |
| iphone.1.h *built* | Hej [Mette], din pakke sendes [tirsdag]. | Hi [Mette], your parcel is sent [Tuesday]. | From `reply` with names[0] and the weekday. |
| iphone.1.s | Tryk på svaret, så spørger Cutling efter navnet. | Tap the reply, then Cutling asks for the name. | "Tryk på" is Apple's Danish for tap, and "Tryk på X, så …" is the app's own sentence shape. One line, level with frame 2. |
| iphone.2.k | Send det til den næste. | Send it to the next one. | "det" points back to "svaret" in frame 1, so the pair reads as one thought. |
| iphone.2.h *built* | Hej [Mads], din pakke sendes [tirsdag]. | Hi [Mads], your parcel is sent [Tuesday]. | From `reply` with names[1]. |
| iphone.2.s | Navnene fra før ligger klar på hver sin tast. | The names from before lie ready, each on its own key. | "ligger klar" is the everyday "waiting, ready"; "hver sin tast" says one key per name. |
| iphone.3.k | Datoen skriver sig selv. | The date writes itself. | A Danish idiom for "takes no effort", here also literally true. |
| iphone.3.h *built* | Leveret den [23. november 2026] | Delivered the [23 November 2026] | From `delivered` with the long date; on iPhone the chip breaks after "23.", the natural place. |
| iphone.3.s | I dag, i morgen eller om en uge, regnet fra dagen, hvor du indsætter. | Today, tomorrow or in a week, counted from the day when you paste. | The three options are the app's own labels (I dag, I morgen, Om en uge) and "indsætter" is its Paste. Worded so the iPhone line breaks after "dagen,". |
| iphone.4.k | Og det, der aldrig ændrer sig: | And that which never changes: | Leads into the headline as one sentence, so the headline starts lowercase after the colon. |
| iphone.4.h | dit [kontonummer], din [adresse] og din [signatur]. | your [account number], your [address] and your [signature]. | Shortest everyday names with the right possessive (dit for neuter, din for common gender). Danes say "kontonummer" (the store's promo text says "kontonumre"); "signatur" as in the app's "E-mail-signatur". No comma before "og" in a Danish list. |
| iphone.4.s | Ét tryk hver på Cutling-tastaturet i alle apps. | One tap each on the Cutling keyboard in all apps. | "Cutling-tastaturet" is the app's name for it; this wording fits one line, so the compound never breaks at its hyphen. |
| iphone.5.k | Der er plads til det hele. | There is room for all of it. | Everyday idiom; "plads" is also the app's word ("Plads til %@"). |
| iphone.5.h | [5.000] cutlings | [5,000] cutlings | Number as the facts give it; lowercase "cutlings" as the app writes it in running text (dine cutlings, Søg cutlings). |
| iphone.5.s | Før var grænsen 100, og hver enkelt kan rumme en hel e-mail. | Before, the limit was 100, and each single one can hold a whole e-mail. | "e-mail" spelled as in the app. |
| iphone.6.k | Til iPhone, iPad og Mac. | For iPhone, iPad and Mac. | "Til" as Danish product labels say it. |
| iphone.6.h | Betal [én gang]. | Pay [once]. | The chip is on "én gang", the Danish for once, with the accent marking the number; on iPhone it sits whole on the second line under "Betal". |
| iphone.6.s | Ét køb til alle tre, uden konto og abonnement. | One purchase for all three, without account and subscription. | "uden … og …" is the Danish way to say no account and no subscription; one line. |
| mac.1.k | Skriv det én gang og send det til alle. | Write it once and send it to everyone. | No comma: two imperatives that share one subject. |
| mac.1.h *built* | Hej [Søren], din [Plus]-pakke sendes [tirsdag]. | Hi [Søren], your [Plus] package is sent [Tuesday]. | From `mac_reply` with mac_name, the better plan and the weekday. |
| mac.1.s | Vælg svaret med {cmd}, udfyld felterne i en lille formular, og så indsættes det. | Choose the reply with ⌘⇧V, fill in the fields in a small form, and then it is pasted. | "felter" is the app's word for blanks (Felter og datoer), and "udfyld felterne" is what Danish forms say. |
| mac.2.k | Uanset hvor du skriver. | No matter where you write. | Plain spoken Danish. |
| mac.2.h | {cmd} | ⌘⇧V | As the brief gives it. |
| mac.2.s | Dine cutlings og det, du sidst har kopieret, vises oven på enhver app. | Your cutlings and what you last copied are shown on top of any app. | "vises" (are shown) because the cutlings themselves do not open; the line breaks right after it. |
| mac.3.k | Historikken springer over | The history skips | "springe over" is Danish for skip, and the app's own setting says hidden items "springes over"; the row of dots reads as its object. "Historik" is the app's tab name. |
| mac.3.s | Det, en adgangskodeadministrator markerer som skjult, gemmes aldrig. | What a password manager marks as hidden is never saved. | "adgangskodeadministrator" and "markerer som skjult" are the words the app and the Danish store description already use. |
| mac.4.k | Ret noget på din Mac, | Change something on your Mac, | "Ret …, så er det rettet" is the Danish "do it here and it's done there" frame. |
| mac.4.h | så er det rettet på din [iPhone]. | then it is changed on your [iPhone]. | Chip on iPhone, as the brief asks. |
| mac.4.s | Alt synkroniseres med din egen iCloud, uden at du skal oprette en konto. | Everything is synced with your own iCloud, without you having to create an account. | "synkroniseres med iCloud" as the app says it. |
| mac.5.k | Til iPhone, iPad og Mac. | For iPhone, iPad and Mac. | Same as iphone.6. |
| mac.5.h | Betal [én gang]. | Pay [once]. | Same as iphone.6. |
| mac.5.s | Ét køb til alle tre, uden konto og abonnement. | One purchase for all three, without account and subscription. | Same as iphone.6. |
