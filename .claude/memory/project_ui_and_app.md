---
name: Cutling UI architecture, app lifecycle, and iCloud sync
description: All views, navigation structure, CutlingApp lifecycle, deep links, quick actions, background sync, iCloud CloudKit setup
type: project
originSessionId: 7b3b13ec-cea4-497f-8624-63751b64c94b
---
## CutlingApp.swift — App Lifecycle

**URL Scheme (`cutling://`):**
- `cutling://settings` → open system Settings
- `cutling://keyboard` → show KeyboardSetupView
- `cutling://addText` → create new text cutling
- `cutling://addImage` → create new image cutling

**Quick Actions (3D Touch / long press):**
- `com.matsuokengo.Cutling.addText` → new text cutling
- `com.matsuokengo.Cutling.addImage` → new image cutling
- Routed through `AppDelegate.pendingShortcutType` → `handlePendingShortcut()`

**Scene Phase:**
- `.active`: sync prefs to app group, reload store, CloudKit fetch, handle pending shortcuts/control actions
- `.background`: schedule BGAppRefreshTask + BGProcessingTask (if iCloud enabled)

**handlePendingControlAction():** Reads `pendingControlAction` from group defaults (set by widget intents), maps "newText"/"newImage" to `pendingNewCutlingKind`, clears key.

**iCloud Sync:**
- `configureSyncIfNeeded()` on launch → creates CloudKitSyncManager if enabled
- `CloudKitSyncManager` uses CKSyncEngine (private CloudKit container)
- `KeyboardSyncHelper` in keyboard ext: lightweight direct CKRecord saves
- Settings.bundle exposes `iCloudSyncEnabled` toggle (experimental)

**Background Sync (iOS):**
- `bgSyncTaskID = "com.matsuokengo.Cutling.sync"` (15 min interval)
- `bgProcessingTaskID = "com.matsuokengo.Cutling.sync.processing"` (5 min, requires network)

**Preference Syncing:** `syncPreferencesToAppGroup()` copies `iCloudSyncEnabled` and `autoDetectInputTypes` from standard UserDefaults → app group UserDefaults so keyboard can read them.

**Migrations:** v1.2 auto-detects input type triggers for existing cutlings.

## Main Views

**MainContentView** — Hub view:
- Grid/list browsing with LazyVGrid
- 3 modes: browse, select, reorder
- Search, sorting (name A-Z/Z-A, text/images first, shortest/longest, reverse)
- Pan gesture selection on iOS (drag to select multiple)
- Auto-scroll at edges, shift+tap for individual toggle
- Card view with copy/share/edit/delete context menu

**TextDetailView** — Text cutling create/edit:
- Name, icon picker, TextEditor (editable), color palette, input type suggestions, expiration
- Undo/redo via UndoHandler (coalescing groups, 0.5s debounce)
- Paste from clipboard button
- Auto-detect input types from text content
- Auto-suggest icon and name from detected categories
- Auto-save on disappear (non-sheet mode)

**ImageDetailView** — Image cutling create/edit:
- Name, image preview, PhotosPicker + file picker, paste from clipboard, expiration
- Undo/redo for image changes
- Auto-save on disappear (non-sheet mode)
- GIF/PNG/JPEG preservation on paste

**RecentlyDeletedView** — 30-day soft-delete recovery:
- Countdown badges ("X days left")
- Restore, permanent delete, empty all
- Type-check expression workaround (complex SwiftUI body)

**KeyboardSetupView** — 6-page onboarding wizard:
1. Welcome, 2. Enable keyboard, 3. Test keyboard, 4. How to use, 5. iCloud opt-in, 6. Done

**SettingsView (iOS)** — Keyboard status indicators, Settings app link
**PreferencesView (macOS)** — iCloud Sync toggle, auto-detect toggle

## Shared UI Components

- `ColorPaletteSection` — 12-color grid, accessibility labels when differentiate-without-color enabled
- `ExpirationPicker` — Toggle + DatePicker for auto-delete
- `IconPickerView` — ~1000 SF Symbols in 8 category tabs with search
- `InputTypePickerSection` — 5 category toggles (Email, URL, Phone, Name, Address)
- `SfSymbolCatalog` — Static catalog of symbols organized into categories

## macOS-Specific

- `CutlingCommands` — Menu bar (New Text, New Image, Select, Reorder, Delete, etc.)
- `DetailWindowView` — Routes to TextDetailView or ImageDetailView by kind
- Multiple WindowGroup scenes for add/edit windows
- Settings window via `PreferencesView`

## Localization

- **59 locales** (60 including Base) across all targets
- Each target has its own `.lproj/Localizable.strings` and `.lproj/InfoPlist.strings`
- "Cutling" brand name is transliterated per-language (see reference_cutling_translations.md)
- Website has 62 locale JSON translation files generated separately

## Settings.bundle (iOS)

- `iCloudSyncEnabled` (Bool, default false) — "Experimental feature"
- `autoDetectInputTypes` (Bool, default true) — auto-detect and suggest input type categories
