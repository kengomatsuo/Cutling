# hi: words for the 2.0 store frames, review

Written from `C-words-brief.md` and the hi facts, into `fastlane/compose/creative/v2/words/hi.json`. Every line speaks to
the buyer as आप with the polite imperative (-ें, -एँ), as Apple's Hindi App Store pages, Cutling's Hindi app strings and
its Hindi 2.0 release notes do. Sentences end with the danda (।), with no space before it. Nukta spellings follow the app
(तारीख़, हफ़्ते, ख़रीद). iPhone, iPad, Mac and iCloud stay in Latin letters, as Apple writes them in Hindi. The app's name
is written `Cutling`, as on the Hindi store page ("Cutling - क्लिपबोर्ड कीबोर्ड"); the product word stays `कटलिंग`, as the
facts give it. Everyday loanwords (सेव, टैप, पेस्ट, ऑर्डर, अकाउंट, सब्सक्रिप्शन) are the ones the Hindi listing and site
already use. The bank account is `खाता` and the sign-up account is `अकाउंट`, so the two never share a word across frames 4
and 6.

Rendered through direction C at App Store sizes (iPhone, iPad, Mac) and measured at the frames' own fonts and widths
before handing over. Nothing clips, and the frame 1 and 2 headlines break on the same lines. No chip splits across
lines, every subline fits on one line, and no headline leaves a single word on its last line. Every limit in the brief
holds even when counted in Unicode code points, which is stricter than counting letters.

| Key | String | Back-translation | Choice |
|---|---|---|---|
| cseed.names | `नेहा`, `रवि`, `पूजा` | Neha, Ravi, Pooja | Common Hindi-belt names, two women and a man; रवि over रोहन, which is wider than नेहा and pushed frame 2's headline to four lines against frame 1's three. |
| cseed.mac_name | `अंकित` | Ankit | Short and common; a second man, so the four names split evenly. |
| cseed.reply | `{name} जी, आपका ऑर्डर {date} को भेजेंगे।` | {name} ji, your order {date} on (we) will send. | Shops address customers by first name with जी, which is where the warmth sits in Hindi (a "Hi" would read borrowed). मंगलवार stays as written and takes the postposition को ("on Tuesday"). The subject हम (we) drops as in everyday chat. 39 of 40 filled. |
| cseed.reply_name | `ऑर्डर अपडेट` | Order update | What an Indian seller calls this message; two loanwords everyone uses. |
| cseed.mac_reply | `{name} जी, आपका {plan} प्लान {date} से शुरू है।` | {name} ji, your {plan} plan from {date} start is. | A plan starts, it is not shipped; present tense for a set start (`शुरू है`) is idiomatic and keeps Mac 1 on three whole phrases, where `शुरू होगा` left `होगा।` alone on a fourth line. 49 of 52 filled. |
| cseed.name_label | `नाम` | Name | The app's own Hindi label for Name. |
| cseed.plan_label | `प्लान` | Plan | The app's own word (its Variables list shows `प्लान ▾`); what Indian buyers call a tier. |
| cseed.plan_choices | `बेसिक`, `प्रीमियम` | Basic, Premium | The pair the Hindi 2.0 release notes already give as their example ("बेसिक या प्रीमियम प्लान"); `प्रीमियम` is exactly 8. |
| cseed.delivered | `{date} को पार्सल पहुँच गया।` | On {date} (the) parcel arrived. | How a small seller says it; date first, so the green date chip stays whole on line 1 on iPhone and iPad (`आपका ऑर्डर {date}…` split it as "23 / नवंबर 2026"). 21 of 28 without the date. |
| cseed.delivered_name | `डिलीवरी मैसेज` | Delivery message | The everyday name a seller gives this note. |
| C.iphone.1.k | `जवाब एक ही बार लिखें।` | Reply one only time write. | Polite imperative with आप implied; `एक ही बार` is "only once". 21 of 24. |
| C.iphone.1.h (built) | `[नेहा] जी, आपका ऑर्डर [मंगलवार] को भेजेंगे।` | [Neha] ji, your order on [Tuesday] (we) will send. | Built from the reply; three lines on iPhone, two on iPad. |
| C.iphone.1.s | `सेव किए जवाब पर टैप करें, Cutling नाम पूछ लेगा।` | Saved reply on tap, Cutling (the) name will ask. | `सेव` as in the listing's own subtitle and promotional text; `पूछ लेगा` says Cutling takes care of asking. |
| C.iphone.2.k | `वही जवाब, अगले ग्राहक को भी।` | Same reply, to (the) next customer too. | Repeats जवाब from frame 1 so the pair reads as one thought; `भी` (too) carries "again". |
| C.iphone.2.h (built) | `[रवि] जी, आपका ऑर्डर [मंगलवार] को भेजेंगे।` | [Ravi] ji, your order on [Tuesday] (we) will send. | Built; the same line breaks as frame 1, only the name chip changes. |
| C.iphone.2.s | `पहले इस्तेमाल किए नाम तैयार मिलते हैं, एक टैप में चुनें।` | Before used names ready are found, in one tap choose. | `तैयार मिलते हैं` ("you find them ready") is the waiting; the one-tap keys become "pick in one tap". |
| C.iphone.3.k | `तारीख़ अपने आप भर जाती है।` | Date by itself fills in. | तारीख़ is the app's word (`खाली जगहें और तारीख़ें`). |
| C.iphone.3.h (built) | `[23 नवंबर 2026] को पार्सल पहुँच गया।` | On [23 November 2026] (the) parcel arrived. | Built from the note with the long date; two lines, chip whole. |
| C.iphone.3.s | `आज, कल या एक हफ़्ते बाद, पेस्ट वाले दिन के हिसाब से।` | Today, tomorrow or one week after, by the paste day's reckoning. | Next to "a week later", `कल` reads as tomorrow. `पेस्ट वाले दिन के हिसाब से` says the date is counted from the day you paste. Shortened to one line, where the first draft broke `उसी के / हिसाब से`. |
| C.iphone.4.k | `और वह सब जो कभी नहीं बदलता:` | And that all which never changes: | Leads into the headline as one sentence; written `वह` rather than the spoken `वो`. 27 of 34. |
| C.iphone.4.h | `आपका [खाता नंबर], [पता] और [हस्ताक्षर]।` | Your [account number], [address] and [signature]. | Hindi puts one possessive over a list. `हस्ताक्षर` is the app's own word, and its `ईमेल हस्ताक्षर` tile shows in frame 5. `खाता नंबर` keeps the bank number apart from the sign-up `अकाउंट`. Breaks after the comma. 33 of 50. |
| C.iphone.4.s | `हर एक बस एक टैप, किसी भी ऐप में, Cutling कीबोर्ड से।` | Each one just one tap, in any app, from Cutling keyboard. | `हर एक बस एक टैप` is natural price-tag-style Hindi; one line, where `हर एक के लिए…` broke `Cutling / कीबोर्ड`. |
| C.iphone.5.k | `सब कुछ समा जाएगा।` | Everything will fit in. | `समा जाना` (to fit inside) is the idiom for room. |
| C.iphone.5.h | `[5,000] कटलिंग` | [5,000] cutlings | n5000 and the product plural exactly as given (कटलिंग has the same plural form); a noun phrase takes no danda. |
| C.iphone.5.s | `पहले सिर्फ़ 100 थे, और हर एक में पूरा ईमेल आ जाता है।` | Before only 100 were, and in each one a whole email comes in. | n100 as given; `पूरा ईमेल आ जाता है` is the release notes' own phrase. |
| C.iphone.6.k | `iPhone, iPad और Mac पर चलता है।` | On iPhone, iPad and Mac (it) runs. | A full sentence, so it ends on Hindi instead of a danda after "Mac". |
| C.iphone.6.h | `भुगतान बस [एक बार]।` | Payment just [one time]. | भुगतान is the word Indian payment apps put on every pay screen; the chip sits on एक बार (once). 17 of 18. |
| C.iphone.6.s | `एक ख़रीद में तीनों। न अकाउंट, न सब्सक्रिप्शन।` | In one purchase all three. No account, no subscription. | The site's own "न…, न…" pattern ("न विज्ञापन, न ट्रैकिंग, न सब्सक्रिप्शन"); अकाउंट as in the listing's description. |
| C.mac.1.k | `एक बार लिखें, सबको भेजें।` | One time write, to all send. | The "एक बार…, सबको…" rhythm of a Hindi slogan. |
| C.mac.1.h (built) | `[अंकित] जी, आपका [प्रीमियम] प्लान [मंगलवार] से शुरू है।` | [Ankit] ji, your [Premium] plan from [Tuesday] starts. | Built from mac_reply; the word प्लान after the chip ties it to the form's प्लान field beside it. |
| C.mac.1.s | `{cmd} से जवाब चुनें, फिर छोटे फ़ॉर्म में खाली जगहें भरें।` | With ⌘⇧V (the) reply choose, then in (a) small form (the) blanks fill. | `खाली जगहें भरें` is how the app says "fill the blank"; the form's पेस्ट button beside it shows the paste comes after. One line, where the first draft split the term `खाली / जगहें`. |
| C.mac.2.k | `जहाँ भी टाइप कर रहे हों,` | Wherever (you) may be typing, | Subjunctive `हों` with आप implied; the comma leads into the keys. |
| C.mac.2.h | `{cmd}` | ⌘⇧V | Exactly as the brief fixes it. |
| C.mac.2.s | `आपके कटलिंग और हाल में कॉपी की चीज़ें, हर ऐप के ऊपर।` | Your cutlings and recently copied things, over every app. | Says "the things you copied lately" rather than the feature name; one line, where the full verb broke `के / ऊपर`. |
| C.mac.3.k | `आपका क्लिपबोर्ड इतिहास छोड़ देता है:` | Your clipboard history leaves out: | Hindi puts the object before the verb, so the colon lets the dots below read as what is left out; `क्लिपबोर्ड इतिहास` is the app's term. |
| C.mac.3.s | `पासवर्ड मैनेजर का छिपाया कुछ भी इतिहास में नहीं आता।` | Password manager's hidden anything into history not comes. | `का छिपाया` is "hidden by"; `कुछ भी… नहीं` (nothing at all) carries both "anything" and "never". One line, where the first draft left `आता।` alone. |
| C.mac.4.k | `अपने Mac पर जो भी बदलें,` | On your own Mac whatever (you) change, | Relative clause that the headline's वह answers; reflexive अपने because you are the subject. |
| C.mac.4.h | `वह आपके [iPhone] पर भी बदल जाता है।` | It on your [iPhone] also changes. | Chip on iPhone; आपके, not अपने, because the subject here is "it". |
| C.mac.4.s | `आपके अपने iCloud से सिंक होता है, बिना अकाउंट बनाए।` | Through your own iCloud (it) syncs, without account making. | `आपके अपने iCloud` as the app says it; one line, where `कोई अकाउंट बनाए बिना` left `बिना।` alone. |
| C.mac.5.k | `iPhone, iPad और Mac पर चलता है।` | On iPhone, iPad and Mac (it) runs. | Same words as iPhone 6. |
| C.mac.5.h | `भुगतान बस [एक बार]।` | Payment just [one time]. | Same words as iPhone 6. |
| C.mac.5.s | `एक ख़रीद में तीनों। न अकाउंट, न सब्सक्रिप्शन।` | In one purchase all three. No account, no subscription. | Same words as iPhone 6. |
