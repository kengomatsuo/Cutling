---
name: Cutling data model, CutlingStore, and persistence
description: Core data model (Cutling, CutlingKind, InputTypeCategory, DeletedCutling), CutlingStore API, limits, image handling, Darwin notifications, app group storage
type: project
originSessionId: 7b3b13ec-cea4-497f-8624-63751b64c94b
---
## Core Models (Cutling.swift)

**CutlingKind:** `.text` | `.image`

**Cutling struct** (Codable, Identifiable, Hashable):
- `id: UUID`, `name: String`, `value: String` (text content or empty for images)
- `icon: String` (SF Symbol name), `kind: CutlingKind`
- `imageFilename: String?` (UUID.png in shared Images directory)
- `sortOrder: Int`, `createdDate: Date`, `lastModifiedDate: Date`
- `expiresAt: Date?`, `color: String?`, `inputTypeTriggers: [String]?`
- Computed: `assignedCategories`, `isExpired`, `tintColor` (defaults to brand teal #00BE86)

**DeletedCutling** (soft-delete, 30-day retention):
- `cutling: Cutling`, `deletedAt: Date`
- `isPermanentlyExpired`, `daysRemaining`, `permanentDeletionDate`

**InputTypeCategory** (5 categories with NSDataDetector + NLTagger auto-detection):
- `.email` → emailAddress content/keyboard types
- `.url` → URL, webSearch types
- `.phoneNumber` → telephoneNumber, phonePad, numberPad, decimalPad
- `.name` → name, givenName, familyName, nickname
- `.address` → streetAddress, city, state, postalCode

**Color palette:** 12 colors (red, orange, yellow, green, mint, teal, cyan, blue, indigo, purple, pink, brown)

## CutlingStore (@MainActor, ObservableObject)

**Limits (nonisolated static let):**
- `maxTextCutlings = 100`, `maxImageCutlings = 25`, `maxTotalCutlings = 125`
- `maxTextLength = 2000` characters

**Persistence:**
- `UserDefaults(suiteName: "group.com.matsuokengo.Cutling")`
- Keys: `savedCutlings` (JSON [Cutling]), `recentlyDeletedCutlings` (JSON [DeletedCutling])
- Images directory in app group container (`containerURL/.../Images/`)

**Public API:**
- `load()`, `save()`, `add()`, `update()`, `delete()`, `duplicate()`
- `canAdd(CutlingKind) -> (allowed: Bool, reason: String?)`
- `sortCutlings(by:)`, `reverseCutlings()`, `moveCutlings(fromOffsets:toOffset:)`
- `purgeExpired()`, `schedulePurgeTimer()`
- `saveImageData(_:for:) -> String?`, `loadImageData(named:)`, `loadThumbnail(named:)`
- `findDuplicateImage(data:) -> Cutling?` (SHA256 hash comparison)
- `isTextTooLong(_:) -> Bool`

**#if MAIN_APP only:**
- `@Published var isSyncing`, `@Published var recentlyDeleted`
- `var syncManager: CloudKitSyncManager?`
- `restore()`, `permanentlyDelete()`, `emptyRecentlyDeleted()`, `purgeExpiredDeletions()`
- `applyRemoteChanges([Cutling])`

**Darwin Notifications:**
- `"com.matsuokengo.Cutling.cutlingsChanged"` — posted on every `save()`, observed by all targets
- Enables cross-process sync between main app and keyboard extension

**Image Thumbnails (memory-efficient):**
- `loadThumbnail()`: CGImageSourceCreateThumbnailAtIndex, 200px max, NSCache (30 items / 10MB)
- Critical for keyboard extension memory limits

## App Group Storage Map

UserDefaults keys:
- `savedCutlings`, `recentlyDeletedCutlings`
- `iCloudSyncEnabled`, `autoDetectInputTypes` (mirrored from Settings.bundle)
- `hasFullAccess` (keyboard), `keyboardPasteCount` (keyboard)
- `pendingControlAction` (widget intents → main app)

File system:
- `Images/` — UUID-named .png files
- `CloudKitSync/SyncEngineState.json`, `RecordMetadata.json` (main app only)
