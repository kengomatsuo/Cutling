# te-IN (Telugu, India): Cutling 2.0 store frames, direction C (card ASG167)

Written blind from `C-words-brief.md` and the `te-IN` entry of `locale-facts.json`; the words file is
`fastlane/compose/creative/v2/words/te-IN.json`. Register: మీరు with the polite imperative (-ండి), the form the te-IN
store description, promotional text and 2.0 release notes use, as do the Telugu Play listings of PhonePe and Spotify;
it holds in every line. The shop owner's replies speak as "we" (పంపిస్తాం) and call each customer by first name with
గారు, as Telugu shops do. Punctuation is the full stop, comma and colon modern Telugu uses: no dashes, no quotation
marks, no మరియు in lists. The product word is కట్లింగ్ / కట్లింగ్‌లు as the facts give it, and the app is called
కట్లింగ్ too, its Telugu home-screen name. iPhone, iPad, Mac and iCloud stay in Latin letters. Loanwords keep the
app's spellings, with the zero-width non-joiner where the app puts one (కట్లింగ్‌లు, కీబోర్డ్‌లో, అప్‌డేట్,
సబ్‌స్క్రిప్షన్). Lengths are counted in Unicode code points, where one Telugu letter with its vowel sign or conjunct
counts 2 to 4: each reply is exactly 40 with its name, the Mac reply 51, the iPhone 6 headline 18. 13 lines carry
non-breaking spaces (written `\u00a0` in the JSON) so a word such as ఏ, లో or లేదు never sits alone and lines break
at the comma. Square brackets mark the green chips.

| Key | String | Literal back-translation | Choice |
|---|---|---|---|
| `cseed.names[0]` | అనూష | Anusha | A common Telugu woman's name; the frame 1 customer. |
| `cseed.names[1]` | పవన్ | Pavan | A common Telugu man's name; the frame 2 customer. |
| `cseed.names[2]` | మేఘన | Meghana | A Telugu woman's name common among younger buyers; all three are 4 code points, so the reply is the same length whichever name fills it. |
| `cseed.mac_name` | సాయి | Sai | A first name heard all over Andhra Pradesh and Telangana, mostly men's (Sai Kumar, Sai Teja); two women and two men across the four names. |
| `cseed.reply` | {name} గారు, మీ ఆర్డర్ {date} పంపిస్తాం. | {name} garu, your order {date} [we] will send. | గారు after the first name is how a Telugu shop addresses a customer of either gender; the weekday stands bare as a time word (మంగళవారం పంపిస్తాం, "we'll send on Tuesday"), so it takes no ending; పంపిస్తాం is the spoken-standard "we'll send"; 40 code points with each name. |
| `cseed.reply_name` | ఆర్డర్ అప్‌డేట్ | Order update | What Indian sellers call this message, in the loanwords they use; అప్‌డేట్ spelled as Google Play's Telugu pages spell it. |
| `cseed.mac_reply` | {name} గారు, మీ {plan} ప్లాన్ {date} మొదలవుతుంది. | {name} garu, your {plan} plan {date} starts. | A plan starts rather than ships, so మొదలవుతుంది ("begins"); the same bare weekday; 51 code points with సాయి and ప్రీమియం. |
| `cseed.name_label` | పేరు | Name | The app's own word for Name. |
| `cseed.plan_label` | ప్లాన్ | Plan | The app's own word (its Variables list shows ప్లాన్ ▾); PhonePe's Telugu listing uses the same loanword for plans. |
| `cseed.plan_choices[0]` | బేసిక్ | Basic | The loanword pair Indian pricing uses, and the pair the te-IN 2.0 release notes already name (బేసిక్ లేదా ప్రీమియం ప్లాన్). |
| `cseed.plan_choices[1]` | ప్రీమియం | Premium | 8 code points, at the limit. |
| `cseed.delivered` | మీ ఆర్డర్ డెలివరీ అయింది: {date} | Your order delivery happened: {date} | డెలివరీ అయింది is how Telugu speakers say "got delivered", with no passive చేయబడింది; the date follows a colon, the way Telugu notes and forms write a date (తేదీ: …), so it needs no ending such as న; 26 code points without the date. |
| `cseed.delivered_name` | డెలివరీ మెసేజ్ | Delivery message | How a seller names the saved message; మెసేజ్ is their word for a chat message. |
| `C.iphone.1.k` | ఈ జవాబు రాసింది ఒక్కసారే | This reply, [it was] written just once | A cleft with the emphatic ఒక్కసారే last, as it is said aloud; జవాబు is the store page's 2.0 word for a reply; 24 code points, at the limit. |
| `C.iphone.1.s` | సేవ్ చేసిన జవాబు నొక్కగానే, పేరు ఏంటని కట్లింగ్ అడుగుతుంది. | Saved reply the moment [you] press, "the name is what?" Cutling asks. | -గానే ("the moment you…") carries the order of events; పేరు ఏంటని ("what the name is") sits between subject and verb, because కట్లింగ్ పేరు side by side reads "Cutling's name"; nbsp make the line break at the comma; 59 code points. |
| `C.iphone.2.k` | అదే జవాబు, తర్వాతి కస్టమర్‌కు | The same reply, to the next customer | Verbless, to answer frame 1's kicker; అదే is "that very same"; కస్టమర్ is the word shops use and the store's release notes write. |
| `C.iphone.2.s` | ఇంతకుముందు వాడిన పేర్లు కీలుగా సిద్ధం, ఒక్క ట్యాప్ చాలు. | Before-used names as keys ready, one tap enough. | ఇంతకుముందు వాడిన పేర్లు is the release notes' own phrase; సిద్ధం ("ready") for waiting; ఒక్క ట్యాప్ as the te-IN promotional text says it; nbsp keep ఒక్క ట్యాప్ చాలు on one line. |
| `C.iphone.3.k` | తేదీ వేసే పని కట్లింగ్‌దే | The date-putting job is Cutling's | తేదీ వేయు is the Telugu verb for dating a letter or form; saying the job is Cutling's tells the buyer they no longer do it; the suffix joins the product word through a zero-width non-joiner, as the app writes కట్లింగ్‌లో. |
| `C.iphone.3.s` | ఈరోజు, రేపు, వారం తర్వాత: ఏ రోజు అతికించినా తేదీ సరిగ్గా వస్తుంది. | Today, tomorrow, a week later: whatever day [you] paste, the date comes right. | The concessive -ఇనా ("whatever day you paste") is Telugu's own way to say "right on the day it is pasted"; అతికించు is the app's Paste; వారం తర్వాత over the app's ఒక వారంలో, which can also mean "within a week". |
| `C.iphone.4.k` | ఎప్పుడూ మారని మీ వివరాలు కూడా: | Your never-changing details too: | Leads into the list with a colon; one మీ ("your") on the group, as Telugu does with a list, so the chips stay bare. |
| `C.iphone.4.h` | [బ్యాంక్ ఖాతా], [చిరునామా], [సంతకం] | [bank account], [address], [signature] | బ్యాంక్ ఖాతా is the app's own name for this cutling, shown in the capture under it, and keeps frame 6's ఖాతా (a sign-up account) from reading as the same thing; సంతకం is the app's word for an email sign-off; commas only, as the te-IN promotional text lists things. |
| `C.iphone.4.s` | కట్లింగ్ కీబోర్డ్‌లో ఒక్కొక్కటి ఒక్క ట్యాప్, ఏ యాప్‌లోనైనా. | On the Cutling keyboard, each one, one tap, in any app at all. | A sentence without a verb, the usual shape of an ad line; ఏ యాప్‌లోనైనా is the promotional text's phrase; nbsp keep ఏ with its noun. |
| `C.iphone.5.k` | అన్నిటికీ చోటు ఉంది | For everything there is room | A plain statement; చోటు is the release notes' word for room. |
| `C.iphone.5.h` | [5,000] కట్లింగ్‌లు | [5,000] cutlings | n5000 and the plural product word exactly as the facts give them. |
| `C.iphone.5.s` | ఇంతకుముందు 100 వరకే, ఇప్పుడు ఒక్కోదానిలో పూర్తి ఈమెయిల్ పడుతుంది. | Before, only up to 100; now in each one a whole email fits. | Before and now side by side with a comma and no connector; పడుతుంది is the everyday "fits" (as in a bag); ఈమెయిల్ spelled as the app spells it. |
| `C.iphone.6.k` | iPhone, iPad, Mac | iPhone, iPad, Mac | Latin device names, as Apple and the app write them; commas only. |
| `C.iphone.6.h` | చెల్లింపు [ఒక్కసారే] | Payment [just once] | A verbless "the payment: only once", the chip on ఒక్కసారే ("only once"); 18 code points, at the limit (చెల్లించేది ఒక్కసారే, "you pay only once", ran to 20). |
| `C.iphone.6.s` | ఒకే కొనుగోలు మూడింటికీ, ఖాతా అక్కర్లేదు, సబ్‌స్క్రిప్షన్ లేదు. | One purchase for all three, account not needed, subscription none. | ఖాతా is the app's own word for an account (ఖాతా, ఇంటర్నెట్ అవసరం లేదు); అక్కర్లేదు is the friendlier "not needed"; సబ్‌స్క్రిప్షన్ spelled as Spotify's Telugu listing spells it; nbsp keep లేదు with its noun. |
| `C.mac.1.k` | ఒక్కసారి రాయండి, అందరికీ పంపండి | Once write, to everyone send | Two parallel polite imperatives. |
| `C.mac.1.s` | {cmd} నొక్కి జవాబు ఎంచుకుంటే, అతికించే ముందు చిన్న ఫారం ఖాళీలను నింపమంటుంది. | Having pressed ⌘⇧V, if [you] pick the reply, before pasting a small form tells [you] to fill the blanks. | ఖాళీలు is the app's word for blanks (ఖాళీలు, తేదీలు); నింపమంటుంది is "asks you to fill"; no ఒక ("a") before చిన్న ఫారం, since an article on every noun is an English habit; nbsp keep అతికించే ముందు whole. |
| `C.mac.2.k` | మీరు ఎక్కడ టైప్ చేస్తున్నా | Wherever you may be typing | The concessive -ఉన్నా, as Spotify's Telugu listing writes మీరు ఎక్కడ ఉన్నా ("wherever you are"); leads into the keys. |
| `C.mac.2.h` | {cmd} | ⌘⇧V | Fixed by the brief. |
| `C.mac.2.s` | మీ కట్లింగ్‌లు, ఇటీవల కాపీ చేసినవి ఏ యాప్ పైనైనా తెరుచుకుంటాయి. | Your cutlings, what [you] recently copied, on top of any app open. | పైనైనా ("on top of any"); ఇటీవల echoes the app's ఇటీవలి క్లిప్‌బోర్డ్ చరిత్ర. |
| `C.mac.3.k` | క్లిప్‌బోర్డ్ చరిత్ర వదిలేసేది: | What the clipboard history leaves out: | Telugu puts the verb last, so the dots can follow only as the thing left out: a cleft ("what it leaves out:") and a colon; క్లిప్‌బోర్డ్ చరిత్ర is the app's name for the history. |
| `C.mac.3.s` | పాస్‌వర్డ్ మేనేజర్ దాచినవిగా గుర్తించినవి ఏవీ చరిత్రలోకి రావు. | The ones a password manager marked as hidden, none come into the history. | The te-IN store description's own wording for this (దాచినవిగా గుర్తించిన); ఏవీ … రావు is "none of them come". |
| `C.mac.4.k` | మీ Mac లో ఏదైనా మార్చండి, | On your Mac change anything, | An imperative as the condition, leading into the headline; Mac లో with a space, as the app writes it (nbsp, so లో never starts a line). |
| `C.mac.4.h` | [iPhone] లోనూ మారిపోతుంది | On [iPhone] too it gets changed | లోనూ ("on … too") written apart, so the chip holds iPhone alone; మారిపోతుంది carries "changes by itself"; no full stop, like the other headlines that are not replies. |
| `C.mac.4.s` | మీ సొంత iCloud లోనే సింక్ అవుతుంది, కొత్త ఖాతా అక్కర్లేదు. | In your own iCloud itself it syncs, a new account not needed. | లోనే ("within … itself") says the data stays in the buyer's own iCloud; సింక్ is the app's word; nbsp keep కొత్త ఖాతా అక్కర్లేదు on one line. |
| `C.mac.5.k` | iPhone, iPad, Mac | iPhone, iPad, Mac | Same as iPhone 6. |
| `C.mac.5.h` | చెల్లింపు [ఒక్కసారే] | Payment [just once] | Same as iPhone 6. |
| `C.mac.5.s` | ఒకే కొనుగోలు మూడింటికీ, ఖాతా అక్కర్లేదు, సబ్‌స్క్రిప్షన్ లేదు. | One purchase for all three, account not needed, subscription none. | Same as iPhone 6. |

Headlines the build makes from the seed, as they render:

| Frame | Headline | Back-translation |
|---|---|---|
| iPhone/iPad 1 | [అనూష] గారు, మీ ఆర్డర్ [మంగళవారం] పంపిస్తాం. | Anusha garu, we'll send your order on Tuesday. |
| iPhone/iPad 2 | [పవన్] గారు, మీ ఆర్డర్ [మంగళవారం] పంపిస్తాం. | Pavan garu, we'll send your order on Tuesday. |
| iPhone/iPad 3 | మీ ఆర్డర్ డెలివరీ అయింది: [23 నవంబర్ 2026] | Your order was delivered: 23 November 2026 |
| Mac 1 | [సాయి] గారు, మీ [ప్రీమియం] ప్లాన్ [మంగళవారం] మొదలవుతుంది. | Sai garu, your Premium plan starts on Tuesday. |

Rendered at store size with the repo's C build (`python3 build.py te-IN C`) on 2026-11-23, with the Telugu entry in
`build.py`'s `DEEP_MARKS` (headline line height 1.32, chips .2em deeper), which keeps a subjoined letter that hangs
under the baseline, such as the second క of ఒక్కసారే, inside its green. Nothing is clipped on iPhone, iPad or Mac,
and every subline breaks at a comma or between clauses.
