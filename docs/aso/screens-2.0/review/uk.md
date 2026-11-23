# uk: words for the 2.0 store frames, review

Written from `C-words-brief.md` and the uk facts, into `fastlane/compose/creative/v2/words/uk.json`. Every line speaks
to the buyer as lowercase `ви`, with the polite plural imperative (`Натисніть`), as Cutling's Ukrainian store
description and 2.0 release notes already do; the app's own screens mix `ти` and `ви`, the store page does not. The
app's name is `Катлінг`, as the facts and its home-screen name write it. The product word is `катлінг` in running text,
lowercase as the 2.0 release notes write it, and it takes its case ending where Ukrainian needs one (`5 000 катлінгів`).
App is `застосунок`, as the release notes and the app say. iPhone, iPad, Mac, iCloud and IBAN stay in Latin letters.

What a Ukrainian reader checks first:

- The customer names are vocatives (`Олено`, `Андрію`, `Оксано`, `Тарасе`). The reply speaks to the customer, and
  Ukrainian addresses a person in the vocative case; `Олена, посилку…` in that slot reads as a mistake. The keyboard's
  one-tap keys therefore offer the forms the owner typed into that blank before.
- `вівторок` is never changed: `у вівторок` takes it as the app writes it, and `у` comes before a word starting with `в`.
- `«»` quotation marks, the apostrophe `’` the app uses in `Ім’я`, a spaced dash only where Ukrainian puts one for a verb
  left out, and no period after the long date, whose own `р.` ends the sentence.
- A one-letter preposition or conjunction (`у`, `в`, `і`, `й`, `а`) is bound to the next word with a no-break space,
  and a dash to the word before it, so none of them ends a line: the headline breaks `відправимо / у вівторок!`, never
  `відправимо у / вівторок!`. In the JSON these spaces are written `\u00a0`.

Rendered with `python3 build.py uk C` at App Store sizes (iPhone 1320 x 2868, iPad 2064 x 2752, Mac 2880 x 1800), and
every frame looked at. Nothing clips, no chip splits, frames 1 and 2 break on the same lines on iPhone and on iPad, and
every limit in the brief holds.

| Key | String | Back-translation | Choice |
|---|---|---|---|
| cseed.names | `Олено`, `Андрію`, `Оксано` | Olena, Andrii, Oksana, each in the form used when speaking to the person | Common Ukrainian first names, two women and a man, in the vocative because the reply speaks to the customer; they are what the owner typed into that blank before, so the keys offer them that way. |
| cseed.mac_name | `Тарасе` | Taras (spoken to) | A fourth common name and a second man, in the vocative for the same reason. |
| cseed.reply | `{name}, посилку відправимо у {date}!` | {name}, the parcel (we) will send on {date}! | Відправимо is the verb Ukrainian shops use for dispatch; the parcel comes first and the day last, where Ukrainian puts the new fact; 37 to 38 characters filled. |
| cseed.reply_name | `Відправка` | Dispatch | What a seller calls the shipping message; it also titles the Mac form, whose reply is about dispatch too. |
| cseed.mac_reply | `{name}, пакет «{plan}» відправимо у {date}!` | {name}, the «{plan}» package (we) will send on {date}! | The iPhone reply's shape, so both read as one shop; пакет is both a tier and a thing you ship, and agrees with the masculine plan names; 46 characters filled. |
| cseed.name_label | `Ім’я` | Name | The app's own label, with the apostrophe (’) the app uses. |
| cseed.plan_label | `Пакет` | Package | The usual Ukrainian word for a tier you buy, as in the пакет послуг a bank or a studio sells. |
| cseed.plan_choices | `Базовий`, `Преміум` | Basic, Premium | The two plans the Ukrainian 2.0 release notes already name as their example. |
| cseed.delivered | `Ваше замовлення доставлено {date}` | Your order (has been) delivered {date} | The -но form states a finished fact the Ukrainian way; no period after {date}, because the date's own «р.» ends the sentence; 27 characters without the date. |
| cseed.delivered_name | `Доставка` | Delivery | Pairs with Відправка; a one-word label a seller would give the note. |
| C.iphone.1.k | `Цю відповідь пишете раз` | This reply (you) write once | Names відповідь, so frame 2's «Та сама» has a word to point back to; 23 characters. |
| C.iphone.1.h (built) | `[Олено], посилку відправимо у [вівторок]!` | [Olena], the parcel (we) will send on [Tuesday]! | Вівторок stays exactly as the app types it: у вівторок takes the word unchanged, and у comes before a word starting with в by the euphony rule. |
| C.iphone.1.s | `Натисніть на збережену відповідь, і Катлінг спитає ім’я.` | Tap on the saved reply, and Cutling will ask (for the) name. | The verbs the Ukrainian 2.0 release notes use for this moment (натисніть, спитає ім’я); 56 characters. |
| C.iphone.2.k | `Та сама — наступному клієнтові` | The same (one), to the next client | The dash stands for the verb left out, as Ukrainian punctuation uses it; the -ові dative after наступному. |
| C.iphone.2.h (built) | `[Андрію], посилку відправимо у [вівторок]!` | [Andrii], the parcel (we) will send on [Tuesday]! | Breaks on the same lines as frame 1 on iPhone and on iPad. |
| C.iphone.2.s | `Імена, які ви вже вводили, вибираєте одним дотиком.` | Names that you already entered, (you) pick with one touch. | Одним дотиком is the store page's own phrase for one tap. |
| C.iphone.3.k | `Дату Катлінг ставить сам` | The date Cutling puts (in) by itself | Ставити дату is how Ukrainian says to date something; сам goes last, where the stress falls. |
| C.iphone.3.h (built) | `Ваше замовлення доставлено [23 листопада 2026 р.]` | Your order delivered [23 November 2026] | The long date exactly as the facts write it. |
| C.iphone.3.s | `Сьогодні, завтра чи через тиждень — дата правильна в день, коли вставляєте.` | Today, tomorrow or in a week: the date (is) right on the day (you) paste. | Через тиждень as the app's own menu writes it; правильна, not the Russianism вірна. |
| C.iphone.4.k | `І те, що у вас не змінюється:` | And what you have that does not change: | У вас carries the «your», so the chips need no possessive; Ukrainian drops it when the owner is clear. |
| C.iphone.4.h | `[IBAN], [адреса] й [підпис]` | [IBAN], [address] and [signature] | IBAN has been the only account-number format for Ukrainian payments since 13 January 2020, and it is what the Try It capture below shows under «Банківський рахунок»; й after a vowel by the euphony rule. |
| C.iphone.4.s | `Один дотик на клавіатурі Катлінг у будь-якому застосунку.` | One touch on the Cutling keyboard in any app. | Застосунок for app, as the release notes and the app say, over the colloquial додаток; 57 characters. |
| C.iphone.5.k | `Місця вистачить на все` | Room will be enough for everything | The everyday idiom. |
| C.iphone.5.h | `[5 000] катлінгів` | [5,000] cutlings | Genitive plural after the number, as Ukrainian requires; the number exactly as the facts write it, with its no-break space. |
| C.iphone.5.s | `Раніше було 100, а кожен уміщує цілий лист.` | Before (there) were 100, and each holds a whole letter. | Лист for an email, as the release notes say it. |
| C.iphone.6.k | `На iPhone, iPad і Mac` | On iPhone, iPad and Mac | Apple's device names stay in Latin letters in Ukrainian. |
| C.iphone.6.h | `Платите [один раз]` | (You) pay [one time] | A verb and a person instead of the noun phrase разова оплата; 16 characters. |
| C.iphone.6.s | `Одна покупка для всіх трьох, без реєстрації й підписки.` | One purchase for all three, without registration or subscription. | Без реєстрації is how Ukrainian listings say there is no account to make. |
| C.mac.1.k | `Пишете раз, надсилаєте всім` | (You) write once, (you) send to everyone | Two verbs side by side, the shape the meaning has. |
| C.mac.1.h (built) | `[Тарасе], пакет «[Преміум]» відправимо у [вівторок]!` | [Taras], the «[Premium]» package (we) will send on [Tuesday]! | The quotes stay outside the chip, so only the value typed into the form is green. |
| C.mac.1.s | `Натисніть {cmd}, виберіть відповідь, заповніть пропуски, і Катлінг її вставить.` | Press ⌘⇧V, pick the reply, fill in the blanks, and Cutling will paste it. | Заповніть пропуски is the phrase every Ukrainian knows from school exercises, and пропуски is the app's own word for blanks; the form is in the picture beside it. |
| C.mac.2.k | `Хоч би де ви писали` | Wherever you may be writing | Хоч би де is the form Ukrainian style guides prefer for «wherever». |
| C.mac.2.h | `{cmd}` | ⌘⇧V | Fixed by the brief. |
| C.mac.2.s | `Ваші катлінги й останнє скопійоване відкриваються поверх будь-якого вікна.` | Your cutlings and the last copied (things) open on top of any window. | Поверх будь-якого вікна: over any window, which is what the picker does on the Mac. |
| C.mac.3.k | `Історія буфера обміну пропускає` | The clipboard history skips | The password dots read as its object; the Ukrainian store description already says пропускає for this. |
| C.mac.3.s | `Усе, що менеджер паролів позначив як приховане, в історію не потрапляє.` | Everything a password manager marked as hidden does not get into the history. | The Ukrainian store description's own words for the same promise. |
| C.mac.4.k | `Змінили щось на Mac?` | Changed something on the Mac? | A question and its answer, the conversational way to say if-then. |
| C.mac.4.h | `Уже й на [iPhone]` | Already on [iPhone] too | Уже, not вже, at the start of a sentence before a consonant; й here means «too»; bound so the line never splits. |
| C.mac.4.s | `Катлінги синхронізуються через ваш власний iCloud, без реєстрації.` | Cutlings sync through your own iCloud, without registration. | The verb the Mac's own iCloud pane in the capture uses. |
| C.mac.5.k | `На iPhone, iPad і Mac` | On iPhone, iPad and Mac | Same words as iPhone 6. |
| C.mac.5.h | `Платите [один раз]` | (You) pay [one time] | Same words as iPhone 6. |
| C.mac.5.s | `Одна покупка для всіх трьох, без реєстрації й підписки.` | One purchase for all three, without registration or subscription. | Same words as iPhone 6. |
