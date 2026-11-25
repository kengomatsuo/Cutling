# What the iOS 27.2 SDK gives an app for the iPhone Duo

Read 2026-11-25 from Xcode 27.2's iPhoneOS27.2.sdk (build 24B8118): UIKit headers and the SwiftUICore `arm64e-apple-ios.swiftinterface`.

## Which SDK each live build used (App Store Connect `buildBundles.sdkBuild`, read 2026-11-25)

- Cutling iOS 1.6.2 (build 20, 2026-11-18): 24B8118, the iOS 27.2 SDK. Undirect iOS 1.1.1 (build 23, 2026-11-23): 24B8118. Earlier builds (Cutling 1.6.0, Undirect 1.0.2) used 24A430, the iOS 27.0 SDK.
- Both apps' Xcode Cloud workflows (Cutling Release and Proof, Undirect Release) pin `27B52`, "Xcode 27.2".
- So both live apps already clear the "iOS 27.1 SDK or later" bar that removes the black bars (iThinkDifferent, 2026-10-31). What remains is whether their layouts are right on each screen.

## Hinge

- `UIHingeInteraction(updateHandler:)` (UIKit, iOS 27.1): add to a view; the handler gets the initial state and each change. `update.hinge` is nil when the view leaves a hierarchy that provides hinge updates. `UIHinge.status` is `.unknown`, `.closed`, `.partiallyOpen`, `.fullyOpen`; `UIHinge.angle` is radians, and the header says to prefer `status` unless the angle is needed.
- SwiftUI (iOS 27.1): `View.onHingeChange(isEnabled:_:)` with `(old: DeviceHingeContext, new: DeviceHingeContext)`; `DeviceHingeContext.hinge: DeviceHinge?`; `DeviceHinge.status` is `.closed`, `.partiallyOpen`, `.fullyOpen`.

## Reserved regions (the hinge crease and the camera)

- `UIView.reservedRegions(ofKind:)` and `reservedRegions(ofKind:options:)` (iOS 27.1). Kinds: `occlusionRegionKind` ("A region that is occluded by an element") and `divisionRegionKind` ("A region where an element should divide into two separate regions"). Each `UIViewReservedRegion` has `frame` in the view's coordinates including `margins` (kept clear "for interactive content"), `kind`, `identifier`, `isActive`; `.includeInactive` returns inactive ones too.
- SwiftUI: `GeometryProxy.reservedRegions(kind: .occlusion | .division, options:, layoutDirectionBehavior:)` (iOS 27.1), returning `ReservedRegion` with `frame`, `margins`, `isActive`.

## Vertical bar (status bar and bars on the side)

- `UITraitCollection.verticalBarEdge` (iOS 27.1): `.unspecified`, `.leading`, `.trailing`; "hardware without a vertical bar" reads unspecified. Observe with `systemTraitsAffectingVerticalBarEdge`.
- `UIViewController.preferredVerticalBarBehavior` (`.automatic` / `.disabled`), `childForPreferredVerticalBarBehavior`, `setNeedsUpdateOfVerticalBarConfiguration()`. The header: disable it only for "a fullscreen video player with toolbar controls or a non-scrolling layout like a calculator"; when it turns on, "the leading or trailing safe area inset for the vertical bar is added or removed". So the side bar arrives to an app as a safe-area inset on one side only, which a layout that assumes symmetric insets gets wrong.
- `UIBarButtonItem.axisBehavior` (`.horizontalOnly`, `.verticalPreferred`) and `UINavigationItem.verticalBarCompressionBehavior` (`.prefersBarItems`, `.prefersTabBar`), iOS 27.1, choose which items move into that bar.

## Other iOS 27.1 layout types

`UISplitArrangement`, `UIOverlayArrangement` and `UIArrangementViewController` (iOS 27.1) are new containers for arranging view controllers side by side or overlaid. Not needed by either app; noted only.
