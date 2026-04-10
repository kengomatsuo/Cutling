# Plan: Automated App Store Screenshots + Framed Promo Images

## Overview
Set up fastlane `snapshot` (automated screenshot capture via UI tests) and `frameit` (device frame + marketing text overlay) for all 39 App Store locales.

## Step 1: Create a UI Test Target
- Add a new `CutlingUITests` target to the Xcode project (xcodeproj modification)
- Create `CutlingUITests/SnapshotHelper.swift` — fastlane's helper file that provides the `snapshot()` function
- Create `CutlingUITests/CutlingUITests.swift` — the UI test that navigates the app and takes screenshots

## Step 2: Add a Screenshot Data Seeding Mode to the App
The app starts empty (`seedIfEmpty()` is a no-op). For screenshots we need visually appealing sample data.

- Add a launch argument check in `CutlingApp.swift`: when `"-SNAPSHOT_MODE"` is passed, seed the store with locale-appropriate sample cutlings
- Create a `SnapshotSeedData.swift` file with sample cutlings that look good on screen:
  - 6-8 text cutlings with varied colors and icons (address, email, bank number, social bio, etc.)
  - Cutling names/values will use `NSLocalizedString` so they display in the active locale
- Add corresponding entries to `Localizable.strings` for each sample cutling name/value

## Step 3: Write the UI Test
The test will:
1. Launch the app with `-SNAPSHOT_MODE` and the target locale
2. Wait for the main grid to populate
3. **Screenshot 1**: Main grid — "Your snippets, one tap away"
4. Tap a cutling to open TextDetailView
5. **Screenshot 2**: Detail/edit view — "Create and customize snippets"
6. Navigate back, open settings/keyboard view
7. **Screenshot 3**: Keyboard settings — "Built-in keyboard for instant paste"

> **Note on keyboard extension screenshot**: XCUITest can't switch to a custom keyboard or interact with the keyboard extension UI. We'll skip this as an automated screenshot — you can take it manually or use a static mockup.

## Step 4: Create Snapfile
```ruby
devices([
  "iPhone 16 Pro Max",    # 6.9" (required)
  "iPhone 16 Plus",       # 6.7"
  "iPhone 15 Pro Max",    # 6.7" (required for some)
  "iPhone 8 Plus",        # 5.5" (required)
  "iPad Pro 13-inch (M4)",# 13" iPad
  "iPad Pro (12.9-inch) (6th generation)" # 12.9" iPad
])

languages([
  "en-US", "ja", "ko", "zh-Hans", "zh-Hant",
  "de-DE", "fr-FR", "es-ES", "it", "pt-BR",
  "ar-SA", "nl-NL", "ru", "tr", "th",
  "sv", "da", "fi", "no", "pl",
  "he", "hi", "cs", "sk", "hu",
  "ro", "hr", "id", "ms", "vi",
  "el", "ca", "uk", "fr-CA", "es-MX",
  "en-AU", "en-CA", "en-GB", "pt-PT"
])

scheme("Cutling")
output_directory("./fastlane/screenshots")
clear_previous_screenshots(true)
```

## Step 5: Set Up frameit
- Create `fastlane/Framefile.json` with layout config (background color, text positioning, font)
- Create `fastlane/screenshots/*/title.strings` for each locale with localized marketing phrases for each screenshot (these overlay on the framed image)

The frameit config will:
- Add iPhone/iPad device frames around each screenshot
- Overlay localized marketing text above the device
- Use a clean background matching the app's teal accent

## Step 6: Create Fastfile Lanes
```ruby
lane :screenshots do
  snapshot
  frameit(white: false, path: "./fastlane/screenshots")
end

lane :upload_metadata do
  deliver(skip_binary_upload: true, skip_screenshots: false, force: true)
end
```

## Files to Create/Modify
1. **NEW** `CutlingUITests/CutlingUITests.swift` — UI test with snapshot calls
2. **NEW** `CutlingUITests/SnapshotHelper.swift` — fastlane snapshot helper
3. **NEW** `Cutling/Cutling/SnapshotSeedData.swift` — sample data for screenshots
4. **MODIFY** `Cutling/Cutling/CutlingApp.swift` — check for `-SNAPSHOT_MODE` launch arg
5. **MODIFY** `Cutling.xcodeproj/project.pbxproj` — add UI test target
6. **MODIFY** 48x `Localizable.strings` — add sample cutling name/value translations
7. **NEW** `fastlane/Snapfile` — device/language config
8. **NEW** `fastlane/Framefile.json` — frameit layout config
9. **NEW** `fastlane/Fastfile` — automation lanes
10. **NEW** `fastlane/screenshots/*/title.strings` — localized overlay text (39 locales)
