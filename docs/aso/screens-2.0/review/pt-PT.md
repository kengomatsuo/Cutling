# pt-PT (Portuguese, Portugal): words for the 2.0 store frames, direction C (card ASG167)

Words: `fastlane/compose/creative/v2/words/pt-PT.json`, written from `docs/aso/screens-2.0/C-words-brief.md` and the
`pt-PT` entry of `locale-facts.json`, with no source sentence.

**Register:** the formal third person in every line, with "você" never spelled out, the way the live pt-PT listing
("Guarde", "Abra", "o seu") and the app's own pt-PT strings ("Toque aqui", "Escrever no seu teclado normal") speak.
In Portugal "escreve" and "paga" also read as the informal tu imperative, so where a line would need them it uses the
impersonal "se" instead ("Escreve-se", "Paga-se"). Portugal's own words throughout: guardada, morada, palavra-passe,
estar a escrever, e-mail, mensalidades. Facts used as given: terça-feira, 23 de novembro de 2026, 5000, 100, and the
app's words Nome, Colar, espaços, cutling(s), Histórico, "O que copiou por último", "Daqui a uma semana".

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | Inês | Inês | Fourth among girls registered in Portugal in 2004 (2,670, IRN figures in Diário de Notícias), so an adult customer; the ê reads as Portuguese at a glance. Frame 1's customer. |
| cseed.names[1] | Tiago | Tiago | First among boys in 2004 (the "mãe me quer" ranking, via RFM). Frame 2's customer. |
| cseed.names[2] | Rita | Rita | Diário de Notícias names Rita among the girls' names "bastante mais comuns" in 2004 than now; the third name key. |
| cseed.mac_name | Diogo | Diogo | Second among boys in 2004 (2,257, Diário de Notícias); five letters keeps the Mac reply at 51 characters. |
| cseed.reply | Olá, {name}! Enviamos na {date}. | Hello, {name}! We send on {date}. | "Enviamos na terça-feira" is how a Portuguese shop answers "when does it ship". "Na" is the preposition and article a weekday takes, so the app's "terça-feira" stays as it is. Portugal writes the past with an accent (enviámos), so "enviamos" reads only as now/next. "A encomenda segue na terça-feira" runs to 45 filled. 36 characters with Tiago. |
| cseed.reply_name | Envio | Shipping | A shop's one-word name for its dispatch reply; the Mac form shows it as its title. |
| cseed.mac_reply | Olá, {name}! Enviamos o pack {plan} na {date}. | Hello, {name}! We send the {plan} pack on {date}. | The iPhone reply with the tier in it. A "plano" (plan) cannot be sent; a pack can. 51 characters filled. |
| cseed.name_label | Nome | Name | The app's own word for Name. |
| cseed.plan_label | Pack | Pack | Portuguese shops and telecoms sell bundles and tiers as "pack" (MEO's "Sport Office Pack"); it matches the reply. |
| cseed.plan_choices[0] | Básico | Basic | Agrees with masculine "pack". The 2.0 release notes say "plano Base" because their noun is "plano". |
| cseed.plan_choices[1] | Premium | Premium | Portugal uses the loanword for the better tier, as the release notes do. |
| cseed.delivered | Foi entregue no dia {date}. | It was delivered on the day {date}. | A bare "Entregue a 23 de novembro" can also read as the formal imperative "deliver on 23 November"; "foi entregue no dia" reads only as done. 21 characters without the date. |
| cseed.delivered_name | Entrega | Delivery | The short name a shop gives that note. |
| C.iphone.1.k | Escreve-se uma só vez | It is written only once | Impersonal "se", because "Escreve-a" would also read as the informal imperative. 21 characters. |
| C.iphone.1.s | Toque na resposta guardada e o Cutling pergunta o nome. | Tap the saved reply and Cutling asks the name. | "Toque em" is the app's own verb for a tap ("toque em Teclados"); "guardada" is Portugal's "saved" (Brazil: "salva"). 55 characters. |
| C.iphone.2.k | E serve para o próximo cliente | And it does for the next customer | "Servir" is the release notes' verb for one reply reaching everyone ("para ela servir a todas as pessoas"); pairs with frame 1. |
| C.iphone.2.s | Os nomes que já usou ficam à espera, cada um numa tecla. | The names you have already used are waiting, each one on a key. | "Já usou" is Portugal's "have used before" ("tem usado" means "have been using"). No-break spaces keep "cada um numa tecla" on one line. |
| C.iphone.3.k | Quem põe a data é o Cutling | The one who puts the date is Cutling | A spoken cleft, the way a Portuguese speaker says whose job a thing is; "pôr a data" is the everyday verb for dating a note. |
| C.iphone.3.s | Hoje, amanhã ou daqui a uma semana: a data certa no dia em que colar. | Today, tomorrow or a week from now: the right date on the day you paste. | "Daqui a uma semana" is the app's own "In a Week", "colar" its Paste; future subjunctive "em que colar" because it is whatever day comes. |
| C.iphone.4.k | E o que nunca muda: | And what never changes: | Leads into the headline as one sentence; lowercase after the colon, as Portuguese writes it. |
| C.iphone.4.h | [o seu IBAN], [a sua morada] e [a sua assinatura]. | [your IBAN], [your address] and [your signature]. | Portugal keeps the article with the possessive ("o seu"; Brazil drops it). IBAN, Morada and Assinatura de e-mail are the pt-PT captures' own cutlings (IBAN: PT50…, Rua Augusta, Lisboa). No-break spaces keep each chip whole and "e" off a line end. 44 characters shown. |
| C.iphone.4.s | Cada um está a um toque no teclado Cutling, em qualquer app. | Each one is one tap away on the Cutling keyboard, in any app. | "O teclado Cutling" as the release notes write it; masculine "cada um" covers the mixed nouns. 60 characters. |
| C.iphone.5.k | Agora cabe tudo | Now everything fits | "Caber" is Portuguese for room, as the release notes' "Cabe muito mais"; "espaço" is left out because the app uses it for a blank. |
| C.iphone.5.h | [5000] cutlings | [5000] cutlings | 5000 as given (Portugal groups digits only from five, as the release notes' "10 000"); lowercase "cutlings" as in the app's "Pesquisar cutlings". |
| C.iphone.5.s | Antes eram só 100, e cada um leva um e-mail inteiro. | Before there were only 100, and each one holds a whole email. | "Levar" in its sense of holding ("o depósito leva 50 litros"); "e-mail" hyphenated as the live listing writes it, with a no-break hyphen so it never splits across lines. |
| C.iphone.6.k | iPhone, iPad e Mac | iPhone, iPad and Mac | No serial comma in Portuguese. |
| C.iphone.6.h | Paga-se [uma vez]. | One pays [once]. | Chip on "uma vez"; the impersonal "se" echoes frame 1's "Escreve-se" and avoids "Paga", which also reads as the tu imperative. 16 characters shown. |
| C.iphone.6.s | Uma compra vale para os três, sem conta nem mensalidades. | One purchase is valid for the three, without account or monthly fees. | Apple Portugal calls a subscription "assinatura", which the app and frame 4 use for a signature; "mensalidades" (monthly fees) is how Portugal says something you keep paying. |
| C.mac.1.k | Escreva uma vez e envie a todos | Write once and send to everyone | Formal imperative, like the listing's "Guarde" and "Abra"; one line at Mac size. |
| C.mac.1.s | Escolha a resposta com {cmd} e preencha os espaços antes de colar. | Choose the reply with ⌘⇧V and fill in the blanks before pasting. | "Espaços" is the app's word for blanks ("Espaços e datas") and "preencher os espaços" the everyday phrase; the form is in the picture beside it. |
| C.mac.2.k | Onde quer que esteja a escrever | Wherever you are writing | "Estar a escrever" is Portugal's progressive (Brazil: "escrevendo"). |
| C.mac.2.h | {cmd} | ⌘⇧V | Fixed by the brief. |
| C.mac.2.s | Os seus cutlings e o que copiou por último abrem por cima de qualquer app. | Your cutlings and what you copied last open on top of any app. | "O que copiou por último" is the app's own string for What you copied; "por cima de" rather than "sobre", which can read as "about". |
| C.mac.3.k | O histórico não guarda | The history does not keep | The row of dots below reads as its object; "Histórico" is the app's tab name. |
| C.mac.3.s | Tudo o que um gestor de palavras-passe marque como oculto nunca entra no histórico. | Everything a password manager marks as hidden never gets into the history. | "Gestor de palavras-passe" and subjunctive "marque como oculto" as the live description says it. |
| C.mac.4.k | O que muda no seu Mac | What changes on your Mac | Leads into the headline; the same verb twice says one follows the other. |
| C.mac.4.h | muda no seu [iPhone]. | changes on your [iPhone]. | Chip on iPhone; lowercase as the kicker's continuation. |
| C.mac.4.s | Tudo sincroniza pelo seu próprio iCloud, sem criar conta. | Everything syncs through your own iCloud, without creating an account. | Intransitive "sincroniza pelo seu iCloud", as the app's setup guide says it ("sincronizam só pelo seu iCloud"). |
| C.mac.5.k | iPhone, iPad e Mac | iPhone, iPad and Mac | Same as iPhone 6. |
| C.mac.5.h | Paga-se [uma vez]. | One pays [once]. | Same as iPhone 6. |
| C.mac.5.s | Uma compra vale para os três, sem conta nem mensalidades. | One purchase is valid for the three, without account or monthly fees. | Same as iPhone 6. |

## Headlines the build makes from the seed, as they render

| Frame | Headline | Literal back-translation |
|---|---|---|
| iPhone and iPad 1 | Olá, [Inês]! Enviamos na [terça-feira]. | Hello, [Inês]! We send on [Tuesday]. |
| iPhone and iPad 2 | Olá, [Tiago]! Enviamos na [terça-feira]. | Hello, [Tiago]! We send on [Tuesday]. |
| iPhone and iPad 3 | Foi entregue no dia [23 de novembro de 2026]. | It was delivered on the day [23 November 2026]. |
| Mac 1 | Olá, [Diogo]! Enviamos o pack [Premium] na [terça-feira]. | Hello, [Diogo]! We send the [Premium] pack on [Tuesday]. |
| Keyboard bar, frames 1 and 2 | Olá, Nome! Enviamos na terça-feira. | Hello, Name! We send on Tuesday. |
| Mac form | Envio · Nome: Diogo · Pack: Premium (Básico, Premium) | Shipping · Name: Diogo · Pack: Premium (Basic, Premium) |

Rendered with `python3 build.py pt-PT C` on iPhone, iPad and Mac (17 frames): every headline fits with no chip
broken, and every subline breaks between phrases.

## Not in these words, seen on the rendered frames

Mac frame 3's history capture (`fastlane/screenshots_mac/raw/pt-PT/02_History.png`) shows the English seed: a German
IBAN (DE89 3704…), a +1 (555) number and a UPS tracking number. The pt-PT grid and picker captures show a Portuguese
IBAN (PT50…) and a Lisbon address, but their "Número de telefone" cutling is +1 (555) 234-5678.

Sources: Diário de Notícias, "Nomes de 2018. Mais Alices e Lourenços" (2004 figures for Inês, Diogo, Rita); RFM,
"Estes são os nomes mais escolhidos para bebés, em Portugal" (Tiago first in 2004); MEO business bundles ("Sport Office
Pack"); Apple Support pt-PT 118428 ("Cancelar uma assinatura da Apple").
