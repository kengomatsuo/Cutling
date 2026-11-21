# Fill-in kinds and inserters: what the idea sources offer and how they show it

Card ASG124. Everything fetched 2026-11-21; sources and saved files are rows in [notes.md](notes.md) (row numbers are written as [n]). "GUESS" is my inference, "UNSURE" is not confirmed from a primary page. Nothing was run on a device: every iOS feasibility line is read from Apple's docs, not tested.

Today in Cutling (docs/fill-ins.md): blank, choice, date (with math), time, cursor, clipboard, inserted from "Add Fill-in or Date" and a bar above the keyboard, shown as pills.

## 1. Platform facts that decide what the keyboard can read

- Without Full Access the keyboard has no network, cannot write to the App Group (it can read it), no microphone. With Full Access it "can access Location Services and Contacts, with user permission" [42]. Calendar, Music, Health, Motion are not in that list: UNSURE, needs a device test.
- A keyboard "has no prompts of its own" (brief): so a permission must be asked by the main app first. Whether the extension then sees the same authorization is UNSURE (docs [44] say the system stores authorization per app; nothing about extensions).
- Value read at use time (keyboard asks the framework when the person taps) vs saved by the app (main app reads, writes to the App Group, keyboard reads the saved copy, which is stale but needs no Full Access to read [42]).
- Mac: the main app can call every framework below directly (no extension limits), with the usual per-app permission prompt.

## 2. Screenshots (shots/)

Source images are the products' own pages (official docs); two are mine from Claude in Chrome (marked CiC). Date of all: 2026-11-21.

| File | Source URL | What it shows |
|---|---|---|
| shots/apple-shortcuts-ios17-variable-picker-b.png | support.apple.com/guide/shortcuts/use-variables-apdd02c2780c/17.0/ios/17.0 [7] | Apple's own picker: a blue banner "Select a Magic Variable" with Done; under each action its output as a blue pill with the action's icon (Current Location, Weather Conditions, Current Song, Current IP Address); search field at the bottom. |
| shots/apple-shortcuts-ios17-variable-picker-a.png | same | An "Ask Each Time" token in the Repeat row: pill with a prompt icon and the parameter name. |
| shots/apple-shortcuts-ios18-variable-picker-a.png | .../18.0/ios/18.0 [7] | Pills in a filter row (Lyrics contains Text) and in "Play Music": blue pill, action icon, label. |
| shots/apple-shortcuts-pills-with-icons.png | support.apple.com/guide/shortcuts/ (iOS 26 guide) [3] | iOS 26: pills with app icon + name, a circled chevron on a pill opens its details; unfilled pill pale ("Recipients"). |
| shots/apple-shortcuts-new-shortcut-prompt.png | same | iOS 26 new-shortcut sheet; no variable UI (kept as proof that the iOS 26 guide has no picker image). |
| shots/apple-shortcuts-use-variables-page.jpg | support.apple.com/guide/shortcuts/use-variables-apdd02c2780c/ios (CiC) [2] | The page text: "Variables are represented by blue pill-shaped tokens." |
| shots/km-insert-token-menu-frames.png, shots/km-insert-token-submenu.png | wiki.keyboardmaestro.com/_media/km-7.1-insert-token-demo-an.gif [12] (frames cut with ffmpeg, 1 per second) | Insert Token popup beside a text field: top group Variable, Calculation, Position Cursor; a rule; categories All, Clipboard, Date, Google Chrome, Macro Information, Mail, Safari, Screen, System, iTunes; each opens a submenu (Google Chrome Field, JavaScript, Ready State, Document Title, Document URL). Result in the field is plain text %SafariTitle%, no pill. |
| shots/km-tokens-wiki-insert-token-field.jpg | wiki.keyboardmaestro.com/Tokens (CiC) [9] | The field with the "Insert Token" popup at its top right. |
| shots/textexpander-fillin-editor-1.png | textexpander.com wp-content Screenshot-2025-11-05 4.48.26 [19] | Top icon toolbar (date, time, math, keyboard, cursor, fill-in, script); Fill-in button open: Single Line Field, Multi Line Field, Date Picker, Optional Section, Popup Menu, Show at Top; in the text, outlined rounded pills with an icon and a name ("Customer Name", "Date of Resolution"); an optional section is a start pill and an "(end optional)" pill with boxed ends. |
| shots/textexpander-fillin-editor-2.png | same, 4.49.25 [19] | Edit dialog opened from a pill: Name, a mini toolbar (date, time) over the default value, Width, Cancel, OK. |
| shots/textblaze-formtext-doc.jpg, shots/textblaze-formmenu-doc.jpg | blaze.today/commands/formtext/ , /formmenu/ (CiC) [23] | Editor: each form command is a rounded pill ("default John", "name firstname"; menu pill with a list icon and "Red, Blue, Green, Black"); under it "Snippet preview" with the fields as yellow inputs and dropdowns. |
| shots/textblaze-commands-guide.jpg | blaze.today/commands/ (CiC) [20] | Guide header only; the command panel text is in [21]. |
| shots/raycast-snippet-editor.png | manual.raycast.com/snippets (asset mac-snippets.png) [27] | Plain text box with format toolbar and one bracketed icon bottom right; hint "Include {Dynamic Placeholders} for context like the copied text or the current date" with a link; no inserter list shown. |
| shots/raycast-snippets-manual.jpg | manual.raycast.com/snippets (CiC) [26] | The manual page. |
| shots/alfred-snippets-prefs.png, shots/alfred-snippets-viewer.png, shots/alfred-snip-keyword.png | alfredapp.com/help/features/snippets/ [29] | Collections, snippet table (name, keyword, text), search viewer with preview. No inserter menu: placeholders are typed. |
| shots/snippety-main-screen.png | snippety.app [34] | Preview of a template: pills coloured by family with a type icon and a label: purple for inputs (Email, Type, Recipient, Deadline with calendar icon, Random Value), green for key presses ("Key: tab"). |
| shots/espanso-form-macos.png | espanso.org/docs/matches/extensions/ [31] | Native form dialog: text field, multiline box, dropdown, Submit. |
| shots/typinator-interactive-fields-help.jpg | help.typinator.ergonis.com (CiC) [35] | Help page for {{?First name}} fields (no UI image on it). |

Not captured: Text Blaze command panel (page text only [21]), Raycast and Drafts and Templater inserter UI (docs describe none: UNSURE if an inserter exists), Shortcuts iOS 26 Variables bar (text only [2]). The Variables bar's look is therefore not seen.

## 3. Catalogue

Product keys: SC Shortcuts, KM Keyboard Maestro, TE TextExpander, TB Text Blaze, RC Raycast, AL Alfred, ES Espanso, SN Snippety, TY Typinator, DR Drafts, TP Templater, PG Pages. "In" means the source row shows it. Cutling = has it today. KB = iPhone keyboard extension (needs Full Access where noted), APP = main app on iOS and Mac.

### Blanks and forms (asked when used)

| Kind | Inserts | In | KB / APP | Permission | Read |
|---|---|---|---|---|---|
| Text blank, optional default, same label once | what the person types | SC Ask Each Time [1,4]; KM %Ask% [11]; TE single line [14]; TB formtext [23]; RC argument [25]; SN Text Variable [32]; TY {{?Label}} [35]; ES form [31]; TP prompt [38]; Cutling | yes / yes | none | at use |
| Multi-line blank | paragraph | TE [14]; TB formparagraph [20]; SN multiline [33]; KM %Ask% full width [11]; ES form [31]; TP prompt multiline [38] | yes (typed on the person's own keyboard, as today) | none | at use |
| Choice list, one | one option | TE popup [14]; TB formmenu [23]; RC options [25]; SN Selectable Value [32]; TY popup, allows free text [35]; ES choice [30]; TP suggester [38]; Cutling | yes | none | at use |
| Multi-select | several options joined | TB formmenu [23]; SN Multiselect [32]; TP multi_suggester [38] | yes (checkbox list) | none | at use |
| Yes/no toggle | text included or skipped | TB formtoggle [20]; TY checkbox [35]; TE optional section [14] | yes | none | at use |
| Optional section | a block in or out | TE [14]; SN conditional block [32]; TB if [20] | yes | none | at use |
| Date picker | a chosen date | TE [14]; TB formdate [23]; SN Selectable Date [32] | yes | none | at use |
| Form headings, descriptions, separators | layout only | TY [35]; TE "Show at top" [14] | yes | none | design |
| Auto-increment number | counter | SN [32]; TY counters (title seen in help search, UNSURE) | app (needs saved counter in App Group; KB can read, writing needs Full Access [42]) | none | saved |
| Random value | number, word, UUID, list pick | AL {random} [28]; RC {uuid} [25]; SN Random Value [32]; ES random [30]; TY {/Any} [35]; DR [[uuid]] is the draft's id [36] | yes (no framework) | none | at use |

### Dates and times

| Kind | Inserts | In | KB / APP | Permission | Read |
|---|---|---|---|---|---|
| Date, time, date-time, weekday | now in the person's locale | all of them; SC Current Date [1]; Cutling | yes | none | at use |
| Custom pattern | ICU or strftime pattern | RC [25]; AL [28]; KM ICUDateTime [11]; DR [36]; TE parts as blocks [17]; TB {time} [23]; TY {YYYY}{MM}{DD} [35]; SN [32]; Cutling | yes | none | at use |
| Date math | +3d, -1w | RC, AL, KM Plus/Minus [11], TE math [17], TB shift [23], SN calculated date [32], TY Delta [35], DR [36], Cutling | yes | none | at use |
| Locale override | date in another language | RC locale [25]; DR (it_IT) [36]; SN [32]; Cutling | yes | none | at use |
| ISO 8601, RFC 2822 | machine formats | AL isodate [28]; KM [11] | yes | none | at use |
| Date of the snippet (created, modified) | stamps | DR [36]; TP creation_date [38] | app only (Cutling would need to store dates; it has none in the snippet UI as far as I read: UNSURE) | none | saved |
| Time zone / second clock | time elsewhere | TY community mention via JS only, not read | GUESS yes (TimeZone) | none | at use |

### Me and my contacts

| Kind | Inserts | In | KB / APP | Permission | Read |
|---|---|---|---|---|---|
| My name, nickname, organisation, email, phone | fields of the Me card | KM AddressBook [11]; TB {user} (org member properties, Business plan) [23]; SC Contacts actions, field list UNSURE | GUESS better saved: CNContactStore has no "me" lookup I read; a "My details" screen in Cutling avoids permission | Contacts [45] | saved by app |
| Any field of any contact | e.g. Anna's birthday | SC (Contacts as a Magic Variable; field names not read: UNSURE) | KB: Contacts allowed with Full Access [42]; picking a contact needs a list UI inside 77 MB: UNSURE. APP: yes | NSContactsUsageDescription [45] | at use (pick) or saved (chosen in editor) |
| Other people's values (team) | org-set properties | TB {user} [23] | needs a server: no | account | n/a |
| Recipient name from the current app | name of the chat/mail recipient | KM Mail tokens (sender, recipients, subject) [9]; no iOS equivalent found | no (no API read) | n/a | n/a |
| Greeting by time of day | "Good morning" | TY {/Replace} idea in help text [35] | yes | none | at use |

### Places

| Kind | Inserts | In | KB / APP | Permission | Read |
|---|---|---|---|---|---|
| Coordinates | lat, long | DR [[latitude]] [[longitude]] [36]; SC Current Location [7] | KB: Full Access allows Location Services [42] (device test UNSURE); APP yes | When In Use [44] | at use |
| Address / city / neighbourhood | place name | SC Get Address (not read, UNSURE); SC Current Location [7] | via CLGeocoder [44], needs network, so Full Access: GUESS | Location + network | at use |
| Maps link | URL of the place | derived (GUESS), TB builds a Maps link from variables [21] | yes | Location | at use |
| Wi-Fi name | SSID | KM WirelessNetwork, needs Location permission on Sonoma+ [11] | Mac via CoreWLAN [49]; iOS API not fetched: UNSURE | Location | at use |
| Weather | conditions, temperature | SC Weather Conditions [7] | WeatherKit iOS 16+, macOS 13+ [48]; needs network, so KB needs Full Access (GUESS from [42]); entitlement and account setup not read | Location + WeatherKit entitlement | at use or saved |
| Web page title, URL, selection | from the open page | TB {site} [23]; KM browser tokens [11]; RC browser-tab [25] | no on iOS (no API) / Mac via AppleScript or extension | Automation | at use |

### Music and media

| Kind | Inserts | In | KB / APP | Permission | Read |
|---|---|---|---|---|---|
| Current song (title, artist, album) | now playing | SC Get Current Song [5,7]; KM CurrentTrack name, artist, album, rating [11] | iOS: MPMusicPlayerController.systemMusicPlayer.nowPlayingItem is the Music app's item [46], so Spotify etc. would not show (GUESS); needs media library permission (not read); MPNowPlayingInfoCenter is for your own app's info [46]. Mac: KM reads Music via scripting | Media library | at use |
| Player state | playing / paused | KM MusicPlayerState [11] | same as above | same | at use |
| Share link to the song | music.apple.com URL | not in any source | GUESS only | n/a | n/a |
| Photo / file content | latest photo, file text | SC Select Photos [5]; SN File Content [32] | no (KB has no file access [42]) | Photos | n/a |

### Calendar and reminders

| Kind | Inserts | In | KB / APP | Permission | Read |
|---|---|---|---|---|---|
| Next event (title, time, location, attendees) | upcoming event | SC Get Upcoming Events [5] | EKEventStore iOS 4+, macOS 10.8+ [47]; in a keyboard UNSURE | Calendar (Full Access to events) | at use |
| Next reminder | due item | not in a source I read | same store [47] | Reminders | at use |
| Meeting link / "in 15 minutes" | derived | GUESS | same | Calendar | at use |

### Device

| Kind | Inserts | In | KB / APP | Permission | Read |
|---|---|---|---|---|---|
| Battery level, charging | % | SC (Battery name UNSURE: gated row 8); iOS UIDevice.batteryLevel, batteryState [49] | likely yes in KB (no permission; monitoring must be switched on): UNSURE | none | at use |
| Device name, model, OS version | text | KM MacName, SystemVersion [9]; UIDevice name, systemName [49]; ProcessInfo [49] | yes (iOS may return a generic device name: not read, UNSURE) | none | at use |
| IP address | address | SC Current IP Address [7]; KM MacIPAddress [11] | NWPathMonitor tells connection type only [49]; address needs other APIs (not read) | none | at use |
| Network type (Wi-Fi / cellular) | text | NWPathMonitor iOS 12+ [49] | yes | none | at use |
| Volume, screen resolution, user name, home folder | Mac values | KM [9] | Mac only | none | at use |
| Focus mode, steps, health samples | text | SC Log Health Sample is named [4]; HKHealthStore, CMPedometer [49]; Focus not documented (gated row 8) | UNSURE for KB; sensitive, GUESS skip | Health / Motion | at use |

### Text and clipboard

| Kind | Inserts | In | KB / APP | Permission | Read |
|---|---|---|---|---|---|
| Clipboard | latest copy | all; SC [1]; Cutling | yes; iOS 14+ tells the person when an app reads another app's pasteboard [49] | paste notice | at use |
| Older clipboard items (offset) | 2nd, 3rd | RC offset [25]; AL {clipboard:n} [28]; SN slot 1-10, iOS slot 1 only [33]; KM PastClipboard [9] | iOS no (apps cannot track it, per Snippety [33]); Mac app could | none | at use |
| Selected text | text selected before | RC {selection} [25]; DR [[selection]] [36]; SN [32]; TP file.selection [38] | KB: UITextDocumentProxy.selectedText (not fetched, UNSURE); Mac needs Accessibility | none | at use |
| Text before cursor / current line | context | DR [[line]] [36] | KB via documentContextBeforeInput (existing research) | none | at use |
| Case and cleanup modifiers | upper, lower, trim, title, percent-encode | RC [25]; AL [28]; SN transformations [32]; TY functions [35]; KM \U \L [9] | yes, pure text | none | at use |
| Escape keys / tab / return | non-printing chars | KM [9]; TE keyboard macros [16]; SN Simulated Key [32]; TB {key} [20] | return and tab yes; page-level key presses no | none | at use |
| Cursor position | caret lands here | RC, AL, TE, TB, SN, KM; Cutling | yes (adjustTextPosition) | none | at use |
| Select-to-here | selection after paste | TE [16] | GUESS no in KB | none | n/a |

### Math and logic

| Kind | Inserts | In | KB / APP | Permission | Read |
|---|---|---|---|---|---|
| Calculator / formula | a result | RC {calculator} [25]; KM %Calculate% [11]; TB {=} [20]; TY calculations (article exists, not read) | yes (needs an expression parser) | none | at use |
| If / else | conditional text | TB {if} [20]; SN conditional block [32]; TE optional section [14] | yes | none | at use |
| Repeat | text N times | TB {repeat} [20]; TY {/Repeat} [35] | yes | none | at use |
| Variables set once, reused | named values | KM %Variable% [9]; TB {=} [20]; TY {{x=?}} [35]; SC manual variables [1]; Cutling: same label repeats | yes | none | at use |
| Counter | 1, 2, 3 | SN Auto-Incrementing Number [32] | saved | none | saved |

### Other snippets, scripts, outside data

| Kind | Inserts | In | KB / APP | Permission | Read |
|---|---|---|---|---|---|
| Another snippet | nested text | RC {snippet} [25]; AL {snippet:} [28]; TE Insert Snippet [16]; TY {"abbr"} [35]; TB {import} [20]; SN Snippet Reference [32]; TP file.include [38] | yes; needs a loop guard (AL does not recurse [28]) | none | at use |
| Hyperlink / image | rich link | TE [13]; TB {link} [20]; SN Hyperlink [32] | only for formatted cutlings | none | at use |
| Run script / shell / JavaScript | output | TE script snippets [15]; ES shell, script [30]; SN Command-Line Script [32]; TB {run} [20]; TP [38]; SC Run JavaScript on Webpage [6] | no on iOS (no process spawn) | n/a | n/a |
| Web request | page or API text | TY {/URL} [35]; TB {urlload} gated row 24; TP tp.web.request [38]; SC web APIs [6] | needs network: Full Access (GUESS from [42]); privacy risk | network | at use |
| AI assistant | generated text | SN AI Assistant [32] | no (on-device model access from KB unread) | n/a | n/a |
| Daily quote, random picture | content | TP tp.web [38] | skip | n/a | n/a |
| Comment / note | text not inserted | TB {note} [20]; SN Note [32] | yes (a pill that prints nothing) | none | design |
| Document fields (page number, date) | live fields | PG date and time field, Update All Fields [39] | n/a, they stay live in the doc | none | n/a |
| Mail and Notes fields | none found | gated row 40 | UNSURE | n/a | n/a |

## 4. Inserter patterns that repeat

1. Toolbar of icon buttons, each opening a small menu: TE [13,19]. Fits a Mac editor, poor on a phone.
2. One "Insert" popup with categories and cascading submenus: KM [12] (about 10 categories, hundreds of tokens). The menu inserts plain text, not a pill.
3. Side panel with search and a scrolling command list, then a configuration dialog, then an icon pill in the text; click the pill to reopen it: TB [21]. Same two steps as Apple's.
4. Pick from a context menu on the field (Shortcuts parameter long-press, Mac Control-click) [2].
5. Typing the syntax by hand with colour feedback: RC (braces turn blue when valid) [25], AL [28], DR [36], ES [30]. No picker described in their docs.
6. A helper that writes the syntax: Typinator's input field assistant [35]; SN picks a placeholder type then fills its parameters [32] (its inserter UI itself was not read: UNSURE).
7. Fill at use time as one form: TY single dialog [35], TB popup form [22], TE fill-in window [14], ES native form [31], SN Live Template [32]. Same label asked once everywhere (TE, TY, RC, Cutling).
8. Filled token looks: pill with an icon and a name (SC, TE, TB, SN), colour by family (SC blue, SN purple inputs and green keys), plain text for KM and RC/AL/ES/DR (just braces; RC and AL colour the braces).

## 5. Apple's own pattern (Shortcuts), plainly

On iPhone, tapping a text field shows the keyboard with a Variables bar above it. The first entry is Select Variable; the special variables (Ask Each Time, Clipboard, Current Date, Shortcut Input) sit in the same bar and you swipe left for more [2]. Select Variable switches the editor into a picker view: every action's output appears under that action as a blue pill carrying the action's icon, and you tap one [2,7]. The pill lands inline at the insertion point. Tapping a pill later opens a variable editor sheet at the bottom of the editor with a Type row, a list of the content's details (an Image offers Width, Height, Date Taken, Location, Camera Make), a name and Reveal Action [3]; a circled chevron on a pill marks that it can be adjusted [shots]. For action parameters, tap or touch-and-hold the parameter and pick a variable from a list; the Ask Each Time pill then pauses the run and asks [2,4]. On Mac: Control-click the field, Insert Variable, Select Variable [2]. Pills are blue and show a small icon. So Apple uses a bar for the few common ones plus a picker view for the many, not one long menu.

## 6. Recommendation for Cutling's inserter (GUESS)

Is a plain menu enough? GUESS: no. The catalogue has roughly 60 kinds across 9 groups; a flat list of that length fails on a phone. Every source that has many kinds uses either categories (KM, 10 groups [12]), a searchable panel (TB [21]) or a bar plus picker (Apple [2]). With few kinds the menu is fine; with more it needs grouping and search.

iPhone, in the editor (where the bar above the keyboard already is):
- The bar keeps six or seven chips for the commonest kinds (Blank, Choice, Date, Time, Clipboard, Cursor) as today, with a last chip "All" (Apple's "Select Variable" slot).
- "All" opens a sheet at medium height that grows to large: search field on top; sections Blanks and forms, Dates and times, Me and contacts, Places, Music, Calendar, Device, Text and clipboard, Math; each row an icon, a name, and a live sample of what it would insert now ("Fri 21 Nov", "78%"). Tapping inserts a pill at the cursor and closes the sheet.
- Kinds that need settings (date pattern or math, choices, which contact field) open a second step inside the sheet with a preview (the TE dialog / Shortcuts variable editor idea). Tapping a pill in the text reopens that step.
- Kinds that need a permission (Places, Calendar, Contacts, Music) show a small lock badge in the list; tapping asks for the permission in the app, since the keyboard cannot prompt. A kind whose value the keyboard cannot read stays out of the keyboard's own bar and shows "app only".
- Pills carry an icon and take a colour per group, as Snippety and Apple do, so a snippet reads at a glance.

Mac:
- An "Add Fill-in" button in the editor toolbar opens a popover with the same search field and sections; type to filter, Return inserts, arrow keys move. Same two-step settings pane.
- A right-click on the text field offers the same list as a menu with the group names as submenus (KM and Shortcuts' Control-click pattern), for people who like menus.
- Typing a "{" could offer completion into a pill (KM and RC do completion); GUESS: only if the owner accepts changing the rule that typed braces stay text (docs/fill-ins.md).

Build order GUESS: first the kinds with no permission and no framework (random, counter, time zone, battery, text modifiers, calculator, if), then Places and Contacts (Full Access doc [42] names them), then Calendar and Music after a device test of each inside the keyboard.

## 7. Open questions (UNSURE)

- Whether CoreLocation, EventKit, MediaPlayer and HealthKit calls work and show up with permission inside the 77 MB keyboard, with and without Full Access. Needs one device test per framework.
- Shortcuts' complete variable and action list (Device Details, Battery, Focus, Text Recognition, contact fields): only the in-app list has it.
- How Raycast, Alfred, Drafts, Templater and Snippety present their inserters, if they have one: their docs do not say.
- aText placeholders ([41] is marketing text) and Text Blaze {urlload}.
