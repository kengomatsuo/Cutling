# Fill-ins: flow plan (board ASG85)

Every step from tapping a cutling to the finished text, per surface, for the two keyboard designs the owner is choosing between (ASG86, mocks in `CutlingKeyboard/FillInMocks.swift`). Sources: competitor and Apple screens in [research/fill-ins-design/README.md](research/fill-ins-design/README.md); platform limits in [research/fill-ins-keyboard-apis.md](research/fill-ins-keyboard-apis.md). Sample cutling: `Hi {Name}, your {Plan: Basic | Pro} order ships {date}.{cursor} Thanks!`

## iPhone and iPad keyboard

| Step | Design "keys" (Apple letter keys in Cutling) | Design "abc" (emoji keyboard's ABC pattern) |
|---|---|---|
| 0. Grid | Cutling's grid; bottom row ABC, delete, space, return. ABC goes back to the person's keyboard (ASG87). | Same. |
| 1. Tap a cutling without blanks | Typed at once, dates filled. | Same. |
| 2. Tap a cutling with blanks | Nothing is typed yet. The grid becomes Apple's letter keyboard; the top strip shows the whole sentence with blank 1 as a green pill, "1 of 2", and ✕. | Cutling types up to blank 1 and waits. The top strip, where the emoji keyboard's search field sits, shows the sentence with blank 1 as a pill; below, saved values and Paste as keys. |
| 3. Fill a typed blank | Type on Cutling's keys; the predictive bar offers saved values ("Sarah", "Sam") and the typed word. | Tap a saved value, or tap ABC, type on the person's own keyboard (any language, dictation, autocorrect), tap the globe back to Cutling. |
| 4. Move on | Return key reads Next. | Return key reads Next; Cutling reads what was typed before the cursor. |
| 5. Fill a choice | Predictive bar shows the choices; letters stay for a value not in the list. | The choices as keys, the default ticked. |
| 6. Finish | Return key reads Insert on the last blank; the whole text is typed in one go and the cursor lands at `{cursor}`. | Return key reads Insert; the rest is typed and the cursor lands at `{cursor}`. |
| Cancel | ✕: nothing was typed, so nothing to undo. | ✕: what was typed stays; the rest is dropped. |
| VoiceOver | Letter keys carry the keyboard-key trait, so Touch Typing works; the strip reads as one line ("Hi, Name, blank 1 of 2"); each new blank is announced. | Value keys are buttons; ABC reads "Back to your keyboard"; typing happens in the person's own keyboard, which VoiceOver already knows. |
| Hardware keyboard on iPad | iOS hides custom keyboards while a hardware keyboard is attached, and a keyboard extension gets no key presses (research Q2), so the blank can only be filled by tapping a suggestion. | The blank is typed straight into the app's field with the hardware keyboard. |
| Languages | Cutling's keys cover Latin letters; other scripts and dictation need a fallback (Raycast ships 10 languages, Snippety English only). | Every language the person's keyboard has. |

## App (iPhone, iPad, Mac window)

Tap a card with blanks: a sheet asks for each blank (saved values as chips, choices as a picker, a live preview), then Copy. Return moves to the next field; on Mac, Tab and Return work and Escape cancels.

## Mac picker (⌘⇧V)

Pick a cutling with blanks: the list becomes a form in the same panel. Tab moves between blanks, Return pastes (or copies when direct paste is off), Escape goes back to the list. Everything works without a mouse.

## Open checks before the rebuild

- Where Cutling's globe sends the person (`KeyboardSwitchUITests`): if `advanceToNextInputMode()` returns to the keyboard used before, ABC means "back"; if it moves on in Settings' order, ABC means "next keyboard" and says so.
- VoiceOver announcements from the extension, and a smooth height change, on iOS 26 and 27 (research Q3, Q4).
