# Italian (it): words for the 2.0 store frames, direction C

Written from `C-words-brief.md` and the `it` entry of `locale-facts.json`, never from another language's words.
Words file: `fastlane/compose/creative/v2/words/it.json`.

- **Register:** informal *tu* in every line, as Cutling's Italian listing and app already speak ("Tieni…", "Scrivi con
  la solita tastiera").
- **Product word:** `cutling`, lowercase in running text, invariable in the plural and masculine, as the app's Italian
  sentences write it ("i tuoi cutling", "Cerca cutling"). The facts' "Cutling" is the standalone label form.
- **No-break spaces** (` ` in the JSON) hold "il tuo" together in both replies and keep each multi-word chip on
  one line ("il tuo indirizzo", "una volta"). Without them the iPhone frame 1 ended a headline line on "il" and the
  chips of frames 4 and 6 split in two.
- **Checked:** `check_words.py it` passes. iPhone and Mac frames were rendered through `build.py`'s direction C and
  looked at. iPad was not rendered. It uses the same words in a wider column, which holds about 69 characters of
  subline (an estimate scaled from the iPhone render), and no iPhone subline is longer than 61.

## Strings

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names | `Sara`, `Marco`, `Giulia` | Sara, Marco, Giulia | Common first names among Italian adults who shop online, two women and a man. The first two have at most 5 letters, so the filled reply stays within 40 ("Marco" makes exactly 40). |
| cseed.mac_name | `Luca` | Luca | A fourth common name, male, so the Mac shows a different customer. |
| cseed.reply | `Ciao {name}, il tuo ordine parte {date}!` | Hi {name}, your order leaves {date}! | "Parte" in the present tense is how Italians announce a shipment that is already scheduled. The weekday stays bare ("parte martedì"), which means this coming Tuesday. "Ciao Sara," is the usual chat greeting, and the "!" is the shop owner's warmth. |
| cseed.reply_name | `Spedizione` | Shipping | The word a shop owner would put on a saved message about shipping. One word. |
| cseed.mac_reply | `Ciao {name}, il tuo piano {plan} parte {date}!` | Hi {name}, your {plan} plan leaves {date}! | The same sentence as the iPhone reply with the plan added, so the two read as one shop. "Parte" covers both a box that ships and a plan that starts. Filled: 46 of 52. |
| cseed.name_label | `Nome` | Name | The app's own word for the name blank ("Name" = "Nome"). |
| cseed.plan_label | `Piano` | Plan | The word Italian buyers see for subscription tiers. The app's Italian release notes already use it ("il piano Base o Premium"). |
| cseed.plan_choices | `Base`, `Premium` | Basic, Premium | "Base" is the native word for the entry tier, and "Premium" is the loanword Italians use for the better one. Both are in the release notes. |
| cseed.delivered | `Pacco consegnato il {date}.` | Parcel delivered on {date}. | Italian puts the article before a day ("il 23 novembre"), so "il" sits before the blank. "Pacco" makes the note concrete. 21 of 28 characters. |
| cseed.delivered_name | `Consegna` | Delivery | The note's name in one word. |
| C.iphone.1.k | `La scrivi una volta sola` | You write it one time only | The "la" points at the reply below it, which is how Italian ads talk ("la scrivi, la usi"). 24 of 24, with no full stop because kickers carry none. |
| C.iphone.1.s | `Tocchi la risposta e Cutling ti chiede il nome.` | You tap the reply and Cutling asks you the name. | Present tense, second person, the way Italian describes a flow. I dropped "salvata" so the line fits one iPhone line instead of leaving "nome." alone on the second. |
| C.iphone.2.k | `Stessa risposta, altro cliente` | Same reply, other customer | A verbless pair, a shape Italian likes ("Stessa spiaggia, stesso mare"). It sits beside frame 1 as its other half. |
| C.iphone.2.s | `Trovi sulla tastiera i nomi già usati: ne tocchi uno e via.` | You find on the keyboard the names already used: you tap one of them and off [you go]. | "E via" is the spoken "and that's it". "Sulla tastiera" comes first so "usati sulla tastiera" can't be misread. |
| C.iphone.3.k | `Alle date ci pensa Cutling` | To the dates, Cutling sees to it | The native idiom for "Cutling handles the dates" (as in "al resto ci pensiamo noi"). |
| C.iphone.3.s | `Oggi, domani o tra una settimana, contando da quando incolli.` | Today, tomorrow or in a week, counting from when you paste. | "Tra una settimana" and "Domani" are the app's own labels. "Contando da quando incolli" says the date is worked out on the day you paste. |
| C.iphone.4.k | `E quello che non cambia mai` | And that which never changes | Leads into the list. "Di te" is left out because the possessives in the headline already say "yours". |
| C.iphone.4.h | `[Il tuo IBAN], [il tuo indirizzo] e [la tua firma].` | [Your IBAN], [your address] and [your signature]. | Italians call their bank account number the IBAN, and the Italian seed's note shows "IBAN: IT60…". "Firma" is the email sign-off ("Firma e-mail" in the seed). Each possessive stays inside its chip, joined by no-break spaces. 45 of 50. |
| C.iphone.4.s | `Un tocco sulla tastiera Cutling, in ogni app.` | One tap on the Cutling keyboard, in every app. | "Tastiera Cutling" is the app's name for its keyboard. Listed under three things, "un tocco" reads as one tap each, and it fits one line. |
| C.iphone.5.k | `C’è spazio per tutto` | There is room for everything | Plain spoken Italian with a typographic apostrophe. |
| C.iphone.5.h | `[5000] cutling.` | [5000] cutlings. | "5000" is written as the facts give it, and the Italian plural doesn't change. |
| C.iphone.5.s | `Prima erano 100, e ognuno può contenere un’email intera.` | Before they were 100, and each one can hold a whole email. | "Email" is feminine ("un’email"), as in the app's release notes. The comma before "e" is right because the two clauses have different subjects. |
| C.iphone.6.k | `iPhone, iPad e Mac` | iPhone, iPad and Mac | Italian writes "e" before the last item and no serial comma. |
| C.iphone.6.h | `Paghi [una volta].` | You pay [one time]. | "Una volta" is the everyday "once". "Una tantum" sounds like a tax. "una volta" is held together by a no-break space. 16 of 18. |
| C.iphone.6.s | `Per tutti e tre, senza account né abbonamento.` | For all three, without account nor subscription. | "Senza X né Y" is the native way to say "no X, no Y". Under "Paghi una volta", "per tutti e tre" says what that one payment covers. |
| C.mac.1.k | `La scrivi una volta, la mandi a tutti` | You write it one time, you send it to everyone | Echoes the iPhone kicker in the same *tu*. |
| C.mac.1.s | `Scegli la risposta con {cmd}: prima di incollarla, un breve modulo ti chiede cosa manca.` | You choose the reply with ⌘⇧V: before pasting it, a short form asks you what is missing. | "Cosa manca" is the buyer's way of saying "the blanks". "Modulo" is the Italian word for a form. |
| C.mac.2.k | `Ovunque tu stia scrivendo` | Wherever you may be writing | The subjunctive after "ovunque", as written Italian requires. |
| C.mac.2.h | `{cmd}` | ⌘⇧V | Fixed. |
| C.mac.2.s | `I tuoi cutling e le ultime cose che hai copiato compaiono sopra qualsiasi app.` | Your cutlings and the last things you have copied appear over any app. | "Compaiono" in place of "si aprono", so the line no longer breaks between "si" and its verb. |
| C.mac.3.k | `La cronologia ricorda tutto, tranne` | The history remembers everything, except | The dots under it read as what is left out. "Cronologia" is the tab name in the Mac app. |
| C.mac.3.s | `Quello che un gestore di password segna come nascosto non ci finisce mai.` | What a password manager marks as hidden never ends up there. | "Gestore di password" and "segna come nascosto" are the Mac app's own Italian setting text. "Ci" points back to the history. |
| C.mac.4.k | `Cambi qualcosa su Mac` | You change something on Mac | "Su Mac" with no article, as the app writes it ("anche su Mac"). |
| C.mac.4.h | `E lo ritrovi aggiornato su [iPhone].` | And you find it again updated on [iPhone]. | I chose this over "e cambia anche su iPhone" because that "cambia" also reads as an order ("change it on iPhone too"). |
| C.mac.4.s | `Si sincronizza con il tuo iCloud e non devi registrarti da nessuna parte.` | It syncs with your iCloud and you don't have to register anywhere. | "Non devi registrarti" says "no account to create" without repeating the "senza account" of the next frame. |
| C.mac.5.k | `iPhone, iPad e Mac` | iPhone, iPad and Mac | Same as iPhone 6. |
| C.mac.5.h | `Paghi [una volta].` | You pay [one time]. | Same as iPhone 6. |
| C.mac.5.s | `Per tutti e tre, senza account né abbonamento.` | For all three, without account nor subscription. | Same as iPhone 6. |

## What the build makes from the seed

| Frame | Headline as rendered | Literal back-translation |
|---|---|---|
| iPhone 1 | Ciao [Sara], il tuo ordine parte [martedì]! | Hi [Sara], your order leaves [Tuesday]! |
| iPhone 2 | Ciao [Marco], il tuo ordine parte [martedì]! | Hi [Marco], your order leaves [Tuesday]! |
| iPhone 3 | Pacco consegnato il [23 novembre 2026]. | Parcel delivered on [23 November 2026]. |
| Mac 1 | Ciao [Luca], il tuo piano [Premium] parte [martedì]! | Hi [Luca], your [Premium] plan leaves [Tuesday]! |
| Mac 3 | La cronologia ricorda tutto, tranne [••••••••••] | The history remembers everything, except [••••••••••] |
