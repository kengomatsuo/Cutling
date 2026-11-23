# sv (Swedish): Cutling 2.0 store frames, direction C (card ASG167)

Written blind from `C-words-brief.md` and the `sv` entry of `locale-facts.json`; the words file is
`fastlane/compose/creative/v2/words/sv.json`. Register: du, the form the Swedish store page and the app already use,
kept in every line. The product word is "cutling", plural "cutlings", lowercase inside a sentence as the app writes it;
a blank is "fält", the app's own word. Square brackets mark the green chips. ` ` in the JSON is a no-break space:
besides "5 000" it holds five subline phrases together ("ett tryck bort", "den dag", "i alla appar", "ett helt mejl",
"utan abonnemang") so no iPhone or Mac line ends on an article or a preposition. Rendered at store size with the
repo's C build (`python3 build.py sv C`) on 2026-11-23 and checked frame by frame: nothing clipped on iPhone, iPad or
Mac, every chip on one line, every subline broken between phrases.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | Elin | Elin (woman's name) | A common Swedish woman's name among adult customers; frame 1's customer. |
| cseed.names[1] | Johan | Johan (man's name) | A common Swedish man's name; frame 2's customer. |
| cseed.names[2] | Sara | Sara (woman's name) | A common Swedish woman's name; the third key on the keyboard. |
| cseed.mac_name | Nils | Nils (man's name) | A short name no reader takes for anything but Swedish; the Mac form's customer. |
| cseed.reply | Hej {name}! Ditt paket skickas på {date}. | Hi {name}! Your parcel is-sent on {date}. | "På tisdag" is how Swedish says "on (this coming) Tuesday", so the app's bare lowercase "tisdag" goes in unchanged. "Paket" (parcel) is warmer than "order", and "beställning" ran past 40 characters. Filled: 39 characters with Elin, 40 with Johan. |
| cseed.reply_name | Skickas snart | Is-sent soon | The name a shop owner would give this reply; it also titles the Mac form, so it fits both replies. |
| cseed.mac_reply | Hej {name}! Ditt {plan}-paket skickas på {date}. | Hi {name}! Your {plan}-package is-sent on {date}. | Swedish joins the plan to its noun as one compound, with a hyphen because the first part is a name ("Premium-paket"); the chip ends cleanly at the hyphen. 47 characters filled. |
| cseed.name_label | Namn | Name | The plain word for a person's name. |
| cseed.plan_label | Paket | Package | Swedish sellers sell tiers as "paket" (baspaket, premiumpaket); the Mac reply builds on the same word. |
| cseed.plan_choices[0] | Bas | Basic | The pair the Swedish store page's 2.0 release notes already give as their example ("till exempel Bas och Premium"). |
| cseed.plan_choices[1] | Premium | Premium | As above; a loanword in everyday Swedish use. |
| cseed.delivered | Levererat den {date}. | Delivered the {date}. | The neuter participle Swedish uses for a bare status, as on a stamped "Betalt"; "den" before a date is how a Swedish sentence states one. |
| cseed.delivered_name | Leveransbesked | Delivery notice | The compound a Swedish shop would use for a note telling a customer about delivery. |
| C.iphone.1.k | Skrivet en enda gång. | Written one single time. | The neuter participle agrees with "svaret" (the reply) shown under it; "en enda gång" stresses "only once". 21 characters. |
| C.iphone.1.h (built) | Hej [Elin]! Ditt paket skickas på [tisdag]. | Hi [Elin]! Your parcel is-sent on [Tuesday]. | Built from cseed.reply. |
| C.iphone.1.s | Tryck på ditt sparade svar, så frågar Cutling efter namnet. | Tap on your saved reply, so asks Cutling for the-name. | An imperative followed by "så" is the everyday Swedish way to say "do this and that happens", with a comma before "så". 59 characters. |
| C.iphone.2.k | Samma svar, nästa kund. | Same reply, next customer. | Two short noun phrases that answer frame 1's kicker beside it. |
| C.iphone.2.h (built) | Hej [Johan]! Ditt paket skickas på [tisdag]. | Hi [Johan]! Your parcel is-sent on [Tuesday]. | Built from cseed.reply. |
| C.iphone.2.s | Namnen du använt förut väntar som knappar, ett tryck bort. | The-names you used before wait as buttons, one tap away. | "Ett tryck bort" (one tap away) is the phrase the Swedish store description already uses; "har" is left out of "du (har) använt", as written Swedish does in a subordinate clause. |
| C.iphone.3.k | Datumet fyller Cutling i själv. | The-date fills Cutling in itself. | Putting the object first opens on the frame's subject, the date, which is ordinary Swedish word order; "fylla i" is the app's own verb ("Fylls i vid användning"). |
| C.iphone.3.h (built) | Levererat den [23 november 2026]. | Delivered the [23 November 2026]. | Built from cseed.delivered. |
| C.iphone.3.s | I dag, i morgon eller om en vecka, alltid rätt den dag du klistrar in. | Today, tomorrow or in a week, always right the day you paste in. | "I morgon" and "om en vecka" are the app's own labels for these dates; "i dag" is written as two words to match "i morgon" in the same line (the app's label writes "Idag"). |
| C.iphone.4.k | Och det som aldrig ändras. | And that which never changes. | It ends on a full stop so the capitalised headline also reads alone at thumbnail size; the possessives in the chips carry "about you". |
| C.iphone.4.h | [Ditt kontonummer], [din adress] och [din signatur]. | [Your account-number], [your address] and [your signature]. | "Kontonummer" is the everyday Swedish word for a bank account number; "signatur" is the Swedish word for a mail sign-off (the store page lists "mejlsignaturer"); no comma before "och", as Swedish lists go. 46 characters. |
| C.iphone.4.s | Ett tryck var på Cutling-tangentbordet, i alla appar. | One tap each on the Cutling-keyboard, in all apps. | "Cutling-tangentbordet" is the app's own name for its keyboard; "i alla appar" over "i vilken app som helst" to stay under 60. 53 characters. |
| C.iphone.5.k | Allt får plats. | Everything gets room. | The idiomatic Swedish "it all fits". |
| C.iphone.5.h | [5 000] cutlings. | [5,000] cutlings. | The number exactly as the facts write it; "cutlings" lowercase, as the app writes the plural inside a sentence ("Sök cutlings", "%lld cutlings totalt"), never "cutlingar". |
| C.iphone.5.s | Förut var det 100, och varje cutling rymmer ett helt mejl. | Before was it 100, and every cutling holds a whole mail. | "Mejl" is the spelling the Swedish store page uses; "rymmer" (holds) is the plain verb for how much fits. |
| C.iphone.6.k | För iPhone, iPad och Mac. | For iPhone, iPad and Mac. | The device names as Apple writes them. |
| C.iphone.6.h | Betala [en gång]. | Pay [one time]. | An imperative with the chip on "en gång" (once). 15 characters. |
| C.iphone.6.s | Ett köp gäller alla tre, utan konto och utan abonnemang. | One purchase applies-to all three, without account and without subscription. | "Abonnemang" is the Swedish word for a subscription you keep paying for; "utan konto" echoes the app's own "Inget konto". |
| C.mac.1.k | Skriv en gång, skicka till alla. | Write one time, send to all. | Two imperatives joined by a comma. |
| C.mac.1.h (built) | Hej [Nils]! Ditt [Premium]-paket skickas på [tisdag]. | Hi [Nils]! Your [Premium]-package is-sent on [Tuesday]. | Built from cseed.mac_reply. |
| C.mac.1.s | Välj svaret med {cmd}: ett kort formulär frågar efter fälten innan det klistras in. | Choose the-reply with ⌘⇧V: a short form asks for the-fields before it is-pasted in. | "Fält" is the app's own word for blanks ("Fält och datum"); the colon keeps it one sentence and keeps "ett kort formulär" whole on the Mac line, where "så frågar ett kort / formulär" split the noun from its adjective; "det" agrees with "svaret". |
| C.mac.2.k | Var du än skriver. | Wherever you write. | "Var du än" is the Swedish "wherever you". |
| C.mac.2.h | {cmd} | ⌘⇧V | Fixed by the brief. |
| C.mac.2.s | Dina cutlings och det du senast kopierade öppnas ovanpå vilken app som helst. | Your cutlings and what you last copied open on-top-of which app as ever. | "Ovanpå" (on top of) is how Swedish puts a window over an app; "vilken app som helst" is the phrase the Swedish promotional text uses. |
| C.mac.3.k | Urklippshistoriken hoppar över | The-clipboard-history skips | "Hoppar över" (skips) is the verb the Swedish store description already uses for this feature; the row of dots is its object. |
| C.mac.3.s | Allt som en lösenordshanterare döljer hamnar aldrig i historiken. | Everything that a password-manager hides ends-up never in the-history. | "Döljer" (hides) is the buyer's word for "marks as hidden". |
| C.mac.4.k | Ändra något på din Mac, | Change something on your Mac, | Kicker and headline make one Swedish "do this, så that" sentence, so the kicker ends on a comma. |
| C.mac.4.h | så ändras det på din [iPhone]. | so changes it on your [iPhone]. | A lowercase "så" carries on the kicker's sentence. |
| C.mac.4.s | Det synkas via din egen iCloud, och du behöver inget konto. | It is-synced via your own iCloud, and you need no account. | "Din egen iCloud" is the app's own wording ("Cutlings synkas bara via din egen iCloud"). |
| C.mac.5.k | För iPhone, iPad och Mac. | For iPhone, iPad and Mac. | Same words as iPhone 6. |
| C.mac.5.h | Betala [en gång]. | Pay [one time]. | Same words as iPhone 6. |
| C.mac.5.s | Ett köp gäller alla tre, utan konto och utan abonnemang. | One purchase applies-to all three, without account and without subscription. | Same words as iPhone 6. |
