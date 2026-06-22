//
//  CutlingTips.swift
//  Cutling: TipKit definitions for the macOS picker's guided tour.
//
//  A single ordered TipGroup walks the user through the popover one
//  control at a time. Each tip is `MaxDisplayCount(1)`, so the first
//  appearance is also the last and the carousel advances as soon as the
//  user closes the popover (or hits the X). Tips that depend on UI
//  state (Clear History, Recently Deleted) are gated by a @Parameter so
//  the ordered group transparently skips them when the underlying
//  button isn't on screen.
//

#if os(macOS)
import TipKit
import SwiftUI

struct SavedTabTip: Tip {
    var title: Text { Text("Saved cutlings") }
    var message: Text? {
        Text("Your pinned snippets live here, ready to copy with one click.")
    }
    var image: Image? { Image(systemName: "tray.full") }
    var options: [Option] { MaxDisplayCount(1) }
}

struct HistoryTabTip: Tip {
    var title: Text { Text("Recent clipboard") }
    var message: Text? {
        Text("Everything you copy lands here. Right-click any row to save it as a cutling.")
    }
    var image: Image? { Image(systemName: "clock.arrow.circlepath") }
    var options: [Option] { MaxDisplayCount(1) }
}

struct ClearHistoryTip: Tip {
    /// True only when the user is on the History tab AND there's at least
    /// one history item. Both are needed because the Clear History button
    /// is only mounted in that combined state.
    @Parameter static var canShow: Bool = false

    var title: Text { Text("Wipe the list") }
    var message: Text? {
        Text("Empties your recent clipboard. Saved cutlings stay put.")
    }
    var image: Image? { Image(systemName: "eraser") }

    var rules: [Rule] {
        #Rule(Self.$canShow) { $0 == true }
    }
    var options: [Option] { MaxDisplayCount(1) }
}

struct AddButtonTip: Tip {
    var title: Text { Text("Create a new cutling") }
    var message: Text? {
        Text("Save text or image snippets you'll reuse from any app.")
    }
    var image: Image? { Image(systemName: "plus.circle") }
    var options: [Option] { MaxDisplayCount(1) }
}

struct SettingsButtonTip: Tip {
    var title: Text { Text("Settings") }
    var message: Text? {
        Text("Rebind the hotkey, toggle clipboard capture, and manage iCloud sync.")
    }
    var image: Image? { Image(systemName: "gear") }
    var options: [Option] { MaxDisplayCount(1) }
}

struct RecentlyDeletedButtonTip: Tip {
    /// True only when the store actually has a deleted item available to
    /// recover. Just-in-time education: pointing at an empty list makes
    /// the tip feel like an instruction manual rather than a useful hint.
    @Parameter static var hasDeletedCutlings: Bool = false

    var title: Text { Text("Undo deletes") }
    var message: Text? {
        Text("Deleted cutlings stay here for 30 days. Restore them or empty for good.")
    }
    var image: Image? { Image(systemName: "arrow.uturn.backward") }

    var rules: [Rule] {
        #Rule(Self.$hasDeletedCutlings) { $0 == true }
    }
    var options: [Option] { MaxDisplayCount(1) }
}

#endif
