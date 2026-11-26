//
//  LimitAlert.swift
//  Cutling
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI

/// The one way the app answers "can't add another cutling": when the free limit is what stops it, the unlock
/// screen opens; when a memory cap stops it, the "Limit Reached" alert explains which.
struct LimitAlert: ViewModifier {
    @Binding var message: String?
    /// What the person was adding when the free limit stopped them (the + menu's text or image): the unlock sheet then
    /// ends with Continue, and `open` starts that cutling once the sheet has left. Read once, so a later limit alert
    /// from another path never inherits it.
    var draft: Binding<NewCutlingDraft?>?
    var open: ((NewCutlingDraft) -> Void)?
    @State private var showUnlock = false
    @State private var waiting: NewCutlingDraft?
    @State private var continued = false

    func body(content: Content) -> some View {
        content
            .alert(
                "Limit Reached",
                isPresented: Binding(
                    get: { message != nil && !showUnlock },
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
                waiting = draft?.wrappedValue
                draft?.wrappedValue = nil
                showUnlock = true
            }
    }
}

extension View {
    func limitAlert(_ message: Binding<String?>, draft: Binding<NewCutlingDraft?>? = nil, open: ((NewCutlingDraft) -> Void)? = nil) -> some View {
        modifier(LimitAlert(message: message, draft: draft, open: open))
    }

    /// For editors that keep the alert as a flag and a text.
    func limitAlert(isPresented: Binding<Bool>, message: String) -> some View {
        modifier(LimitAlert(message: Binding(
            get: { isPresented.wrappedValue ? message : nil },
            set: { if $0 == nil { isPresented.wrappedValue = false } }
        )))
    }
}
