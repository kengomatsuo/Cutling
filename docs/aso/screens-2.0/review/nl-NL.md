# nl-NL (Dutch, Netherlands): words for the 2.0 store frames, direction C

Written from `C-words-brief.md` and the `nl-NL` entry of `locale-facts.json`; the file is
`fastlane/compose/creative/v2/words/nl-NL.json`. The buyer is addressed as "je" with imperatives, in sentence case, as
Dutch App Store listings do (Tikkie's listing: "Met Tikkie betalen je vrienden jou eenvoudig terug") and as the app and
its Dutch store description already do. "één" carries its accents where it means the number one, and is written "Eén"
at the start of a sentence (Team Taaladvies, "een / één"). A comma stands between two finite verbs that meet
("gebruikte, kies"), and none before "en" in a list. No dashes. Numbers and dates are as the facts give them (5.000,
23 november 2026, dinsdag in lowercase). ` ` in the file is a no-break space that keeps a short phrase on one line
(om de naam, kies je, met één tik, een kort formulier, geen account nodig). Rows marked *built* are made by the build from the
seed and are shown so the finished headline can be read. Rendered with `python3 build.py nl-NL C` on iPhone, iPad and
Mac: frames 1 and 2 break into the same lines (4 on iPhone, 2 on iPad).

| Key | Dutch | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names | Lisa, Bas, Femke | Lisa, Bas, Femke | Meertens Instituut, Nederlandse Voornamenbank (2022, as first name): Lisa 23,761 women, Bas 19,663 men, Femke 19,687 women. Lisa and Bas also set the reply in the same lines in frames 1 and 2 on iPhone and iPad; Daan (27,619) made iPad frame 2 a line longer than frame 1. |
| cseed.mac_name | Thijs | Thijs | 22,851 men (Meertens, 2022); the "ij" reads as Dutch at a glance. |
| cseed.reply | Hoi {name}, ik verstuur je pakket {date}. | Hi {name}, I send your parcel {date}. | "Hoi" is the warm everyday greeting in Dutch customer messages, and "ik" is a one-person shop writing in its own name. A bare weekday is a plain Dutch time adverb (ik kom dinsdag), so "dinsdag" takes no preposition and comes last, where Dutch puts the new information. 40 characters filled, with Lisa and with Bas. |
| cseed.reply_name | Verzending | Shipping | The word Dutch web shops use for sending an order out. |
| cseed.mac_reply | Hoi {name}, ik verstuur je {plan}pakket {date}. | Hi {name}, I send your {plan}package {date}. | "pakket" is both the parcel and the tier you buy (basispakket), so the plan is the parcel that ships. Written as one word, the main rule for compounds (Team Taaladvies, Aaneenschrijven 01): Pluspakket, like basispakket. The chip already shows where the blank ends, so the optional readability hyphen is left out. 45 characters filled. |
| cseed.name_label | Naam | Name | The app's own label for Name. |
| cseed.plan_label | Pakket | Package | The usual Dutch word for a tier you buy, and the app's own default label for a new choice blank. |
| cseed.plan_choices | Basis, Plus | Basic, Plus | Ordinary Dutch tier names (basispakket, pluspakket); the 2.0 release notes already use Basis as an example. |
| cseed.delivered | Bezorgd op {date} | Delivered on {date} | "bezorgd" is the Dutch tracking word for a parcel that reached the door; Dutch puts "op" before a full date. 11 characters without the date. |
| cseed.delivered_name | Bezorging | Delivery | One word, as an owner would file the note. |
| iphone.1.k | Eén keer geschreven. | One time written. | A participle with no subject: the reply was written only once. 20 characters. |
| iphone.1.h *built* | Hoi [Lisa], ik verstuur je pakket [dinsdag]. | Hi [Lisa], I send your parcel [Tuesday]. | From `reply` with names[0] and the weekday. |
| iphone.1.s | Tik op het antwoord en Cutling vraagt om de naam. | Tap on the reply and Cutling asks for the name. | "Tik op" is Apple's and the app's Dutch for tap; "vragen om" (ask for) as in the 2.0 release notes. "om de naam" stays together on the iPhone's second line. |
| iphone.2.k | En weer naar de volgende klant. | And again to the next customer. | Opens with "En" so it carries on from frame 1's kicker, with the verb left out as in a spoken follow-up. |
| iphone.2.h *built* | Hoi [Bas], ik verstuur je pakket [dinsdag]. | Hi [Bas], I send your parcel [Tuesday]. | From `reply` with names[1]; the same line breaks as frame 1. |
| iphone.2.s | Namen die je eerder gebruikte, kies je met één tik. | Names that you earlier used, choose you with one tap. | Object first, so the names lead the line; the comma stands between the two finite verbs (gebruikte, kies). "kies je" and "met één tik" each stay whole on the iPhone. |
| iphone.3.k | Cutling vult de datum zelf in. | Cutling fills the date itself in. | "invullen" is what you do to a date in a form; "zelf" is "by itself". |
| iphone.3.h *built* | Bezorgd op [23 november 2026] | Delivered on [23 November 2026] | From `delivered` with the long date; Dutch writes the month in lowercase. |
| iphone.3.s | Vandaag, morgen of over een week: de datum klopt op de dag dat je plakt. | Today, tomorrow or in a week: the date is right on the day that you paste. | The three options are the app's own labels (Vandaag, Morgen, Over een week); "klopt" is the everyday "is right" and "plakken" the app's Paste. "de dag dat" is correct beside the more formal "de dag waarop" (Team Taaladvies). |
| iphone.4.k | En wat nooit verandert: | And what never changes: | Leads into the headline as one sentence, so the headline starts in lowercase after the colon. |
| iphone.4.h | je [IBAN], [adres] en [handtekening]. | your [IBAN], [address] and [signature]. | One "je" covers the list, as Dutch forms write "je naam, adres en woonplaats"; repeating it left "en je" alone on an iPhone line. The account number Dutch people share is their IBAN (the app's own Dutch seed writes it so), and it is the shortest name for it; "handtekening" as in the app's "E-mailhandtekening". No comma before "en". |
| iphone.4.s | Eén tik op het Cutling-toetsenbord, in elke app. | One tap on the Cutling keyboard, in every app. | "Cutling-toetsenbord" is the app's own name for it; one line on iPhone. |
| iphone.5.k | Er is ruimte voor alles. | There is room for everything. | "ruimte" as in the app's "Ruimte voor %@". |
| iphone.5.h | [5.000] cutlings | [5,000] cutlings | The number as the facts give it; "cutlings" in lowercase as the app writes it in running text (je cutlings, Zoek cutlings). |
| iphone.5.s | Eerst waren het er 100, en in elke cutling past een hele e-mail. | At first were it there 100, and in each cutling fits a whole e-mail. | "waren het er 100" is how Dutch gives a former count; "past" (fits) says long enough. The comma before "en" separates two clauses with different subjects; e-mail spelled as in the app. |
| iphone.6.k | Voor iPhone, iPad en Mac. | For iPhone, iPad and Mac. | No comma before "en" in a Dutch list. |
| iphone.6.h | [Eén keer] betalen. | [One time] pay. | The infinitive is how Dutch states a benefit; "één keer" is the everyday word for once, plainer than the invoice word "eenmalig". 17 characters. |
| iphone.6.s | Eén aankoop voor alle drie, zonder account of abonnement. | One purchase for all three, without account or subscription. | "zonder … of …" is how Dutch says neither one nor the other; "account" is the word the app and the store description use. |
| mac.1.k | Eén keer geschreven, voor iedereen. | One time written, for everyone. | Opens like iPhone frame 1, so both stores say it the same way. |
| mac.1.h *built* | Hoi [Thijs], ik verstuur je [Plus]pakket [dinsdag]. | Hi [Thijs], I send your [Plus]package [Tuesday]. | From `mac_reply` with mac_name, the better plan and the weekday; the drawn form's preview reads "Pluspakket". |
| mac.1.s | Kies het antwoord met {cmd}, vul een kort formulier in en Cutling plakt het. | Choose the reply with ⌘⇧V, fill a short form in and Cutling pastes it. | The three steps in the order they happen; "plakt" is the app's Paste. "een kort formulier" stays on one line. |
| mac.2.k | Waar je ook typt. | Where you also type. | "waar … ook" is the Dutch "wherever". |
| mac.2.h | {cmd} | ⌘⇧V | As the brief gives it. |
| mac.2.s | Je cutlings en wat je laatst kopieerde, verschijnen boven elke app. | Your cutlings and what you last copied appear above every app. | "wat je laatst kopieerde" is the app's own Dutch label for the clipboard; the comma stands between the two finite verbs (kopieerde, verschijnen). |
| mac.3.k | Klembordgeschiedenis zonder | Clipboard history without | The row of dots reads as the object of "zonder": clipboard history without the password. "Klembordgeschiedenis" is the app's word. |
| mac.3.s | Wat een wachtwoordbeheerder als vertrouwelijk markeert, komt er nooit in. | What a password manager as confidential marks, comes there never in. | The app's setting and the Dutch store description already say "wat een wachtwoordbeheerder als vertrouwelijk markeert" and "komen er nooit in"; "er" points back to the history in the kicker. |
| mac.4.k | Verander iets op je Mac, | Change something on your Mac, | Imperative, comma, then "dan": the Dutch "do this, then that" sentence. |
| mac.4.h | dan verandert het ook op je [iPhone]. | then changes it also on your [iPhone]. | The chip is on iPhone, as the brief asks. |
| mac.4.s | Alles synchroniseert via je eigen iCloud: geen account nodig. | Everything synchronises via your own iCloud: no account needed. | "synchroniseren via je eigen iCloud" as the app says it; "geen account nodig" is the store description's phrase. It replaced "zonder een account aan te maken", whose unstated subject would have been "Alles". "geen account nodig" stays on one line. |
| mac.5.k | Voor iPhone, iPad en Mac. | For iPhone, iPad and Mac. | Same as iphone.6. |
| mac.5.h | [Eén keer] betalen. | [One time] pay. | Same as iphone.6. |
| mac.5.s | Eén aankoop voor alle drie, zonder account of abonnement. | One purchase for all three, without account or subscription. | Same as iphone.6. |
