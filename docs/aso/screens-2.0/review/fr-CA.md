# fr-CA: words for the 2.0 store frames, direction C (ASG167)

Written from `C-words-brief.md` and the `fr-CA` entry of `locale-facts.json`, into
`fastlane/compose/creative/v2/words/fr-CA.json`.

**Register: tutoiement in every line.** The fr-CA listings of Transit, Chrono, Fizz Wi-Fi, Gboard and SwiftKey all
say "vous". On December 1, though, every other text on Cutling's own fr-CA page says "tu": the 2.0 In-App Event, What's
New, the description, and the app screens shown inside these frames (the keyboard's "Taper sur ton clavier habituel",
the setup guide's "Essaie"). The fr-CA onboarding strings record the same choice ("Tutoiement as in the locale's
existing strings"), so frames in "vous" would be the only "vous" text on the page. Quebec typography (OQLF): no space
before ! ? ;, a no-break space before :, typographic apostrophes, no long dashes. A no-break space also keeps a
possessive or a short word off the end of a line where the render showed one stranded there.

## The seed (`cseed`)

| Key | String | Back-translation | Choice |
|---|---|---|---|
| names | Léa, Félix, Maude | Léa, Félix, Maude | Quebec birth registry (Données Québec, 1980 to 2025): Léa ranked 1st (2013), Félix 4th at best, Maude 2nd at best; customers in their 20s and 30s, two women and a man |
| mac_name | Simon | Simon | Ranked 5th in 1986, so a customer in his 40s; evens the genders |
| reply | Bonjour {name}, ta commande part {date}! | Hello {name}, your order leaves {date}! | French puts no preposition before a weekday, so "part mardi" takes the word as given; "ta" because a small Quebec shop greeting a customer by first name commonly says tu; the "!" carries the warmth and sits against the word, as Quebec sets it; 36 to 38 characters filled |
| reply_name | Expédition | Shipping | One word a shop owner would file this reply under |
| mac_reply | Bonjour {name}, ta commande {plan} part {date}! | Hello {name}, your {plan} order leaves {date}! | The plan follows the noun, as a tier name does; 42 characters with Pro, 46 with De base |
| name_label | Prénom | First name | "Nom" also reads as surname, and the greeting takes the first name |
| plan_label | Forfait | Plan (package) | The Quebec word for a plan you buy (phone, service); the app's own choice blank is "forfait" |
| plan_choices | De base, Pro | Basic, Pro | The pair the fr-CA 2.0 What's New gives as its example |
| delivered | Livré le {date} | Delivered on {date} | A status line; masculine because it stands for the parcel (le colis) |
| delivered_name | Livraison | Delivery | The noun a note like this is filed under |

## The words (`C`)

| Key | String | Back-translation | Choice |
|---|---|---|---|
| iphone.1.k | Écrite une seule fois. | Written only once. | The feminine participle agrees with the reply (la réponse) the headline shows, so no pronoun is needed; 22 of 24 |
| iphone.1.s | Touche la réponse et Cutling te demande d’abord le prénom. | Tap the reply and Cutling first asks you for the first name. | "Toucher" is Apple's fr-CA verb for tap; "d’abord" gives the order of events and fills the second line (the render left "le prénom." alone without it); 58 of 60 |
| iphone.2.k | La même, au client suivant. | The same one, to the next customer. | "client" is masculine to match Félix in this frame's headline |
| iphone.2.s | Les prénoms déjà utilisés t’attendent, chacun sur sa touche. | The first names already used are waiting for you, each on its key. | "chacun sur sa touche" is the one-tap key; no-break spaces keep "sur sa touche" together |
| iphone.3.k | La date s’écrit toute seule. | The date writes itself. | The everyday idiom "ça s’écrit tout seul" |
| iphone.3.s | Aujourd’hui, demain ou dans une semaine, selon le jour où tu colles. | Today, tomorrow or in a week, depending on the day you paste. | The app's own option names (Aujourd’hui, Demain, Dans une semaine); "selon le jour où tu colles" says the date is worked out on the day of pasting |
| iphone.4.k | Et ce qui ne change jamais : | And what never changes: | No-break space before the colon (OQLF); runs into the headline as one sentence |
| iphone.4.h | ton [numéro de compte], ton [adresse], ta [signature]. | your [account number], your [address], your [signature]. | "ton adresse", since "ta" becomes "ton" before a vowel; "signature" as the app's own cutling says it (Signature de courriel); no-break spaces keep each possessive with its noun, so the render reads "ton numéro de compte, / ton adresse, / ta signature." with no "ton" or "ta" left at a line end; 48 of 50 |
| iphone.4.s | Une touche chacun, dans toutes tes apps, au clavier Cutling. | One tap each, in all your apps, from the Cutling keyboard. | "chacun" (masculine plural) covers the mixed-gender trio; "au clavier Cutling" as the fr-CA site says it; 60 of 60 |
| iphone.5.k | De la place pour tout. | Room for everything. | Plain and whole on its own |
| iphone.5.h | [5 000] cutlings | [5,000] cutlings | The number exactly as `n5000` gives it (no-break space); lowercase "cutlings" in running text, as the app's "Rechercher des cutlings" |
| iphone.5.s | Au lieu de 100, et chacun peut contenir un courriel entier. | Instead of 100, and each one can hold an entire email. | "courriel", the Quebec (OQLF) word the app and listing already use |
| iphone.6.k | iPhone, iPad et Mac. | iPhone, iPad and Mac. | No comma before "et" |
| iphone.6.h | Tu paies [une fois]. | You pay [once]. | The buyer's own sentence with the chip on "once"; "Paiement unique" (one-time payment) also fits but is a label; 18 of 18 |
| iphone.6.s | Un seul achat pour les trois, sans compte à créer ni abonnement. | One single purchase for the three, with no account to create and no subscription. | "abonnement" already means paying again and again, and "à payer" would echo "paies" just above |
| mac.1.k | Écrite une fois, envoyée à tous. | Written once, sent to everyone. | The same participle as iPhone 1, so both devices open on one idea |
| mac.1.s | Choisis la réponse avec {cmd} : un petit formulaire te demande ce qui change. | Pick the reply with ⌘⇧V: a short form asks you what changes. | "ce qui change" is how the fr-CA What's New names a blank; "before it pastes" is left to the form's Coller button in the picture, because with it the line ran to three |
| mac.2.k | Partout où tu écris. | Wherever you write. | "écrire" rather than "taper", which in a keyboard app also means pressing keys |
| mac.2.h | {cmd} | ⌘⇧V | As the brief fixes it |
| mac.2.s | Tes cutlings et ce que tu viens de copier, par‑dessus n’importe quelle app. | Your cutlings and what you just copied, on top of any app. | A non-breaking hyphen in "par‑dessus": at this width it broke as "par- / dessus" |
| mac.3.k | Ton historique laisse de côté | Your history leaves out | The dots below read as its object; "Historique" is the picker's own tab; "laisser de côté" is the verb the fr-CA site and description use for this fact |
| mac.3.s | Ce que ton gestionnaire de mots de passe masque n’y entre jamais. | What your password manager hides never gets in there. | "n’y" points back to the history in the kicker |
| mac.4.k | Modifie un cutling sur ton Mac, | Edit a cutling on your Mac, | "modifier" is the app's verb for editing; "change-le" could read as "replace it" |
| mac.4.h | il est à jour sur ton [iPhone]. | it is up to date on your [iPhone]. | "à jour" is how French says a copy is in sync; no-break spaces keep "sur ton iPhone" on one line |
| mac.4.s | Synchronisé par ton propre iCloud, sans compte à créer. | Synced through your own iCloud, with no account to create. | Agrees with "cutling" in the kicker |
| mac.5.k | iPhone, iPad et Mac. | iPhone, iPad and Mac. | Same as iPhone 6, as the brief allows |
| mac.5.h | Tu paies [une fois]. | You pay [once]. | Same as iPhone 6 |
| mac.5.s | Un seul achat pour les trois, sans compte à créer ni abonnement. | One single purchase for the three, with no account to create and no subscription. | Same as iPhone 6 |

## Headlines the build makes from the seed

| Frame | Headline | Characters |
|---|---|---|
| iPhone 1 | Bonjour [Léa], ta commande part [mardi]! | 36 |
| iPhone 2 | Bonjour [Félix], ta commande part [mardi]! | 38 |
| iPhone 3 | Livré le [23 novembre 2026] | 25 |
| Mac 1 | Bonjour [Simon], ta commande [Pro] part [mardi]! | 42 |
