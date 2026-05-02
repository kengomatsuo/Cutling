# Plan: Share Extension + Control Center Widgets for Cutling

## Context

Cutling is a clipboard/snippet manager that currently lets users add content via the main app or the custom keyboard extension. Users want two new system integration points:

1. **Share Extension** -- Save text/images to Cutling directly from any app's share sheet
2. **Control Center Widgets** (iOS 18+) -- Three quick-action buttons: add from clipboard, new text cutling, new image cutling

Both features need full localization across the existing 50+ languages.

---

## Part A: Share Extension

### A1. Create the Share Extension Target

- **Target name:** `CutlingShare`
- **Bundle ID:** `com.matsuokengo.Cutling.CutlingShare`
- **Deployment target:** iOS 18.0 (matches main app)
- **Language:** Swift 6.0

**Files to create:**
- `CutlingShare/ShareViewController.swift` -- Entry point, UIViewController hosting SwiftUI
- `CutlingShare/ShareView.swift` -- SwiftUI UI for the share sheet
- `CutlingShare/Info.plist`
- `CutlingShare/CutlingShare.entitlements`

### A2. Entitlements & App Group

Add to `CutlingShare.entitlements`:
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.matsuokengo.Cutling</string>
</array>
```

This gives the extension access to the shared UserDefaults and Images directory that `CutlingStore` already uses.

### A3. Info.plist -- Activation Rules

Configure `NSExtension` to accept text and images:

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>NSExtensionActivationRule</key>
        <dict>
            <key>NSExtensionActivationSupportsText</key>
            <true/>
            <key>NSExtensionActivationSupportsImageWithMaxCount</key>
            <integer>1</integer>
            <key>NSExtensionActivationSupportsWebURLWithMaxCount</key>
            <integer>1</integer>
        </dict>
    </dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.share-services</string>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).ShareViewController</string>
</dict>
```

**Key rule:** Use the dictionary form of `NSExtensionActivationRule` (not `TRUEPREDICATE` which Apple rejects during review).

### A4. ShareViewController Architecture

Since the Share Extension API is UIKit-based, wrap SwiftUI in `UIHostingController`:

```
ShareViewController : UIViewController
  └─ hosts ShareView (SwiftUI)
       ├─ Detects shared item type (text vs image vs URL)
       ├─ Shows name field + preview
       ├─ Save button → writes to CutlingStore via App Group
       └─ Cancel button → dismisses extension
```

**Data flow:**
1. Extract items from `extensionContext?.inputItems`
2. Use `NSItemProvider.loadItem(forTypeIdentifier:)` for `public.plain-text`, `public.url`, and `public.image`
3. For text/URLs: create a `Cutling(kind: .text, ...)`
4. For images: save image data via `CutlingStore.saveImageData()`, create `Cutling(kind: .image, ...)`
5. Encode updated cutlings array to shared UserDefaults
6. Post Darwin notification `com.matsuokengo.Cutling.cutlingsChanged` so the main app picks up changes
7. Call `extensionContext?.completeRequest(returningItems: nil)`

### A5. Shared Code Strategy

The following files must be shared with the Share Extension target (add to Target Membership):
- `Cutling/Cutling.swift` -- Model types (`Cutling`, `CutlingKind`, `DeletedCutling`)
- `Cutling/CutlingStore.swift` -- Data access layer (already handles App Group)

Add a `SHARE_EXTENSION` Swift compilation condition to the Share Extension target (similar to the existing `KEYBOARD_EXTENSION` flag) so that sync-related code and other main-app-only features can be gated with `#if !SHARE_EXTENSION`.

### A6. Share Extension UI

Minimal SwiftUI view:
- **Name field** -- pre-populated from shared content (first line of text, or "Shared Image")
- **Preview** -- text preview or image thumbnail
- **Icon picker** -- optional, default to `doc.on.clipboard` for text, `photo` for images
- **Save / Cancel buttons**

Style to match the main app's teal accent color (`Cutling.defaultTint`).

### A7. Limit Enforcement

Before saving, check `CutlingStore.canAdd(.text)` / `canAdd(.image)`. If limits are reached, show an alert explaining the limit and dismiss.

### A8. Duplicate Detection for Images

Reuse `CutlingStore.findDuplicateImage(data:)` to warn if an identical image already exists.

---

## Part B: Control Center Widgets

### B1. Create the Widget Extension Target

- **Target name:** `CutlingWidgets`
- **Bundle ID:** `com.matsuokengo.Cutling.CutlingWidgets`
- **Deployment target:** iOS 18.0
- **Frameworks:** WidgetKit, AppIntents, SwiftUI

**Files to create:**
- `CutlingWidgets/CutlingWidgetsBundle.swift` -- `@main WidgetBundle`
- `CutlingWidgets/AddFromClipboardControl.swift` -- Control widget
- `CutlingWidgets/NewTextCutlingControl.swift` -- Control widget
- `CutlingWidgets/NewImageCutlingControl.swift` -- Control widget
- `CutlingWidgets/Info.plist`
- `CutlingWidgets/CutlingWidgets.entitlements`

### B2. AppIntents (shared between widget extension and main app)

Create AppIntent files with target membership in **both** the main app and the widget extension (required for `OpenIntent` conformance to open the app):

- `Shared/AddFromClipboardIntent.swift`
- `Shared/NewTextCutlingIntent.swift`
- `Shared/NewImageCutlingIntent.swift`

**AddFromClipboardIntent:**
- Conforms to `AppIntent`
- Reads `UIPasteboard.general` for text or image
- Writes directly to `CutlingStore` via shared App Group
- Posts Darwin notification
- Returns result without opening the app (fire-and-forget)

**NewTextCutlingIntent & NewImageCutlingIntent:**
- Conform to `AppIntent` & `OpenIntent`
- Open the app via URL scheme: `cutling://addText` / `cutling://addImage`
- The main app already handles these URLs in `CutlingApp.onOpenURL`

### B3. Control Widget Definitions

Each control is a struct conforming to `ControlWidget`:

```swift
struct AddFromClipboardControl: ControlWidget {
    static let kind = "com.matsuokengo.Cutling.addFromClipboard"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: AddFromClipboardIntent()) {
                Label("Add from Clipboard", systemImage: "doc.on.clipboard")
            }
        }
        .displayName("Add from Clipboard")
        .description("Save clipboard contents as a new cutling.")
    }
}
```

Similarly for `NewTextCutlingControl` (systemImage: `text.badge.plus`) and `NewImageCutlingControl` (systemImage: `photo.badge.plus`).

### B4. Entitlements

`CutlingWidgets.entitlements` needs:
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.matsuokengo.Cutling</string>
</array>
```

### B5. Widget Bundle

```swift
@main
struct CutlingWidgetsBundle: WidgetBundle {
    var body: some Widget {
        AddFromClipboardControl()
        NewTextCutlingControl()
        NewImageCutlingControl()
    }
}
```

### B6. AddFromClipboard: Handling the Clipboard in an Extension

**Important constraint:** `UIPasteboard.general` is accessible from widget extensions, but clipboard access may show a system paste prompt. The intent should:

1. Read `UIPasteboard.general.string` or `UIPasteboard.general.image`
2. Create a `Cutling` and save to shared UserDefaults / image directory
3. Post Darwin notification
4. Use `controlWidgetStatus()` to show brief "Saved!" feedback

If clipboard is empty or contains unsupported content, show appropriate status text.

---

## Part C: Localization

### C1. New Strings Required

**Share Extension strings:**
| Key | English (en) |
|-----|-------------|
| `"Save to Cutling"` | `"Save to Cutling"` |
| `"Shared Text"` | `"Shared Text"` |
| `"Shared Image"` | `"Shared Image"` |
| `"Shared URL"` | `"Shared URL"` |
| `"Save"` | `"Save"` (already exists) |
| `"Cancel"` | `"Cancel"` (already exists) |
| `"Saving..."` | `"Saving..."` |
| `"Saved!"` | `"Saved!"` |
| `"Limit Reached"` | `"Limit Reached"` (already exists) |

**Control Center strings:**
| Key | English (en) |
|-----|-------------|
| `"Add from Clipboard"` | `"Add from Clipboard"` (already exists in Localizable.strings) |
| `"New Text Cutling"` | `"New Text Cutling"` (already exists) |
| `"New Image Cutling"` | `"New Image Cutling"` (already exists) |
| `"Save clipboard contents as a new cutling."` | `"Save clipboard contents as a new cutling."` |
| `"Create a new text cutling."` | `"Create a new text cutling."` |
| `"Create a new image cutling."` | `"Create a new image cutling."` |
| `"Clipboard is empty."` | `"Clipboard is empty."` |

### C2. Localization Strategy

1. **Share Extension** -- Create a `Localizable.strings` for `CutlingShare` target. Include existing shared strings (Save, Cancel, Limit Reached) plus new share-specific strings. Ensure Target Membership is set to CutlingShare.

2. **Widget Extension** -- For Control Center widgets, `displayName` and `description` use `LocalizedStringResource` which reads from the widget extension's bundle. Create `Localizable.strings` inside `CutlingWidgets/`.

3. **InfoPlist.strings** -- Each extension needs its own `CFBundleDisplayName` localized:
   - CutlingShare: `"Cutling"` (shown in share sheet)
   - CutlingWidgets: `"Cutling"` (shown in Control Center gallery)

4. **Translation workflow:** Add the English strings first, then translate across all 50+ existing locales. The existing `Localizable.strings` files in the main app already cover many reusable strings.

### C3. Existing Strings to Reuse

These strings already exist in `Localizable.strings/en` and are already translated in all 50+ locales:
- `"Add from Clipboard"`, `"New Text Cutling"`, `"New Image Cutling"`
- `"Save"`, `"Cancel"`, `"Done"`, `"OK"`
- `"Limit Reached"`, limit-related error messages
- `"Text Cutling"`, `"Image Cutling"`
- `"Saved!"` / `"Copied"`

**Strategy:** Reference the main app's existing translations as the source of truth. Copy the relevant subset into each extension's `Localizable.strings` for all locales.

---

## Part D: Project Configuration Summary

### New Targets
| Target | Type | Bundle ID |
|--------|------|-----------|
| CutlingShare | Share Extension | `com.matsuokengo.Cutling.CutlingShare` |
| CutlingWidgets | Widget Extension | `com.matsuokengo.Cutling.CutlingWidgets` |

### Files Shared Across Targets (Target Membership)
| File | Main App | Keyboard | Share | Widget |
|------|----------|----------|-------|--------|
| `Cutling.swift` | Yes | Yes | Yes | Yes |
| `CutlingStore.swift` | Yes | Yes | Yes | Yes* |
| `AddFromClipboardIntent.swift` | Yes | -- | -- | Yes |
| `NewTextCutlingIntent.swift` | Yes | -- | -- | Yes |
| `NewImageCutlingIntent.swift` | Yes | -- | -- | Yes |

*Widget only needs read/write for `AddFromClipboardIntent`; the other two intents just open the app via URL.

### Compilation Conditions
| Target | Flag |
|--------|------|
| Keyboard | `KEYBOARD_EXTENSION` (existing) |
| Share Extension | `SHARE_EXTENSION` |
| Widget Extension | `WIDGET_EXTENSION` |

### Entitlements (App Group) Required
All four targets need `group.com.matsuokengo.Cutling` in their entitlements.

---

## Part E: Implementation Order

### Session 1: Share Extension
1. Create `CutlingShare` target in Xcode
2. Configure entitlements, Info.plist, activation rules
3. Add `SHARE_EXTENSION` compilation flag; gate sync code in `CutlingStore.swift`
4. Implement `ShareViewController.swift` (UIHostingController wrapper)
5. Implement `ShareView.swift` (SwiftUI UI)
6. Share `Cutling.swift` and `CutlingStore.swift` with the new target
7. Test with text and images from Safari, Photos, Notes
8. Build and verify

### Session 2: Control Center Widgets
1. Create `CutlingWidgets` target in Xcode
2. Configure entitlements, Info.plist
3. Create AppIntent files (shared target membership with main app)
4. Implement three `ControlWidget` structs
5. Implement `CutlingWidgetsBundle`
6. Test: add controls to Control Center, verify each action
7. Build and verify

### Session 3: Localization
1. Create `Localizable.strings` for `CutlingShare` with new strings in English
2. Create `Localizable.strings` for `CutlingWidgets` with new strings in English
3. Create `InfoPlist.strings` for both extensions (display name)
4. Copy and adapt translations from main app's 50+ locale files
5. Add new translations for share/widget-specific strings
6. Verify localization in simulator with different languages

### Session 4: Polish & Edge Cases
1. Handle clipboard empty state in AddFromClipboard
2. Handle unsupported content types gracefully in Share Extension
3. Test memory limits (share extension has ~120MB limit)
4. Test with large images, long text
5. Verify Darwin notifications trigger reload in main app
6. Test iCloud sync interaction (cutlings added via extension should sync)

---

## Verification Plan

1. **Share Extension:** Open Safari/Notes/Photos -> tap Share -> "Cutling" appears -> save text/image -> open Cutling app -> new cutling visible
2. **Control Center:** Swipe to Control Center -> add Cutling controls from gallery -> tap each -> verify action (clipboard add, app opens to new text/image)
3. **Localization:** Switch device language to 2-3 non-English locales -> verify all new UI strings appear translated in share sheet and Control Center
4. **Edge cases:** Empty clipboard, limit reached, duplicate image, very long text, no network (for sync)
5. **Build:** All four targets build without errors

---

## Key Files to Modify (Existing)

| File | Changes |
|------|---------|
| `Cutling.xcodeproj/project.pbxproj` | Add 2 new targets, file references, build settings |
| `Cutling/CutlingStore.swift` | Add `#if !SHARE_EXTENSION` / `#if !WIDGET_EXTENSION` gates alongside existing `#if !KEYBOARD_EXTENSION` |
| `Cutling/Cutling.swift` | No changes needed (already shared-ready) |
| `Cutling/CutlingApp.swift` | No changes needed (URL handling already exists) |

## Sources

- [iOS Share Extension with SwiftUI and SwiftData](https://www.merrell.dev/ios-share-extension-with-swiftui-and-swiftdata/)
- [Implementing a SwiftUI Share Extension](https://kait.dev/posts/implementing-swiftui-share-extension)
- [Create Powerful iOS Share Extensions](https://curatedios.substack.com/p/19-share-extension)
- [Sharing Data Between Extensions & App](https://www.fleksy.com/blog/communicating-between-an-ios-app-extensions-using-app-groups/)
- [Apple: Creating Controls to Perform Actions Across the System](https://developer.apple.com/documentation/widgetkit/creating-controls-to-perform-actions-across-the-system)
- [Apple: ControlWidgetButton](https://developer.apple.com/documentation/widgetkit/controlwidgetbutton)
- [WWDC24: Extend Your App's Controls Across the System](https://developer.apple.com/videos/play/wwdc2024/10157/)
- [Exploring WidgetKit: Creating Your First Control Widget](https://rudrank.com/exploring-widgetkit-first-control-widget-ios-18-swiftui)
- [iOS Localization: .strings, .xcstrings & String Catalogs](https://simplelocalize.io/blog/posts/manage-ios-translation-files/)
- [Apple: NSExtensionActivationRule](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSExtension/NSExtensionAttributes/NSExtensionActivationRule)
