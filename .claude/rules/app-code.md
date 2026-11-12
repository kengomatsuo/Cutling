---
paths:
  - "Cutling/**/*.swift"
  - "CutlingKeyboard/**"
  - "CutlingShare/**"
  - "CutlingAction/**"
  - "CutlingWidgets/**"
---

# App code

**Data model.** `Cutling` struct (`Cutling.swift`): id (UUID), name, value (text), icon (SF Symbol name), color, expiration, inputTypeTriggers, kind (.text | .image). `CutlingStore` (`CutlingStore.swift`): `@MainActor @Observable` class, single source of truth. Persists to App Group `UserDefaults` + image files. Enforces limits: 100 text, 25 image, 125 total; 1,000 char max per text cutling (`CutlingStore.maxTextLength`). Soft-delete: `DeletedCutling` with 30-day retention, recoverable from `RecentlyDeletedView`.

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
- `KeyboardSetupView.swift`: 6-page onboarding wizard.
- `CardView.swift`: cutling card display component.
- `TutorialOverlay.swift`: iOS-only interactive, skippable, 12-step coach-mark walkthrough (create, edit, delete, recover). A persistent `TutorialHUD` carries progress + Skip on every screen, so no missing spotlight frame or closed TipKit popover can strand the user. Full account: [docs/tutorial.md](../../docs/tutorial.md).

**App Intents and Siri Shortcuts.** `CutlingAppShortcutsProvider.swift` registers 10 App Shortcuts that surface in the Shortcuts gallery, Spotlight and Siri without user setup. Backing intents live in `*Intent.swift` files at the project root and share `CutlingStore.shared`. Provider constraints: max 10 shortcuts per app, every phrase must contain `\(.applicationName)`, parameter placeholders in phrases must be `AppEntity` or `AppEnum` (String/IntentFile params cannot be inlined). Settings exposes a `SiriTipView` + `ShortcutsLink` to teach phrases and open the gallery.
