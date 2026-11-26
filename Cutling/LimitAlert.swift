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
    @State private var showUnlock = false

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
            .sheet(isPresented: $showUnlock) {
                UnlockView()
            }
            .onChange(of: message) { _, new in
                guard new != nil, CutlingStore.shared.needsUnlock else { return }
                message = nil
                showUnlock = true
            }
    }
}

extension View {
    func limitAlert(_ message: Binding<String?>) -> some View {
        modifier(LimitAlert(message: message))
    }

    /// For editors that keep the alert as a flag and a text.
    func limitAlert(isPresented: Binding<Bool>, message: String) -> some View {
        modifier(LimitAlert(message: Binding(
            get: { isPresented.wrappedValue ? message : nil },
            set: { if $0 == nil { isPresented.wrappedValue = false } }
        )))
    }
}
