# ja (Japanese): words for the 2.0 store frames (ASG167)

Written from `C-words-brief.md` and the `ja` entry of `locale-facts.json` (weekday `火曜日`, long date `2026年11月23日`,
`5,000`, `100`); the file is `fastlane/compose/creative/v2/words/ja.json`. Every subline is in です/ます, as the ja
listing's promotional text is; kickers and headlines end on a noun or a particle, and だ/である appears nowhere. Product
words are the app's own ja strings: カットリング (the app's Japanese display name and its word for the items),
カットリングキーボード, 空欄, ペースト, 「今日」「明日」「1週間後」, クリップボード履歴, 機密に指定した内容. Punctuation is
Japanese (、。「」・), digits are half-width, there are no spaces between Latin and Japanese, and no dashes.

The customers are family names with 様, not first names: a Japanese shop writes to a buyer as 中村様, and a first name
with 様 reads as overfamiliar. Family names carry no gender, so the brief's mix of genders has no reading in Japanese.
The names, the reply and the blank label are the ones the ja "Every app" preview seed already uses
(`EveryAppSeedCopy` in `Cutling/SnapshotSeedData.swift`), so frame 1 and the video beside it show the same customers.

The frames break every Japanese line between phrases (`build.py`: `word-break:auto-phrase` for ja, and the fit script
shrinks a headline until its widest phrase fits), so no word is split across lines.

Rows marked *built* are put together by the build from the seed; `[x]` is a green chip.

| Key | String | Back-translation | Choice |
|---|---|---|---|
| cseed.names | 中村, 小林, 松本 | Nakamura, Kobayashi, Matsumoto | Common family names, two characters each, as a shop addresses buyers; the preview seed's first three |
| cseed.mac_name | 岡田 | Okada | The preview seed's fourth name |
| cseed.reply | {name}様、ご注文の品は{date}に発送いたします。 | {name}-sama, the items you ordered will be shipped on {date}. | 様 and humble いたします are how a shop writes to a customer; the weekday takes に (火曜日に, "on Tuesday") and is not changed. 22 characters filled |
| cseed.reply_name | 発送連絡 | Shipping notice | The owner's own label, without the polite お/ご a customer would see |
| cseed.mac_reply | {name}様、{plan}プランは{date}に発送いたします。 | {name}-sama, the {plan} plan will be shipped on {date}. | Same register as the iPhone reply; プラン follows the blank so the plan names stay short. 25 characters filled |
| cseed.name_label | 名前 | Name | The owner's form label (お名前 is what a shop shows customers); same as the preview seed |
| cseed.plan_label | プラン | Plan | The word Japanese shops and subscriptions use for a tier |
| cseed.plan_choices | ベーシック, プレミアム | Basic, Premium | The usual pair on Japanese pricing pages |
| cseed.delivered | {date}にお届け済みです。 | Delivered on {date}. | A status line with no subject, as a shop writes it; the long date takes に. Without a subject the date leads the headline and the bubble keeps the date on one line |
| cseed.delivered_name | 配達完了 | Delivery complete | The owner's terse label for the event |
| C.iphone.1.h *built* | [中村]様、ご注文の品は[火曜日]に発送いたします。 | [Nakamura]-sama, the items you ordered will be shipped on [Tuesday]. | Breaks as 中村様、/ ご注文の品は / 火曜日に / 発送いたします。 |
| C.iphone.1.k | この返信、書くのは一度だけ。 | This reply: you write it only once. | Topic and comment ending on だけ, the shape of a Japanese ad line |
| C.iphone.1.s | 保存した返信をタップすると、カットリングが名前を尋ねます。 | When you tap the saved reply, Cutling asks for the name. | 尋ねる is the app's own verb (毎回尋ねる, Ask Each Time) |
| C.iphone.2.h *built* | [小林]様、ご注文の品は[火曜日]に発送いたします。 | [Kobayashi]-sama, the items you ordered will be shipped on [Tuesday]. | The same sentence, the next name |
| C.iphone.2.k | 同じ返信を、そのまま次のお客様へ。 | The same reply, just as it is, to the next customer. | そのまま carries "the very same, untouched"; お客様 is a shop's word for its buyers |
| C.iphone.2.s | 前に使った名前が、ワンタップで選べるキーになって並びます。 | The names you used before line up as keys you can pick with one tap. | 並ぶ ("line up") is how Japanese describes keys in a row; ワンタップ is the listing's word |
| C.iphone.3.h *built* | [2026年11月23日]にお届け済みです。 | Delivered on [November 23, 2026]. | The date chip opens the headline |
| C.iphone.3.k | 日付は、カットリングにおまかせ。 | Leave the dates to Cutling. | 〜はおまかせ is the everyday idiom for "it takes care of that" |
| C.iphone.3.s | 「今日」「明日」「1週間後」は、ペーストした日に合わせて正しい日付が入ります。 | "Today", "Tomorrow" and "In a week" fill in the right date for the day you paste. | The three options in 「」 exactly as the app labels them; ペースト is the app's word |
| C.iphone.4.k | いつも同じ、自分の情報も。 | Your own details, always the same, too. | 自分の is the app's possessive (自分の名前); も ("too") carries on from the reply frames |
| C.iphone.4.h | [口座番号]、[住所]、[署名] | [Account number], [address], [signature] | The shortest natural name of each; 署名 is the sign-off block under a message. The kicker's 自分の does the possessive's job. No 。 after a list |
| C.iphone.4.s | カットリングキーボードから、どのアプリでもワンタップで入力できます。 | From the Cutling keyboard, you can type them into any app with one tap. | カットリングキーボード is the app's name for its keyboard |
| C.iphone.5.k | 全部とっておけます。 | You can keep all of it. | とっておく is the everyday verb for keeping something for later |
| C.iphone.5.h | [5,000]個のカットリング | [5,000] cutlings | Counted with 個, as the app counts them (8 個の カットリング); Japanese has no plural |
| C.iphone.5.s | これまでは100個でした。1つにメール1通がまるごと入ります。 | Until now it was 100. One holds a whole email. | 1通 is the counter for emails; まるごと means whole |
| C.iphone.6.k | iPhone・iPad・Macで使えます。 | Works on iPhone, iPad and Mac. | ・ is the usual separator for a list of names |
| C.iphone.6.h | お支払いは[一度]だけ。 | You pay [once], and that's all. | Chip on 一度 (once); 買い切り (one-time purchase) was the other option, but お支払い makes the buyer's payment the subject |
| C.iphone.6.s | 1回の購入で3つとも使えて、アカウント登録もサブスクもありません。 | One purchase works on all three, and there is no account to register and no subscription. | 1回の購入 and アカウント登録 are the listing's own phrases; サブスク is the buyer's word |
| C.mac.1.h *built* | [岡田]様、[プレミアム]プランは[火曜日]に発送いたします。 | [Okada]-sama, the [Premium] plan will be shipped on [Tuesday]. | Breaks as 岡田様、/ プレミアムプランは / 火曜日に / 発送いたします。 |
| C.mac.1.k | 一度書けば、あとは誰にでも。 | Write it once, and from then on it is for anyone. | 〜ば、あとは… is the natural "once you do X, the rest is…" |
| C.mac.1.s | {cmd}で返信を選ぶと、ペーストする前に小さなフォームが空欄の中身を尋ねます。 | When you pick the reply with ⌘⇧V, a small form asks what goes in the blanks before it pastes. | 空欄 is the app's word for a blank (空欄と日付); 尋ねる as on iPhone 1 |
| C.mac.2.k | どこで入力していても。 | Wherever you are typing. | A ても clause that leads into the keys |
| C.mac.2.h | {cmd} | ⌘⇧V | Fixed by the brief |
| C.mac.2.s | 保存したカットリングと最近コピーしたものが、使っているアプリの上に開きます。 | Your saved cutlings and the things you copied recently open over the app you are using. | 保存した matches the picker's 保存済み tab |
| C.mac.3.k | クリップボード履歴に残らないのは、 | What does not stay in the clipboard history is | A cleft (〜のは、) whose answer is the row of dots under it; クリップボード履歴 is the app's term |
| C.mac.3.s | パスワードマネージャが機密に指定した内容は、履歴に入りません。 | Anything a password manager marks as confidential never gets into the history. | 機密に指定した内容 is the app's own wording for concealed items |
| C.mac.4.k | Macで変えた内容は、 | What you change on the Mac | Kicker and headline read as one sentence |
| C.mac.4.h | [iPhone]にも反映されます。 | is reflected on [iPhone] too. | 反映 is the word Japanese apps use for a change showing up elsewhere; no "instantly", which sync cannot promise |
| C.mac.4.s | 自分のiCloudで同期するので、アカウント登録はいりません。 | It syncs through your own iCloud, so you do not need to register an account. | The app's own claim (同期は自分の iCloud だけで行います), joined with ので |
| C.mac.5.k | iPhone・iPad・Macで使えます。 | Works on iPhone, iPad and Mac. | Same as iPhone 6 |
| C.mac.5.h | お支払いは[一度]だけ。 | You pay [once], and that's all. | Same as iPhone 6 |
| C.mac.5.s | 1回の購入で3つとも使えて、アカウント登録もサブスクもありません。 | One purchase works on all three, and there is no account to register and no subscription. | Same as iPhone 6 |
