# Arabic (ar-SA) words for the 2.0 store frames, direction C (card ASG167)

Written from `docs/aso/screens-2.0/C-words-brief.md` and the `ar-SA` entry of `locale-facts.json`
(`الثلاثاء`, `٢٣ نوفمبر، ٢٠٢٦`, `٥٬٠٠٠`, `١٠٠`, product word `كاتلينج`). File: `fastlane/compose/creative/v2/words/ar-SA.json`.

**Register.** Plain Modern Standard Arabic with the generic masculine "you", the way Apple's Saudi pages
(apple.com/sa-ar) and Salla, the top Saudi app for shop owners, speak to buyers. Saudi dialect was ruled out
because App Store Connect has one Arabic localization and Apple shows it in 17 storefronts from Morocco to Oman,
where dialect words such as يخلّي or ليش (used in the current ar-SA store description) read as foreign. Where a
line speaks to the shop's customer, it avoids gendered verbs, because the same saved reply goes to Noura and to Fahd.

**Checked on the real frames.** All 17 frames were rendered with `build.py` (iPhone, iPad, Mac). Two sublines left
one word alone on a second line and were shortened (iPhone 4, Mac 4). The keyboard's one-line sentence
(`أهلًا الاسم، سنشحن طلبك يوم الثلاثاء.`) fits on its line.

| Key | String | Back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | نورة | Noura | One of the most-registered Saudi girls' names in civil-affairs lists; Saudi spelling with ة. The customer in frame 1. |
| cseed.names[1] | فهد | Fahd | A common Saudi man's name on the same lists, so frame 2's customer is a man. |
| cseed.names[2] | ريم | Reem | A common Gulf girl's name; short, so the three name keys stay even. |
| cseed.mac_name | خالد | Khalid | A common Saudi man's name for the Mac form. |
| cseed.reply | أهلًا {name}، سنشحن طلبك يوم {date}. | Hi {name}, we will ship your order on {date}. | Works for a man or a woman: unvowelled طلبك reads for both, and no verb addresses the customer. يوم goes before the weekday so الثلاثاء stays as given. The shop speaks as "we". 36 characters filled. |
| cseed.reply_name | موعد الشحن | Shipping date | What an owner would title the template that tells the ship day. |
| cseed.mac_reply | أهلًا {name}، سنشحن باقتك {plan} يوم {date}. | Hi {name}, we will ship your {plan} package on {date}. | باقتك (your package) is definite, so the plan word after it takes ال: باقتك المميزة is correct agreement. 45 characters filled. |
| cseed.name_label | الاسم | The name | The app's own word for Name. |
| cseed.plan_label | الباقة | The package | The Saudi word for a tier you buy; Apple's Saudi iCloud+ page calls its tiers الباقة/الباقات. Chosen over الخطة (the app's Variables example), which fits a service, not a box that ships. |
| cseed.plan_choices | الأساسية، المميزة | the Basic, the Premium | The usual Arabic tier adjectives, with ال so they agree with باقتك when filled in. 8 and 7 letters. |
| cseed.delivered | تم توصيل طلبك بتاريخ {date}. | Your order was delivered on {date}. | The wording Saudi stores already use: Salla's order statuses are تم الشحن، جاري التوصيل، تم التوصيل. بتاريخ is how Arabic attaches a date to an event. |
| cseed.delivered_name | تأكيد التوصيل | Delivery confirmation | The note's title as an owner would save it. |
| iphone.1.k | تكتب الرد مرة واحدة فقط | You write the reply only once | Second person present, the mood of a promise, so it reads as what the buyer gets. 23 characters. |
| iphone.1.h (built) | أهلًا [نورة]، سنشحن طلبك يوم [الثلاثاء]. | Hi [Noura], we will ship your order on [Tuesday]. | Built from the seed; shown here so the frame can be read whole. |
| iphone.1.s | اضغط على الرد المحفوظ، فيسألك كاتلينج عن الاسم. | Tap the saved reply, and Cutling asks you for the name. | اضغط … فـ is the app's own tap-and-result pattern (اضغط على كاتلينج فيُكتب). The app name is written كاتلينج, as on the home screen. |
| iphone.2.k | والرد نفسه للعميل التالي | And the same reply, for the next customer | Opens with و so it reads as the second half of frame 1's kicker. عميل is the Saudi business word for customer (Salla says عملائك). |
| iphone.2.h (built) | أهلًا [فهد]، سنشحن طلبك يوم [الثلاثاء]. | Hi [Fahd], we will ship your order on [Tuesday]. | Built from the seed. |
| iphone.2.s | الأسماء التي كتبتها من قبل تنتظرك، كل اسم بضغطة. | The names you wrote before are waiting for you, each name with one tap. | ضغطة is a noun of one instance, so بضغطة already means a single tap. |
| iphone.3.k | كاتلينج يكتب التواريخ بنفسه | Cutling writes the dates by itself | Plural التواريخ on purpose: singular التاريخ also means "history", and "Cutling writes history" would be the first reading. |
| iphone.3.h (built) | تم توصيل طلبك بتاريخ [٢٣ نوفمبر، ٢٠٢٦]. | Your order was delivered on [23 November, 2026]. | Built from the seed. |
| iphone.3.s | اليوم أو غدًا أو بعد أسبوع، والتاريخ صحيح يوم تلصقه. | Today, tomorrow or after a week, and the date is right on the day you paste it. | The three day words are the app's own variable names (اليوم، غدًا، بعد أسبوع). |
| iphone.4.k | وبياناتك التي لا تتغير | And your details that do not change | Leads into the list as one sentence; no colon, so the green line stays a plain lead-in. |
| iphone.4.h | [رقم حسابك]، [عنوانك]، [توقيعك] | [your account number], [your address], [your signature] | The possessive ending -ك, unvowelled, reads for a man or a woman. Echoes the app's tiles الحساب البنكي، عنوان المنزل، توقيع البريد. Arabic commas join the chips, so no chip edge cuts a و off its word. |
| iphone.4.s | كل منها بضغطة، في أي تطبيق، من لوحة مفاتيح كاتلينج. | Each of them with one tap, in any app, from Cutling's keyboard. | لوحة المفاتيح is the app's word (the store description's كيبورد is dialect). Shortened after the render left كاتلينج alone on a second line. |
| iphone.5.k | مساحة لكل ما تحفظه | Room for everything you keep | مساحة is the word the app's What's New uses for room (ومساحة أكبر بكثير). |
| iphone.5.h | [٥٬٠٠٠] كاتلينج | [5,000] cutlings | After thousands Arabic counts with a singular noun, so the invariant product word reads correctly. |
| iphone.5.s | كان الحد ١٠٠ فقط، وكل كاتلينج يتسع الآن لإيميل كامل. | The limit was only 100, and each cutling now holds a whole email. | إيميل is the word Apple's Saudi pages use; البريد الإلكتروني is longer and stiffer. |
| iphone.6.k | على iPhone وiPad وMac | On iPhone, iPad and Mac | Apple's Saudi style: Latin product names, with و joined straight onto the name (وiPad). |
| iphone.6.h | تدفع [مرة واحدة] | You pay [one time] | The chip covers both words, because Arabic says "once" as مرة واحدة. 14 characters. |
| iphone.6.s | شراء واحد يشمل الثلاثة، بلا حساب ولا اشتراك تدفعه كل شهر. | One purchase covers the three, with no account and no subscription you pay every month. | تدفعه كل شهر answers the headline's تدفع مرة واحدة. |
| mac.1.k | تكتب الرد مرة وترسله للجميع | You write the reply once and send it to everyone | The same statement voice as iPhone 1. |
| mac.1.h (built) | أهلًا [خالد]، سنشحن باقتك [المميزة] يوم [الثلاثاء]. | Hi [Khalid], we will ship your [Premium] package on [Tuesday]. | Built from the seed. |
| mac.1.s | تختار الرد بضغطة {cmd}، ونموذج قصير يطلب ملء الحقول قبل اللصق. | You pick the reply with a press of ⌘⇧V, and a short form asks for the fields to be filled before pasting. | الحقول is the app's word for blanks (حقول وتواريخ). بضغطة before the keys avoids a بـ hanging in front of key caps. |
| mac.2.k | أينما كنت تكتب | Wherever you are typing | Leads straight into the three keys below. |
| mac.2.h | {cmd} | ⌘⇧V | As the brief fixes it. |
| mac.2.s | تظهر لك الكاتلينج وآخر ما نسخته فوق أي تطبيق. | The cutlings and the last things you copied appear for you over any app. | Feminine تظهر, because the app treats plural الكاتلينج as feminine (تتزامن الكاتلينج المحفوظة). |
| mac.3.k | سجل الحافظة لا يحفظ | The clipboard history does not keep | A transitive verb whose object is the row of dots under it. سجل الحافظة is the app's name for the history. |
| mac.3.s | كل ما يُخفيه مدير كلمات السر لا يدخل السجل أبدًا. | Anything the password manager hides never enters the history. | كلمات السر, as Apple's Saudi pages and the app's own setting for this feature say it (the store description says كلمات المرور). |
| mac.4.k | ما تغيّره على Mac | What you change on Mac | Apple's Saudi page writes على Mac … على iPhone with no possessive. The shadda marks تغيّره as the verb. |
| mac.4.h | يتغيّر على [iPhone] | changes on [iPhone] | Completes the kicker as one sentence, chip on iPhone. |
| mac.4.s | كل شيء يتزامن عبر iCloud الخاص بك، بلا حساب جديد. | Everything syncs through your own iCloud, with no new account. | جديد because iCloud is itself an account. iCloud الخاص بك is the app's and Apple's phrasing. Shortened after the render left تنشئه alone on a second line. |
| mac.5.k | على iPhone وiPad وMac | On iPhone, iPad and Mac | Same as iPhone 6. |
| mac.5.h | تدفع [مرة واحدة] | You pay [one time] | Same as iPhone 6. |
| mac.5.s | شراء واحد يشمل الثلاثة، بلا حساب ولا اشتراك تدفعه كل شهر. | One purchase covers the three, with no account and no subscription you pay every month. | Same as iPhone 6. |
