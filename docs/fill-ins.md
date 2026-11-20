# Fill-ins and date stamps

A text cutling can hold placeholders in braces, the way Raycast and Alfred write theirs, so a snippet copied from either works as it is. They are replaced each time the cutling is typed, copied or pasted. Research behind every choice: [research/cutling-pains.md](research/cutling-pains.md).

**Off in every build for now.** `FillIns.isOn` (`Cutling/FillIn.swift`, App Group key `fillInsOn`) is false unless the `-FILLIN_TEST` seed sets it, because the owner has not approved the screens below; they are being redesigned to look like Apple's default keyboard (board cards ASG84 to ASG91). While it is off, every path types, copies and pastes braces as written, the editor has no fill-in menu, and What's New, the site (`web/_generator/live.py`) and the store listing say nothing about fill-ins.

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

- **iPhone and iPad keyboard** (`CutlingKeyboard/FillInPanel.swift`, `KeyboardViewController.use`): stamps and the clipboard are typed at once. At a blank, Cutling stops and the grid becomes a panel with the blank's label. The user either taps a value (the clipboard, a choice, or one of the last five values used for that label), or switches to their own keyboard with the globe key, types the value straight into the app's field, comes back and taps Next; the last blank says Done. A keyboard extension cannot raise the system keyboard for a text field of its own, so typing happens in the host app's field: any language, autocorrect and dictation work, unlike Snippety's built-in English-only letter keys. The session survives keyboard switches (`FillSession`, 15 minutes, extension's own defaults). Next learns what was typed from the text before the cursor, remembers it, and drops a trailing space before punctuation. `{cursor}` moves the cursor back with `adjustTextPosition` (UTF-16 count) once everything is typed.
- **App (iPhone, iPad, Mac window)**: tapping a card with blanks opens `FillInForm` as a sheet (fields, saved values as chips, live preview), then copies. Without blanks the card copies at once with stamps filled.
- **Mac picker (⌘⇧V)**: a cutling with blanks swaps the list for `FillInForm`; Return pastes. With direct paste on, `{cursor}` is placed by pressing ← once per character after it, as Espanso and Snippety do. History items paste exactly as copied.
- **Shortcuts** (Copy Cutling, Get Cutling Text): stamps are filled; blanks stay as written so a shortcut can replace them.
- Share, drag and Spotlight keep the template as written.

Saved values live in the App Group (`FillInMemory`, key `fillInRecentValues`, five per label, values up to 200 characters), on the device only, never synced.

## Tests

`Tests/Placeholders/run.sh` (engine: syntax, dates in several locales, offsets, fields, Markdown, cursor, Raycast forms). `CutlingUITests/FillInUITests.swift` drives the keyboard panel on the simulator.
