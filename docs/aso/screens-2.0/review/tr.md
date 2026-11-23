# tr: words for the 2.0 store frames, review

Written from `C-words-brief.md` and the tr facts, into `fastlane/compose/creative/v2/words/tr.json`. Every line speaks
to the buyer with sen, as Cutling's Turkish listing (description, promotional text, 2.0 release notes) and the app's
2.0 screens do. The shop owner says sen to the customer too: the reply opens with a bare first name, and the polite
"Elif Hanım" / "Mehmet Bey" would need a different reply for each gender. Suffixes on names take the apostrophe the
app's product terms use (’), with the vowel each name is said with, as Apple's Turkish pages write them (Mac’te,
iPhone’um, iCloud’da). Rendered through direction C at App Store sizes (iPhone, iPad, Mac) on tr's own captures: every
line fits, nothing is cut.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names | Elif, Mehmet, Zeynep | Elif, Mehmet, Zeynep | Common names of Turkish adults in their 20s to 40s, woman, man, woman; Mehmet looks nothing like Elif, so the name change between frames 1 and 2 shows at thumbnail size. |
| cseed.mac_name | Burak | Burak | A common man's name of the same generation. |
| cseed.reply | {name}, siparişin {date} yola çıkıyor! | {name}, your order sets out on the road {date}! | "Yola çıkıyor" is how a Turkish shop says a parcel leaves; the weekday stands bare as a time word ("Salı yola çıkıyor", like "Salı geliyorum"), so Salı is never inflected. "!" because a full stop reads cold in a chat message. |
| cseed.reply_name | Kargo bilgisi | Cargo info | "Kargo" is the everyday word for shipping and the courier; this is what a shop owner would call the quick reply. |
| cseed.mac_reply | {name}, {plan} paketin {date} yola çıkıyor! | {name}, your {plan} package sets out on the road {date}! | Same reply with the tier; "paket" means both the tier and the parcel, so "Premium paketin yola çıkıyor" reads as one thought. |
| cseed.name_label | İsim | Name | Picked over the form word "Ad": a two-letter "Ad," opening the sentence reads poorly as a blank, and the 2.0 release notes already say "isim". |
| cseed.plan_label | Paket | Package | The word Turkish buyers use for a tier they buy (Premium paket). |
| cseed.plan_choices | Standart, Premium | Standard, Premium | The usual Turkish pair, already in Turkish spelling; the 2.0 release notes use the same two. |
| cseed.delivered | {date} tarihinde teslim edildi. | Was delivered on the date {date}. | "tarihinde" (on the date of) takes the case ending, so "23 Kasım 2026" stays exactly as the app types it. |
| cseed.delivered_name | Teslim notu | Delivery note | Plain name for the note. |
| C.iphone.1.k | Bunu bir kez yazarsın. | You write this one time. | "Bunu" points at the reply under it; the aorist says this is how it always goes. 22 of 24. |
| C.iphone.1.h (built) | [Elif], siparişin [Salı] yola çıkıyor! | Elif, your order sets out on the road on Tuesday! | Built from the seed. 34 of 40. |
| C.iphone.1.s | Kayıtlı yanıta dokununca Cutling müşterinin ismini sorar. | When [you] touch the saved reply, Cutling asks the customer's name. | "dokununca" (on touching) keeps the verb last; "müşterinin ismini" because "Cutling ismi sorar" can be misread as "the name Cutling asks". 57 of 60. |
| C.iphone.2.k | Sıradaki müşteriye de aynısı. | To the next customer too, the same one. | How Turks order the same again ("bana da aynısı"); reads as the second half of frame 1. |
| C.iphone.2.h (built) | [Mehmet], siparişin [Salı] yola çıkıyor! | Mehmet, your order sets out on the road on Tuesday! | Built from the seed. 36 of 40. |
| C.iphone.2.s | Daha önce kullandığın isimler hazır, birine dokunman yeter. | The names you used before [are] ready, your touching one is enough. | "dokunman yeter" (a touch is all it takes) is the spoken way to say one-tap keys. |
| C.iphone.3.k | Tarihi Cutling kendisi yazar. | The date, Cutling writes it itself. | Cutling sits just before the verb, the Turkish focus slot: Cutling writes it, not you. |
| C.iphone.3.h (built) | [23 Kasım 2026] tarihinde teslim edildi. | Was delivered on the date 23 November 2026. | Built from the seed. |
| C.iphone.3.s | Bugünün, yarının ya da bir hafta sonrasının tarihi, yapıştırdığın gün doğru yazılır. | Today's, tomorrow's or a week later's date is written correctly on the day you paste. | One sentence ending on the verb; "bugünün tarihi" is the app's own name for the today blank. |
| C.iphone.4.k | Bir de hiç değişmeyenler: | And then the never-changing ones: | "Bir de" is the spoken "and then there's"; the colon hands over to the list. 25 of 34. |
| C.iphone.4.h | [IBAN’ım], [adresim] ve [imzam]. | My IBAN, my address and my signature. | First person, as the app names its own seed cutlings (Adresim); in Turkey the account number people paste is the IBAN, and an e-mail sign-off is an "imza". 26 of 50. |
| C.iphone.4.s | Her biri Cutling klavyesinden her uygulamaya tek dokunuşla. | Each one from Cutling's keyboard into every app with a single touch. | "-den ... -e" (from ... into) carries the movement with no verb, as Turkish taglines do. 59 of 60. |
| C.iphone.5.k | Hepsine yer var. | There is room for all of them. | Everyday idiom. |
| C.iphone.5.h | [5.000] Cutling. | 5,000 Cutling. | A noun after a number stays singular in Turkish ("5.000 şarkı"), so the plural Cutling’ler would be wrong here. |
| C.iphone.5.s | Eskiden 100 taneydi, üstelik her birine koca bir e-posta sığar. | Formerly it was 100 pieces, and what's more a whole e-mail fits into each one. | "100 taneydi" keeps 100 free of a suffix; "sığar" (fits) is the plain verb for room. |
| C.iphone.6.k | iPhone, iPad ve Mac | iPhone, iPad and Mac | A bare list as the label, so no name takes a suffix. |
| C.iphone.6.h | [Bir kez] ödersin. | You pay one time. | Chip on "Bir kez" (once). 16 of 18. |
| C.iphone.6.s | Tek satın alma üçünde de geçerli, hesap da abonelik de gerekmez. | A single purchase [is] valid on all three, neither an account nor a subscription is needed. | "üçünde de" points back to the three devices; "da ... de gerekmez" is Turkish's own neither-nor. |
| C.mac.1.k | Bir kez yaz, herkese gönder. | Write one time, send to everyone. | Two sen imperatives, the usual shape of a Turkish ad line. |
| C.mac.1.h (built) | [Burak], [Premium] paketin [Salı] yola çıkıyor! | Burak, your Premium package sets out on the road on Tuesday! | Built from the seed. 41 of 52. |
| C.mac.1.s | Yanıtı {cmd} ile seç, boşlukları kısa bir formda doldur ve yapıştır. | Choose the reply with ⌘⇧V, fill in the blanks in a short form and paste. | "ile" is a separate word, so the keys never carry a suffix; "boşluk" is the app's word for a blank; the form's own button says Yapıştır. |
| C.mac.2.k | Nerede yazıyorsan orada | Wherever you are writing, there | Leads into the keys below, which finish the sentence. |
| C.mac.2.s | Cutling’lerin ve son kopyaladıkların her uygulamanın üstünde açılır. | Your Cutlings and your last-copied things open on top of every app. | The product term Cutling’ler with sen's possessive. |
| C.mac.3.k | Pano geçmişi bunu kaydetmez: | The clipboard history does not record this: | Turkish puts the object before the verb, so "bunu" (this) stands for the dots under it; "Pano geçmişi" and "kaydet" are the app's own Mac words. It does not say "the only thing", because the history also skips transient and auto-generated items. |
| C.mac.3.s | Parola yöneticinin gizli işaretlediği hiçbir şey geçmişe düşmez. | Nothing your password manager marks hidden falls into the history. | "Parola" as Apple and the app say it; "geçmişe düşmez" (never lands in the record) is the idiom. |
| C.mac.4.k | Mac’inde değiştirdiğin her şey | Everything you change on your Mac | k and h read as one sentence. |
| C.mac.4.h | [iPhone’unda] da değişir. | changes on your iPhone too. | The suffix sits inside the chip: a green block ending before "’unda" would split the word in two. |
| C.mac.4.s | Kendi iCloud’unla eşitlenir, hesap açmana gerek yok. | It syncs with your own iCloud, there is no need for you to open an account. | "eşitlenir" is the verb of the app's iCloud Eşitleme setting. |
| C.mac.5.k | iPhone, iPad ve Mac | iPhone, iPad and Mac | Same as iPhone 6. |
| C.mac.5.h | [Bir kez] ödersin. | You pay one time. | Same as iPhone 6. |
| C.mac.5.s | Tek satın alma üçünde de geçerli, hesap da abonelik de gerekmez. | A single purchase [is] valid on all three, neither an account nor a subscription is needed. | Same as iPhone 6. |

Two things a Turkish reviewer will notice, both kept on purpose. Salı is capitalised because that is how the app
types the weekday; the Turkish Language Association lowercases a weekday that has no date with it, but everyday
writing capitalises it, and the chip must show what the app types. And "5.000 Cutling" is singular where the brief
asked for the plural word, because Turkish grammar requires it.
