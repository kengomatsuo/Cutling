# de-DE: words for the 2.0 store frames, review

Written from `C-words-brief.md` and the de-DE facts, into `fastlane/compose/creative/v2/words/de-DE.json`. Every line
says du, as Cutling's German listing and 2.0 release notes do; the shop owner says du to customers too, as small German
shops do once they use a first name. Rendered through direction C at App Store sizes (iPhone, iPad, Mac) before handing
over: nothing clips, the frame 1 and 2 headlines break on the same lines, no chip splits inside a word group, and no
subline strands a short word on its last line or breaks a compound at its hyphen.

| Key | String | Back-translation | Choice |
|---|---|---|---|
| cseed.names | `Lena`, `Jan`, `Anna` | Lena, Jan, Anna | Common names for German shoppers in their twenties and thirties, two women and a man; Jan over Jonas, which is wider than Lena and pushed frame 2's headline to five lines against frame 1's four. |
| cseed.mac_name | `Paul` | Paul | Short and common; a second man, so the four names split evenly. |
| cseed.reply | `Hi {name}, dein Paket geht {date} raus!` | Hi {name}, your parcel goes out {date}! | du with the first name; "Hi" over "Liebe/Lieber", which would need the name's gender; Duden gives "am" before a weekday as optional ("sie kommt [am] Dienstag"), so "geht Dienstag raus" is correct and stays at 39 characters where "am" makes 42. |
| cseed.reply_name | `Versandinfo` | Shipping info | One compound noun, 11 characters. |
| cseed.mac_reply | `Hi {name}, dein {plan}-Paket geht {date} raus!` | Hi {name}, your {plan} package goes out {date}! | Same voice as the iPhone reply; German joins a tier name to its noun with a hyphen ("Premium-Paket"), so the chip sits on the plan and "-Paket" follows; 47 of 52 filled. |
| cseed.name_label | `Name` | Name | The app's own German label for a name. |
| cseed.plan_label | `Paket` | Package | What German shops call a tier ("Basis-Paket", "Premium-Paket") and the word the reply uses; picked over the app's default "Tarif", which Germans use for phone and energy contracts. |
| cseed.plan_choices | `Basis`, `Premium` | Basic, Premium | The pair the German 2.0 release notes already give as their example. |
| cseed.delivered | `Zugestellt am {date}.` | Delivered on {date}. | The words German parcel tracking shows; 15 characters before the date. |
| cseed.delivered_name | `Zustellung` | Delivery | A noun, as a saved note's name. |
| C.iphone.1.k | `Einmal geschrieben` | Written once | An overline, set without a full stop as German overlines are; 18 of 24. |
| C.iphone.1.s | `Tippst du auf die Antwort, fragt Cutling nach dem Namen.` | If you tap the reply, Cutling asks for the name. | Verb-first "Tippst du …, fragt …" is everyday German for if-then; "Antwort" ties back to the headline; 56 of 60. |
| C.iphone.2.k | `Dieselbe Antwort, nächster Kunde` | The very same reply, next customer | "dieselbe" (the identical one) over "die gleiche" (one like it); "Kunde" fits Jan. |
| C.iphone.2.s | `Die Namen von früher warten schon als Tasten.` | The names from before are already waiting as keys. | "Namen von früher" as in the German release notes; "Tasten" already says one tap each. |
| C.iphone.3.k | `Das Datum schreibt Cutling selbst` | The date, Cutling writes itself | Object first for stress; singular "Datum" because the plural "Daten" also means data. |
| C.iphone.3.s | `Heute, morgen oder in einer Woche, gerechnet ab dem Einfügen.` | Today, tomorrow or in a week, counted from the pasting. | "gerechnet ab" says the date is worked out on the day you paste. |
| C.iphone.4.k | `Und was sich nie ändert` | And what never changes | Leads into the list without a colon, so the headline starts as its own capitalised line; 23 of 34. |
| C.iphone.4.h | `[Deine IBAN], [deine Adresse], [deine Signatur]` | Your IBAN, your address, your signature | "IBAN" is what Germans give as their account number; "Signatur" matches the app's "E-Mail-Signatur"; a no-break space inside each chip keeps every chip whole, one per line; 41 of 50. |
| C.iphone.4.s | `In jeder App reicht dafür ein Tipp auf der Cutling-Tastatur.` | In any app, one tap on the Cutling keyboard is enough for it. | "dafür" points back at each item; the line breaks before "Cutling-Tastatur" rather than at its hyphen; 60 of 60. |
| C.iphone.5.k | `Platz für alles` | Room for everything | The set phrase. |
| C.iphone.5.h | `[5.000] Cutlings` | 5,000 Cutlings | Number and plural exactly as the facts give them. |
| C.iphone.5.s | `Bisher waren es 100, und in jeden passt eine ganze E-Mail.` | Until now it was 100, and a whole email fits in each one. | "jeden" is masculine because the app says "der Cutling"; "passt in" is how German says something holds. |
| C.iphone.6.k | `iPhone, iPad und Mac` | iPhone, iPad and Mac | Product names without articles, as Apple writes them. |
| C.iphone.6.h | `[Einmal] zahlen` | Pay once | The infinitive slogan form German ads use; chip on "Einmal"; 13 of 18. |
| C.iphone.6.s | `Ein Kauf gilt für alle drei, und du brauchst weder Konto noch Abo.` | One purchase counts for all three, and you need neither an account nor a subscription. | "Abo" is the everyday word for a subscription; worded so "Abo." is not left alone on the iPhone's second line. |
| C.mac.1.k | `Einmal schreiben, an alle schicken` | Write once, send to everyone | Paired infinitives, as German slogans pair them. |
| C.mac.1.s | `Mit {cmd} wählst du die Antwort, ein kurzes Formular fragt erst die Platzhalter ab.` | With ⌘⇧V you choose the reply, a short form first asks for the placeholders. | "Platzhalter" is the app's German word for blanks; "erst" (first) carries "before it pastes" and keeps it to two lines, without "ab." alone on a third. |
| C.mac.2.k | `Überall, wo du tippst` | Everywhere you type | du-form. |
| C.mac.2.h | `{cmd}` | ⌘⇧V | As the brief sets it. |
| C.mac.2.s | `Deine Cutlings und das zuletzt Kopierte öffnen sich über jeder App.` | Your Cutlings and what you last copied open over any app. | "das zuletzt Kopierte" is the compact German for the last things copied; "über jeder App" is the dative of position. |
| C.mac.3.k | `Der Verlauf merkt sich alles außer` | The history remembers everything except | The password dots complete the sentence as the object of "außer"; "Verlauf" is the tab named in the picture below. |
| C.mac.3.s | `Was ein Passwortmanager als vertraulich markiert, landet nie im Verlauf.` | Whatever a password manager marks as confidential never lands in the history. | "vertraulich" and "Passwortmanager" as Cutling's German description already says. |
| C.mac.4.k | `Am Mac geändert` | Changed on the Mac | "am Mac" for the person working at it. |
| C.mac.4.h | `Auch auf dem [iPhone]` | On the iPhone too | The verb carries over from the kicker; "auf dem iPhone" for what is on the device. |
| C.mac.4.s | `Synchronisiert wird über deine eigene iCloud, ohne neues Konto.` | It syncs through your own iCloud, with no new account. | "deine iCloud" as the app's own German says; "ohne neues Konto" because iCloud is itself an account. |
| C.mac.5.k | `iPhone, iPad und Mac` | iPhone, iPad and Mac | Same as iPhone 6. |
| C.mac.5.h | `[Einmal] zahlen` | Pay once | Same as iPhone 6. |
| C.mac.5.s | `Ein Kauf gilt für alle drei, ohne Konto und ohne Abo.` | One purchase counts for all three, with no account and no subscription. | Shorter than iPhone 6's line, because it fits one line on the Mac. |

## For the build

- The long date needs a no-break space after the day ("23. November 2026"). German typesetting keeps day and month
  together; without it the frame 3 headline breaks "Zugestellt am 23." / "November 2026." on iPhone and iPad. Rendered
  with the space bound, it sets "Zugestellt am / 23. November / 2026." and "Zugestellt am / 23. November 2026.".
- The de-DE `01_KeyboardInMessages` captures (iPhone and iPad), under frame 4, are English: Maya's chat, "Bank
  Account", "Add from Clipboard". Frame 4 shows them under German words until they are shot in German.
