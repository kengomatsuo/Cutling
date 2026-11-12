# CLAUDE.md

**Open ASO items: say them in the first reply of each session until they close (owner, 2026-10-01).** Full account: [docs/aso/open-items.md](docs/aso/open-items.md)

Cutling is a SwiftUI-first iOS/macOS clipboard manager with **no third-party dependencies** (Apple frameworks only; Sparkle only in the direct-download target).

## Build

Open `Cutling.xcodeproj` (Xcode 16+, `fileSystemSynchronizedGroups`). Minimum deployment iOS 18.0 / macOS 14.0. `CutlingUITests` (XCUITest + fastlane snapshot) automates screenshots; no unit test suite exists.

Always use `./deploy.sh <command>` (bump, build, binary, snap, frame, screenshots, metadata, metadata_mac, upload, all, release_notes, release_notes_mac, web, dist, mas), never `fastlane` directly. Commands: [docs/deploy-commands.md](docs/deploy-commands.md). Release steps: [docs/release-workflow.md](docs/release-workflow.md).

**No App Store binary contains Sparkle:** the `Cutling` target ships iOS and macOS App Store builds without it; only `Cutling (Direct)` links it (details in `.claude/rules/deploy.md`).

## Targets

| Target | Type |
|---|---|
| `Cutling` | Main app, iOS + macOS, iCloud sync, background tasks; all App Store builds |
| `Cutling (Direct)` | macOS direct-download build, same sources, links Sparkle |
| `CutlingKeyboard` | Keyboard extension (UIKit + SwiftUI) |
| `CutlingShare` | Share extension (SwiftUI) |
| `CutlingAction` | Action extension, reuses `ShareView` |
| `CutlingWidgetsExtension` | WidgetKit + App Intents |
| `CutlingUITests` | Screenshot automation |

Extensions share core files (`Cutling.swift`, `CutlingStore.swift`, UI components) via target membership.

## Cross-process state

All targets share the **`group.com.matsuokengo.Cutling`** App Group: shared `UserDefaults` (single source of truth for cutling data) and shared image files. Any target that writes to the store posts the Darwin notification `"com.matsuokengo.Cutling.cutlingsChanged"`; the others reload on receipt.

Website, localization, data model and views, and store screenshots have path rules in `.claude/rules/`.
