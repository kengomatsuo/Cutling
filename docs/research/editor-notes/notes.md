# Sources for ASG125 and ASG126, fetched 2026-11-21

Guide pages were fetched with curl (server-rendered, full text) and the main ones also opened in Claude in Chrome for a capture (`shots/cic-*`). Text Blaze plans were read in Chrome. `pages/_fetch/` holds the fetch script, the URL lists and each page's image list.

| # | URL | saved file | what to take |
|---|---|---|---|
| 1 | https://support.apple.com/guide/iphone/get-started-with-notes-iph9e04f3be2/27/ios/27 | `pages/ios_notes_get_started.txt` | Notes on iOS 27 overview; five pictures (note, quick note, scan, markup, share) |
| 2 | https://support.apple.com/guide/iphone/create-and-format-notes-iph1ac0b3a2/27/ios/27 | `pages/ios_notes_create_format.txt` | First line is the title, Done saves, Format button, checklist, table, divider, collapsible headings |
| 3 | https://support.apple.com/guide/iphone/use-quick-notes-iph5084c0387/27/ios/27 | `pages/ios_notes_quick_notes.txt` | Quick Note sheet with the bar above the keyboard (`shots/iphone-notes-quick-note-save.png`) |
| 4 | https://support.apple.com/guide/iphone/add-drawings-and-handwriting-iphd939f0a1c/27/ios/27 | `pages/ios_notes_drawings.txt` | Markup tray |
| 5 | https://support.apple.com/guide/iphone/add-photos-video-and-more-iph23f4d9aa9/27/ios/27 | `pages/ios_notes_photos.txt` | Attachments button and its options |
| 6 | https://support.apple.com/guide/iphone/scan-text-and-documents-iph653f28965/27/ios/27 | `pages/ios_notes_scan.txt` | Scan from the paperclip |
| 7 | https://support.apple.com/guide/iphone/add-links-iph908d1558b/27/ios/27 | `pages/ios_notes_links.txt` | Add Link from the edit menu, link to note or section, ">>", data detectors |
| 8 | https://support.apple.com/guide/iphone/search-notes-iphb8628c6b8/27/ios/27 | `pages/ios_notes_search.txt` | Find in Note from Note Actions |
| 9 | https://support.apple.com/guide/iphone/share-and-collaborate-iphe4d04f674/27/ios/27 | `pages/ios_notes_share.txt` | Send a Copy, Share a Link, permissions, activity, @mention |
| 10 | https://support.apple.com/guide/iphone/export-or-print-notes-iphdf551cfa2/27/ios/27 | `pages/ios_notes_export.txt` | Export as Markdown exists |
| 11 | https://support.apple.com/guide/ipad/create-and-format-notes-ipad99e3f0bb/27/ipados/27 | `pages/ipad_notes_create_format.txt` | Same steps on iPad; bar at the top of the note |
| 12 | https://support.apple.com/guide/ipad/add-links-ipad03a11b57/27/ipados/27 | `pages/ipad_notes_links.txt` | Add Link popover on iPad, undo and redo in the top bar |
| 13 | https://support.apple.com/guide/ipad/share-and-collaborate-ipad8c7b03b9/27/ipados/27 | `pages/ipad_notes_share.txt` | Share popover on iPad |
| 14 | https://support.apple.com/guide/ipad/use-keyboard-shortcuts-ipad8a907a42/27/ipados/27 | `pages/ipad_notes_shortcuts.txt` | Hardware keyboard shortcuts in Notes |
| 15 | https://support.apple.com/guide/notes/get-started-apd441e46563/4.13/mac/27 | `pages/mac_notes_get_started.txt` | Mac toolbar: Aa, checklist, table, media, markup, Writing Tools |
| 16 | https://support.apple.com/guide/notes/format-notes-apd1955d3b21/4.13/mac/27 | `pages/mac_notes_format.txt` | Styles, highlight, alignment, divider (Command-L), collapsible sections |
| 17 | https://support.apple.com/guide/notes/create-and-edit-notes-not9474646a9/4.13/mac/27 | `pages/mac_notes_create_edit.txt` | "Your note saves automatically as you work" |
| 18 | https://support.apple.com/guide/notes/add-lists-apd93c815aa0/4.13/mac/27 | `pages/mac_notes_lists.txt` | Lists and checklists on Mac |
| 19 | https://support.apple.com/guide/notes/add-a-table-apd0a136b9cc/4.13/mac/27 | `pages/mac_notes_table.txt` | Table button, column handles |
| 20 | https://support.apple.com/guide/notes/share-notes-and-collaborate-apd4e6e2c9a6/4.13/mac/27 | `pages/mac_notes_share.txt` | Share menu, activity highlights |
| 21 | https://support.apple.com/guide/notes/search-your-notes-not18ab658ed/4.13/mac/27 | `pages/mac_notes_search.txt` | Search and suggested searches |
| 22 | https://support.apple.com/en-us/118442 | `pages/apple_use_notes_118442.txt` | Apple's pictures of the Format panel (iOS 26), paperclip menu and Add Link menu (iOS 27) |
| 23 | https://itunes.apple.com/lookup?id=1110145109&country=us | `pages/lookup_notes_1110145109.json` | Notes 2.12 (2026-10-26) App Store screenshots, iPhone and iPad |
| 24 | https://support.apple.com/guide/shortcuts/use-variables-apdd02c2780c/4.0/ios/15.0 | `pages/sc_4.0_use-variables.txt` | Pictures of the Variables bar, expanded bar, special variables, pill in a text field, Ask Each Time prompt |
| 25 | https://support.apple.com/guide/shortcuts/adjust-variables-apda36b9018b/4.0/ios/15.0 | `pages/sc_4.0_adjust-variables.txt` | Pictures of the variable editor that opens when a pill is tapped |
| 26 | https://support.apple.com/guide/shortcuts/variable-types-apdd2b316022/4.0/ios/15.0 | `pages/sc_4.0_variable-types.txt` | Picture of the bar above the keyboard and the Magic Variable picker |
| 27 | https://support.apple.com/guide/shortcuts/use-the-ask-each-time-variable-apd8b28e2166/4.0/ios/15.0 | `pages/sc_4.0_use-the-ask-each-time-variable.txt` | Ask Each Time pill and run-time prompt pictures |
| 28 | https://support.apple.com/guide/shortcuts/variable-types-apdd2b316022/10.0/ios/27 | `pages/sc_ios_variable_types.txt` | iOS 27 text: Magic, special and manual variables; pills carry the action's icon |
| 29 | https://support.apple.com/guide/shortcuts/use-variables-apdd02c2780c/10.0/ios/27 | `pages/sc_ios_use_variables.txt` | iOS 27 text: Variables bar, Select Variable, inline at the insertion point, remove with delete |
| 30 | https://support.apple.com/guide/shortcuts/adjust-variables-apda36b9018b/10.0/ios/27 | `pages/sc_ios_adjust_variables.txt` | iOS 27 text: tap a token, variable editor, Type row, property list, rename, Reveal Action |
| 31 | https://support.apple.com/guide/shortcuts/use-the-ask-each-time-variable-apd8b28e2166/10.0/ios/27 | `pages/sc_ios_ask_each_time.txt` | Shortcut pauses and prompts, Done continues |
| 32 | https://support.apple.com/guide/shortcuts/date-and-time-formats-apdfbad418ca/10.0/ios/27 | `pages/sc_ios_date_formats.txt` | None, Short, Medium, Long for date and for time |
| 33 | https://support.apple.com/guide/shortcuts/custom-date-formats-apd8d9b19184/10.0/ios/27 | `pages/sc_ios_custom_date.txt` | Custom format uses Unicode TS 35 patterns |
| 34 | https://support.apple.com/guide/shortcuts-mac/use-variables-apdd02c2780c/10.0/mac/27 | `pages/sc_mac_use_variables.txt` | Mac: Control-click, Insert Variable |
| 35 | https://support.apple.com/guide/shortcuts/intro-to-variables-apdb5506f698/8.0/ios/26 | `pages/sc_8.0_intro-to-variables.txt` | iOS 26 picture of pills in a Text action (`shots/sc-ios26-variable-examples-in-shortcut-editor.png`) |
| 36 | https://manual.raycast.com/snippets.md | `pages/raycast_snippets.md` | "Snippet text has a maximum length of 65K characters. This limit exists for performance reasons"; Mac, Windows, iOS |
| 37 | https://blaze.today/plans/ (Chrome) | `pages/textblaze_plans_chrome_2026-11-21.txt` | Free "Limited snippets", Pro $2.99, Business $6.99; no per-snippet character number printed |
| 38 | https://snippety.app/help/release-notes/ios/ | `pages/snippety_ios_release.html` | "Improved the snippet editor, including form scrolling and full-screen template mode." |
| 39 | https://community.blaze.today/t/25k-character-limit-too-small-for-snippets/51365 | `pages/textblaze_community_51365.json` | User hits "25,000 character limit for snippets" (2025-06-25); staff reply does not dispute it |
| 40 | https://community.blaze.today/t/2500-character-limit/59789 | `pages/textblaze_community_59789.json` | Basic plan "has a 2500 character limit" (2026-02-11); staff: "The paid plans have higher character limits" |
| 41 | https://developer.apple.com/documentation/cloudkit/ckrecord | `pages/apple_ckrecord.json` | "the data that a record stores must not exceed 1 MB. Assets don't count toward this limit" |
| 42 | https://developer.apple.com/documentation/uikit/uitextdocumentproxy , /uikit/uikeyinput/inserttext(_:) , /uikit/creating-a-custom-keyboard | `pages/apple_uitextdocumentproxy.md`, `pages/apple_uikeyinput_inserttext.md`, `pages/apple_creating_a_custom_keyboard.md` | No length limit stated for insertText; "The memory limits vary from model to model" |
| 43 | https://itunes.apple.com/lookup?id=1530751461 (Snippety), 6805960547 (TextExpander), 967805235 (Paste), 1503446680 (PastePal), 6503428327 (Raycast) | `pages/lookup_snippety_1530751461.json`, `pages/lookup_textexpander_6805960547.json`, `pages/lookup_paste_967805235.json`, `pages/lookup_pastepal_1503446680.json`, `pages/lookup_raycast_6503428327.json` | App Store screenshots of each rival's iPhone app (`shots/appstore-*`) |
| 44 | https://textexpander.com/pricing , https://pasteapp.io/help | `pages/textexpander_pricing.html`, `pages/paste_help.html` | Neither page text mentions a per-snippet character limit (word search for "character", "maximum length", "size limit": no hits) |
| 45 | Cutling repo: commits 5a500792 and 0e7878b4, Cutling/CutlingStore.swift:46-63, Cutling/TextDetailView.swift:389, Cutling/RichText.swift:44, Cutling/CloudKitSyncManager.swift:383, docs/formatting-plan.md, docs/research/keyboard-memory-limits.md | gated: local repository files and git log, read in place, not copied | Limit history (2,000 then 1,000 "because of iOS form layout issues"), memory figures, the 450-point box, plain-text-only typing |
| 46 | Apple Notes: picture of Find in Note, of redo on iPhone, of an empty new note | gated: Apple's guide pages [2][8] carry no picture of these | Text only |
| 47 | Shortcuts: picture of a tapped Current Date pill on iOS 27 | gated: the iOS 16-27 guide pages dropped the variable pictures; only text [30][32] | Text only |
| 48 | TextExpander, Snippety, Paste, PastePal iPhone snippet editors and per-snippet limits | gated: not shown in App Store screenshots or stated on the pages read; apps not installed or signed in to | UNSURE |
