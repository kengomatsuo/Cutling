# Romanian (ro): words for the 2.0 store frames, direction C

Written from `C-words-brief.md` and the `ro` entry of `locale-facts.json`; words file
`fastlane/compose/creative/v2/words/ro.json`. Rendered on iPhone, iPad and Mac and looked at frame by frame.

Register: `tu` in every line, as apple.com/ro speaks to buyers ("Află", "Cumpără", "Datele tale"), as the app's
Romanian strings do ("Lipește", "Caută cutling-uri") and as Cutling's current Romanian store page does. The shop
owner's replies use `tu` too, the way Romanian small shops write to a customer they call by first name. Punctuation
is Romanian: ș and ț with the comma below, no comma before "și", a colon before a list, no long dashes.

Line breaks: a word with a hyphen ("Cutling-uri", "să-ți") must not end a line, because the browser splits it at the
hyphen. `|` in iPhone 5's headline forces the break after "de". Two sublines carry no-break spaces (` `) so the
iPhone line breaks at a comma or before "și", never leaving a short word or one lone word at a line end.

| Key | String | Back-translation | Choice |
|---|---|---|---|
| cseed.names | Ioana, Andrei, Maria | Ioana, Andrei, Maria | Three of Romania's most common first names, woman, man, woman; all three stay unchanged when used to address someone in writing, so no vocative ending is needed. |
| cseed.mac_name | Mihai | Mihai | A common man's name, same in address. |
| cseed.reply | {name}, îți trimitem comanda {date}! | {name}, we are sending you the order {date}! | The shop speaks as "we" to "you"; the bare weekday "marți" is how Romanian says "on Tuesday", with no preposition, and the present tense carries the near future; "!" is the warm end a shop puts on this message. |
| cseed.reply_name | Expediere | Dispatch | One noun, as a shop owner labels a saved message. |
| cseed.mac_reply | {name}, îți trimitem {date} pachetul {plan}! | {name}, we are sending you {date} the {plan} package! | Same voice as the iPhone reply; the weekday goes before the object, a natural Romanian order, so the three chips never touch; "pachet" is both the tier and the parcel that ships. |
| cseed.name_label | Prenume | First name | Romanian forms keep Nume (surname) and Prenume (given name) apart, and the blank takes a first name. |
| cseed.plan_label | Pachet | Package | Romanian sells tiers as "pachetul Standard / Premium" (banks, phone operators); "plan" would not ship in a box. |
| cseed.plan_choices | Standard, Premium | Standard, Premium | The pair Romanian buyers see for basic and better. |
| cseed.delivered | Coletul a ajuns pe {date}. | The parcel arrived on {date}. | What Romanians say of a delivered parcel, in the active voice; short enough that "Coletul a ajuns pe" holds one line above the date chip (the passive "a fost livrat pe" left "pe" alone on an iPhone line); a full date takes "pe". |
| cseed.delivered_name | Livrare | Delivery | One noun, like Expediere. |
| iphone.1.h (built) | [Ioana], îți trimitem comanda [marți]! | Ioana, we are sending you the order on Tuesday! | Built from the reply; 34 characters filled. |
| iphone.2.h (built) | [Andrei], îți trimitem comanda [marți]! | Andrei, we are sending you the order on Tuesday! | Built from the reply; 35 characters filled. |
| iphone.3.h (built) | Coletul a ajuns pe [23 noiembrie 2026]. | The parcel arrived on 23 November 2026. | Built from the note with today's long date. |
| mac.1.h (built) | [Mihai], îți trimitem [marți] pachetul [Premium]! | Mihai, we are sending you on Tuesday the Premium package! | Built from the Mac reply; 43 characters filled. |
| iphone.1.k | Scrii răspunsul o dată. | You write the reply once. | "o dată" in two words is the counted "once"; written as one word, "odată" means "formerly". |
| iphone.1.s | Atingi răspunsul și Cutling te întreabă cui îi scrii. | You tap the reply and Cutling asks you who you are writing to. | "cui îi scrii" because "îți cere numele" would read as "asks for your own name". |
| iphone.2.k | Același răspuns, următorul client. | The same reply, the next customer. | A line with no verb that reads as the second half of frame 1's kicker. |
| iphone.2.s | Numele folosite deja te așteaptă ca taste. | The names already used wait for you as keys. | A key is one tap, so "taste" carries it; one line, like frame 1's subline beside it. "nume" is the same word in singular and plural, and the participle "folosite" makes it plural. |
| iphone.3.k | Data o scrie Cutling. | The date, Cutling writes it. | Topic first with the doubling pronoun "o", the everyday Romanian way to say who does a job; singular "data", since "datele" also means "the data". |
| iphone.3.s | Azi, mâine sau peste o săptămână: data iese corectă oricând lipești. | Today, tomorrow or in a week: the date comes out right whenever you paste. | "iese corectă" is the spoken "comes out right"; "oricând lipești" carries "right on the day it is pasted". |
| iphone.4.k | Și ce nu se schimbă niciodată: | And what never changes: | Leads into the list with a colon, Romanian's own mark before an enumeration. |
| iphone.4.h | [IBAN-ul tău], [adresa ta] și [semnătura ta]. | your IBAN, your address and your signature. | Romanians name their account number by its IBAN when they ask for or give it ("dă-mi IBAN-ul"); the possessive follows each noun, as Romanian does; no comma before "și". |
| iphone.4.s | Câte o atingere pe tastatura Cutling, în orice aplicație. | One tap each on the Cutling keyboard, in any app. | The distributive "câte o" says "each one is a single tap" in two words; no-break spaces hold "în orice aplicație" together, so the iPhone line breaks at the comma. |
| iphone.5.k | Ai loc pentru tot. | You have room for everything. | Says "you" where "there is room" would be impersonal. |
| iphone.5.h | [5.000] de\|Cutling-uri. | 5,000 Cutlings. | Romanian puts "de" after any number from 20 up; the plural is the app's own "Cutling-uri", capitalised as in its count label "%lld Cutling-uri"; `\|` breaks the line after "de", because on iPad the word split at its hyphen. |
| iphone.5.s | Până acum erau doar 100, iar în fiecare încape un e-mail întreg. | Until now there were only 100, and a whole email fits in each. | "iar" joins two facts about different things, as Romanian does; "e-mail" with the hyphen, the DOOM spelling. |
| iphone.6.k | iPhone, iPad și Mac. | iPhone, iPad and Mac. | The three names, nothing else. |
| iphone.6.h | Plătești [o dată]. | You pay once. | Chip on "o dată" (once); 16 characters. |
| iphone.6.s | O singură achiziție pentru toate trei, fără cont și fără abonament. | A single purchase for all three, without an account and without a subscription. | "achiziție" is the word the current Romanian store description uses for the purchase; "fără" repeated, as Romanian lists what is absent; a no-break space in "și fără" starts the second line with "și". |
| mac.1.k | Scrii o dată, trimiți tuturor. | You write once, you send to everyone. | Two short clauses with the same "tu" verb ending. |
| mac.1.s | Alegi răspunsul cu {cmd}, completezi spațiile și Cutling îl lipește. | You pick the reply with ⌘⇧V, fill in the blanks and Cutling pastes it. | "spațiile" is the app's word for blanks ("Spații și date") and the school phrase "completează spațiile"; "ce lipsește" (what is missing) was dropped because it sits badly next to "lipește" (pastes). |
| mac.2.k | Oriunde scrii. | Wherever you type. | "scrii" covers typing and writing. |
| mac.2.h | {cmd} | ⌘⇧V | Fixed by the brief. |
| mac.2.s | Cutling-urile tale și ce ai copiat recent se deschid peste orice aplicație. | Your Cutlings and what you copied recently open over any app. | "ce ai copiat recent" names the clipboard history from the user's side. |
| mac.3.k | Istoricul de copiere nu păstrează | The copy history does not keep | No end mark, so the row of password dots under it reads as its object; "istoric de copiere" is the store page's own term. |
| mac.3.s | Tot ce marchează un manager de parole ca ascuns nu ajunge niciodată în istoric. | Everything a password manager marks as hidden never gets into the history. | Verb before subject in the relative clause, the natural Romanian order; the double negative "nu ... niciodată" is standard. |
| mac.4.k | Schimbi ceva pe Mac? | You change something on the Mac? | A question and its answer, so the headline does not start in lower case. |
| mac.4.h | Se schimbă și pe [iPhone]. | It changes on the iPhone too. | Chip on "iPhone". |
| mac.4.s | Prin iCloud-ul tău, fără să creezi vreun cont. | Through your iCloud, without creating any account. | Answers "how?" after the headline, beside the capture's own "Sincronizare iCloud" switch; "iCloud-ul" takes the article after a hyphen, as Romanian does with foreign names; "să-ți faci cont" split at its hyphen on the Mac frame. |
| mac.5.k | iPhone, iPad și Mac. | iPhone, iPad and Mac. | Same as iPhone frame 6. |
| mac.5.h | Plătești [o dată]. | You pay once. | Same as iPhone frame 6. |
| mac.5.s | O singură achiziție pentru toate trei, fără cont și fără abonament. | A single purchase for all three, without an account and without a subscription. | Same as iPhone frame 6. |
