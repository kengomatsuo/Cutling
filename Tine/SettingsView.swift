//
//  SettingsView.swift
//  Tine
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Keyboard") {
                    Label("How to enable Tine keyboard", systemImage: "keyboard")
                }
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        #if os(macOS)
                        Text("Done")
                        #else
                        Image(systemName: "xmark")
                        #endif
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 360, idealWidth: 400, minHeight: 250, idealHeight: 300)
        #endif
    }
}

#Preview {
    SettingsView()
    #if os(macOS)
    .frame(width: 400, height: 500)
    #endif
}
