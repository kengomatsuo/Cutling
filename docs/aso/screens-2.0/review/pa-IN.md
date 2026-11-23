# pa-IN: words for the 2.0 store frames, review

Written from `C-words-brief.md` and the pa-IN facts, into `fastlane/compose/creative/v2/words/pa-IN.json`. Every line
speaks to the buyer as ਤੁਸੀਂ (ਤੁਹਾਡਾ, ਤੁਹਾਡੇ) with the polite imperative in -ੋ (ਲਿਖੋ, ਚੁਣੋ, ਭਰੋ), which is how Cutling's
Punjabi app strings, its Punjabi store listing and its Punjabi site already talk to people. Sentences end with the danda
(।), with no space before it. The short postpositions ’ਤੇ (for ਉੱਤੇ) and ’ਚ (for ਵਿੱਚ) take a curly apostrophe: the app's
strings type a straight one, which looks like a typewriter mark in the frames' large serif. Nukta spellings follow the
app (ਤਾਰੀਖ਼, ਦਸਤਖ਼ਤ, ਹਫ਼ਤੇ, ਫ਼ਾਰਮ, ਸ਼ੁਰੂ), and so do the words it writes without one (ਖਰੀਦ, ਖਾਲੀ, ਖਾਤਾ). The file is NFC, with
the nukta as its own code point (U+0A3C), the same encoding as the app's strings.

iPhone, iPad, Mac and iCloud stay in Latin letters. The app's name is written `Cutling`, as in the store name ("Cutling -
ਕਲਿੱਪਬੋਰਡ ਕੀਬੋਰਡ") and the release notes ("Cutling ਕੀਬੋਰਡ"), and the product word is ਕਟਲਿੰਗ, which the facts give for one
and for many. Punjabi verbs agree in gender, so when Cutling does something the subject is either its keyboard (ਕੀਬੋਰਡ,
masculine) or the app as the Punjabi site treats it (feminine, ਚੱਲਦੀ). ਖਾਤਾ is the app's word for both kinds of account:
frame 4 says ਖਾਤਾ ਨੰਬਰ, which only a bank account has, and frame 6 and Mac 4 say ਨਾ ਖਾਤਾ and ਖਾਤਾ ਬਣਾਏ, which only a
sign-up has, so each use carries its own meaning. The shop is in Chandigarh, where the pa-IN Try It capture puts the
owner's address (123 ਐਮ.ਜੀ. ਰੋਡ, ਚੰਡੀਗੜ੍ਹ 160001), so the customers carry names common across Punjab today.

Rendered through direction C at App Store sizes (iPhone 1320 x 2868, iPad 2064 x 2752, Mac 2880 x 1800) and measured in
headless Chrome at the frames' own fonts (New York falling back to Gurmukhi Sangam MN in headlines, SF falling back to
Mukta Mahee elsewhere) and widths. No headline shrinks and nothing clips, including the fill-in bar, the name keys and
the Mac form. Every kicker and subline fits on one line, no chip splits, and the frame 1 and 2 headlines break on the
same lines (three on iPhone, two on iPad). The signs that hang below a Gurmukhi letter inside a chip, the ੁ of ਗੁਰਵੀਰ and
the subjoined ਰ of ਪ੍ਰੀਮੀਅਮ, stay inside the green. Every limit in the brief holds when counted in Unicode code points,
which is stricter than counting letters.

One break is a compromise. On iPad, frames 1 and 2 break between ਮੰਗਲਵਾਰ and its postposition ਨੂੰ, which is an ordinary
place for a Punjabi line to break. Each alternative tried was worse: putting ਆਰਡਰ before the day left ਆਰਡਰ alone on an
iPhone line, and a no-break space there would have gone into the seed reply that the keyboard types.

| Key | String | Back-translation | Choice |
|---|---|---|---|
| cseed.names | `ਸਿਮਰਨ`, `ਗੁਰਵੀਰ`, `ਹਰਲੀਨ` | Simran, Gurveer, Harleen | Common first names in Punjab today, two women and a man. ਸਿਮਰਨ and ਗੁਰਵੀਰ set at almost the same width, so frames 1 and 2 break on the same lines; ਹਰਲੀਨ shows only as the third key. |
| cseed.mac_name | `ਕਰਨ` | Karan | Short and common all over Punjab; a second man, so the four names split evenly. |
| cseed.reply | `{name} ਜੀ, {date} ਨੂੰ ਆਰਡਰ ਭੇਜਾਂਗੇ।` | {name} ji, {date} on (the) order (we) will send. | A Punjabi shop calls a customer by first name with ਜੀ, and that is where the warmth sits. ਮੰਗਲਵਾਰ stays as the app writes it and takes ਨੂੰ ("on Tuesday"); the subject ਅਸੀਂ (we) drops, as it does in chat. Day first with the one-word ਭੇਜਾਂਗੇ sets as three whole phrases on iPhone; "ਆਰਡਰ … ਭੇਜ ਦਿਆਂਗੇ" left ਆਰਡਰ alone on a line and split the verb. 35 and 36 of 40 filled. |
| cseed.reply_name | `ਆਰਡਰ ਅੱਪਡੇਟ` | Order update | What an Indian seller calls this message; ਅੱਪਡੇਟ with the addak, as the Punjabi site spells it. |
| cseed.mac_reply | `{name} ਜੀ, ਤੁਹਾਡਾ {plan} ਪਲਾਨ {date} ਤੋਂ ਸ਼ੁਰੂ ਹੈ।` | {name} ji, your {plan} plan from {date} start is. | A plan starts, it is not shipped. The present ਸ਼ੁਰੂ ਹੈ for a fixed start is everyday Punjabi ("starts from Tuesday"), and with ਤੁਹਾਡਾ the Mac headline sets as three phrases; ਸ਼ੁਰੂ ਹੋਵੇਗਾ without it split ਪ੍ਰੀਮੀਅਮ from ਪਲਾਨ. 50 of 52 filled. |
| cseed.name_label | `ਨਾਮ` | Name | The app's own Punjabi label for Name. |
| cseed.plan_label | `ਪਲਾਨ` | Plan | The app's own word (its Variables list shows `ਪਲਾਨ ▾`). |
| cseed.plan_choices | `ਬੇਸਿਕ`, `ਪ੍ਰੀਮੀਅਮ` | Basic, Premium | The pair the Punjabi 2.0 release notes already name ("ਜਿਵੇਂ ਬੇਸਿਕ ਜਾਂ ਪ੍ਰੀਮੀਅਮ ਪਲਾਨ"); ਪ੍ਰੀਮੀਅਮ is exactly 8. |
| cseed.delivered | `{date} ਨੂੰ ਪਾਰਸਲ ਪਹੁੰਚ ਗਿਆ।` | On {date} (the) parcel reached. | Date first, so the green date chip opens the line whole; ਪਹੁੰਚ ਗਿਆ ("has got there") is how a seller confirms a delivery. 21 of 28 without the date. |
| cseed.delivered_name | `ਡਿਲੀਵਰੀ ਸੁਨੇਹਾ` | Delivery message | ਸੁਨੇਹਾ is the everyday Punjabi word for a message; ਡਿਲੀਵਰੀ is what shops say. |
| C.iphone.1.k | `ਜਵਾਬ ਇੱਕੋ ਵਾਰ ਲਿਖੋ।` | Reply just-once write. | Polite imperative; ਇੱਕੋ ਵਾਰ is "just the once". The Punjabi 2.0 release notes open with the same three words, so frame and notes agree. 19 of 24. |
| C.iphone.1.h (built) | `[ਸਿਮਰਨ] ਜੀ, [ਮੰਗਲਵਾਰ] ਨੂੰ ਆਰਡਰ ਭੇਜਾਂਗੇ।` | [Simran] ji, [Tuesday] on (the) order (we) will send. | iPhone: ਸਿਮਰਨ ਜੀ, / ਮੰਗਲਵਾਰ ਨੂੰ / ਆਰਡਰ ਭੇਜਾਂਗੇ। iPad: two lines, breaking before ਨੂੰ (see above). |
| C.iphone.1.s | `ਸੰਭਾਲੇ ਜਵਾਬ ’ਤੇ ਟੈਪ ਕਰੋ, Cutling ਕੀਬੋਰਡ ਨਾਮ ਪੁੱਛੇਗਾ।` | Saved reply on tap, Cutling keyboard (the) name will ask. | ਸੰਭਾਲੇ is the app's word for saved (the Mac picker's tab reads ਸੰਭਾਲੇ ਗਏ). The keyboard is the subject, so the verb is masculine ਪੁੱਛੇਗਾ, as in the release notes' "Cutling ਕੀਬੋਰਡ ਨਾਮ ਪੁੱਛਦਾ ਹੈ". 52 of 60. |
| C.iphone.2.k | `ਉਹੀ ਜਵਾਬ, ਅਗਲੇ ਗਾਹਕ ਨੂੰ ਵੀ।` | Same reply, to (the) next customer too. | Repeats ਜਵਾਬ from frame 1 so the pair reads as one thought; ਵੀ (too) carries "again". |
| C.iphone.2.h (built) | `[ਗੁਰਵੀਰ] ਜੀ, [ਮੰਗਲਵਾਰ] ਨੂੰ ਆਰਡਰ ਭੇਜਾਂਗੇ।` | [Gurveer] ji, [Tuesday] on (the) order (we) will send. | The same line breaks as frame 1 on both devices; only the name chip changes. |
| C.iphone.2.s | `ਪਹਿਲਾਂ ਵਰਤੇ ਨਾਮ ਤਿਆਰ ਮਿਲਦੇ ਹਨ, ਇੱਕ ਟੈਪ ਨਾਲ ਚੁਣੋ।` | Before used names ready are found, with one tap choose. | ਤਿਆਰ ਮਿਲਦੇ ਹਨ ("you find them ready") is the waiting; "ਇੱਕ ਟੈਪ ਨਾਲ … ਚੁਣ" is how the release notes describe the one-tap keys. |
| C.iphone.3.k | `ਤਾਰੀਖ਼ ਆਪਣੇ-ਆਪ ਭਰ ਜਾਂਦੀ ਹੈ।` | (The) date by itself fills in. | ਤਾਰੀਖ਼ is the app's word, and ਆਪਣੇ-ਆਪ takes the hyphen the store description gives it. With the date as subject, the app's gender never comes up. |
| C.iphone.3.h (built) | `[23 ਨਵੰਬਰ 2026] ਨੂੰ ਪਾਰਸਲ ਪਹੁੰਚ ਗਿਆ।` | On [23 November 2026] (the) parcel reached. | Built with the long date; the chip opens line 1 whole on iPhone and iPad. |
| C.iphone.3.s | `ਅੱਜ, ਭਲਕੇ ਜਾਂ ਹਫ਼ਤੇ ਬਾਅਦ, ਪੇਸਟ ਵਾਲੇ ਦਿਨ ਮੁਤਾਬਕ ਸਹੀ।` | Today, tomorrow or (a) week after, by (the) paste day right. | ਭਲਕੇ is the Punjabi word that can only mean tomorrow. ਕੱਲ੍ਹ means both yesterday and tomorrow (which is why the app's label says ਆਉਣ ਵਾਲਾ ਕੱਲ੍ਹ), and "ਅੱਜ, ਕੱਲ੍ਹ" would also read as ਅੱਜ-ਕੱਲ੍ਹ, "these days". ਮੁਤਾਬਕ as in the release notes' "ਉਸ ਦਿਨ ਮੁਤਾਬਕ ਸਹੀ ਤਾਰੀਖ਼". |
| C.iphone.4.k | `ਅਤੇ ਜੋ ਕਦੇ ਨਹੀਂ ਬਦਲਦਾ:` | And what never changes: | Leads into the headline as one sentence. 22 of 34. |
| C.iphone.4.h | `ਤੁਹਾਡਾ [ਖਾਤਾ ਨੰਬਰ], [ਪਤਾ] ਅਤੇ [ਦਸਤਖ਼ਤ]।` | Your [account number], [address] and [signature]. | Punjabi puts one possessive over the list, and all three nouns are masculine, so ਤੁਹਾਡਾ fits each. ਖਾਤਾ ਨੰਬਰ is the word in the store's promotional text; ਪਤਾ and ਦਸਤਖ਼ਤ match the keyboard tiles in the capture below (ਘਰ ਦਾ ਪਤਾ, ਈਮੇਲ ਦਸਤਖ਼ਤ). A no-break space (U+00A0) joins ਅਤੇ to the last chip, so iPad breaks as "… [ਪਤਾ] / ਅਤੇ [ਦਸਤਖ਼ਤ]।" and no chip sits alone on its line; iPhone breaks after the comma. 33 of 50. |
| C.iphone.4.s | `ਹਰੇਕ ਲਈ ਬੱਸ ਇੱਕ ਟੈਪ, ਕਿਸੇ ਵੀ ਐਪ ਵਿੱਚ, Cutling ਕੀਬੋਰਡ ਤੋਂ।` | For each just one tap, in any app, from Cutling keyboard. | Said the way Punjabi gives a price per item. 57 of 60. |
| C.iphone.5.k | `ਹਰ ਚੀਜ਼ ਲਈ ਥਾਂ ਹੈ।` | For every thing room is. | ਥਾਂ is the app's word for room ("ਬਹੁਤ ਜ਼ਿਆਦਾ ਥਾਂ", "%@ ਲਈ ਥਾਂ"). |
| C.iphone.5.h | `[5,000] ਕਟਲਿੰਗ` | [5,000] cutlings | n5000 and the product word exactly as given (ਕਟਲਿੰਗ is the same in the plural); a noun phrase takes no danda. |
| C.iphone.5.s | `ਪਹਿਲਾਂ ਸਿਰਫ਼ 100 ਸਨ, ਅਤੇ ਹਰੇਕ ਵਿੱਚ ਪੂਰੀ ਈਮੇਲ ਆ ਜਾਂਦੀ ਹੈ।` | Before only 100 were, and in each (a) whole email comes in. | n100 as given; ਈਮੇਲ is feminine, as the app writes it (ਮੇਰੀ ਈਮੇਲ). |
| C.iphone.6.k | `iPhone, iPad ਅਤੇ Mac ’ਤੇ ਚੱਲਦੀ ਹੈ।` | On iPhone, iPad and Mac (it) runs. | A whole sentence, with the app as a feminine subject, the way the Punjabi site writes Cutling ("ਮੀਨੂ ਬਾਰ ਵਿੱਚ ਬੈਠੀ ਰਹਿੰਦੀ ਹੈ"). |
| C.iphone.6.h | `[ਇੱਕ ਵਾਰ] ਦਾ ਭੁਗਤਾਨ` | [One time]'s payment | "A one-time payment", with the chip on ਇੱਕ ਵਾਰ (once). ਭੁਗਤਾਨ keeps the headline about paying and leaves ਖਰੀਦ (purchase) to the subline. Breaks as modifier, then noun. 17 of 18. |
| C.iphone.6.s | `ਇੱਕ ਖਰੀਦ ਤਿੰਨਾਂ ਲਈ ਕਾਫ਼ੀ ਹੈ। ਨਾ ਖਾਤਾ, ਨਾ ਸਬਸਕ੍ਰਿਪਸ਼ਨ।` | One purchase for (all) three enough is. No account, no subscription. | ਕਾਫ਼ੀ ਹੈ ("is enough") says one purchase covers all three. "ਨਾ …, ਨਾ …" and the spelling ਸਬਸਕ੍ਰਿਪਸ਼ਨ are the Punjabi site's own ("ਨਾ ਸਬਸਕ੍ਰਿਪਸ਼ਨ, ਨਾ ਐਪ ਦੇ ਅੰਦਰ ਖਰੀਦਾਂ"). |
| C.mac.1.k | `ਇੱਕ ਵਾਰ ਲਿਖੋ, ਸਭ ਨੂੰ ਭੇਜੋ।` | One time write, to all send. | Two matching imperatives, the rhythm of a Punjabi slogan. |
| C.mac.1.h (built) | `[ਕਰਨ] ਜੀ, ਤੁਹਾਡਾ [ਪ੍ਰੀਮੀਅਮ] ਪਲਾਨ [ਮੰਗਲਵਾਰ] ਤੋਂ ਸ਼ੁਰੂ ਹੈ।` | [Karan] ji, your [Premium] plan from [Tuesday] start is. | Sets as ਕਰਨ ਜੀ, ਤੁਹਾਡਾ / ਪ੍ਰੀਮੀਅਮ ਪਲਾਨ / ਮੰਗਲਵਾਰ ਤੋਂ ਸ਼ੁਰੂ ਹੈ। The word ਪਲਾਨ after the chip ties it to the form's ਪਲਾਨ field beside it. |
| C.mac.1.s | `{cmd} ਨਾਲ ਜਵਾਬ ਚੁਣੋ, ਫਿਰ ਛੋਟੇ ਫ਼ਾਰਮ ਵਿੱਚ ਖਾਲੀ ਥਾਵਾਂ ਭਰੋ।` | With ⌘⇧V (the) reply choose, then in (a) small form (the) blanks fill. | ਖਾਲੀ ਥਾਵਾਂ is the app's plural for blanks ("ਭਰਨ ਵਾਲੀਆਂ ਖਾਲੀ ਥਾਵਾਂ"), and ਫ਼ਾਰਮ takes the nukta like the app's ਫ਼ਾਰਮੈਟ. The form's ਪੇਸਟ button beside it shows that the paste comes after. |
| C.mac.2.k | `ਜਿੱਥੇ ਵੀ ਲਿਖ ਰਹੇ ਹੋਵੋ,` | Wherever (you) may be writing, | Subjunctive ਹੋਵੋ with ਤੁਸੀਂ implied; ਲਿਖਣਾ is how the app says type ("ਟੈਪ ਕਰ ਕੇ ਲਿਖੋ"). The comma leads into the keys. |
| C.mac.2.h | `{cmd}` | ⌘⇧V | Exactly as the brief fixes it. |
| C.mac.2.s | `ਤੁਹਾਡੇ ਕਟਲਿੰਗ ਅਤੇ ਹੁਣੇ ਕਾਪੀ ਕੀਤੀਆਂ ਚੀਜ਼ਾਂ, ਹਰ ਐਪ ਦੇ ਉੱਪਰ।` | Your cutlings and just-now copied things, over every app. | "ਹੁਣੇ ਕਾਪੀ ਕੀਤਾ" is the app's own phrase for what you just copied. ਤੁਹਾਡੇ makes ਕਟਲਿੰਗ read as your saved items, not the app, and ਉੱਪਰ (above) fits a picker that opens over the app. ਹਾਲ ਹੀ ਵਿੱਚ ("recently") pushed "ਦੇ ਉੱਪਰ" onto a second line. |
| C.mac.3.k | `ਕਲਿੱਪਬੋਰਡ ਇਤਿਹਾਸ ਇਹ ਛੱਡ ਦਿੰਦਾ ਹੈ:` | Clipboard history this leaves out: | Punjabi puts the object before the verb, so ਇਹ ("this") holds the object's place and the colon hands it to the dots below. ਕਲਿੱਪਬੋਰਡ ਇਤਿਹਾਸ is the app's term. |
| C.mac.3.h (fixed) | `[••••••••••]` | (password dots) | Fixed by the build. |
| C.mac.3.s | `ਪਾਸਵਰਡ ਮੈਨੇਜਰ ਦਾ ਲੁਕਾਇਆ ਕੁਝ ਵੀ ਇਤਿਹਾਸ ’ਚ ਨਹੀਂ ਆਉਂਦਾ।` | Password manager's hidden anything into history not comes. | "ਦਾ ਲੁਕਾਇਆ" is "hidden by", Punjabi's way of giving a participle its agent; "ਕੁਝ ਵੀ … ਨਹੀਂ" ("nothing at all") covers both "anything" and "never". ’ਚ, the everyday short form of ਵਿੱਚ, keeps it on one line. |
| C.mac.4.k | `ਆਪਣੇ Mac ’ਤੇ ਜੋ ਵੀ ਬਦਲੋ,` | On (your) own Mac whatever (you) change, | A relative clause that the headline's ਉਹ answers; reflexive ਆਪਣੇ because you are the subject. |
| C.mac.4.h | `ਉਹ [iPhone] ’ਤੇ ਵੀ ਬਦਲ ਜਾਂਦਾ ਹੈ।` | That on [iPhone] too changes. | Chip on iPhone. ਤੁਹਾਡੇ was dropped because it pushed ’ਤੇ to the start of the next line, away from iPhone; the kicker's ਆਪਣੇ already says whose devices these are. |
| C.mac.4.s | `ਤੁਹਾਡੇ ਆਪਣੇ iCloud ਰਾਹੀਂ ਸਿੰਕ ਹੁੰਦਾ ਹੈ, ਬਿਨਾਂ ਕੋਈ ਖਾਤਾ ਬਣਾਏ।` | Through your own iCloud (it) syncs, without any account making. | "ਤੁਹਾਡੇ ਆਪਣੇ iCloud" as the app says it; "ਬਿਨਾਂ … ਬਣਾਏ" ("without making") is the construction the site uses in "ਬਿਨਾਂ ਆਪਣਾ ਕੰਮ ਛੱਡੇ". 60. |
| C.mac.5.k | `iPhone, iPad ਅਤੇ Mac ’ਤੇ ਚੱਲਦੀ ਹੈ।` | On iPhone, iPad and Mac (it) runs. | Same words as iPhone 6. |
| C.mac.5.h | `[ਇੱਕ ਵਾਰ] ਦਾ ਭੁਗਤਾਨ` | [One time]'s payment | Same words as iPhone 6. |
| C.mac.5.s | `ਇੱਕ ਖਰੀਦ ਤਿੰਨਾਂ ਲਈ ਕਾਫ਼ੀ ਹੈ। ਨਾ ਖਾਤਾ, ਨਾ ਸਬਸਕ੍ਰਿਪਸ਼ਨ।` | One purchase for (all) three enough is. No account, no subscription. | Same words as iPhone 6. |
