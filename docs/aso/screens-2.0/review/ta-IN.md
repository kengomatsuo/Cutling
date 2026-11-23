# ta-IN (Tamil, India): Cutling 2.0 store frames, direction C (card ASG167)

Written blind from `C-words-brief.md` and the `ta-IN` entry of `locale-facts.json`; the words file is
`fastlane/compose/creative/v2/words/ta-IN.json`. Register: நீங்கள் (polite "you": உங்கள், -லாம்), the form the
ta-IN store page, its 2.0 release notes and Meta's Tamil WhatsApp Business listing use, kept in every line. The shop
owner's replies speak as "we" (அனுப்புகிறோம்). Some of the app's older Tamil strings say நீ (உனது), and these frames
do not follow them. Words come from the app where it has one: கட்லிங்கு/கட்லிங்குகள், விசைப்பலகை (its Keyboard Setup
string), வெற்றிடம் (blank), நகலெடு (copy), ஒத்திசை (sync), ஒட்டு (paste). The brand is written in Latin, "Cutling", and
case endings join Latin names with a hyphen (Mac-இல்), as the store page and the app write them. Apple's own Tamil
joins them without one (iPhoneஇல்). There is no மற்றும் anywhere: as a noun-joining "and" it reads as translated
Tamil, so lists use commas or a case ending on the last item. Punctuation is the full stop and comma modern Tamil
uses, with no long dashes.

Lengths: the brief counts characters, but every Tamil vowel sign and pulli is its own code point. Both counts are given
where a limit applies, and the rendered frames decide. All 17 frames were built with `python3 build.py ta-IN C`, and
all of them fit. In frames 1 and 2 the keyboard's fill-in bar is one line that cuts off what overflows. Measured in
the real page, the reply takes 938 of 1054 px on iPhone and 1286 of 1445 px on iPad. Two longer drafts were cut off
there and were rewritten.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names | பிரியா, அருண், கவிதா | Priya, Arun, Kavitha | Common first names for Tamil Nadu customers in their 20s to 40s: woman, man, woman. 3 Tamil letters each. |
| cseed.mac_name | செந்தில் | Senthil | A clearly Tamil man's name (one of Murugan's names). 4 letters, 8 code points. |
| cseed.reply | {name}, {date} அன்று ஆர்டரை அனுப்புகிறோம். | {name}, on {date} [we] are sending the order. | The shop speaks as "we", in the present tense Tamil uses for a planned day. The weekday stays bare and takes அன்று ("on"), which works for all seven days. Putting the date before the object means no sandhi consonant has to agree with whichever weekday Cutling types. உங்கள் ("your") is left out because with it the bar measured 1093 px in 1054 and cut the last word. Leaving out a possessive the chat already makes clear is ordinary Tamil. Filled: 27 Tamil letters, 44 code points. |
| cseed.reply_name | ஆர்டர் நிலை | Order status | What a seller would file a dispatch reply under. 11 code points. |
| cseed.mac_reply | {name}, {date} அன்று உங்கள் {plan} ஆர்டரை அனுப்புகிறோம். | {name}, on {date} [we] are sending your {plan} order. | Same reply as the iPhone one. The Mac form's preview wraps, so "your" stays. Filled: 39 Tamil letters (63 code points), against a limit of 52. |
| cseed.name_label | பெயர் | Name | The plain word for a person's name. |
| cseed.plan_label | திட்டம் | Plan | Tamil tech press calls Netflix and BSNL tiers பேசிக் திட்டம் and பிரீமியம் திட்டம், and Cutling's own 2.0 notes give the same example. |
| cseed.plan_choices | பேசிக், பிரீமியம் | Basic, Premium | Loanwords Tamil buyers know from those plans. பிரீமியம் is 5 Tamil letters but 9 code points; it fits its chip. |
| cseed.delivered | {date} அன்று டெலிவரி செய்யப்பட்டது. | On {date} delivery was done. (Delivered on {date}.) | The exact wording Flipkart's Tamil text and small Tamil sellers post with a date. டெலிவரி is the everyday word. 19 Tamil letters without the date (29 code points). |
| cseed.delivered_name | டெலிவரி தேதி | Delivery date | A short name for the saved note. |
| C.iphone.1.k | ஒருமுறை எழுதிய பதில். | A reply written once. | Names the reply under it. Pairs with frame 2's kicker, and both end on பதில் (reply). |
| C.iphone.1.s | சேமித்த பதிலைத் தட்டியதும் Cutling பெயரைக் கேட்கும். | As soon as [you] tap the saved reply, Cutling asks for the name. | -அதும் is "as soon as". The sandhi doublings (பதிலைத் தட்டி, பெயரைக் கேட்கும்) are written as careful Tamil writes them. |
| C.iphone.2.k | அடுத்த வாடிக்கையாளருக்கும் அதே பதில். | The same reply to the next customer too. | A verbless sentence. -உம் ("too") says "again". வாடிக்கையாளர் is the word WhatsApp Business's Tamil listing uses for a customer. |
| C.iphone.2.s | முன்பு பயன்படுத்திய பெயர்கள் விசைகளாகவே காத்திருக்கும். | Names used before will be waiting right there as keys. | -ஏ on விசைகளாக gives "already, right there". On a keyboard, keys already mean one tap, and frame 4 says "one tap" outright. |
| C.iphone.3.k | தேதியை Cutling தானே எழுதும். | Cutling writes the date by itself. | தானே = "by itself". |
| C.iphone.3.s | இன்றோ நாளையோ ஒரு வாரம் கழித்தோ, ஒட்டும் நாளில் தேதி சரியாக வரும். | Whether today, tomorrow or a week later, on the day [you] paste, the date comes out right. | -ஓ…-ஓ is Tamil's own "whether…or". ஒரு வாரம் கழித்து ("a week later") is the store notes' name for that option. |
| C.iphone.4.k | உங்களைப் பற்றி என்றும் மாறாதவையும் | And the things about you that never change | -உம் gives the "and". It runs into the headline, so there is no full stop. 34 code points against a limit of 34. |
| C.iphone.4.h | [வங்கிக் கணக்கு எண்], [வீட்டு முகவரி], [கையொப்பம்]. | Bank account number, home address, signature. | "Your" is said once, in the kicker, as Tamil does for a list. Each chip is the plain name of the thing. கையொப்பம் is the store description's word for an email signature. 30 letters, 45 code points, against 50. |
| C.iphone.4.s | எந்த ஆப்பிலும் Cutling விசைப்பலகையில் ஒவ்வொன்றும் ஒரு தட்டல்தான். | In any app, on the Cutling keyboard, each one is just one tap. | ஆப் is how Cutling's store page and app write "app" (Apple's Tamil chrome writes செயலி). தட்டல் is Apple's Tamil noun for a tap. 44 letters, 65 code points; two lines. |
| C.iphone.5.k | எல்லாவற்றுக்கும் இடம் உண்டு. | There is room for everything. | உண்டு is the short, idiomatic "there is". |
| C.iphone.5.h | [5,000] கட்லிங்குகள் | 5,000 cutlings | n5000 and the product's plural, as the facts give them. |
| C.iphone.5.s | முன்பு 100 மட்டுமே, இப்போது ஒவ்வொன்றிலும் ஒரு முழு மின்னஞ்சலே அடங்கும். | Before, only 100; now even a whole email fits in each one. | இப்போது ("now") stops both facts reading as "before". -ஏ on மின்னஞ்சல் gives "even a whole email". |
| C.iphone.6.k | iPhone, iPad, Mac-இல் இயங்கும். | Runs on iPhone, iPad, Mac. | The case ending on the last item covers the whole list, as Tamil headlines write சென்னை, மதுரை, கோவையில். |
| C.iphone.6.h | [ஒருமுறை] வாங்கினால் போதும். | Buying [it] once is enough. | The phrase Tamil ads, a Tamil App Store listing and a Tamil Google Play listing use for a one-time purchase. The chip is on ஒருமுறை (once). 15 Tamil letters (26 code points) against 18; three lines on iPhone, two on iPad. |
| C.iphone.6.s | ஒரே வாங்குதலில் மூன்றிலும் கிடைக்கும், கணக்கும் சந்தாவும் இல்லை. | With a single purchase it is on all three; no account and no subscription either. | வாங்குதல் and சந்தா are Apple's own Tamil words on the App Store, and ஒரே வாங்குதலில் is the store description's phrase. "Neither X nor Y" is said with -உம்…-உம் இல்லை. |
| C.mac.1.k | ஒருமுறை எழுதி எல்லோருக்கும் அனுப்பலாம். | Having written [it] once, [you] can send [it] to everyone. | -லாம் ("can") is the store page's way of offering the buyer something. |
| C.mac.1.s | {cmd} அழுத்திப் பதிலைத் தேர்ந்தெடுத்தால், ஒட்டும் முன் ஒரு சிறு படிவம் வெற்றிடங்களைக் கேட்கும். | If [you] press ⌘⇧V and pick the reply, before pasting a small form asks for the blanks. | வெற்றிடம் is the app's word for a blank (வெற்றிடங்களும் தேதிகளும்). Three lines on the Mac. |
| C.mac.2.k | எங்கே தட்டச்சு செய்தாலும் | Wherever [you] type | Runs into the ⌘⇧V keys, so there is no full stop. |
| C.mac.2.h | {cmd} | ⌘⇧V | As the brief fixes it. |
| C.mac.2.s | உங்கள் கட்லிங்குகளும் கடைசியாக நகலெடுத்தவையும் எந்த ஆப்பின் மேலும் திறக்கும். | Your cutlings and what [you] copied last open on top of any app. | நகலெடு is the app's Copy. மேல் + உம் after the genitive reads as "on top of", not as "moreover". |
| C.mac.3.k | கிளிப்போர்டு வரலாறு சேமிக்காதது | What the clipboard history does not save | Tamil puts the verb last, so the dots below cannot be the verb's object. A nominal "what it does not save" makes the row of dots read as the answer. கிளிப்போர்டு is spelled as in the store name. |
| C.mac.3.s | கடவுச்சொல் நிர்வாகி மறைவானது எனக் குறிக்கும் எதுவும் வரலாற்றில் சேராது. | Anything a password manager marks as hidden never gets into the history. | கடவுச்சொல் நிர்வாகி is the store description's name for a password manager. The verb changes from the kicker's "save" to "get into". |
| C.mac.4.k | Mac-இல் எதை மாற்றினாலும் | Whatever [you] change on the Mac | -ஆலும் gives "whatever". It runs into the headline. |
| C.mac.4.h | [iPhone]-இலும் மாறிவிடும். | On the iPhone too it gets changed. | The chip covers only "iPhone"; the hyphen-joined case ending sits outside it. -விடும் says it happens by itself. |
| C.mac.4.s | உங்கள் சொந்த iCloud வழியாகவே ஒத்திசையும், கணக்கு எதுவும் தேவையில்லை. | [It] syncs through your own iCloud; no account of any kind is needed. | ஒத்திசையும் is the verb form the app's own iCloud string uses. |
| C.mac.5.k | iPhone, iPad, Mac-இல் இயங்கும். | Runs on iPhone, iPad, Mac. | Same words as iPhone 6. |
| C.mac.5.h | [ஒருமுறை] வாங்கினால் போதும். | Buying [it] once is enough. | Same as iPhone 6. |
| C.mac.5.s | ஒரே வாங்குதலில் மூன்றிலும் கிடைக்கும், கணக்கும் சந்தாவும் இல்லை. | With a single purchase it is on all three; no account and no subscription either. | Same as iPhone 6. |

Headlines the build makes from the seed (chips in brackets):

| Frame | Headline | Literal back-translation |
|---|---|---|
| iPhone/iPad 1 | [பிரியா], [செவ்வாய்] அன்று ஆர்டரை அனுப்புகிறோம். | Priya, on Tuesday [we] are sending the order. |
| iPhone/iPad 2 | [அருண்], [செவ்வாய்] அன்று ஆர்டரை அனுப்புகிறோம். | Arun, on Tuesday [we] are sending the order. |
| iPhone/iPad 3 | [23 நவம்பர், 2026] அன்று டெலிவரி செய்யப்பட்டது. | Delivered on 23 November, 2026. |
| Mac 1 | [செந்தில்], [செவ்வாய்] அன்று உங்கள் [பிரீமியம்] ஆர்டரை அனுப்புகிறோம். | Senthil, on Tuesday [we] are sending your Premium order. |
