# bn-BD (Bengali, Bangladesh): words for the 2.0 store frames, direction C (ASG167)

Written from the meanings in `C-words-brief.md` and the bn-BD entry of `locale-facts.json`. Every line speaks to
the buyer as আপনি with -উন imperatives, as the bn-BD listing and app do. Digits are Latin because
locale-facts gives 5,000, 100 and 23 নভেম্বর, 2026 that way; Apple names stay in Latin, as in the app. `[x]` is a
green chip; rows marked built are made by the build from the seed.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| `cseed.names` | নুসরাত, রাকিব, সাদিয়া | Nusrat, Rakib, Sadia | Three common Bangladeshi first names (woman, man, woman), short enough for one key each; নুসরাত is the customer in frame 1, রাকিব in frame 2. |
| `cseed.mac_name` | তানভীর | Tanvir | Another common Bangladeshi man's name, so the four customers are two women and two men. |
| `cseed.reply` | {name}, আপনার অর্ডার {date} পাঠাচ্ছি। | {name}, your order {date} (I) am sending. | Written the way a Bangladeshi shop owner messages a customer: the name, then the formal আপনার. Bengali says "on Tuesday" with the bare weekday before the verb, so মঙ্গলবার goes in unchanged. 39 characters filled. |
| `cseed.reply_name` | অর্ডার আপডেট | Order update | What a Bangladeshi online shop would call this message; both words are everyday loans there. |
| `cseed.mac_reply` | {name}, আপনার {plan} প্যাকেজ {date} পাঠাচ্ছি। | {name}, your {plan} package {date} (I) am sending. | Same shape as the iPhone reply, with the plan name followed by প্যাকেজ, the way buyers say প্রিমিয়াম প্যাকেজ. 51 characters filled. |
| `cseed.name_label` | নাম | Name | The app's own word for Name. |
| `cseed.plan_label` | প্যাকেজ | Package | What Bangladeshi sellers call a tier you buy, as operators sell data and internet packages. The app's own strings say প্ল্যান for Plan, which reads like a subscription plan, so the shop's own word is used here. |
| `cseed.plan_choices` | বেসিক, প্রিমিয়াম | Basic, Premium | The usual pair in Bangladesh, and the pair the bn-BD 2.0 release notes already name. প্রিমিয়াম is 10 code points but four letters on screen; in the drawn Mac form its chip is only a little wider than বেসিক. |
| `cseed.delivered` | {date} তারিখে ডেলিভারি হয়েছে। | {date} on the date, delivery has happened. | Bengali puts the date before the verb, and তারিখে ("on the date") carries the "on", so the app's date is left as it is. ডেলিভারি is the word Bangladeshi couriers and shops use. 24 characters without the date. |
| `cseed.delivered_name` | ডেলিভারি নোট | Delivery note | The plain name a shop owner gives this saved note. |
| `iphone.1.h (built)` | [নুসরাত], আপনার অর্ডার [মঙ্গলবার] পাঠাচ্ছি। | Nusrat, your order Tuesday (I) am sending. | Made by the build from the reply; shown here because it is the line read in search. |
| `iphone.2.h (built)` | [রাকিব], আপনার অর্ডার [মঙ্গলবার] পাঠাচ্ছি। | Rakib, your order Tuesday (I) am sending. | Made by the build: the same reply with the second name. |
| `iphone.3.h (built)` | [23 নভেম্বর, 2026] তারিখে ডেলিভারি হয়েছে। | 23 November, 2026 on the date, delivery has happened. | Made by the build from the note; the green date opens the line. |
| `mac.1.h (built)` | [তানভীর], আপনার [প্রিমিয়াম] প্যাকেজ [মঙ্গলবার] পাঠাচ্ছি। | Tanvir, your Premium package Tuesday (I) am sending. | Made by the build from the Mac reply. |
| `iphone.1.k` | উত্তর একবারই লিখুন। | Write the reply only once. | Polite imperative (-উন), the আপনি register of the whole bn-BD listing, kept in every line. একবারই is "only once". |
| `iphone.1.s` | উত্তরে ট্যাপ করলেই Cutling নাম জানতে চায়। | Tap on the reply and Cutling wants to know the name. | জানতে চায় ("wants to know") is how Bengali says "asks for". Cutling stays in Latin for the app and কাটলিং is kept for the items, as in the 2.0 release notes. One line on iPhone. |
| `iphone.2.k` | পরের জনকেও সেটাই পাঠান। | Send that same one to the next person too. | Pairs with frame 1 as a second polite imperative: write it once, then send the same one. জন ("person") is the everyday way to say "the next one". |
| `iphone.2.s` | আগের নামগুলো কীবোর্ডেই তৈরি, এক ট্যাপেই বসে যায়। | The earlier names are ready right on the keyboard; with just one tap it goes in. | "Ready on the keyboard" carries "waiting as keys". এক ট্যাপেই follows the native এক ক্লিকেই; the calque এক ট্যাপের দূরত্বে ("one tap away") was left out. |
| `iphone.3.k` | তারিখ নিজেই বসে যায়। | The date goes in by itself. | Says what the buyer sees happen. |
| `iphone.3.s` | আজ, আগামীকাল বা এক সপ্তাহ পরে, হিসাব হয় পেস্ট করার দিন থেকে। | Today, tomorrow or one week later, the counting happens from the day of pasting. | আজ, আগামীকাল and এক সপ্তাহ পরে are the app's own labels for the three dates. "Counted from the day you paste" is how a Bengali speaker says the date is right on that day. |
| `iphone.4.k` | আর আপনার যা কখনো বদলায় না: | And whatever of yours never changes: | Leads into the list as one sentence. The possessive আপনার sits here and covers all three chips, which is where Bengali puts it, and the two-word chip then gets a line of its own. |
| `iphone.4.h` | [অ্যাকাউন্ট নম্বর], [ঠিকানা] ও [স্বাক্ষর]। | Account number, address and signature. | The shortest names: অ্যাকাউন্ট নম্বর is what people send to be paid, ঠিকানা is address, and স্বাক্ষর is the app's word for an email signature (its seed card says ইমেইল স্বাক্ষর). |
| `iphone.4.s` | প্রতিটি এক ট্যাপে, যেকোনো অ্যাপে, Cutling কীবোর্ডে। | Each in one tap, in any app, on the Cutling keyboard. | Three short phrases; ট্যাপে and অ্যাপে rhyme. Fits one line. |
| `iphone.5.k` | সবকিছুর জায়গা আছে। | For everything there is room. | A plain everyday sentence. |
| `iphone.5.h` | [5,000] কাটলিং | 5,000 cutlings | The number as locale-facts writes it (Latin digits); কাটলিং is the app's plural. No classifier টি, which Bengali headlines drop after a number. |
| `iphone.5.s` | আগে ছিল 100, আর প্রতিটিতে পুরো একটা ইমেল ধরে। | Before it was 100, and in each one a whole email fits. | ধরে ("holds, fits") is the verb Bengali uses for capacity. ইমেল is the app's spelling. |
| `iphone.6.k` | iPhone, iPad ও Mac। | iPhone, iPad and Mac. | Device names in Latin script, as the app and the listing write them; ও for "and" in a short list. |
| `iphone.6.h` | [একবার] কিনলেই হলো। | Once, if you buy it, it's done. | The Bengali idiom for a one-time payment ("buying once is enough"); the chip is on একবার ("once"). A no-break space keeps কিনলেই হলো together, so iPad breaks the line as iPhone and Mac do. |
| `iphone.6.s` | এক কেনায় তিন ডিভাইসেই চলে, অ্যাকাউন্ট বা সাবস্ক্রিপশন ছাড়াই। | With one purchase it runs on all three devices, without account or subscription. | সাবস্ক্রিপশন is the everyday loan for a plan you keep paying for. ছাড়াই ("without any") covers both the account to make and the fee to keep paying. |
| `mac.1.k` | একবার লিখুন, সবাইকে পাঠান। | Write once, send to everyone. | Two polite imperatives, the voice of iPhone frames 1 and 2. |
| `mac.1.s` | {cmd} চেপে উত্তর বেছে নিন, ছোট ফর্মে ফাঁকা জায়গা ভরে পেস্ট করুন। | Pressing {cmd}, pick the reply, fill the blanks in a small form and paste. | চেপে follows the app's own hotkey line (%@ চাপুন); ফাঁকা জায়গা is the app's word for blanks. Filling the form and pasting is what the drawn Mac form beside it shows. |
| `mac.2.k` | যেখানে টাইপ করছেন, সেখানেই। | Where you are typing, right there. | The correlative যেখানে … সেখানেই is the natural Bengali way to say "wherever you are typing". |
| `mac.2.h` | {cmd} | the ⌘ ⇧ V keys | Fixed by the brief. |
| `mac.2.s` | আপনার কাটলিং আর সাম্প্রতিক কপি যেকোনো অ্যাপের ওপরেই খুলে যায়। | Your cutlings and recent copies open up right over any app. | সাম্প্রতিক follows the app's Recent clipboard (সাম্প্রতিক ক্লিপবোর্ড). |
| `mac.3.k` | আপনার ক্লিপবোর্ড ইতিহাসে যা ঢোকে না: | What does not get into your clipboard history: | The history takes the locative, so the dots after the colon read as what is kept out. "ক্লিপবোর্ড ইতিহাস রাখে না" would read as "does not keep your clipboard history". ক্লিপবোর্ড ইতিহাস is the app's term. |
| `mac.3.s` | পাসওয়ার্ড ম্যানেজারের গোপন করা কিছুই ইতিহাসে জমা হয় না। | Nothing the password manager has concealed gets stored in the history. | গোপন করা ("concealed") is the listing's own phrase for what password managers hide; কিছুই … না makes it "nothing at all". |
| `mac.4.k` | আপনার Mac-এ কিছু বদলালে, | If you change something on your Mac, | A conditional that runs into the headline as one sentence. Mac-এ is how the app puts a Bengali ending on a Latin name. |
| `mac.4.h` | [iPhone-এও] বদলায়। | on the iPhone too, it changes. | The ending -এও ("on … too") stays inside the chip with iPhone; left outside the green block it floated as a stray -এও. |
| `mac.4.s` | আপনার নিজের iCloud দিয়েই সিঙ্ক হয়, আলাদা অ্যাকাউন্ট লাগে না। | Through your own iCloud it syncs; no separate account needed. | সিঙ্ক and নিজের iCloud follow the app's own line (আপনার নিজের iCloud-এ সিঙ্ক হয়). আলাদা ("separate") because the buyer does have an iCloud account, just no Cutling one. |
| `mac.5.k` | iPhone, iPad ও Mac। | iPhone, iPad and Mac. | Same as iPhone 6. |
| `mac.5.h` | [একবার] কিনলেই হলো। | Once, if you buy it, it's done. | Same as iPhone 6. |
| `mac.5.s` | এক কেনায় তিন ডিভাইসেই চলে, অ্যাকাউন্ট বা সাবস্ক্রিপশন ছাড়াই। | With one purchase it runs on all three devices, without account or subscription. | Same as iPhone 6. |
