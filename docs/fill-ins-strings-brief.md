# Fill-in strings: meaning brief

What each new on-screen string for fill-ins and date stamps must mean. Every locale, English included, is written from this brief; no locale is the source the others are translated from. Reuse the words each locale already uses in `Cutling/<locale>.lproj/Localizable.strings` (its word for snippet or "cutling", clipboard, cursor, paste).

Background a writer needs: Cutling is an app that keeps snippets of text (addresses, replies, signatures) and types them into any app through its own iPhone keyboard, or pastes them on a Mac. A snippet can now hold **blanks** (a person's name, an order number) that the person fills each time they use it, and **stamps** that turn into today's date or the current time. The register is the app speaking plainly to its user, short, friendly, no exclamation marks.

## iPhone and iPad keyboard: the fill-in screen (board ASG91)

The person tapped a snippet with blanks in Cutling's keyboard. Nothing is typed yet. The keyboard's top bar shows the snippet's whole sentence on one line with the blank it waits for in green (for example "Hi Name, your order ships today." with "Name" green) and an ✕ on the right. Below is one wide key across the keyboard, green text beside a keyboard icon, then smaller keys holding values for this blank (its choices, values used before, the clipboard key). The bottom row keeps the globe, delete, space and a green return key. Cutling has no letter keys of its own, so any value the person types is typed on their own regular keyboard, straight into the app's text field.

| Key | Role | What it must say | Budget |
|---|---|---|---|
| K3 `own-keyboard` | label of the wide key | Tapping it switches to the person's own regular keyboard (the one they normally type letters on, in their language) so they type the blank's value there and then come back to Cutling with the globe key. Names that action as a button label in the locale's own button convention (capitals, verb form). Must not read as switching to Cutling's keyboard or to "the next keyboard". | one line on the narrowest iPhone: about 30 Latin characters, 15 CJK, 22 Indic, Thai or Arabic-script characters |
| K4 `insert` | VoiceOver label of the green return key while the last blank waits | Pressing it puts the finished text, every blank filled, into the app's text field. A verb, in the form the locale uses for a key's spoken label. Must differ from the locale's word on the clipboard key (which only fills the blank), because both keys can be on screen. | 15 chars |
| K5 `announce` | VoiceOver announcement when a blank comes up | The blank's own label, then which blank this is out of how many. Three variables: the label as the person wrote it (e.g. "Name", "Order number"), this blank's number (1) and the number of blanks (2). Spoken, so short, like the position VoiceOver reads in a list. Positional specifiers (`%1$@ %2$lld %3$lld`) where the locale's order differs from label, number, total. | spoken; about 25 chars plus the label |

The screen's other controls reuse words the locale already has: the clipboard key its "Paste", the return key's spoken label on earlier blanks its "Next", and the ✕ button's spoken label its "Cancel". The earlier panel's counter, hint line and last-blank "Done" are gone. Per-locale results and their back-check: [fill-ins-strings-check.md](fill-ins-strings-check.md).

## Snippet editor: the menu that adds blanks and stamps

The person is editing a snippet's text on iPhone, iPad or Mac. Below the text box, under the "Paste from Clipboard" button, is a menu button. Its items each put a short code at the text cursor; the code is replaced with a real value every time the snippet is typed or copied.

| Key | Role | What it must say | Budget |
|---|---|---|---|
| A1 `menu` | menu button label, with a curly-braces icon | opens a menu for adding a blank or a date to this snippet | 28 chars |
| A2 `section` | small grey title at the top of the open menu | everything below is replaced with its real value each time the snippet is used | 40 chars |
| A3 `field` | menu item | adds a blank the person fills in each time (like a name) | 22 chars |
| A4 `date` | menu item | adds today's date (the date on the day it is used) | 22 chars |
| A5 `time` | menu item | adds the current time (at the moment it is used) | 16 chars |
| A6 `cursor` | menu item | marks where the text cursor ends up after the snippet is typed | 22 chars |
| A7 `clipboard` | menu item | adds whatever text is on the clipboard when the snippet is used | 22 chars |

A new blank is named with the locale's existing word for "Name" (the same word the editor's name field uses).

## Snippet editor: the one-time tip on that menu (board ASG91)

iPhone and iPad only. The person opens a text snippet's editor for the second time or later (never the first, which the tutorial covers). In the editor's Text section, under the text box and the Paste from Clipboard row, sits the A1 menu row. A tip bubble (Apple's standard TipKit popover) shows above that row with its arrow pointing at it: a curly-braces icon on the left, a bold title line, a smaller message under it, and an ✕ that closes it. It shows once and never again. The person may never have noticed the row, since plain snippets never need it. Each locale reuses its own A1, A3 and A4 words, its word for a snippet, and the register and title convention of its existing tips (the More menu tip, the drag-to-select tip, the smart field matching tip).

| Key | Role | What it must say | Budget |
|---|---|---|---|
| T1 `tip-title` | bold title line of the tip | names the two things the row adds, blanks and dates; a short noun phrase, no end punctuation, capitalised the way the locale's existing tip titles are; it must not read as one thing filled with the other | one line in the bubble on the narrowest iPhone: about 26 Latin characters, 13 CJK, 20 Indic, Thai or Arabic-script characters |
| T2 `tip-message` | the tip's message under the title | one sentence: with this row the person can put into this snippet a blank they fill in each time they use the snippet, or today's date; spoken to the person in the register the locale's existing strings use. The date is named the way the locale's A4 item names it, with no second clause explaining it, since the menu's A2 heading already says values fill in at each use. "Each time" must belong to filling the blank, never to adding it, and the date must read as the second thing added, never as something the person uses | at most three lines in the bubble: about 100 Latin characters, 50 CJK, 80 Indic, Thai or Arabic-script characters |
