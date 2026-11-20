# Apple Developer Forums threads, read in Claude in Chrome (get_page_text) on 2026-11-21
Page text only; reply bodies the page did not show are marked UNREAD. Paraphrased, not copied.

## 849736  https://developer.apple.com/forums/thread/849736   created Oct 2026 (iPhone Duo, Xcode 27.1 RC 1)
DTS engineer Ziqiao Chen, Oct 2026 (marked Recommended): a custom keyboard checks needsInputModeSwitchKey to decide whether to show a globe key wired to advanceToNextInputMode. On iPhones with Face ID it returns false because the system draws the globe. On iPhone Duo and other iPhones without Face ID it returns true and the keyboard must draw its own. DTS says failing to do so leads to an App Review rejection because people would have no way to switch.

## 92030  https://developer.apple.com/forums/thread/92030   Nov 2017 - Dec 2018
needsInputModeSwitchKey returned false on iPhone X inside a compatibility-mode (non-X-optimised) app, so no globe was visible at all; filed rdar://35549038; poster says fixed in iOS 12 beta 1. Replies say show the key anyway rather than strand people.

## 83066  https://developer.apple.com/forums/thread/83066   Jul 2017
handleInputModeList(from:with:) showed no menu when called from touch overrides, and just advanced when called on touch up inside. Accepted answer: add it as the button's target for .allTouchEvents.

## 706659  https://developer.apple.com/forums/thread/706659   May 2022 (+ reply May 2023)
On iPhones without a Home button a keyboard cannot tell the system globe (system-drawn, below the keyboard) from the keyboard being hidden: viewWillDisappear fires for both. Reply: watch keyboardWillChangeFrame and UIWindowScene.textInputMode?.primaryLanguage to learn whether your keyboard is still the active one.

## 794642  https://developer.apple.com/forums/thread/794642   Jul 2025
For an APP's own text views only: DTS says override textInputContextIdentifier so the instance remembers its input mode; overriding UITextInputMode in a UIResponder (textInputMode, choosing from UITextInputMode.activeInputModes by primaryLanguage) works per text field, not app-wide. Applies to host-app fields, not to a keyboard extension choosing another keyboard.

## 766595  https://developer.apple.com/forums/thread/766595   Oct 2024
Developer's own answer (not Apple): with a hardware keyboard connected to iPad (same on iPhone with a Bluetooth keyboard), the hardware keyboard's globe key opens a list; choosing the custom keyboard shows it on screen even though the hardware keyboard is connected; pressing globe again switches between the two most recent keyboards.

## 777475  https://developer.apple.com/forums/thread/777475   Mar 2025
DTS Ziqiao Chen: it is as-designed that the system hides the virtual keyboard when an external keyboard is connected, and there is no API for a keyboard extension to show itself without the user action ("Show Keyboard" in the shortcuts bar).

## 788019  https://developer.apple.com/forums/thread/788019   Jun 2025, last reply 16 Sep 2026
iOS 26: the mini keyboard (shortcuts) bar does not consistently appear with a hardware keyboard; iOS 18 always showed it. FB18105243. A reply says it persists on iPadOS 27.

## 650883  https://developer.apple.com/forums/thread/650883   Jun 2020
pressesBegan/pressesEnded overridden on a UIInputViewController subclass "don't seem to be called at all". 0 replies. Not an Apple answer.

## 842928  https://developer.apple.com/forums/thread/842928   Aug 2026
Asks whether UIKeyCommand in a keyboard extension can intercept Bluetooth keyboard keys. The only reply is not from Apple and gives no API answer. No Apple answer.

## 813579  https://developer.apple.com/forums/thread/813579   Jan 2026 (last reply Oct 2026)
Fixed 268 pt height set with a constraint on self.view: the extension view is first 0x0, then ~295 ms later full screen height (956 pt), ~373 ms later 452 pt, ~390 ms later 268 pt: a visible flicker. intrinsicContentSize on a UIInputView subclass, allowsSelfSizing, preferredContentSize, frame overrides all ignored. iOS 17, 18, 26.2, simulator and device. Reply texts UNREAD (page showed only counts).

## 799003  https://developer.apple.com/forums/thread/799003   Sep 2025 - May 2026
A height-constraint keyboard with a DTS reply that the page text did not show: reply body UNREAD.

## 738465  https://developer.apple.com/forums/thread/738465   Sep 2023 - Dec 2023
On iPad the keyboard gets taller each time it is switched back to. Reply bodies UNREAD.

## 843093  https://developer.apple.com/forums/thread/843093   Aug 2026 - Oct 2026 (FB24460699)
iOS 27 betas 1-6: after leaving to another app and returning with the text field still focused, the host sees the keyboard frame 17 pt taller; extension view.bounds, safe area and a 180 pt constraint are unchanged; reproduced with several third-party keyboards. Replies (9) UNREAD.

## 76508  https://developer.apple.com/forums/thread/76508   Apr-May 2017
Custom keyboard behaving like Apple's keyboard in VoiceOver Touch Typing: keys carried UIAccessibilityTraitKeyboardKey; VoiceOver said "Bottom of document" on delete. Poster's fix: post UIAccessibilityAnnouncementNotification with the character read from textDocumentProxy.documentContextBeforeInput before deleting. Developer answer, not Apple.

## 727085  https://developer.apple.com/forums/thread/727085   Mar 2023
Apple Frameworks Engineer: nothing can change how VoiceOver processes (hardware) keyboard events; single-letter input can be eaten by Quick Nav. About hardware keyboards in an app, not extensions.

## 854736  https://developer.apple.com/forums/thread/854736   ~Nov 2026 ("2w" old on 2026-11-21; replies dated 2 Nov)
DTS Travis: the archived Custom Keyboard guide is the documented baseline: no microphone, so no dictation input; "no API to obtain a list of enabled keyboards or for picking a particular keyboard to switch to"; the extension has only advanceToNextInputMode() and handleInputModeList(from:with:); DTS knows of no later public API; suggests dictation in the containing app or letting the person switch to the system keyboard. Also: on iPhone Duo with iOS 27.1 the system dictation button sits inside the system keyboard and is therefore unavailable with a third-party keyboard.

## 843118  https://developer.apple.com/forums/thread/843118   Aug 2026
Keyboard + app for dictation: asker says settled already: no public API to identify or return to the host app. Guideline 4.4.1 forbids launching apps other than Settings; no answer given. A reply asks for a user-granted microphone permission for keyboards (FB24570791).

## 821235  https://developer.apple.com/forums/thread/821235   Apr 2026
Full Access does not give a keyboard the microphone though the doc wording suggests so. No reply.

## 775077  https://developer.apple.com/forums/thread/775077   Feb 2025 - Sep 2025
AVAudioEngine start fails in a keyboard with error 561145187 even with Full Access and microphone permission. Reply bodies UNREAD.

## 812642 / 772158 (from cutling-pains.md Q3)
Already recorded there; not re-read.
