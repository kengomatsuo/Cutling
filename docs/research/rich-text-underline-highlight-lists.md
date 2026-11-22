# Underline, highlight and lists in formatted cutlings: what Apple's text system does (2026-11-22)

Measured on this Mac (macOS 27, Swift 6.4.2) and on the iOS 27.2 simulator with small programs that call Foundation, AppKit and UIKit directly. What other apps keep when these are pasted is in [rich-text-paste-targets.md](rich-text-paste-targets.md).

## Apple's Markdown parser

`AttributedString(markdown:options:)` with `.inlineOnlyPreservingWhitespace`, as Cutling parses formatted text:

| Input | Default scope (what Cutling 1.6 and earlier read) | With a scope that declares `underline` and `highlight` |
|---|---|---|
| `^[under](underline: true)` | `under`, no attribute | `under`, underline |
| `^[**both**](underline: true, highlight: true)` | `both`, bold | `both`, bold, underline, highlight |
| `^[**x** [l](https://a.b)](underline: true)` | `x l`, bold and link | the same, underlined |
| `<u>under</u>`, `<mark>hi</mark>` | the tags shown as text (inline HTML runs) | the same |
| `==hi==`, `++ins++` | shown as typed | the same |
| `- dash`, `* star`, `1. one`, `• bullet` at a line start | shown as typed (inline-only parses no blocks) | the same |
| `\- x`, `1\. x`, `&#8226; x`, `&bull; x` | `- x`, `1. x`, `• x`, `• x` | the same |
| `\• x` | `\• x` (• is not ASCII punctuation, so no escape) | the same |
| `` `a\nb` `` | `a b` (a code span joins lines) | the same |

The `^[text](name: value)` syntax is Apple's own extension, read through a `MarkdownDecodableAttributedStringKey`. A reader that does not declare the key keeps the text and drops the attribute, so an older Cutling shows an underlined word as the plain word. Inline HTML and `==` would show their markers there.

## Apple's attributed text

- **Highlight** is `NSAttributedString.Key.textHighlightStyle` (`NSTextHighlightStyleAttributeName`), iOS 18 and macOS 15, the same floor as Cutling. Its colour schemes (`textHighlightColorScheme`: default, purple, pink, orange, mint, blue) are the five Notes offers. The default scheme follows the view's tint (`UITextView.textHighlightAttributes`). UIKit's header says it is "Supported only with TextKit2"; nothing in Cutling's editor touches `layoutManager`, so its `UITextView` stays on TextKit 2.
- Apple's RTF writer writes it as `\AppleHighlight`, and its RTF reader reads it back, on macOS 27 and iOS 27. A `backgroundColor` is written as `\cb`. Apple's HTML writer writes the highlight as `<mark style="background-color: rgba(0, 0, 0, 0.0)">`, a transparent mark.
- **Underline** is `underlineStyle`, RTF `\ul`, HTML `<u>`.
- **Lists** are `NSTextList` in the paragraph style. The RTF writer writes a list table with `{disc}`, `{hyphen}` (marker U+2043) and `{decimal}` and a `\listtext` per item, whether or not the marker is in the text (it writes `\'95` for a bullet when it is not). The RTF reader gives the items' text without markers on macOS 27 and iOS 27 (`NSTextList.includesTextListMarkers` is new in 26 and false). The HTML reader gives `\t•\t` and `\t1\t` in the text on macOS and no markers on iOS, both with the `NSTextList`.
- UIKit's own `UITextView` has no list editing (no Return-continues-list); NSTextView has Format › List.

## What Cutling stores (built 2026-11-22)

| Style | Stored in the formatted value | Plain text (keyboard, search, Shortcuts) | Copy: RTF | Copy: HTML |
|---|---|---|---|---|
| Underline | `^[text](underline: true)` | `text` | `\ul` | `<u>` |
| Highlight | `^[text](highlight: true)` | `text` | `\AppleHighlight` with Notes' purple scheme | `<mark>`, purple text on a 15 % purple, as Apple's own HTML writer draws it |
| Bulleted list | `• item` at the line start | `• item` | `NSTextList` `{disc}` | `<ul>` |
| Dashed list | `- item` | `- item` | `{hyphen}` | `<ul class="Apple-dash-list">` with `list-style-type:'- '` |
| Numbered list | `1. item` | `1. item` | `{decimal}` | `<ol>` |

- A list's marker is stored as the text a plain-text host should show, so a list needs no conversion for plain text, and an older Cutling shows it as the same lines.
- A line that only looks like a list is escaped as text: `\- `, `1\. `, `&#8226; `. CommonMark and older Cutlings show all three as typed. So a Plain cutling whose lines start with "- " stays Plain and unchanged when edited; only the list menu, or a pasted list, makes a list.
- Existing formatted cutlings whose lines already start with "- ", "• " or "1. " now draw those lines as lists. Their stored text and plain text do not change.
- Numbers are written by position: each run of numbered lines counts from 1.
- In the editor the markers stay in the text, marked as the list's (`NSAttributedString.Key.cutlingListMarker`), with wrapped lines hung under the item. Return carries the list on and ends it on an empty item; Backspace just after a marker takes the line out of the list; the cursor never stands inside a marker. A list pasted from another app (its `NSTextList`) is read as Cutling's own.
- The highlight is Notes' first colour, purple, everywhere: the editor, card previews and both copy flavours. Mail and web pages on iOS build a paste from the RTF and Mac apps from the HTML ([rich-text-paste-targets.md](rich-text-paste-targets.md) §3), so both carry the same look, and Notes keeps it as its own highlight.
- A pasted background colour counts as a highlight only when it is a colour (saturation above 0.25): web pages paint white, grey and black boxes behind text that nobody meant as highlights. A link's underline is the link's own.

Checks: `Tests/RichText/run.sh` (50 checks, among them these rows, an old reader's view, a TextEdit dashed-list RTF and a WebKit HTML list).
