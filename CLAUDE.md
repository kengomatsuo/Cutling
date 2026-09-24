# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Deploy

**Xcode:** Open `Cutling.xcodeproj`. Requires Xcode 16+ (uses `fileSystemSynchronizedGroups`). Main app target is `Cutling`, minimum deployment iOS 18.0 / macOS 14.0.

**App Store Connect auth** — metadata authenticates via a 2FA Spaceship session, binaries via `altool`, which ignores that session and needs an app-specific password. Drop an ASC API key at `fastlane/asc_api_key.json` (`key_id` / `issuer_id` / `key`, gitignored) and both paths use it instead, so deploys run unattended; with no key file every lane falls back to the Apple ID flow. Setup notes: the header of [fastlane/Fastfile](fastlane/Fastfile).

**Deploy script wrapper** — always use `./deploy.sh` commands, never invoke `fastlane` directly:
```bash
./deploy.sh bump [patch|minor|major]  # Bump MARKETING_VERSION across every shipping build config
./deploy.sh build          # Build IPA for App Store (output: ./build/Cutling.ipa)
./deploy.sh binary         # Upload the already-built IPA to App Store Connect (binary only, no submit; run build first)
./deploy.sh snap           # Capture missing locale screenshots
./deploy.sh snap --all     # Recapture all screenshots
./deploy.sh frame          # Add device frames + marketing text to screenshots
./deploy.sh screenshots    # Upload framed screenshots to App Store Connect
./deploy.sh metadata       # Upload iOS metadata/release notes to App Store Connect
./deploy.sh metadata_mac   # Upload macOS metadata (fastlane/metadata_mac: release notes, promo text, description, keywords, support URL) to App Store Connect (platform osx)
./deploy.sh upload         # Upload metadata + framed screenshots together
./deploy.sh all            # Full pipeline: metadata → screenshots → build → upload
./deploy.sh release_notes  # Translate iOS release_notes.txt to all locales (fastlane/metadata)
./deploy.sh release_notes_mac # Translate macOS release notes to all locales (fastlane/metadata_mac)
./deploy.sh web            # Deploy website to gh-pages (serves cutling.matsuokengo.com)
./deploy.sh dist           # Build/notarize/publish the macOS Developer ID app (direct download) + Sparkle appcast
./deploy.sh mas            # Build the clean "Cutling" target for the Mac App Store (no Sparkle) and upload the .pkg via fastlane (build_mac_app + deliver, platform osx)
```

**Website is `cutling.matsuokengo.com`** (moved off `kengomatsuo.github.io/Cutling` 2026-08-15). Pages serves `gh-pages` at the domain root, so `SITE_BASE` in `web/locale-router.js` + `web/fuzzy-redirect.js` is `''`, and `web/CNAME` must be copied into `dist/` on every build — `deploy_web` rsyncs with `--delete` and would otherwise wipe it and silently unset the domain. Old github.io URLs 301 with the path preserved, which is what keeps already-installed Sparkle clients on the old `SUFeedURL` updating.

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

**`CutlingStore`** (`CutlingStore.swift`): `@MainActor @Observable` class, single source of truth. Persists to App Group `UserDefaults` + image files. Enforces limits: 100 text, 25 image, 125 total; 1,000 char max per text cutling (`CutlingStore.maxTextLength`).

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
- `TutorialOverlay.swift` — iOS-only interactive, skippable, 12-step coach-mark walkthrough (create → edit → delete → recover). A persistent `TutorialHUD` carries progress + Skip on every screen, so no missing spotlight frame or closed TipKit popover can strand the user. Full account: [docs/tutorial.md](docs/tutorial.md).

### App Intents & Siri Shortcuts

`CutlingAppShortcutsProvider.swift` registers 10 App Shortcuts that surface in the Shortcuts app gallery, Spotlight, and Siri without user setup. Backing intents live in `*Intent.swift` files at the project root and share `CutlingStore.shared`. Constraints baked into the provider: max 10 shortcuts per app, every phrase must contain `\(.applicationName)`, parameter placeholders in phrases must be `AppEntity` or `AppEnum` (String/IntentFile params can't be inlined). Settings exposes a `SiriTipView` + `ShortcutsLink` to teach phrases and open the gallery.

## Localization

59 languages / 76 locale folders. Each target has `.lproj/Localizable.strings` and `.lproj/InfoPlist.strings`. App Shortcut phrases live in **`.lproj/AppShortcuts.strings`** (separate file required by AppIntents) — placeholder syntax is `${applicationName}` / `${target}` (not the Swift `\(.applicationName)` / `\(\.$target)` form).

**In-app UI strings (`.lproj/Localizable.strings`) are hand-translated into every locale** — read the existing locale file first and reuse its established terms, and use the per-locale "Cutling" form (see project memory). The `./deploy.sh release_notes` / `release_notes_mac` Google-translate flow is **only** for fastlane release notes (`fastlane/metadata/en-US/release_notes.txt` for iOS, `fastlane/metadata_mac/en-US/release_notes.txt` for macOS); never use it for `Localizable.strings`.

**Website copy is composed per locale from a meaning brief, never translated** — `web/_generator/INTENT.md` states what each of the 181 keys must MEAN; each `web/_generator/translations/<locale>.json` is written from it without reading `en-US.json`. Gate every file on `python3 web/_generator/validate_translations.py`.

## Release Workflow

1. `./deploy.sh bump` (patch by default) — rewrites MARKETING_VERSION **and CURRENT_PROJECT_VERSION** in every shipping build config, leaving CutlingUITests alone. App Store Connect tracks build numbers **per platform** and rejects any that isn't higher than that platform's last upload, so the single shared counter must exceed BOTH (macOS was already at 14 while iOS was at 1 — hence the jump to 15 for 1.5.3).
2. Edit the **two** App Store "What's New" sources — iOS and macOS carry **different** copy and live in separate metadata trees:
   - `fastlane/metadata/en-US/release_notes.txt` — **iOS** App Store. iOS-relevant items only; never list macOS-only features (Mac welcome screen, global hotkey, menu bar picker, auto-update) here.
   - `fastlane/metadata_mac/en-US/release_notes.txt` — **macOS** App Store (the `Cutling` target's `mas` build). macOS-relevant items only. (The direct-download `dist` + Sparkle build is a separate channel and has no App Store listing.)
   - Scope each to the delta over what is LIVE on that platform (a platform's live version can differ from the other's).
3. `./deploy.sh release_notes` (iOS) and `./deploy.sh release_notes_mac` (macOS) — translate each to all locales
4. `./deploy.sh all` (iOS build + metadata + screenshots) and `./deploy.sh metadata_mac` (macOS notes); macOS binary via `./deploy.sh mas`

To correct notes on a version already submitted for review, use `./deploy.sh resubmit_notes` (cancels the in-review submission, re-uploads metadata, resubmits — resets the review queue).
