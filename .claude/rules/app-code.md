---
paths:
  - "Cutling/**/*.swift"
  - "CutlingKeyboard/**"
  - "CutlingShare/**"
  - "CutlingAction/**"
  - "CutlingWidgets/**"
---

# App code

**Data model.** `Cutling` struct (`Cutling.swift`): id (UUID), name, value (text), icon (SF Symbol name), color, expiration, inputTypeTriggers, kind (.text | .image). `CutlingStore` (`CutlingStore.swift`): `@MainActor @Observable` class, single source of truth. Persists the lists as JSON files in the App Group container's `Lists/` (moved once out of `UserDefaults`, which iOS caps at about 4 MB) + image files. Enforces limits: 5,000 text, 500 image, 5,500 total, set under the keyboard's 77 MB memory limit (measured peaks in `CutlingStore.swift`; the keyboard grid reuses cells and reads disk thumbnails, so photos cost almost nothing and text about 2.3 MB per 1,000); 10,000 characters per text cutling and 5,000,000 across all of them (`CutlingStore.maxTextLength`, `maxTotalTextCharacters`). Soft-delete: `DeletedCutling` with 30-day retention, recoverable from `RecentlyDeletedView`.

**Patterns.**
- SwiftUI + `@Observable` throughout the main app; the keyboard extension uses `UIHostingController` to embed SwiftUI.
- `#if MAIN_APP` guards iCloud sync (`CKSyncEngine`), recently deleted, and background tasks.
- `#if os(iOS)` / `#if os(macOS)` for platform-specific UI.
- Input type auto-detection (email, URL, phone, name, address) via `NSDataDetector` + `NLTagger`.
- Sensitive content detection (credit card, API key, seed phrase) in `CutlingStore`.
- Rich link metadata fetching in `ShareView`.
- Widgets communicate with the main app via a `pendingControlAction` key in shared `UserDefaults`.

**Main app views.**
- `MainContentView.swift`: primary grid/list browsing with 3 modes (browse/select/reorder), search, sort.
- `TextDetailView.swift` / `ImageDetailView.swift`: editors with undo/redo.
- `KeyboardSetupView.swift`: opens the setup guide, `SetupGuide` in `SetupFlows.swift`: Welcome, Add the Keyboard (the real Settings video, `SettingsDemoVideo.swift`, recorded by `scripts/record-settings-demo.sh`), Try It, then What You Can Do, Sync Across Devices and You're All Set (`SetupPages.swift`). Every page and sheet uses one layout, `AppleSheetPage` (`AppleSheet.swift`); Full Access is optional. What's New and Welcome Back (`WhatsNewSheet`) show once per `WhatsNewKind.releaseID` and after 30 days away.
- `CardView.swift`: cutling card display component.
- `TutorialOverlay.swift`: iOS-only interactive, skippable, 13-step coach-mark walkthrough (create, an optional fill-in step, edit, delete, recover), started only from How to Use Cutling. A persistent `TutorialHUD` carries progress + Skip on every screen, so no missing spotlight frame or closed TipKit popover can strand the user. Full account: [docs/tutorial.md](../../docs/tutorial.md).

**App Intents and Siri Shortcuts.** `CutlingAppShortcutsProvider.swift` registers 10 App Shortcuts that surface in the Shortcuts gallery, Spotlight and Siri without user setup. Backing intents live in `*Intent.swift` files at the project root and share `CutlingStore.shared`. Provider constraints: max 10 shortcuts per app, every phrase must contain `\(.applicationName)`, parameter placeholders in phrases must be `AppEntity` or `AppEnum` (String/IntentFile params cannot be inlined). Settings exposes a `SiriTipView` + `ShortcutsLink` to teach phrases and open the gallery.

- Empty states use `ContentUnavailableView`. A phantom `No such module 'UIKit'` in Zed means a stale `buildServer.json`.
