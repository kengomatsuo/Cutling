# Text page, Format card, Variables and fill-in editor strings: meaning brief (ASG125, ASG146)

What each on-screen string of the cutling editor's Text page must mean. Every locale is written from this brief
through the `blind-translation` skill; no locale is the source the others are translated from, English included.

Background: Cutling keeps snippets of text and images ("cutlings") and types them into any app through its own
keyboard. A cutling's text opens on a page built like an Apple Notes note: the text fills the screen, and a bar above
the keyboard holds an Aa button (a Format card), buttons that insert variables, then style buttons in Notes' order and
a list button whose menu offers three kinds of list. A variable is a field Cutling fills in when the cutling is used:
a blank the person types each time, a choice, today's date, what is on the clipboard. Register: the app speaking
plainly, short, no exclamation marks. Titles and buttons follow the locale's own title convention (English uses title
case, as Apple's apps do).

Reuse each locale's own words from `Cutling/<locale>.lproj/Localizable.strings`: its word for a cutling, and the
strings already there for "Today's date", "Clipboard text", "Cursor position", "Time", "Default", "Name", "Formatted",
"Cancel", "Done". Where Apple's own apps already name the thing in that language, use Apple's word: the text style
names in the iOS Format menu and in Notes (bold, italic, underline, strikethrough, highlight), Notes' list menu
(bulleted, dashed, numbered) and its Add Link sheet, the Shortcuts app's word for variables and its "ask each time",
Photos' word for a screenshot.

## The Text page and its bar (iPhone and iPad)

| Key | Role | Must say | Budget |
|---|---|---|---|
| TP1 | title of the formatting card, VoiceOver label of the Aa button, and a section header in the date editor listing date styles (one string serves all three) | format (as Notes titles its Format card) | 14 |
| TP2 | VoiceOver label of a style button | bold | 16 |
| TP3 | VoiceOver label of a style button | italic | 16 |
| TP4 | VoiceOver label of a style button | underline | 18 |
| TP5 | VoiceOver label of a style button | strikethrough | 22 |
| TP6 | VoiceOver label of a style button (a highlighter pen icon); turns a coloured highlight on the selected text on or off | highlight | 18 |
| TP7 | VoiceOver label of a style button that sets text in a fixed-width code font | monospace | 22 |
| TP8 | VoiceOver label of the link button, and the title of the sheet it opens (one string serves both) | add a link | 20 |
| TP9 | VoiceOver label of the link button when the text at the cursor already is a link | remove the link | 22 |
| TP10 | VoiceOver label of the list button at the end of the bar | list | 14 |
| TP11 | menu item, beside a bullet-list icon: makes the paragraph a list with round bullets | bulleted (Notes' word) | 18 |
| TP12 | menu item, beside a dash-list icon: a list whose items start with a dash | dashed (Notes' word) | 18 |
| TP13 | menu item, beside a 1-2-3 list icon: a list whose items are numbered | numbered (Notes' word) | 18 |
| TP14 | VoiceOver label of the round button that closes the Format card | close | 14 |
| TP15 | section header in the Add Link sheet, above the address field | link to (Notes' Add Link sheet) | 18 |
| TP16 | placeholder of the field for the link's shown name, which may stay empty | optional | 16 |
| TP17 | a button on the bar that opens the whole list of variables, and that list's title (one string serves both) | variables (the Shortcuts app's word) | 16 |
| TP18 | a variable: a blank the person fills in each time the cutling is used; also its button on the bar | ask each time (the Shortcuts app's phrase) | 24 |
| TP19 | menu item in the editor form that opens the whole list of variables | all variables | 22 |
| TP20 | menu in the editor form (a braces icon) that inserts a variable | add a variable | 22 |

## The Variables list

Grouped like a Settings list: a group header, then rows of an icon, the variable's name and a grey sample at the right.

| Key | Role | Must say | Budget |
|---|---|---|---|
| PK1 | group header: variables the person fills in at the moment they use the cutling | filled in when used | 30 |
| PK2 | group header | dates and times | 24 |
| PK3 | group header: the clipboard's text and where the cursor ends up | clipboard and text | 26 |
| PK4 | a variable: pick one of a few choices each time; also the placeholder of each choice's field in the choice editor | choice | 16 |
| PK5 | grey sample beside PK4: how such a field looks, the default name (CE1) followed by a small down triangle; keep the ▾ | plan ▾ | 14 |
| PK6 | a variable, and a row in the date editor | date and time | 22 |
| PK7 | a variable that writes the day of the week, and a row in the date editor | weekday | 16 |
| PK8 | a variable that writes tomorrow's date, and a row in the date editor | tomorrow | 16 |
| PK9 | a variable that writes yesterday's date, and a row in the date editor | yesterday | 16 |
| PK10 | a variable that writes the date one week from today, and a row in the date editor | in a week | 18 |

## Choice editor

A sheet where a choice variable is named and its choices listed, one ticked as the first offered.

| Key | Role | Must say | Budget |
|---|---|---|---|
| CE1 | default name of a new choice variable, as if a customer picks a plan or tier | plan | 14 |
| CE2 | first default choice | option 1 | 14 |
| CE3 | second default choice | option 2 | 14 |
| CE4 | button that adds another choice | add a choice | 22 |
| CE5 | section header above the choices | choices | 16 |
| CE6 | section footer | the ticked choice is the one filled in first | 60 |

## Date editor

A sheet for a date or time variable: what it shows, in which style, and which day or moment. Each row has a grey
sample at the right.

| Key | Role | Must say | Budget |
|---|---|---|---|
| DE1 | section header: whether it shows a date, a time, both or the weekday | show | 14 |
| DE2 | row | date | 14 |
| DE3 | style row (like Apple's date styles) | short | 14 |
| DE4 | style row | medium | 14 |
| DE5 | style row | long | 14 |
| DE6 | style row | full | 14 |
| DE7 | style row for a time | 24-hour clock | 14 |
| DE8 | row for a style or a day the person set some other way | custom | 16 |
| DE9 | section header for a time: which moment | when | 14 |
| DE10 | section header for a date: which day | day | 14 |
| DE11 | row | now | 14 |
| DE12 | row | in 15 minutes | 22 |
| DE13 | row | in 30 minutes | 22 |
| DE14 | row | in an hour | 22 |
| DE15 | row | today | 14 |
| DE16 | row | in 3 days | 18 |
| DE17 | row | in a month | 18 |

## Undo names

Shown after the system's word for Undo or Redo (in the shake-to-undo alert and the Mac's Edit menu), as Apple's apps
name an action ("Undo Typing"). Write each as the locale names an action there.

| Key | Must say | Budget |
|---|---|---|
| UN1 | change the text | 24 |
| UN2 | change the name | 24 |
| UN3 | change the colour | 24 |
| UN4 | change the input types (the kinds of field, such as email or phone, where Cutling suggests this cutling) | 30 |
| UN5 | change the expiry (when the cutling deletes itself) | 26 |
| UN6 | change the image | 24 |

## Elsewhere in the app

| Key | Role | Must say | Budget |
|---|---|---|---|
| MS1 | alert line when no more cutlings can be added | no more cutlings can be added | 60 |
| MS2 | start of a saved screenshot's name, followed by its date and time | screenshot (Photos' word) | 16 |
| MS3 | button in a Shortcuts result that opens the cutling in the app | open | 14 |
| MS4 | title of the app's keyboard settings screen | keyboard (the locale's word in Settings) | 20 |
| MS5 | alert title when an image dragged into the app cannot be read | couldn't read the image | 30 |
| MS6 | that alert's line | the dropped image couldn't be loaded | 60 |
| MS7 | alert title when the same cutling already exists | already saved | 24 |
| MS8 | that alert's line | a cutling with the same content already exists | 60 |
| MS9 | name given to an image shared to Cutling from another app | shared image | 20 |
| MS10 | what Siri or Shortcuts answers when the text or image is already a cutling | already saved (a sentence) | 30 |

## How writers hand back

One JSON file per language at `docs/research/text-page/strings/<language>.json`:
`{"folders": ["de", "de-DE"], "strings": {"TP1": "...", ...}, "back": {"TP1": "literal back-translation", ...}, "notes": "register and grammar choices"}`.
Keys are the IDs above (TP1-TP20, PK1-PK10, CE1-CE6, DE1-DE17, UN1-UN6, MS1-MS10). PK5 keeps its ▾. If the locale's
`Localizable.strings` already holds a string that says exactly the same thing, reuse it.
