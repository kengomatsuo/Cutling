# Sources for ../fill-ins-keyboard-apis.md (fetched 2026-11-21)

| # | URL | saved file | what to take |
|---|---|---|---|
| 1 | https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html (Updated 2017-10-19) | `ExtensibilityPG_CustomKeyboard.html` | No API to list or pick a keyboard; height may change after first draw; no microphone |
| 2 | https://developer.apple.com/documentation/uikit/uiinputviewcontroller/advancetonextinputmode() | `uikit_uiinputviewcontroller_advancetonextinputmode__.json` | "Next keyboard in the user-enabled list", no previous |
| 3 | https://developer.apple.com/documentation/uikit/uiinputviewcontroller/handleinputmodelist(from:with:) | `uikit_uiinputviewcontroller_handleinputmodelist_from_with__.json` | List on long press or swipe up, advance on tap |
| 4 | https://developer.apple.com/documentation/uikit/uiinputviewcontroller/needsinputmodeswitchkey | `uikit_uiinputviewcontroller_needsinputmodeswitchkey.json` | true means show your own switch key |
| 5 | https://developer.apple.com/documentation/uikit/uiinputviewcontroller | `uikit_uiinputviewcontroller.json` | Complete member list: nothing for previous or named keyboard |
| 6 | https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard | `apple_creating-a-custom-keyboard.md` | Face ID iPhones get a system globe and needsInputModeSwitchKey false; wire globe to handleInputModeList with allTouchEvents |
| 7 | https://developer.apple.com/documentation/uikit/configuring-a-custom-keyboard-interface | `apple_configuring-a-custom-keyboard-interface.md` | Height by constraint on the controller's view; lexicon; hasDictationKey hides system dictation button |
| 8 | https://developer.apple.com/documentation/uikit/handling-text-interactions-in-custom-keyboards | `apple_handling-text-interactions-in-custom-keyboards.md` | insertText, deleteBackward, adjustTextPosition, marked text |
| 9 | https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard | `apple_configuring-open-access-for-a-custom-keyboard.md` | No microphone with or without Full Access; lexicon and shortcuts available without it |
| 10 | https://developer.apple.com/design/human-interface-guidelines/virtual-keyboards | `hig_virtual-keyboards.json` | Globe replaces Emoji key; do not duplicate system keys; no keyboard shortcuts |
| 11 | iPhoneOS27.2.sdk UIKit headers (local Xcode) | `sdk_headers_iOS27.2.txt` | No previous-keyboard API; UITextChecker and accessibility posts not extension-unavailable; documentInputMode |
| 12 | https://developer.apple.com/documentation/uikit/uiaccessibilitytraits/keyboardkey | `uikit_uiaccessibilitytraits_keyboardkey.json` | Trait definition |
| 13 | https://developer.apple.com/documentation/uikit/uitextchecker | `uikit_uitextchecker.json` | Spell-check API |
| 14 | https://developer.apple.com/documentation/uikit/uiinputviewcontroller/requestsupplementarylexicon(completion:) | `uikit_uiinputviewcontroller_requestsupplementarylexicon_completion__.json` | What the lexicon holds |
| 15 | Apple Developer Forums threads 849736, 92030, 83066, 706659, 794642, 766595, 777475, 788019, 650883, 842928, 813579, 799003, 738465, 843093, 76508, 727085, 854736, 843118, 821235, 775077 | `forums_apple_read_2026-11-21.md` | DTS statements and reports with dates; UNREAD reply bodies listed |
| 16 | https://support.apple.com/guide/iphone/add-or-change-keyboards-iph73b71eb/ios ; https://support.apple.com/en-us/111796 (2025-03-20) | `apple_support_pages_2026-11-21.md` | Globe long press; VoiceOver Typing Mode |
| 17 | https://textexpander.com/learn/using/textexpander-for-iphone-ipad/how-to-set-up-textexpander-for-iphone-ipad (2026-09-04) | `textexpander_setup_2026-11-21.md` | Globe key only; fill-ins in keyboard |
| 18 | https://manual.raycast.com/ios/keyboard.md | `raycast_ios_keyboard.md` | Bottom row, Secondary Mode, Switch Keyboard on Close, languages |
| 19 | https://support.microsoft.com/en-gb/topic/how-do-i-switch-to-my-microsoft-swiftkey-keyboard-6134b555-0a98-4ef4-bcfb-8d91e5fc367e | `swiftkey_switch.html` | Globe left of the spacebar |
| 20 | https://www.applevis.com/forum/ios-ipados/bigkeys-large-key-keyboard-low-vision-voiceover-support (2026-09-02) | `applevis_bigkeys_2026-09-02.md` | VoiceOver in a shipped keyboard: trait, Touch Typing, rotor actions |
| 21 | https://github.com/imfuxiao/Hamster (65693706) | `code/imfuxiao_Hamster--Packages_HamsterKeyboardKit_Sources_KeyboardKit_Keyboard_KeyboardContext.swift` | Globe via handleInputModeList (MIT) |
| 22 | https://github.com/Kyome22/KeyboardExtensionKit (21e44542) | `code/Kyome22_KeyboardExtensionKit--Sources_KeyboardExtensionKit_GlobeButton_KEGlobeButtonOverlay.swift` | Globe overlay (MIT) |
| 23 | https://github.com/Kyome22/KeyboardExtensionKit (21e44542) | `code/Kyome22_KeyboardExtensionKit--Sources_KeyboardExtensionKit_Keyboard_KEKeyboardModel.swift` | Model side of globe (MIT) |
| 24 | https://github.com/azooKey/azooKey (0b191114) | `code/azooKey_azooKey--AzooKeyCore_Sources_KeyboardViews_View_UnifiedKey_KeyModels_Qwerty_QwertyLanguageSwitchKeyModel.swift` | In-keyboard language tab (MIT) |
| 25 | https://github.com/divvun/giellakbd-ios (e609ba11) | `code/divvun_giellakbd-ios--Keyboard_Models_SystemKeys.swift` | needsInputModeSwitchKey drives the bottom row (Apache-2.0) |
| 26 | https://github.com/Cantoboard/Cantoboard (12e2d963) | `code/Cantoboard_Cantoboard--CantoboardFramework_Keyboard_InputController.swift` | handleInputModeList forwarding (no licence: read only) |
| 27 | https://github.com/pathorsAI/parley (909a1010) | `code/pathorsAI_parley--ios_Keyboard_KeyboardVoicePane.swift` | isKeyboardKey trait, reduce motion (Apache-2.0) |
| 28 | https://github.com/pathorsAI/parley (909a1010) | `code/pathorsAI_parley--ios_Keyboard_KeyboardSystemLexicon.swift` | Lexicon: keep shortcuts, drop contact names (Apache-2.0) |
| 29 | https://github.com/jtvargas/SnipKey | `code/jtvargas_SnipKey--SnipKeyboard_QWERTY_PredictiveTextEngine.swift` | UITextChecker completions and guesses in an extension (MIT) |
| 30 | https://github.com/VocaHQ/vocaphone | `code/VocaHQ_vocaphone--ios_VocaPhoneKeyboard_SpellChecking.swift` | UITextChecker cost and memory notes (AGPL: read only) |
| 31 | https://snippety.app/help/ios/ | gated: page returned 404, no iOS keyboard-key page found | Snippety's switch key label: UNSURE |
| 32 | Gboard iPhone help | gated: no Google page found that names the key | Gboard's switch key label: UNSURE |
