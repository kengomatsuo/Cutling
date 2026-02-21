//
//  SettingsView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isKeyboardAdded = false
    @State private var hasFullAccess = false

    private var isKeyboardEnabled: Bool {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let keyboards = UserDefaults.standard.stringArray(forKey: "AppleKeyboards") ?? []
        return keyboards.contains(where: { $0.hasPrefix(bundleID) })
    }

    private var fullAccessEnabled: Bool {
        UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.bool(forKey: "hasFullAccess") ?? false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Keyboard Setup") {
                    HStack {
                        Label("Keyboard Added", systemImage: "keyboard")
                        Spacer()
                        Image(systemName: isKeyboardAdded ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(isKeyboardAdded ? .green : .secondary)
                    }
                    HStack {
                        Label("Full Access", systemImage: "hand.raised")
                        Spacer()
                        Image(systemName: hasFullAccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(hasFullAccess ? .green : .secondary)
                    }

                    if !isKeyboardAdded || !hasFullAccess {
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Open Settings to Enable", systemImage: "arrow.up.forward.square")
                        }
                    }
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
            .onAppear {
                isKeyboardAdded = isKeyboardEnabled
                hasFullAccess = fullAccessEnabled
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
