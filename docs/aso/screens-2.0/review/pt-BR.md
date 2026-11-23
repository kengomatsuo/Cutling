# pt-BR (Portuguese, Brazil): words for the 2.0 store frames, direction C

Words: `fastlane/compose/creative/v2/words/pt-BR.json`, written from `docs/aso/screens-2.0/C-words-brief.md` and the
`pt-BR` entry of `locale-facts.json`, with no source sentence.

- **Register:** *você* in every line, with third-person verbs and the *você* imperative (Toque, Escreva, Escolha), as
  the live pt-BR listing and the 2.0 release notes speak. The app name takes the article, "o Cutling", as the app's
  own strings write it ("O Cutling digitou isto para mim").
- **Facts used as given:** terça-feira, 23 de novembro de 2026, 5.000 and 100. The app's own words: Nome, Colar,
  teclado Cutling, Histórico, and "cutlings" in lowercase in running text, as the app writes "Buscar cutlings" and the
  release notes write "5.000 cutlings de texto".
- **No-break spaces** (literal U+00A0 in the JSON) hold each possessive to its chip in iPhone frame 4 and keep short
  words ("a um toque", "pede o nome", "no teclado Cutling") off line ends in the sublines. "e‑mail" uses the
  non-breaking hyphen U+2011, because the first render split it as "e- / mail".
- **Checked:** `check_words.py pt-BR` passes. All 17 frames (6 iPhone, 6 iPad, 5 Mac) were rendered through
  `build.py pt-BR C` and looked at.

## Strings

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | Ana | Ana | In IBGE's 2022 census, the second most common woman's name in Brazil (3.93 million), after Maria. With 3 letters the filled reply is 39 characters. |
| cseed.names[1] | João | João | The second most common man's name (3.41 million). With 4 letters the filled reply is exactly 40. |
| cseed.names[2] | Luiz | Luiz | Eighth among men's names (1.33 million). It only appears as a key, but at 4 letters any of the three names fills the reply within 40. |
| cseed.mac_name | Júlia | Júlia | Fourth among women's names, which makes the four customers two women and two men. Spelled with its accent, as Portuguese writes it. |
| cseed.reply | Oi, {name}! Seu pedido sai na {date}. | Hi, {name}! Your order goes out on {date}. | "Oi" plus the name is how a Brazilian shop greets a customer in chat. "Sai na terça-feira" is how a shop says an order ships. The app's weekday stays as it is after "na", the form a named day takes ("on Tuesday"). The comma before the name follows Portuguese punctuation for a person addressed. |
| cseed.reply_name | Envio | Shipping | The one word a shop owner would file a shipping reply under. The Mac form is titled with it too, and its reply also ships. |
| cseed.mac_reply | Oi, {name}! Seu kit {plan} sai na {date}. | Hi, {name}! Your {plan} kit goes out on {date}. | The same reply with the tier added. A plan cannot ship in Portuguese ("seu plano sai" reads wrong). Brazilian shops sell bundles as kits ("Kit Básico" and "Kit Premium" are common listings on Magazine Luiza and Beleza na Web), and masculine "kit" agrees with both choices. 46 of 52 filled. |
| cseed.name_label | Nome | Name | The app's own word for Name. |
| cseed.plan_label | Kit | Kit | Matches the reply, so the form's label and its sentence name the same thing. |
| cseed.plan_choices[0] | Básico | Basic | The usual Brazilian name for an entry tier. |
| cseed.plan_choices[1] | Premium | Premium | The loanword Brazilians use for the better tier. |
| cseed.delivered | Pedido entregue em {date}. | Order delivered on {date}. | Worded like a Brazilian delivery status ("entregue em" and the full date), with "Pedido" saying what was delivered. 20 of 28 characters without the date. |
| cseed.delivered_name | Entrega | Delivery | The note's name in one word. |
| C.iphone.1.k | Você escreve uma vez só | You write one time only | A plain statement with *você*, so it reads as a fact about the reply and not an order. "Uma vez só" is the spoken "just once". 23 of 24. |
| C.iphone.1.s | Toque na resposta salva e o Cutling pede o nome. | Tap the saved reply and Cutling asks for the name. | "Tocar em" is the app's verb for a tap ("Toque num cutling"). "Pede o nome" (asks for the name) is what the keyboard does on screen. 48 of 60. |
| C.iphone.2.k | E manda de novo ao próximo cliente | And send(s) it again to the next customer | Continues frame 1's sentence ("Você escreve uma vez só / e manda de novo…"), so the pair beside the preview reads as one thought. "Mandar" is the everyday Brazilian word for send. One line on iPhone. |
| C.iphone.2.s | Os nomes que você já usou ficam no teclado, a um toque. | The names you have already used stay on the keyboard, one tap away. | "A um toque" is the Brazilian "one tap away". |
| C.iphone.3.k | O Cutling põe a data sozinho | Cutling puts the date in by itself | "Pôr a data" is how Brazilians say putting the date on something; "sozinho" is "by itself". |
| C.iphone.3.s | Hoje, amanhã ou daqui a uma semana, sempre certa no dia em que você cola. | Today, tomorrow or a week from now, always right on the day you paste. | "Daqui a uma semana" can only mean a week from now, where the app's label "Em uma semana" can also read as "within a week". "Certa" agrees with "a data" in the kicker. |
| C.iphone.4.k | E o que nunca muda: | And what never changes: | Leads into the headline as one sentence. Portuguese goes on in lowercase after the colon. |
| C.iphone.4.h | sua [chave Pix], seu [endereço] e sua [assinatura]. | your [Pix key], your [address] and your [signature]. | The bank detail Brazilians paste to get paid is the Pix key, as the CLABE is in Mexico and the IBAN in Spain: 148.3 million people used Pix in December 2025, about 86% of adults (Banco Central, Relatório de Gestão do Pix 2026). "Dados bancários" (bank details) runs the line to 52 characters, past 50, and "sua conta" on its own reads as a login. "Assinatura" is the app's word for a sign-off ("Assinatura de e-mail"). The possessives stay outside the chips, which hold only what Cutling types. 45 of 50. |
| C.iphone.4.s | Cada um com um toque, em qualquer app, no teclado Cutling. | Each one with one tap, in any app, on the Cutling keyboard. | "Teclado Cutling" is the keyboard's name in the app and the release notes. Masculine "cada um" covers a mixed list, as Portuguese does. 58 of 60. |
| C.iphone.5.k | Tem espaço para tudo | There is room for everything | "Tem" for "there is" is spoken Brazilian, also in the release notes ("Tem muito mais espaço"). |
| C.iphone.5.h | [5.000] cutlings | [5,000] cutlings | 5.000 as given, since Brazil groups thousands with a dot. "Cutlings" in lowercase, as in the release notes. |
| C.iphone.5.s | Antes eram 100, e em cada um cabe um e‑mail inteiro. | Before they were 100, and in each one fits a whole email. | "Caber" is the native verb for something fitting inside. "E-mail" is hyphenated, as the app writes it. The comma before "e" is right because the two clauses have different subjects. |
| C.iphone.6.k | iPhone, iPad e Mac | iPhone, iPad and Mac | Portuguese uses no serial comma. |
| C.iphone.6.h | Pagamento [único]. | Payment [one-time]. | "Pagamento único" is the fixed Brazilian term for paying once, as opposed to a subscription. The chip sits on "único", the word that means once. 16 of 18. |
| C.iphone.6.s | Uma compra vale para os três, sem cadastro nem mensalidade. | One purchase is good for the three, without sign-up nor monthly fee. | "Sem cadastro" is how Brazilians say there is no account to create. Brazilian App Store listings say there is no recurring fee with "sem mensalidade" (InfinitePay: "sem pagar taxa de adesão ou mensalidade"). It also avoids "assinatura", which frame 4 already uses for the sign-off. "Sem X nem Y" is the native "no X, no Y". 59 of 60. |
| C.mac.1.k | Escreva uma vez e mande para todos | Write it once and send it to everyone | The *você* imperative, as Brazilian listings address a buyer. The Mac set is seen on its own in the Mac App Store, so it does not lean on the iPhone pair. One line. |
| C.mac.1.s | Escolha a resposta com {cmd} e um formulário curto pede o que falta antes de colar. | Choose the reply with ⌘⇧V and a short form asks for what is missing before pasting. | "O que falta" (what is missing) is a buyer's word for the blanks. "Colar" is the app's Paste. |
| C.mac.2.k | Onde você estiver digitando | Wherever you are typing | The future subjunctive is the native way to say "wherever". |
| C.mac.2.h | {cmd} | ⌘⇧V | Fixed by the brief. |
| C.mac.2.s | Seus cutlings e o que você copiou por último abrem por cima de qualquer app. | Your cutlings and what you copied last open on top of any app. | "Por cima de" rather than "sobre", which can also read as "about". |
| C.mac.3.k | O histórico guarda tudo, menos | The history keeps everything, except | The dots below read as what is left out. "Histórico" is the tab's name in the Mac app. |
| C.mac.3.s | O que um gerenciador de senhas marca como oculto nunca entra no histórico. | What a password manager marks as hidden never gets into the history. | The live pt-BR description already uses these words ("o que um gerenciador de senhas marca como oculto"). |
| C.mac.4.k | Mudou no Mac, | Changed on the Mac, | The two-beat "did this, got that" rhythm of Brazilian ads. With the headline it reads "Mudou no Mac, mudou no iPhone." |
| C.mac.4.h | mudou no [iPhone]. | changed on the [iPhone]. | Continues the kicker in lowercase. |
| C.mac.4.s | Sincronizado pelo seu próprio iCloud, sem criar conta. | Synced through your own iCloud, without creating an account. | A participle, because a bare "Sincroniza" can read as a spoken command in Brazil. "Sem criar conta" avoids repeating frame 5's "sem cadastro". |
| C.mac.5.k | iPhone, iPad e Mac | iPhone, iPad and Mac | Same as iPhone 6. |
| C.mac.5.h | Pagamento [único]. | Payment [one-time]. | Same as iPhone 6. |
| C.mac.5.s | Uma compra vale para os três, sem cadastro nem mensalidade. | One purchase is good for the three, without sign-up nor monthly fee. | Same as iPhone 6. |

## What the build makes from the seed

| Frame | Headline as rendered | Literal back-translation |
|---|---|---|
| iPhone and iPad 1 | Oi, [Ana]! Seu pedido sai na [terça-feira]. | Hi, [Ana]! Your order goes out on [Tuesday]. |
| iPhone and iPad 2 | Oi, [João]! Seu pedido sai na [terça-feira]. | Hi, [João]! Your order goes out on [Tuesday]. |
| iPhone and iPad 3 | Pedido entregue em [23 de novembro de 2026]. | Order delivered on [23 November 2026]. |
| Mac 1 | Oi, [Júlia]! Seu kit [Premium] sai na [terça-feira]. | Hi, [Júlia]! Your [Premium] kit goes out on [Tuesday]. |
| Mac 3 | O histórico guarda tudo, menos [••••••••••] | The history keeps everything, except [••••••••••] |
| Keyboard bar, frames 1 and 2 | Oi, Nome! Seu pedido sai na terça-feira. | Hi, Name! Your order goes out on Tuesday. |
