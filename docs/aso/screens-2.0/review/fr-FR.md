# fr-FR words for Cutling 2.0's store frames (card ASG167)

Words: `fastlane/compose/creative/v2/words/fr-FR.json`, written from `C-words-brief.md` and the fr-FR entry of `locale-facts.json`.

**Register: vous.** French listings for utilities and seller tools say vous (Paste, Gboard, Microsoft SwiftKey, WhatsApp Business and Shopify all do; Vinted, a peer-to-peer resale app, is the one that says tu). The live fr-FR description and the 1.x French captions say vous too. The drawn keyboard's own label (`Taper sur ton clavier habituel`, frames 1 and 2) and the iPhone 6 setup capture (`Essaie`, `Écris avec Cutling ici`) say tu, as the app's iOS strings and the fr-FR 2.0 release notes do.

**Typography.** A no-break space (U+00A0) sits before every colon. More no-break spaces keep the phrase after the colon or comma whole in seven sublines (`un toucher suffit.`, `dans toutes vos apps.`, `un e‑mail entier.`, `sans inscription ni abonnement.`, `remplissez les champs et c’est collé.`, `par‑dessus n’importe quelle app.`, `sans compte à créer.`), so every two-line subline breaks at its colon or comma. `e‑mail` and `par‑dessus` use a non-breaking hyphen (U+2011), since a plain hyphen is a line-break point. Apostrophes are ’. `5 000` is the facts file's own, with a narrow no-break space (U+202F). Rendered and checked on iPhone, iPad and Mac with `python3 build.py fr-FR C`.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | `Julie` | Julie | A very common first name among French women of the age that shops online; short and plainly French at thumbnail size. |
| cseed.names[1] | `Thomas` | Thomas | One of the most common French men's names in that generation, so frames 1 and 2 read as two different people. |
| cseed.names[2] | `Inès` | Inès | A common French girls' name across backgrounds; the key shows the accent as typed. |
| cseed.mac_name | `Karim` | Karim | A common French man's name of Maghrebi origin, so the four customers look like a French shop's. |
| cseed.reply | `Bonjour {name}, votre colis part {date}.` | Hello {name}, your parcel leaves {date}. | vous plus the first name, as French shops write to customers. "part mardi" takes no article or preposition, so the weekday drops in unchanged. "colis" over "commande", which made it 41 characters with Julie (now 38 and 39). |
| cseed.reply_name | `Expédition` | Dispatch | The one word a French seller files a shipping notice under. |
| cseed.mac_reply | `Bonjour {name}, votre coffret {plan} part {date}.` | Hello {name}, your {plan} gift-set leaves {date}. | "coffret" (gift set) over "box", which in France first means the internet router (Livebox, Freebox). 48 characters filled with Karim and Premium. |
| cseed.name_label | `Prénom` | First-name | The blank takes a first name, and French forms label that Prénom (Nom is the surname). |
| cseed.plan_label | `Formule` | Formula [the usual French word for a plan or tier] | French shops sell "formule Standard / formule Premium"; "forfait" reads as a phone plan. |
| cseed.plan_choices[0] | `Standard` | Standard | Used as is in France; Essentiel and Classique are nine letters. |
| cseed.plan_choices[1] | `Premium` | Premium | The loanword French shops use for the better tier. |
| cseed.delivered | `Colis livré le {date}` | Parcel delivered on-the {date} | Note style, with no "a été" and no full stop, as a seller logs it. "le 23 novembre 2026" is how French puts a date after a verb. |
| cseed.delivered_name | `Livraison` | Delivery | The plain name of that note. |
| C.iphone.1.k | `Écrivez-la une fois.` | Write [imperative, vous]-it [fem., the reply] one time. | Imperative vous, the voice of French store copy; "la" points to the reply set below it. |
| C.iphone.1.h (built) | `Bonjour [Julie], votre colis part [mardi].` | Hello Julie, your parcel leaves Tuesday. | Built from cseed.reply. "mardi" stays lowercase, as French writes weekdays. |
| C.iphone.1.s | `Touchez-la et Cutling vous demande le prénom.` | Tap [imperative, vous]-it and Cutling [to-]you asks the first-name. | "Touchez" is Apple's French verb for tap; "le prénom" matches the blank's label. Fits one line; the first wording ("Touchez la réponse et…") left "prénom." alone on a second line. |
| C.iphone.2.k | `Renvoyez-la au suivant.` | Send-again [vous]-it to-the next [one]. | "Au suivant" is what a French shopkeeper calls to the next customer; it pairs with frame 1's "Écrivez-la". |
| C.iphone.2.h (built) | `Bonjour [Thomas], votre colis part [mardi].` | Hello Thomas, your parcel leaves Tuesday. | Built from cseed.reply. |
| C.iphone.2.s | `Les prénoms déjà saisis vous attendent : un toucher suffit.` | The first-names already typed-in [to-]you wait: one tap suffices. | "saisis" (typed in) over "utilisés", which ran to 61 characters. "un toucher suffit" is the touch form of "un clic suffit", and the app already says "en un seul toucher". No-break spaces keep "un toucher suffit." whole, so the line breaks at the colon instead of "un / toucher". |
| C.iphone.3.k | `Les dates s’écrivent toutes seules.` | The dates write-themselves all alone. | "s'écrire tout seul" is the everyday French for a thing that does itself; Cutling is the one doing it. |
| C.iphone.3.h (built) | `Colis livré le [23 novembre 2026]` | Parcel delivered on 23 November 2026 | Built from cseed.delivered with today's long date from the facts file. |
| C.iphone.3.s | `Aujourd’hui, demain ou dans une semaine : toujours la bonne date.` | Today, tomorrow or in one week: always the right date. | The three time words are the app's own date items (Aujourd’hui, Demain, Dans une semaine), so the buyer finds them in the menu; "toujours la bonne date" says what they get on the day they paste. |
| C.iphone.4.k | `Et ce qui ne change jamais :` | And what not changes never: | Leads into h as one sentence. |
| C.iphone.4.h | `votre [RIB], votre [adresse], votre [signature].` | your bank-details [RIB], your address, your signature. | "RIB" is what a landlord, employer or friend asks for in France ("envoie-moi ton RIB"), and the 1.x French screenshots already say it; IBAN was the other choice. "signature" is French for an email sign-off. Lowercase after the colon. |
| C.iphone.4.s | `D’un toucher sur le clavier Cutling, dans toutes vos apps.` | With-one tap on the keyboard Cutling, in all your apps. | "Each one" is carried by the list above it. "dans toutes vos apps" over "dans n’importe quelle app", which ran to 63 characters. Breaks after the comma on iPhone; one line on iPad. |
| C.iphone.5.k | `De la place pour tout.` | Some room for everything. | Plain and short. |
| C.iphone.5.h | `[5 000] cutlings` | 5,000 cutlings | n5000 copied from the facts file, narrow no-break space included. "cutlings" is lowercase in running text, as the app's French release notes write it. |
| C.iphone.5.s | `Contre 100 avant, et chacun peut contenir un e‑mail entier.` | Against 100 before, and each-one can hold an e-mail whole. | "Contre 100 avant" is how French gives an old figure. "e-mail" as Apple France writes it, with a non-breaking hyphen and no-break spaces so the frame no longer splits it as "e- / mail". |
| C.iphone.6.k | `iPhone, iPad et Mac.` | iPhone, iPad and Mac. | Apple's product names, with no articles. |
| C.iphone.6.h | `Achat [unique].` | Purchase single [one-time]. | "Achat unique" is the French phrase for a one-time purchase, set against "abonnement" in French listings; the chip is on "unique", the "once" word. |
| C.iphone.6.s | `Valable sur les trois, sans inscription ni abonnement.` | Valid on the three, without sign-up nor subscription. | "Valable sur les trois" avoids saying "achat" twice; "sans inscription ni abonnement" is the set French phrase. No-break spaces make the line break after the comma. |
| C.mac.1.k | `Écrivez-la une fois, envoyez-la à tous.` | Write [vous]-it one time, send [vous]-it to all. | Same voice as iPhone 1, so both devices open the same way. |
| C.mac.1.h (built) | `Bonjour [Karim], votre coffret [Premium] part [mardi].` | Hello Karim, your Premium gift-set leaves Tuesday. | Built from cseed.mac_reply with the better plan. |
| C.mac.1.s | `Choisissez la réponse avec {cmd}, remplissez les champs et c’est collé.` | Choose the reply with ⌘⇧V, fill-in the fields and it-is pasted. | "champs" is the app's own word for blanks (Champs et dates). The form sits beside it, so "remplissez" says what the buyer does in it. Breaks after the comma. |
| C.mac.2.k | `Partout où vous écrivez.` | Everywhere where you write. | "écrire" over "taper", the everyday verb. |
| C.mac.2.h | `{cmd}` | ⌘⇧V | Fixed by the brief. |
| C.mac.2.s | `Vos cutlings et vos dernières copies, par‑dessus n’importe quelle app.` | Your cutlings and your last copies, on-top-of any app. | "copie" for a copied item, as Paste's French listing writes it ("Ne perdez plus jamais une copie"). Breaks after the comma. |
| C.mac.3.k | `L’historique du presse-papiers ignore` | The history of-the clipboard ignores | The row of dots reads as the object of "ignore", the verb the live French description already uses for this. |
| C.mac.3.s | `Ce qu’un gestionnaire de mots de passe masque n’y entre jamais.` | What a manager of passwords hides there never enters. | "y" points back to the history in the kicker; "masque" for "marks as hidden". |
| C.mac.4.k | `Modifié sur votre Mac,` | Changed on your Mac, | Participle headline style, symmetrical with h. |
| C.mac.4.h | `à jour sur votre [iPhone].` | up-to-date on your iPhone. | "à jour" is the French word for a synced copy; the chip is on iPhone. |
| C.mac.4.s | `Synchronisé via votre propre iCloud, sans compte à créer.` | Synced via your own iCloud, without account to create. | "propre" keeps "your own". No-break spaces keep "sans compte à créer" together after the comma. |
| C.mac.5.k | `iPhone, iPad et Mac.` | iPhone, iPad and Mac. | Same as iPhone 6. |
| C.mac.5.h | `Achat [unique].` | Purchase single [one-time]. | Same as iPhone 6. |
| C.mac.5.s | `Valable sur les trois, sans inscription ni abonnement.` | Valid on the three, without sign-up nor subscription. | Same as iPhone 6. |
