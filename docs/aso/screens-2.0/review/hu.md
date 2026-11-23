# Hungarian (hu): words for the 2.0 store frames, direction C

Words: `fastlane/compose/creative/v2/words/hu.json`. Written from `C-words-brief.md` and the `hu` entry of
`locale-facts.json`, with no source sentence.

- **Register:** informal *te* in every line, the way Cutling's current Hungarian listing ("Nyisd meg", "illeszd be")
  and its Hungarian app strings ("Koppints, és beíródik") already speak to the buyer. No *Ön* form anywhere.
- **Punctuation (AkH. 12):** a greeting word and a name are set off with commas ("Szia, Réka, …", rules 255, 256
  and 261a). Kickers and headings take no closing period (rule 266), but the replies keep their "!". Sublines are
  sentences and end with a period. There are no dashes.
- **Grammar the facts force:** the weekday must stay "kedd", so the replies say "kedd reggel" (Tuesday morning), the
  everyday uninflected time phrase, instead of "kedden". A noun after a numeral stays singular, so it is
  "5000 Cutling". This matches the app's own "%lld Cutling". Suffixes on "Cutling" use back vowels (Cutlingjaid),
  like `product_terms` "Cutlingok".

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | Réka | Réka | A name only Hungarians use. #7 among girls born in 2000 (KSH), so the age of a typical shopper today. |
| cseed.names[1] | Bence | Bence | #3 among boys born in 2000 (KSH). |
| cseed.names[2] | Anna | Anna | #3 among girls born in 2000 and still in the 2025 top list (KSH). |
| cseed.mac_name | Máté | Máté | #4 among boys born in 2000 (KSH). |
| cseed.reply | Szia, {name}, {date} reggel postázom! | Hi, {name}, {date} morning I post it! | "Postázom" is how a one-person shop says it is shipping. The weekday cannot take "-en" (kedden), so it stands bare before "reggel". Filled: 33 and 34 of 40. |
| cseed.reply_name | Postázás | Posting (sending by post) | The same verb as the reply, as a one-word label. |
| cseed.mac_reply | Szia, {name}, a {plan} csomagod {date} reggel indul! | Hi, {name}, your {plan} package leaves {date} morning! | "Csomag" means both the tier and the parcel, so "a Prémium csomagod" reads as a bundle that ships. Filled: 49 of 52. |
| cseed.name_label | Név | Name | The app's own word for Name. |
| cseed.plan_label | Csomag | Package | The app translates Plan as "csomag", and Netflix Hungary calls its plans "díjcsomag". Capitalised as a form label. |
| cseed.plan_choices[0] | Alap | Basic | Netflix Hungary's name for its basic plan ("Alap csomag"). |
| cseed.plan_choices[1] | Prémium | Premium | Hungarian spelling, with é. |
| cseed.delivered | Átvéve: {date} | Received: {date} | The date cannot take "-án", so it follows a colon, like a parcel status. "Átvéve" replaced "Kézbesítve" (delivered): the longer word made the iPhone headline break the date as "november / 23.". |
| cseed.delivered_name | Átvétel | Receipt (taking delivery) | The noun of the status word. |
| iphone.1.h (built) | Szia, [Réka], [kedd] reggel postázom! | Hi, [Réka], [Tuesday] morning I post it! | Three lines on iPhone, two on iPad. |
| iphone.1.k | Elég egyszer megírnod | It is enough for you to write it once | The same idiom as the 2.0 release notes. Carries "only once" without "csak". |
| iphone.1.s | Ha rákoppintasz, a Cutling megkérdezi a nevet. | If you tap on it, Cutling asks the name. | "Koppint" is the app's verb for tap. It fits one line. |
| iphone.2.h (built) | Szia, [Bence], [kedd] reggel postázom! | Hi, [Bence], [Tuesday] morning I post it! | The same reply as frame 1 with the next name. |
| iphone.2.k | A következő vevő ugyanezt kapja | The next customer gets this same | "Vevő" is a small shop's word for customer. "Ugyanezt" points at the reply on screen. |
| iphone.2.s | A korábbi nevek egy koppintásra várnak. | The earlier names are waiting for one tap. | Keeps the brief's picture of names waiting as keys. One line, level with frame 1. |
| iphone.3.h (built) | Átvéve: [2026. november 23.] | Received: [2026. November 23.] | Renders as "Átvéve: 2026." over "november 23." on iPhone and iPad. |
| iphone.3.k | A dátumot a Cutling írja be | The date, Cutling writes it in | Hungarian focus order: Cutling, not you, sits in the stressed slot before the verb. |
| iphone.3.s | Ma, holnap vagy egy hét múlva: a beillesztés napjától számol. | Today, tomorrow or in a week: it counts from the day of pasting. | The three are the app's own option names (Ma, Holnap, Egy hét múlva). |
| iphone.4.k | És minden, ami sosem változik | And everything that never changes | "About you" is carried by the possessive endings in the headline. |
| iphone.4.h | [Számlaszámod], [lakcímed] és [aláírásod] | [Your account number], [your home address] and [your signature] | Possessive suffixes, with "és" before the last item. "Lakcím" and "aláírás" are the Hungarian demo cutlings' own names. 35 of 50. |
| iphone.4.s | Egy-egy koppintás a Cutling billentyűzetén, bármely appban. | One tap each on Cutling's keyboard, in any app. | "Egy-egy" is the Hungarian "one each", so "each one is a single tap" needs no extra clause. 59 of 60. |
| iphone.5.k | Mindennek jut hely | There is room for everything | A common idiom. |
| iphone.5.h | [5000] Cutling | [5000] Cutling | Singular after a numeral, not "Cutlingok". |
| iphone.5.s | Eddig csak 100 volt, és mindegyikbe belefér egy teljes e-mail. | Until now it was only 100, and a whole e-mail fits into each one. | "Csak" stresses the jump. The line breaks into two balanced lines. |
| iphone.6.k | iPhone, iPad és Mac | iPhone, iPad and Mac | No period: it is a label. |
| iphone.6.h | [Egyszer] fizetsz | [Once] you pay | The set phrase for a one-time price. 15 of 18. |
| iphone.6.s | Egy vásárlás mindhárom eszközre, fiók és előfizetés nélkül. | One purchase for all three devices, without account and subscription. | "Fiók" matches the listing's "Nem kell fiók". |
| mac.1.h (built) | Szia, [Máté], a [Prémium] csomagod [kedd] reggel indul! | Hi, [Máté], your [Premium] package leaves [Tuesday] morning! | The drawn form shows Név: Máté, Csomag: Alap / Prémium, and this sentence. |
| mac.1.k | Egyszer megírod, mindenki megkapja | You write it once, everyone gets it | Two short clauses with no conjunction, a common Hungarian pattern. |
| mac.1.s | Kiválasztod a {cmd} billentyűkkel, kitöltöd a rövid űrlapot, és beilleszti. | You select it with the {cmd} keys, you fill in the short form, and it pastes it. | The three steps in the order they happen. The article "a" goes before the keys because they are read "Command…". |
| mac.2.k | Bárhol is gépelsz | Wherever you type | It runs straight into the keys, with no punctuation. |
| mac.2.h | {cmd} | ⌘ ⇧ V | Fixed by the brief. |
| mac.2.s | A Cutlingjaid és a legutóbb másolt szövegek bármely app fölött megnyílnak. | Your cutlings and the most recently copied texts open above any app. | "Legutóbb másolt" is the buyer's phrase for the history tab. "Bármely" is used here as in iphone.4.s. |
| mac.3.k | Az előzményekből kimarad | Out of the history is left [the dots] | The dots read as what "kimarad" (is left out) refers to. "Előzmények" is the picker's own tab name. |
| mac.3.s | Amit a jelszókezelő rejtettnek jelöl, az sosem kerül az előzményekbe. | What the password manager marks as hidden, that never gets into the history. | The same wording as the current Hungarian description. |
| mac.4.k | Átírod a Maceden | You rewrite it on your Mac | Pairs with "iPhone-odon" (your Mac, your iPhone). |
| mac.4.h | Az [iPhone-odon] is átíródik | On your [iPhone] too it gets rewritten | Hungarian says "on your iPhone" with suffixes, hyphenated after the silent e (AkH 217a), as the app's "Az iPhone-odon marad" does. The chip covers the whole word, because "-odon" left outside the chip looks broken. |
| mac.4.s | A saját iCloudodon át szinkronizál, regisztrálnod sem kell. | It syncs through your own iCloud, you do not even have to register. | "A saját iCloudodon át" is the app's own phrase. "Regisztráció" rather than "fiók", because iCloud is itself an account. |
| mac.5.k | iPhone, iPad és Mac | iPhone, iPad and Mac | Reused from iPhone 6. |
| mac.5.h | [Egyszer] fizetsz | [Once] you pay | Reused from iPhone 6. |
| mac.5.s | Egy vásárlás mindhárom eszközre, fiók és előfizetés nélkül. | One purchase for all three devices, without account and subscription. | Reused from iPhone 6. |

## Seen in the render (`python3 build.py hu C`)

Every frame fits, with no clipped or shrunk headline. Three captures under the words are wrong for Hungarian:

- iPhone and iPad frame 4: hu's `01_KeyboardInMessages` is entirely English (Maya, Bank Account, Home Address).
- iPhone and iPad frame 5: hu's `02_MainGrid` shows "8 Cutlingok", from before the app's string became "%lld Cutling".
- Mac frame 3: hu's `02_History` shows "Clear History", although the app's string is "Előzmények törlése".
