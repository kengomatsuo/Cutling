# Sources for fill-ins-press-feedback.md (fetched 2026-11-21)

| # | URL | saved file | what to take |
|---|---|---|---|
| 1 | https://support.apple.com/en-us/102463 | `apple_support_102463.txt` | Keyboard Feedback has separate Sound and Haptic switches (iOS 16+); published 2026-05-27 |
| 2 | https://developer.apple.com/documentation/uikit/uidevice/playinputclick() | `uikit_uidevice_playinputclick__.json` | click plays only if the user enabled keyboard clicks and the input view adopts the protocol |
| 3 | https://developer.apple.com/documentation/uikit/uiinputviewaudiofeedback | `uikit_uiinputviewaudiofeedback.json` | protocol "optional but expected" |
| 4 | https://developer.apple.com/documentation/uikit/uiinputviewaudiofeedback/enableinputclickswhenvisible | `uikit_uiinputviewaudiofeedback_enableinputclickswhenvisible.json` | return true; click needs the user's setting |
| 5 | https://developer.apple.com/documentation/uikit/uiimpactfeedbackgenerator | `apple_uiimpactfeedbackgenerator.md` | impactOccurred(intensity:) exists |
| 6 | https://developer.apple.com/documentation/uikit/uiselectionfeedbackgenerator | `uikit_uiselectionfeedbackgenerator.json` | selection feedback meaning: discrete values |
| 7 | https://developer.apple.com/documentation/swiftui/view/sensoryfeedback(_:trigger:) | `swiftui_view_sensoryfeedback__:trigger:_.json` | SwiftUI haptic API |
| 8 | https://developer.apple.com/design/human-interface-guidelines/playing-haptics | `hig_playing-haptics.json` | haptics optional, complement visuals, avoid overuse |
| 9 | https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard | `apple_configuring-open-access-for-a-custom-keyboard.md` | open-access list does not mention haptics |
| 10 | https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html | `../fill-ins-keyboard-apis-sources/ExtensibilityPG_CustomKeyboard.html` | RequestsOpenAccess unlocks playInputClick audio (2017) |
| 11 | https://developer.apple.com/forums/thread/710612 | `developer_apple_com_forums_thread_710612.txt` | no answer on stock click id or haptics in keyboards (2022) |
| 12 | https://developer.apple.com/documentation/uikit/uifeedbackgenerator | `apple_uifeedbackgenerator.md` | generator overview |
| 13 | https://github.com/KeyboardKit/KeyboardKit tag 9.0.0 (MIT; 1906 stars, pushed 2026-11-16, not archived) | `code/kk9_KeyboardFeedback+HapticConfiguration.swift` | default haptics selection on press and release, medium on long press |
| 14 | same repo, 9.0.0 | `code/kk9_KeyboardFeedback+Audio.swift` | sound ids 1104, 1155, 1156 |
| 15 | same repo, 9.0.0 | `code/kk9_StandardStyleService.swift` | pressed-state colour swap, no animation |
| 16 | same repo, 9.0.0 | `code/kk9_README.md` | haptic feedback needs Full Access (author's claim) |
| 17 | https://github.com/azooKey/azooKey (MIT; 812 stars, pushed 2026-11-14, not archived) | `code/azookey_KeyboardFeedback.swift` | impact intensity 0.7 to 1, sound ids, gated on Full Access, fire at touch down |
| 18 | same repo, commit 0b19111 | `code/azookey_SemiStaticStates.swift` | hapticsAvailable and hasFullAccess |
| 19 | same repo | `code/azookey_SimpleKeyView.swift` | press state set on touch down, no animation on the key |
| 20 | same repo | `code/azookey_ResultBar.swift` | only the candidate bar animates (0.2 s) |
| 21 | https://www.macrumors.com/2026/07/01/ios-27-new-copy-and-paste-feature/ | `macrumors_ios27_paste.html` | iOS 27 paste suggestion in the bar; no confirmation described |
| 22 | https://pasteapp.io/blog/ios-27-keyboard-paste-button | `paste_ios27_keyboard_paste.html` | same, 2026-07-14, a vendor blog |
| 23 | https://support.google.com/gboard/answer/10742542 | `gboard_clipboard_help.html` | tap item to paste, no confirmation described (Android) |
| 24 | https://manual.raycast.com/ios/keyboard | `../fill-ins-keyboard-apis-sources/raycast_ios_keyboard.md` | no tap confirmation described; Key Haptic Feedback defaults from the iOS keyboard haptics setting (line 270) |
| 25 | https://developer.apple.com/design/human-interface-guidelines/virtual-keyboards | `../fill-ins-keyboard-apis-sources/hig_virtual-keyboards.json` | says nothing on key press visuals |
| 26 | Apple's own keyboard frames | gated: simulators held by the device queue, no download approved; no frames extracted | Q1 and Q3 stay GUESS |
