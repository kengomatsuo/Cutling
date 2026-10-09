# Formatting, plain text and code in text cutlings

Status: built 2026-10-02 (phases 1–5). Formats sync between devices only after the CloudKit schema deploy described under Data and sync.

## The decision in one paragraph

Every text cutling gets a **format**: Plain (the default, and what every existing cutling becomes), Rich, or Code. Plain behaves exactly as today. Rich stores a small Markdown subset (bold, italic, strikethrough, inline code, links) in the same `value` string, shows it styled, and writes plain + RTF + HTML to the pasteboard on copy so the destination picks what it can show. Code is shown in monospace, never interpreted as Markdown, never re-spaced or trimmed, and edited with smart quotes off. The keyboard inserts plain text for all three, because iOS gives keyboards no other way.

## Why it is shaped this way

### Formatting arrives as messy HTML, so we never store HTML

Google Docs puts HTML on the clipboard that is mostly inline CSS: the whole selection sits inside `<b style="font-weight:normal;" id="docs-internal-guid-…">`, and the text sits in `<span style="font-size:11pt;font-family:Arial;…;font-weight:400;font-style:normal">`. It also adds a private `application/x-vnd.google-docs-document-slice-clip+wrapped` JSON type. Editors that accept it (CKEditor, Quill, Lexical) each keep a dedicated Google Docs normalizer and a separate Word one, because Word HTML is different again. Browser sanitizing strips only `<script>` and `javascript:` links, so the styling noise survives.

Sources: Lexical's paste fixtures (`packages/lexical/src/__tests__/unit/HTMLCopyAndPaste.test.ts`), CKEditor's `googledocsnormalizer.ts` and `mswordnormalizer.ts`, Quill's `normalizeExternalHTML/normalizers/googleDocs.ts`, atjson's `google-docs-explainer.md`, and the W3C Clipboard API draft §6.6 and §10.1.

Storing that HTML would carry fonts, sizes and colours into every paste, blow through the 1,000-character limit on markup alone, and need WebKit to read back. Apple says HTML import must run on the main thread, "can still time out" on external resources, and "is meant for implementing something like markdown … not for general HTML import" (`NSAttributedString init(data:options:documentAttributes:)`).

What we keep is the *intent*: bold, italic, strikethrough, monospace and links. Fonts, sizes and colours are dropped, which is the same choice Alfred recommends ("use plain text snippets … where you want the pasted text to match the destination format").

### Markdown is the storage, because `value` stays a String

| Concern | Markdown in `value` | RTF or HTML blob |
|---|---|---|
| CloudKit | Same String field | New Bytes field or a CKAsset |
| 1,000-char limit | Counts visible text easily | Markup inflates the count |
| Search, Spotlight, App Intents, input-type and sensitive-content detection | Run on the stripped text | Need a decode step everywhere |
| Display | `Text(AttributedString(markdown:))` already in the SDK | Needs an NSAttributedString round trip |
| Precedent | Espanso stores `markdown:` replacements; Bear stores notes as Markdown | Alfred and TextExpander store RTF |

I tested SwiftUI directly (a render on this Mac). `Text` draws inline styles, bold, italic and links, but it **ignores block structure**. With `.full` parsing, a heading, two list items and a code block collapse into one run-on line. With `.inlineOnlyPreservingWhitespace`, `#` and `-` stay as literal characters and the line breaks survive. So Rich parses inline-only. Lists and headings stay as their plain-text form, which still reads correctly when pasted as plain text.

The same test is why Markdown must **never** be applied to Plain or Code cutlings: `snake_case_name` would turn italic and `a*b*c` would lose its asterisks.

### The keyboard can only type plain text

`UITextDocumentProxy` has `insertText(NSString)` and nothing attributed, in every SDK through iOS 27 (`UIKeyInput.h:30`). Apple's keyboard guide says a keyboard provides "an unattributed NSString". The one way to deliver formatting from the keyboard is to write the pasteboard (Full Access) and have the user tap Paste.

### Plain text has to be one tap away everywhere

Paste, Raycast and Maccy all offer both a per-item "paste as plain text" and a global "always paste plain text" setting. Maccy's code shows what "plain" means mechanically: re-publish only the string flavour. Raycast's own troubleshooting says some apps strip formatting regardless. So a Plain cutling is never second-class.

### Code needs exactness more than colour

Snippet tools that care about code (SnippetsLab, Pieces, Gists) store it as plain text with a language, and highlight it with a library: Pygments, highlight.js or Tree-sitter. Apple ships no highlighter. A grep of every iOS 27 UIKit, SwiftUI and Foundation interface finds none. Cutling's rule is no third-party dependencies, and a JavaScriptCore highlighter would also cost keyboard memory, so highlighting is out of v1. Exactness is in: the things that silently corrupt code today are
- `SaveTextToCutlingIntent` trimming leading whitespace, which removes the first line's indentation,
- smart spacing adding a space before an inserted cutling,
- smart quotes in the editor (`UITextView.smartQuotesType`; SwiftUI has no smart-quotes modifier, so the Code editor needs a `UITextView`/`NSTextView` representable),
- duplicate detection comparing trimmed values.

## What changes, surface by surface

| Surface | Plain (default) | Rich | Code |
|---|---|---|---|
| Keyboard tap | Insert text, with smart spacing | Copy the styled version (Full Access); the user pastes it. Without Full Access, or with "Always paste plain text" on, type the stripped text | Insert exact text, no smart spacing |
| Keyboard long-press | — | "Type as Plain Text" types the stripped text (owner, 2026-10-03: styled by default, plain on long-press) | — |
| Teaching the paste | — | A keyboard can only insert plain strings (`UITextDocumentProxy` has no attributed insert in the iOS 27 SDK), so a formatted tap copies and shows "Copied". The editor shows a one-time inline TipKit tip under the Text field ("Due to iOS keyboard limits, formatted text is copied, not typed.", one sentence, owner 2026-10-09), chosen over an alert because the HIG says to avoid alerts that only inform (owner, 2026-10-09) | — |
| App copy (iOS/Mac), share | String | One pasteboard item with plain + RTF + HTML | String |
| Mac picker paste | String | Same three flavours, then ⌘V; ⌥-click or "Copy as Plain Text" pastes plain (the picker is click-driven, so Maccy's ⌥⇧↩ has no place) | String |
| Global setting | — | "Always paste plain text" | — |
| Card, keyboard key, picker | As today | Inline styles rendered | Monospace |
| Editor | `TextEditor` as today | Styled text in a native text view; bold and italic come from the system's own Format menu, and pasted fonts and colours are cut back to the kept styles | Monospace `UITextView`/`NSTextView`, smart quotes, dashes, autocorrect and autocapitalisation off |
| Intents, Spotlight, search, detection | Value | Stripped text | Value |
| Capture from clipboard, share sheet | String | If the item carries `public.rtf` (or `public.html`), offer "Keep Formatting" | Suggest Code when the existing Mac heuristic (`MacPickerView` `codeLooking`) fires |

Capture reads **RTF first**. WebKit's own source writes RTF, RTFD and HTML for every Safari selection (`PlatformPasteboardIOS.mm`, `PasteboardMac.mm`), Apple documents no main-thread rule for RTF. `NSAttributedString` resolves Google Docs' "bold wrapper that is not bold" into real font traits, so no Google Docs normalizer is needed: Lexical's real fixture HTML converts to `Hello **bold** *and italic*` (`Tests/RichText/run.sh`). HTML import runs only in the main app, on the main thread, as the fallback. The keyboard and share extension never parse HTML.

The converter walks the attributed string and emits Markdown only for bold, italic and strikethrough traits, monospace fonts and `.link` attributes.

## The limit

1,000 characters counts the **visible** text. The stored string is capped at 1,500 so markers can't push a full-length Rich cutling over. The Code and Plain limits are unchanged.

## Data and sync

- `Cutling.format: TextFormat` (`plain | rich | code`), decoded with `decodeIfPresent … ?? .plain`.
- A new field must be added in six places, or iCloud silently wipes it, because a remote change replaces the whole struct (`CloudKitSyncManager.swift` `applyRemoteChanges`):
  1. the decoder,
  2. both CloudKit record writers (`CloudKitSyncManager.record(for:)` and `KeyboardSyncHelper.buildRecord`),
  3. the CloudKit reader,
  4. `CutlingStore.duplicate()`,
  5. ShareView's `.cutling` import.
- **CloudKit schema deploy.** Production refuses fields it hasn't seen. Apple: "you must deploy the development schema to the production environment to copy over its record types, fields, and indexes". The steps:
  - The `format` field joins `createdDate` and `userSetInputType`, which were never synced. That sync is built today behind `CloudKitSchema.productionHasMetadataFields` in `Cutling/Cutling.swift`: debug builds write the fields, release builds wait for the flag.
  - Run a debug build once with iCloud on, then deploy the schema in the CloudKit Console.
  - Then flip the flag.
  - All three fields go in one deploy.
- Older app versions show a Rich cutling's Markdown markers as literal text. Nothing breaks, and the next update fixes the display.

## Phases

| # | Ships | Depends on |
|---|---|---|
| 1 | `format` field (all Plain), metadata sync flag flipped, schema deployed | Owner deploys the schema in the CloudKit Console |
| 2 | Code format: monospace everywhere, exact insert, no trim, the representable editor, Code suggestion | 1 |
| 3 | Rich display + Markdown editing toolbar + rich copy on iOS/Mac + Mac picker plain/rich paste + "Always paste plain text" | 1 |
| 4 | Rich capture from RTF/HTML on the pasteboard and the share sheet | 3 |
| 5 | Keyboard "Copy with Formatting" | 3 |
| Later | Syntax highlighting (needs a dependency decision), `{date}` / `{clipboard}` / `{cursor}` placeholders (Raycast, Alfred and TextExpander all have them) | — |

## How it gets verified

- `Tests/RichText/run.sh` compiles `RichText.swift` alone and checks the converter (19 checks). Its fixtures:
  - Lexical's real Google Docs HTML,
  - RTF written by the app itself (round trip),
  - `snake_case`, `a*b*c` and tab-indented code staying byte-identical as Plain and Code.
- On a device, three things no Apple doc settles:
  - which flavour a plain `UITextField` picks when the pasteboard holds plain + RTF + HTML,
  - what Chrome on iOS puts on the pasteboard,
  - whether `TextEditor` with `.autocorrectionDisabled` still curls quotes.
- Every new string is hand-written in all 76 locale folders, using Apple's own terms where Settings already has them.

## Not doing

- Storing HTML, RTF or fonts, sizes and colours.
- Headings and lists as styled blocks. SwiftUI `Text` cannot draw them, and pasting as plain keeps their meaning.
- `TextEditor(text: Binding<AttributedString>)`. It is iOS 26 / macOS 26+, and Cutling supports iOS 18 / macOS 15. Revisit when the floor moves.

## As built

- Shared code: `Cutling/RichText.swift` (formats, Markdown ↔ attributed/RTF/HTML, `CutlingPasteboard`), `Cutling/CodeTextEditor.swift` (the Code editor).
- `CutlingUITests/FormattingUITests.swift` types each format through the real keyboard. The screenshot run is held to its own test by `only_testing` in `fastlane/Snapfile`.
- Not yet checked on a device: a Safari or Word RTF capture, and Chrome's pasteboard on iOS.

## Revised 2026-10-02: detection, no format controls

The owner dropped the segmented picker and the B / I / S / code / link icons. The format is now decided for the user:

| Signal | Result |
|---|---|
| Paste carries RTF/HTML formatting | Formatted |
| Code rules (`TextFormat.looksLikeCode`) match | Code |
| Rules unsure, and Foundation Models is available (iOS/macOS 26+, Apple Intelligence on) | The on-device model decides and names the language (`Cutling/CodeDetector.swift`) |
| Anything else | Plain |

- The editor shows a chip beside the character count only when the text is not Plain ("Formatted", "Code: Swift"). Tapping it offers Plain Text, Formatted (only while formatted) and Code. Choosing one stops detection for that cutling.
- Typing never swaps the editor. Detection runs on open, on paste and big edits, and the rules run once more at save.
- Cutlings saved before formats existed are read through the code rules at display time (`Cutling.textFormat`).
- Core AI was considered and rejected: it deploys custom converted models (WWDC26 "Meet Core AI"), while classifying a snippet needs no custom model.
- Foundation Models is weak-linked, so iOS 18–25 still launch; it runs in the main app only, never the keyboard.
