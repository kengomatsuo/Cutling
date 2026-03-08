//
//  SettingsView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: CutlingStore
    #if os(iOS)
    @State private var isKeyboardAdded = false
    @State private var hasFullAccess = false
    @State private var showSetupGuide = false

    private var isKeyboardEnabled: Bool {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let keyboards = UserDefaults.standard.stringArray(forKey: "AppleKeyboards") ?? []
        return keyboards.contains(where: { $0.hasPrefix(bundleID) })
    }

    private var fullAccessEnabled: Bool {
        UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.bool(forKey: "hasFullAccess") ?? false
    }
    #endif

    var body: some View {
        NavigationStack {
            Form {
                #if os(iOS)
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

                    Button {
                        showSetupGuide = true
                    } label: {
                        Label("Keyboard Setup Guide", systemImage: "book.pages")
                    }
                }
                #endif
                
                Section {
                    LabeledContent("Text Cutlings", value: "\(store.textCutlingsCount) / \(CutlingStore.maxTextCutlings)")
                    LabeledContent("Image Cutlings", value: "\(store.imageCutlingsCount) / \(CutlingStore.maxImageCutlings)")
                    LabeledContent("Max Text Length", value: "\(CutlingStore.maxTextLength) chars")
                } header: {
                    Text("Storage")
                } footer: {
                    Text("Each text cutling can hold up to \(CutlingStore.maxTextLength) characters.")
                }

                Section("About") {
                    LabeledContent("Version", value: "1.1.0")
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
                        #elseif os(iOS)
                        if #available(iOS 26, *) {
                            Image(systemName: "xmark")
                        } else {
                            Text("Done")
                        }
                        #endif
                    }
                }
            }
            #if os(iOS)
            .onAppear {
                isKeyboardAdded = isKeyboardEnabled
                hasFullAccess = fullAccessEnabled
            }
            .sheet(isPresented: $showSetupGuide) {
                KeyboardSetupView(isOnboarding: false)
            }
            #endif
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
