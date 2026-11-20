# Fill-ins in the keyboard: what iOS lets a keyboard extension do

Card ASG87 / ASG88. Read 2026-11-21 unless dated otherwise. Every source is saved under `docs/research/fill-ins-keyboard-apis-sources/` (file named in each bullet; table in `notes.md` there). "GUESS" marks anything not read from a source. "UNSURE" marks a source seen but not opened or a claim not confirmed. Not re-done: the text-field-inside-a-keyboard findings and guideline 4.4.1 in `cutling-pains.md` Q3.

Devices: this Mac has Xcode with the iPhoneOS 27.2 SDK; nothing below was run on a device or simulator. Every "what it does" about switching is therefore read, not observed.

## Q1. A key that returns to the keyboard the person used before

### Answer

No. Apple's public API gives a keyboard extension only "go to the next keyboard" and "show the list". Nothing in the iOS 27.2 SDK headers or in Apple's current docs lets an extension switch to a named keyboard or to the previous one. What `advanceToNextInputMode()` does when the person arrived through the globe is not written anywhere I could read: GUESS that it moves to the next entry in the system's order and may or may not equal the previous keyboard; it needs a device test (below).

### Sources

- Apple, archived App Extension guide, "Updated: 2017-10-19", saved `ExtensibilityPG_CustomKeyboard.html` (https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html): to move on, call `advanceToNextInputMode`; the system picks the "appropriate next" keyboard from the enabled list, and "there is no API to obtain a list of enabled keyboards or for picking a particular keyboard to switch to". It also says to put the key near where the system's globe sits.
- Apple DTS, forum thread 854736, replies dated 2 Nov 2026 (saved in `forums_apple_read_2026-11-21.md`): quotes that same sentence and adds that DTS knows of no later public API; extension has only `advanceToNextInputMode()` and `handleInputModeList(from:with:)`. This is the current Apple statement and it post-dates iOS 27.1.
- Apple doc pages (JSON saved: `uikit_uiinputviewcontroller_advancetonextinputmode__.json`, `..._handleinputmodelist_from_with__.json`, `..._needsinputmodeswitchkey.json`; fetched 2026-11-21, pages carry no date):
  - `advanceToNextInputMode()`, iOS 8+: "Switches to the next keyboard in the list of user-enabled keyboards"; tapping the globe or a custom next-keyboard key makes the system pick the "appropriate" next keyboard. Same text on iOS 18, 26, 27: the page has no per-version notes.
  - `handleInputModeList(from:with:)`, iOS 10+: launch the list on long press or swipe up, advance on a tap.
  - `needsInputModeSwitchKey`, iOS 11+: true means the keyboard should provide the key.
- iPhoneOS 27.2 SDK headers (`sdk_headers_iOS27.2.txt`): `UIInputViewController` still has only `advanceToNextInputMode`, `handleInputModeListFromView:withEvent:`, `needsInputModeSwitchKey`, `dismissKeyboard`, `primaryLanguage`, `hasDictationKey`, `requestSupplementaryLexiconWithCompletion:`. No previous or specific-mode call. One related thing: `UITextDocumentProxy.documentInputMode` is the input mode the host app stored with its document, offered so a keyboard "can switch to the inputMode and set primaryLanguage if it supports it"; it only adapts the keyboard's own language, it does not change keyboards.
- Apple current doc "Creating a custom keyboard", copyright 2026 (`apple_creating-a-custom-keyboard.md`): put in a key that switches keyboards; the system keyboard uses a globe. On iPhones with Face ID iOS shows the globe below the keyboard and `needsInputModeSwitchKey` is false. Wire the key to `handleInputModeList(from:with:)` with `.allTouchEvents` so a long press shows the picker.
- Apple HIG "Virtual keyboards" (`hig_virtual-keyboards.json`, fetched 2026-11-21, undated): the system globe key replaces the dedicated Emoji key when several keyboards exist, and people expect a custom keyboard to switch as intuitively; on some devices the Emoji/Globe and Dictation keys appear under the keyboard even with custom keyboards, the app cannot affect them, and repeating them is confusing.

### needsInputModeSwitchKey without a Home button

- Face ID iPhones: false, because the system draws the globe under the keyboard (Apple doc above; DTS thread 849736, Oct 2026).
- iPhones without Face ID, including iPhone Duo: true, the keyboard must draw its own key, and DTS says skipping it will get the app rejected (849736, DTS Ziqiao Chen, Oct 2026, iOS 27.1 RC).
- iPads: the keyboard must draw its own key (comment in the Divvun keyboard, Apache-2.0, `code/divvun_giellakbd-ios--Keyboard_Models_SystemKeys.swift`, read 2026-11-21; a code comment, not Apple). UNSURE for iPad with a floating keyboard.
- Past bug: false inside non-X-optimised compatibility mode on iPhone X, so no globe at all; reported 2017-11, fixed in iOS 12 beta 1 (thread 92030).
- A key drawn when the property is true should be the only switch key; when false, Cutling's own "Next keyboard" button must be hidden. The shipping code already reads the property (`CutlingKeyboard/KeyboardViewController.swift` line 59, 256, 1127).

### What the system keyboard and the globe do (Apple, user guide)

- Apple Support, "Add or change keyboards on iPhone" (iOS 27 to 12 versions listed, undated; `apple_support_pages_2026-11-21.md`): to switch, touch and hold the globe or emoji key and tap the keyboard.
- Forum 766595 (Oct 2024, a developer's own finding, not Apple): with a hardware keyboard, pressing its globe key opens the list; pressing it again flips between the "two most recent keyboards". That is the system's own globe, not `advanceToNextInputMode` from an extension.

### How the keyboards you named label and place the key

| Keyboard | What the source says | Source, date | Saved |
|---|---|---|---|
| TextExpander | Globe key; "tap the globe key or keyboard switcher until the TextExpander keyboard appears"; switch away "with the globe key". No Next Keyboard or return-to-previous key named | textexpander.com setup page, last updated 2026-09-04 | `textexpander_setup_2026-11-21.md` |
| Raycast | Bottom row 123, Emoji, Globe, space, return. A secondary mode with no letter keys: the Globe key switches between Raycast and the usual keyboard, and a setting "Switch Keyboard on Close" moves to the next keyboard when a Raycast feature closes. Leading-button Keyboard returns from a panel to its own letter keys | manual.raycast.com/ios/keyboard.md, fetched 2026-11-21 (Last-Modified not given; Date header 2026-11-20) | `raycast_ios_keyboard.md` |
| SwiftKey | "Tap the globe icon to the left of the spacebar to navigate through your installed keyboards" | Microsoft support, undated | `swiftkey_switch.html` |
| Gboard | No Google iPhone page found that names the key: UNSURE | | |
| Snippety | No iOS help page found for the key (help/ios 404): UNSURE | | |

Take from Raycast: the one shipped keyboard that auto-leaves on close does it with "next keyboard", so a user with two keyboards gets the next one, not the previous. GUESS: it is `advanceToNextInputMode()`; no source states that.

### Other people's code (all read 2026-11-21)

- Every shipped open-source keyboard I found wires a globe to `handleInputModeList` and only shows it when `needsInputModeSwitchKey`: Hamster's KeyboardKit fork (MIT, `code/imfuxiao_Hamster--...KeyboardContext.swift`), KeyboardExtensionKit (MIT, `...KEGlobeButtonOverlay.swift`, forwards touch phases), Cantoboard (no licence, read only), Divvun. None implements a "previous keyboard" key.
- azooKey (MIT, `code/azooKey_azooKey--...QwertyLanguageSwitchKeyModel.swift`): its language key switches its own in-keyboard tab (Japanese/English), not iOS keyboards. That is the only route to "go back": put the other layout inside the same keyboard.
- GitHub code search for `previousInputMode`, "switch back to previous keyboard", `advanceToNextInputMode previous keyboard`: no keyboard repo. UNSURE for private or closed-source keyboards.
- Gap: whether `UITextInputMode.activeInputModes` or the `keyboardWillChangeFrame` + `UIWindowScene.textInputMode` trick (forum 706659, reply May 2023) can be read from inside the extension to learn which keyboard was active before: GUESS yes in a host app, UNSURE in an extension; no source.

### Any public way to switch to a specific keyboard

- No, from an extension (DTS, Nov 2026, above). In a host app's own text field a UIKit app can override `UIResponder.textInputMode` or `textInputContextIdentifier` to remember a mode (DTS, forum 794642, Jul 2025), which is for the app that owns the field, not for a keyboard.
- Private routes are out.

### What Cutling can do (design implication, GUESS)

1. Draw the system-like globe only when `needsInputModeSwitchKey`; wire it to `handleInputModeList` for tap = advance, hold = list.
2. For a fill-in screen with its own letters, label a leave key honestly: it leaves the fill-in view back to the cutling grid inside Cutling, which the app fully controls, and let the globe handle other keyboards. A key that claims "ABC" but jumps to some other keyboard would mislead (HIG: do not repeat or re-purpose system keys).
3. Device test owed on iOS 26 and 27: with keyboards A (Cutling) and B (another), enter Cutling from B via the globe, then call `advanceToNextInputMode()` from Cutling and record whether it lands on B or the next in Settings order, with two and with three keyboards, and with Emoji in the list.

## Q2. Custom keyboards and hardware keyboards

- Whether an extension shows with an external keyboard: iOS hides the virtual keyboard when an external keyboard is connected. DTS Ziqiao Chen, forum 777475, Mar 2025, marked Recommended: this is as designed; there is no API for a keyboard extension to show itself again, only the person using Show Keyboard from the shortcuts bar.
- What iPadOS shows instead: the Shortcuts bar (small bar at the bottom with shortcuts, a keyboard button, a mic). The forum 777475 poster describes it ("keyboard shortcut menu-item group with a keyboard button and a mic button"). Apple's iPad guide describes the bar and says the keyboard icon can switch language keyboards, emoji and the onscreen keyboard (page found by search, version 13 to 17 guides; not opened: UNSURE). In iOS 26 it "does not consistently appear" (forum 788019, Jun 2025, FB18105243; a reply in Sep 2026 says the problem continues on iPadOS 27).
- A person can still reach a custom keyboard: forum 766595 (Oct 2024, developer's finding, not Apple): the hardware keyboard's globe key opens the list, choosing the custom keyboard shows it on screen even though the hardware keyboard is connected; same on iPhone with a Bluetooth keyboard. The Apple user guide line "you can also switch between Magic Keyboard and other keyboards" is in `apple_support_pages_2026-11-21.md`.
- `pressesBegan`: a developer overrode it on a `UIInputViewController` subclass and it "doesn't seem to be called" (forum 650883, Jun 2020, 0 replies, no Apple answer). `UIKeyCommand` in an extension: asked Aug 2026 (forum 842928), no Apple answer. The iOS 27.2 `UIKeyCommand.h` and `UIPress.h` headers carry no extension-unavailable marker (header grep, `sdk_headers_iOS27.2.txt`), which does not say the events arrive. GUESS: hardware key presses go to the host app's text input, and the extension gets only what the host forwards through the proxy (inserted text, deletes); not verified.
- HIG "Virtual keyboards": a virtual keyboard "doesn't support keyboard shortcuts".
- Full Keyboard Access: no source found that covers a keyboard extension. Apple WWDC21 session 10120 (found by search, not opened: UNSURE) covers FKA for apps. GUESS: FKA moves focus among the extension's accessibility elements when the extension is on screen, but with a hardware keyboard attached the extension is usually hidden (above), so the case is narrow.
- What this means for fill-ins: for a person typing on a hardware keyboard the system keyboard is hidden, so Cutling's whole keyboard is not on screen. A fill-in that needs typing there cannot be inside the keyboard at all. GUESS: the only route for that person is to type the value into the host field with the hardware keys, which is the uncommitted `FillInPanel.swift` idea in `cutling-pains.md`, and to reach Cutling by the globe key. Device test owed: iPad + Magic Keyboard + globe, then tap a cutling with a fill-in.

## Q3. VoiceOver and other accessibility settings in an extension

- Trait: Apple lists `.keyboardKey` as "The accessibility element behaves like a keyboard key" (`uikit_uiaccessibilitytraits_keyboardkey.json`, fetched 2026-11-21). In SwiftUI it is `.accessibilityAddTraits(.isKeyboardKey)`; a shipped keyboard does that on its keys: Parley, Apache-2.0, `code/pathorsAI_parley--ios_Keyboard_KeyboardVoicePane.swift` (commit 909a101, repo pushed 2026-11-19) and its Reduce Motion handling in the same file.
- Typing modes: Apple Support 111796, published 2025-03-20 (`apple_support_pages_2026-11-21.md`): Typing Mode on the VoiceOver rotor switches between Standard Typing, Touch Typing and Direct Touch typing, and appears on the rotor only when a keyboard is present; the Typing Style can also be set in Settings. Descriptions of what each mode does come from the search summary, not the page text: GUESS (standard = focus then double-tap; touch typing = lift to type; direct touch = VoiceOver off for the keyboard).
- What a custom keyboard gets in each mode, from the developer of a shipped low-vision keyboard (AppleVis, 2026-09-02, `applevis_bigkeys_2026-09-02.md`; a developer's claim, not Apple): every key has a label and the keyboard-key trait, which makes keys eligible for Touch Typing; Touch Typing and Standard typing both work; the keyboard's own gesture recogniser never sees the touches under VoiceOver; long press never fires, so alternates must be rotor actions; keys drawn as plain shapes expose no accessibility elements unless the developer adds them; he guards this with Apple's accessibility audit in tests; he mutes his own key speech while VoiceOver runs.
- Announcing state: `UIAccessibilityPostNotification` and the screen-changed and announcement constants carry no extension-unavailable marker in the iOS 27.2 headers (`sdk_headers_iOS27.2.txt`). A keyboard developer posted an announcement notification from an extension to speak the deleted character, with the character read from `documentContextBeforeInput` (forum 76508, May 2017, a developer's solution); BigKeys posts word announcements at low priority (AppleVis, 2026-09-02). So it works from an extension, per two developers. Whether `.screenChanged` moves VoiceOver focus into the new view of an extension: no source; GUESS it works as in an app, test owed.
- Behaviour of a delete in Touch Typing: VoiceOver says what the system keyboard says only if the keyboard announces it (forum 76508, 2017).
- Dynamic Type: no Apple source on a keyboard's fixed height. Apple's current doc says the system sizes a keyboard to match the system keyboard by screen size and orientation and the width is always the system's (`apple_configuring-a-custom-keyboard-interface.md`, 2026). GUESS: a large type size must not grow the keys; the system keyboard does not scale with Dynamic Type either, so use VoiceOver and a larger key hit area, not text growth, and clamp type with `.dynamicTypeSize(...)` (Parley clamps one pane to xxLarge, `ios/App/Parley/LiveView.swift` line 750, not the keyboard).
- Reduce Motion, Increase Contrast, Switch Control: no Apple page found tying them to extensions. Parley's keyboard reads `accessibilityReduceMotion` (above). GUESS: these environment values and `UIAccessibility.isReduceMotionEnabled` are readable in the extension process as in an app. Switch Control: Apple says VoiceOver and Switch Control draw on the same accessibility information (a WebAIM post, found by search, not opened: UNSURE); GUESS that an element exposed for VoiceOver is reachable by Switch Control too.
- HIG: "Virtual keyboards" has no accessibility section and nothing on custom-keyboard accessibility beyond the keyboard sound ("play the standard keyboard sound", `hig_virtual-keyboards.json`). The HIG accessibility page was not read: UNSURE.

## Q4. Changing the keyboard's height while it shows

- Documented way: adjust the height constraint on the `UIInputViewController`'s view. Current Apple doc, copyright 2026 (`apple_configuring-a-custom-keyboard-interface.md`): by default the system sizes the keyboard to match the system keyboard; width is always the system's; "to change a keyboard's height, adjust the height constraints on the UIInputViewController's view". Archived guide (2017-10-19): the sample adds an equal-height constraint to `self.view`, and "In iOS 8.0, you can adjust a custom keyboard's height any time after its primary view initially draws on screen."
- So a height change after first draw is documented, which fits showing a letter keyboard plus a fill-in bar by raising the constraint. No Apple page says anything about animation; the animation of a later change: GUESS wrap the constraint change in `UIView.animate` with `view.superview?.layoutIfNeeded()`; not sourced.
- Known glitches, all forum, all developer reports:
  - Launch flicker, forum 813579 (Jan 2026, replies to Oct 2026): view frames go 0x0, then full screen (956 pt), then 452 pt, then the constraint's 268 pt, over about 390 ms, on iOS 17, 18 and 26.2, simulator and device. intrinsicContentSize, `allowsSelfSizing`, `preferredContentSize` and frame overrides were ignored. Reply bodies not shown in the page text: UNREAD.
  - Grows each time on iPad, forum 738465 (Sep to Dec 2023): the keyboard gets taller every switch back. A search summary says replacing the old height constraint in `viewWillAppear` fixed it; I did not see that in the page text: UNSURE.
  - iOS 27 betas 1 to 6, forum 843093 (Aug to Oct 2026, FB24460699): after leaving the host app and returning with the field still focused the host sees the keyboard frame 17 pt taller, extension bounds unchanged. 9 replies UNREAD.
  - Forum 799003 (Sep 2025 to May 2026) has a DTS reply the page did not show: UNREAD.
- Cutling's own code: `grep` found no `heightAnchor` or height constraint in `CutlingKeyboard/KeyboardViewController.swift` (one `NSLayoutConstraint.activate` at line 347); it relies on the system height today.
- Implication (GUESS): a fill-in that grows the keyboard re-lays the host's screen (the host scrolls the field above the keyboard); a change that keeps the same height and swaps the grid for the fill-in bar avoids both the launch glitch path and host scroll jumps. Device test owed on iOS 26 and 27.

## Q5. Drawing letter keys to fill a blank

### How it routes (read in code, all 2026-11-21)

- Insert and delete go through `textDocumentProxy.insertText` / `deleteBackward`; cursor moves through `adjustTextPosition(byCharacterOffset:)` (Apple current doc `apple_handling-text-interactions-in-custom-keyboards.md`, 2026). The proxy is swapped for a keyboard-owned field in KeyboardKit 7.9.8 (MIT, tag commit `bc8949cd`) as recorded in `cutling-pains.md` Q3: unchanged here.
- A label route (not a text field): keyboard-owned `UILabel` or SwiftUI `Text` with its own caret and a plain string buffer: keys append to the buffer instead of calling the proxy; the stack answer (q 27935625, 2015) and the 34420344 fake-cursor answer are in Q3 of `cutling-pains.md`. Apple's docs say nothing about this route: GUESS it needs no API.
- Marked text: `setMarkedText(_:selectedRange:)` and `unmarkText()` exist on the proxy (iOS 13+, SDK header). GUESS: a fill-in could show the value as marked text in the host field while it is typed so the host sees it live; not verified, and web fields may differ (Q3 in `cutling-pains.md`).

### What is lost against the system keyboard

- Autocorrect and suggestions: Apple says a keyboard gets `UILexicon` via `requestSupplementaryLexicon(completion:)` with the person's text shortcuts, contact names and a common-words list, "a supplement" to the keyboard's own (`uikit_uiinputviewcontroller_requestsupplementarylexicon_completion__.json`, fetched 2026-11-21; current doc says the same in `apple_configuring-a-custom-keyboard-interface.md`). Available with Full Access off (`apple_configuring-open-access-for-a-custom-keyboard.md`: "Access to a common words lexicon" and the shortcuts list are in the no-open-access list).
- UITextChecker in an extension: the iOS 27.2 header has no extension-unavailable marker (`sdk_headers_iOS27.2.txt`), and shipped keyboards call it: SnipKey (extension target `SnipKeyboard`; what it does beyond typing not read) (MIT, `code/jtvargas_SnipKey--SnipKeyboard_QWERTY_PredictiveTextEngine.swift`, pushed 2026-10-18) calls `completions(forPartialWordRange:in:language:)` and `guesses(forWordRange:in:language:)`; Vocaphone (AGPL, read only, `code/VocaHQ_vocaphone--ios_VocaPhoneKeyboard_SpellChecking.swift`, pushed 2026-11-16) says it is main-actor, costs "50 to 135 ms per new prefix" on its measurements, and that it loads the user's dictionaries so it is built on first use because a keyboard extension is killed at about 45 to 60 MB. So yes it works; the cost is memory and main-thread time (the developer's measurements, not Apple's). Cutling's own limit notes: `docs/research/keyboard-memory-limits.md`. iOS 27 adds grammar-check methods to `UITextChecker` (header, iOS 27.0+): not needed here.
- Parley (Apache-2.0, `code/pathorsAI_parley--ios_Keyboard_KeyboardSystemLexicon.swift`) reads only text shortcuts out of the lexicon and drops contact names before copying; useful as a privacy pattern.
- Dictation: Apple's docs: with open access off or on, "no access to microphone and speaker" (current doc, 2026) and the archived guide's "no access to the device microphone, so dictation input is not possible". DTS Travis, forum 854736, Nov 2026: knows of no public API for an extension to start dictation; suggests dictating in the containing app or switching to the system keyboard. On iPhone Duo with iOS 27.1 the system dictation button is inside the system keyboard, so it is unavailable with a custom keyboard; elsewhere it sits outside the keyboard and stays available. `hasDictationKey = true` hides the system's own dictation button ("iOS won't show the system button", current doc) and so should stay false for Cutling. Full Access does not unlock the microphone (forum 821235, Apr 2026; forum 775077, Feb 2025, error 561145187). Launching the app for dictation is the 4.4.1 problem (forum 843118, Aug 2026, no answer).
- Other languages: the system keyboard switches language; a custom layout is one `primaryLanguage` (BCP 47, current doc `uikit_uiinputviewcontroller_primarylanguage.json`) plus whatever layouts the developer ships. Raycast's keyboard ships English plus nine downloadable languages and says to use its Secondary Mode (no letters) for anything else (`raycast_ios_keyboard.md`, fetched 2026-11-21); Snippety is English-only (Q3 in `cutling-pains.md`). GUESS: a Cutling letter set for the fill-in would cover latin layouts at most, and a person typing Arabic, Thai, CJK or emoji needs the host field and their own keyboard.
- Not in a keyboard-owned label at all: text selection, the magnifier cursor, the edit menu, spell-check underlines, QuickType (all system keyboard features; Apple's list of what a keyboard cannot do is in the archived guide, per Q3).

### Cutling design implication (GUESS)

- Typing in the keyboard costs a layout per language and loses dictation, which is why a person who dictates or types in another script would need the host field route.
- The two routes are not exclusive: one-tap chips for saved values and the clipboard (ClipKeyboard) for no-typing fills; a small Latin letter row for short values; "type it in the field instead" as the way out. This is the owner's call; not decided here.

## Shipped keyboards read, with licence (for the card's "code to copy" column)

| Project | Licence | Used for | Note |
|---|---|---|---|
| KeyboardKit 7.9.8 | MIT (tag) | proxy swap | closed source since; see Q3 in cutling-pains.md |
| Hamster / HamsterKeyboardKit | MIT | globe + `handleInputModeList` | 1645 stars, last push 2025-05-13 |
| KeyboardExtensionKit | MIT | globe button overlay | last push 2023-09-02, 8 stars |
| azooKey | MIT | in-keyboard language tab | 812 stars, pushed 2026-11-14 |
| Divvun giellakbd-ios | Apache-2.0 | bottom-row logic by `needsInputModeSwitchKey` | 61 stars, pushed 2026-11-20 |
| Parley | Apache-2.0 | `.isKeyboardKey`, reduce motion, lexicon filter | 28 stars, pushed 2026-11-19 |
| SnipKey | MIT | UITextChecker in a keyboard extension | 24 stars, pushed 2026-10-18 |
| Vocaphone | AGPL-3.0 | UITextChecker cost notes | read only, do not copy |
| Cantoboard | none | `handleInputModeList` | read only |

## Open items needing a device

1. Does `advanceToNextInputMode()` return to the previous keyboard (Q1)? iOS 26 and 27, two and three keyboards, with Emoji enabled.
2. Hardware keyboard on iPad and iPhone: is the extension's `pressesBegan` ever called, and what does the globe key show (Q2)?
3. `.screenChanged` / `.announcement` from the extension under VoiceOver in Touch Typing; Switch Control reach; Reduce Motion and Increase Contrast values readable (Q3).
4. Height change after first draw on iOS 26 and 27: smoothness, host scroll jump, the 17 pt gap (Q4).
