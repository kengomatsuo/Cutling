---
paths:
  - "*/*.lproj/*.strings"
  - "translate_release_notes.py"
  - "fastlane/metadata*/**/release_notes.txt"
---

# Localization

59 languages / 76 locale folders. Each target has `.lproj/Localizable.strings` and `.lproj/InfoPlist.strings`. App Shortcut phrases live in **`.lproj/AppShortcuts.strings`** (separate file required by AppIntents); placeholder syntax is `${applicationName}` / `${target}` (not the Swift `\(.applicationName)` / `\(\.$target)` form).

**In-app UI strings (`.lproj/Localizable.strings`) are hand-translated into every locale.** Read the existing locale file first and reuse its established terms, and use the per-locale "Cutling" form (see project memory). The `./deploy.sh release_notes` / `release_notes_mac` Google-translate flow is only for fastlane release notes (`fastlane/metadata/en-US/release_notes.txt` for iOS, `fastlane/metadata_mac/en-US/release_notes.txt` for macOS); never use it for `Localizable.strings`.
