# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Deploy

**Xcode:** Open `Cutling.xcodeproj`. Requires Xcode 16+ (uses `fileSystemSynchronizedGroups`). Main app target is `Cutling`, minimum deployment iOS 18.0 / macOS 14.0.

**Deploy script wrapper** — always use `./deploy.sh` commands, never invoke `fastlane` directly:
```bash
./deploy.sh build          # Build IPA for App Store (output: ./build/Cutling.ipa)
./deploy.sh binary         # Upload the already-built IPA to App Store Connect (binary only, no submit; run build first)
./deploy.sh snap           # Capture missing locale screenshots
./deploy.sh snap --all     # Recapture all screenshots
./deploy.sh frame          # Add device frames + marketing text to screenshots
./deploy.sh screenshots    # Upload framed screenshots to App Store Connect
./deploy.sh metadata       # Upload metadata/release notes to App Store Connect
./deploy.sh upload         # Upload metadata + framed screenshots together
./deploy.sh all            # Full pipeline: metadata → screenshots → build → upload
./deploy.sh release_notes  # Translate release_notes.txt to all 59 locales
./deploy.sh web            # Deploy website to gh-pages
```

**UI Tests:** `CutlingUITests` target uses XCUITest + fastlane snapshot for screenshot automation. No unit test suite exists.

## Architecture

Cutling is a SwiftUI-first iOS/macOS clipboard manager with **no third-party dependencies** (Apple frameworks only).

### Targets

| Target | Type | Notes |
|--------|------|-------|
| `Cutling` | Main App | iOS + macOS, iCloud sync, background tasks |
| `CutlingKeyboard` | Keyboard Extension | UIKit + SwiftUI hybrid (`UIInputViewController`) |
| `CutlingShare` | Share Extension | SwiftUI |
| `CutlingAction` | Action Extension | Reuses `ShareView` |
| `CutlingWidgetsExtension` | Widget Extension | WidgetKit + App Intents |
| `CutlingUITests` | UI Tests | Screenshot automation |

All extension targets share core files (`Cutling.swift`, `CutlingStore.swift`, UI components) via target membership.

### App Group & Cross-Process Sync

All targets share the **`group.com.matsuokengo.Cutling`** App Group for:
- Shared `UserDefaults` (single source of truth for cutling data)
- Shared image files for image cutlings

Cross-process updates use **Darwin Notifications** (`"com.matsuokengo.Cutling.cutlingsChanged"`): any target that writes to the store posts this notification; other targets reload on receipt.

Widgets communicate with the main app via a `pendingControlAction` key in shared `UserDefaults`.

### Data Model

**`Cutling` struct** (`Cutling.swift`): id (UUID), name, value (text), icon (SF Symbol name), color, expiration, inputTypeTriggers, kind (.text | .image).

**`CutlingStore`** (`CutlingStore.swift`): `@MainActor @Observable` class, single source of truth. Persists to App Group `UserDefaults` + image files. Enforces limits: 100 text, 25 image, 125 total; 2,000 char max per text cutling.

Soft-delete: `DeletedCutling` with 30-day retention, recoverable from `RecentlyDeletedView`.

### Key Patterns

- **SwiftUI + `@Observable`** throughout main app; keyboard extension uses `UIHostingController` to embed SwiftUI
- **`#if MAIN_APP`** guards iCloud sync (`CKSyncEngine`), recently deleted, and background tasks
- **`#if os(iOS)` / `#if os(macOS)`** for platform-specific UI
- Input type auto-detection (email, URL, phone, name, address) via `NSDataDetector` + `NLTagger`
- Sensitive content detection (credit card, API key, seed phrase) in `CutlingStore`
- Rich link metadata fetching in `ShareView`

### Main App Views

- `MainContentView.swift` — primary grid/list browsing with 3 modes (browse/select/reorder), search, sort
- `TextDetailView.swift` / `ImageDetailView.swift` — editors with undo/redo
- `KeyboardSetupView.swift` — 6-page onboarding wizard
- `CardView.swift` — cutling card display component
- `TutorialOverlay.swift` — iOS-only interactive, forced, skippable coach-mark walkthrough. A shared `TutorialCoordinator.shared` drives a 10-step flow (createAdd → createName → createText → createSave → editOpen → editSave → deleteOpen → deleteConfirm → recoverTap → recoverWhere) across three screens; controls publish live global frames via `.tutorialFrame(_:)` and each screen hosts its own overlay via `.tutorialOverlay(_:)` so coach-marks render above sheets/pushes. Edit and delete are spotlighted with no un-highlightable menu rows: the card's ⋯ button (`CardView.topRightButton`, which calls `onEdit()` directly) opens the editor, and delete uses the editor's bottom "Delete Cutling" button (`.editorDelete`). Content controls (cards, form fields, in-form buttons) get a hard tap-through hole (`BlockingScrim`); nav-bar controls (+, Save, More) are highlighted but non-blocking. During the walkthrough `+` opens a text cutling directly and Recently Deleted is navigated programmatically (then it points back at More). Auto-launches once for any user who hasn't seen it (`hasSeenInteractiveTutorial`), replayable via "How to Use Cutling" in the keyboard manager's (`KeyboardView`) About section (which dismisses the sheet, then starts the walkthrough on the grid). The long-press TipKit tip was removed (the tutorial teaches it); the remaining tips (More-menu, drag-to-select, smart matching) stay gated until the tutorial is seen.

### App Intents & Siri Shortcuts

`CutlingAppShortcutsProvider.swift` registers 10 App Shortcuts that surface in the Shortcuts app gallery, Spotlight, and Siri without user setup. Backing intents live in `*Intent.swift` files at the project root and share `CutlingStore.shared`. Constraints baked into the provider: max 10 shortcuts per app, every phrase must contain `\(.applicationName)`, parameter placeholders in phrases must be `AppEntity` or `AppEnum` (String/IntentFile params can't be inlined). Settings exposes a `SiriTipView` + `ShortcutsLink` to teach phrases and open the gallery.

## Localization

59 languages / 76 locale folders. Each target has `.lproj/Localizable.strings` and `.lproj/InfoPlist.strings`. App Shortcut phrases live in **`.lproj/AppShortcuts.strings`** (separate file required by AppIntents) — placeholder syntax is `${applicationName}` / `${target}` (not the Swift `\(.applicationName)` / `\(\.$target)` form).

**In-app UI strings (`.lproj/Localizable.strings`) are hand-translated into every locale** — read the existing locale file first and reuse its established terms, and use the per-locale "Cutling" form (see project memory). The `./deploy.sh release_notes` Google-translate flow is **only** for fastlane release notes (`fastlane/metadata/en-US/release_notes.txt`); never use it for `Localizable.strings`.

## Release Workflow

1. Bump version in Xcode (CFBundleShortVersionString / CFBundleVersion)
2. Edit `fastlane/metadata/en-US/release_notes.txt`
3. `./deploy.sh release_notes` — translate to all locales
4. `./deploy.sh all` — build, screenshot, and upload to App Store Connect
