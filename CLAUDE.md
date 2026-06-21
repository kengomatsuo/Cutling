# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Deploy

**Xcode:** Open `Cutling.xcodeproj`. Requires Xcode 16+ (uses `fileSystemSynchronizedGroups`). Main app target is `Cutling`, minimum deployment iOS 18.0 / macOS 14.0.

**Deploy script wrapper** — always use `./deploy.sh` commands, never invoke `fastlane` directly:
```bash
./deploy.sh build          # Build IPA for App Store (output: ./build/Cutling.ipa)
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

### App Intents & Siri Shortcuts

`CutlingAppShortcutsProvider.swift` registers 10 App Shortcuts that surface in the Shortcuts app gallery, Spotlight, and Siri without user setup. Backing intents live in `*Intent.swift` files at the project root and share `CutlingStore.shared`. Constraints baked into the provider: max 10 shortcuts per app, every phrase must contain `\(.applicationName)`, parameter placeholders in phrases must be `AppEntity` or `AppEnum` (String/IntentFile params can't be inlined). Settings exposes a `SiriTipView` + `ShortcutsLink` to teach phrases and open the gallery.

## Localization

59 locales. Each target has `.lproj/Localizable.strings` and `.lproj/InfoPlist.strings`. App Shortcut phrases live in **`.lproj/AppShortcuts.strings`** (separate file required by AppIntents) — placeholder syntax is `${applicationName}` / `${target}` (not the Swift `\(.applicationName)` / `\(\.$target)` form). Release notes are translated via `./deploy.sh release_notes` from `fastlane/metadata/en-US/release_notes.txt`.

## Release Workflow

1. Bump version in Xcode (CFBundleShortVersionString / CFBundleVersion)
2. Edit `fastlane/metadata/en-US/release_notes.txt`
3. `./deploy.sh release_notes` — translate to all locales
4. `./deploy.sh all` — build, screenshot, and upload to App Store Connect
