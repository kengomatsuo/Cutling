# ms (Malay, Malaysia): Cutling 2.0 store frames, direction C (card ASG167)

Written blind from `C-words-brief.md` and the `ms` entry of `locale-facts.json`; the words file is
`fastlane/compose/creative/v2/words/ms.json`. Register: anda (the polite, neutral "you" of Malaysian Malay, written in
lower case), the form the app's own strings and the Malay listing's promotional text already use, kept in every line.
Spelling and words are Malaysian throughout (papan kekunci, tampal, ketik, akaun, e-mel, tarikh, kata laluan, borang),
with none of the Indonesian forms (papan ketik, tempel, akun, tanggal, kata sandi, a capital Anda). Rendered at store
size with the repo's C build on 2026-11-23: nothing clipped on iPhone, iPad or Mac. Square brackets mark the green
chips.

The first draft's reply, "Hai {name}, pesanan anda dipos {date} ini.", left "ini." alone on the last line of the
iPhone and iPad headline, and "Pesanan anda sampai pada {date}." stranded "pada" on a line of its own on iPad. Both were
rewritten so each built headline ends on its chip. Kickers carry no full stop; the built headlines are the shop owner's
own messages and end as sentences; the written headlines are phrases with no full stop; sublines are sentences. No
dashes, which Malay copy does not use to join clauses.

| Key | Malay | Back-translation (literal) | Choice |
|---|---|---|---|
| cseed.names | Aina, Amir, Mei Ling | (names) | Aina (f) and Amir (m) are common Malay names for the two headline customers; Mei Ling (f, Chinese Malaysian) is the third key, because a Malaysian shop's customers are mixed. Four letters each in the headlines keeps the reply short. |
| cseed.mac_name | Ravi | (name) | An Indian Malaysian man's name, the fourth community a Malaysian seller writes to. |
| cseed.reply | Hai {name}, pesanan dipos hari {date}. | Hi {name}, order posted day {date}. | "hari Selasa" is the grammatical frame for the app's bare weekday ("on Tuesday"), and it ends the sentence on the weekday chip. "dipos" is how Malaysian sellers say a parcel goes out by courier. The possessive "anda" is left out as sellers do in chat ("pesanan" is understood as yours). 36 characters filled. |
| cseed.reply_name | Pesanan dipos | Order posted | What a seller would call this saved reply. |
| cseed.mac_reply | Hai {name}, pakej {plan} dipos hari {date}. | Hi {name}, package {plan} posted day {date}. | The same shape as the iPhone reply, with the tier named by its package. 42 characters filled. |
| cseed.name_label | Nama | Name | The app's own word for Name. |
| cseed.plan_label | Pakej | Package | Malaysians say "pakej" for a tier they buy ("pakej asas" from telcos, the government's Pakej Perpaduan); "pelan" is a telco contract word, and a plan cannot be "dipos" (posted) while a package can. |
| cseed.plan_choices | Asas, Premium | Basic, Premium | "Pakej asas" is the usual Malaysian name for the basic tier; "Premium" is the loan Malaysians use for the better one. |
| cseed.delivered | Diterima pada {date}. | Received on {date}. | Delivery-receipt wording. "Sampai pada 23 November" with no subject can read as "until 23 November", and a short lead keeps "pada" on the line above the long date chip on every device. |
| cseed.delivered_name | Pesanan diterima | Order received | Names the note with the verb the note itself uses. |
| C.iphone.1.k | Ditulis sekali sahaja | Written once only | A passive whose subject is the reply right under it; "sahaja" is the written form of "only". 21 of 24. |
| C.iphone.1.h (built) | Hai [Aina], pesanan dipos hari [Selasa]. | Hi [Aina], order posted day [Tuesday]. | Built from cseed.reply. |
| C.iphone.1.s | Ketik balasan tersimpan dan Cutling meminta nama pelanggan. | Tap saved reply and Cutling asks-for name customer. | "ketik" is the app's (and Apple's Malay) verb for tap; "balasan tersimpan" follows the app's "cutling tersimpan". 59 of 60. |
| C.iphone.2.k | Dihantar lagi kepada pelanggan seterusnya | Sent again to customer next | Pairs with frame 1's "Ditulis": the two passives read "written once" and "sent again". Fits one line. |
| C.iphone.2.h (built) | Hai [Amir], pesanan dipos hari [Selasa]. | Hi [Amir], order posted day [Tuesday]. | Built from cseed.reply. |
| C.iphone.2.s | Nama yang pernah anda taip sedia sebagai kekunci sekali ketik. | Names that ever you typed ready as keys one tap. | "anda taip" is the standard object-first passive with "anda"; "kekunci" is a keyboard key and "sekali ketik" one tap. |
| C.iphone.3.k | Cutling mengisi tarikh sendiri | Cutling fills-in date by-itself | "isi" (fill in) is the verb of the 2.0 feature itself. |
| C.iphone.3.h (built) | Diterima pada [23 November 2026]. | Received on [23 November 2026]. | Built from cseed.delivered with the long date. |
| C.iphone.3.s | Hari ini, esok atau seminggu lagi, dikira dari hari ia ditampal. | Today, tomorrow or a-week more, counted from day it pasted. | "Hari ini", "Esok" and "Seminggu lagi" are the app's own menu words; "dikira dari" says the date is worked out on the day of pasting. |
| C.iphone.4.k | Dan butiran diri yang kekal sama | And details self that stay same | "butiran diri" is the heading Malaysians know from forms for personal particulars. 32 of 34. |
| C.iphone.4.h | [Akaun bank], [alamat rumah] dan [tandatangan] anda | [Bank account], [home address] and [signature] your | The chips use the app's own cutling names (Akaun Bank, Alamat Rumah, Tandatangan E-mel). Malay puts the possessive "anda" once after the list, outside the chips because Cutling does not type it. 45 of 50. |
| C.iphone.4.s | Satu ketikan di papan kekunci Cutling, dalam mana-mana app. | One tap on keyboard Cutling, in any app. | "app" as Apple's Malay App Store writes it; "di papan kekunci Cutling" as the app's strings say it. 59 of 60. |
| C.iphone.5.k | Ada ruang untuk semuanya | There-is room for all-of-it | Plain spoken phrasing. |
| C.iphone.5.h | [5,000] Cutling | [5,000] Cutling(s) | A Malay noun does not change after a number, and the facts give "Cutling" for one and for many. |
| C.iphone.5.s | Dulu hanya 100, dan setiap satu boleh memuatkan e-mel penuh. | Before only 100, and each one can hold email full. | "memuatkan" (hold, contain) is the standard verb for a container's room. 60 characters. |
| C.iphone.6.k | Untuk iPhone, iPad dan Mac | For iPhone, iPad and Mac | No serial comma, as Malay writes lists. |
| C.iphone.6.h | Hanya bayar [sekali] | Only pay [once] | "Bayar sekali sahaja" runs to 19 characters; this says the same in 18 and ends on the chip. |
| C.iphone.6.s | Satu pembelian untuk ketiga-tiganya, tanpa akaun atau langganan. | One purchase for all-three-of-them, without account or subscription. | "langganan" is the word Malaysian App Store users see for a subscription; "tanpa ... atau ..." is how Malay says neither. |
| C.mac.1.k | Tulis sekali, hantar kepada semua | Write once, send to all | Imperatives, the usual voice of a Malay tagline. |
| C.mac.1.h (built) | Hai [Ravi], pakej [Premium] dipos hari [Selasa]. | Hi [Ravi], package [Premium] posted day [Tuesday]. | Built from cseed.mac_reply. |
| C.mac.1.s | Pilih balasan dengan {cmd} dan isi borang ringkas sebelum ia ditampal. | Pick reply with ⌘⇧V and fill form short before it pasted. | The short form asking for the blanks is said from the reader's side (you fill it); "borang" is the Malaysian word for a form. |
| C.mac.2.k | Di mana sahaja anda menaip | Wherever you type | The Malaysian spelling of "wherever". The prose scanner flags "di mana" because it exempts only the Indonesian "di mana saja"; this is not the relative-clause calque that rule is for. |
| C.mac.2.h | {cmd} | ⌘⇧V | As the brief fixes it. |
| C.mac.2.s | Cutling anda dan apa yang baru disalin muncul di atas mana-mana app. | Cutling(s) your and what that just copied appear on top of any app. | "muncul di atas" (appear on top of) describes the picker opening over the app. |
| C.mac.3.k | Sejarah papan keratan tidak menyimpan | History clipboard does not keep | "Sejarah papan keratan" is the app's own name for clipboard history; the row of dots reads as the object of "tidak menyimpan". Fits one line. |
| C.mac.3.s | Apa-apa yang ditandakan sulit oleh pengurus kata laluan akan dilangkau. | Anything that marked confidential by manager password will be-skipped. | The app's own Settings sentence for this behaviour, word for word, so the frame and the setting agree. |
| C.mac.4.k | Ubah sesuatu pada Mac anda | Change something on Mac your | "pada" before a device, as the app writes "pada Mac ini". |
| C.mac.4.h | Ia turut berubah pada [iPhone] | It also changes on [iPhone] | "Ia" (it) keeps the changed thing as the subject rather than the phone. |
| C.mac.4.s | Disegerakkan melalui iCloud anda sendiri, tanpa perlu mendaftar akaun. | Synced through iCloud your own, without need register account. | "disegerakkan" and "iCloud anda sendiri" are the app's words; "mendaftar akaun" is how Malaysians say sign up. |
| C.mac.5.k | Untuk iPhone, iPad dan Mac | For iPhone, iPad and Mac | Reused from iPhone 6. |
| C.mac.5.h | Hanya bayar [sekali] | Only pay [once] | Reused from iPhone 6. |
| C.mac.5.s | Satu pembelian untuk ketiga-tiganya, tanpa akaun atau langganan. | One purchase for all-three-of-them, without account or subscription. | Reused from iPhone 6. |
