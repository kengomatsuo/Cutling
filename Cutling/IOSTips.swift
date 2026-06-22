//
//  IOSTips.swift
//  Cutling: TipKit definitions for contextual feature discovery on iOS.
//
//  These are intentionally sparse and rule-gated — Apple's TipKit guidance
//  says tips should highlight non-obvious features users haven't discovered
//  on their own, NOT guide them through the app. The full setup walkthrough
//  lives in KeyboardSetupView; these tips fill in the gaps for features
//  that are physically present in the UI but easy to miss.
//

#if os(iOS)
import TipKit
import SwiftUI

/// Surfaces the hidden Select / Reorder / Recently Deleted actions buried
/// under the toolbar's ellipsis menu. Gated by cutling count so the tip
/// only fires when bulk actions are actually useful, and skipped after
/// the user opens the menu (any first donation invalidates it).
struct MoreMenuTip: Tip {
    @Parameter static var cutlingCount: Int = 0
    @Parameter static var setupComplete: Bool = false
    static let opened = Event(id: "moreMenuOpened")

    var title: Text { Text("More options") }
    var message: Text? {
        Text("Tap here to select multiple cutlings, reorder them, or restore recently deleted ones.")
    }
    var image: Image? { Image(systemName: "ellipsis.circle") }

    var rules: [Rule] {
        #Rule(Self.$setupComplete) { $0 == true }
        #Rule(Self.$cutlingCount) { $0 >= 5 }
        #Rule(Self.opened) { $0.donations.count == 0 }
    }
    var options: [Option] { MaxDisplayCount(1) }
}

/// The long-press context menu on each card hides Copy / Edit / Share /
/// Delete shortcuts. Surface this once the user has enough cards that
/// per-card actions matter. `hasOpenedContextMenu` flips true the first
/// time any card's context menu fires and persists via TipKit's datastore.
struct LongPressCardTip: Tip {
    @Parameter static var cutlingCount: Int = 0
    @Parameter static var hasOpenedContextMenu: Bool = false
    @Parameter static var setupComplete: Bool = false

    var title: Text { Text("Long-press a cutling") }
    var message: Text? {
        Text("Hold any card for quick actions: copy, edit, share, or delete.")
    }
    var image: Image? { Image(systemName: "hand.tap") }

    var rules: [Rule] {
        #Rule(Self.$setupComplete) { $0 == true }
        #Rule(Self.$cutlingCount) { $0 >= 3 }
        #Rule(Self.$hasOpenedContextMenu) { $0 == false }
    }
    var options: [Option] { MaxDisplayCount(1) }
}

/// The drag-across-cards range-select gesture is completely invisible
/// without a hint. Fires once the user enters Select mode for the first
/// time and disappears the moment they leave the mode or perform a drag.
struct DragToSelectTip: Tip {
    @Parameter static var isSelecting: Bool = false
    @Parameter static var setupComplete: Bool = false

    var title: Text { Text("Drag to select") }
    var message: Text? {
        Text("Swipe across cards to select a range. Swipe back over them to deselect.")
    }
    var image: Image? { Image(systemName: "hand.draw") }

    var rules: [Rule] {
        #Rule(Self.$setupComplete) { $0 == true }
        #Rule(Self.$isSelecting) { $0 == true }
    }
    var options: [Option] { MaxDisplayCount(1) }
}

/// Smart field matching is the keyboard's most magical feature but it
/// happens silently — users have no way to discover that Cutling
/// auto-promotes matching snippets when typing in an email / URL / phone
/// field. Shown the first time the user opens the keyboard manager and
/// owns at least one snippet that the detector has tagged.
struct InputTypeMatchTip: Tip {
    @Parameter static var hasTaggedCutling: Bool = false
    @Parameter static var setupComplete: Bool = false

    var title: Text { Text("Smart field matching") }
    var message: Text? {
        Text("Cutling spots email, URL, phone, and address fields, then floats matching snippets to the top of the keyboard.")
    }
    var image: Image? { Image(systemName: "wand.and.stars") }

    var rules: [Rule] {
        #Rule(Self.$setupComplete) { $0 == true }
        #Rule(Self.$hasTaggedCutling) { $0 == true }
    }
    var options: [Option] { MaxDisplayCount(1) }
}
#endif
