# fi (Finnish): Cutling 2.0 store frames, direction C (card ASG167)

Written blind from `C-words-brief.md` and the `fi` entry of `locale-facts.json`; the words file is
`fastlane/compose/creative/v2/words/fi.json`. Register: sinä (informal singular "you"), the form the Finnish App Store
listing and the app already use, kept in every line. Rendered at store size with the repo's C build on 2026-11-23:
nothing clipped on iPhone, iPad or Mac. Square brackets mark the green chips.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | Aino | Aino (woman's name) | A classic Finnish name that was also the most given girls' name in 2020 and 2023; frame 1's customer. |
| cseed.names[1] | Mikko | Mikko (man's name) | A common Finnish man's name; frame 2's customer. |
| cseed.names[2] | Laura | Laura (woman's name) | A common Finnish woman's name; third key on the keyboard. |
| cseed.mac_name | Ville | Ville (man's name) | A common Finnish man's name; the filled Mac reply comes to 51 of 52 characters with it. |
| cseed.reply | Hei {name}, lähetyspäivä on {date}. | Hi {name}, shipping-day is {date}. | The app types the bare weekday "tiistai", and "on Tuesday" would need the ending "tiistaina", so the weekday is the predicate of "lähetyspäivä on" (the shipping day is), where the bare form is correct; comma after the name, as Kielitoimisto separates a form of address. |
| cseed.reply_name | Tilaus lähtee | Order leaves | What an owner calls the snippet; kept clear of "paketti", which is the plan blank's label. |
| cseed.mac_reply | Hei {name}, {plan}-paketin lähetyspäivä on {date}. | Hi {name}, {plan}-package's shipping-day is {date}. | Finnish joins a product name to a noun with a hyphen (Premium-paketti), so the plan stays uninflected; the weekday sits in the same construction as on iPhone. |
| cseed.name_label | Nimi | Name | The app's own word for Name. |
| cseed.plan_label | Paketti | Package | The app already translates Plan as "paketti", and Finnish services sell their tiers as packages. |
| cseed.plan_choices[0] | Perus | Basic | Same pair as the Finnish 2.0 release notes ("Perus tai Premium"). |
| cseed.plan_choices[1] | Premium | Premium | The loanword Finnish services use for the top tier. |
| cseed.delivered | Toimitettu {date}. | Delivered {date}. | How a delivery entry reads on a Finnish order note; "23. marraskuuta 2026" serves as the time expression without any ending. |
| cseed.delivered_name | Toimituspäivä | Delivery day | Names what the note fills in. |
| iphone 1 h (built) | Hei [Aino], lähetyspäivä on [tiistai]. | Hi [Aino], shipping-day is [Tuesday]. | Built from cseed.reply; 34 of 40 characters. |
| iphone 2 h (built) | Hei [Mikko], lähetyspäivä on [tiistai]. | Hi [Mikko], shipping-day is [Tuesday]. | Built from cseed.reply; 35 of 40. |
| iphone 3 h (built) | Toimitettu [23. marraskuuta 2026]. | Delivered [23rd of-November 2026]. | Built from cseed.delivered. |
| mac 1 h (built) | Hei [Ville], [Premium]-paketin lähetyspäivä on [tiistai]. | Hi [Ville], [Premium]-package's shipping-day is [Tuesday]. | Built from cseed.mac_reply; the hyphen follows the plan chip. |
| C.iphone.1.k | Kirjoitat vain kerran. | You-write only once. | A plain statement in the sinä form; 22 of 24. |
| C.iphone.1.s | Kun napautat vastausta, Cutling kysyy ensin nimen. | When you-tap the-reply, Cutling asks first the-name. | "ensin" (first) says it asks before it types; 50 of 60. |
| C.iphone.2.k | Sama vastaus seuraavalle. | Same reply to-the-next-one. | Verbless, the way Finnish ad lines often run; the new name in the headline shows who "the next one" is. |
| C.iphone.2.s | Aiemmin käyttämäsi nimet ovat yhden napautuksen päässä. | Earlier you-used names are one tap's distance away. | "yhden napautuksen päässä" is the idiom the Finnish listing already uses for "one tap away". |
| C.iphone.3.k | Päivämäärät hoituvat itsestään. | The-dates take-care-of themselves. | The everyday idiom "hoitua itsestään" (sort itself out). |
| C.iphone.3.s | Tänään, huomenna tai viikon päästä: päivämäärä on aina oikein, kun liität. | Today, tomorrow or a week from-now: the-date is always right, when you-paste. | The three options are the app's own labels (Tänään, Huomenna, Viikon päästä). |
| C.iphone.4.k | Ja se, mikä ei muutu: | And that, which doesn't change: | Leads into the list as one sentence; the colon before a list is ordinary Finnish punctuation; 21 of 34. |
| C.iphone.4.h | [tilinumerosi], [osoitteesi] ja [allekirjoituksesi]. | [your-account-number], [your-address] and [your-signature]. | Possessive suffix -si on each; "tilinumero" is what Finns call a bank account number, and "allekirjoitus" is the mail apps' word for the sign-off block; no comma before "ja"; 46 of 50. |
| C.iphone.4.s | Napautus Cutling-näppäimistöllä riittää joka sovelluksessa. | A-tap on-the-Cutling-keyboard suffices in-every app. | "Cutling-näppäimistö" as in the Finnish release notes; 59 of 60. |
| C.iphone.5.k | Tilaa riittää kaikelle. | Room suffices for-everything. | Fixed idiom. |
| C.iphone.5.h | [5 000] cutlingia | [5 000] cutling (partitive) | After a number Finnish uses the partitive singular, so the plural "Cutlingit" becomes "cutlingia", lowercase as in the app's own "Tilaa %@ cutlingille"; the number keeps the facts' no-break space. |
| C.iphone.5.s | Ennen raja oli 100, ja jokaiseen mahtuu kokonainen sähköposti. | Before the-limit was 100, and into-each fits a-whole email. | Comma before "ja" because both halves are complete clauses (Kielitoimisto). |
| C.iphone.6.k | iPhone, iPad ja Mac. | iPhone, iPad and Mac. | No serial comma in Finnish. |
| C.iphone.6.h | Maksat [kerran]. | You-pay [once]. | The chip goes on "kerran" (once); 14 of 18. |
| C.iphone.6.s | Yksi ostos kattaa kaikki kolme ilman tiliä ja kuukausimaksuja. | One purchase covers all three without account and monthly-fees. | "kuukausimaksu" is the buyer's word for a subscription you keep paying, and it avoids "tilaus", which also means the shop's order. |
| C.mac.1.k | Kirjoita kerran, lähetä kaikille. | Write once, send to-everyone. | Two imperatives joined by a comma, a common Finnish ad shape. |
| C.mac.1.s | Paina {cmd} ja valitse vastaus, niin lyhyt lomake kysyy ensin puuttuvat tiedot. | Press {cmd} and choose the-reply, so a-short form asks first the-missing details. | "kysyy puuttuvat tiedot" is the everyday phrase for a form asking for what is missing. |
| C.mac.2.k | Missä tahansa kirjoitatkin. | Wherever you-happen-to-be-writing. | The -kin ending gives "wherever". |
| C.mac.2.h | {cmd} | (the keys ⌘ ⇧ V) | As given. |
| C.mac.2.s | Cutlingisi ja viimeksi kopioimasi avautuvat minkä tahansa sovelluksen päälle. | Your-cutlings and what-you-last-copied open on-top-of any app. | "kopioimasi" (what you copied) as the app itself writes it ("Tallenna kopioimasi"). |
| C.mac.3.k | Leikepöydän historia ohittaa | The-clipboard's history skips | The dots below read as the object of "ohittaa"; "Leikepöydän historia" is the app's own name for the feature. |
| C.mac.3.s | Salasanojen hallintaohjelman piilottamat tiedot eivät koskaan päädy historiaan. | Details hidden by-a-password-management-program never end-up in-the-history. | "salasanojen hallintaohjelma" is the term Finland's National Cyber Security Centre uses. |
| C.mac.4.k | Kun muokkaat cutlingia Macilla, | When you-edit a-cutling on-the-Mac, | "Macilla" for what you do on a device; "cutlingia" is more concrete than "jotain" (something). |
| C.mac.4.h | se muuttuu myös [iPhonessa]. | it changes also [in-the-iPhone]. | "iPhonessa" for where the data sits, as Apple's Finnish pages write it; the chip covers the whole inflected word. |
| C.mac.4.s | Cutlingit synkronoituvat oman iCloudisi kautta, eikä tiliä tarvitse luoda. | The-cutlings sync via your-own iCloud, and-no account needs to-be-created. | "oman iCloudisi kautta" as in the app's onboarding; comma before "eikä". |
| C.mac.5.k | iPhone, iPad ja Mac. | iPhone, iPad and Mac. | Same as iPhone 6. |
| C.mac.5.h | Maksat [kerran]. | You-pay [once]. | Same as iPhone 6. |
| C.mac.5.s | Yksi ostos kattaa kaikki kolme ilman tiliä ja kuukausimaksuja. | One purchase covers all three without account and monthly-fees. | Same as iPhone 6. |
