# How Apple's own apps let you write a field's text at full size (2026-11-21)

The job: write the cutling's text at full size, with formatting and variables, from the editing form.

Apple's guide pages picture few of these screens, so three rows are Apple's words only, and four apps were not looked at in this pass (Messages' draft, Reminders' notes, Contacts' notes, Journal): no picture or text of them is saved here, and nothing below rests on them.

| App | Evidence | What it does for a long text |
|---|---|---|
| Mail's signature, in Settings | Apple's words, no picture: "Tap Signature (below Composing). Tap the text field, then edit your signature." https://support.apple.com/guide/iphone/change-mail-settings-iph80dabb18b/ios | A row in a list leads to a page that holds only the text. No button beside the text. |
| Notes | `notes-ios27-note-is-the-page.png` (Apple, iPhone guide for iOS 27); the owner's recording in `../owner-recording/` | A row in the list shows the note's start; a tap opens the note as the whole page. |
| Calendar's event form | Apple's words, no picture: "In the event details, tap a setting to change it, or tap in a field to type new information." https://support.apple.com/guide/iphone/create-and-edit-events-in-calendar-iph3d110f84/26/ios/26 | The field is typed in where it stands and grows; there is no full-size view. |
| Shortcuts' text fields | `shortcuts-ios26-text-field-inline.png` (Apple, Shortcuts guide) | Typed in where they stand inside the action's card, variables as pills; no full-size view. |
| Translate | `translate-ios-enter-full-screen.png` (Apple, iPhone guide): "Show the translation in full screen: Tap the Enter Full Screen button." | The one Apple app found with a full-screen control on a text: a tinted icon inside the card's bottom row, for showing a result, not for writing. |

## What this says

- Apple never puts a labelled row beside a text box to open that same text elsewhere. A text is either typed where it stands (Calendar, Shortcuts) or shown as a row and written on its own page (Notes, Mail's signature).
- The shape for "write it at full size" is therefore the second: the form shows the text, and the text itself is the way in.

## What Cutling does with it

The form's Text box shows the text as it reads (pills drawn, up to eight lines) with a disclosure chevron, and a tap opens the Text page with the keyboard up. There is no separate row or icon. A new cutling's Return on the Name field goes on to the page. The interactive walkthrough and the Mac still type in the box itself.

Rejected: the icon in the section header (the owner: "doesn't even look like it's tappable"), the "Variables & Formatting" row (the owner: "kinda ick"), and Translate's icon inside the box (an icon again, and Apple uses it for showing, not writing).
