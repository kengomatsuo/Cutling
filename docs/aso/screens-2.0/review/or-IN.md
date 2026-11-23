# Odia (or-IN): words for the 2.0 store frames, direction C (card ASG167)

Written from `C-words-brief.md` and the `or-IN` entry of `locale-facts.json`, with no source sentence. The words file is
`fastlane/compose/creative/v2/words/or-IN.json`.

**Register:** ଆପଣ, the polite "you", with the polite imperative in -ନ୍ତୁ, in every line that speaks to the buyer. The app's
Odia strings (ବାତିଲ୍ କରନ୍ତୁ, ଚେଷ୍ଟା କରନ୍ତୁ), the live Odia listing and Apple's own Odia App Store pages (ଆପଣ ମଧ୍ଯ
ପସନ୍ଦ କରିପାରନ୍ତି) all speak this way. The shop owner's replies use the first-person plural (ପଠାଇଦେବୁ, "we'll send")
and no second-person form; the delivery note says ଆପଣଙ୍କ ("your", polite).

**Facts used as given:** ମଙ୍ଗଳବାର, 23 ନଭେମ୍ବର 2026, 5,000, 100, and the product words
କଟ୍‌ଲିଂ and କଟ୍‌ଲିଂଗୁଡ଼ିକ with their zero-width non-joiner. The app's name on an Odia home screen
(`CFBundleDisplayName`) is also କଟ୍‌ଲିଂ, so the frames call the app that, as its own screens under the words do.

**Punctuation:** the Odia full stop । ends sentences, commas are Latin, and nothing uses a dash. Kickers and the
headlines that are not a message carry no full stop.

**Lengths:** every string is inside the brief's limits even counted in code points, which run about 1.6 times the
letters an Odia reader sees (the iPhone reply is 32 code points, 20 letters).

## Demo data (`cseed`)

| Key | Odia | Literal back-translation | Choice |
|---|---|---|---|
| names | ଲିପ୍ସା · ଶୁଭମ · ଇତିଶ୍ରୀ | Lipsa · Subham · Itishree | Common Odia first names, two women (first and third) and a man; ଲିପ୍ସା is the customer of frame 1, ଶୁଭମ of frame 2. A bare name needs no vocative ending in Odia. |
| mac_name | ସମ୍ବିତ | Sambit | An Odia man's name, so the Mac's customer is a fourth person. |
| reply | {name}, ଅର୍ଡର {date} ପଠାଇଦେବୁ। | {name}, [the] order {date} [we] will send off [for you]. | The shop speaks in the first-person plural ପଠାଇଦେବୁ, whose -ଦେ- adds "for you". The app's ମଙ୍ଗଳବାର stands bare: a weekday is an ordinary Odia time adverb (ସୋମବାର ଆସିବି, "I'll come Monday"), so no -ରେ is glued to the chip. Leaving out ଆପଣଙ୍କ ("your"; in a chat the order is plainly theirs) and ଦିନ ("on the day") took the iPhone headline from six lines to three. |
| reply_name | ଅର୍ଡର ଖବର | Order news | What a shop owner would title it: ଖବର (news) is the everyday Odia word for an update. |
| mac_reply | {name}, {plan} ପ୍ୟାକ {date} ପଠାଇଦେବୁ। | {name}, {plan} pack {date} [we] will send off. | Same voice as the iPhone reply. A pack is the tier Indian shops sell and the thing that is sent. |
| name_label | ନାମ | Name | The app's own word for Name. |
| plan_label | ପ୍ୟାକ | Pack | The tier word for goods in Indian shops (combo pack, premium pack). The app's ପ୍ଲାନ means a subscription plan, and a plan is not sent. |
| plan_choices | ବେସିକ · ପ୍ରିମିୟମ | Basic · Premium | English loans in Odia script, as Indian packs and plans are named. |
| delivered | ଆପଣଙ୍କ ପାର୍ସଲ {date} ଦିନ ପହଞ୍ଚିଲା। | Your parcel {date} [on the] day arrived. | ଦିନ after a full date is ordinary Odia ("15 ଅଗଷ୍ଟ ଦିନ") and keeps a -ରେ ending off the green date chip. The polite ଆପଣଙ୍କ ("your") stays because the note tells the customer it is their parcel. |
| delivered_name | ଡେଲିଭରି ଖବର | Delivery news | Titled like the order note, with ଡେଲିଭରି, the loan Indian online shops use. |

## Frame words (`C`)

| Key | Odia | Literal back-translation | Choice |
|---|---|---|---|
| iphone 1 k | ଥରେ ହିଁ ଲେଖିଥିବା ଉତ୍ତର | A reply written just once | A noun phrase naming the sentence below it; ହିଁ is the "only, just" particle. |
| iphone 1 s | ସେଭ୍ ଉତ୍ତରଟି ଟ୍ୟାପ୍ କଲେ କଟ୍‌ଲିଂ ନାମ ପଚାରେ। | [If you] tap the saved reply, Cutling asks [the] name. | ସେଭ୍ ଉତ୍ତର is the live listing's own subtitle phrase; the -ଲେ form ("when, if") is how Odia says tapping X makes Y happen. |
| iphone 2 k | ସେହି ଉତ୍ତର ପୁଣି, ଆଉ ଜଣେ ଗ୍ରାହକଙ୍କୁ | That same reply again, to one more customer | Pairs with frame 1's kicker; ଗ୍ରାହକଙ୍କୁ carries the honorific ending Odia gives a customer. |
| iphone 2 s | ଆଗରୁ ଦେଇଥିବା ନାମ କୀବୋର୍ଡରେ ଥାଏ, ଗୋଟିଏ ଟ୍ୟାପ୍‌ରେ ବାଛନ୍ତୁ। | Names given before stay on the keyboard; choose with one tap. | ନାମ ଦେବା (give a name) is how Odia forms ask for one. Odia does not say keys are "waiting", so they stay (ଥାଏ). |
| iphone 3 k | ତାରିଖ କଟ୍‌ଲିଂ ନିଜେ ଲେଖିଦିଏ | Cutling writes the date in by itself | ଲେଖିଦିଏ has the same -ଦେ- helper verb ("for you") as the reply. |
| iphone 3 s | ଆଜି, ଆସନ୍ତାକାଲି ବା ସପ୍ତାହେ ପରର ତାରିଖ, ପେଷ୍ଟ କରିବା ଦିନ ହିସାବରେ ଠିକ୍ ଆସେ। | Today's, tomorrow's or a week later's date comes out right by the day of pasting. | ଆସନ୍ତାକାଲି is the app's word for Tomorrow (bare କାଲି means yesterday or tomorrow); ସପ୍ତାହେ ପରେ is how Odia news says "a week later" (Kalinga TV, Kanak News); one genitive -ର on the last item covers all three. |
| iphone 4 k | ଆଉ ଆପଣଙ୍କର ଯାହା କେବେ ବଦଳେ ନାହିଁ | And what of yours never changes | The polite possessive sits once in the kicker, so the three chips stay the bare names of the things. |
| iphone 4 h | [ଆକାଉଣ୍ଟ ନମ୍ବର], [ଘର ଠିକଣା] ଓ [ସ୍ୱାକ୍ଷର] | [Account number], [home address] and [signature] | The app's own seed words (ଘର ଠିକଣା, ଇମେଲ ସ୍ୱାକ୍ଷର, shown in the Try It capture under this frame), cut to what is typed; ସ୍ୱାକ୍ଷର is the sign-off. ଓ (and) before the last item, as an Odia list has it. |
| iphone 4 s | ଯେକୌଣସି ଆପରେ, କଟ୍‌ଲିଂ କୀବୋର୍ଡରୁ ଗୋଟିଏ ଟ୍ୟାପ୍‌ରେ ଟାଇପ୍ ହୁଏ। | In any app, [it] gets typed with one tap from the Cutling keyboard. | Intransitive ଟାଇପ୍ ହୁଏ (gets typed) makes each of the three the subject. |
| iphone 5 k | ସବୁ ପାଇଁ ଜାଗା ଅଛି | There is room for everything | ଜାଗା is the app's word for room ("Room for %@" is "%@ ପାଇଁ ଜାଗା"). |
| iphone 5 h | [5,000] କଟ୍‌ଲିଂ | [5,000] cutlings | Odia drops the plural ending after a number: the app's own count string is "%lld କଟ୍‌ଲିଂ", so କଟ୍‌ଲିଂଗୁଡ଼ିକ would read wrong here. |
| iphone 5 s | ଆଗରୁ 100 ଥିଲା, ଆଉ ପ୍ରତ୍ୟେକଟିରେ ଗୋଟିଏ ପୂରା ଇମେଲ ରଖିହେବ। | It was 100 before, and a whole email can be kept in each one. | ରଖିହେବ (can be kept), the release notes' verb. ଅଣ୍ଟିବ means "will suffice" (enough rice, enough money), not "fits". |
| iphone 6 k | iPhone, iPad ଓ Macରେ | On iPhone, iPad and Mac | One case ending on the last name covers all three, and it is glued to the Latin word as Odia news writes it ("Netflix-Amazon Primeର", KNews Odisha). |
| iphone 6 h | [ଥରେ] କିଣିଲେ ହେଲା | Buy [once] and that's it | X-ଲେ ହେଲା ("doing X is enough") says one payment and no more in the buyer's own idiom; the chip is on ଥରେ (once). |
| iphone 6 s | ତିନୋଟିଯାକ ପାଇଁ ଗୋଟିଏ ଦାମ, ଖାତା କି ସବସ୍କ୍ରିପସନ ନାହିଁ। | One price for all three; no account or subscription. | ସବସ୍କ୍ରିପସନ is how Apple's Odia App Store pages, PhonePe and ETV Bharat Odisha spell it; ଖାତା is the app's word for the account it does not have, kept apart from frame 4's bank ଆକାଉଣ୍ଟ. ତିନୋଟିଯାକ (all three) is in Odisha school department papers and Sambad. |
| mac 1 k | ଥରେ ଲେଖନ୍ତୁ, ସମସ୍ତଙ୍କୁ ପଠାନ୍ତୁ | Write once, send to everyone | Two polite imperatives in -ନ୍ତୁ, the app's own button form (ବାତିଲ୍ କରନ୍ତୁ). |
| mac 1 s | {cmd} ଚାପି ଉତ୍ତର ବାଛନ୍ତୁ, ପେଷ୍ଟ ହେବା ଆଗରୁ ଛୋଟ ଫର୍ମଟିଏ ଖାଲି ସ୍ଥାନ ଭରିବାକୁ କହେ। | Press ⌘⇧V and choose the reply; before it pastes, a small form asks you to fill the blanks. | ଚାପି (pressing), as the app writes "⌘⇧V ଚାପନ୍ତୁ"; ଖାଲି ସ୍ଥାନ is the app's word for a blank (ଖାଲି ସ୍ଥାନ ଓ ତାରିଖ, Blanks and Dates). |
| mac 2 k | ଯେଉଁଠି ବି ଟାଇପ୍ କରୁଥାଆନ୍ତୁ | Wherever you may be typing | The concessive of ଆପଣ ଯେଉଁଠି ବି ଥାଆନ୍ତୁ ("wherever you may be"). |
| mac 2 h | {cmd} | ⌘⇧V | As the brief fixes it. |
| mac 2 s | ଆପଣଙ୍କ କଟ୍‌ଲିଂଗୁଡ଼ିକ ଓ ଏବେ ଏବେ କପି କରିଥିବା ଜିନିଷ ଯେକୌଣସି ଆପ ଉପରେ ଖୋଲିଯାଏ। | Your cutlings and the things you just copied open up over any app. | The plural product word, since no number stands before it; ଏବେ ଏବେ (just now) for the last copies. |
| mac 3 k | କ୍ଲିପବୋର୍ଡ ଇତିହାସ ସବୁ ରଖେ, କେବଳ ଏହାକୁ ଛାଡ଼ି | Clipboard history keeps everything, leaving out only this | Odia puts the object before its verb, so the dots under the line cannot be the sentence's last word; ଏହାକୁ (this) points down at them. କ୍ଲିପବୋର୍ଡ ଇତିହାସ is the app's name for the feature. |
| mac 3 s | ପାସୱାର୍ଡ ମ୍ୟାନେଜର ଗୋପନ ବୋଲି ଚିହ୍ନିତ କରିଥିବା କିଛି ବି ଇତିହାସକୁ ଆସେ ନାହିଁ। | Nothing a password manager has marked as secret comes into the history. | ପାସୱାର୍ଡ ମ୍ୟାନେଜର spelled as the app does; କିଛି ବି ... ନାହିଁ is "nothing at all". |
| mac 4 k | Macରେ ଯାହା ବଦଳାଇବେ | Whatever you change on the Mac | Opens a ଯାହା ... sentence that the headline closes. |
| mac 4 h | [iPhone]ରେ ବି ବଦଳିଯିବ | will change on the [iPhone] too | The chip is the device name with its case ending glued on, as in frame 6's kicker. |
| mac 4 s | ଆପଣଙ୍କ ନିଜ iCloud ଦେଇ ସିଙ୍କ ହୁଏ, କୌଣସି ଖାତା ଦରକାର ନାହିଁ। | It syncs through your own iCloud; no account is needed. | ଦେଇ (through) over the bookish ମାଧ୍ୟମରେ; ସିଙ୍କ spelled as the app's "iCloud ସିଙ୍କ". |
| mac 5 k | iPhone, iPad ଓ Macରେ | On iPhone, iPad and Mac | Same words as iPhone 6. |
| mac 5 h | [ଥରେ] କିଣିଲେ ହେଲା | Buy [once] and that's it | Same words as iPhone 6. |
| mac 5 s | ତିନୋଟିଯାକ ପାଇଁ ଗୋଟିଏ ଦାମ, ଖାତା କି ସବସ୍କ୍ରିପସନ ନାହିଁ। | One price for all three; no account or subscription. | Same words as iPhone 6. |

## Headlines the build makes

| Frame | Odia | Literal back-translation |
|---|---|---|
| iphone 1 | [ଲିପ୍ସା], ଅର୍ଡର [ମଙ୍ଗଳବାର] ପଠାଇଦେବୁ। | [Lipsa], [the] order [Tuesday] [we] will send off. |
| iphone 2 | [ଶୁଭମ], ଅର୍ଡର [ମଙ୍ଗଳବାର] ପଠାଇଦେବୁ। | [Subham], [the] order [Tuesday] [we] will send off. |
| iphone 3 | ଆପଣଙ୍କ ପାର୍ସଲ [23 ନଭେମ୍ବର 2026] ଦିନ ପହଞ୍ଚିଲା। | Your parcel arrived on [23 November 2026]. |
| mac 1 | [ସମ୍ବିତ], [ପ୍ରିମିୟମ] ପ୍ୟାକ [ମଙ୍ଗଳବାର] ପଠାଇଦେବୁ। | [Sambit], [the] [Premium] pack [Tuesday] [we] will send off. |
| keyboard bar, iphone 1 and 2 | ନାମ (blank), ଅର୍ଡର ମଙ୍ଗଳବାର ପଠାଇଦେବୁ। | Name (blank), [the] order Tuesday [we] will send off. |

## Fit, and one change to the build

Rendered with `python3 build.py or-IN C` on iPhone, iPad and Mac, and every frame looked at. At New York's headline
line-height (1.14) Odia's marks below the letter hung out of their chips in dark green on the black ground (the
subjoined ସ of ଲିପ୍ସା, the u-sign of ଶୁଭମ, the subjoined ଟ of ଆକାଉଣ୍ଟ) and met the reph of the line below. `build.py` now gives or-IN headlines a
line-height of 1.34 and each chip .18em of green below its letters (`DEEP_MARKS`); every chip on the 17 frames holds
its marks, and no other language's CSS changed. The iPhone headlines of frames 1 and 2 read in three lines, and the
fill-in bar's sentence fits its one line with room to spare.

## Not in these words, seen on the rendered frames

The iPhone and iPad grid captures under frames 5 and 6 (`02_MainGrid`, taken 2026-10-01) show the bank account as
"IBAN: DE89 3704 00…". The app's or-IN seed has since become "IFSC: SBIN0001234 / A/c: 1234 5678 9012"
(`Cutling/or-IN.lproj/Localizable.strings` line 280), which the Try It capture on frame 4 and the Mac picker already
show, so an Odia buyer sees a German IBAN only on those two grids until `02_MainGrid` is captured again.
