# Where Apple puts the checkmark (card ASG160), fetched 2026-11-22

Question: in a list where one option is picked, is the checkmark at the leading or the trailing end of the row? Answer: **trailing in a list, leading in a menu.** Cutling's fill-in editor had it leading in a list, so it now uses SwiftUI's inline `Picker`, which draws Apple's trailing tick itself.

| File | Source | What it shows |
|---|---|---|
| `hig-menus-toggled-item.png` | HIG, Menus, https://developer.apple.com/design/human-interface-guidelines/menus | A menu with "a checkmark icon on the leading edge" of the picked item (Apple's alt text). Menus tick leading. |
| `hig-pop-up-button-open.png` | HIG, Pop-up buttons, https://developer.apple.com/design/human-interface-guidelines/pop-up-buttons | Calendar on iPhone, the Repeat pop-up menu open: the tick sits left of "Never". A menu, so leading. |
| `uikit-tableviewcell-accessory-area.png` | UIKit, UITableViewCell, https://developer.apple.com/documentation/uikit/uitableviewcell | A cell's accessory view sits at the trailing end. `UITableViewCell.AccessoryType.checkmark` ("A checkmark image") is that accessory, so a list ticks trailing. |
| `apple-calendar-calendars-list.png` | iPhone User Guide, Set up multiple calendars, https://support.apple.com/guide/iphone/set-up-multiple-calendars-iph3d1110d4/ios | Calendar's Calendars list: a many-pick list of coloured check circles on the leading edge. A many-pick toggle in the calendar's own colour, not a one-pick list; shown for contrast. |
| `sim-settings-date-format.png`, `sim-settings-temperature.png`, `sim-settings-first-day-of-week.png`, `sim-calendar-default-alert.png` | Settings on the iOS 27 simulator (iPhone), 2026-11-22, shot by `CutlingUITests/DateEditorUITests.testAppleCheckmarkLists` | Apple's own one-pick lists: General > Language & Region > Date Format, Temperature and First Day of Week, and Apps > Calendar > Default Alert Times > Events. Each ticks the picked row at its trailing end. (Auto-Lock is not on the simulator.) |

Apple's words: the HIG's Lists and tables page says a table that lists options "often highlights a row only briefly before adding an image — such as a checkmark"; its Menus page says to "consider using a checkmark to show that an attribute is currently in effect" in a menu.

Shortcuts, for the date editor's other two fixes (pages saved in `docs/research/editor-notes/pages/`):

- `sc_ios_adjust_variables.txt` (https://support.apple.com/guide/shortcuts/adjust-variables-apda36b9018b/ios): after a detail is chosen in the variable editor, "The variable token is updated to indicate your preference." Cutling's date pill now shows what it will type.
- `sc_ios_custom_date.txt` (https://support.apple.com/guide/shortcuts/custom-date-formats-apd8d9b19184/ios): Format Date's Custom shows a Format String field of Unicode TR35 patterns, with a table of example patterns and results and a tip that text in single quotes is typed as written. Cutling's Custom row does the same, with tappable examples.
- `sc_ios_date_formats.txt` (https://support.apple.com/guide/shortcuts/date-and-time-formats-apdfbad418ca/ios): Short, Medium and Long are "the most convenient and simple date formats". Cutling offers Default (Medium), Short and Long, plus ISO 8601 and Custom.
