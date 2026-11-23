# sk (Slovak): words for the 2.0 store frames, direction C (card ASG167)

Written from `docs/aso/screens-2.0/C-words-brief.md` and the `sk` entry of `locale-facts.json` (`utorok`,
`23. novembra 2026`, `5 000`, `100`). File: `fastlane/compose/creative/v2/words/sk.json`. Rows marked *built* are
made by the build from the seed and are shown so the finished headline can be read.

**Register.** The captions speak to the buyer with informal *ty* (tykanie). Slovak App Store listings use both. Of
the Slovak listings read on 23 November 2026 (iTunes Search API, Slovak storefront), six say *ty*, all shopping and
food apps (Alza, Lidl Plus, Notino, Bistro.sk, Bolt Food, O2's Radosť), and fourteen say *vy* (Apple's Pages,
Martinus, Kaufland, dm, Wolt, Sinsay, and the banks and telcos: George, Tatra banka, O2, Telekom); Packeta mixes the
two. *Vy* is the more common, and *ty* is picked anyway because Cutling's own Slovak 2.0 screens use it
(the setup guide in iPhone frame 4's capture: "Vyskúšaj", "Máš hotovo"), and so do the Slovak 2.0 What's New and the
in-app event on the same store page. Present and future tense only, so no verb shows the reader's gender. Note for
the page as a whole: the Slovak store description and promotional text, written earlier, still say *vy*.

**The reply** is the shop owner writing to a customer by first name, so it uses *ty* with "Ahoj", which is how small
Slovak shops write. Slovak needs a preposition before the weekday, and "v utorok" is correct with the app's bare word
because the accusative of "utorok" is "utorok".

**Punctuation**, per the Pravidlá slovenského pravopisu (JÚĽŠ SAV), chapter VIII: an interjection such as "ahoj" and
the name of the person addressed are both set off by commas ("Ahoj, Jana, …"); headings and inscriptions take no
full stop, so the kickers and the label-like headlines have none, while messages and sentences end with one; "tvoj"
stays lowercase, as the rules prescribe for advertising. Every one-letter preposition or conjunction (v, o, u, z, a)
is joined to the next word by a no-break space, as Slovak typesetting keeps them off the end of a line: in the first
render "v" ended a line on iPhone 1 and 2, iPad 2 and Mac 1, and "a" on iPad 4. The last two words of four sublines
are joined the same way, so none ends on a lone word. No dashes; no quotation marks needed.

**Product words.** "cutling" is lowercase in running text, plural "cutlingy", and genitive plural "cutlingov" after
5 000, as the Slovak What's New writes it. "klepnúť" for a tap, as the app's strings and What's New say it.
"história schránky" for the Mac clipboard history, matching the picker's "História" tab.

**Fit.** Rendered with `python3 build.py sk C` on iPhone, iPad and Mac: every frame fits, and no one-letter word ends
a line.

| Key | Slovak | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names | `Jana, Tomáš, Zuzana` | Jana, Tomáš, Zuzana | Two women and a man. Zuzana is the third most common woman's name in Slovakia (Ministry of Interior), Jana a top-five woman's name in a 2025 open-data count of 19 Slovak towns, Tomáš a top-ten boys' name in 2015 and 2020. Slovak addresses people in the nominative, so each name stays as written after "Ahoj,". |
| cseed.mac_name | `Martin` | Martin | A top-five man's name in the same 2025 count; six letters keep the Mac reply at 49 characters. |
| cseed.reply | `Ahoj, {name}, balíček ti pošlem v {date}.` | Hi, {name}, the little parcel I will send you on {date}. | "Ahoj" goes with *ty*, and a small shop writing to a customer by first name would use both; "balíček" (little parcel) is warmer than "balík". "v" + weekday is correct with the bare word, because "utorok" has the same form in the accusative. 39 and 40 characters filled. |
| iphone.1.h *built* | `Ahoj, [Jana], balíček ti pošlem v [utorok].` | Hi, [Jana], the little parcel I will send you on [Tuesday]. | The comma after "Ahoj" and the pair around the name follow the rules for interjections and forms of address (PSP, chapter VIII, 2.4.1). |
| iphone.2.h *built* | `Ahoj, [Tomáš], balíček ti pošlem v [utorok].` | Hi, [Tomáš], the little parcel I will send you on [Tuesday]. | Same reply, second name; "pošlem" carries no gender, so it reads right for Jana and Tomáš alike. |
| cseed.reply_name | `Odoslanie` | Dispatch | One noun, the title a shop owner gives a saved dispatch message. |
| cseed.mac_reply | `Ahoj, {name}, balíček {plan} ti pošlem v {date}.` | Hi, {name}, the {plan} parcel I will send you on {date}. | The iPhone reply with the plan naming the box, so both devices show the same shop; 49 characters filled. |
| mac.1.h *built* | `Ahoj, [Martin], balíček [Premium] ti pošlem v [utorok].` | Hi, [Martin], the [Premium] parcel I will send you on [Tuesday]. | Three chips: name, the better plan, the weekday. |
| cseed.name_label | `Meno` | Name | The word for a person's name; the app's "Názov" means a title, so it is not used here. |
| cseed.plan_label | `Plán` | Plan | The app's own word in its Choice example ("plán ▾") and in the Slovak 2.0 What's New. |
| cseed.plan_choices | `Základný, Premium` | Basic, Premium | The pair the Slovak 2.0 What's New already names (plán „Základný“ alebo „Premium“); masculine "Základný" agrees with both "plán" and "balíček"; 8 and 7 characters. |
| cseed.delivered | `Balíček bol doručený {date}.` | The little parcel was delivered {date}. | A plain passive, as a delivery notice is worded, with the reply's parcel word; a date needs no preposition in Slovak. 22 characters without the date. |
| iphone.3.h *built* | `Balíček bol doručený [23. novembra 2026].` | The little parcel was delivered [23 November 2026]. | The long date exactly as the facts give it, as one chip. |
| cseed.delivered_name | `Doručenie` | Delivery | One noun, the note's title on the card. |
| iphone.1.k | `Odpoveď napíšeš len raz` | The reply you will write only once | Perfective future, *ty*; no full stop, as Slovak headings take none. 23 of 24. |
| iphone.1.s | `Klepneš na ňu a Cutling sa opýta na meno.` | You tap on it and Cutling asks for the name. | "ňu" points back to the reply in the kicker; "klepnúť" and "opýta sa na meno" as the app and its What's New say them. 41 of 60. |
| iphone.2.k | `Tú istú pošleš aj ďalšiemu` | The same one you send to the next one too | Picks up frame 1's kicker as one thought; "ďalšiemu" leaves "customer" implied, as Slovak would. |
| iphone.2.s | `Mená použité predtým čakajú na klávesoch, stačí klepnúť.` | Names used before wait on the keys, a tap is enough. | "mená použité predtým" is the What's New's phrase; a passive participle, so no gendered past tense. |
| iphone.3.k | `Dátum doplní Cutling sám` | The date Cutling fills in by itself | "doplní … sám" as the Slovak 2.0 event text says it. |
| iphone.3.s | `Dnes, zajtra či o týždeň: dátum sedí v deň, keď ho vložíš.` | Today, tomorrow or in a week: the date is right on the day you paste it. | "sedí" is the everyday Slovak for "is right"; the colon introduces the explanation, as the rules allow. |
| iphone.4.k | `Aj to, čo sa u teba nemení:` | Also what does not change with you: | Leads into the list as one sentence; "u teba" carries "about you", so the chips need no possessive, which Slovak drops anyway. 27 of 34. |
| iphone.4.h | `[číslo účtu], [adresa] a [podpis].` | [account number], [address] and [signature]. | Shortest names, matching the cutlings in the capture below (Bankový účet, Domáca adresa, E-mailový podpis); lowercase after the colon; nominative because "čo" is the subject. 28 of 50. |
| iphone.4.s | `Z klávesnice Cutling ich máš kdekoľvek na jedno klepnutie.` | From the Cutling keyboard you have them anywhere at a single tap. | "na jedno klepnutie" is the idiom for one tap away; "kdekoľvek" echoes the store subtitle "Kopírovať a vložiť kdekoľvek". 58 of 60. |
| iphone.5.k | `Zmestí sa všetko` | Everything fits | The idiom for "there is room for all of it". |
| iphone.5.h | `[5 000] cutlingov` | [5,000] cutlings | Genitive plural after 5 and up, as the What's New writes "5 000 textových cutlingov"; n5000 with its no-break space; a noun phrase, so no full stop. |
| iphone.5.s | `Doteraz bol limit 100 a každý cutling pojme celý e-mail.` | Until now the limit was 100, and each cutling holds a whole e-mail. | "limit" is the app's own word (Limit textu); "pojme" is the verb for capacity; "e-mail" spelled as the What's New spells it. |
| iphone.6.k | `iPhone, iPad a Mac` | iPhone, iPad and Mac | A plain list, so no case endings are needed. |
| iphone.6.h | `Zaplatíš len [raz]` | You will pay only [once] | Chip on "raz" (once); 16 of 18; no full stop, as a heading. |
| iphone.6.s | `Jeden nákup na všetky tri. Účet ani predplatné netreba.` | One purchase for all three. No account or subscription needed. | "netreba" is the spoken "no need", instead of the translated "Žiadny účet. Žiadne predplatné." pattern. |
| mac.1.k | `Napíšeš raz, pošleš každému` | You write once, you send to everyone | Two clauses joined by a comma, Slovak's own rhythm for this. |
| mac.1.s | `Odpoveď vyberieš cez {cmd} a krátky formulár sa pred vložením opýta na meno a plán.` | You pick the reply with ⌘⇧V, and before pasting a short form asks for the name and the plan. | Names the two fields the form shows (Meno, Plán); "cez ⌘⇧V" and "pred vložením" as the Mac What's New says them. |
| mac.2.k | `Nech píšeš kdekoľvek` | Wherever you are writing | Concessive "nech", the natural "no matter where". |
| mac.2.h | `{cmd}` | ⌘⇧V | As the brief fixes it. |
| mac.2.s | `Tvoje cutlingy a história schránky sa otvoria nad každou aplikáciou.` | Your cutlings and the clipboard history open over every app. | "história schránky" matches the picker's "História" tab and the Slovak store description. |
| mac.3.k | `História schránky vynechá` | The clipboard history leaves out | The row of dots below reads as the object: "leaves out ••••••••••". |
| mac.3.s | `Nič, čo správca hesiel skryje, sa do histórie nedostane.` | Nothing a password manager hides gets into the history. | Slovak's double negative ("nič … nedostane"); "správca hesiel" is the store description's word. |
| mac.4.k | `Čo zmeníš na Macu,` | What you change on the Mac, | Leads into the headline as one sentence; "na Macu" as Apple's Slovak writes it. |
| mac.4.h | `zmení sa aj na [iPhone].` | changes on the [iPhone] too. | Chip on iPhone; "na iPhone" is the locative Apple's Slovak Pages listing uses ("na iPhone, iPade a Macu"). |
| mac.4.s | `Synchronizuje sa cez tvoj vlastný iCloud, bez nového účtu.` | It syncs through your own iCloud, without a new account. | "tvoj" lowercase, as the rules prescribe for advertising. |
| mac.5.k | `iPhone, iPad a Mac` | iPhone, iPad and Mac | Same as iphone.6. |
| mac.5.h | `Zaplatíš len [raz]` | You will pay only [once] | Same as iphone.6. |
| mac.5.s | `Jeden nákup na všetky tri. Účet ani predplatné netreba.` | One purchase for all three. No account or subscription needed. | Same as iphone.6. |
