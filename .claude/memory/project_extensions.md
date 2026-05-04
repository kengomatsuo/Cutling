---
name: Cutling extension targets — keyboard, share, action, widgets
description: Architecture and features of all 4 extension targets (CutlingKeyboard, CutlingShare, CutlingAction, CutlingWidgetsExtension)
type: project
originSessionId: 7b3b13ec-cea4-497f-8624-63751b64c94b
---
## CutlingKeyboard (Keyboard Extension)

**Files:** `KeyboardViewController.swift` (1266 lines), `KeyboardSyncHelper.swift` (209 lines)

**Architecture:**
- `KeyboardViewController` (UIInputViewController) hosts SwiftUI `KeyboardView` via UIHostingController
- `KeyboardState` (Observable) bridges UIKit ↔ SwiftUI (return key type, full access, keyboard/content type)

**Layout (3 parts):**
1. Suggestion bar — clipboard button + "Open Cutling" link
2. Cutling grid — LazyVGrid of CutlingKeyView cards, filtered by input type
3. Bottom row — backspace (with repeat), space, return keys

**Text vs Image handling:**
- Text: `textDocumentProxy.insertText()` (instant)
- Image: `UIPasteboard.general.image = ...` (requires full access, shows lock icon otherwise)

**Special features:**
- InstantPress modifier (zero-latency DragGesture)
- BackspaceRepeat (500ms delay → char-by-char 100ms → word-by-word after 1.8s)
- System keyboard sounds (AudioToolbox: 1123/1155/1156) + haptics
- Input type awareness — suggests cutlings matching active keyboard type
- Memory-constrained: thumbnails only (200px), NSCache eviction
- Lightweight CloudKit sync via `KeyboardSyncHelper` (direct CKRecord saves, no CKSyncEngine)

**Sizing:** iPad 64pt keys / iPhone 44pt / landscape 32pt; grid height scales with size class.

## CutlingShare (Share Extension)

**Files:** `ShareViewController.swift`, `ShareView.swift`

**ShareViewController:** UIViewController hosting SwiftUI ShareView via UIHostingController. Passes `extensionContext` and dismiss callback.

**ShareView (SwiftUI Form):**
- Extracts shared content from `NSExtensionContext.inputItems` via `NSItemProvider`
- Supports 3 types: `.text(String)`, `.url(URL)`, `.image(Data)`
- Priority order: image → URL → plain text
- Full editing: name, icon picker, color palette, input type suggestions (for text/URL), expiration
- Limit enforcement via `store.canAdd()`, duplicate image detection
- Image data conversion: URL → Data, UIImage → pngData, raw Data

**Info.plist activation rules:** text, 1 image max, 1 URL max (dictionary form, not TRUEPREDICATE).

## CutlingAction (Action Extension)

**Files:** `ActionViewController.swift`

Reuses `ShareView` identically to CutlingShare. Appears in the "Actions" row of the share sheet instead of the "Share" row. Same `NSExtensionActivationRule` configuration.

## CutlingWidgetsExtension (Widget Extension)

**Files:** `CutlingWidgetsBundle.swift`, `AddFromClipboardControl.swift`, `NewTextCutlingControl.swift`, `NewImageCutlingControl.swift`

**3 ControlWidget structs (iOS 18+):**
1. `AddFromClipboardControl` — `ControlWidgetButton` + `AddFromClipboardIntent` (fire-and-forget, copies clipboard to store)
2. `NewTextCutlingControl` — `ControlWidgetButton` + `OpenCutlingIntent(target: .newText)` (opens app)
3. `NewImageCutlingControl` — `ControlWidgetButton` + `OpenCutlingIntent(target: .newImage)` (opens app)

**AppIntents (shared with main app):**
- `AddFromClipboardIntent: AppIntent` — reads UIPasteboard, saves text/image to store, returns IntentDialog feedback ("Saved!", "Clipboard is empty.", or limit reason)
- `OpenCutlingIntent: OpenIntent` — sets `pendingControlAction` in group UserDefaults, main app reads on foreground
- `CutlingScreen: AppEnum` — `.newText`, `.newImage` (target parameter for OpenCutlingIntent)

**Communication:** Widget → App via `pendingControlAction` key in shared UserDefaults. App reads and clears in `handlePendingControlAction()`.
