# no (Norwegian Bokmål): words for the 2.0 store frames, direction C

Written from `C-words-brief.md` and the `no` entry of `locale-facts.json`; the file is
`fastlane/compose/creative/v2/words/no.json`. The buyer is "du", addressed with imperatives in sentence case, as Norwegian
App Store listings and Cutling's own Norwegian strings do ("Lagre det du skriver igjen og igjen"). Product names stay bare
in these heading-like lines, as Apple's Norwegian headings write them. "Cutlings" is the app's plural (`product_terms`;
"Søk i cutlings" on the Mac), lowercase inside a line. "én" and "ett" mark the number one. A subordinate clause inside a
main clause takes a comma after it. No dashes or quotation marks were needed. Rows marked *built* are made by the build
from the seed and are shown so the finished headline can be read. Rendered on iPhone, iPad and Mac, every frame fits;
Mac 4 was shortened once (see its row).

| Key | Norwegian | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names | Ida, Lars, Nora | Ida, Lars, Nora | SSB table 10501, 2025: Lars 28,943 men (5th), Ida 20,093 women (9th), Nora 13,125 women (32nd); four letters at most, so the reply stays inside 40 characters. |
| cseed.mac_name | Emil | Emil | SSB 2025: 13,738 men (39th), a younger man's name beside Lars. |
| cseed.reply | Hei, {name}! Pakken din sendes på {date}. | Hi, {name}! The parcel your is sent on {date}. | "på tirsdag" is how Bokmål names the coming Tuesday, so the app's bare "tirsdag" reads as grammar; comma after "Hei" and "!" after the name as in Språkrådet's own example "Hei, Målfrid!", the "!" for warmth. 39 to 40 characters filled. |
| cseed.reply_name | Pakken sendes | The parcel is sent | Named after what it says, the way an owner labels a saved reply; it also heads the Mac form. |
| cseed.mac_reply | Hei, {name}! {plan}-pakken din sendes på {date}. | Hi, {name}! The {plan} package your is sent on {date}. | "pakke" is both the tier sold and the parcel shipped, so one word carries the plan; hyphen because the first part is a name. 48 characters filled. |
| cseed.name_label | Navn | Name | The app's own word for Name. |
| cseed.plan_label | Pakke | Package | Norwegian sellers call a tier a "pakke"; "abonnement" left out, since frame 6 sells no subscription. |
| cseed.plan_choices | Basis, Premium | Basic, Premium | The pair the app's own Norwegian 2.0 release notes give as the example ("Basis eller Premium"). |
| cseed.delivered | Pakken din ble levert {date}. | The parcel your was delivered {date}. | No "den" before the date, the plain written form. 23 characters without the date. |
| cseed.delivered_name | Pakke levert | Parcel delivered | Two words, as the owner would label it. |
| iphone.1.k | Skrevet bare én gang. | Written only one time. | A participle line, as Norwegian ads write them; "én" carries the accent that marks the number. 21/24. |
| iphone.1.h *built* | Hei, [Ida]! Pakken din sendes på [tirsdag]. | Hi, [Ida]! The parcel your is sent on [Tuesday]. | Built from the seed. |
| iphone.1.s | Trykk på svaret, så spør Cutling om navnet. | Tap on the reply, so asks Cutling about the name. | "Trykk på …, så …" is the app's own pattern ("Trykk på en cutling, så skrives den der du skriver"). 43/60. |
| iphone.2.k | Samme svar, neste kunde. | Same reply, next customer. | Answers frame 1's line; side by side they read as written once, used again. |
| iphone.2.h *built* | Hei, [Lars]! Pakken din sendes på [tirsdag]. | Hi, [Lars]! The parcel your is sent on [Tuesday]. | Built from the seed. |
| iphone.2.s | Navnene du har brukt før, ligger klare som egne taster. | The names you have used before lie ready as own keys. | "ligger klare" is "waiting"; a relative clause inside the main clause takes a comma after it (Store norske leksikon, "Kommaregler"). |
| iphone.3.k | Cutling fyller inn datoen selv. | Cutling fills in the date itself. | "selv" is "by itself". |
| iphone.3.h *built* | Pakken din ble levert [23. november 2026]. | The parcel your was delivered [23. November 2026]. | Built from the seed with the facts' long date. |
| iphone.3.s | Velg i dag, i morgen eller om en uke, og datoen stemmer når du limer inn. | Choose today, tomorrow or in a week, and the date is right when you paste in. | "I dag", "I morgen" and "Om en uke" are the app's own menu items; one sentence with no colon, so no capital-after-colon question. |
| iphone.4.k | Og det som aldri endrer seg: | And that which never changes itself: | Leads into the list, which therefore starts in lowercase. 28/34. |
| iphone.4.h | [ditt kontonummer], [din adresse] og [din signatur]. | [your account number], [your address] and [your signature]. | "kontonummer" is the Norwegian name for a bank account number and "Signatur" is the iOS Mail setting's name; possessive first stresses "yours" and keeps the longest chip at 16 letters ("kontonummeret ditt … signaturen din" ran to 51). 46/50. |
| iphone.4.s | Ett trykk hver på Cutling-tastaturet, i alle apper. | One tap each on the Cutling keyboard, in all apps. | "Cutling-tastaturet" and "i alle apper" are the app's words. 51/60. |
| iphone.5.k | Det er plass til alt. | There is room for everything. | Plain statement; the app's own screens say "Plass til" ("Room for"). |
| iphone.5.h | [5 000] cutlings. | [5,000] cutlings. | The facts' number with its no-break space; the app's plural, lowercase mid-line as in "Søk i cutlings". |
| iphone.5.s | Før var grensen 100, og hver av dem rommer en hel e-post. | Before was the limit 100, and each of them holds a whole email. | "rommer" is "holds"; comma before "og" because it joins two main clauses. |
| iphone.6.k | På iPhone, iPad og Mac. | On iPhone, iPad and Mac. | Bare names, as Apple's Norwegian headings write them ("Endre innstillingene for Mail på iPhone"). |
| iphone.6.h | Betal [én gang]. | Pay [one time]. | Chip on "én gang", the word for once. 14/18. |
| iphone.6.s | Ett kjøp dekker alle tre, uten konto og uten abonnement. | One purchase covers all three, without account and without subscription. | "uten" said twice for weight. |
| mac.1.k | Skriv én gang, send til alle. | Write one time, send to all. | Two short imperatives joined by a comma, as Norwegian slogans run. |
| mac.1.h *built* | Hei, [Emil]! [Premium]-pakken din sendes på [tirsdag]. | Hi, [Emil]! The [Premium] package your is sent on [Tuesday]. | Built from the seed; the chip and "-pakken" stay on one line in the render. |
| mac.1.s | Velg svaret med {cmd}, fyll ut feltene i et kort skjema, og det limes inn. | Choose the reply with ⌘⇧V, fill out the fields in a short form, and it is pasted in. | "felt" is the app's word for a blank ("Felt og datoer"); told as the buyer's three steps. |
| mac.2.k | Uansett hvor du skriver. | Regardless where you write. | "Uansett hvor" is the everyday "wherever". |
| mac.2.h | {cmd} | ⌘⇧V | As the brief fixes it. |
| mac.2.s | Cutlingene dine og det du har kopiert nylig, åpnes over alle apper. | The cutlings your and what you have copied recently, open over all apps. | Definite plural as the app writes it ("Synkroniser cutlingene dine"); comma after the relative clause before the verb. |
| mac.3.k | Cutling husker alt du kopierer, unntatt | Cutling remembers everything you copy, except | Ends on "unntatt" so the dots below read as what is left out. |
| mac.3.s | Det en passordbehandler markerer som skjult, havner aldri i loggen. | What a password manager marks as hidden, ends up never in the history. | "Logg" is the tab name in the Norwegian capture beside it; "passordbehandler" is the store listing's word. |
| mac.4.k | Endrer du noe på Mac, | Change you something on Mac, | Verb-first conditional, the everyday Norwegian "if you change". |
| mac.4.h | endres det på [iPhone]. | is changed it on [iPhone]. | "Endrer … endres" mirror each other; "også" (too) was cut after the render, because "endres det også på" filled the column and touched the settings window. |
| mac.4.s | Alt synkroniseres via din egen iCloud, og du slipper å opprette konto. | Everything is synced via your own iCloud, and you escape to create account. | "via din egen iCloud" is the app's phrase; "slipper å" is "don't have to". |
| mac.5.k | På iPhone, iPad og Mac. | On iPhone, iPad and Mac. | Same as iphone.6. |
| mac.5.h | Betal [én gang]. | Pay [one time]. | Same as iphone.6. |
| mac.5.s | Ett kjøp dekker alle tre, uten konto og uten abonnement. | One purchase covers all three, without account and without subscription. | Same as iphone.6. |
