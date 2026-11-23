# vi: words for the 2.0 store frames

Written blind from `C-words-brief.md` and the vi entry of `locale-facts.json`; file: `fastlane/compose/creative/v2/words/vi.json`.

Register: the reader is "bạn" in every line that needs a pronoun, as on the vi store page (promotional text, 2.0 release notes). The saved replies are the shop owner's own chat voice: the seller calls itself "shop", calls the customer by first name with "ơi", and ends on "nhé". MISA eShop's Zalo scripts for sellers use "shop", "bạn" and "nhé" this way ("bạn nhắn shop trong 7 ngày nhé"), and GHN's chatbot scripts also end on "nhé". The "ơi" call is my own choice for a reply inside an open chat. Product words are the app's own: "ô trống" (blank), "câu trả lời" (reply), "Lịch sử bộ nhớ tạm" (clipboard history), "Tên" (Name), "Dán" (Paste).

| Key | String | Back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | Thảo | Thảo (woman's name) | A very common woman's name; its "ả" shows the frame is Vietnamese at a glance. |
| cseed.names[1] | Tuấn | Tuấn (man's name) | A very common man's name, so frames 1 and 2 have one customer of each gender. |
| cseed.names[2] | Linh | Linh (woman's name, also used for men) | Among the most common given names. "Mai" was dropped because it also means "tomorrow" in a frame about dates. |
| cseed.mac_name | Minh | Minh (man's name, also used for women) | Very common; appears only on the Mac. |
| cseed.reply | {name} ơi, {date} shop gửi hàng nhé. → Thảo ơi, Thứ Ba shop gửi hàng nhé. | {name} [vocative], {date} the shop sends the goods, OK. | No anh/chị (Mr/Ms), so one reply fits a woman (frame 1) and a man (frame 2). "Thứ Ba" goes first as the time, the usual Vietnamese order, and needs no "vào" (on). It ends with a period: "nhé" already makes it warm. 34 characters filled. |
| cseed.reply_name | Báo gửi hàng | Notice: sending goods | What a seller would call a shipping message. "gửi hàng" (send goods) avoids "gửi đơn", which can also mean "submit an application". |
| cseed.mac_reply | {name} ơi, {date} shop gửi gói {plan} nhé. → Minh ơi, Thứ Ba shop gửi gói Nâng cao nhé. | {name} [vocative], {date} the shop sends the {plan} package, OK. | Same shape as the iPhone reply, so the two read as the same kind of message. "gói" means both "plan" and "parcel", so sending one sounds natural. 42 characters filled. |
| cseed.name_label | Tên | Name | The app's own word for "Name", and the {{Tên}} placeholder Vietnamese shop tools use. |
| cseed.plan_label | Gói | Plan / package | The usual Vietnamese word for a tier you buy (gói cước, gói dịch vụ). |
| cseed.plan_choices[0] | Cơ bản | Basic | Same pair the vi 2.0 release notes use as their example (Gói Cơ bản / Gói Nâng cao). |
| cseed.plan_choices[1] | Nâng cao | Advanced | 8 characters, at the limit. |
| cseed.delivered | Đơn hàng đã giao {date}. → Đơn hàng đã giao ngày 23 tháng 11, 2026. | Order delivered {date}. | Sellers write "đã giao" without the passive "được". The app's date already begins with "ngày" (day), so "vào ngày" would double it. |
| cseed.delivered_name | Báo đã giao | Notice: delivered | Pairs with "Báo gửi hàng". |
| C.iphone.1.k | Câu này chỉ viết một lần | This sentence is written only once | "Câu này" (this sentence) points at the reply below; frame 2 answers it with "Vẫn câu đó". 24 characters, at the limit. |
| C.iphone.1.s | Chạm vào câu trả lời đã lưu là Cutling hỏi tên ngay. | Tap the saved reply and Cutling asks for the name right away. | The spoken "chạm … là … ngay" (tap and right away) construction; "câu trả lời" as in the release notes. |
| C.iphone.2.k | Vẫn câu đó, gửi khách sau | Still that sentence, sent to the next customer | "gửi khách" (send to a customer) is seller wording. |
| C.iphone.2.s | Tên từng dùng đã nằm sẵn trên phím, một chạm là xong. | Names used before already lie ready on the keys, one tap and done. | "từng dùng" (once used) reads more natural than "đã dùng" (have used) for "used before". |
| C.iphone.3.k | Cutling tự điền ngày tháng | Cutling fills in dates by itself | "ngày tháng" is the everyday word for dates. |
| C.iphone.3.s | Hôm nay, ngày mai hay một tuần nữa, kể từ hôm bạn dán. | Today, tomorrow or a week on, counted from the day you paste. | "kể từ" rather than "tính từ": a line break after "tính từ" leaves a pair that also means "adjective". |
| C.iphone.4.k | Và cả những thứ không bao giờ đổi | And also the things that never change | Carries on from the frames before. Vietnamese marks no possessive on each item, so the list below needs no "của bạn" (your). |
| C.iphone.4.h | [Số tài khoản], [địa chỉ nhà] và [chữ ký email] | [Account number], [home address] and [email signature] | "Số tài khoản" means a bank account number in everyday speech (sellers say STK). "Địa chỉ nhà" and "Chữ ký email" are the cutling names on the vi keyboard capture right under this line. |
| C.iphone.4.s | Thứ nào cũng chỉ một chạm trên bàn phím Cutling, ở mọi app. | Any of them is just one tap on the Cutling keyboard, in every app. | "app", as the vi promotional text says it. |
| C.iphone.5.k | Đủ chỗ cho tất cả | Enough room for everything | Plain and short. |
| C.iphone.5.h | [5.000] Cutling | [5,000] Cutling | Number and product word exactly as locale-facts gives them; the capital C matches the "8 Cutling" count on the grid capture under it. |
| C.iphone.5.s | Trước đây chỉ 100, giờ mỗi cutling chứa được cả một email. | Before, only 100; now each cutling holds a whole email. | "giờ" (now) fixes the tense, which Vietnamese otherwise leaves open. Lowercase "cutling" mid-sentence, as the app writes it ("Tìm cutling"). |
| C.iphone.6.k | iPhone, iPad và Mac | iPhone, iPad and Mac | Device names as Apple writes them. |
| C.iphone.6.h | Chỉ trả [một lần] | Pay only [once] | "trả một lần" is the everyday term for paying in full at once (as against "trả góp", paying in instalments). 15 characters. |
| C.iphone.6.s | Dùng trên cả ba máy, không cần tài khoản, không gói đăng ký. | Use it on all three devices, no account needed, no subscription. | "gói đăng ký" is Apple Vietnam's and the press's word for a subscription (Settings > Đăng ký); "thuê bao" sounds like a phone contract. |
| C.mac.1.k | Viết một lần, gửi cho mọi người | Write once, send to everyone | Plain, matching the brief's "everyone". |
| C.mac.1.s | Nhấn {cmd} chọn câu trả lời, một khung nhỏ hỏi những gì cần điền rồi mới dán. | Press ⌘⇧V and pick the reply; a small box asks what needs filling in, and only then pastes. | "Nhấn" (press) as the Mac app's own strings use it. "khung" (box), not "ô", so that "ô" stays the word for a blank. |
| C.mac.2.k | Dù bạn đang gõ ở đâu | Wherever you are typing | Leads into the keys below it. |
| C.mac.2.h | {cmd} | ⌘⇧V | As the brief fixes it. |
| C.mac.2.s | Các cutling đã lưu và những gì vừa sao chép hiện ngay trên mọi app. | The saved cutlings and what you just copied appear right over any app. | "đã lưu" echoes the picker's "Đã lưu" tab in the capture. "Các" (plural) keeps "cutling đã lưu" from reading as "Cutling has saved". |
| C.mac.3.k | Lịch sử bộ nhớ tạm bỏ qua | Clipboard history skips [••••••••••] | The app's own name for the history. The dots under it read as what "bỏ qua" (skips) skips. |
| C.mac.3.s | Những gì trình quản lý mật khẩu đánh dấu ẩn không bao giờ lọt vào lịch sử. | Whatever a password manager marks hidden never slips into the history. | "đánh dấu ẩn" (marks hidden) is the app's settings wording ("đánh dấu là ẩn") without "là"; "lọt vào" is the everyday verb for something slipping in. |
| C.mac.4.k | Sửa gì trên Mac | Whatever you edit on the Mac | "Sửa" (edit) is the verb the release notes use for changing a cutling. |
| C.mac.4.h | [iPhone] đổi theo | [iPhone] changes along | "đổi theo" (changes to follow) carries the sync. "cũng" (too) was dropped so the line sets on one row instead of leaving "theo" alone. |
| C.mac.4.s | Đồng bộ qua iCloud của chính bạn, không cần tạo tài khoản. | Syncs through your own iCloud, no account to create. | "iCloud của chính bạn" (your own iCloud) is how the app's onboarding says it. |
| C.mac.5.k | iPhone, iPad và Mac | iPhone, iPad and Mac | Same as iPhone 6. |
| C.mac.5.h | Chỉ trả [một lần] | Pay only [once] | Same as iPhone 6. |
| C.mac.5.s | Dùng được trên cả ba máy, không cần tài khoản, không gói đăng ký. | Usable on all three devices, no account needed, no subscription. | iPhone 6's line with "được" added, so the wider Mac line breaks after "tài khoản," instead of splitting "không / gói đăng ký". |
