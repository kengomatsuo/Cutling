# Catalan (ca) words for the 2.0 screenshots: review

Written blind from `C-words-brief.md` and the `ca` entry of `locale-facts.json`, into
`fastlane/compose/creative/v2/words/ca.json`. Register: `tu` in every line, as 3Cat's Catalan App Store listing, Apple's
Catalan iOS and Cutling's own Catalan 2.0 release notes speak; the shop owner also uses `tu` with customers. Apostrophes
are typographic (’), as the app's Catalan strings write them; no dashes, no inverted ¡ (Catalan does not use it).

Rendered with direction C (`build.py`'s C set, iPhone, iPad and Mac): every line fits its frame. One fix came from the render:
`Pagues [un cop].` split its chip across two lines on iPhone and Mac, so the chip holds a non-breaking space.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names | Laia, Pau, Marta | Laia, Pau, Marta | Catalan first names with a mix of ages and genders: Laia (f, average age 22.7 in Idescat's 2025 Alt Penedès list), Pau (m, 17th among 2024 births in Catalonia), Marta (f, fifth among women in the same Alt Penedès list). |
| cseed.mac_name | Jordi | Jordi | First among men in Idescat's 2025 Alt Penedès list, ahead of José and Antonio. |
| cseed.reply | Hola, {name}! T’enviem la comanda {date}. | Hello, Laia! We-send-you the order Tuesday. | Filled: 40 characters with Laia, 39 with Pau. The weekday takes no article (it means "this coming Tuesday") and sits mid-sentence, so the lowercase `dimarts` Cutling types is correct. The comma between Hola and the name follows the UB and UOC style guides. `comanda` is the shop word for an order (Mango and Shopify in Catalan). |
| cseed.reply_name | Enviament | Shipping | One word. The Mac form shows it as the title of the Mac reply too, and both replies are about shipping. |
| cseed.mac_reply | Hola, {name}! La comanda del pla {plan} surt {date}. | Hello, Jordi! The order of-the plan Pro goes-out Tuesday. | Filled: 49 characters. `del pla {plan}` reads right with both choices (el pla Bàsic, el pla Pro, as the Catalan release notes already say); `la comanda Pro` would clash in gender with Bàsic. `surt` (goes out) is how shops say an order ships. |
| cseed.name_label | Nom | Name | The app's own word for Name. |
| cseed.plan_label | Pla | Plan | The word the Catalan release notes use for this choice. |
| cseed.plan_choices | Bàsic, Pro | Basic, Pro | The same pair as the release notes; Pro is used as it is. |
| cseed.delivered | Lliurat el {date}. | Delivered on-the 23 of November of-the 2026. | `lliurat` is the standard word: Correos' Catalan pages use only lliurar and lliurament ("Gestiona el lliurament de la teva tramesa", "se’t lliurarà al domicili"), never entregar, so it is picked over the colloquial `entregat`. Masculine by default (the parcel). A Catalan date takes `el`. 12 characters without the date. |
| cseed.delivered_name | Lliurament | Delivery | Pairs with Enviament; the noun Catalan shops use (terminis de lliurament). |
| C.iphone.1.k | L’escrius un sol cop. | You-write-it one single time. | Indicative `tu`, the voice of the release notes ("Escrius una resposta un sol cop"). `L’` points at the reply below it. 21/24. |
| C.iphone.1.s | Toques la resposta i Cutling et demana el nom. | You-tap the reply and Cutling asks-you-for the name. | Plain present for a routine; `demanar` is "ask for". Fits one line. |
| C.iphone.2.k | I l’envies al client següent. | And you-send-it to-the customer next. | Completes frame 1 as a pair (L’escrius… / I l’envies…). The elided `l’` keeps it from reading as "la comanda". |
| C.iphone.2.s | Els noms que ja has fet servir, els tens a un toc. | The names that already you-have used, them you-have at one tap. | A fronted object with the pronoun repeated, as Catalans say it; `fer servir` over the formal `utilitzar`; `a un toc` like `a un clic`. |
| C.iphone.3.k | La data s’escriu sola. | The date writes-itself alone. | `s’escriu sola` is the idiom for "writes itself". Singular, to match the one date in the headline. |
| C.iphone.3.s | Avui, demà o d’aquí a una setmana, i surt bé el dia que l’enganxes. | Today, tomorrow or from-here to one week, and it-comes-out right the day that you-paste-it. | `d’aquí a una setmana` is the correct "a week from now" (not `en una setmana`); `surt bé` is the release notes' wording. |
| C.iphone.4.k | I el que no canvia mai: | And what not changes ever: | Leads into the headline as one sentence; the colon opens the list. 23/34. |
| C.iphone.4.h | el teu [IBAN], la teva [adreça] i la teva [signatura]. | your IBAN, your address and your signature. | IBAN is what people in Spain call their account number, and the Catalan grid capture shows "IBAN: ES91…". `signatura` matches the app's "Signatura de correu". Catalan repeats the possessive for each item. 48/50. |
| C.iphone.4.s | Un toc al teclat de Cutling i ja hi és, a qualsevol app. | One tap on-the keyboard of Cutling and already there it-is, in any app. | `app`, as the Catalan listing already writes it ("a qualsevol app"). 56/60. |
| C.iphone.5.k | Hi cap tot. | There fits everything. | The everyday idiom for "there's room for all of it". |
| C.iphone.5.h | [5.000] cutlings | 5,000 cutlings | `n5000` as given. The product word is lowercase in running text, as the release notes and the app's "Cerca cutlings" write it; the facts' "Cutlings" is the title-case label. |
| C.iphone.5.s | Abans n’hi cabien 100, i cada un pot ser un correu sencer. | Before of-them-there fitted 100, and each one can be an email whole. | Same verb as the kicker (`cabre`); `un correu sencer` as in the release notes. |
| C.iphone.6.k | iPhone, iPad i Mac. | iPhone, iPad and Mac. | Names as Apple writes them. |
| C.iphone.6.h | Pagues [un cop]. | You-pay one time. | The buyer's own words. `un cop` has a non-breaking space (written `\u00a0` in the JSON), so the chip stays one block. 14/18. |
| C.iphone.6.s | Una sola compra per als tres, sense compte ni subscripció. | One single purchase for the three, without account nor subscription. | `sense compte` as the app says it ("Sense compte ni internet"). |
| C.mac.1.k | L’escrius un cop i l’envies a tothom. | You-write-it once and you-send-it to everyone. | Same voice as iPhone 1. |
| C.mac.1.s | Tries la resposta amb {cmd} i un formulari breu et demana el que falta abans d’enganxar. | You-pick the reply with ⌘⇧V and a form short asks-you what is-missing before pasting. | `el que falta` (what's missing) is the buyer's word for the blanks; `espais buits` is the app's term. |
| C.mac.2.k | Escriguis on escriguis. | You-write where you-write. | Catalan's repeated subjunctive for "wherever" (like `vagis on vagis`). |
| C.mac.2.h | {cmd} | ⌘⇧V | As the brief gives it. |
| C.mac.2.s | Els teus cutlings i el que has copiat fa poc s’obren sobre qualsevol app. | Your cutlings and what you-have copied a-little-ago open over any app. | `fa poc` (recently) for "the last things you copied". |
| C.mac.3.k | L’historial del porta-retalls no desa | The history of-the clipboard doesn't save | The dots read as the object: "doesn't save ••••". `desa` is the app's own verb ("Desa l’historial del porta-retalls"); `porta-retalls` keeps its hyphen. |
| C.mac.3.s | El que un gestor de contrasenyes marca com a ocult no hi entra mai. | What a manager of passwords marks as hidden not there enters ever. | The app's own phrasing ("marqui com a ocults"); `hi` means "into the history". |
| C.mac.4.k | Ho canvies al Mac | You-change-it on-the Mac | Runs into the headline with `i`, so no comma. |
| C.mac.4.h | i ja ho tens canviat a l’[iPhone]. | and already you-have-it changed on the iPhone. | `tenir` with a participle is the everyday way to say a change is done. The chip is on iPhone; `l’` stays outside it. |
| C.mac.4.s | Se sincronitza amb el teu iCloud, sense crear cap compte. | It-syncs with your iCloud, without creating any account. | `se` before a verb starting with s, as the app writes it ("se sincronitzen"). |
| C.mac.5.k | iPhone, iPad i Mac. | iPhone, iPad and Mac. | Reused from iPhone 6, as the brief allows. |
| C.mac.5.h | Pagues [un cop]. | You-pay one time. | Reused from iPhone 6, non-breaking space included. |
| C.mac.5.s | Una sola compra per als tres, sense compte ni subscripció. | One single purchase for the three, without account nor subscription. | Reused from iPhone 6. |

Sources read on 2026-11-23: Idescat name lists (idescat.cat/noms, idescat.cat/nadons 2024), the UB and UOC style guides on
the comma after `Hola`, Correos' Catalan "Rep" page (correos.es/es/ca/particulars/rep, only lliurar and lliurament), Mango's Catalan help pages (comanda,
lliurament), 3Cat's Catalan App Store listing (`tu` register), and Cutling's own `ca` strings, metadata and release notes.
