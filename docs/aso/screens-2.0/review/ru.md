# Russian (ru) words for the 2.0 store frames, direction C (card ASG167)

Written from `docs/aso/screens-2.0/C-words-brief.md` and the `ru` entry of `locale-facts.json`
(`вторник`, `23 ноября 2026 г.`, `5 000`, `100`). File: `fastlane/compose/creative/v2/words/ru.json`.

**Register.** Every caption speaks to the buyer with polite lowercase *вы*, shown mostly by verb endings (пишете,
нажмите, платите). The Russian 2.0 release notes, the 2.0 event card, the store description and the site speak the same
way. The app's newer screens use *ты* ("Попробуй", "Печатай здесь"), but those are the app's voice, not the listing's.
The demo reply is the shop owner writing to one customer, also with *вы* and the customer's first name, as Russian
shops write; lowercase "ваш" keeps it a friendly chat message, not an official letter.

**Product words.** The app is "Cutling" in Latin letters, as the store title ("Cutling - Буфер обмена") and the 2.0
release notes write it. One saved item is "катлинг", lowercase in running text, as the app ("Поиск катлингов") and the
release notes write it. The site and the older description call the app "Катлинг"; these frames follow the 2.0 text on
the same store page.

**Spacing and punctuation.** Every one-letter word and short preposition (и, а, в, во, у, с, на, не) is joined to the
next word by a no-break space (U+00A0), so the big serif headline never leaves one hanging at a line end. Each em dash
has a no-break space before it, so no line starts with a dash. Dashes are ordinary Russian punctuation here: each one
stands for a left-out verb or joins a condition to its result. Quotes are «ёлочки», ё is written throughout, as in the
release notes. `5 000` is the facts' string with its no-break space, and the date keeps its narrow no-break space
before "г.". The table shows all of these as plain spaces.

**Render check.** All 17 ru frames (6 iPhone, 6 iPad, 5 Mac) were built with `python3 build.py ru C` and looked at.
Every headline fits at its set size, every chip is whole, no line starts with a dash or ends on a one-letter word, and
iPhone frames 1 and 2 break on the same lines ("Анна, ваш / заказ / отправим / во вторник!"). Mac frame 1's reply runs
to five lines at the full 168 px with no shrinking. One thing on the frames is not from this file: the ru grid
capture behind iPhone and iPad frame 5 (and the small grids in frame 6 and Mac frame 4) is a 1.x screen reading
"8 Катлинги" and "Поиск Катлинг". The app's current strings already say "Катлингов: %lld" and "Поиск катлингов",
so a fresh ru `02_MainGrid` capture fixes it.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | `Анна` | Anna | Frame 1's customer; a top Russian woman's name at every age. Written Russian addresses people in the nominative, so "Анна, …" needs no case change. |
| cseed.names[1] | `Сергей` | Sergey | Frame 2's customer, so the pair shows a woman and then a man; one of the commonest men's names of shopping age. |
| cseed.names[2] | `Ольга` | Olga | Third key; a common woman's name, 5 letters. |
| cseed.mac_name | `Дмитрий` | Dmitry | A common man's name, 7 of the 8 letters allowed. |
| cseed.reply | `{name}, ваш заказ отправим во {date}!` | {name}, your order [we] will-send on {date}! | Object first ("ваш заказ отправим") is how a Russian shop says it. "во вторник": в becomes во before "вт", and "вторник" is the same in the accusative, so the app's word stands as typed. The template is only right for вторник, the one day the frames show (feminine weekdays change form after "в"). "!" because a bare full stop in a chat message reads curt in Russian. Filled: 36 and 38 characters. |
| cseed.reply_name | `Отправка заказа` | Order dispatch | The plain name a shop would give its "ships on" message; 15 characters. |
| cseed.mac_reply | `{name}, ваш набор «{plan}» отправим во {date}!` | {name}, your set «{plan}» [we] will-send on {date}! | The same reply with the tier named in «ёлочки», as Russian writes a product's name. Filled: "Дмитрий, ваш набор «Премиум» отправим во вторник!", 49 characters. |
| cseed.name_label | `Имя` | (First) name | The app's own word for Name. |
| cseed.plan_label | `Набор` | Set (a boxed kit) | A box or kit a shop packs and ships. "Тариф", the release notes' example word, means a service or phone plan, and a shop does not ship a тариф. |
| cseed.plan_choices[0] | `Базовый` | Basic | The release notes' own example «Базовый», so the store page agrees with itself; agrees with masculine "набор". 7 characters. |
| cseed.plan_choices[1] | `Премиум` | Premium | The release notes' «Премиум»; the loanword Russian shops use as is. 7 characters. |
| cseed.delivered | `Заказ доставлен {date}` | Order delivered {date} | No full stop after the date: it ends in "г.", and Russian never adds a second period after an abbreviation that ends a sentence. Filled: "Заказ доставлен 23 ноября 2026 г.". |
| cseed.delivered_name | `Дата доставки` | Delivery date | Names the note by what it holds; 13 characters. |
| C.iphone.1.k | `Пишете один раз.` | [You] write one time. | Polite *вы* in the verb ending; the ru 2.0 event card already uses this exact line. 16 characters. |
| C.iphone.1.s | `Нажмите на сохранённый ответ, и Cutling спросит имя.` | Press on the-saved reply, and Cutling will-ask the-name. | "Нажмите на" is the verb for a tap in the app and the release notes ("Нажмите на такой катлинг, и клавиатура Cutling спросит имя"). Comma before "и" because two clauses with their own subjects meet. 52 characters. |
| C.iphone.2.k | `Тот же ответ — следующему.` | The same reply — to-the-next-one. | The dash stands for the left-out verb, ordinary Russian. "следующему" is how a queue calls the next customer; the new name in the headline shows who. 26 characters, one line like frame 1's kicker. |
| C.iphone.2.s | `Имена, которые вы вводили раньше, уже на клавишах.` | The-names which you entered before [are] already on the-keys. | The keys in the picture are where they wait; "уже на клавишах" says it without a verb. |
| C.iphone.3.k | `Даты Cutling ставит сам.` | Dates Cutling puts by-himself. | "Ставить дату" is the everyday verb for dating a note (the event card: "сам ставит сегодняшнюю дату"). Object first puts dates up front. "сам" is masculine, as Russian treats a brand name ending in a consonant. 24 characters. |
| C.iphone.3.s | `Сегодня, завтра или через неделю — дата всегда верна в день вставки.` | Today, tomorrow or in a week — the-date [is] always right on the-day of-pasting. | "Вставка" is the app's own noun for Paste. A dash between the list and what is said about it follows the Russian punctuation rule. |
| C.iphone.4.k | `И то, что у вас не меняется:` | And that what with you doesn't change: | Leads into the headline as one sentence. "у вас" says whose things they are once, so the chips need no "ваш … ваш … ваша", a repetition that reads as translated English. 28 characters. |
| C.iphone.4.h | `[номер счёта], [адрес] и [подпись].` | [account number], [address] and [signature]. | The shortest everyday names: "номер счёта" (the ru promotional text says "номера счетов"), "адрес", and "подпись", the sign-off under a message (the ru capture's cutling is "Подпись e-mail"). No comma before "и", as Russian lists go. 29 characters. |
| C.iphone.4.s | `Вставляйте одним касанием с клавиатуры Cutling, где угодно.` | Insert [them] with-one touch from the-keyboard Cutling, anywhere. | "одним касанием" as the ru promotional text says it; "где угодно" (anywhere) carries "in any app" within the limit. 59 of 60 characters. |
| C.iphone.5.k | `Места хватит на всё.` | Room will-suffice for everything. | A set Russian phrase for "there is room for everything". |
| C.iphone.5.h | `[5 000] катлингов` | [5,000] cutlings | After 5 000 Russian takes the genitive plural "катлингов", the form the app uses in "Поиск катлингов"; "Катлинги" would be ungrammatical here. Lowercase as in running text. The number is the facts' "5 000" (the release notes write "5000"; Russian allows both for four digits). |
| C.iphone.5.s | `Раньше было всего 100, а в каждый поместится целое письмо.` | Before there-was only 100, and into each will-fit a-whole letter. | "письмо" is the everyday word for an email, as in the release notes ("хватит на целое письмо"). "каждый" agrees with masculine "катлинг". 58 characters. |
| C.iphone.6.k | `iPhone, iPad и Mac.` | iPhone, iPad and Mac. | The same heading the ru site uses. |
| C.iphone.6.h | `Платите [один раз].` | [You] pay [one time]. | The ru site's own promise ("Вы платите один раз"); the chip is "один раз", Russian for "once". 17 of 18 characters. |
| C.iphone.6.s | `Одна покупка сразу на все три, без аккаунта и подписки.` | One purchase at-once for all three, without account and subscription. | "Без аккаунта" as the ru description says it. Not "без регистрации": Russian readers know "без регистрации и смс" as the tag line of dodgy download sites. |
| C.mac.1.k | `Пишете один раз — отправляете всем.` | [You] write one time — [you] send to-everyone. | Opens like iPhone frame 1. The dash is how Russian joins a condition and its result without a conjunction. |
| C.mac.1.s | `Выберите ответ через {cmd}, и перед вставкой короткая форма спросит, что вписать.` | Choose the-reply through ⌘⇧V, and before pasting a-short form will-ask what to-write-in. | "через ⌘⇧V" and "короткая форма перед вставкой" are the ru Mac release notes' words. "что вписать" (what to write in) is plainer than naming "пропуски". |
| C.mac.2.k | `Где бы вы ни печатали.` | Wherever you type. | The Russian concessive "где бы … ни". |
| C.mac.2.h | `{cmd}` | ⌘⇧V | Fixed. |
| C.mac.2.s | `Катлинги и недавно скопированное появляются поверх любого приложения.` | Cutlings and the-recently copied appear over any app. | "недавно скопированное" (what was copied lately) covers text and pictures alike. No "ваши": the reader knows whose they are. |
| C.mac.3.k | `История буфера обмена пропускает` | The-history of-the-clipboard skips | The row of password dots under it is the object of "пропускает", the verb the ru description already uses for this. No punctuation, since the sentence runs on into the dots. |
| C.mac.3.s | `Всё, что менеджер паролей пометил как скрытое, в историю не попадает.` | Everything that a-manager of-passwords marked as hidden doesn't get into the-history. | The ru description's own words for the same promise, so the page says it one way. |
| C.mac.4.k | `Изменили на Mac —` | [You] changed [it] on Mac — | Leads into the headline with a dash, as Russian joins a condition and its result. Not "Меняете на Mac", which also reads as "you trade it for a Mac". |
| C.mac.4.h | `изменилось и на [iPhone].` | it-changed also on [iPhone]. | "и" here means "also". The repeated verb makes the two devices mirror each other. 23 characters. |
| C.mac.4.s | `Синхронизация идёт через ваш iCloud, аккаунт заводить не нужно.` | Syncing goes through your iCloud, an-account [you] don't need to-set-up. | "аккаунт заводить не нужно" is the everyday way to say there is no account to make; "ваш" stays because "your own iCloud" is the point. |
| C.mac.5.k | `iPhone, iPad и Mac.` | iPhone, iPad and Mac. | Same as iPhone frame 6. |
| C.mac.5.h | `Платите [один раз].` | [You] pay [one time]. | Same as iPhone frame 6. |
| C.mac.5.s | `Одна покупка сразу на все три, без аккаунта и подписки.` | One purchase at-once for all three, without account and subscription. | Same as iPhone frame 6. |
