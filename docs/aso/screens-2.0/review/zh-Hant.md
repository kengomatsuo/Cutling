# zh-Hant (Traditional Chinese, Taiwan): words for the 2.0 store frames (ASG167)

Written from `C-words-brief.md` and the `zh-Hant` entry of `locale-facts.json` (weekday `星期二`, long date
`2026年11月23日`, `5,000`, `100`); the file is `fastlane/compose/creative/v2/words/zh-Hant.json`. The frames speak to
the reader as 你, as the zh-Hant listing (`fastlane/metadata/zh-Hant`) and Apple Taiwan do; the shop owner's own
messages say 您 to customers, as Taiwanese shops write. The vocabulary is Taiwan's (出貨, 帳號, 註冊, 訂閱, 簽名檔, 方案,
客人), and the product words are the app's own zh-Hant strings: 剪切片段, 填空, 貼上, 複製, 方案, 今天 / 明天 / 一週後,
剪貼板歷史. Punctuation is full-width Chinese (，。、：！), digits are half-width, and a space separates Chinese from Latin
letters and digits (Cutling 鍵盤, 100 個), as the app, the listing and Apple Taiwan all write; the app types the long
date with no spaces, so none are put around it. There are no dashes and no quotation marks.

The customers are given names, the most common of their generation in Taiwan, two characters each, in a mix of
genders: 怡君 and 雅婷 are women, 家豪 and 冠宇 men. A small Taiwanese shop opens a message with the buyer's given name and
您好. The weekday stands as a bare time word before the verb (您的訂單星期二就會出貨囉), which is ordinary Chinese and
leaves 星期二 untouched.

Chinese has no spaces, and the frames' Chrome breaks it between any two characters (its `auto-phrase` covers Japanese
only, tested in Chrome 158). Every kicker and subline was measured at its frame's own font, size and width, and each
fits one line on iPhone, iPad and Mac, except Mac 2's subline, which wraps at the space before App. Headlines that must
break carry `|` (iPhone 4, iPhone 5, Mac 4). The built headlines carry no marks, since the same seed text also fills
the keyboard bar, the bubble and the Mac form. They break between phrases (怡君您好， / 您的訂單 / 星期二 / 就會出貨囉！)
when the frame sets a Chinese headline `keep-all` and allows a break at each chip edge.

Rows marked *built* are put together by the build from the seed; `[x]` is a green chip and `|` a line break.

| Key | String | Back-translation | Choice |
|---|---|---|---|
| cseed.names | 怡君, 家豪, 雅婷 | Yi-chun (f), Chia-hao (m), Ya-ting (f) | Taiwan's most common given names of their generation, two characters each; a shop writes to a buyer by given name |
| cseed.mac_name | 冠宇 | Kuan-yu (m) | Another of the most common men's names |
| cseed.reply | {name}您好，您的訂單{date}就會出貨囉！ | {name}, hello; your order ships as soon as {date}! | Name + 您好 is how a Taiwanese shop opens a message; 出貨 is the e-commerce verb for sending an order out; 就會…囉 makes it prompt and warm. The weekday stands bare before the verb. 18 characters filled, and the keyboard bar shows it whole |
| cseed.reply_name | 出貨通知 | Shipping notice | What a shop calls this message; also the title of the Mac form |
| cseed.mac_reply | {name}您好，您訂的{plan}在{date}就會出貨囉！ | {name}, hello; the {plan} you ordered ships as soon as {date}! | Same voice as the iPhone reply; 在 keeps the plan and weekday chips apart. 22 characters filled |
| cseed.name_label | 名字 | Name (given name) | 名字 is the given name the blank holds; 姓名 would ask for the full name |
| cseed.plan_label | 方案 | Plan | The app's own string for Plan, and the Taiwanese word for a tier you buy (phone plans, crowdfunding tiers) |
| cseed.plan_choices | 基本方案, 進階方案 | Basic plan, Advanced plan | The pair the zh-Hant 2.0 release notes already give as the example |
| cseed.delivered | 您的包裹已於{date}送達，請查收。 | Your package was delivered on {date}; please check and receive it. | 已於 is the written form delivery notices use, 請查收 the usual courtesy. 13 characters without the date |
| cseed.delivered_name | 送達通知 | Delivery notice | The owner's own label for the note |
| C.iphone.1.k | 這則回覆只要寫一次 | This reply only needs writing once | 則 is the measure word for a message, so 這則回覆 points at the reply below |
| C.iphone.1.h | *built*: [怡君]您好，您的訂單[星期二]就會出貨囉！ | [Yi-chun], hello; your order ships as soon as [Tuesday]! | From the seed |
| C.iphone.1.s | 點一下回覆，Cutling 會先請你填上名字。 | Tap the reply once, and Cutling first asks you to fill in the name. | 請你填上名字 says the user fills it in; 問你名字 would read as "asks your name". One line |
| C.iphone.2.k | 同一則回覆，再傳給下一位客人 | The same reply, sent again to the next customer | 客人 is what a shop owner calls the people who buy |
| C.iphone.2.h | *built*: [家豪]您好，您的訂單[星期二]就會出貨囉！ | [Chia-hao], hello; your order ships as soon as [Tuesday]! | From the seed; same lines as frame 1 |
| C.iphone.2.s | 用過的名字都排在鍵盤上，點一下就填好。 | The names you have used are all lined up on the keyboard; one tap and it is filled in. | 排 (lined up) pictures the row of name keys |
| C.iphone.3.k | Cutling 自己會填好日期 | Cutling fills in the date by itself | 自己會 is "by itself" in everyday speech |
| C.iphone.3.h | *built*: 您的包裹已於[2026年11月23日]送達，請查收。 | Your package was delivered on [November 23, 2026]; please check and receive it. | From the seed; three lines: 您的包裹已於 / the date / 送達，請查收。 |
| C.iphone.3.s | 今天、明天或一週後，都照你貼上那天算。 | Today, tomorrow or a week later: all counted from the day you paste. | 今天, 明天 and 一週後 are the app's own option names; 照…算 is "reckoned from" |
| C.iphone.4.k | 還有你那些不會變的資料： | And those details of yours that do not change: | Leads into the list with a colon; 你那些 carries the possessive, so the chips stay bare |
| C.iphone.4.h | [銀行帳號]、\|[地址]、[簽名檔] | [bank account number], [address], [email signature] | 帳號 is the account number (the app's 銀行帳戶 is the account itself); 地址 is the app's word; 簽名檔 is Taiwan's everyday word for a sign-off block, as the listing writes (Email 簽名檔). 、 is the list comma |
| C.iphone.4.s | 任何 App 都只要在 Cutling 鍵盤上點一下。 | In any app, it takes just one tap on the Cutling keyboard. | 都只要 carries "each one, a single tap" after the list. One line |
| C.iphone.5.k | 全部都存得下 | All of it can be kept | 存得下: there is room to save it |
| C.iphone.5.h | [5,000] 個\|剪切片段 | [5,000] cutlings | 個 is the counter of the app's own grid header (8 個 剪切片段), which sits right below; the break keeps 剪切片段 whole |
| C.iphone.5.s | 以前只有 100 個，每個都放得下整封 Email。 | It used to be only 100; each one holds a whole email. | Email in Latin letters, as the listing writes it. One line |
| C.iphone.6.k | iPhone、iPad 和 Mac 都能用 | Works on iPhone, iPad and Mac | Apple Taiwan's list form, 、 between items and a conjunction before the last (apple.com/tw writes iPhone、iPad 或 Mac) |
| C.iphone.6.h | [一次]買斷 | Bought outright [once] | 一次買斷 is what Taiwanese buyers call a one-time purchase, set against a subscription; the chip is on 一次, "once" |
| C.iphone.6.s | 買一次，三種裝置通用，免註冊、免訂閱。 | Buy once, it works on all three kinds of device, no sign-up, no subscription. | 免註冊、免訂閱 is the usual Taiwanese store phrasing for no account and no subscription. One line |
| C.mac.1.k | 寫一次，傳給誰都行 | Write it once, send it to anyone | 誰都行: anyone at all |
| C.mac.1.h | *built*: [冠宇]您好，您訂的[進階方案]在[星期二]就會出貨囉！ | [Kuan-yu], hello; the [Advanced plan] you ordered ships as soon as [Tuesday]! | From the seed |
| C.mac.1.s | 按 {cmd} 選回覆，先在小表單填空再貼上。 | Press ⌘⇧V to pick the reply; fill in the blanks in a small form first, then paste. | 填空 is the app's word for blanks, and 貼上 is the form's own button. One line |
| C.mac.2.k | 不管在哪裡打字 | Wherever you are typing | Reads straight into the keys below |
| C.mac.2.h | {cmd} | ⌘⇧V | As the brief sets it |
| C.mac.2.s | 你的剪切片段和最近複製的內容，會在任何 App 上方直接打開。 | Your cutlings and what you copied recently open right over any app. | 複製 is the app's term for Copy. Two lines, breaking at the space before App |
| C.mac.3.k | 剪貼板歷史不會留下你的 | Clipboard history will not keep your | The dots under it end the sentence as its object ("your ••••••••••"); 剪貼板歷史 is the app's term, the same words as the Clear History button in the capture beside it |
| C.mac.3.s | 密碼管理工具標為隱藏的內容，一律不記錄。 | Anything a password manager marks as hidden is never recorded. | Close to the app's own setting text (密碼管理工具標記為隱藏…的內容不會被儲存). One line |
| C.mac.4.k | 在 Mac 上改了什麼， | Whatever you change on the Mac, | Kicker and headline are one sentence |
| C.mac.4.h | [iPhone]\|也跟著改。 | [iPhone] changes along with it. | 跟著改 echoes 改了什麼; the break sets the iPhone chip on its own line, since a full line would leave 改。 alone below it |
| C.mac.4.s | 透過你自己的 iCloud 同步，免註冊帳號。 | It syncs through your own iCloud; no account to register. | The app's own claim (只透過你自己的 iCloud 同步); 免註冊帳號 as on iPhone 6. One line |
| C.mac.5.k | iPhone、iPad 和 Mac 都能用 | Works on iPhone, iPad and Mac | Same as iPhone 6 |
| C.mac.5.h | [一次]買斷 | Bought outright [once] | Same as iPhone 6 |
| C.mac.5.s | 買一次，三種裝置通用，免註冊、免訂閱。 | Buy once, it works on all three kinds of device, no sign-up, no subscription. | Same as iPhone 6 |
