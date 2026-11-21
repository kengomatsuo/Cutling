# Fill-ins and date stamps

A text cutling can hold placeholders in braces, the way Raycast and Alfred write theirs, so a snippet copied from either works as it is. They are replaced each time the cutling is typed, copied or pasted. Research behind every choice: [research/cutling-pains.md](research/cutling-pains.md).

**On in builds since 2026-11-21** (the owner approved the redesigned keyboard screen). `FillIns.isOn` (`Cutling/FillIn.swift`) is false only when the App Group key `fillInsOff` is set, which only the `-FILLIN_OFF` test seed does; then every path types, copies and pastes braces as written and the editor has no fill-in menu. The site and AI files still say "not yet" until the release is live (`web/_generator/live.py`).

## Syntax (`Cutling/Placeholders.swift`)

| Write | Becomes |
|---|---|
| `{date}` `{time}` `{datetime}` `{day}` | today's date, the time, both, the weekday, in the user's language and region |
| `{date:short}` `:medium` `:long` `:full` | that system style |
| `{date:yyyy-MM-dd}` | a Unicode (ICU) pattern, Gregorian year, as Raycast, Alfred and Snippety take |
| `{date +3d}` `{date -1w}` `{time +30m}` `{date +1M +2d:long}` | date math: `m` minutes, `h` hours, `d` days, `w` weeks, `M` months, `y` years (Raycast's and Alfred's letters, `m`/`M` case-sensitive like theirs; `min` and `mo` also work) |
| `{Name}` | a blank the user fills; any label of letters, digits and spaces touching both braces |
| `{City: Jakarta}` | a blank with a default |
| `{Plan: Basic \| Pro \| Team}` | a blank with choices; the first is the default |
| `{cursor}` | where the cursor lands after typing (first one only) |
| `{clipboard}` | the clipboard's text when used |
| `{argument name="Tone" default="warm" options="warm, formal"}`, `{date format="yyyy-MM-dd" offset="+2d" locale="fr-FR"}` | Raycast's own forms |
| `\{date}` | literal braces |

Blanks with the same label (ignoring case) are filled once and repeat. Braces that are not a known word or a label, such as `{ return x }`, JSON or anything spanning lines, stay text. **Code cutlings are typed byte for byte and carry no placeholders.** Formatted cutlings keep their formatting; inserted values are Markdown-escaped (`Cutling.filled(_:)` in `Cutling/FillIn.swift`).

## Where they are replaced

Every path that uses a cutling takes `Cutling.filled(_:)`'s copy:

- **iPhone and iPad keyboard** (`CutlingKeyboard/FillInPanel.swift`, `KeyboardViewController.use`): stamps and the clipboard are typed at once. A cutling with blanks types nothing yet: the top bar shows its sentence with the waiting blank in green, and the grid offers Type with Your Keyboard, the blank's choices, values used before (five per label) and Paste. Cutling draws no letter keys (one keyboard cannot cover every language), so a value is typed on the person's own keyboard, either before tapping the cutling (the word before the cursor, one trailing space allowed, fills the first blank; a choice only takes one of its options) or after Type with Your Keyboard, coming back with the globe key (what was typed after the cursor's spot when they left fills the waiting blank). The return key reads Next (arrow), then Insert (checkmark) on the last blank; empty blanks take their default. On Insert, what the person typed for the blanks is deleted, if the text before the cursor still ends with it, and the finished text goes in with smart spacing; `{cursor}` moves the cursor back with `adjustTextPosition` (UTF-16 count). ✕ cancels and leaves what was typed. Screens change at once and keys press with the keyboard's flat highlight, as Apple's keyboard does ([research/fill-ins-press-feedback.md](research/fill-ins-press-feedback.md), [research/fill-ins-type-first.md](research/fill-ins-type-first.md)); VoiceOver hears each blank announced. The session survives keyboard switches (`FillSession`, 15 minutes, App Group).
- **App (iPhone, iPad, Mac window)**: tapping a card with blanks opens `FillInForm` as a sheet (fields, saved values as chips, live preview), then copies. Without blanks the card copies at once with stamps filled.
- **Mac picker (⌘⇧V)**: a cutling with blanks swaps the list for `FillInForm`; Return pastes. With direct paste on, `{cursor}` is placed by pressing ← once per character after it, as Espanso and Snippety do. History items paste exactly as copied.
- **Shortcuts** (Copy Cutling, Get Cutling Text): stamps are filled; blanks stay as written so a shortcut can replace them.
- Share, drag and Spotlight keep the template as written.

Saved values live in the App Group (`FillInMemory`, key `fillInRecentValues`, five per label, values up to 200 characters), on the device only, never synced.

## Tests

`Tests/Placeholders/run.sh` (engine: syntax, dates in several locales, offsets, fields, Markdown, cursor, Raycast forms). `CutlingUITests/FillInUITests.swift` drives the keyboard panel on the simulator.
