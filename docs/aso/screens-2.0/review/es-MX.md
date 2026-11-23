# es-MX, direction C words (card ASG167)

Every line uses tú, the same as apple.com/mx, the app's es-MX strings and the current es-MX listing. I rendered the words on direction C's build for iPhone, iPad and Mac. Only one headline shrinks: iPhone frame 3 (the long date), by one 4% step. Only the date chip breaks across lines, and no subline ends on a single word.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names | `Ximena`, `Diego`, `Paola` | (first names) | Common Mexican names, two women and a man. Ximena is the Mexican spelling (Spain writes Jimena), so frame 1 reads as Mexico at a glance. |
| cseed.mac_name | `Andrés` | (first name) | A common Mexican man's name, so the four names split two and two. |
| cseed.reply | `¡{name}, tu pedido sale el {date}!` | "{name}, your order goes out the {date}!" | The ¡! is the warmth a Mexican shop puts in a WhatsApp reply. "Sale el martes" is how people here say an order ships that day: the weekday takes "el" and stays as the app writes it. 34 characters with Ximena. |
| cseed.reply_name | `Envío` | "Shipment" | One word, the way owners name a quick reply. |
| cseed.mac_reply | `¡{name}, tu paquete {plan} sale el {date}!` | "{name}, your {plan} package goes out the {date}!" | Same shape as the iPhone reply. "Paquete" is what Mexican shops call a tier you buy, and it also means parcel, so the sentence is true either way. 43 characters filled. |
| cseed.name_label | `Nombre` | "Name" | The app's own word for Name. |
| cseed.plan_label | `Paquete` | "Package" | The Mexican word for a tier you buy. "Plan" sounds like a phone plan. |
| cseed.plan_choices | `Básico`, `Premium` | "Basic", "Premium" | The tier names Mexican services use. Premium is a loanword everyone knows. |
| cseed.delivered | `Pedido entregado el {date}.` | "Order delivered the {date}." | A status line a shop sends. Spanish puts "el" before a full date. 21 characters without the date. |
| cseed.delivered_name | `Entrega` | "Delivery" | Pairs with Envío. |
| C.iphone.1.k | `La escribes una sola vez` | "You write it one single time" | Present tense, tú. "La" points at the reply printed under it. 24 of 24. |
| C.iphone.1.h (built) | `¡[Ximena], tu pedido sale el [martes]!` | "Ximena, your order goes out the Tuesday!" | Built from reply, names[0] and the weekday. |
| C.iphone.1.s | `Tocas la respuesta guardada y Cutling solo pide el nombre.` | "You touch the saved reply and Cutling only asks the name." | "Solo" tells the buyer the date fills itself. 58 of 60. |
| C.iphone.2.k | `Y la misma va al siguiente cliente` | "And the same one goes to the next customer" | Starts with "Y" so it reads on from frame 1's kicker beside it. |
| C.iphone.2.h (built) | `¡[Diego], tu pedido sale el [martes]!` | "Diego, your order goes out the Tuesday!" | Built from reply and names[1]. |
| C.iphone.2.s | `Los nombres que ya usaste quedan a un toque.` | "The names that you already used stay at one touch." | "Ya usaste" is the Mexican preterite (Spain says "has usado"), and "a un toque" is the stock phrase for one tap away. One line on iPhone and iPad. |
| C.iphone.3.k | `Las fechas se escriben solas` | "The dates write themselves alone" | "Solas" agrees with fechas, which avoids "solo", a word that can also mean "only". |
| C.iphone.3.h (built) | `Pedido entregado el [23 de noviembre de 2026].` | "Order delivered the 23 of November of 2026." | Built from delivered and long_date_nov23. |
| C.iphone.3.s | `Hoy, mañana o en una semana, según el día en que pegues.` | "Today, tomorrow or in one week, according to the day on which you paste." | Subjunctive "pegues" because the paste has not happened yet. "Según" ties the date to the paste day. |
| C.iphone.4.k | `Y tus datos de siempre` | "And your details of always" | "Tus datos de siempre" is a stock Mexican phrase for your usual details. |
| C.iphone.4.h | `Tu [CLABE], tu [dirección] y tu [firma].` | "Your CLABE, your address and your signature." | The CLABE is the 18-digit number Mexicans send to get paid by transfer, and the app's es-MX seed already shows one. "Tu" sits outside the chips because Cutling types the number, not the "your". 34 of 50. |
| C.iphone.4.s | `En cualquier app, un toque en el teclado de Cutling y listo.` | "In any app, one touch on the keyboard of Cutling and ready." | "Y listo" is everyday Mexican for "and that's it", the same voice as the listing's "Listo" and "Ya quedó". 60 of 60. |
| C.iphone.5.k | `Ahora cabe todo` | "Now everything fits" | "Ahora" sets up the subline's "Antes". |
| C.iphone.5.h | `[5,000] cutlings.` | "5,000 cutlings." | n5000 as given, with a comma for thousands. The product word is lowercase, as the app writes it ("Buscar cutlings"). |
| C.iphone.5.s | `Antes eran 100 y cada uno guarda hasta un correo completo.` | "Before they were 100 and each one holds up to a complete email." | "Cada uno" is masculine because the app says "un cutling". "Guarda" avoids repeating the kicker's "cabe". |
| C.iphone.6.k | `iPhone, iPad y Mac` | "iPhone, iPad and Mac" | The device names stay as Apple writes them. |
| C.iphone.6.h | `Pago [único].` | "Single payment." | "Pago único" is the usual Mexican term for paying once. Its chip is one word, so it never splits; "Pagas [una vez]." broke in two on iPhone and Mac. |
| C.iphone.6.s | `Con una compra lo tienes en los tres, sin cuenta ni suscripción.` | "With one purchase you have it on the three, without account nor subscription." | "Lo" is Cutling and "los tres" are the devices in the kicker. "Sin cuenta ni suscripción" is how a Spanish speaker pairs two things you don't need. |
| C.mac.1.k | `Escríbela una vez y mándala a todos` | "Write it one time and send it to all" | Imperative with tú. "Mandar" is the everyday Mexican verb for sending a message; "enviar" is the formal one. |
| C.mac.1.h (built) | `¡[Andrés], tu paquete [Premium] sale el [martes]!` | "Andrés, your Premium package goes out the Tuesday!" | Built from mac_reply, mac_name, the better plan and the weekday. |
| C.mac.1.s | `Con {cmd} eliges la respuesta, llenas los campos y se pega.` | "With ⌘⇧V you choose the reply, you fill the fields and it pastes itself." | "Campos" is the app's word for blanks ("Campos y fechas"), and "llenar" is Mexican (Spain says "rellenar"), both as the app's strings already have them. |
| C.mac.2.k | `Donde sea que escribas` | "Wherever it be that you write" | "Donde sea" is the colloquial Mexican "wherever". |
| C.mac.2.h | `{cmd}` | (the keys ⌘ ⇧ V) | Fixed by the brief. |
| C.mac.2.s | `Tus cutlings y lo último que copiaste se abren sobre cualquier app.` | "Your cutlings and the latest that you copied open over any app." | Mexican preterite "copiaste". "App" is also Apple Mexico's word. |
| C.mac.3.k | `Todo lo que copias se guarda, menos` | "All that you copy is saved, except" | Ends on "menos", so the row of dots under it reads as the exception. It follows the app's own setting text, "Todo lo que copies se guarda". |
| C.mac.3.s | `Si tu administrador de contraseñas lo marca como oculto, no se guarda.` | "If your password manager marks it as hidden, it does not get saved." | "Administrador de contraseñas" is the term the app and the current es-MX listing use; Spain says "gestor". |
| C.mac.4.k | `Cambias algo en tu Mac` | "You change something on your Mac" | "Tu Mac" needs no article. Apple Mexico says "la Mac", while the app's strings say "este Mac". |
| C.mac.4.h | `Y ya está en tu [iPhone].` | "And already it is on your iPhone." | "Ya está" is how people here say the change has already arrived. "Y cambia en tu iPhone" was dropped because "cambia" can also be read as the command "change it". |
| C.mac.4.s | `Todo se sincroniza con tu propio iCloud, sin crear otra cuenta.` | "Everything syncs itself with your own iCloud, without creating another account." | "Otra cuenta" because the reader already has iCloud. |
| C.mac.5.k | `iPhone, iPad y Mac` | "iPhone, iPad and Mac" | Same as iPhone 6. |
| C.mac.5.h | `Pago [único].` | "Single payment." | Same as iPhone 6. |
| C.mac.5.s | `Con una compra lo tienes en los tres, sin cuenta ni suscripción.` | "With one purchase you have it on the three, without account nor subscription." | Same as iPhone 6. |
