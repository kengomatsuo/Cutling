# zh-Hans (Simplified Chinese, mainland China): words for the 2.0 store frames (ASG167)

Written from `C-words-brief.md` and the `zh-Hans` entry of `locale-facts.json` (weekday `星期二`, long date `2026年11月23日`,
`5,000`, `100`); the file is `fastlane/compose/creative/v2/words/zh-Hans.json`. The frames speak to the buyer with 你, as
the zh-Hans listing and the app's own strings do. The shop owner's messages are a different speaker: a Chinese shop writes
to a buyer with 您 and calls them 王女士 or 李先生, never by a bare given name. Product words are the app's own zh-Hans
strings: 剪切片段 for one cutling or many (counted with 个, as the app's "8 个 剪切片段"), Cutling kept in Latin letters as
the app writes it in sentences, 轻点 (tap), 复制 (copy), 粘贴 (paste), 套餐 (the app's word for Plan), 今天/明天/一周后,
填空 (blanks), 剪贴板历史 (clipboard history), and the listing's own 标记为机密 for concealed items. Punctuation is mainland
Chinese (，。、！), with a half-width space between Chinese and Latin letters or digits, as the app writes it ("在这里用
Cutling 输入"), and no dashes, colons, semicolons or quotation marks.

Chrome breaks Chinese between any two characters, and its `word-break:auto-phrase` covers Japanese only (tested on Chrome
158 under zh-Hans, zh, zh-CN and zh-Hans-CN). So every headline or subline I wrote that runs past one line carries a `|`
line break after a comma or between a phrase and the next. The seed sentences, which the build turns into the headlines
of iPhone 1 to 3 and Mac 1, are worded so the chips force the breaks. Measured in the built frames, every line on iPhone,
iPad and Mac now breaks between phrases. The one exception is frame 3's bubble: the build has to keep the date whole there.

| Key | String | Back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | 王女士 | Ms Wang | Chinese shops address a buyer by surname and 女士/先生; the honorific also makes the gender mix plain |
| cseed.names[1] | 李先生 | Mr Li | Second most common surname, male |
| cseed.names[2] | 陈女士 | Ms Chen | Common surname, female |
| cseed.mac_name | 张先生 | Mr Zhang | Same pattern, one of the three most common surnames |
| cseed.reply | {name}，{date}给您发货哦！ | {name}, (we) ship it to you {date}! | The shop's own voice: 您 to the buyer, 给您发货 as sellers write it, 哦 for the friendly tone of Chinese shop chat; 星期二 stands before the verb as a time word, so it needs no change |
| cseed.reply_name | 发货通知 | Shipping notice | What a seller titles a saved shipping message |
| cseed.mac_reply | {name}，您订的{plan}已备好，{date}发货哦！ | {name}, the {plan} you ordered is ready, it ships {date}! | Same voice; 已备好 keeps the plan chip and the date chip apart, and on the Mac each line ends at a comma (张先生，您订的 / 豪华版已备好， / 星期二发货哦！) |
| cseed.name_label | 称呼 | Form of address | The field Chinese forms use for "how should we address you", which fits a value like 王女士; 姓名 asks for a full legal name |
| cseed.plan_label | 套餐 | Package (plan) | The app's own word for Plan, and how a Chinese listing labels a product option |
| cseed.plan_choices[0] | 标准版 | Standard edition | The usual name of the basic option of one product |
| cseed.plan_choices[1] | 豪华版 | Deluxe edition | The usual name of the better option |
| cseed.delivered | 您的包裹送达于{date}。 | Your parcel was delivered on {date}. | Delivery-notice wording; with the date last, every line breaks between phrases (已于{date}送达 split 送达 as 送 / 达 on iPad) |
| cseed.delivered_name | 送达通知 | Delivery notice | Title of the saved note |
| C.iphone.1.k | 这条回复只写一次 | This reply is written only once | Eight characters, paired with frame 2's eight |
| C.iphone.1.h (built) | [王女士]，[星期二]给您发货哦！ | [Ms Wang], we ship it to you [Tuesday]! | Built from the seed; breaks 王女士， / 星期二给您 / 发货哦！ on iPhone |
| C.iphone.1.s | 轻点存好的回复，\|Cutling 会先问你怎么称呼对方。 | Tap the saved reply, and Cutling first asks you how to address the other person. | 轻点 is Apple's and the app's word for tap; 怎么称呼对方 is how Chinese asks for someone's name; 你 for the buyer, as in the listing |
| C.iphone.2.k | 再发给下一位客户 | Send it again to the next customer | 再发 (send again) says it is the very same reply |
| C.iphone.2.h (built) | [李先生]，[星期二]给您发货哦！ | [Mr Li], we ship it to you [Tuesday]! | Built from the seed |
| C.iphone.2.s | 用过的称呼都排在键盘上，\|轻点一下就填好。 | The names you have used are all lined up on the keyboard; one tap and it is filled in. | 称呼 matches the blank's label in the keyboard below; 排在 (lined up) describes the keys |
| C.iphone.3.k | 日期也会自动填好 | Dates get filled in by themselves too | 也 (too) ties dates to the names filled in frames 1 and 2 |
| C.iphone.3.h (built) | 您的包裹送达于[2026年11月23日]。 | Your parcel was delivered on [23 November 2026]. | Built from the seed; two lines on iPhone and iPad |
| C.iphone.3.s | 今天、明天或一周后，\|都从粘贴那天算起，不会出错。 | Today, tomorrow or a week later, all counted from the day you paste, so it is never wrong. | 今天、明天、一周后 are the app's own date choices |
| C.iphone.4.k | 还有你多年不变的 | And your (things) unchanged for years | Reads into the list as one sentence; the possessive 你 sits here, so the chips hold only the things; 多年不变 is said of an address or a signature |
| C.iphone.4.h | [银行卡号]、[家庭住址]和[邮件签名] | [bank card number], [home address] and [email signature] | 银行卡号 is what people in China send for a transfer (also the listing's word); 家庭住址 and 邮件签名 are the app's own titles in the capture below |
| C.iphone.4.s | 在任何 App 里，\|用 Cutling 键盘轻点一下就能输入。 | In any app, one tap on the Cutling keyboard types it. | Close to the app's own onboarding line (在任何 App 的键盘上轻点就能输入) |
| C.iphone.5.k | 全都存得下 | All of it fits | Spoken "it all fits", about storage |
| C.iphone.5.h | [5,000] 个\|剪切片段 | [5,000] (counter) cutlings | 个 is the counter the app uses; the break keeps the number with its counter and the product word whole |
| C.iphone.5.s | 以前只能存 100 个，\|现在每个都放得下一整封邮件。 | It used to hold only 100, and now each one holds a whole email. | 放得下 (fits) for "long enough to hold" |
| C.iphone.6.k | iPhone、iPad 和 Mac 通用 | Works across iPhone, iPad and Mac | Apple China's list form, 、 then 和 |
| C.iphone.6.h | [一次]买断 | Buy it outright [once] | 一次买断 is the set phrase Chinese buyers use for an app paid once with no subscription; chip on 一次 (once) |
| C.iphone.6.s | 买一次，三种设备都能用。\|不用注册账户，也没有订阅费。 | Buy once and all three devices can use it. No account to register, and no subscription fee. | 订阅费 (subscription fee) carries "no subscription to keep paying" |
| C.mac.1.k | 写一次，发给每个人 | Write it once, send it to everyone | 每个人 (each person): each reply goes to one customer, where 所有人 would sound like a mass mailing |
| C.mac.1.h (built) | [张先生]，您订的[豪华版]已备好，[星期二]发货哦！ | [Mr Zhang], the [deluxe edition] you ordered is ready, it ships [Tuesday]! | Built from the seed; three lines of seven characters on the Mac |
| C.mac.1.s | 按 {cmd} 选好回复，\|粘贴前会先弹出小表单，让你填空。 | Press ⌘⇧V to pick the reply; before it pastes, a small form pops up so you fill in the blanks. | 填空 is the app's own word for blanks (填空与日期) |
| C.mac.2.k | 无论在哪里打字 | Wherever you are typing | Plain lead-in to the keys |
| C.mac.2.h | {cmd} | ⌘⇧V | As the brief sets it |
| C.mac.2.s | 剪切片段和最近复制的内容，\|会在任何 App 上方弹出。 | Your cutlings and what you copied recently pop up over any app. | 复制 is the app's word for copy; no 你的, which Chinese leaves out where it is clear |
| C.mac.3.k | 剪贴板历史什么都记得，除了 | Clipboard history remembers everything, except | Ends on 除了 (except), so the row of dots reads as what is left out |
| C.mac.3.s | 密码管理器标记为机密的内容，\|绝不会进入历史记录。 | Anything a password manager marks as confidential never gets into the history. | 标记为机密 is the zh-Hans listing's own phrase for concealed items |
| C.mac.4.k | 在 Mac 上改一下 | Change it on the Mac | First half of one sentence across kicker and headline |
| C.mac.4.h | [iPhone] 上\|也跟着变 | On [iPhone] it changes too | 跟着变 (changes along with it) says sync without the word; the break keeps "iPhone 上" (on iPhone) together |
| C.mac.4.s | 用你自己的 iCloud 同步，\|不用注册账户。 | It syncs through your own iCloud, with no account to register. | 你自己的 iCloud follows the app's own privacy line |
| C.mac.5.k | iPhone、iPad 和 Mac 通用 | Works across iPhone, iPad and Mac | Same as iPhone 6 |
| C.mac.5.h | [一次]买断 | Buy it outright [once] | Same as iPhone 6 |
| C.mac.5.s | 买一次，三种设备都能用。\|不用注册账户，也没有订阅费。 | Buy once and all three devices can use it. No account to register, and no subscription fee. | Same as iPhone 6 |
