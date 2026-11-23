# es-ES (Spanish, Spain): words for the 2.0 store frames, direction C

Words: `fastlane/compose/creative/v2/words/es-ES.json`, written from `docs/aso/screens-2.0/C-words-brief.md` with no
source sentence. Register: tú in every line, as the live es-ES listing and the app's own Spanish strings use it, with
Spain's forms (has usado, has copiado, sitio, correo, tu Mac). Facts used as given: martes, 23 de noviembre de 2026,
5000, 100, and the app's words Nombre, Pegar, huecos, cutling.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | Lucía | Lucía | The top name for girls born in Spain for years (INE); the customer in frame 1. |
| cseed.names[1] | Pablo | Pablo | Top ten among boys born in 2019 (INE); the customer in frame 2. |
| cseed.names[2] | Marta | Marta | About 228,000 women, average age 32.6 (INE): the age of someone who orders online. |
| cseed.mac_name | Javier | Javier | Among Spain's ten most common men's names (INE, 2024 residents). |
| cseed.reply | ¡Hola, {name}! Tu pedido sale el {date}. | Hello, {name}! Your order goes out on {date}. | "Sale el martes" is how a Spanish shop says an order ships; a named day takes "el"; the greeting in ¡! is how a shop writes to a customer. 39 characters filled. |
| cseed.reply_name | Envío | Shipping | A shop's one-word name for its dispatch reply; the build also titles the Mac form with it, so both replies are about shipping. |
| cseed.mac_reply | ¡Hola, {name}! Tu pack {plan} sale el {date}. | Hello, {name}! Your {plan} pack goes out on {date}. | The same kind of reply as on iPhone. A plan cannot ship in Spanish ("tu plan sale el martes" reads wrong), and masculine "pack" agrees with both Básico and Premium. 46 characters filled. |
| cseed.name_label | Nombre | Name | The app's own word for Name. |
| cseed.plan_label | Pack | Pack | Spanish online shops sell their tiers as "Pack Básico" and "Pack Premium"; it matches the reply. |
| cseed.plan_choices[0] | Básico | Basic | The pair the es-ES 2.0 release notes already use as their example of a choice. |
| cseed.plan_choices[1] | Premium | Premium | Spain uses the loanword for the better tier. |
| cseed.delivered | Entregado el {date}. | Delivered on {date}. | The participle reads as a status note and avoids choosing between "se ha entregado" and "se entregó" for today's date. |
| cseed.delivered_name | Entrega | Delivery | The short name a shop owner gives that note. |
| C.iphone.1.k | La escribes una sola vez | You write it one single time | "La" is la respuesta, which the subline names. 24 characters. |
| C.iphone.1.s | Tocas la respuesta y Cutling te pregunta el nombre. | You tap the reply and Cutling asks you the name. | "Tocar" is Apple Spain's verb for a tap; "pregunta" is what the keyboard does on screen. |
| C.iphone.2.k | Y la misma, al siguiente cliente | And the same one, to the next customer | The comma stands for the dropped verb (RAE's elliptical comma); pairs with frame 1's "La escribes". |
| C.iphone.2.s | Los nombres que ya has usado están a un toque. | The names you have already used are one tap away. | Spain's present perfect "has usado" (Mexico would say "usaste"). |
| C.iphone.3.k | La fecha la pone Cutling | The date, Cutling puts it in | Topic first with a resumptive "la", the way a Spaniard says who does a job. |
| C.iphone.3.s | Hoy, mañana o dentro de una semana, según el día en que lo pegues. | Today, tomorrow or a week from now, according to the day you paste it. | "Dentro de una semana" means a week from now, where "en una semana" can mean within a week; subjunctive "pegues" because it is whatever day comes. |
| C.iphone.4.k | Y lo que nunca cambia: | And what never changes: | Leads into the headline as one sentence; lowercase after the colon. |
| C.iphone.4.h | [tu IBAN], [tu dirección] y [tu firma]. | [your IBAN], [your address] and [your signature]. | Spaniards say IBAN for their account number; "firma" is the app's word ("Firma de correo"). No-break spaces keep each chip whole and the "y" off a line end. |
| C.iphone.4.s | Un toque en el teclado Cutling y lo tienes en cualquier app. | One tap on the Cutling keyboard and you have it in any app. | "El teclado Cutling" as the 2.0 release notes write it. 60 characters. |
| C.iphone.5.k | Hay sitio para todo | There is room for everything | "Sitio" is Spain's word for room (Latin America says "lugar"). |
| C.iphone.5.h | [5000] cutlings | [5000] cutlings | 5000 as given, since Spanish writes four digits without a separator; "cutlings" in lowercase inside a phrase, as the app writes "Buscar cutlings" and the release notes "5000 cutlings de texto". |
| C.iphone.5.s | Antes eran 100, y en cada uno cabe un correo entero. | Before they were 100, and in each one fits a whole email. | "Correo" is Spain's everyday word for an email. |
| C.iphone.6.k | iPhone, iPad y Mac | iPhone, iPad and Mac | No serial comma in Spanish. |
| C.iphone.6.h | Pagas [una vez]. | You pay [once]. | Chip on "una vez"; present tense like the other frames; a no-break space keeps the chip whole. 14 characters shown. |
| C.iphone.6.s | Una compra vale para los tres, sin cuenta ni suscripción. | One purchase is good for the three, without account or subscription. | "Ni" is Spanish's "nor"; "suscripción" is the RAE spelling. |
| C.mac.1.k | Escríbela una vez y mándasela a todos | Write it once and send it to everyone | Imperative tú; "se" doubles "a todos" as Spanish speech does. One line at Mac size. |
| C.mac.1.s | Con {cmd} eliges la respuesta y, antes de pegarla, rellenas los huecos. | With ⌘⇧V you choose the reply and, before pasting it, you fill in the blanks. | "Huecos" is the app's word for blanks ("Huecos y fechas"); "rellenar los huecos" is the everyday phrase; the form sits beside it. |
| C.mac.2.k | Escribas donde escribas | Wherever you type (lit. "you type where you type") | Spanish's doubled subjunctive, the native way to say wherever. |
| C.mac.2.h | {cmd} | ⌘⇧V | Fixed by the brief. |
| C.mac.2.s | Tus cutlings y lo último que has copiado se abren encima de cualquier app. | Your cutlings and the latest you have copied open on top of any app. | "Encima de" rather than "sobre", which can read as "about". |
| C.mac.3.k | El historial del portapapeles no guarda | The clipboard history does not keep | The row of dots below reads as its object; "historial del portapapeles" is the app's term. |
| C.mac.3.s | Lo que tu gestor de contraseñas marca como oculto nunca llega al historial. | What your password manager marks as hidden never reaches the history. | "Gestor de contraseñas" is the Spanish term, also in the live description. |
| C.mac.4.k | Cambias algo en tu Mac | You change something on your Mac | "Tu Mac", as Apple Spain writes. |
| C.mac.4.h | y ya está en tu [iPhone]. | and it is already on your [iPhone]. | "Ya está" says both that it is there and that it is done. |
| C.mac.4.s | Se sincroniza con tu propio iCloud, sin crear ninguna cuenta. | It syncs with your own iCloud, without creating any account. | Plain verb for sync, the word buyers know. |
| C.mac.5.k | iPhone, iPad y Mac | iPhone, iPad and Mac | Same as iPhone 6. |
| C.mac.5.h | Pagas [una vez]. | You pay [once]. | Same as iPhone 6. |
| C.mac.5.s | Una compra vale para los tres, sin cuenta ni suscripción. | One purchase is good for the three, without account or subscription. | Same as iPhone 6. |

Headlines the build makes from the seed, as they render:

| Frame | Headline | Literal back-translation |
|---|---|---|
| iPhone and iPad 1 | ¡Hola, [Lucía]! Tu pedido sale el [martes]. | Hello, [Lucía]! Your order goes out on [Tuesday]. |
| iPhone and iPad 2 | ¡Hola, [Pablo]! Tu pedido sale el [martes]. | Hello, [Pablo]! Your order goes out on [Tuesday]. |
| iPhone and iPad 3 | Entregado el [23 de noviembre de 2026]. | Delivered on [23 November 2026]. |
| Mac 1 | ¡Hola, [Javier]! Tu pack [Premium] sale el [martes]. | Hello, [Javier]! Your [Premium] pack goes out on [Tuesday]. |
| Keyboard bar, frames 1 and 2 | ¡Hola, Nombre! Tu pedido sale el martes. | Hello, Name! Your order goes out on Tuesday. |
