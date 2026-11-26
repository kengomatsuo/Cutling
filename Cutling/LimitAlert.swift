//
//  LimitAlert.swift
//  Cutling
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI

/// What waits while the person unlocks, so nothing they were adding is lost at the free limit: the glyph in the sixth
/// tile, what runs once the unlock arrives (saves the item), and what runs if the sheet closes without it. A duplicate
/// or a restore keeps its original where it is until then; a Share or keyboard item waits in `Pending/`.
struct UnlockWaiting: Identifiable {
    let id = UUID()
    var icon: String?
    var onUnlocked: (() -> Void)?
    var onDismissed: (() -> Void)?
}

extension EnvironmentValues {
    /// Opens the unlock sheet with an item waiting, from a view that has no sheet of its own (a card's Duplicate).
    /// Set by the screen that owns the sheet.
    @Entry var askToUnlock: (UnlockWaiting) -> Void = { _ in }
}

/// The one way the app answers "can't add another cutling": when the free limit is what stops it, the unlock
/// screen opens; when a memory cap stops it, the "Limit Reached" alert explains which.
struct LimitAlert: ViewModifier {
    @Binding var message: String?
    /// What the person was adding when the free limit stopped them (the + menu's text or image): the unlock sheet then
    /// ends with Continue, and `open` starts that cutling once the sheet has left. Read once, so a later limit alert
    /// from another path never inherits it.
    var draft: Binding<NewCutlingDraft?>?
    var open: ((NewCutlingDraft) -> Void)?
    #if os(macOS)
    /// Runs once the unlock window has unlocked (the Mac's add windows save what they hold).
    var retry: (() -> Void)?
    #endif
    @State private var showUnlock = false
    @State private var waiting: NewCutlingDraft?
    @State private var continued = false

    func body(content: Content) -> some View {
        content
            .alert(
                "Limit Reached",
                isPresented: Binding(
                    get: { message != nil && !showUnlock && !handsOffToUnlock },
                    set: { if !$0 { message = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(message ?? "")
            }
            .sheet(isPresented: $showUnlock, onDismiss: {
                if continued, let waiting { open?(waiting) }
                continued = false
                waiting = nil
            }) {
                UnlockView(onContinue: waiting == nil ? nil : { continued = true })
            }
            .onChange(of: message) { _, new in
                guard new != nil, CutlingStore.shared.needsUnlock else { return }
                message = nil
                #if os(macOS)
                // The Mac asks in its own window, never a sheet.
                MacUnlockWindow.shared.show(MacUnlockWaiting(onUnlocked: retry))
                return
                #else
                waiting = draft?.wrappedValue
                draft?.wrappedValue = nil
                showUnlock = true
                #endif
            }
    }

    /// The free limit, not a memory cap, stopped the add: the unlock ask follows, so the plain alert must not flash first.
    private var handsOffToUnlock: Bool {
        #if os(macOS)
        CutlingStore.shared.needsUnlock
        #else
        false
        #endif
    }
}

extension View {
    func limitAlert(_ message: Binding<String?>, draft: Binding<NewCutlingDraft?>? = nil, open: ((NewCutlingDraft) -> Void)? = nil) -> some View {
        modifier(LimitAlert(message: message, draft: draft, open: open))
    }

    /// For editors that keep the alert as a flag and a text.
    func limitAlert(isPresented: Binding<Bool>, message: String, retry: (() -> Void)? = nil) -> some View {
        let shown = Binding<String?>(
            get: { isPresented.wrappedValue ? message : nil },
            set: { if $0 == nil { isPresented.wrappedValue = false } }
        )
        #if os(macOS)
        return modifier(LimitAlert(message: shown, retry: retry))
        #else
        return modifier(LimitAlert(message: shown))
        #endif
    }
}

#if os(iOS)
extension View {
    /// Opens the unlock sheet with `waiting` in its sixth tile when it is set; closing clears it.
    func unlockSheet(_ waiting: Binding<UnlockWaiting?>) -> some View {
        sheet(item: waiting) { item in
            UnlockView(waiting: item)
        }
    }
}
#endif
