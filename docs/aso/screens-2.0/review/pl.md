# pl (Polish): Cutling 2.0 store frames, direction C (card ASG167)

Written blind from `C-words-brief.md` and the `pl` entry of `locale-facts.json`; the words file is
`fastlane/compose/creative/v2/words/pl.json`. Register: ty (informal singular "you"), the form the Polish App Store
listing and the app already use, kept in every line. Second-person pronouns are capitalised mid-sentence (Twój,
Twoją): Polish capitalises them in a letter or e-mail to the person addressed, which the shop's replies are, and
Apple's own Polish pages and the app's 2.0 strings capitalise them in copy for buyers as well (the current Polish
App Store description writes a lowercase "ci"). A non-breaking space follows each one-letter word (a, i, o)
and holds "we wtorek", "na iPhonie", "od dnia", "nie trafi", "bez zakładania" and "cały e-mail" together, so no
line ends on a word that belongs to the next one, as Polish typesetting requires. Square brackets mark the green chips.

Rendered at store size with the repo's C build on 2026-11-23, all 17 frames on iPhone, iPad and Mac: nothing
clipped; frames 1 and 2 break on the same lines on iPhone (three lines) and on iPad (two), so the pair reads as one
reply sent twice; no line ends on a one-letter word or splits a bound pair. `check_words.py pl` is clean.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | Aniu | Ania (addressed; the everyday form of Anna) | The name opens the reply as a form of address, where the vocative "Aniu," is the careful form and "Ania," the colloquial one. The keyboard offers what was typed into the blank before, so its key holds the vocative too. Anna is the most common Polish woman's name. Frame 1's customer. |
| cseed.names[1] | Jacku | Jacek (addressed) | A common man's name, vocative for the same reason; Aniu and Jacku were picked over Kasiu and Tomku because their widths make frames 1 and 2 break on the same lines on iPhone and on iPad, so the pair reads as the same reply. |
| cseed.names[2] | Kasiu | Kasia (addressed; the everyday form of Katarzyna) | Another very common woman's name; the third key. |
| cseed.mac_name | Bartku | Bartek (addressed; the everyday form of Bartosz) | A common man's name, vocative. |
| cseed.reply | {name}, Twoją paczkę wyślę we {date}! | {name}, Your parcel I will send on {date}! | "On Tuesday" is "we wtorek" (w becomes we before wt), and "wtorek" is already the accusative there, so the app's word stays as it is; "wyślę" (I will send) is a one-person shop and has no gender in the future tense; "Twoją" is capitalised as in a message to one person; "!" is the warmth a Polish shop's message carries. 35 and 36 characters filled. |
| cseed.reply_name | Wysyłka | Shipping | What a seller calls a "when it ships" reply; one word. |
| cseed.mac_reply | {name}, Twój pakiet {plan} wyślę we {date}! | {name}, Your {plan} package I will send on {date}! | The iPhone reply with the plan named after "pakiet", the way Poles name a tier ("pakiet Premium"), so the plan name never inflects. 44 characters filled. |
| cseed.name_label | Imię | First name | The usual label of a first-name field. |
| cseed.plan_label | Pakiet | Package | Poles buy tiers as "pakiety" (pakiet Standard, pakiet Premium); "plan" sounds like a streaming service, and this shop sends parcels. |
| cseed.plan_choices | Standard, Premium | Standard, Premium | The usual pair of Polish tier names; "Podstawowy" (basic) is longer than 8 letters. |
| cseed.delivered | Paczka doręczona {date}. | Parcel delivered {date}. | "Doręczona" is the couriers' word for delivered; a Polish date needs no preposition. |
| cseed.delivered_name | Doręczenie | Delivery | The noun for the handover itself, what the owner would title the note. |
| C.iphone.1.k | Tę odpowiedź piszesz raz | This reply you write once | Object first, so the line ends on "raz" (once); "tę", not the colloquial "tą"; 24 characters. |
| C.iphone.1.h (built) | [Aniu], Twoją paczkę wyślę we [wtorek]! | [Ania], Your parcel I will send on [Tuesday]! | Built from the reply. |
| C.iphone.1.s | Stuknij zapisaną odpowiedź, a Cutling zapyta o imię. | Tap the saved reply, and Cutling will ask about the name. | "Stuknij" is the tap verb of Apple's Polish and the app's newer strings; "zapyta o imię" is the release notes' own phrase. |
| C.iphone.2.k | Ta sama trafia do kolejnego klienta | The same one reaches the next customer | "Ta sama" points back to frame 1's "Tę odpowiedź", so the pair reads as one thought. |
| C.iphone.2.h (built) | [Jacku], Twoją paczkę wyślę we [wtorek]! | [Jacek], Your parcel I will send on [Tuesday]! | Built from the reply. |
| C.iphone.2.s | Imiona użyte wcześniej czekają na klawiszach, wystarczy stuknąć. | Names used earlier wait on the keys, it is enough to tap. | Two clauses joined by a bare comma, as Polish does without a conjunction; no past-tense "you", because Polish past tense shows the reader's gender. |
| C.iphone.3.k | Cutling sam wpisuje daty | Cutling by itself writes in dates | "Sam" (by itself) agrees with Cutling, a masculine noun. |
| C.iphone.3.h (built) | Paczka doręczona [23 listopada 2026]. | Parcel delivered [23 November 2026]. | Built from the note, with the date as the app types it today. |
| C.iphone.3.s | Dziś, jutro czy za tydzień, zawsze licząc od dnia wklejenia. | Today, tomorrow or in a week, always counting from the day of pasting. | "Licząc od dnia" is the phrase every Polish deadline uses, so the date reads as worked out on the day it is pasted. |
| C.iphone.4.k | I to, czego nie zmieniasz latami: | And what you do not change for years: | Leads into the list as one sentence, with the colon Polish puts before a list; "latami" (for years) is how a Pole says "never", and it stays true of an address. |
| C.iphone.4.h | [numer konta], [adres] i [podpis]. | [account number], [address] and [signature]. | No possessives, which Polish drops once "you" is in the sentence; "numer konta" is what Poles call their bank account number, "podpis" the name at the end of a message; no comma before "i". |
| C.iphone.4.s | Klawiatura Cutling wpisze je wszędzie jednym stuknięciem. | The Cutling keyboard will type them everywhere with one tap. | "Wszędzie" (everywhere) stands for "in any app" and keeps the line under 60; "je" is the plural for these three things. |
| C.iphone.5.k | Jest miejsce na wszystko | There is room for everything | The everyday idiom. |
| C.iphone.5.h | [5000] cutlingów | [5000] cutlings | After 5000 Polish needs the genitive plural, so "Cutlingi" becomes "cutlingów", the form the release notes use; no thousands space in a four-digit number. |
| C.iphone.5.s | Wcześniej było ich 100, a każdy zmieści cały e-mail. | Earlier there were 100 of them, and each will fit a whole e-mail. | "Każdy" agrees with cutling (masculine); "e-mail" is spelt as in the release notes. |
| C.iphone.6.k | iPhone, iPad i Mac | iPhone, iPad and Mac | A plain list in the nominative. |
| C.iphone.6.h | Płacisz [raz]. | You pay [once]. | "Raz" is the word for once; "Płacisz raz" is how Polish pricing says a single payment. |
| C.iphone.6.s | Jeden zakup na wszystkie trzy, bez konta i bez abonamentu. | One purchase for all three, without an account and without a subscription. | "Abonament" is the Polish word for a fee you keep paying (phone, TV, streaming), so it says "keep paying" by itself. |
| C.mac.1.k | Napisz raz, wysyłaj wszystkim | Write once, send to everyone | Perfective "napisz" (once, done) against imperfective "wysyłaj" (over and over): Polish aspect carries the idea in two verbs. |
| C.mac.1.h (built) | [Bartku], Twój pakiet [Premium] wyślę we [wtorek]! | [Bartek], Your [Premium] package I will send on [Tuesday]! | Built from the Mac reply. |
| C.mac.1.s | Wybierz odpowiedź skrótem {cmd}, a formularz zapyta o puste pola przed wklejeniem. | Pick the reply with the shortcut ⌘⇧V, and the form will ask about the blank fields before pasting. | "Puste pola" is the app's own word for blanks ("Puste pola i daty"); "skrótem" is how Polish refers to a keyboard shortcut. |
| C.mac.2.k | Gdziekolwiek piszesz | Wherever you write | "Pisać" covers typing as well as writing. |
| C.mac.2.h | {cmd} | ⌘⇧V | Fixed by the brief. |
| C.mac.2.s | Twoje cutlingi i ostatnio skopiowane teksty otwierają się nad każdą aplikacją. | Your cutlings and recently copied texts open above every app. | Plain words for the clipboard history, which frame 3 then names. |
| C.mac.3.k | Historia schowka na Macu pomija | The clipboard history on the Mac skips | The password dots read as the object of "pomija" (skips), as in "pomija hasła" in the Polish listing. |
| C.mac.3.s | Nic, co menedżer haseł oznaczy jako ukryte, nie trafi do historii. | Nothing that a password manager marks as hidden will get into the history. | Polish double negative (nic … nie); "co menedżer haseł oznaczy jako ukryte" is the wording of the app's own History setting. |
| C.mac.4.k | Zmień coś na Macu | Change something on the Mac | An imperative, so kicker and headline read as cause and effect. |
| C.mac.4.h | Zmieni się też na [iPhonie]. | It will change on the [iPhone] too. | The chip is on "iPhonie", the locative Polish needs after "na", as Apple's Polish pages write it ("na Macu, a otworzysz na iPhonie"). |
| C.mac.4.s | Synchronizuje się przez Twój własny iCloud, bez zakładania konta. | It syncs through Your own iCloud, without setting up an account. | "Twój" capitalised mid-sentence, as on Apple's Polish pages. |
| C.mac.5.k | iPhone, iPad i Mac | iPhone, iPad and Mac | The same words as iPhone 6. |
| C.mac.5.h | Płacisz [raz]. | You pay [once]. | The same words as iPhone 6. |
| C.mac.5.s | Jeden zakup na wszystkie trzy, bez konta i bez abonamentu. | One purchase for all three, without an account and without a subscription. | The same words as iPhone 6. |

Sources read on 2026-11-23: Apple's Polish iCloud page (https://www.apple.com/pl/icloud/) for "na iPhonie, iPadzie
lub Macu" and the capitalised "Twój"; the Narodowe Centrum Kultury "Ojczysty" notes on pronouns and capitals
(capitalised in letters and e-mails to the person addressed:
https://nck.pl/projekty-kulturalne/projekty/ojczysty-dodaj-do-ulubionych/ciekawostki-jezykowe/zaimki-i-wielkie-litery.ajax)
and on the vocative ("Basiu! rzadziej Basia!"; the separate vocative is "zdecydowanie staranniejsze", the nominative
in address colloquial:
https://nck.pl/projekty-kulturalne/projekty/ojczysty-dodaj-do-ulubionych/ciekawostki-jezykowe/wolacz.ajax).
