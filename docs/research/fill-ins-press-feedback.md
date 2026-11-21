# Apple keyboard press feedback: what Cutling should copy

Cards ASG100 / ASG101. Written 2026-11-21. Every source is saved under `docs/research/fill-ins-press-feedback/` (table in `fill-ins-press-feedback/notes.md`). GUESS = not read from a source. UNSURE = a source was seen but does not settle it.

## What was not done, and why it matters

- **No frame of Apple's own keyboard was read.** The way to get Apple's real press colours and timings is to run the iOS 27.2 simulator, tap-and-hold a key and record. The simulators are on the shared device queue (a hook refused a boot of a third device while other sessions hold two); the queue showed 3 waiting at about 6 minutes each, and the only input route (synthetic mouse events on the Simulator window) would also move the owner's pointer. Not run. No Apple support video was downloaded either (a download needs the owner's yes).
- So every Apple colour and timing below is GUESS or comes from a third-party imitation, and each says so. The Apple-primary findings are about the public APIs and Settings, not about pixels.
- Not read: Fleksy, Hamster (not opened). Gboard iOS and the Raycast keyboard have no page that describes a tap response.
- Nothing here was run on a device: haptics cannot be felt in a simulator anyway.

## Cutling today (read from `CutlingKeyboard/KeyboardViewController.swift`, 2026-11-21)

- `InstantPress` and `KeyboardButtonStyle`: highlight appears on touch down with no animation (InstantPress fill 0.25 black / 0.3 white; ButtonStyle 0.12 black / 0.18 white), `UIImpactFeedbackGenerator(.light)` plus `AudioServicesPlaySystemSound` fire on touch down.
- `KeyboardSound` plays ids 1123 / 1155 / 1156 with `AudioServicesPlaySystemSound` directly. `AudioFeedbackInputView` (adopts `UIInputViewAudioFeedback`) exists but nothing calls `playInputClick()`. So the click ignores the user's Keyboard Feedback > Sound switch (see Q2).
- `CutlingKeyView`: on insert `isCopied` shows `.ultraThinMaterial`, a checkmark label ("Inserted") with `.scale(0.85)` + opacity, inside `.animation(.spring(duration: 0.35, bounce: 0.2))`; `isExisted` adds a green glow and `scaleEffect(1.025)` with `.spring(duration: 0.4, bounce: 0.5)`.

## Q1. What Apple's keyboard does on press

Short answer: **no source I could read states it.** Apple's docs describe no key visuals. What exists is imitation code.

- Apple HIG "Virtual keyboards" (`fill-ins-keyboard-apis-sources/hig_virtual-keyboards.json`, fetched 2026-11-21, undated) and Apple "Creating a custom keyboard" (2026) say nothing about key press colour, callout or timing. Not a source for Q1.
- KeyboardKit 9.0.0 (MIT, `code/kk9_StandardStyleService.swift`, repo pushed 2026-11-16): an author's imitation of Apple's keys, not Apple. Pressed state swaps the fill with no animation: a character key goes to the "dark" key colour; a system key (shift, delete, 123, return-like) goes to the character-key colour (white in light mode, the lighter grey in dark mode); the primary (return) key goes from blue to white in light mode and to the dark key colour in dark mode; idle opacity is 0.95 in light, 1 in dark and when pressed. The input callout draws only when `deviceTypeForKeyboard == .phone` (`Callouts/Views/KeyboardCallout+InputCallout.swift` line 82), so none on iPad, matching the brief. This repeats the well-known look of the old iOS keyboard; GUESS that iOS 26/27 still does the same colour swap.
- azooKey (MIT, pushed 2026-11-14, `code/azookey_*`): pressed fill is a flat swap, `isPressed = true` on touch down and false on touch up, with no animation modifier on the key background (`SimpleKeyView.swift` lines 62-96, read from a clone at commit 0b19111). Its colour assets: light pressed key about (0.929, 0.929, 0.945) in P3, dark pressed system key about `#2C2C2E`-ish (HighlightedKeyColor dark 0.169/0.173/0.180). These are the author's approximations of Apple, not measurements. GUESS-grade.
- Timing: azooKey's source comment says firing feedback on touch down "feels more responsive" (`azookey_KeyboardFeedback.swift`, comments on `click()`), and both azooKey and KeyboardKit insert on touch-up. Whether Apple's own key highlight lasts a set time after release: no source. GUESS: it clears on release.
- Scale: no source says an Apple key scales. GUESS: no scale on the key itself; the pop-up callout is a separate layer on iPhone letter keys only.
- Liquid Glass (iOS 26): I found no Apple or press source describing a key-press change. Search returned third-party notes that the keyboard was redrawn for Liquid Glass and that 26.1 reduced the glow on glass controls (Cult of Mac, listed in the search, not opened or saved: UNSURE). Do not copy any glass or glow on keys.
- Predictive bar suggestions, emoji cells: no source for their press colour. GUESS: the same flat highlight, no scale.

## Q2. Haptics and sound

- Apple Support HT213404 / 102463, "Change iPhone keyboard sounds or haptics", published 2026-05-27, read in Chrome (`apple_support_102463.txt`): iOS 16 or later, Settings > Sounds & Haptics > Keyboard Feedback has separate Sound and Haptic switches; haptics need Settings > Accessibility > Touch > Vibration on; haptics might affect battery.
- `UIDevice.playInputClick()` (Apple doc JSON saved `uikit_uidevice_playinputclick__.json`, fetched 2026-11-21): plays the standard click "only if the user has enabled keyboard clicks in Settings > Sounds" and only if the input view adopts `UIInputViewAudioFeedback` and returns true from `enableInputClicksWhenVisible`; the protocol page says adoption is "optional but expected". The doc names the old Sounds path, not Keyboard Feedback > Sound: UNSURE whether the iOS 16+ switch is the one it reads (GUESS: yes, it is the same preference).
- Full Access and the click: the archived Apple App Extension guide (2017-10-19, `../fill-ins-keyboard-apis-sources/ExtensibilityPG_CustomKeyboard.html`) lists "Ability to play audio, including keyboard clicks using the playInputClick method" under the capabilities that `RequestsOpenAccess` unlocks. The current Apple page (`apple_configuring-open-access-for-a-custom-keyboard.md`, 2026) lists "No access to microphone and speaker" without Full Access and does not mention clicks.
- Haptic APIs: `UIImpactFeedbackGenerator` (styles; `impactOccurred(intensity:)`), `UISelectionFeedbackGenerator`, SwiftUI `sensoryFeedback(_:trigger:)` (Apple JSON saved). Apple's own text: selection feedback is for "movement through a series of discrete values", impact for a collision or snap. No Apple page says which one the system keyboard uses: GUESS.
- Does a keyboard need Full Access for haptics? Apple does not say (the open-access page does not list haptics). KeyboardKit 9.0.0 README line 204 says Full Access must be enabled "for some features to work, like haptic feedback" (`code/kk9_README.md`), and azooKey gates haptics on `hasFullAccess` and `CHHapticEngine.capabilitiesForHardware().supportsHaptics` (`azookey_KeyboardFeedback.swift`, `azookey_SemiStaticStates.swift`). That is two shipped keyboards behaving as if yes; no Apple statement: UNSURE. Needs a device test with Full Access off.
- Can a keyboard read the system Keyboard Feedback switches? Raycast's keyboard manual (`../fill-ins-keyboard-apis-sources/raycast_ios_keyboard.md` line 270, fetched 2026-11-21) says its Key Haptic Feedback (Off, Soft, Medium, Hard) is "Soft by default if keyboard haptics are on in iOS Settings, otherwise Off", so a shipped keyboard claims to default from the system Haptic switch; how it reads it is not stated (UNSURE; GUESS: an undocumented read). Its keyboard also offers Character Preview None/Detached/Attached and a Key Sound switch. Apart from that, no public API found in the docs I fetched, and no forum answer (Apple forum 710612, Jul 2022, a developer asks for the keyboard click sound id and gets no reply; `developer_apple_com_forums_thread_710612.txt`). GUESS: no documented read. So a custom keyboard cannot rely on honouring the Haptic switch without a device test (Raycast suggests it can be done); it can honour the Sound one only by using `playInputClick`, which the system filters.
- What the shipped keyboards do:
  - KeyboardKit 9.0.0 (MIT): `HapticConfiguration` defaults press = `.selectionChanged`, release = `.selectionChanged`, long press = `.mediumImpact`, repeat = `.selectionChanged`; audio ids input 1104, delete 1155, system 1156 through `AudioServicesPlaySystemSound`; its own settings default to audio on and haptics off (`code/kk9_*`).
  - azooKey (MIT): `UIImpactFeedbackGenerator(.light)` at intensity 0.7 for letters, 0.75 for delete and special keys, 0.8 for clear-all; sound 1104 / 1156 / 1155; both gated by the app's own switches; fires on touch down.
  - Cutling uses sound 1123 for letters; KeyboardKit and azooKey both use 1104 for letters. Whether 1123 is a click at all is UNSURE (no Apple list read).
- HIG "Playing haptics" (`hig_playing-haptics.json`, fetched 2026-11-21): use system patterns as documented, complement visual feedback with matching intensity, avoid overuse, and make haptics optional.

## Q3. Layout changes (ABC / 123 / emoji / search, predictive bar)

No Apple source describes the animation. GUESS (from memory of using the keyboard, not a source): the key rows swap instantly and the bar contents change without a transition. Code evidence only on imitations: KeyboardKit 9.0.0 swaps layouts with no transition in its keyboard view (only `isSpaceDragGestureActive` and dictation use `withAnimation`; grep read 2026-11-21); azooKey animates only its own candidate bar (`ResultBar.swift` easeIn 0.2 on the bar showing or hiding). Neither proves Apple. Needs a recording.

## Q4. What a snippet or clipboard keyboard shows on insert

- iOS 27 paste suggestion in the QuickType bar: MacRumors 2026-07-01 and Paste blog 2026-07-14 (saved `macrumors_ios27_paste.html`, `paste_ios27_keyboard_paste.html`) both say tapping it drops the content into the field, and neither mentions any confirmation, animation or haptic. Absence in a news article is not proof: UNSURE; GUESS that Apple shows only the pressed state and the text appearing.
- Gboard clipboard help page (`gboard_clipboard_help.html`, fetched 2026-11-21, Android wording): tap the Clipboard icon, tap the item; no confirmation described. Not iOS.
- Raycast iOS keyboard manual (`../fill-ins-keyboard-apis-sources/raycast_ios_keyboard.md`, 2026-11-21): tap a snippet or recent to insert; the page describes no confirmation either.
- Paste's own keyboard: UNSURE, no page opened.
- Emoji recents: no source read.
- The text appearing in the field is itself the confirmation in every case above. Cutling's material plus checkmark has no counterpart in anything I could read.

## What Cutling should do

1. Delete the material overlay, checkmark label, `.scale(0.85)` transition and the `isCopied` spring on a text snippet. On tap show only the key press state, then the text lands in the field. Ties to Q4 (no source shows any other confirmation) and to the owner's rejection of spring and scale.
2. Keep the press highlight a flat colour swap on touch down, cleared on release, with no animation (Q1: both imitations do this; the Apple behaviour itself is a GUESS). Cutling's `KeyboardButtonStyle` already does this; the springs on `isCopied` and `isExisted` (scale 1.025, bounce 0.5) are the part to remove.
3. Fire haptic and click on touch down, insert on touch up (Q1/Q2, azooKey comment and code). Already so in `InstantPress`.
4. Replace `AudioServicesPlaySystemSound` with `UIDevice.current.playInputClick()` through the existing `AudioFeedbackInputView`, so the system's own switch decides whether it clicks (Q2, Apple doc). Verify on a device that it sounds with Full Access on and off.
5. Gate haptics on `hasFullAccess` and offer an in-app Haptics switch, default on only when Full Access is granted, because no documented API reads the system Haptic switch (Q2: none found; KeyboardKit and azooKey use their own switch; Raycast claims to default from the system one, method unknown). Device test needed for the Full Access claim.
6. Haptic style: keep `.light` impact (matches azooKey, 0.7 intensity for letter-like taps) or move to `UISelectionFeedbackGenerator` as KeyboardKit does; both are third-party choices, neither is Apple's (Q2). Owner picks by feel on a device.
7. Swap layouts and bar contents with no transition (Q3, GUESS).
8. To close the gaps above: record Apple's keyboard in the simulator once a device-queue ticket is free, at 60 fps, light and dark, and extract frames into `docs/research/fill-ins-press-feedback/`.
