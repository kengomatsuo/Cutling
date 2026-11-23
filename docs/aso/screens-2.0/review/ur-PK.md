# ur-PK: Cutling 2.0 store frame words, review

Words: `fastlane/compose/creative/v2/words/ur-PK.json`, written from `docs/aso/screens-2.0/C-words-brief.md` and the
`ur-PK` entry of `locale-facts.json`. Rendered for iPhone, iPad and Mac with direction C before handing over.

Register: the buyer is addressed as آپ with the polite imperative (لکھیں، بھیجیں، چنیں، بدلیں), as Cutling's Urdu app,
store listing and 2.0 release notes do. The app is written "Cutling" in Latin letters, as the store name, the release
notes and the in-app event write it, and takes masculine verbs as in the app (کٹلنگ نے ٹائپ کر دیا). A saved item is
کٹلنگ, masculine, the same word for one and many, as locale-facts gives it. Urdu punctuation throughout (، ؛ ۔).
"Tomorrow" is never کل, which also means yesterday.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names | عائشہ، حسن، زینب | Ayesha, Hassan, Zainab | Common Pakistani first names: woman, man, woman. عائشہ and حسن set the same width in the headline face (205 and 210 px at 100 px), so frames 1 and 2 break in the same places on iPhone and iPad. With حمزہ (159 px), iPad frame 2 pulled the weekday chip up a line. |
| cseed.mac_name | بلال | Bilal | A common man's name, so the four customers are two women and two men. |
| cseed.reply | {name}، آپ کا آرڈر {date} کو روانہ ہوگا۔ | {name}, your order on {date} will-be dispatched. | آپ کا agrees with آرڈر (masculine), not with the customer, so one reply fits a woman and a man. The weekday stays bare, with کو ("on") outside its chip. روانہ ہونا is what shops and couriers say of a parcel leaving. ہوگا is written joined, as the app does, so a line can never strand گا. 38 characters filled. |
| cseed.reply_name | آرڈر روانہ | Order dispatched | A label a shop owner gives the template. It also heads the Mac form, where the reply is about an order going out too. |
| cseed.mac_reply | {name}، آپ کا {plan} پیکج {date} کو روانہ ہوگا۔ | {name}, your {plan} package on {date} will-be dispatched. | پیکج is the word Pakistan buys tiers by (mobile and internet packages), masculine like آرڈر. 43 characters filled with پریمیم. |
| cseed.name_label | نام | Name | The app's own word for Name. |
| cseed.plan_label | پیکج | Package | As in the reply. |
| cseed.plan_choices | بیسک، پریمیم | Basic, Premium | The pair the Urdu 2.0 release notes already give as their example (بیسک یا پریمیم پلان). |
| cseed.delivered | آپ کا پارسل {date} کو پہنچ گیا۔ | Your parcel on {date} has-arrived. | پہنچ گیا ("has arrived"), since the passive پہنچا دیا گیا runs past 28 characters; کو follows the date as it follows the weekday. 25 characters without the date. |
| cseed.delivered_name | پارسل پہنچ گیا | Parcel arrived | Not ڈیلیوری, which in everyday Pakistani Urdu also means childbirth. |
| iphone.1.k | ایک ہی بار لکھا گیا جواب | A reply written only one time | A noun phrase that leads into the reply set under it; ہی makes "only once". 24 characters. |
| iphone.1.h (built) | [عائشہ]، آپ کا آرڈر [منگل] کو روانہ ہوگا۔ | [Ayesha], your order will be dispatched on [Tuesday]. | Built from reply. |
| iphone.1.s | محفوظ جواب پر ٹیپ کرتے ہی Cutling نام پوچھتا ہے۔ | The moment you tap the saved reply, Cutling asks the name. | ٹیپ کرتے ہی ("as soon as tapping") as the release notes say it. 48 characters. |
| iphone.2.k | وہی جواب، اگلے گاہک کو | The same reply, to the next customer | Pairs with frame 1's kicker. گاہک is the everyday shop word for a customer, for a man or a woman. |
| iphone.2.h (built) | [حسن]، آپ کا آرڈر [منگل] کو روانہ ہوگا۔ | [Hassan], your order will be dispatched on [Tuesday]. | Same reply, next customer. |
| iphone.2.s | پچھلے گاہکوں کے نام ایک ٹیپ پر تیار ملتے ہیں۔ | Previous customers' names are found ready at one tap. | ایک ٹیپ پر follows the idiom ایک کلک پر ("at one click"). |
| iphone.3.k | تاریخ Cutling خود لکھتا ہے | The date, Cutling writes itself | The topic (تاریخ) first, as Urdu puts what it is talking about. |
| iphone.3.h (built) | آپ کا پارسل [23 نومبر، 2026] کو پہنچ گیا۔ | Your parcel arrived on [23 November, 2026]. | Built from delivered. |
| iphone.3.s | آج، اگلے دن یا ایک ہفتے بعد کی تاریخ، چسپاں کرنے کے دن بالکل درست۔ | Today's, the next day's or a week-later date, exactly right on the day of pasting. | اگلے دن, not کل (also "yesterday"; and آج، کل can read as آج کل, "nowadays"). ایک ہفتے بعد is the app's own label, and its ایک keeps ہفتے from reading as Saturday. The comma falls mid-line, where the two lines break. |
| iphone.4.k | اور جو کبھی نہیں بدلتا: | And what never changes: | Leads into the headline as one sentence; the colon hands over to the list. |
| iphone.4.h | [میرا اکاؤنٹ نمبر]، [میرا پتہ] اور [میرے دستخط] | [My account number], [my address] and [my signature] | The headline is the buyer's own words, so the possessive is میرا, as the app names these (میرا پتہ). اکاؤنٹ نمبر is what Pakistanis send to be paid. دستخط takes plural agreement (میرے) as in speech, and is the word the app's own seed uses for an email sign-off (ای میل دستخط), shown in the capture below. 41 characters. |
| iphone.4.s | ہر ایک کسی بھی ایپ میں، Cutling کی بورڈ پر بس ایک ٹیپ۔ | Each one, in any app, just one tap on the Cutling keyboard. | Verbless, as Urdu ad lines run. کی بورڈ in two words as the store name spells it. 54 characters. |
| iphone.5.k | سب کچھ سما جائے گا | Everything will fit | سمانا ("to fit inside") says room in the buyer's terms. |
| iphone.5.h | [5,000] کٹلنگ | [5,000] cutling | Bare after a number, as locale-facts gives the plural and the app counts (%lld کٹلنگ). |
| iphone.5.s | پہلے صرف 100 کٹلنگ کی گنجائش تھی، اب ہر ایک میں پوری ای میل آتی ہے۔ | Before there was room for only 100 cutlings; now a whole email fits in each one. | گنجائش is the app's word for room (%@ کی گنجائش). آتی ہے rather than آ جاتی ہے, so the verb has no helper to split. کٹلنگ makes both clauses the same width, so the two iPhone lines break at the comma (without it, اب ended line 1). |
| iphone.6.k | iPhone،‏ iPad اور Mac | iPhone, iPad and Mac | A right-to-left mark follows the comma (written `‏` in the file). Without it the comma joins "iPhone" on its Latin side, so reading from the right meets iPad first. |
| iphone.6.h | ادائیگی بس [ایک بار] | Payment just [one time] | بس ایک بار ("just once") is the spoken emphasis. 18 characters. |
| iphone.6.s | تینوں کے لیے ایک ہی خریداری؛ نہ اکاؤنٹ، نہ سبسکرپشن۔ | One single purchase for all three; no account, no subscription. | نہ اکاؤنٹ، نہ … is the app's own pattern (نہ اکاؤنٹ، نہ انٹرنیٹ). سبسکرپشن is the word Pakistani app buyers use. |
| mac.1.k | ایک بار لکھیں، سب کو بھیجیں | Write once, send to all | Two polite imperatives. |
| mac.1.h (built) | [بلال]، آپ کا [پریمیم] پیکج [منگل] کو روانہ ہوگا۔ | [Bilal], your [Premium] package will be dispatched on [Tuesday]. | Built from mac_reply with the better plan. |
| mac.1.s | {cmd} سے جواب چنیں تو چسپاں ہونے سے پہلے، ایک چھوٹا فارم آپ سے نام اور پیکج پوچھ لیتا ہے۔ | Pick the reply with ⌘⇧V and, before it is pasted, a small form asks you the name and package. | Names the two blanks the form beside it shows (the date fills itself). آپ سے ("you") evens the two halves, so the lines break at the comma and never between سے and پہلے. |
| mac.2.k | جہاں بھی ٹائپ کر رہے ہوں | Wherever you may be typing | Subjunctive ہوں, with آپ understood. |
| mac.2.h | {cmd} | ⌘⇧V | Fixed by the brief. |
| mac.2.s | آپ کے کٹلنگ اور جو حال ہی میں کاپی کیا، دونوں کسی بھی ایپ کے اوپر کھل جاتے ہیں۔ | Your cutlings and whatever you copied lately: both open over any app. | Says what was copied, not کاپیاں, which also means school notebooks. دونوں ("both") gathers the two subjects for one plural verb, and the comma is where the two lines break. |
| mac.3.k | کلپ بورڈ ہسٹری میں سب کچھ، سوائے اس کے: | Everything in the clipboard history, except this: | The row of password dots under it is the اس ("this") left out. ہسٹری rather than the app's tab word تاریخ, which also means date. |
| mac.3.s | پاس ورڈ مینیجر جسے مخفی قرار دے، وہ ہسٹری میں کبھی بھی نہیں آتا۔ | What a password manager declares hidden never, ever comes into the history. | مخفی ("hidden") is the listing's own word. کبھی بھی ("ever") puts the weight on never and evens the halves, so the lines break at the comma, not inside قرار دے. |
| mac.4.k | Mac پر جو بھی بدلیں، | Whatever you change on the Mac, | The جو … وہ pair runs from kicker into headline as one sentence. |
| mac.4.h | وہ [iPhone] پر بھی بدل جاتا ہے | that changes on the [iPhone] too | The chip is on iPhone alone. |
| mac.4.s | سنک آپ کے اپنے iCloud سے ہوتا ہے، کوئی اکاؤنٹ بنانے کی ضرورت نہیں۔ | The sync goes through your own iCloud; no need to create any account. | سنک is the everyday word (the app's ہم آہنگ can split across a line as ہم / آہنگ). بنانے ("create") keeps this account from reading as the bank account of iPhone frame 4. |
| mac.5.k | iPhone،‏ iPad اور Mac | iPhone, iPad and Mac | Same as iPhone 6, with the same right-to-left mark. |
| mac.5.h | ادائیگی بس [ایک بار] | Payment just [one time] | Same as iPhone 6. |
| mac.5.s | تینوں کے لیے ایک ہی خریداری؛ نہ اکاؤنٹ، نہ سبسکرپشن۔ | One single purchase for all three; no account, no subscription. | Same as iPhone 6. |

## What the render showed

- Nastaliq runs about half an em past New York's line box above and below. At the build's Latin spacing (headline
  1.14, subline 1.25, bubble 1.25), each line's descenders ran into the chip below it, the three chips of iPhone
  frame 4 merged into one green block, and the drawn Mac form hid its نام label behind the name field. `build.py`
  `locale_css` now gives ur-PK a headline line height of 2, chip padding of .22em above and .38em below, sublines,
  note and bubble 1.9, balanced headline and subline lines, and a 1.2 line box inside the drawn Mac form. The note
  card and bubble in `directions/C.py` take their line heights from classes (`.note`, `.bubble`) instead of inline
  styles, so a script can set its own; every other language keeps 1.5 and 1.25.
- Urdu writes many single units as two spaced words (ہم آہنگ، قرار دے، کاپی کیا، سے پہلے), and Chrome may break a line
  at any of those spaces. So every subline that runs to two lines is worded with a comma at the width midpoint, and
  balanced wrapping breaks it there. Each break was measured at the frame's real width before the final render.
- With that spacing, `python3 build.py ur-PK C` renders all 17 frames right to left: every chip covers its whole
  word, no line touches the next, and frames 1 and 2 break identically on iPhone (three lines) and iPad (two).
- The Urdu `02_MainGrid` captures (iPhone and iPad; shown on frames 5 and 6 and inside Mac 4) are older than the
  app's words: they title the grid کٹلنگز with "8 کٹلنگز" under it, from before the app's string became
  "%lld کٹلنگ". Fresh captures would match the iPhone 5 headline.
- The Try It capture on frame 4 writes the app's name in Urdu script (یہاں کٹلنگ سے ٹائپ کریں), as the app's own
  strings do; the frame words write it in Latin letters, as the store listing does.
