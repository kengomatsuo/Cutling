# Fill-in strings: meaning brief

What each new on-screen string for fill-ins and date stamps must mean. Every locale, English included, is written from this brief; no locale is the source the others are translated from. Reuse the words each locale already uses in `Cutling/<locale>.lproj/Localizable.strings` (its word for snippet or "cutling", clipboard, cursor, paste).

Background a writer needs: Cutling is an app that keeps snippets of text (addresses, replies, signatures) and types them into any app through its own iPhone keyboard, or pastes them on a Mac. A snippet can now hold **blanks** (a person's name, an order number) that the person fills each time they use it, and **stamps** that turn into today's date or the current time. The register is the app speaking plainly to its user, short, friendly, no exclamation marks.

## iPhone keyboard: the fill-in panel

The person tapped a snippet in Cutling's keyboard. Cutling typed the snippet up to its first blank and now shows a panel in place of the snippet grid. The panel shows the blank's name in large type (for example "Name"), a small grey line under it, a row of one-tap values (clipboard, values used before), and a green button on the right.

| Key | Role | What it must say | Budget |
|---|---|---|---|
| K1 `progress` | small grey counter, top right | which blank this is out of how many, with two numbers, e.g. "1 of 2". Format string with two integers, written `%lld` twice in order (current, total). | 10 chars |
| K2 `hint` | small grey line under the blank's name, beside a globe icon | tells the person to type the value with their usual keyboard (they switch with the globe key and type it straight into the app's text field; Cutling waits). An instruction, not a sentence about Cutling. | 32 chars |

The panel's other controls reuse words the locale already has: the clipboard chip uses its "Paste", the green button its "Next" (more blanks follow) or "Done" (last blank: types the rest), and the ✕ button's spoken label its "Cancel".

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
