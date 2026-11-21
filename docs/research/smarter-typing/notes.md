# Sources for smarter-typing.md (fetched 2026-11-21)

| # | URL | saved file | what to take |
|---|---|---|---|
| 1 | https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel | `apple_fm_systemlanguagemodel.json` | availability, 3 model versions, UseCase |
| 2 | https://developer.apple.com/documentation/foundationmodels | `apple_fm_root.json` | on-device and PCC models, watchOS 27 |
| 3 | iPhoneOS 27.2 SDK FoundationModels swiftinterface (local Xcode) | `sdk_FoundationModels_iOS27.2.swiftinterface` | contextSize 4096 before 27, PrivateCloudComputeLanguageModel, supportedLanguages, tokenCount |
| 4 | https://developer.apple.com/forums/thread/833575 (Chrome) | `forum_833575_fm_in_extensions.md` | DTS: system model not in extension memory; XPC caveat unanswered |
| 5 | https://developer.apple.com/forums/thread/795044 (Chrome) | `forum_795044_fm_memory.md` | Frameworks engineer: OS-managed model, minimal app memory |
| 6 | https://developer.apple.com/videos/play/wwdc2025/286/ | `wwdc25_286.html` | 3B parameters 2-bit, availability enum, content tagging adapter |
| 7 | https://developer.apple.com/videos/play/wwdc2025/301/ | `wwdc25_301.html` | tokens add latency, context limit error |
| 8 | https://developer.apple.com/documentation/technotes/tn3193-managing-the-on-device-foundation-model-s-context-window | `apple_tn3193.md` | 4096 tokens per session |
| 9 | https://developer.apple.com/documentation/foundationmodels/managing-the-context-window | `apple_fm_context.md` | context budgeting |
| 10 | https://developer.apple.com/documentation/foundationmodels/generating-content-and-performing-tasks-with-foundation-models | `apple_fm_generating.json` | guided generation how-to |
| 11 | https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output | `apple_fm_safety.json` | guardrails |
| 12 | https://support.apple.com/en-gb/121115 (Chrome) | `apple_support_121115_apple_intelligence_2026-11-21.md` | devices, 16 languages, features list, China, storage |
| 13 | https://developer.apple.com/documentation/naturallanguage/nlembedding | `apple_nl_nlembedding.json` | word and sentence embeddings API, not thread safe |
| 14 | https://developer.apple.com/documentation/naturallanguage/finding-similarities-between-pieces-of-text | `apple_nl_similarity.md` | sentence similarity how-to |
| 15 | https://developer.apple.com/documentation/naturallanguage/nlcontextualembedding | `apple_nl_contextualembedding.json` | contextual embedding, requestAssets, use NLEmbedding for similarity |
| 16 | https://developer.apple.com/videos/play/wwdc2023/10042/ | `wwdc23_10042.html` | three models Latin, Cyrillic, CJK; assets downloaded as needed |
| 17 | https://developer.apple.com/documentation/naturallanguage/nltagger | `apple_nl_nltagger.json` | tagger API, thread safety |
| 18 | https://developer.apple.com/documentation/naturallanguage/nltagscheme | `apple_nl_nltagscheme.json` | nameType scheme |
| 19 | https://developer.apple.com/documentation/naturallanguage/nllanguagerecognizer | `apple_nl_languagerecognizer.json` | language detection API |
| 20 | https://developer.apple.com/documentation/naturallanguage/nlmodel | `apple_nl_nlmodel.json` | custom Core ML text model wrapper |
| 21 | https://developer.apple.com/documentation/coreml | `apple_coreml_root.json` | models run on device, in the caller's memory |
| 22 | https://developer.apple.com/documentation/createml/mltextclassifier | `apple_createml_mltextclassifier.json` | trained text classifier, iOS 15 |
| 23 | https://developer.apple.com/documentation/foundation/nsdatadetector | `apple_foundation_nsdatadetector.json` | detector types |
| 24 | https://developer.apple.com/documentation/uikit/uitextchecker | `apple_uikit_uitextchecker.json` | completions, guesses, learnWord |
| 25 | https://developer.apple.com/documentation/uikit/uitextdocumentproxy | `apple_uikit_uitextdocumentproxy.json` | what the keyboard reads |
| 26 | iPhoneOS 27.2 SDK UIKit headers (local Xcode) | `sdk_uikit_proxy_writingtools_iOS27.2.txt` | proxy members; Writing Tools absent from proxy |
| 27 | https://developer.apple.com/documentation/uikit/uiwritingtoolsbehavior | `apple_uikit_writingtools.json` | Writing Tools is a text view behaviour |
| 28 | https://developer.apple.com/documentation/uikit/uitextcontenttype | `apple_uikit_uitextcontenttype.json` | field content types the host may set |
| 29 | https://developer.apple.com/documentation/uikit/uitextinputtraits | `apple_uikit_uitextinputtraits.json` | field traits |
| 30 | https://developer.apple.com/documentation/uikit/uiinputviewcontroller | `apple_uikit_uiinputviewcontroller.json` | keyboard controller API |
| 31 | https://developer.apple.com/documentation/uikit/uipasteconfiguration | `apple_uikit_pasteconfig.json` | paste configuration (host side) |
| 32 | https://developer.apple.com/documentation/appintents/indexedentity | `apple_appintents_indexedentity.json` | Spotlight index of entities, iOS 18 |
| 33 | https://developer.apple.com/documentation/corespotlight/cssearchableitem | `apple_cs_searchableitem.json` | Spotlight donations |
| 34 | App Extension guide, custom keyboard (earlier run) | `../fill-ins-keyboard-apis-sources/ExtensibilityPG_CustomKeyboard.html` | secure and phone pad fields get the system keyboard |
| 35 | Apple Open Access doc (earlier run) | `../fill-ins-keyboard-apis-sources/apple_configuring-open-access-for-a-custom-keyboard.md` | Full Access duties, keystroke data |
| 36 | https://textexpander.com/learn/accounts/security/how-textexpander-handles-your-keystrokes-keylogging-and-snippet-security | `te_keystrokes.html` | 30 / 300 keystrokes in memory, hashes, secure-field caveat, 2025-09-23 |
| 37 | https://textexpander.com/?p=93957 | `te_snippet_recommendations.html` | Recommendations: Gemini Nano local, Chrome only, requirements, 2026-07-22 |
| 38 | owner VOC file rows A14 R13 R14 (local) | `voc_rows_A14_R13_R14.md` | the three trust failures in buyers' words |
| 39 | https://support.google.com/gboard/answer/10742542 | `gboard_copy_paste_help.html` | smart paste splits copied text; dates numeric only |
| 40 | https://support.microsoft.com/en-us/swiftkey-keyboard/how-does-the-clipboard-work-with-microsoft-swiftkey-keyboard | `swiftkey_clipboard.html` | clipboard and shortcuts |
| 41 | https://support.microsoft.com/en-us/swiftkey-keyboard/why-does-my-microsoft-swiftkey-keyboard-need-full-access-in-ios | `swiftkey_full_access_ios.html` | Full Access explanation |
| 42 | https://manual.raycast.com/ios/keyboard.md | `raycast_ios_keyboard.md` | Full Access split, no help in sensitive fields, Create Snippet |
| 43 | https://manual.raycast.com/ios/snippets.md | `raycast_ios_snippets.md` | iOS snippets |
| 44 | https://www.raycast.com/changelog/ios/1-2-13 | `raycast_ios_changelog_1_2_13.html` | snippet expansion on iOS, BYOK, 2026-05-29 |
| 45 | https://pasteapp.io/blog/ios-27-keyboard-paste-button | `paste_ios27_blog.html` | iOS 27 paste suggestion as described by a rival, 2026-07-14 |
| 46 | iTunes lookup id 1503446680 | `itunes_pastepal.json` | PastePal claims, rating |
| 47 | iTunes lookup id 1543660502 | `itunes_clipkeyboard.json` | Clip Keyboard smart clipboard |
| 48 | https://www.grammarly.com/blog/engineering/personal-language-model/ | `grammarly_personal_language_model.html` | keyboard has about 70 MB; 2024-10-09 |
| 49 | gh api repos checks (NagaYu, KeyboardKit, FlorisBoard, Espanso, NLEmbeddingsSearch) | `github_repo_checks_2026-11-21.json` | stars, pushed, licence |
| 50 | https://github.com/NagaYu/local-first-rag-apple | `nagayu_local_first_rag_readme.md` | NLEmbedding + Core Spotlight pattern, MIT |
| 51 | my run on this Mac: Foundation Models | `measure_foundationmodels_mac_output.txt` | 8192 context, 24 locales, 16 s cold, 2 s warm |
| 52 | my run on this Mac: FM tasks | `measure_foundationmodels_tasks_mac_output.txt` | blanks and metadata extraction |
| 53 | my run on this Mac: NLEmbedding | `measure_nlembedding_mac_output.txt` | sentence languages, memory, timing |
| 54 | my run on this Mac: languages | `measure_nl_languages_mac_output.txt` | contextual embedding languages, recognizer |
| 55 | my run on this Mac: ranking and tagger | `measure_ranking_and_tagger_mac_output.txt` | ranking test, timings |
| 56 | my run on this Mac: NLTagger names | `measure_nltagger_languages_mac_output.txt` | names English only |
