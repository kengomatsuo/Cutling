---
name: Cutling project architecture and targets
description: Complete project structure — 6 targets, shared code strategy, compilation conditions, bundle IDs, entitlements, app group
type: project
originSessionId: 7b3b13ec-cea4-497f-8624-63751b64c94b
---
## What is Cutling

Cutling is a clipboard/snippet manager for iOS and macOS. Users save text and images as "cutlings" and access them via a custom keyboard, share extension, action extension, or Control Center widgets. iCloud sync (experimental) keeps cutlings in sync across devices.

**Current version:** 1.3
**Developer:** Kenneth Johannes Fang (kennethfang1000@gmail.com)
**Team ID:** PM3K35YS39
**App Group:** `group.com.matsuokengo.Cutling`

## Targets (6 total)

| Target | Type | Bundle ID | Deployment | Compilation Flag |
|--------|------|-----------|------------|------------------|
| Cutling | Main App | `com.matsuokengo.Cutling` | iOS 18.0 / macOS 14.0 | `MAIN_APP` |
| CutlingKeyboard | Keyboard Extension | `com.matsuokengo.Cutling.CutlingKeyboard` | iOS 18.0 | `KEYBOARD_EXTENSION` |
| CutlingShare | Share Extension | `com.matsuokengo.Cutling.CutlingShare` | iOS 18.0 | `SHARE_EXTENSION` |
| CutlingAction | Action Extension | `com.matsuokengo.Cutling.CutlingAction` | iOS 18.0 | `ACTION_EXTENSION` |
| CutlingWidgetsExtension | Widget Extension | `com.matsuokengo.Cutling.CutlingWidgets` | iOS 18.0 | `WIDGET_EXTENSION` |
| CutlingUITests | UI Tests | `com.matsuokengo.CutlingUITests` | — | — |

## Shared Code (Target Membership)

| File | Main | Keyboard | Share | Action | Widgets |
|------|------|----------|-------|--------|---------|
| `Cutling.swift` | Yes | Yes | Yes | Yes | Yes |
| `CutlingStore.swift` | Yes | Yes | Yes | Yes | Yes |
| `AddFromClipboardIntent.swift` | Yes | — | — | — | Yes |
| `OpenCutlingIntent.swift` | Yes | — | — | — | Yes |
| `ShareView.swift` | — | — | Yes | Yes | — |
| `ColorPaletteSection.swift` | Yes | — | Yes | Yes | — |
| `ExpirationPicker.swift` | Yes | — | Yes | Yes | — |
| `IconPickerView.swift` | Yes | — | Yes | Yes | — |
| `InputTypePickerSection.swift` | Yes | — | Yes | Yes | — |
| `SfSymbolCatalog.swift` | Yes | — | Yes | Yes | — |

## Conditional Compilation Pattern

Main-app-only code (iCloud sync, recently deleted, background tasks) is gated with `#if MAIN_APP`. Platform-specific code uses `#if os(iOS)` / `#if os(macOS)`.

## Entitlements

- **Main app:** CloudKit, iCloud Key-Value Store, App Groups, APS (push)
- **Keyboard:** CloudKit, App Groups, iCloud container
- **Share / Action / Widgets:** App Groups only

## Project Structure (Xcode 16 filesystem-synced groups)

Uses `fileSystemSynchronizedGroups` — .lproj directories and new files are auto-discovered by Xcode from the filesystem. No manual "Add Files" needed.

## No External Dependencies

Built entirely with Apple frameworks: SwiftUI, UIKit, CloudKit, WidgetKit, AppIntents, CryptoKit, NaturalLanguage, AudioToolbox, UniformTypeIdentifiers.
