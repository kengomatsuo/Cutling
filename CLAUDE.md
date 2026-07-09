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
./deploy.sh metadata       # Upload iOS metadata/release notes to App Store Connect
./deploy.sh metadata_mac   # Upload macOS release notes (fastlane/metadata_mac) to App Store Connect (platform osx)
./deploy.sh upload         # Upload metadata + framed screenshots together
./deploy.sh all            # Full pipeline: metadata → screenshots → build → upload
./deploy.sh release_notes  # Translate iOS release_notes.txt to all locales (fastlane/metadata)
./deploy.sh release_notes_mac # Translate macOS release notes to all locales (fastlane/metadata_mac)
./deploy.sh web            # Deploy website to gh-pages
./deploy.sh dist           # Build/notarize/publish the macOS Developer ID app (direct download) + Sparkle appcast
./deploy.sh mas            # Build the clean "Cutling" target for the Mac App Store (no Sparkle) and upload the .pkg via fastlane (build_mac_app + deliver, platform osx)
```

**The App Store is clean; only the direct-download build carries Sparkle:**
- **`Cutling`** target → **all App Store builds**: iOS App Store (`build`/`binary`) **and** the macOS **App Store** (`mas`). It does **not** link Sparkle, so no App Store binary ever contains a self-updater (guideline 2.4.5). Uses `Cutling/Info.plist` (no `SU*` keys).
- **`Cutling (Direct)`** target → the macOS **direct-download** build (`dist`) only. Same sources, macOS-only, and the **only** target that links the **Sparkle** Swift Package. Uses `CutlingDirect/Info.plist` (which holds the `SU*` keys).

Every Sparkle call site is gated on `#if canImport(Sparkle)`, so a target that doesn't link the package compiles all of it out with **zero code changes** — the clean `Cutling` target simply has no Sparkle symbols. Both targets share bundle ID `com.matsuokengo.Cutling` (universal purchase) and `Cutling/Cutling.entitlements`. `mas` is a fastlane `platform :mac` lane (`build_mac_app` + `upload_to_app_store platform: "osx"`) and reuses the same App Store Connect auth as the iOS lanes (Appfile / session), so no extra credentials are needed.

**UI Tests:** `CutlingUITests` target uses XCUITest + fastlane snapshot for screenshot automation. No unit test suite exists.

## Architecture

Cutling is a SwiftUI-first iOS/macOS clipboard manager with **no third-party dependencies** (Apple frameworks only).

### Targets

| Target | Type | Notes |
|--------|------|-------|
| `Cutling` | Main App | iOS + macOS, iCloud sync, background tasks. Ships **all App Store builds** (iOS + macOS App Store); **no Sparkle**. Uses `Cutling/Info.plist` |
| `Cutling (Direct)` | Main App (macOS) | macOS **direct-download** build only. Same sources as `Cutling`, macOS-only, and the **only** target that links Sparkle. Shares the `Cutling` synchronized source folder; uses `CutlingDirect/Info.plist` |
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
- `TutorialOverlay.swift` — iOS-only interactive, forced, skippable coach-mark walkthrough. A shared `TutorialCoordinator.shared` drives a 10-step flow (createAdd → createName → createText → createSave → editOpen → editSave → deleteOpen → deleteConfirm → recoverTap → recoverWhere) across three screens; controls publish live global frames via `.tutorialFrame(_:)` and each screen hosts its own overlay via `.tutorialOverlay(_:)` so coach-marks render above sheets/pushes. Edit and delete are spotlighted with no un-highlightable menu rows: the card's ⋯ button (`CardView.topRightButton`, which calls `onEdit()` directly) opens the editor, and delete uses the editor's bottom "Delete Cutling" button (`.editorDelete`). Content controls (cards, form fields, in-form buttons) get a hard tap-through hole (`BlockingScrim`); nav-bar controls (+, Save, More) are highlighted but non-blocking. During the walkthrough `+` opens a text cutling directly and Recently Deleted is navigated programmatically (then it points back at More). Backing out is a deliberate escape hatch rather than blocked: the create sheet keeps Cancel enabled but routes it (and only it — swipe-dismiss stays off) through a "Leave Tutorial?" confirmation alert (`tutorialGuardsDismiss`); the pushed editor swaps its system Back for a custom one during the edit/delete steps (`tutorialInterceptsBack`) — on `editSave` Back requires a real text edit (`tutorialDidEdit`, set from `value` changes) or else shows the same leave alert, and on `deleteConfirm` Back resets the flow to `deleteOpen` (re-points at ⋯) instead of stranding it. Auto-launches once for any user who hasn't seen it (`hasSeenInteractiveTutorial`), replayable via "How to Use Cutling" in the keyboard manager's (`KeyboardView`) About section (which dismisses the sheet, then starts the walkthrough on the grid). The long-press TipKit tip was removed (the tutorial teaches it); the remaining tips (More-menu, drag-to-select, smart matching) stay gated until the tutorial is seen.

### App Intents & Siri Shortcuts

`CutlingAppShortcutsProvider.swift` registers 10 App Shortcuts that surface in the Shortcuts app gallery, Spotlight, and Siri without user setup. Backing intents live in `*Intent.swift` files at the project root and share `CutlingStore.shared`. Constraints baked into the provider: max 10 shortcuts per app, every phrase must contain `\(.applicationName)`, parameter placeholders in phrases must be `AppEntity` or `AppEnum` (String/IntentFile params can't be inlined). Settings exposes a `SiriTipView` + `ShortcutsLink` to teach phrases and open the gallery.

## Localization

59 languages / 76 locale folders. Each target has `.lproj/Localizable.strings` and `.lproj/InfoPlist.strings`. App Shortcut phrases live in **`.lproj/AppShortcuts.strings`** (separate file required by AppIntents) — placeholder syntax is `${applicationName}` / `${target}` (not the Swift `\(.applicationName)` / `\(\.$target)` form).

**In-app UI strings (`.lproj/Localizable.strings`) are hand-translated into every locale** — read the existing locale file first and reuse its established terms, and use the per-locale "Cutling" form (see project memory). The `./deploy.sh release_notes` / `release_notes_mac` Google-translate flow is **only** for fastlane release notes (`fastlane/metadata/en-US/release_notes.txt` for iOS, `fastlane/metadata_mac/en-US/release_notes.txt` for macOS); never use it for `Localizable.strings`.

## Release Workflow

1. Bump version in Xcode (CFBundleShortVersionString / CFBundleVersion)
2. Edit the **two** App Store "What's New" sources — iOS and macOS carry **different** copy and live in separate metadata trees:
   - `fastlane/metadata/en-US/release_notes.txt` — **iOS** App Store. iOS-relevant items only; never list macOS-only features (Mac welcome screen, global hotkey, menu bar picker, auto-update) here.
   - `fastlane/metadata_mac/en-US/release_notes.txt` — **macOS** App Store (the `Cutling` target's `mas` build). macOS-relevant items only. (The direct-download `dist` + Sparkle build is a separate channel and has no App Store listing.)
   - Scope each to the delta over what is LIVE on that platform (a platform's live version can differ from the other's).
3. `./deploy.sh release_notes` (iOS) and `./deploy.sh release_notes_mac` (macOS) — translate each to all locales
4. `./deploy.sh all` (iOS build + metadata + screenshots) and `./deploy.sh metadata_mac` (macOS notes); macOS binary via `./deploy.sh mas`

To correct notes on a version already submitted for review, use `./deploy.sh resubmit_notes` (cancels the in-review submission, re-uploads metadata, resubmits — resets the review queue).
