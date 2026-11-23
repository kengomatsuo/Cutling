# Indonesian (id) words for the 2.0 store frames, direction C (card ASG167)

Written from `docs/aso/screens-2.0/C-words-brief.md` and the `id` entry of `locale-facts.json` (`Selasa`,
`23 November 2026`, `5.000`, `100`, product word `cutling`). File: `fastlane/compose/creative/v2/words/id.json`.

**How it was written.** A separate Claude process with no tools wrote every string. It was given the brief, the
facts and the words Cutling already uses in Indonesian (store listing, 2.0 release notes, the 2.0 in-app event, and
the "Every app" preview's lines and seed), and never another language's lines. The house rule asks for Fable, but
this account's Fable limit runs until November 29, so the writer ran on Opus 5.5 at max effort.

**Register.** `kamu`, everyday words in standard spelling, the voice Cutling's Indonesian store page, release
notes and preview already use. The app's own interface says `Anda`, so the drawn key "Ketik di Keyboard Biasa
Anda" sits under `kamu` lines; that split is older than 2.0. The shop owner's reply is the preview's own sentence,
and the customers are names from the preview, so frame 1 and the video beside it in search show the same shop.
Indonesian online sellers call every customer "Kak", and the weekday works on its own after "kirim" as a time
word.

**Checked on the real frames.** All 17 frames were rendered through `build.py`'s direction C code, last against
the build that keeps every chip whole (C.py as of 13:21 on November 23). In the first draft, rendered before that
change, "Paket diterima pada {date}." broke the date chip on iPhone frame 3 into three pieces ("pada 23" /
"November" / "2026."). The writer dropped "pada", and the headline now reads "Paket diterima" over the whole date
on iPhone and iPad. Every limit in the brief holds: the reply fills to exactly 40 characters with either name,
and the Mac reply fills to 46.

**Left to the build.** Two last lines hold one word: "ya." under the reply on iPad frames 1 and 2, and "akun."
under Mac frame 4's subline. Both come from how the build breaks lines. The reply was kept because it is the
preview video's own sentence.

| Key | String | Back-translation | Choice |
|---|---|---|---|
| `cseed.names[0]` | Rina | Rina | Common woman's name taken from the app preview video's seed, so frame 1 and the video show the same shop. |
| `cseed.names[1]` | Yoga | Yoga | Common man's name from the video seed; chosen over Dimas because four letters keep the filled reply within 40 (Dimas makes it 41). |
| `cseed.names[2]` | Sari | Sari | Common woman's name from the video seed; appears only as the third name key. |
| `cseed.mac_name` | Dimas | Dimas | Man's name from the video seed; the Mac reply has room for five letters. |
| `cseed.reply` | Kak {name}, paketnya kami kirim {date} ya. | Kak [polite 'older sibling'] {name}, the-parcel we send {date} yeah. | The preview video's own reply; 'Kak' is how Indonesian sellers address any customer, and 'Selasa' stands bare after 'kirim' as a time word, needing no 'hari' or preposition; 40 filled with Rina or Yoga. |
| `cseed.reply_name` | Jadwal kirim | Schedule send | Same name as in the preview video ('shipping schedule'). |
| `cseed.mac_reply` | Kak {name}, Paket {plan} kami kirim {date} ya. | Kak {name}, Package {plan} we send {date} yeah. | Indonesian shops sell bundles as 'Paket Hemat' and 'Paket Premium' (the 2.0 release notes' example), so the plan follows 'Paket' with no suffix hanging off its chip; 46 filled. |
| `cseed.name_label` | Nama | Name | The blank's label in the preview video. |
| `cseed.plan_label` | Paket | Package | 'Paket' is the everyday word for a tier you buy (paket data, paket hemat). |
| `cseed.plan_choices[0]` | Hemat | Saver | The basic bundle as the release notes name it. |
| `cseed.plan_choices[1]` | Premium | Premium | The loanword Indonesian shops really use for the better bundle; the release notes' wording. |
| `cseed.delivered` | Paket diterima {date}. | Package received {date}. | Dropped 'pada' so 'Paket diterima' fills the first line and the date gets the next line to itself; a date with no preposition is normal in Indonesian chat and delivery notes. 'Tanda terima' still names it. |
| `cseed.delivered_name` | Tanda terima | Sign (of) receiving | The standard Indonesian word for a delivery receipt. |
| `C.iphone.1.k` | Cukup tulis sekali | Enough write once | 'Cukup' plus a bare verb is the everyday 'you only need to'; the reply under it is the implied object. |
| `C.iphone.1.h (built)` | Kak [Rina], paketnya kami kirim [Selasa] ya. | Kak Rina, the-parcel we send Tuesday yeah. | Built from reply with names[0]; chips on the name and the weekday. |
| `C.iphone.1.s` | Begitu kamu ketuk balasannya, Cutling tanya namanya dulu. | As-soon-as you tap the-reply, Cutling asks the-name first. | 'kamu' as on the rest of the page; bare 'tanya' and 'nama dulu' as the event card and video say it. |
| `C.iphone.2.k` | Lalu ke pembeli berikutnya | Then to buyer next | Picks up frame 1's kicker as the next beat; 'pembeli' is what small online sellers call their customers. |
| `C.iphone.2.h (built)` | Kak [Yoga], paketnya kami kirim [Selasa] ya. | Kak Yoga, the-parcel we send Tuesday yeah. | Built from reply with names[1]; the same sentence as frame 1 with a new name. |
| `C.iphone.2.s` | Nama yang pernah kamu pakai jadi tombol, tinggal ketuk. | Names that ever you use become keys, only-remains tap. | 'tinggal ketuk' is the idiomatic 'just tap'; 'tombol' is the usual word for a key. |
| `C.iphone.3.k` | Tanggal terisi sendiri | Date gets-filled by-itself | 'terisi sendiri' says the date fills itself in without a stiff di- passive. |
| `C.iphone.3.h (built)` | Paket diterima [23 November 2026]. | Package received [23 November 2026]. | Built from delivered with the long date as one chip; on iPhone and iPad it reads 'Paket diterima' over the whole date. |
| `C.iphone.3.s` | Hari ini, besok, seminggu lagi, benar kapan pun kamu tempel. | Day this, tomorrow, one-week more, right whenever you paste. | 'seminggu lagi' is the everyday 'a week from now'; 'kapan pun kamu tempel' carries 'right on the day it is pasted'. |
| `C.iphone.4.k` | Dan yang tak pernah berubah | And what not ever changes | Leads into the list with no colon, like every kicker; 'you' is carried by -mu on each chip. |
| `C.iphone.4.h` | [Nomor rekeningmu], [alamat rumahmu], [salam penutupmu] | Number account-your, address house-your, greeting closing-your | First two as the preview video says them; 'salam penutup' is the Indonesian term for a sign-off; no 'dan' so three labels fit 50 (counted without chip brackets). |
| `C.iphone.4.s` | Satu ketukan dari keyboard Cutling, di app apa pun. | One tap from keyboard Cutling, in app any. | House terms 'satu ketukan' and 'keyboard Cutling', and the video's 'app apa pun'. |
| `C.iphone.5.k` | Ada tempat untuk semuanya | There-is place for all-of-it | 'tempat' is the everyday word for room (semua ada tempatnya) and leaves 'muat' for the subline. |
| `C.iphone.5.h` | [5.000] cutling | 5,000 cutling | Dot as thousands separator; 'cutling' lowercase and unchanged in the plural, as in the release notes. |
| `C.iphone.5.s` | Dulu hanya 100, dan tiap cutling muat satu email utuh. | Before only 100, and each cutling fits one email whole. | 'hanya' over colloquial 'cuma'; 'satu email utuh' as in the release notes. |
| `C.iphone.6.k` | Di iPhone, iPad, dan Mac | On iPhone, iPad, and Mac | Comma before 'dan' as EYD writes a list. |
| `C.iphone.6.h` | Bayar [sekali] saja | Pay once only | Chip on 'sekali' (once); 'saja' makes 'only once' read at a glance. |
| `C.iphone.6.s` | Sudah termasuk ketiganya, tanpa akun dan tanpa langganan. | Already included the-three, without account and without subscription. | 'Sudah termasuk' is the everyday price phrase (harga sudah termasuk ongkir) and keeps 'sekali' from repeating under the headline. |
| `C.mac.1.k` | Tulis sekali untuk semua pembeli | Write once for all buyers | Echoes the iPhone's first kicker; 'untuk' avoids repeating 'kirim' from the headline. |
| `C.mac.1.h (built)` | Kak [Dimas], Paket [Premium] kami kirim [Selasa] ya. | Kak Dimas, Package Premium we send Tuesday yeah. | Built from mac_reply; chips on the name, the better plan and the weekday. |
| `C.mac.1.s` | Pilih balasan dengan {cmd}, lengkapi isiannya, lalu tempel. | Pick reply with ⌘⇧V, complete its-blanks, then paste. | 'isian' is the house word for a blank; ends on 'tempel', the button in the form ({cmd} counted as 5). |
| `C.mac.2.k` | Di mana pun kamu mengetik | In where-ever you type | Matches the video's 'di tempat kamu mengetik'; 'di mana pun' written apart as EYD spells it. |
| `C.mac.2.s` | Semua cutling dan yang baru kamu salin muncul di atas app apa pun. | All cutling and what just you copy appear on top-of app any. | 'yang baru kamu salin' in plain words, leaving 'riwayat papan klip' for frame 3. |
| `C.mac.3.k` | Riwayat papan klip melewatkan | History clipboard skips | Ends on the verb so the row of dots reads as its object; 'melewatkan' as the store description says it. |
| `C.mac.3.s` | Yang ditandai rahasia oleh pengelola kata sandi tak ikut tersimpan. | What is-marked secret by manager password not along stored. | The store description's 'ditandai rahasia oleh pengelola kata sandi'; 'tak ikut tersimpan' means it is not saved with the rest. |
| `C.mac.4.k` | Ubah di Mac-mu | Change on Mac-your | -mu hyphenated after a brand name, as the video writes 'iPhone-mu'. |
| `C.mac.4.h` | Ikut berubah di [iPhone] | Along changes on iPhone | 'ikut berubah' means it changes along with the Mac; chip on 'iPhone' with no suffix after it. |
| `C.mac.4.s` | Sinkron lewat iCloud-mu sendiri, tanpa membuat akun. | Sync via iCloud-your own, without making account. | 'sinkron' is the word Indonesian app listings use; 'tanpa membuat akun' says there is no account to create. |
| `C.mac.5.k` | Di iPhone, iPad, dan Mac | On iPhone, iPad, and Mac | Reused from iPhone frame 6. |
| `C.mac.5.h` | Bayar [sekali] saja | Pay once only | Reused from iPhone frame 6. |
| `C.mac.5.s` | Sudah termasuk ketiganya, tanpa akun dan tanpa langganan. | Already included the-three, without account and without subscription. | Reused from iPhone frame 6. |
