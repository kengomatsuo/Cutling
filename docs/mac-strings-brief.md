# Mac app strings: meaning brief

What each macOS-only string in `Cutling/Mac/*.swift` has to MEAN. Locale writers work
from this file and the locale's existing `Localizable.strings`, never from the English
string. No locale is the source the others are translated from; English is a peer.

Written 2026-10-01, when these keys were found missing from every `.lproj`.

## Rules for every string

- Reader: someone using Cutling, a clipboard manager, on their own Mac. Talk to them the
  way that language's macOS system UI talks to its user (the same politeness level the
  locale file already uses).
- Reuse the locale file's established words: its form of "Cutling" and "cutlings",
  "clipboard history", "Recently Deleted", "Settings", "hotkey"/shortcut, "picker",
  "Accessibility", "iCloud", "History" tab, input-type names. Two screens must never
  name one thing twice.
- Apple's own UI names (System Settings, Login Items, Finder, the File menu, Keyboard
  Shortcuts, Privacy & Security, menu bar) use the exact word Apple's macOS uses in that
  language.
- Keep `%@` placeholders exactly; move them wherever the grammar wants.
- Buttons and toggles: verb + object, short. Headers and tab labels: noun phrase, short.
- "…" at the end of a button means it opens another window or dialog; keep it.

## Keys

| ID | Where and when | Role, budget | Must mean |
|---|---|---|---|
| M01 | Settings → shortcut tab. Next to a box showing the current key combination, e.g. ⌥⌘V. | button, ≤10 chars | Start listening so the next key combination pressed becomes the new shortcut. |
| M02 | Same row as M01. | button, ≤10 chars | Put the shortcut back to the app's default combination. |
| M03 | Title bar of the window that edits an existing saved cutling. | window title, ≤25 | Editing this cutling. |
| M04 | Inside that window when the cutling was deleted elsewhere before the window opened. | grey placeholder line, ≤30 | This cutling no longer exists / could not be found. |
| M05 | Picker popover, small warning strip: "Direct paste needs Accessibility access." Clicking opens System Settings. | tiny link-style button, ≤10 | Give that permission (opens a window). |
| M06 | Right-click menu on a saved cutling in the picker. | menu item | Edit it (opens the editor window). |
| M07 | Right-click menu on a clipboard-history item. | menu item | Keep this history item permanently as a saved cutling. |
| M08 | Tooltip on the + button in the picker footer. | tooltip | Make a new cutling. |
| M09 | Tooltip on the ? button in the picker footer; opens the website. | tooltip, one word | Help. |
| M10 | Button on the picker's History tab footer, and in Settings → Storage under the clipboard history counts. | button, ≤20 | Remove every entry from the clipboard history. |
| M11 | Tooltip on the power button in the picker footer. | tooltip | Quit the Cutling app. |
| M12 | Settings window toolbar tab, icon ⌘, holding the global keyboard shortcut. Sits beside tabs General, Paste, iCloud, Storage, Recently Deleted. | tab label, one word ideal, ≤12 | The keyboard shortcut that opens Cutling. Use the locale file's existing word for "hotkey" if it has one. |
| M13 | Settings toolbar tab for the direct-paste option and its permission. The locale file already names this tab in its line about skipping Accessibility and granting it later from Settings → (this tab). | tab label, one word, ≤12 | Pasting. Must match that existing line's tab name exactly. |
| M14 | Settings → Paste tab, Permission section, shown while Accessibility access is not granted. | button, ≤30 | Give Accessibility access (opens system prompt / System Settings). |
| M15 | Same section. Reveals the app file itself in a Finder window. | button | Show the file "Cutling.app" in Finder. Keep `Cutling.app` literally. |
| M16 | Settings → General, first toggle. | toggle label | Open Cutling automatically when the user logs in to the Mac. |
| M17 | Under M16. Opens System Settings at General → Login Items. | button with … | Open Login Items in System Settings (Apple's own names for both). |
| M18 | Header of the section holding M16/M17. | section header, 1–2 words | What happens when the Mac starts / login. |
| M19 | Footer under M16/M17. | 2 sentences | When on, Cutling starts by itself each time you log in to this Mac. The first time, macOS may ask you to approve it. |
| M20 | Settings → General, toggle. | toggle label | Show Cutling's icon in the menu bar. |
| M21 | Header of the section holding M20. | section header | The menu bar. |
| M22 | Footer under M20. | 2 sentences | Turn the icon off if you only want to open Cutling with the keyboard shortcut. Cutling keeps running in the background and the shortcut still works. |
| M23 | Settings → General, toggle. | toggle label | Record clipboard history (keep what the user copies). |
| M24 | Footer under M23. | 2 sentences | Everything you copy is saved to the History tab automatically. Anything a password manager marks as hidden/confidential is skipped. |
| M25 | Settings → General, toggle. | toggle label | Detect input types automatically. Use the locale file's word for "input type". |
| M26 | Footer under M25. | 1 sentence | While you edit a text cutling, Cutling suggests input type categories: email, URL, phone, name, address (use the locale file's names for these five). |
| M27 | Settings → General, Help section, button. | button | Show the welcome screens (the ones seen on first launch) again. |
| M28 | Same section, button. | button | Reset the tips so they show again. Use the locale file's word for tips. |
| M29 | Header of that section. | section header | Help and tips. |
| M30 | Footer under M27/M28. | 1 sentence | Open the first-launch welcome again, or reset the tips so the in-context hints come back while you use Cutling. |
| M31 | Settings → shortcut tab, row label left of the shortcut box. | row label, ≤20 | What the shortcut does: open the picker (the popover listing cutlings). Use the locale file's word for picker. |
| M32 | Header of that section. | section header | Shortcut that works system-wide, from any app. |
| M33 | Footer under it. | 2 sentences | Press this shortcut in any app to bring up the clipboard picker. If nothing happens, another app or macOS may already use the same keys: check System Settings → Keyboard → Keyboard Shortcuts (Apple's names). |
| M34 | Settings → iCloud tab, footer under the iCloud Sync toggle. | 2 short sentences | Saved cutlings sync to your other devices. Clipboard history is never synced; it stays only on this Mac. |
| M35 | Settings → Storage tab, section header over counts like "12 / 100". | section header | Saved cutlings (as opposed to history). |
| M36 | Row label in M35, value "3 / 25". | row label, one word | Images (count of image cutlings). |
| M37 | Row label, value is a total count ("15 / 125") in one section and total disk size ("4.2 MB") in another. | row label, one word | Total. |
| M38 | Storage tab, section header over the history entry count. | section header | Clipboard history (title form). |
| M39 | Row label under M38, value "42 / 200". | row label, one word | Number of entries/items. |
| M40 | Row label in the disk-usage section, value "1.3 MB". | row label | Clipboard history (sentence form; may be identical to M38). |
| M41 | Row label in the disk-usage section, value "800 KB". | row label | Recently deleted (items waiting in the trash-like area). |
| M42 | Row label in the disk-usage section, orange value "120 KB", shown only when present. | row label | Image files left on disk that no cutling uses any more. Short. |
| M43 | Button under M42. | button | Delete those leftover files. |
| M44 | Header of the disk-usage section. | section header | Disk space used by images. |
| M45 | Footer under it. | 2 sentences | Images captured from the clipboard and images in saved cutlings are stored inside the app's own storage. Recently deleted images stay until they are deleted for good or until you empty Recently Deleted. |
| M46 | Settings → Recently Deleted tab, empty state under a trash icon. | 1 line | There are no recently deleted cutlings. |
| M47 | Header over the list of deleted cutlings, number on the right. | section header | Deleted cutlings. |
| M48 | Footer under that list. | 2 sentences | Cutlings stay here 30 days, then are removed for good. Deletions sync across devices through iCloud. |
| M49 | Destructive red button under the list, and the red confirm button in the dialog that follows. | button, ≤20 | Permanently delete everything in Recently Deleted (empty it). |
| M50 | Title of the confirmation dialog after M49. | question | Delete all recently deleted cutlings permanently? |
| M51 | Message under M50 and similar dialogs. | 1 sentence | This action can't be reversed. |
| M52 | Title of the confirmation dialog after the row's Delete button. | question | Delete this cutling permanently? |
| M53 | Red confirm button in that dialog. | button | Delete permanently. |
| M54 | Message in that dialog. `%@` = the cutling's name, e.g. "Home address". | 1 sentence | %@ will be deleted permanently. |
| M55 | Small button on each deleted row. | button, one word | Restore (bring back to saved cutlings). |
| M56 | Popover title just under the menu bar, with an arrow pointing up at Cutling's menu bar icon, right after first launch. | title, ≤25 | Cutling lives up here (in the menu bar). |
| M57 | Line under M56. `%@` = the shortcut, e.g. "⌥⌘V". | 1 sentence | Click the clipboard icon, or press %@ in any app, to open the picker. |
| M58 | Welcome window, a drawn mock of the macOS menu bar: the bold first menu, which on a real Mac shows the frontmost app's name. | placeholder, one short word | Stand-in for "the app's name" / an app. |
| M59 | Same mock, the menu after it. | one word | The File menu, exactly as macOS names it in that language. |
| M60 | Welcome window, iCloud step, small grey line under the iCloud toggle. | 1 sentence | You can change this later in Settings → iCloud. Use this locale's existing "Settings" and the iCloud tab name, joined by → like the existing "Settings → (Paste tab)" line. |
| M61 | Settings → shortcut tab, inside the box that normally shows the current combination, while it waits for a new one after M01. | placeholder, ≤25 | Press the new key combination now. |
| M62 | Red item in the right-click menu on a clipboard-history entry in the picker. The entry is gone for good; it does not go to Recently Deleted. | menu item, ≤25 | Remove this entry from the history. |
| M63 | Settings → Paste tab, grey status at the right end of the Accessibility access row. | status, one or two words | The permission has been given. |
| M64 | Same spot. | status, ≤15 | The permission has not been given yet. |
| M65 | Grey one-line preview under a text cutling's name (picker list, Recently Deleted rows) when its text is blank. | preview text, one word | Empty: there is no text. |
| M66 | Right-click menu on a Rich (formatted) cutling in the picker, under Copy. | menu item, ≤25 | Copy it without bold, italic or links. |
| M67 | Settings → General, toggle. | toggle label, ≤35 | Every paste from Cutling drops formatting. |
| M68 | Footer under M67. "⌥-click" stays as the symbol. | footer, ≤110 | Formatted cutlings keep bold, italic and links when pasted; holding ⌥ while clicking one pastes it without formatting. |
