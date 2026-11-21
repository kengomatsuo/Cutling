# The text editor as a Notes-like page, and the 1,000-character limit (cards ASG125, ASG126)

Fetched 2026-11-21. Sources are rows in [notes.md](notes.md), written as [n]. Every image is in [shots/](shots/) with a row in [shots/README.md](shots/README.md); page text is in `pages/`. GUESS is my opinion, UNSURE is not confirmed from a primary source. Nothing was run on a device or in the simulator in this run. Chrome was used read-only in my own tab (closed).

Not redone: where the insert control sits (`../fill-ins-editor/`), the fill-in kinds and how rivals show them (`../fill-ins-kinds/`).

## Two recommendations

1. **Text page (ASG125): yes to a pushed page, no to an "Advanced" button, and only the part of Notes a keyboard can type.** Keep the text box in the form for short cutlings and give it an expand control that pushes a full-height "Text" page built like a Notes note: back chevron, undo and redo, a Done check, the text filling the screen, one bar above the keyboard (format button, fill-in buttons, find). Formatting stops at what Cutling already stores (bold, italic, strikethrough, monospace, links). No headings, checklists, tables, attachments, markup, mentions or sharing. GUESS on the hybrid; the facts behind it are in sections 3 and 4.
2. **Limit (ASG126): raise to 10,000 characters per text cutling, with a total of 5,000,000 characters across all text cutlings, after two device checks.** The 1,000 was set for a layout problem that the full page removes, not for memory, sync or the host app. GUESS on the number; the arithmetic is in section 5.

## 1. Apple Notes, iOS, iPadOS and macOS 27 (and 26)

Apple's guide for iOS 27 is live [1-13], so most pictures are version 27. The Format panel picture is Apple's iOS 26 one [22].

### What each screen does

| Screen | Image | Layout | Colour | How it works (Apple's words in the saved page) |
|---|---|---|---|---|
| Note open on iPhone | `shots/iphone-notes-note-with-tags-drawing.png` | Pushed from the list: round back chevron top left; a glass capsule top right holding share and more (three dots). Text fills the screen edge to edge, no card, no section header. First line is the title in large bold type. Bottom: a floating capsule with checklist, paperclip, markup; a separate round compose button bottom right. | White page, black text, tags yellow when they match (`#school`), grey when not. | "The first line of the note becomes the note's title." [2] |
| Note while typing | `shots/iphone-notes-ios26-format-panel.png`, `shots/iphone-notes-quick-note-save.png` | Top bar gains undo (curved arrow) and a yellow round check on the far right. The bottom capsule becomes a bar that sits on the keyboard: Aa, checklist, table, paperclip, markup, and a sixth item cut off at the edge (the bar scrolls sideways). | The check is the only filled control: yellow circle, white tick. | "To save the note, tap [the Done button]." [2] |
| Format panel (Aa) | `shots/iphone-notes-ios26-format-panel.png` | A sheet over the keyboard's place, title "Format", round X top right. Row 1: Title, Heading, Subheading, Body, scrolling sideways, each drawn in its own size. Row 2: B I U S joined in one capsule, then a highlighter pen and a colour dot. Row 3: dashed list, bullet list, numbered list, outdent, indent, block quote. | Current style and active B are yellow filled; the rest grey capsules. Highlight colour dot is purple. | "Tap [the Format button], then choose a style such as Heading, bold or italic font, highlight, and more. You can also swipe over the format bar options to quickly access commonly used styles." [2] |
| Headings | `shots/iphone-notes-collapsible-headings.png`, `shots/ipad-notes-collapsible-headings.png` | Headings carry a small chevron in the left margin; collapsed ones hide their body. Undo joins share and more in the top capsule. | Each heading highlighted in its own colour (purple, red, orange, teal): text in the colour, pale fill behind. | "In a note, select the text for the heading. Tap [Format], then tap Heading or Subheading." Collapse and expand with the chevron. [2] |
| Lists, checklist, table | `shots/iphone-notes-ios17-a-note-with-a-table-a-cell-in-the-table-is-being.png` (iOS 17), `shots/mac-notes-table-button-column.png` | Checklist and table are their own bar buttons, not inside Aa. Table handles are three dots at the row start and column top. | Selected column outlined yellow on the Mac. | "Make a checklist: Tap [Checklist]. Add a table: Tap [Add Table]." Divider line: more menu, "Insert Divider Line". [2] |
| Attachments (paperclip) | `shots/iphone-notes-ios27-attachment-menu.png` | A menu that grows from the paperclip: Attach File, Record Audio, rule, Image Playground, Choose Photo or Video, Take Photo or Video, Scan Documents, Scan Text. Icon left, label right. | Monochrome. | "In a note, tap [Attachments], then choose an option." [5] |
| Markup | `shots/iphone-notes-markup-tools.png` | Tool tray at the bottom (pen, marker, highlighter, eraser, colour, plus); top bar keeps back, undo, more, check. | Tools in their own ink colours. | [4] |
| Links | `shots/iphone-notes-add-link.png`, `shots/iphone-notes-ios27-more-menu-add-link.png` | Reached from the text edit menu (Paste, Delete, Select; Select All; Writing Tools; AutoFill; Add Link; Insert Divider Line; Attach File). Add Link is a sheet: X left, title, yellow check right; "Link To" field holding the target as a yellow pill; "Link to Section" row; "Name" with a "Use Section Title" switch. | Target shown as a yellow filled pill with a note icon. | "select the text or tap to place the insertion point. Tap [Forward], tap Add Link, then enter the URL ... Optionally, you can add a name." Typing ">>" links to a note. "touch and hold the link" to edit or remove. Addresses, phones, dates underline themselves. [7] |
| @mentions | `shots/appstore-notes-iphone-01_shared-note.jpg` | Inline text token. | Name in colour (purple or yellow by participant). | "type an @ sign followed by their name." Only in shared notes. [9] |
| Find in note | text only [8] | No picture on Apple's page. | | "Tap [Note Actions], then tap Find in Note." Options include "Include Attachments". |
| Share and collaborate | `shots/iphone-notes-share-overlay.png`, `shots/mac-notes-share-menu.png`, `shots/mac-notes-collab-highlights.png` | Share sheet with the note's title and a menu under it (Share a Link or Send a Copy), a "People you choose can edit." row, then AirDrop, Messages, Mail; Copy Link, Copy, Export as Markdown. On the Mac, an Activity side panel and pink highlights on changed lines. | | "tap the menu under the note title, then tap Send a Copy" or "Share a Link". [9] |
| Undo, redo, Done | `shots/iphone-notes-ios26-format-panel.png`, `shots/ipad-notes-add-link.png` | iPhone shows undo only in the top capsule (redo not pictured: UNSURE where it is). iPad shows undo and redo side by side at the top left group. Done is the yellow check on iPhone; iPad has no check. | | [2] |
| iPad | `shots/ipad-notes-note-with-tags-drawing.png` | Same page, but the bar is at the top centre (Aa, checklist, table, paperclip) and markup, share, more are top right; sidebar toggle, back, compose top left. Nothing sits above the keyboard in these pictures. | | [11] |
| Mac | `shots/mac-notes-toolbar-format-checklist-table-media.png`, `shots/mac-notes-table-button-column.png` | Three panes (folders, list, note). Window toolbar: more, compose, Aa, checklist, table, paperclip, markup, Writing Tools, then collaborate, share, more, search. | | "Click Aa to apply a paragraph style or format text". Fonts window, alignment and "Insert Divider Line" (Command-L) are in the menus. "Your note saves automatically as you work." [15-17] |
| Empty states | none pictured | Apple shows no empty-note picture. | | A new note opens with the keyboard up and nothing on the page; the first line typed becomes the title [2]. UNSURE how the empty page looks on 27. |

Earlier looks for comparison: `shots/iphone-notes-ios17-...family-vacatio.png` and `shots/iphone-notes-ios16-...` (bottom bar with checklist, camera, markup, compose; yellow tint on every control).

### What Notes teaches for a snippet editor

- The page is a navigation push, the text has the whole screen, and there are no rows around it.
- All tools sit in one bar above the keyboard; anything with more than one choice opens a panel or menu from its own button (Format sheet, paperclip menu).
- One filled control only (the yellow Done check).
- The Format sheet replaces the keyboard instead of covering the text.
- Saving is automatic; the check ends editing.

## 2. Apple Shortcuts: how variables are presented

Apple's iOS 16 to 27 guide pages kept the text but dropped the pictures of the bar; the iOS 15, 14 and 12 versions of the same pages still serve them [24-27]. The text of the iOS 27 pages [28-33] matches what the iOS 15 pictures show, so the behaviour is current; the look on iOS 27 is seen only in two small pictures (`shots/sc-ios26-variable-examples-in-shortcut-editor.png`).

| Screen | Image | Layout | Colour | How it works |
|---|---|---|---|---|
| Variables bar | `shots/sc-ios15-make-top-25-playlist-shortcut-screen-showing-var.png` | One row resting on the keyboard: "Variables" (text button, left), a wand icon (Select Magic Variable), then special variables as pills scrolling sideways (Ask Each Time, Clipboard ...), "Done" at the right. | Pills pale blue with blue text; each has its own small icon: blue speech bubble (Ask Each Time), red scissors (Clipboard), red calendar (Current Date). | "Tap a text field to display the Variables bar and keyboard, then tap one of the special variables. ... You may need to swipe left to see all." [29] |
| Bar expanded | `shots/sc-ios15-expanded-variables-bar.png`, `shots/sc-ios15-special-variables.png` | Tapping "Variables" swaps the keyboard for a panel: "Select Magic Variable" first, then the shortcut's own variables as pills in a wrapping grid, special variables in a row along the bottom. "Variables" turns into a filled blue button while open. | Same pills; panel grey like the keyboard. | [24] |
| Select Magic Variable | `shots/sc-ios15-selectable-magic-variables-in-shortcut-editor.png` | The editor itself becomes the picker: title "Select a Magic Variable", Cancel top left, and under every action its output as a pill. | Pills blue with the action's icon. | "The shortcut editor displays an alternate view showing each action's output ... Tap the Magic Variable ... The variable is placed inline in the text field (at the original insertion point)." [29] |
| Pill in a text field | `shots/sc-ios15-variable-token-added-to-shortcut.png`, `shots/sc-ios26-variable-examples-in-shortcut-editor.png` | The pill sits in the line like a word, cursor after it. iOS 26: pale blue rounded pill, small glyph, blue label ("Shortcut Input", "Current Date"). | Selected pill is solid blue with white text (iOS 15). | "Variables are represented by blue pill-shaped tokens." Remove: cursor next to it, delete key. [29] |
| Tap a pill | `shots/sc-ios15-selected-variable-available-for-editing-in-the-s.png`, `shots/sc-ios15-variable-editor.png`, `shots/sc-ios15-get-property-selected-from-variable-editor.png` | The keyboard is replaced by the variable editor: a bar with a keyboard-return button, Rename, Reveal Action, Done; the variable's icon and name; a blue link "as Rich text >" for its type; then a list of what to take from it, the default marked "Default" with a tick. | Tick and links blue. | "tap a variable token. The variable editor appears. The Type row indicates the content type ... Tap a property in the list. The variable token is updated to indicate your preference." [30] |
| Current Date's format | text only | Not pictured by Apple: UNSURE how the date rows look on 27. | | A date variable is adjusted in the same editor; the formats Apple names are None, Short, Medium, Long for date and for time, plus Custom with a Unicode pattern ("yyyy.MM.dd G 'at' HH:mm:ss zzz") [32][33]. |
| Ask Each Time | `shots/sc-ios15-ask-each-time-variable-token-in-the-date-field-o.png`, `shots/sc-ios15-ask-each-time-variable-pausing-the-shortcut-to-r.png` | In the editor it is a pill like any other. When the shortcut runs, a card drops from the top with the field's name, the field, Cancel and Done. | Speech-bubble icon. | "the shortcut pauses, prompting you ... When you select Done, the shortcut continues." [31] |
| Clipboard, Shortcut Input | `shots/sc-ios15-special-variables.png`, `shots/sc-ios26-variable-examples-in-shortcut-editor.png` | Special variables: always in the bar, no setup. | | [28] |
| Empty text field | `shots/sc-ios15-expanded-variables-bar.png` | Grey placeholder "Text" with the cursor before it. | | |
| Mac | text only [34] | No bar: "Control-click in any text field ... Insert Variable". | | |

What carries over to Cutling: the bar above the keyboard holds the commonest inserts as pills with icons and a "more" entry at the left (Cutling's bar already does the first half); tapping a pill swaps the keyboard for that fill-in's settings, with the default option ticked, instead of an alert; one pill colour, the icon tells the kind.

## 3. How rivals edit a long snippet

| App | Evidence | What it does |
|---|---|---|
| Snippety (iPhone) | `shots/appstore-snippety-iphone-1.jpg`, `-4.jpg`; iOS release notes [38] | A snippet opens as a pushed page titled "Snippet" (back chevron, share, delete), name and tags on top, then "Snippet Preview" with the text and coloured pills filling the rest; a pencil button bottom left opens the editor. Release notes: "Improved the snippet editor, including form scrolling and full-screen template mode." So: a form, plus a full-screen mode for the text. |
| Raycast (iPhone) | `shots/appstore-raycast-iphone-2.jpg`; manual [36] | Raycast Notes is a pushed full page (back chevron, undo, redo, more) with a format bar on the keyboard (headings, lists, B I U). Snippets: "Snippet text has a maximum length of 65K characters. This limit exists for performance reasons". Snippet editor on iPhone not pictured: UNSURE. |
| TextExpander (iPhone) | `shots/appstore-textexpander-iphone-*.jpg` | The listing shows the keyboard and the fill-in card only; no editor picture. Editing on iPhone: UNSURE. |
| Text Blaze | `../fill-ins-kinds/shots/textblaze-*.jpg`; plans [37]; forum [39][40] | Web editor: the snippet text is the page, commands in a side panel. No iPhone editor. |
| Paste, PastePal | `shots/appstore-paste-iphone-*.jpg`, `shots/appstore-pastepal-iphone-*.jpg` | Clipboard managers: listings show cards, collections and the keyboard, no text editor picture. UNSURE how either edits long text. |

Pattern: where a rival shows its phone editor at all (Snippety, Raycast Notes), text gets a full page. Nobody pictured hides the editor behind a button called Advanced.

## 4. Should Cutling's text be its own page?

Facts:

- Today the text box sits in a Form with `.frame(minHeight: 120, maxHeight: 450)` (`Cutling/TextDetailView.swift:389`), between Name, Icon and Colour above and Paste, fill-ins, input types and expiration below.
- The limit was cut from 2,000 to 1,000 on 2026-05-08 "because of iOS form layout issues" (commit `0e7878b4`, which also cut the box from 650 to 450 points). The form is what made long text awkward.
- Notes gives text the whole pushed page [2]; Snippety has a form and a full-screen text mode [38].
- A keyboard can only type plain text: `UITextDocumentProxy.insertText` takes an unattributed string in every SDK through iOS 27, and SwiftUI `Text` drops block structure (`docs/formatting-plan.md`, "The keyboard can only type plain text" and the render test above it). Formatted cutlings type their stripped text; styles survive only on Copy and in the app.

Recommendation (GUESS, built on those facts):

- **Keep the box in the form, add an expand control, push a "Text" page.** Most cutlings are an address or one line; a forced extra tap for those is a cost with no gain (GUESS: no usage data exists). The expand control is an icon on the box's corner, and a box that has reached its height cap offers it too. On the Mac there is no push: the window is already the page, so the text pane should simply take the window's height.
- **Not an "Advanced" button.** The page is the same editor with more room, not a second set of features; a second editor would need its own tests in 50-odd languages (GUESS).
- **The page, taken from Notes:** back chevron; undo and redo top right; a Done check that ends editing (saving stays as it is); text edge to edge; the character count as small grey text; one bar above the keyboard with a format button (opens a sheet in the keyboard's place with a close X, as Notes does), the fill-in buttons that exist now, and Find for long text (UNSURE which API; not researched this run).
- **Tap a pill to change it,** as Shortcuts does: the keyboard gives way to that fill-in's settings (date style and offset, choices, default), default ticked.

Notes features, one by one:

| Notes feature | Fits a typed snippet? | Why |
|---|---|---|
| Full-page push, undo/redo, Done check, bar above keyboard | Yes | Layout only; no data change. |
| Bold, italic, strikethrough, monospace, link | Yes, already stored | Rich format's Markdown subset (`docs/formatting-plan.md`); typed as stripped text, copied with styles. |
| Underline, highlight colours | No | Not in the stored subset; cannot be typed. |
| Title, Heading, Subheading, collapsible sections | No | Block styles: the keyboard types plain text, SwiftUI `Text` cannot draw them. |
| Bullet, dash, numbered lists | Only as plain characters | "- " and "1. " survive as text. Continuing a list on Return is possible as plain typing (GUESS, not designed). |
| Checklists, tables, divider line | No | No plain-text meaning in the host field. |
| Photos, scans, audio, files, markup | No | A keyboard cannot type an attachment; image cutlings already exist as their own kind. |
| @mentions, tags, share and collaborate, activity | No | They belong to shared notes; cutlings are not shared documents. |
| Links to other notes (">>") | No | Nothing to link to. |
| Find in note | Yes, once text can be long | Useful past a screenful. |

## 5. The character limit

### Why it is 1,000

| Fact | Where |
|---|---|
| First set at 2,000 on 2026-03-08 | commit `5a500792` ("UI Tweaks") |
| Cut to 1,000 on 2026-05-08, "because of iOS form layout issues" | commit `0e7878b4` |
| The memory comment came later and sizes the count, not the length: "The keyboard holds every text cutling in memory, about 2.3 MB per 1,000 at full length"; 5,000 text with 500 photos peaks at 59 MB; 10,000 text 65 MB; 10,000 text with 500 photos 72 MB, "too close to the limit" of 77 MB | `Cutling/CutlingStore.swift:46-54`, `../keyboard-memory-limits.md` |
| Formatted text may store 1,500 characters of Markdown for 1,000 visible | `Cutling/RichText.swift:44` |

So the number came from the form, and memory depends on the total held, not on any one cutling.

### What bounds a longer limit

| Bound | Fact | Result |
|---|---|---|
| Keyboard memory | 2.3 MB per 1,000 cutlings of 1,000 characters = about 2.3 bytes per character. Today's worst case: 5,000 x 1,000 = 5,000,000 characters = about 11.5 MB of text, peak 59 MB. | A flat 2,000 doubles the worst case to 10,000,000 characters, the same load as the "10,000 text" run (65 MB, 72 MB with photos), which the code already calls too close. A flat 10,000 would be 50,000,000 characters, about 115 MB: over the limit. A higher per-cutling limit therefore needs a cap on the total. |
| iCloud | "the data that a record stores must not exceed 1 MB. Assets don't count toward this limit" [41]. Text is one String field (`CloudKitSyncManager.swift:383`). | 10,000 characters is at most 40 KB at 4 bytes each, plus 15,000 stored for formatted: under 6% of a record. Not the bound. |
| Typing into the host app | Apple's pages state no length limit for `insertText` [42]. No report of truncation or slowness was found in two searches (UNSURE: absence of reports, not a test). Raycast, which ships an iPhone keyboard, allows 65,536 characters "for performance reasons" [36]. aText on the Mac offers "Automatically use Clipboard for long text" because typed-out long text goes wrong in browser apps (`../cutling-pains.md`, aText entry). | Unknown until tried on a device. |
| The editor | The form box, 450 points. | Removed by the full page (section 4). |

### What rivals allow

| App | Limit per snippet | Source |
|---|---|---|
| Raycast | 65,536 characters | [36] |
| Text Blaze | 2,500 on the free plan, 25,000 on a paid plan, both from users on Text Blaze's own forum with staff replying ("The paid plans have higher character limits"); the plans page read in Chrome prints no number ("Limited snippets") | [37][39][40] |
| TextExpander, Snippety, Paste, PastePal, Apple Text Replacement | none stated on the pages read | UNSURE |

A Text Blaze user at 2,500: "frequently have text blocks that exceed this limit" [40]. At 25,000 the complaint is LLM prompts with pasted attachments [39].

### Recommendation (GUESS on the numbers)

- **10,000 characters per text cutling** (15,000 stored for formatted, keeping today's 1.5 ratio). About 1,600 English words: a long email template or a prompt. Four times Text Blaze's free tier; a sixth of Raycast's.
- **5,000,000 characters in total across text cutlings**, which is exactly today's worst case (5,000 x 1,000), so the measured 59 MB peak still stands if memory follows total characters (GUESS: that follows from the per-1,000 figure, but long single texts have not been measured). The count limit of 5,000 stays.
- **Why not higher:** past 10,000 the keyboard's fill-in bar, the card preview and typing into a chat box stop making sense for something typed by a tap (GUESS); 65K is Raycast's ceiling on a desktop-first tool.
- **Two checks before it ships,** both on a real iPhone since the Simulator enforces no memory limit (`../keyboard-memory-limits.md`):
  1. `scripts/keyboard-memory.sh` with 500 cutlings of 10,000 characters plus 500 photos: peak must stay near 59 MB.
  2. Tap a 10,000-character cutling into Notes, Messages, Mail, Safari (a textarea), WhatsApp and Gmail: all of it arrives, and the keyboard does not stall. If any app drops text or lags, fall back to 5,000, or type in pieces.
- **Code that names the limit today** (to move together): `CutlingStore.maxTextLength` and its uses in `TextDetailView`, `ShareView` (also the orange warning at "limit minus 500"), `MainContentView`, `KeyboardViewController`, `SaveTextToCutlingIntent`, `PreferencesView`, `RichText.maxStoredLength`.

## Could not confirm

- How Notes on iOS 27 shows redo on iPhone, the empty new note, and Find in Note (no Apple picture).
- How a tapped Current Date pill looks in Shortcuts on iOS 27 (text only).
- TextExpander's, Snippety's, Paste's and PastePal's per-snippet limits and phone editors.
- Any length limit or slowdown in `insertText`: nothing found, nothing tested.
- That keyboard memory depends only on total characters.
