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

// MARK: - Interactive tutorial: in-sheet steps (native popovers)
//
// The editor (create / edit) steps use TipKit popovers instead of the custom
// overlay so the system handles anchoring, scrolling, and keyboard avoidance.
// The coordinator drives `EditorTipAnchor` (with a 2s debounce and dismiss
// while typing); each tip is eligible only when the anchor matches.
// (#Rule can't read enum rawValue, so the raw ints are inlined.)

enum EditorTipAnchor: Int {
    case none = -1, name = 0, text = 1, save = 2, back = 3, delete = 4
}

struct EditorNameTip: Tip {
    @Parameter static var anchor: Int = -1
    var title: Text { Text("Give your cutling a name.") }
    var rules: [Rule] { #Rule(Self.$anchor) { $0 == 0 } }
    var options: [Option] { MaxDisplayCount(1000) }
}

struct EditorTextTip: Tip {
    @Parameter static var anchor: Int = -1
    var title: Text { Text("Now type the text you want to save.") }
    var rules: [Rule] { #Rule(Self.$anchor) { $0 == 1 } }
    var options: [Option] { MaxDisplayCount(1000) }
}

struct EditorSaveTip: Tip {
    @Parameter static var anchor: Int = -1
    var title: Text { Text("Tap here to save your cutling.") }
    var rules: [Rule] { #Rule(Self.$anchor) { $0 == 2 } }
    var options: [Option] { MaxDisplayCount(1000) }
}

struct EditorBackTip: Tip {
    @Parameter static var anchor: Int = -1
    var title: Text { Text("Edit anything, then go back to save.") }
    var rules: [Rule] { #Rule(Self.$anchor) { $0 == 3 } }
    var options: [Option] { MaxDisplayCount(1000) }
}

struct EditorDeleteTip: Tip {
    @Parameter static var anchor: Int = -1
    var title: Text { Text("Scroll down and tap Delete Cutling to remove it.") }
    var rules: [Rule] { #Rule(Self.$anchor) { $0 == 4 } }
    var options: [Option] { MaxDisplayCount(1000) }
}

/// Popover on the toolbar More button, shown once the walkthrough finishes via
/// the recover step, to teach where Recently Deleted lives.
struct RecoverWhereTip: Tip {
    @Parameter static var active: Bool = false
    var title: Text { Text("Open the More menu, then Recently Deleted, to restore anything you removed.") }
    var rules: [Rule] { #Rule(Self.$active) { $0 == true } }
    var options: [Option] { MaxDisplayCount(1000) }
}
#endif
