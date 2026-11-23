# th (Thai): words for the 2.0 store frames (ASG167)

Written from `C-words-brief.md` and the `th` entry of `locale-facts.json` (weekday `วันอังคาร`, long date
`23 พฤศจิกายน 2569`, `5,000`, `100`); the file is `fastlane/compose/creative/v2/words/th.json`. Rendered for iPhone, iPad
and Mac with `python3 build.py th C` and measured line by line in Chrome 158: every line breaks between phrases and
nothing overflows.

Register: the app's own lines speak the way Apple Thailand and the app's Thai listing do: plain, friendly written Thai,
คุณ where a pronoun is needed, and no ครับ/ค่ะ, the gendered spoken particles that store copy leaves out. The shop
owner's saved replies are the one exception, because they are the owner's own chat voice: คุณ + the customer's nickname,
the shop calling itself ทางร้าน, closing on นะคะ, as Thai online shops write to buyers ("ทางร้านจะจัดส่งสินค้าให้วันนี้นะคะ"
is a real shop's post). นะคะ is the female speaker's particle and the default voice of Thai shop admins; a man would
write นะครับ. คุณ fits a customer of either gender, so one saved reply serves every buyer.

Product words are the app's own Thai strings: คัตลิง (the app and the items, as `product_terms` gives it), คีย์บอร์ดคัตลิง,
ช่องว่าง (blanks), วาง (paste), วันนี้ / พรุ่งนี้ / อีก 1 สัปดาห์ (the app's date options), ประวัติคลิปบอร์ด,
ตัวจัดการรหัสผ่าน…ระบุว่าเป็นความลับ (the Mac setting's wording), แพ็กเกจ (the app's word for Plan), ปุ่ม (a key), and the
onboarding's ซิงก์ผ่าน iCloud ของคุณเอง and ไม่ต้องมีบัญชี.

Punctuation is Thai: no full stop, a space between clauses and around Latin words and numerals, and commas only between
Apple's product names, as Apple Thailand writes "iPhone, iPad หรือ Mac". ๆ is written against its word (สั้นๆ) so it can
never start a line. Digits are Arabic, as the facts give them.

Line breaks: Thai has no spaces between words, and Chrome breaks it at any dictionary word boundary. The first render
left คะ alone on the last line of the reply, จบ and ด้วย alone on headline lines, and split ทาง|ร้าน, จะไม่|หลุด,
ไม่มีค่า|รายเดือน and ในแอป|ไหนก็ได้; Chrome's `word-break: auto-phrase` and `keep-all` change nothing for Thai (tested). So in every headline
and subline of the file, the characters inside a phrase are joined with U+2060 WORD JOINER. A line can break only at a
space, or at a U+200B ZERO WIDTH SPACE where the reply may break with no space shown (after จะ and before the date on
iPhone; after จะ and after the plan on Mac). U+00A0 holds อีก 1 สัปดาห์, แค่ 100, กด ⌘⇧V แล้ว…, ฟอร์มสั้นๆ จะ…, บน iPhone,
ผ่าน iCloud ของคุณ and 5,000 คัตลิง together. All three are invisible and change no glyph width (measured, Sathu and
Thonburi). Kickers, names, labels and plan names have none. To edit a line, write it plainly, then put U+2060 between
every two characters inside each phrase, except before a combining mark or Sara Am (ำ), which shape with the consonant
before them. The table shows the visible text.

How the built frames break, measured: iPhone 1 and 2 `คุณ[แนน] / ทางร้านจะ / ส่งของให้ / [วันอังคาร]นะคะ` (the same
for บอล; the fit script takes the type one step down, 196 to 188 px, for the last line); iPad 1 and 2
`คุณ[แนน] ทางร้านจะ / ส่งของให้ / [วันอังคาร]นะคะ`; Mac 1 `คุณ[ต้น] ทางร้านจะ / ส่งแพ็กเกจ[พรีเมียม] / ให้[วันอังคาร]นะคะ`.
A Thai chip in Sathu is 1.36 em tall with its padding, so `build.py` now sets Thai headline lines 1.42 em apart (it was
1.3): Mac 1 and frame 4 stack one chip over another, and at 1.3 they ran 7 to 9 px into each other and the tone marks of
ร้ and ให้ met the chip above. At 1.42 every stacked pair keeps 10 px apart, measured.

`[x]` is a green chip; rows marked *built* are put together by the build from the seed.

| Key | String | Back-translation | Choice |
|---|---|---|---|
| cseed.names | แนน, บอล, พลอย | Nan, Ball, Ploy | Nicknames (ชื่อเล่น), the names Thai customers go by in chat and the ones a shop calls them; among the most common, female, male, female |
| cseed.mac_name | ต้น | Ton | A common male nickname |
| cseed.reply | คุณ{name} ทางร้านจะส่งของให้{date}นะคะ | Khun {name}, the shop will send the things to you {date}, na-kha. | ส่งของ is the everyday seller's verb, warmer than จัดส่งสินค้า; the weekday follows ให้ bare, as shops write จัดส่งสินค้าให้วันนี้; the sentence ends on its particle, with no full stop. 38 characters filled |
| cseed.reply_name | แจ้งส่งของ | Shipping notice | The owner's short label: แจ้ง (notify) + ส่งของ (sending the goods) |
| cseed.mac_reply | คุณ{name} ทางร้านจะส่งแพ็กเกจ{plan}ให้{date}นะคะ | Khun {name}, the shop will send the {plan} package to you {date}, na-kha. | The iPhone reply with the plan in it; แพ็กเกจ is the tier and also reads as the parcel going out. 50 characters filled |
| cseed.name_label | ชื่อ | Name | The app's string for Name |
| cseed.plan_label | แพ็กเกจ | Package | The app's string for Plan, and the word Thai buyers use for a tier (phone and internet packages) |
| cseed.plan_choices | เบสิก, พรีเมียม | Basic, Premium | The loanword pair Thai pricing pages use, in Royal Institute spelling |
| cseed.delivered | จัดส่งสำเร็จเมื่อวันที่ {date} | Delivery succeeded on the date {date} | Worded like a delivery status; a Thai day number takes วันที่ before it. 24 characters without the date |
| cseed.delivered_name | แจ้งของถึง | Arrival notice | Pairs with แจ้งส่งของ |
| C.iphone.1.h *built* | คุณ[แนน] ทางร้านจะส่งของให้[วันอังคาร]นะคะ | Khun [Nan], the shop will send the things to you [Tuesday], na-kha. | The vocative stands on its own line, as a chat greeting reads |
| C.iphone.1.k | เขียนแค่ครั้งเดียว | Write it just once | แค่ (just, only) carries the brief's "only one time" |
| C.iphone.1.s | แตะคำตอบที่บันทึกไว้ คัตลิงจะถามชื่อก่อนพิมพ์ | Tap the saved reply, and Cutling asks the name before it types. | คำตอบ is the 2.0 release notes' word for the reply (เขียนคำตอบครั้งเดียว); ถาม is the app's verb (ถามทุกครั้ง, Ask Each Time) |
| C.iphone.2.h *built* | คุณ[บอล] ทางร้านจะส่งของให้[วันอังคาร]นะคะ | Khun [Ball], the shop will send the things to you [Tuesday], na-kha. | The same sentence for the next customer, broken exactly as frame 1 |
| C.iphone.2.k | ส่งซ้ำให้ลูกค้าคนต่อไป | Send it again to the next customer | ส่งซ้ำ (send again) answers frame 1's เขียนแค่ครั้งเดียว beside it |
| C.iphone.2.s | ชื่อที่เคยใช้มีปุ่มรอไว้ให้แล้ว แค่แตะก็เลือกได้ | The names you used before already have keys waiting for you; just tap to pick one. | ปุ่ม is the app's word for a key (ทุกปุ่มพิมพ์ได้) |
| C.iphone.3.h *built* | จัดส่งสำเร็จเมื่อวันที่ [23 พฤศจิกายน 2569] | Delivery succeeded on the date [23 November 2569] | Breaks before the date chip, which keeps the Buddhist Era year the app writes |
| C.iphone.3.k | คัตลิงใส่วันที่ให้เอง | Cutling puts the date in for you, by itself | ให้เอง is "for you, on its own" |
| C.iphone.3.s | วันนี้ พรุ่งนี้ หรืออีก 1 สัปดาห์ ถูกต้องเสมอไม่ว่าจะวางวันไหน | Today, tomorrow or in 1 week: always right, whichever day you paste. | The three options in the app's own labels |
| C.iphone.4.k | และข้อมูลของคุณที่ไม่เคยเปลี่ยน | And your details that never change | ของคุณ gives the three chips their possessive once, as Thai would not repeat it on each |
| C.iphone.4.h | ทั้ง[เลขบัญชี] [ที่อยู่] และ[คำลงท้าย] | All of [account number], [address] and [closing line] | ทั้ง…และ… joins kicker and headline into one sentence; เลขบัญชี is the listing's own word, คำลงท้าย the closing line of a letter or email (ขอแสดงความนับถือ); spaces, not commas, between Thai list items |
| C.iphone.4.s | แต่ละอย่างแค่แตะเดียวจากคีย์บอร์ดคัตลิง ในแอปไหนก็ได้ | Each one is just one tap from the Cutling keyboard, in any app. | แค่แตะเดียว is the listing description's phrase, ในแอปไหนก็ได้ its promotional text's |
| C.iphone.5.k | มีพื้นที่พอสำหรับทุกอย่าง | There's room enough for everything | พื้นที่ is the app's word for room (พื้นที่อีกมาก) |
| C.iphone.5.h | [5,000] คัตลิง | [5,000] cutlings | The number before the noun with no classifier, as the app's grid writes 8 คัตลิง |
| C.iphone.5.s | จากเดิมแค่ 100 และแต่ละอันยาวพอใส่อีเมลได้ทั้งฉบับ | Up from just 100, and each one is long enough to hold a whole email. | จากเดิม and อีเมลทั้งฉบับ are the 2.0 release notes' words |
| C.iphone.6.k | ใช้ได้ทั้ง iPhone, iPad และ Mac | Works on iPhone, iPad and Mac | Commas between the product names, as Apple Thailand writes them |
| C.iphone.6.h | จ่าย[ครั้งเดียว] | Pay [once] | The chip on ครั้งเดียว; จ่ายครั้งเดียวจบ ("pay once, done") was the first version, but จบ wrapped alone onto a second line on iPhone and Mac |
| C.iphone.6.s | ซื้อทีเดียวใช้ได้ครบทั้งสามเครื่อง ไม่ต้องมีบัญชี ไม่มีค่ารายเดือน | Buy it in one go and use it on all three devices; no account needed, no monthly fee. | ทีเดียว keeps from repeating the headline's ครั้งเดียว; ไม่มีค่ารายเดือน is how Thai buyers say "no subscription"; ไม่ต้องมีบัญชี is the app's own line |
| C.mac.1.h *built* | คุณ[ต้น] ทางร้านจะส่งแพ็กเกจ[พรีเมียม]ให้[วันอังคาร]นะคะ | Khun [Ton], the shop will send the [Premium] package to you [Tuesday], na-kha. | Three lines, each a phrase |
| C.mac.1.k | เขียนครั้งเดียว ส่งได้ทุกคน | Write once, send to everyone | Two four-syllable halves, the rhythm of a Thai slogan |
| C.mac.1.s | กด {cmd} แล้วเลือกคำตอบ ฟอร์มสั้นๆ จะให้กรอกช่องว่างก่อนวาง | Press ⌘⇧V and pick the reply; a short form has you fill in the blanks before it pastes. | กด %@ is the app's Mac wording; กรอกช่องว่าง is the everyday "fill in the blanks" |
| C.mac.2.k | ไม่ว่าจะพิมพ์อยู่ที่ไหน | Wherever you are typing | Leads into the keys under it |
| C.mac.2.h | {cmd} | ⌘⇧V | Fixed by the brief |
| C.mac.2.s | คัตลิงของคุณและสิ่งที่คัดลอกล่าสุด เปิดขึ้นมาบนแอปไหนก็ได้ | Your cutlings and the things you copied last open up over any app. | คัดลอกล่าสุด follows the app's ข้อความที่คุณคัดลอกล่าสุด |
| C.mac.3.k | ประวัติคลิปบอร์ดไม่เก็บ | Your clipboard history does not keep | The row of dots under it is the object: does not keep •••••••••• |
| C.mac.3.s | อะไรที่ตัวจัดการรหัสผ่านระบุว่าเป็นความลับ จะไม่หลุดเข้าประวัติเลย | Anything a password manager marks as secret never slips into the history. | The app's own wording for concealed items; หลุด (slip out, leak) is the word for passwords |
| C.mac.4.k | แก้อะไรบน Mac | Change anything on the Mac | แก้อะไร…ก็… is the Thai "whatever you change…, …" |
| C.mac.4.h | บน [iPhone] ก็เปลี่ยนตาม | on [iPhone] it changes to match | ก็…ตาม (follows suit) replaced an ending in ด้วย, which wrapped alone onto a line |
| C.mac.4.s | ซิงก์ผ่าน iCloud ของคุณเอง ไม่ต้องมีบัญชี | Syncs through your own iCloud, with no account needed. | The onboarding's two lines; ซิงก์ is the spelling most of the app uses |
| C.mac.5.k | ใช้ได้ทั้ง iPhone, iPad และ Mac | Works on iPhone, iPad and Mac | Same as iPhone 6 |
| C.mac.5.h | จ่าย[ครั้งเดียว] | Pay [once] | Same as iPhone 6 |
| C.mac.5.s | ซื้อทีเดียวใช้ได้ครบทั้งสามเครื่อง ไม่ต้องมีบัญชี ไม่มีค่ารายเดือน | Buy it in one go and use it on all three devices; no account needed, no monthly fee. | Same as iPhone 6 |
