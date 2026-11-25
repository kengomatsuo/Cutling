# Apple's guidance for the iPhone Duo, as it bears on Cutling and Undirect

Read 2026-11-25 by a fetch agent; quotes are Apple's unless marked. Sources:
[P1] https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo.md ·
[H] https://developer.apple.com/tutorials/data/design/human-interface-guidelines/designing-for-iphone-duo.md ·
[W] https://developer.apple.com/iphone-duo/prepare/ ·
[F1] https://developer.apple.com/forums/thread/848598 (a developer, no replies) ·
[F2] https://developer.apple.com/forums/thread/847644 (DTS group lab summary; only its first 40k characters were read verbatim, the rest is marked [summary]).

## SDK and orientation
- "Apps built with the iOS 27 SDK and later resize dynamically on iPhone Duo"; "Apps built with the iOS 27.1 SDK or later are optimized for iPhone Duo" [W]. "When you build with Xcode 26 and earlier, your app doesn't extend under the status bar and camera" [P1].
- What a portrait-only Info.plist does on the inner screen is not stated by Apple. [F1] (a developer) found five behaviours across settings; with all orientations in the plist and the scene returning portrait the app went full screen locked to portrait. [F2] [summary] says the inner display gives "regular-regular size classes, ignoring orientation restrictions". Unresolved: measured on the simulator instead (see simulator.md).
- "Don't use userInterfaceIdiom or UIInterfaceOrientation for layout decisions" [P1]; "the device's orientation doesn't tell you what shape your app is" [W]. HIG: "You can choose to lock to either portrait or landscape orientation, but be sure to fill the screen as the device pose changes" [H].

## Folding with an app open
- "Treat display transitions as size-class and trait changes, not a scene disconnect or app termination"; "apps adapt in place as the device opens and closes rather than backgrounding" [F2].
- "the active editing session and keyboard do not get a completely new scene"; the system "generally preserves text input and scroll position automatically" [F2]. This contradicts the keyboard developer in forum 850917 (focus lost on fold), so it is tested on the simulator rather than taken on trust.
- A fold "can resize your app in the middle of a session": re-read size in `layoutSubviews` / `viewDidLayoutSubviews` or with `onGeometryChange` [W].

## Fold and camera regions
- "A division occurs when a folding region divides a large view into smaller views." "An occlusion is an area of a view where a hardware element, such as the camera, covers your content." The fold region "is active when iPhone Duo is partially open, but inactive when it is fully open." [P1]
- "Use the ReservedRegion API to keep important elements clear of the center if the system doesn't move them automatically." "In a grid-style layout, prefer an even number of columns so content divides cleanly." [H]
- A custom element over the camera region: "touch events in that area are suppressed or may not register as expected" [F2].
- Nothing on keyboards or app extensions crossing the fold.

## Vertical bars
- Bars go vertical "for some views in the leading or trailing position on the inner display when the device is open"; in a split view, "horizontally for the sidebar or content view, and vertically for the detail view" [P1].
- "If your item has a title and doesn't have an icon, the system doesn't present it vertically"; custom-view items are not presented vertically either [P1].
- "In general, don't override the default bar placement" [H]. "There's no API that moves a custom tab bar for you": read `toolbarVerticalEdge` (SwiftUI) or `verticalBarEdge` (UIKit) [F2].
- "Before shipping an app build with the iOS 27.1 SDK, make sure your app's content adapts to the bars becoming vertical" [W].

## Size classes
- "A compact width layout for the outer display and a regular width layout for the inner display give you the fundamentals for every pose" [H].

## Extensions
- None of the five pages mentions app extensions, custom keyboards or Safari web extensions. Web side: Viewport Segments and Device Posture are "opt-in experimental features in iOS 27.1" in Safari [F2].

## Apple's own pre-submission list
- Replace `UIScreen.main`; remove orientation-based layout and idiom checks and fixed-size checks [W].
- Check each view, sheet and popover closed, open and partially folded; check for controls in the fold [P1].
- Test in the iPhone Duo simulator, "the best way to test the full native experience" [W].
