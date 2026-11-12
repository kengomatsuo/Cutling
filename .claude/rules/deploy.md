---
paths:
  - "deploy.sh"
  - "fastlane/**"
  - "CutlingDirect/**"
  - "ExportOptions-DeveloperID.plist"
---

# Deploy and targets

Always use `./deploy.sh`, never `fastlane` directly. Commands: [docs/deploy-commands.md](../../docs/deploy-commands.md). Release steps: [docs/release-workflow.md](../../docs/release-workflow.md).

**App Store Connect auth:** metadata authenticates via a 2FA Spaceship session, binaries via `altool`, which ignores that session and needs an app-specific password. Drop an ASC API key at `fastlane/asc_api_key.json` (`key_id` / `issuer_id` / `key`, gitignored) and both paths use it instead, so deploys run unattended; with no key file every lane falls back to the Apple ID flow. Setup notes: the header of [fastlane/Fastfile](../../fastlane/Fastfile).

**The App Store is clean; only the direct-download build carries Sparkle:**
- **`Cutling`** target: all App Store builds, iOS (`build`/`binary`) and macOS (`mas`). It does not link Sparkle, so no App Store binary contains a self-updater (guideline 2.4.5). Uses `Cutling/Info.plist` (no `SU*` keys).
- **`Cutling (Direct)`** target: the macOS direct-download build (`dist`) only. Same sources, macOS-only, and the only target that links the Sparkle Swift Package. Shares the `Cutling` synchronized source folder; uses `CutlingDirect/Info.plist` (which holds the `SU*` keys).

Every Sparkle call site is gated on `#if canImport(Sparkle)`, so a target without the package compiles all of it out with zero code changes. Both targets share bundle ID `com.matsuokengo.Cutling` (universal purchase) and `Cutling/Cutling.entitlements`. `mas` is a fastlane `platform :mac` lane (`build_mac_app` + `upload_to_app_store platform: "osx"`) and reuses the iOS lanes' App Store Connect auth, so it needs no extra credentials.
