# he: Cutling 2.0 store frame words, review

Words: `fastlane/compose/creative/v2/words/he.json`, written from `docs/aso/screens-2.0/C-words-brief.md` and the `he`
entry of `locale-facts.json`. Rendered for iPhone, iPad and Mac with direction C before handing over.

Register: the reader is spoken to the way Israeli listings speak (bit, PayBox, Cutling's own Hebrew listing and site):
impersonal present plural (כותבים, משלמים) and plural "you" (שלכם, השתמשתם) where a line speaks to the reader. No
masculine-singular imperative and no slash forms. The shop owner's messages to one customer use שלך, which is spelled
the same for a man and a woman, so one saved reply fits every customer.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names | נועה, איתי, תמר | Noa, Itai, Tamar | Common first names of Israeli adults: woman, man, woman; 3 to 4 letters. |
| cseed.mac_name | עומר | Omer | A common man's name, so the four customers are two women and two men. |
| cseed.reply | {name}, ההזמנה שלך יוצאת לדרך ב{date}! | {name}, the-order of-you goes-out to-the-road on-{date}! | Weekday: ב is a prefix Hebrew joins to the next word, so it sits just outside the chip and reads ביום שלישי, as ב״יום שלישי״ is written with quotes. יוצאת לדרך ("sets out") is the warm idiom, and it agrees with ההזמנה, never with the customer. 39 characters filled. |
| cseed.reply_name | עדכון משלוח | Shipping update | What a shop calls a message about a shipment; it heads the Mac form too, where the reply is also about the order going out. |
| cseed.mac_reply | {name}, ההזמנה שלך במסלול {plan} יוצאת ב{date}! | {name}, the-order of-you in-the-plan {plan} goes-out on-{date}! | "במסלול {plan}" stays grammatical with both choices (בסיסי is an adjective, פרימיום a noun), which "מסלול ה{plan} שלך" would not. לדרך is dropped to stay under 52 (49 filled with פרימיום). |
| cseed.name_label | שם | Name | The app's own label for a name. |
| cseed.plan_label | מסלול | Plan (lit. "track") | The Israeli word for a tier you buy (Netflix Israel: מסלול בסיסי / פרימיום); Cutling's 2.0 release notes use it too. |
| cseed.plan_choices | בסיסי, פרימיום | Basic, Premium | The pair Israeli plans use, and the example in the Hebrew release notes. |
| cseed.delivered | החבילה נמסרה ב-{date}. | The-package was-delivered on-{date}. | ב before a number takes a hyphen (ב-23), so ב- sits outside the date chip. 16 characters without the date. |
| cseed.delivered_name | אישור מסירה | Delivery confirmation | The courier term for proof of delivery. |
| iphone.1.k | כותבים אותה פעם אחת | [One] writes it one time | Impersonal present; אותה (it, feminine) points at the reply set below it. |
| iphone.1.h (built) | [נועה], ההזמנה שלך יוצאת לדרך ב[יום שלישי]! | [Noa], your order sets out on [Tuesday]! | Built from reply; ב sits against the weekday chip. |
| iphone.1.s | כשמקישים על התשובה, קאטלינג שואל מה השם. | When-[one]-taps on the-reply, Cutling asks what the-name [is]. | The app calls itself קאטלינג and makes it masculine (קאטלינג הקליד). "Saved" is left out to keep the line short; the keyboard below shows the reply as a saved key. |
| iphone.2.k | ושולחים אותה שוב, ללקוח הבא | And-[one]-sends it again, to-the-customer the-next | Finishes frame 1's kicker as one sentence across the pair; ללקוח is masculine to match איתי in this frame. |
| iphone.2.h (built) | [איתי], ההזמנה שלך יוצאת לדרך ב[יום שלישי]! | [Itai], your order sets out on [Tuesday]! | Same reply, next customer. |
| iphone.2.s | השמות שכבר השתמשתם בהם מחכים לכם במקלדת, הקשה אחת ובחרתם. | The-names that-already you-used them wait for-you in-the-keyboard, one tap and-you-chose. | Plural "you"; "הקשה אחת ו..." is the Hebrew one-tap idiom. |
| iphone.3.k | קאטלינג כותב את התאריך לבד | Cutling writes the date alone | לבד ("by itself") is the spoken word; בעצמו would read stiffer. |
| iphone.3.h (built) | החבילה נמסרה ב-[23 בנובמבר 2026]. | The package was delivered on [23 November 2026]. | Built from delivered; renders as החבילה נמסרה / ב-[date]. |
| iphone.3.s | היום, מחר או בעוד שבוע, תמיד נכון ליום שבו מדביקים. | Today, tomorrow or in-another week, always correct for-the-day on-which [one] pastes. | נכון ל... is the Hebrew "as of" (נכון להיום), so the date is right as of the day of pasting. |
| iphone.4.k | ומה שאצלכם אף פעם לא משתנה | And-what that-at-you never not changes | אצלכם ("at your end") says "about you" once, so the chips need no possessive. |
| iphone.4.h | [מספר החשבון], [הכתובת], [החתימה] | [The-account number], [the-address], [the-signature] | Hebrew lets the definite article carry "your" after אצלכם; שלכם on each chip would triple the length. A comma list with no ו keeps a prefix off the last chip. 27 characters. |
| iphone.4.s | מקלדת קאטלינג מקלידה כל אחד מהם בהקשה אחת, בכל אפליקציה. | Keyboard-of Cutling types each one of-them in-one-tap, in-every app. | הקשה is Apple's Hebrew word for a tap. |
| iphone.5.k | יש מקום להכול | There-is room for-everything | הכול in the full spelling the app uses (הכול מוכן). |
| iphone.5.h | [5,000] קאטלינג | [5,000] cutling | Uninflected after a number, as locale-facts gives the plural and as the app's count label prints it (%lld קאטלינג). קאטלינגים would also be grammatical. |
| iphone.5.s | עד עכשיו היה מקום ל-100, וכל אחד מכיל מייל שלם. | Until now there-was room for-100, and-each one holds a-whole email. | Echoes מקום from the kicker; ל-100 hyphenated like the app's "מקום ל-%@"; מכיל in its "has room for" sense. |
| iphone.6.k | iPhone, iPad ו-Mac | iPhone, iPad and-Mac | As Cutling's Hebrew site writes it; ו before a Latin word takes a hyphen. |
| iphone.6.h | משלמים [פעם אחת] | [One] pays [one time] | The site's own phrase (משלמים פעם אחת). 14 characters. |
| iphone.6.s | רכישה אחת כוללת את שלושתם, בלי הרשמה ובלי מנוי. | One purchase includes the-three-of-them, without registration and-without subscription. | בלי הרשמה ("no sign-up") as in the listing, because חשבון ("account") would also read as the bank account of frame 4. |
| mac.1.k | כותבים פעם אחת, שולחים לכולם | [One] writes one time, [one] sends to-everyone | Same impersonal present as the iPhone pair. |
| mac.1.h (built) | [עומר], ההזמנה שלך במסלול [פרימיום] יוצאת ב[יום שלישי]! | [Omer], your order on the [Premium] plan goes out on [Tuesday]! | Built from mac_reply with the better plan. |
| mac.1.s | בוחרים תשובה עם {cmd}, וטופס קצר שואל מה חסר לפני ההדבקה. | [One] picks a-reply with ⌘⇧V, and-a-form short asks what is-missing before the-pasting. | עם ("with") keeps the keycaps free of a prefix; they render ⌘⇧V left to right inside the line, as Cutling's Hebrew site sets the shortcut. |
| mac.2.k | איפה שלא תקלידו | Wherever that-not you-will-type | The spoken form of "wherever you type", plural. |
| mac.2.h | {cmd} | ⌘⇧V | Fixed by the brief. |
| mac.2.s | הקאטלינג שלכם ומה שהעתקתם לאחרונה נפתחים מעל כל אפליקציה. | The-cutling of-you and-what you-copied lately open above every app. | Product word uninflected, as on iPhone 5. |
| mac.3.k | היסטוריית לוח הגזירים מדלגת על | History-of the-clipboard skips over | Ends on על so the row of dots reads as its object; לוח הגזירים and מדלגת על are the listing's own words. |
| mac.3.s | מה שמנהל סיסמאות מסמן כמוסתר לא נכנס להיסטוריה. | What that-a-manager-of passwords marks as-hidden does-not enter to-the-history. | כמוסתר as in the listing; אף פעם ("never") dropped, since לא נכנס already leaves no exception. |
| mac.4.k | מה שמשנים ב-Mac | What that-[one]-changes on-Mac | Kicker and headline read as one sentence. |
| mac.4.h | משתנה גם ב-[iPhone] | changes also on-[iPhone] | ב- stays outside the chip, hyphenated before a Latin word. |
| mac.4.s | הסנכרון עובר דרך ה-iCloud שלכם, בלי הרשמה. | The-sync passes through the-iCloud of-you, without registration. | ה-iCloud with a hyphen, as the app writes it. |
| mac.5.k | iPhone, iPad ו-Mac | iPhone, iPad and-Mac | Same as iPhone 6. |
| mac.5.h | משלמים [פעם אחת] | [One] pays [one time] | Same as iPhone 6. |
| mac.5.s | רכישה אחת כוללת את שלושתם, בלי הרשמה ובלי מנוי. | One purchase includes the-three-of-them, without registration and-without subscription. | Same as iPhone 6. |

## What the render showed

- `python3 build.py he C` on the build of commit 9549bf97: all 15 frames render right to left, every chip stays whole,
  and every line fits its column on iPhone, iPad and Mac.
- The Hebrew `02_MainGrid` captures (iPhone and iPad; shown on frames 5 and 6 and inside Mac 4) are older than the
  app's words: they title the grid קאטלינגים with "8 קאטלינגים" under it, from before the app's string became
  "%lld קאטלינג". Fresh captures would match the iPhone 5 headline.
