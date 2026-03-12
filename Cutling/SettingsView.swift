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
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @State private var showICloudAlert = false
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
                    Toggle(isOn: Binding(
                        get: { iCloudSyncEnabled },
                        set: { newValue in
                            if newValue {
                                showICloudAlert = true
                            } else {
                                iCloudSyncEnabled = false
                                UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.set(false, forKey: "iCloudSyncEnabled")
                            }
                        }
                    )) {
                        Label("iCloud Sync", systemImage: "icloud")
                    }
                    .alert("Enable iCloud Sync?", isPresented: $showICloudAlert) {
                        Button("Enable", role: .destructive) {
                            iCloudSyncEnabled = true
                            UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.set(true, forKey: "iCloudSyncEnabled")
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("iCloud Sync is an experimental feature and may not work correctly in all situations, which may lead to data loss.")
                    }
                } header: {
                    Text("Experimental Feature: iCloud")
                } footer: {
                    Text("Sync your cutlings across all your devices using iCloud.")
                }
                
                Section {
                    LabeledContent("Text Cutlings", value: "\(store.textCutlingsCount) / \(CutlingStore.maxTextCutlings)")
                    LabeledContent("Image Cutlings", value: "\(store.imageCutlingsCount) / \(CutlingStore.maxImageCutlings)")
                    LabeledContent("Max Text Length", value: String(localized: "\(CutlingStore.maxTextLength) chars"))
                } header: {
                    Text("Storage")
                } footer: {
                    Text("Each text cutling can hold up to \(CutlingStore.maxTextLength) characters.")
                }

                Section("About") {
                    LabeledContent("Version", value: "1.1.1")

                    Link(destination: URL(string: "mailto:kenneth@matsuokengo.com")!) {
                        Label("Contact Support", systemImage: "envelope")
                    }

                    Link(destination: URL(string: "https://kengomatsuo.github.io/Cutling/privacy/")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.square")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        if #available(iOS 26, *) {
                            Image(systemName: "xmark")
                        } else {
                            Text("Done")
                        }
                    }
                }
            }
            #endif
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
        .frame(minWidth: 360, idealWidth: 400, maxWidth: 400, minHeight: 250, idealHeight: 300)
        #endif
    }
}

#Preview {
    SettingsView()
    #if os(macOS)
    .frame(width: 400, height: 500)
    #endif
}
