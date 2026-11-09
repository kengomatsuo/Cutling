//
//  PromoTakeDirector.swift
//  Cutling: promo takes only.
//
//  A film script drives the real picker over a distributed notification, so a
//  take never moves the owner's pointer, takes keyboard focus, or touches the
//  clipboard. Orders, carried as the notification's object:
//  show, hide, quit, hover:<row>, hover:none, press:<row>, tab:saved, tab:history.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#if os(macOS) && DEBUG
import AppKit
import Combine

@MainActor
final class PromoTakeDirector: ObservableObject {
    static let shared = PromoTakeDirector()
    nonisolated static let isDirected = ProcessInfo.processInfo.arguments.contains("-PROMO_DIRECTED")

    @Published private(set) var hoveredRow: UUID?
    @Published private(set) var pressedRow: UUID?
    @Published private(set) var requestedTab: MacPickerTab?

    private var observer: NSObjectProtocol?

    func start() {
        observer = DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("com.matsuokengo.Cutling.promoTake"),
            object: nil,
            queue: .main
        ) { note in
            guard let order = note.object as? String else { return }
            Task { @MainActor in PromoTakeDirector.shared.perform(order) }
        }
    }

    private func rowID(_ text: Substring) -> UUID? {
        guard let index = Int(text) else { return nil }
        let rows = CutlingStore.shared.cutlings.sorted { $0.sortOrder < $1.sortOrder }
        return rows.indices.contains(index) ? rows[index].id : nil
    }

    private func perform(_ order: String) {
        let parts = order.split(separator: ":", maxSplits: 1)
        guard let verb = parts.first else { return }
        let argument = parts.count > 1 ? parts[1] : ""
        switch verb {
        case "show":
            // The notification the hotkey handler posts: same path as ⌘⇧V.
            if !CutlingPickerController.shared.isPanelVisible {
                NotificationCenter.default.post(name: .cutlingHotkeyPressed, object: nil)
            }
        case "hide":
            CutlingPickerController.shared.hide()
        case "quit":
            NSApp.terminate(nil)
        case "hover":
            hoveredRow = rowID(argument)
        case "press":
            pressedRow = rowID(argument)
            // A pick's visible effect is the panel closing; the clipboard stays out of it.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                NotificationCenter.default.post(name: .cutlingDidPickFromPicker, object: nil)
            }
        case "tab":
            requestedTab = argument == "history" ? .history : .saved
        default:
            break
        }
    }
}
#endif
