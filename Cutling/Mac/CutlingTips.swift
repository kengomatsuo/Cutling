//
//  CutlingTips.swift
//  Cutling: TipKit definitions for contextual feature discovery.
//
//  Two tips:
//    HotkeyTip: surfaces the global hotkey after the user has opened the
//      menu bar popover twice without ever pressing ⌘⇧V.
//    PromoteHistoryTip: after the user views the history tab at least
//      once but hasn't promoted any item to a saved cutling.
//
//  Apple HIG explicitly recommends "context-specific tips integrated into
//  your experience" over single onboarding flows, which is what TipKit
//  provides. Configure once at app launch; donate events when the user
//  exercises the feature so the tip auto-retires.
//

#if os(macOS)
import TipKit
import SwiftUI

struct HotkeyTip: Tip {
    static let pickerOpened = Event(id: "pickerOpened")
    static let hotkeyPressed = Event(id: "hotkeyPressed")

    var title: Text {
        Text("Summon from anywhere")
    }

    var message: Text? {
        Text("Press ⌘⇧V from any app to open this picker at your cursor.")
    }

    var image: Image? {
        Image(systemName: "keyboard")
    }

    var rules: [Rule] {
        // After they've explored the popover at least twice.
        #Rule(Self.pickerOpened) { $0.donations.count >= 2 }
        // And they haven't discovered the hotkey on their own.
        #Rule(Self.hotkeyPressed) { $0.donations.count == 0 }
    }

    var options: [Option] {
        MaxDisplayCount(3)
    }
}

struct PromoteHistoryTip: Tip {
    static let viewedHistory = Event(id: "viewedHistory")
    static let promotedToSaved = Event(id: "promotedToSaved")

    var title: Text {
        Text("Save it for later")
    }

    var message: Text? {
        Text("Right-click any history item to promote it to a named cutling that syncs across your devices.")
    }

    var image: Image? {
        Image(systemName: "star")
    }

    var rules: [Rule] {
        #Rule(Self.viewedHistory) { $0.donations.count >= 1 }
        #Rule(Self.promotedToSaved) { $0.donations.count == 0 }
    }

    var options: [Option] {
        MaxDisplayCount(3)
    }
}
#endif
