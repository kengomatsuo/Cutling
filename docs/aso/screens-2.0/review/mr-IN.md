# mr-IN (Marathi, India): Cutling 2.0 store frames, direction C (card ASG167)

Written blind from `C-words-brief.md` and the `mr-IN` entry of `locale-facts.json`; the words file is
`fastlane/compose/creative/v2/words/mr-IN.json`. Register: तुम्ही (the polite plural "you") with -ा imperatives (लिहा,
पाठवा, निवडा), the form the Marathi listing, the app and the Marathi 2.0 In-App Event text already use, kept in every
line. Marathi ends a sentence with the full stop, not the Hindi danda; digits are Latin as the facts give them; Apple's
product names stay in Latin with the Marathi postposition after a space (Mac साठी), as the app writes them. Square
brackets mark the green chips. Lengths are counted in Unicode code points, which is stricter than visible letters for
Devanagari.

Rendered at store size with the repo's C build on 2026-11-23: nothing clipped on iPhone, iPad or Mac. While fitting,
the chip on the next line hid the ु of तुमची and तुमचे; direction C now paints every chip's green under all letters
(`directions/C.py`, landed in d92e290a). In a test, Hindi frames 1, 2 and 4 came out pixel-identical, and Finnish
frame 4 changed only where the chip below had hidden the tail of a "j". Several sublines and two seed sentences carry no-break spaces so a
phrase never splits across lines; the Choice column says where.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| cseed.names[0] | सायली | Sayali (woman's name) | A distinctly Marathi girl's name, short; frame 1's customer. |
| cseed.names[1] | ओंकार | Omkar (man's name) | A common Maharashtrian man's name; frame 2's customer. |
| cseed.names[2] | गौरी | Gauri (woman's name) | A common Marathi woman's name; the third key on the keyboard. |
| cseed.mac_name | अमेय | Amey (man's name) | A Marathi man's name; the filled Mac reply comes to 51 of 52 with it. |
| cseed.reply | {name}, तुमची ऑर्डर {date} सकाळी निघेल. | {name}, your order {date} morning will-set-out. | The app types the bare weekday मंगळवार, and "on Tuesday" would need the ending मंगळवारी; "मंगळवार सकाळी" (Tuesday morning) is everyday Marathi that keeps the weekday bare. निघेल is how a parcel leaving is said; ऑर्डर is feminine, hence तुमची. 39 of 40 filled; a no-break space keeps "सकाळी निघेल." together so the iPad headline never ends on a lone verb. |
| cseed.reply_name | ऑर्डर अपडेट | Order update | The loanword pair Indian shop owners use for this kind of message; 11 of 16. |
| cseed.mac_reply | {name}, तुमचा {plan} प्लॅन {date} सकाळी सुरू होईल. | {name}, your {plan} plan {date} morning will-start. | The same weekday construction; प्लॅन is masculine (तुमचा) and the plan's name goes before it, as in "प्रीमियम प्लॅन". 51 of 52 filled. |
| cseed.name_label | नाव | Name | The app's own word for Name. |
| cseed.plan_label | प्लॅन | Plan | The app's own word for the Plan blank, and what Indian buyers call a tier they pay for. |
| cseed.plan_choices[0] | बेसिक | Basic | The pair the Marathi 2.0 In-App Event text already uses ("बेसिक किंवा प्रीमियम प्लॅन"). |
| cseed.plan_choices[1] | प्रीमियम | Premium | The loanword Indian services use for the top tier; 8 of 8. |
| cseed.delivered | तुमचे पार्सल {date} रोजी पोहोचले. | Your parcel {date} on reached. | रोजी is the standard Marathi word after a full date ("15 ऑगस्ट, 1947 रोजी") and leaves the date as the app writes it; पार्सल is neuter, hence तुमचे and पोहोचले. 27 of 28 without the date; a no-break space keeps "रोजी पोहोचले." together. |
| cseed.delivered_name | डिलिव्हरी | Delivery | The word Indian shoppers use for it; 9 of 16. |
| iphone 1 h (built) | [सायली], तुमची ऑर्डर [मंगळवार] सकाळी निघेल. | [Sayali], your order [Tuesday] morning will-set-out. | Built from cseed.reply; 39 of 40. |
| iphone 2 h (built) | [ओंकार], तुमची ऑर्डर [मंगळवार] सकाळी निघेल. | [Omkar], your order [Tuesday] morning will-set-out. | Built from cseed.reply; 39 of 40. |
| iphone 3 h (built) | तुमचे पार्सल [23 नोव्हेंबर, 2026] रोजी पोहोचले. | Your parcel [23 November, 2026] on reached. | Built from cseed.delivered. |
| mac 1 h (built) | [अमेय], तुमचा [प्रीमियम] प्लॅन [मंगळवार] सकाळी सुरू होईल. | [Amey], your [Premium] plan [Tuesday] morning will-start. | Built from cseed.mac_reply; 51 of 52. |
| C.iphone.1.k | एकदाच लिहिलेले उत्तर | Only-once written reply | A label for the reply under it; एकदाच is "just once", उत्तर the reply word of the Marathi event text; 20 of 24. |
| C.iphone.1.s | जतन केलेल्या उत्तरावर टॅप करताच कटलिंग नाव विचारते. | The-moment (you) tap on-the saved reply, Cutling asks the-name. | जतन is the app's word for Save; करताच carries "as soon as"; 51 of 60. |
| C.iphone.2.k | तेच उत्तर, पुढच्या ग्राहकाला | The-same reply, to-the-next customer | Verbless, so it pairs with frame 1's label; the new name in the headline shows who the next customer is. |
| C.iphone.2.s | आधी वापरलेली नावे कीबोर्डवर तयार असतात, एकच टॅप पुरतो. | Before used names are ready on-the-keyboard, a-single tap suffices. | पुरतो (suffices) agrees with the masculine टॅप; no-break spaces keep "एकच टॅप पुरतो." on its own line on iPhone. |
| C.iphone.3.k | कटलिंग तारीख स्वतः लिहिते | Cutling the-date itself writes | लिहिते is the app's verb for what its keyboard types ("कटलिंगने लिहिले"). |
| C.iphone.3.s | आजची, उद्याची किंवा आठवड्यानंतरची तारीख, पेस्ट कराल त्या दिवशी बरोबर येते. | Today's, tomorrow's or a-week-later date, on-the day (you) will-paste, comes-out right. | The three options mirror the app's आज, उद्या and एका आठवड्यानंतर; no-break spaces put the line break after "तारीख," on iPhone and iPad. |
| C.iphone.4.k | आणि तुमचे कधीच न बदलणारे तपशील: | And your never not-changing details: | Leads into the list as one sentence; the possessive stands once here, as Marathi does, rather than on each chip; 31 of 34. |
| C.iphone.4.h | [बँक खाते], [घरचा पत्ता], [स्वाक्षरी] | [bank account], [home's address], [signature] | The names the app's own sample cutlings carry (बँक खाते, घरचा पत्ता, ईमेल स्वाक्षरी), which the keyboard capture under the words shows; स्वाक्षरी is the sign-off; 31 of 50. |
| C.iphone.4.s | कोणत्याही अ‍ॅपमध्ये, कटलिंग कीबोर्डवर प्रत्येकी एक टॅप. | In any app, on-the Cutling keyboard one tap each. | प्रत्येकी is "apiece"; अ‍ॅप is spelled with the joiner exactly as the app spells it; 54 of 60. |
| C.iphone.5.k | सगळ्यासाठी भरपूर जागा | For-everything plenty-of room | जागा as in the app's own "Room for %@" (%@ साठी जागा). |
| C.iphone.5.h | [5,000] कटलिंग | [5,000] cutlings | The app writes कटलिंग unchanged for one and many. |
| C.iphone.5.s | पूर्वी मर्यादा 100 होती, आणि प्रत्येकात एक पूर्ण ईमेल मावतो. | Earlier the-limit 100 was, and in-each-one a whole email fits. | मर्यादा (limit, feminine, so होती) says what 100 was; ईमेल is masculine, so मावतो; no-break spaces carry the second clause to its own line on iPhone. |
| C.iphone.6.k | iPhone, iPad आणि Mac साठी | For iPhone, iPad and Mac | Leads into the headline: "for all three, money just once". |
| C.iphone.6.h | पैसे फक्त [एकदाच] | Money only [just-once] | "फक्त एकदाच" is the everyday "only once"; the chip is on एकदाच; 15 of 18. |
| C.iphone.6.s | एकाच खरेदीत तिन्ही; खाते नाही, सबस्क्रिप्शन नाही. | In-a-single purchase all-three; account none, subscription none. | Two short "…नाही" beats, the rhythm the Marathi listing already uses ("जाहिराती नाहीत. ट्रॅकिंग नाही."); सबस्क्रिप्शन is the word the Marathi site's FAQ uses; no-break spaces keep the two beats together. |
| C.mac.1.k | एकदा लिहा, सगळ्यांना पाठवा | Once write, to-everyone send | Two polite imperatives joined by a comma. |
| C.mac.1.s | {cmd} दाबून उत्तर निवडा; पेस्ट करण्याआधी छोटा फॉर्म रिकाम्या जागा भरायला सांगतो. | {cmd} pressing the-reply choose; before pasting a-short form the-blank spaces to-fill tells. | दाबून (by pressing) is how Marathi instructions name a key combination; रिकाम्या जागा is the app's own word for blanks. |
| C.mac.2.k | तुम्ही कुठेही लिहीत असा | You wherever writing be | The idiom "तुम्ही कुठेही असा" (wherever you are), with लिहीत (writing). |
| C.mac.2.h | {cmd} | (the keys ⌘ ⇧ V) | As given. |
| C.mac.2.s | कोणत्याही अ‍ॅपवर तुमचे कटलिंग आणि अलीकडे कॉपी केलेले उघडतात. | Over any app your cutlings and recently copied (things) open. | "कॉपी केलेले" (what was copied) as the app writes it; the place comes first so the two subjects read as one list; no-break spaces keep the second subject on one line. |
| C.mac.3.k | Mac चा क्लिपबोर्ड इतिहास वगळतो: | The-Mac's clipboard history skips: | The password dots under it are the object of वगळतो, the verb the Marathi listing uses for this ("…पासवर्ड वगळतो"). |
| C.mac.3.s | पासवर्ड मॅनेजरने लपवलेले काहीही इतिहासात कधीच येत नाही. | By-a-password-manager hidden anything into-the-history never comes. | "पासवर्ड मॅनेजरने लपवलेले" is the app's own phrase in its History setting; no-break spaces keep the predicate on one line. |
| C.mac.4.k | तुमच्या Mac वर काही बदलले की | Your Mac on something changed as-soon-as | "…ले की" is the everyday "as soon as" clause; it leads into the headline. |
| C.mac.4.h | ते [iPhone] वरही बदलते. | It [iPhone] on-too changes. | The chip is on iPhone; वरही (on … too) follows after a space as Marathi writes it after a Latin name, held to the chip by a no-break space. |
| C.mac.4.s | तुमच्या स्वतःच्या iCloud मधून सिंक होते, खाते लागत नाही. | Through your own iCloud (it) syncs, an-account is-not-needed. | The app's own onboarding words ("स्वतःच्या iCloud मधून सिंक", "खाते … लागत नाही"). |
| C.mac.5.k | iPhone, iPad आणि Mac साठी | For iPhone, iPad and Mac | Same as iPhone 6. |
| C.mac.5.h | पैसे फक्त [एकदाच] | Money only [just-once] | Same as iPhone 6. |
| C.mac.5.s | एकाच खरेदीत तिन्ही; खाते नाही, सबस्क्रिप्शन नाही. | In-a-single purchase all-three; account none, subscription none. | Same as iPhone 6. |
