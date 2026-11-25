# What the iPhone Duo simulator showed (Xcode 27.2, iOS 27.2 runtime, 2026-11-25)

Device 1C9B1433 (iPhone Duo, slim simulator through the device queue). Outer screen 466 x 678 pt (1398 x 2034 px), inner 951 x 669 pt open (2853 x 2007 px). Screens: `~/Downloads/Claude/duo-editions/`.

## Portrait-only apps fill the inner screen
Both apps declare only portrait on iPhone and both fill the open inner screen (951 x 669, wide), with no black bars, built with the iOS 27.2 SDK. The open-source claim that a portrait-only app gets a centred portrait window with black sides (CYLTabBarController #719) does not hold for these builds. The inner screen gives the app the regular width class; Cutling's adaptive grid lays out 4 columns there (an even count, as Apple's HIG asks, so the fold falls between the second and third), 2 on the outer screen.

## Bars go vertical
On both screens the status bar and the toolbar sit in a column on the right. Cutling's +, keyboard and more buttons move into it; Undirect's split view keeps its sidebar on the inner screen and collapses to the detail with a back button in the column on the outer one.

## Toolbar items that are zoom transition sources come back empty after an unfold
Cutling's grid launched on the outer screen and then unfolded showed an empty capsule in the side column: no +, keyboard or more button, and taps on it did nothing, until the app relaunched. A cold launch on the inner screen was fine, and folding back to the outer screen was fine. Reproduced in a bare SwiftUI app (scratch `DuoRepro`): a `NavigationStack` toolbar whose `ToolbarItem`s carry `.matchedTransitionSource(id:in:)` (the source of a sheet's zoom) loses all its items on outer-to-inner; without the modifier the items survive; `.matchedTransitionSource` on the button view instead of the item fails the same way; keying only the two source items' content with `.id(horizontalSizeClass)` brought them back but dropped the third item; keying every item's content by the width class keeps all three, tappable, with the zoom sources kept. Cutling now does the last (commit be5a34a2).

## Cutling's keyboard across fold and unfold
In Safari's address field with the Cutling keyboard up: typing a cutling on the outer screen, unfolding, typing on the inner screen, folding and typing again all worked; focus and text stayed, and the keyboard stayed Cutling's. Half open (100 degrees) the keyboard stays up and types; it does not split around the fold as Apple's keyboard does, and its 4-column grid puts the fold in the gap between the second and third columns. The forum report of focus lost on fold (thread 850917) did not reproduce here.

On the inner screen the keyboard takes the regular-width (iPad) height, about 400 pt of the 669 pt screen; Apple's keyboard there is about 267 pt (Divvun's measure).

The first time the Cutling keyboard was chosen from the globe menu on the outer screen it came up blank (iOS's default 245 pt, no keys), with UIKit logging "Invalid UIScreen coordinate space conversion" between two UIScreen objects of the same 466 x 678 size while converting the keyboard's 452 x 294 frame; that cold start took 73 s on an overloaded Mac (load 50-200). Focusing the field again showed the keyboard whole. Dictus's audit (getdictus/dictus-ios #785) saw the same blank cover-screen keyboard after the globe menu, fixed by refocusing. GUESS: an iOS 27.2 issue with third-party keyboards on the cover screen, not Cutling's code, which does no screen conversion.

`needsInputModeSwitchKey` was true on the outer screen: Cutling drew its globe key there.
