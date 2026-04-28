//
//  ExpirationPicker.swift
//  Cutling
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import SwiftUI

// MARK: - Expiration Picker Section

/// Calendar-style auto-delete UI: a toggle that reveals a date picker when enabled.
struct ExpirationPickerSection: View {
    @Binding var autoDeleteEnabled: Bool
    @Binding var deleteAt: Date
    
    var body: some View {
        Section {
            Toggle("Auto-Delete", isOn: $autoDeleteEnabled.animation())
            if autoDeleteEnabled {
                DatePicker(
                    "Delete At",
                    selection: $deleteAt,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .frame(minHeight: 0, idealHeight: 0, maxHeight: 44)

            }
        } footer: {
            if autoDeleteEnabled {
                Text("This cutling will be automatically deleted at the selected date and time.")
            }
        }
    }
}
