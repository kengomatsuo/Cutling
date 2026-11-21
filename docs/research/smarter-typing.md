# Smarter typing with Apple's on-device ML

Card ASG121. Research only; the decision belongs to the owner. Read and measured 2026-11-21. Every source is saved in `docs/research/smarter-typing/` and listed in `docs/research/smarter-typing/notes.md` (file named per row). "GUESS" marks a value or risk estimate that no source gives. "UNSURE" marks something I could not confirm.

Measurements marked **Mac** were run by me on this Mac (macOS 27, Xcode with the iPhoneOS 27.2 SDK), not on an iPhone: the iPhone keyboard process, its memory and its neural-engine speed are not measured. Output files: `measure_*.txt` in the sources folder. Treat Mac numbers as direction, not as budget.

## Answer in brief

1. Nothing Apple ships lets a keyboard see the host app's field label, its placeholder or the whole message. The keyboard sees `documentContextBeforeInput` / `After` / `selectedText`, plus the field traits (`textContentType`, `keyboardType`, `returnKeyType`). Cutling already reads that text on every change (`CutlingKeyboard/KeyboardViewController.swift`, `refreshWordBeforeCursor`), so reading it for ranking adds no new data access, only a new use.
2. The one language model Apple exposes (Foundation Models) is **not** loaded into the caller's memory, so it is not counted against the 77 MB (Apple DTS, June 2026). But it is slow for a typing surface (about 2 to 2.5 s warm, 16 s the first call on this Mac), supports 24 locales, does not include Indonesian in its list (though it answered an Indonesian prompt correctly in one test), and runs only on Apple Intelligence devices. It fits actions the person taps, not as-you-type.
3. The small models (NaturalLanguage) run in-process and cost memory and time. NLTagger person/place/organisation tagging worked **only for English** in my Mac test. Sentence embeddings loaded only for English and Simplified Chinese on this Mac. Contextual embeddings cover 20 Latin-script languages.
4. The privacy story is the product here. TextExpander's own page says it keeps up to 300 keystrokes in memory when suggestions are on, and the buyers' words (R13, R14, A14) show that a "suggested snippet" that surfaced a password or a bank number cost it customers. Whatever Cutling adds should read only text it is already handed, store none of it, and say so in one line.

## 1. What runs where

### Foundation Models (iOS/macOS 26 and later)

- Availability: iOS, iPadOS, macOS, visionOS 26.0+ (`apple_fm_systemlanguagemodel.json`). Needs an Apple Intelligence device in a supported region; `SystemLanguageModel.default.availability` gives `.available` or `.unavailable(reason)` (WWDC25 286, `wwdc25_286.html`). Devices for iOS 27 (Apple support 121115, published 2026-11-08, `apple_support_121115_apple_intelligence_2026-11-21.md`): iPhone 15 Pro and later, iPhone 16 and later, iPhone Air, iPad M1 and later. Not the iPhone 15, 14 or older, and not devices bought in mainland China.
- Model: about 3 billion parameters, 2-bit (WWDC25 286). Apple updates it in OS releases; three versions exist: 26.0 to 26.3, 26.4, 27.0 (`apple_fm_systemlanguagemodel.json`), so a prompt tuned on one can change behaviour on another.
- Context: documented as 4096 tokens per session (`apple_tn3193.md`). The iOS 27.2 SDK interface returns 4096 before 27 and a runtime value from 27 (`sdk_FoundationModels_iOS27.2.swiftinterface`); on this Mac it reported **8192** (Mac).
- Languages: `supportedLanguages` on this Mac listed da, de, en (AU, GB, IN), es (and es-419, es-US), fr (CA), it, ja, ko, nb, nl, pt (PT), sv, tr, vi, zh (HK, TW) (Mac, `measure_foundationmodels_mac_output.txt`). Apple's own list for the feature: English, Danish, Dutch, French, German, Italian, Norwegian, Portuguese, Spanish, Swedish, Turkish, Vietnamese, Chinese (both), Japanese, Korean. No Indonesian, Arabic, Hindi, Thai, Polish, Russian, Hebrew, Malay. The device language and Siri language must match a supported language.
- Memory: Apple Frameworks Engineer, July 2025: the model and inference resources are managed centrally by the OS, "increase to your app's memory usage will be very minimal" (`forum_795044_fm_memory.md`). Apple DTS, June 2026, about extensions: the system model "is not loaded into the app / extension's memory" and so does not count on the extension's limit; "some extensions don't allow XPC due to privacy reason" and cannot use it; the follow-up asking whether that includes SystemLanguageModel has no answer on the page (`forum_833575_fm_in_extensions.md`). Measured here: the test process stayed at about 12 to 15 MB resident across four model calls (Mac), which agrees with the DTS statement.
- Whether a **keyboard** extension may call it at all: UNSURE. No Apple page says. A file that imports FoundationModels and NaturalLanguage type-checks with the `-application-extension` flag against the iOS 27.2 SDK (no API-level ban), but that is compile time only. Needs a device test with a keyboard target before anything is promised. Full Access may also matter (GUESS; Apple's page ties networking and shared containers to it, not on-device model calls).
- Latency (Mac, `measure_foundationmodels_mac_output.txt`): first call 15.8 s (model load), then 2.0 to 2.5 s for a short structured pick among 8 snippets. Filling blanks from a sentence 2.2 to 2.8 s. Naming a snippet and finding its variable parts 5.1 s. The content-tagging variant 9.1 s on the same text. An iPhone with a smaller chip will not be faster (GUESS).
- Quality in my small tests (Mac): picking 2 of 8 snippets for a refund email gave sensible choices; extracting Name and Date from English, Indonesian and Japanese sentences all worked (`Sarah / Tuesday 3 December`, `Budi / 3 Desember`, `田中さん / 12月3日`), including Indonesian, which is not in the supported list. The suggested SF Symbol for a snippet was `Rp`, which is not a symbol: any icon suggestion must be validated against real SF Symbol names. It missed a person's name ("Maria") when asked for the parts that change, so it is unreliable as the only detector.
- New in iOS 27: `PrivateCloudComputeLanguageModel` is in the SDK. It sends text to Apple servers, so Cutling should not use it (rule: on device and say so). Apple says server-model features have daily limits (support 121115).
- Safety: guardrails apply; `permissiveContentTransformations` exists (`sdk_FoundationModels_iOS27.2.swiftinterface`). Snippets with card numbers or a seed phrase could trigger refusals (GUESS).
- Already in the app: `Cutling/CodeDetector.swift` uses it in the main app only, with rules first and the model second.

### NaturalLanguage

- `NLTagger` `.nameType` (people, places, organisations): iOS 12+. **English only** in my Mac test; Spanish, French, German, Portuguese, Indonesian and Japanese sentences all returned "Other" for names and places (`measure_nltagger_languages_mac_output.txt`). Cutling's existing name detection (`Cutling.swift`, `NLTagger(tagSchemes: [.nameType])`) therefore probably finds nothing outside English (UNSURE on iPhone; needs a device check). 20 ms for a 120-character sentence (Mac). Not thread safe: one tagger per thread (`apple_nl_nltagger.json`).
- `NLLanguageRecognizer`: gave Indonesian with 0.99999 on a 6-word sentence (Mac, `measure_nl_languages_mac_output.txt`). Cheap, any length.
- `NLEmbedding.wordEmbedding` / `sentenceEmbedding` (iOS 13+): on-device, bundled with the OS. On this Mac sentence and word embeddings existed only for **English and Simplified Chinese** among 26 languages I tried (Mac; Apple's page speaks of "a number of languages" and names none, `apple_nl_nlembedding.json`). 512 dimensions. Cost grows with text: about 20 ms for 40 characters and about 300 ms for 500 characters; 200 sentences moved resident memory from 15 MB to 32 MB (Mac, `measure_nlembedding_mac_output.txt`, `measure_ranking_and_tagger_mac_output.txt`). Embedding about 300 long cutlings took 37 s, so 1,000 would take about 2 minutes: main app, in the background, once per cutling, cached. One instance is not safe across threads.
- `NLContextualEmbedding` (iOS 17+): BERT-style; on this Mac one model covered 20 Latin-script languages (cs da de en es fi fr hr hu id it nb nl pl pt ro sk sv tr vi), 512 dimensions, 256 tokens maximum, assets downloaded on demand with `requestAssets` (Mac, `measure_nl_languages_mac_output.txt`; WWDC23 10042 says three models: Latin, Cyrillic, CJK, `wwdc23_10042.html`). Apple says to use `NLEmbedding` for similarity (`apple_nl_nlembedding.json`). The assets download is a network event from the system, not from the app (GUESS).
- From an extension: no Apple page says either way for NLEmbedding. A Grammarly engineering post (2024-10-09, `grammarly_personal_language_model.html`) says a keyboard gets about 70 MB, theirs used 60 MB, so a model that sits in RAM is the hard part. Cutling's own measure: the keyboard peaks at 59 MB with 5,000 text cutlings and 500 photos (`Cutling/CutlingStore.swift`, comment, lines 46 to 54), leaving about 18 MB under 77. A sentence embedding on the Mac took 9 MB to load and grew to 32 MB in use: too tight at the top of the cutling limit (GUESS; measure on a device with Instruments).
- A quick ranking test (Mac, English, 8 cutlings, 5 contexts): the right cutling was top for 3 of 5 contexts. "Where should I send the parcel? My address is" ranked Home address outside the top three; "I will be away next week" ranked Out of office third. Treat it as a weak signal, useful only as one input beside input type, recency and use count (GUESS on the weights).

### Core ML / Create ML

- A text classifier trained in Create ML (`MLTextClassifier`, iOS 15+, `apple_createml_mltextclassifier.json`) loads into the keyboard's own memory (DTS about custom models, forum 833575). Cutling has no training data and no data collection, so a trained classifier would have to be built from public text and shipped in the app; no benefit over rules for the ideas below (GUESS). Not recommended.

### NSDataDetector

- Dates, links, addresses, phone numbers, transit info. 3.7 ms for a 120-character message (Mac). It parsed "Friday 3 Dec at 3pm" into a date (`measure_ranking_and_tagger_mac_output.txt`); Gboard's own help page says its paste feature only reads dates "written in numerical format" (`gboard_copy_paste_help.html`). Cutling already uses it.

### UITextChecker and the lexicon

- `UITextChecker` (iOS 3.2+): spell check, `completions(forPartialWordRange:...)`, `guesses`, `learnWord` (`apple_uikit_uitextchecker.json`). Per language lexicon; useful for word completion, not for choosing a cutling. Cutling draws no letter keys, so it has no completion to feed.
- `UILexicon` via `requestSupplementaryLexicon`: names and text-replacement shortcuts; the Parley keyboard copies shortcuts only and drops contact names as a privacy pattern (earlier research `fill-ins-keyboard-apis.md`).

### Writing Tools

- UITextView and UITextInput behaviour, iOS 18+ (`apple_uikit_writingtools.json`). In the iPhone OS 27.2 UIKit headers, `UITextDocumentProxy` has no Writing Tools member; the names appear only in UITextView, UITextInput, UIResponder and related headers (`sdk_uikit_proxy_writingtools_iOS27.2.txt`). A keyboard cannot call Writing Tools; the person can still select the text and use it from the host app. Apple's support list includes "Automatic proofreading", "Personalised Smart Reply in Messages (English only)" and "Suggestions in Mail (English only)" as system features (support 121115).

### App Intents, Siri, Spotlight

- `IndexedEntity` (iOS 18+) and Core Spotlight `CSSearchableItem` (iOS 9+) put cutlings in Spotlight and Siri (`apple_appintents_indexedentity.json`, `apple_cs_searchableitem.json`); Cutling already has 10 App Shortcuts. Neither reads what the person types. No ML on typing here; it is for finding a cutling outside the keyboard. A MIT-licensed repo (0 stars, pushed 2026-07-05) combines `NLEmbedding.sentenceEmbedding` with Core Spotlight and App Intents (`nagayu_local_first_rag_readme.md`): a pattern to read, not to depend on.

### What the keyboard can and cannot see

- Sees: `documentContextBeforeInput`, `documentContextAfterInput`, `selectedText`, `documentIdentifier`, `documentInputMode`, field traits (`sdk_uikit_proxy_writingtools_iOS27.2.txt`, `apple_uikit_uitextdocumentproxy.json`, `apple_uikit_uitextcontenttype.json`). The content type list is rich (name, givenName, emailAddress, fullStreetAddress, creditCardNumber, birthdate, organizationName, location and more), but only if the host app sets it.
- Never sees: secure (password) fields and phone-pad fields, where iOS replaces any custom keyboard with the system keyboard (Apple archived App Extension guide, `ExtensibilityPG_CustomKeyboard.html` in `docs/research/fill-ins-keyboard-apis-sources/`). So a password typed in a password field cannot reach a Cutling feature: unlike TextExpander on the Mac, which depends on apps marking fields secure (TextExpander page, 2025-09-23). That is worth saying in the privacy line.
- The context window the proxy returns is a slice around the cursor (the amount is not documented; UNSURE how many characters).
- Without Full Access: no network and no shared container (Apple Open Access page, 2026). Cutling already needs Full Access for the App Group, so every ML feature would run with it granted; none needs the network.

## 2. What others ship

| Product | What it does | How it reads the text | What users said |
|---|---|---|---|
| TextExpander Suggested Snippets (Mac, Windows) | Suggests a new snippet when you type the same thing repeatedly | Logs up to 30 keystrokes in memory, 300 with Snippet Suggestions on, stored as hashes; relies on apps to mark password fields secure; if an app does not, it "may" suggest from them (`te_keystrokes.html`, updated 2025-09-23) | "all text is keylogged - including sensitive passwords and banking information" (R13, r/ios 2025-08-28); a rival now sells "doesn't log or transmit your keystrokes like TextExpander does" (R14, 2026-09-07) (`voc_rows_A14_R13_R14.md`) |
| TextExpander AI Recommendations (Chrome only) | Recommends snippets from the text you are working on | Gemini Nano, "runs entirely on your computer"; needs 22 GB free, 4 GB VRAM or 16 GB RAM; not on iOS, Android or ChromeOS (`te_snippet_recommendations.html`, updated 2026-07-22) | Not read. It is the closest shipped idea to ranking by context, and it chose on-device and said so. |
| Gboard (Android) | A suggestion strip shows recently copied text; Smart paste splits a copied block into email, URL, phone, number, address, date and time for one-tap pasting | Reads clipboard and the field; dates only if numeric; addresses, dates and times only in some regions and languages (`gboard_copy_paste_help.html`) | Not read this run. The off switch exists. |
| Microsoft SwiftKey (iOS) | Clipboard (30 clips, 1,000 characters each, unpinned clips expire after 1 hour), text shortcuts | Full Access is for the container; "No language data or words you type will ever be transferred" unless an account is created (`swiftkey_full_access_ios.html`, `swiftkey_clipboard.html`) | Its page has to argue against the Full Access warning, which shows the fear is common. |
| Raycast Keyboard (iOS) | Full keyboard; Snippets work without Full Access; Quick Fix, Ask AI, AI Commands, Create Snippet from the field need Full Access because they use the network; no typing help in password, one-time code, phone, card number, postal code and date fields; Create Snippet saves the selected text or the whole field (`raycast_ios_keyboard.md`, `raycast_ios_changelog_1_2_13.html` 2026-05-29: inline snippet expansion and BYOK) | Sends text to a server for AI; snippet expansion is local | No AI feature that suggests snippets was found in the manual (UNSURE it does not exist). |
| Paste / PastePal (iOS) | Searchable clipboard history; PastePal: 75 text transforms, "no automatic tracking, no external servers" (`itunes_pastepal.json`, App Store, version date 2026-11-07, 4.14 from 192 ratings) | Keyboard shows items on request | Paste's own blog (2026-07-14) says iOS 27 adds a paste suggestion in the bar above the keys for the last copy only (`paste_ios27_blog.html`). I could not find an Apple page for it (UNSURE; it is a rival's account). |
| Clip Keyboard (iOS) | "Smart clipboard: what you copy is sorted for you", recognises emails, phones, addresses, card numbers, IBANs; secure snippets behind Face ID (`itunes_clipkeyboard.json`, 2026-11-20, 4.54 from 13 ratings) | Pattern matching on copied text | One 1-star review: a suggestion surfaced a bank account number and prompted to paste it, "Scam beware" (A14, 2026-11-04, `voc_rows_A14_R13_R14.md`). |
| Apple QuickType and iOS 27 paste suggestion | QuickType shows words and codes; I did not fetch an Apple page for the iOS 27 paste suggestion | not fetched | UNSURE: nothing from Apple read for this row. |

Takeaways from the rows: (a) Every one of the three trust failures (R13, R14, A14) comes from a suggestion that surfaced something the person did not expect. (b) The only shipped context-ranking idea (TextExpander in Chrome) is on-device and says so. (c) Raycast shows a way to mark fields that get no assistance. (d) Nobody I found ships "turn the names and amounts in a pasted snippet into blanks" on iOS (UNSURE: I did not search every app).

Open-source reference points (`github_repo_checks_2026-11-21.json`): Espanso (GPL-3.0, 14,818 stars, pushed 2026-11-15): expander, no ML; its licence rules out copying code into a closed app. FlorisBoard (Apache-2.0, 8,793 stars, pushed 2026-11-18): Android keyboard; it can inform design but has no code for iOS. KeyboardKit (licence field NOASSERTION, 1,906 stars, pushed 2026-11-16): a UI kit with its own terms; not needed since Cutling draws its own screens. NagaYu/local-first-rag-apple (MIT, 0 stars): pattern only. Nothing to take as code; the Apple frameworks are the dependency.

## 3. Candidate features

Common privacy line, for every feature below (no source says it should be this; it is the owner's pick): "Runs on this iPhone. Cutling reads only the text beside the cursor, only while you use the keyboard, keeps none of it and sends none of it." True only if the code stores nothing, writes no log, and uses no network call. It is true today for the fill-in reading of the word before the cursor.

Value guesses are labelled GUESS; I have no usage data.

### A. Rank cutlings by what is being written (sentence embeddings)

- Does: reorders the grid or shows a short "Suggested" row by similarity between the text before the cursor and each cutling's name and text.
- Frameworks: `NLEmbedding.sentenceEmbedding`, optionally `NLLanguageRecognizer`.
- Where: cutling vectors computed once in the main app (about 2 minutes per 1,000 long cutlings on a Mac, GUESS slower on a phone) and written to a file in the App Group; the keyboard embeds only the short text before the cursor (20 ms for 40 characters on a Mac; 300 ms for 500, so cap the slice at about 200 characters, GUESS) and compares against vectors it memory-maps.
- Privacy: on device; vectors are numbers derived from the person's own cutlings; nothing leaves; the typed text is never stored.
- Risk: memory is the problem. The keyboard already peaks at 59 MB at the cutling limit with photos; the embedding model added up to 17 MB on the Mac (15 to 32 MB; UNSURE on iPhone). Mitigate by turning it on only below a cutling count measured on a device, loading the model on first use and dropping it after. Languages: English and Simplified Chinese only in my Mac test, so for others it would silently do nothing. Quality: 3 of 5 top-1 in my small test; a wrong top suggestion is the A14 failure (a surprise).
- Value: GUESS medium for people with hundreds of cutlings; low for fewer than 30 where scrolling is fast; weak without a language.

### B. Fill a blank from the text around the cursor (a name or date already typed)

- Does: when a cutling has `{Name}` or `{Date}` and the text before the cursor holds "Hi Sarah," or a date, the blank starts filled with that value, shown for one tap to confirm.
- Frameworks: `NLTagger.nameType` for English, `NSDataDetector` for dates, rules for amounts. Foundation Models on tap as a second pass on supported devices (it filled Name and Date correctly in English, Indonesian and Japanese in my test, about 2.5 s).
- Where: rules in the keyboard; the model call only if Foundation Models works from a keyboard (UNSURE).
- Privacy: the same slice the keyboard reads today for the first blank (`FillSession.wordTypedFirst`); nothing stored.
- Risk: low memory (tagger and detector are system services; 20 ms and 4 ms on a Mac). Wrong guesses are visible and one tap to change, not silent. Names only in English by tagger; the model covers more.
- Value: GUESS the best match to what the owner said ("be smarter about what people type"), because it removes the typing step that Cutling's keyboard has, since it draws no letter keys.

### C. Offer to turn names, dates and amounts in a new cutling into fill-ins

- Does: when a cutling is saved or edited, show a "Make these blanks?" row with the detected pieces (a name, a date, an amount, an order number); one tap rewrites `Maria` into `{Name: Maria}`.
- Frameworks: `NSDataDetector` (dates, links, phones), `NLTagger` (names, English), a regular expression for amounts and numbers, Foundation Models in the main app for the rest (it found "order #4471", "3 Dec", "Rp 150.000", "3 days" in my test, missed the name, 5 s).
- Where: main app only (the editor), where memory is not a problem and Foundation Models already runs (`CodeDetector.swift`).
- Privacy: text never leaves the editor; no keyboard involvement; the easiest line to state.
- Risk: lowest. Never touches the keyboard's 77 MB. Skip code cutlings and cutlings flagged sensitive (credit card, API key, seed phrase) so no detector reads them.
- Value: GUESS medium; it teaches the new fill-ins feature at the moment someone creates a cutling. Fits the card for the growth board because it makes fill-ins visible.

### D. Suggest a name and an icon when saving

- Does: proposes a 2 to 3 word name and an SF Symbol for a new cutling.
- Frameworks: rules first (the existing input type detection: email, phone, address); Foundation Models for the rest; validate the symbol against `UIImage(systemName:)` or `NSImage(systemSymbolName:)` since the model returned `Rp` (not a symbol).
- Where: main app only.
- Privacy: same as C.
- Risk: low; 5 s per suggestion on a Mac, so run it in the background after the text is pasted, show nothing until ready. Poor icons are cosmetic.
- Value: GUESS small; saves a step for people who paste 10 items at once, but the person can already name them.

### E. Detect language or tone of the field

- Does: language: show cutlings written in the same language first (`NLLanguageRecognizer` on the text before the cursor, or `primaryLanguage` / `documentInputMode` the keyboard already receives). Tone: a formal vs casual label from the model.
- Frameworks: `NLLanguageRecognizer` (cheap, reliable in my Indonesian test); tone needs Foundation Models.
- Where: language in the keyboard (no model, tiny); tone only on tap if at all.
- Risk: language low. Tone: slow (2 s plus), supports 24 locales, and labels are subjective: GUESS reject for now.
- Value: language, GUESS small-to-medium for bilingual users (a person who keeps English and Indonesian cutlings) and needs a language tag on each cutling, computed once in the main app. Tone: GUESS low.

### F. Smart date phrases

- Does: `{date +3d}` already exists. Add detection of dates already in the text ("see you Friday") and offer `{date +Fri}`-style or "same day next week".
- Frameworks: `NSDataDetector` on the text before the cursor.
- Where: keyboard, system service, 4 ms on a Mac.
- Risk: low. Duplicates B for dates; do inside B.
- Value: GUESS small as its own feature.

### G. Not recommended

- Suggested Snippets from what people type (TextExpander's model): needs a log of typing; R13 and A14 are the reason not to. Cutling can instead offer "save this" on a selected text, which the person starts (Raycast's Create Snippet does that: selected text or the whole field).
- Core ML trained classifier: no training data; adds memory.
- Private Cloud Compute model: not on device.
- Writing Tools: no keyboard API.
- Typed-abbreviation expansion: out of scope here (VOC item), needs watching keystrokes.

## Top three to propose first

1. **Fill a blank from the text around the cursor (B), then fold the date part of F into it.** It does what the owner described, "smarter about what people type", using text the keyboard already reads for the first blank, and adds no model to the keyboard's memory: NSDataDetector and NLTagger are system services measured at 4 ms and 20 ms on a Mac. Wrong values are shown for a tap, never typed silently, which avoids the surprise behind A14. Limits to say plainly in the card: person names only in English from the tagger (UNSURE on iPhone, needs a device check), and the model second pass on Apple Intelligence devices only, if Foundation Models turns out to work from the keyboard (UNSURE, needs a device test). Start with the tagger and detector; the model is an optional second step.
2. **Offer to turn names, dates and amounts in a newly saved cutling into fill-ins (C), with name and icon suggestions (D) alongside.** It lives in the main app, where Foundation Models already runs and memory is free, so the 77 MB limit and the keyboard's speed are untouched, and the privacy line is the easiest to write: the text never leaves the editor. It makes the new fill-ins feature discoverable at the moment of saving, and it skips code and sensitive cutlings. Validate every suggested SF Symbol (my test returned a non-symbol). Works without Apple Intelligence through rules for dates, links, phones and amounts, with the model adding more on supported devices.
3. **Rank by what is being written (A), as an experiment behind a measured cutling count, language-limited.** It is the most "smart" feature and the one TextExpander chose to build on-device, but it is also the one with real costs: a sentence embedding model in a keyboard that peaks at 59 MB with 18 MB to spare, English and Simplified Chinese only in my test, and 3 of 5 correct top results in a tiny test. Propose it only after a device measurement of memory and speed with the real cutling counts, and ship it as a quiet "Suggested" row that appears only when the match is strong, with the on-device line next to its switch. If the device test fails, language detection (E) alone gives the bilingual case for almost no memory.

## Not confirmed

- Whether a keyboard extension can call Foundation Models, and whether it needs Full Access: no Apple source; device test needed.
- iPhone memory, speed and language coverage of NLEmbedding, NLTagger names and NLContextualEmbedding: all numbers are from a Mac.
- Apple's own page for the iOS 27 paste suggestion; I only found Paste's blog.
- Gboard and SwiftKey user comments; I read only their help pages.
- How many characters `documentContextBeforeInput` returns in practice.
- Whether TextExpander for iPhone has Suggested Snippets.
