//
//  PreferencesView.swift
//  Cutling
//
//  macOS-only preferences view shown in the Settings scene (Cmd+,).
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import SwiftUI

struct PreferencesView: View {
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @AppStorage("autoDetectInputTypes") private var autoDetectInputTypes = true
    @AppStorage("spotlightIndexingEnabled") private var spotlightIndexingEnabled = true
    @State private var showICloudAlert = false

    var body: some View {
        Form {
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
                Toggle(isOn: $autoDetectInputTypes) {
                    Label("Auto-detect Input Types", systemImage: "wand.and.stars")
                }
            } header: {
                Text("Input Types")
            } footer: {
                Text("Automatically detect and suggest input type categories when editing text.")
            }

            Section {
                Toggle(isOn: $spotlightIndexingEnabled) {
                    Label("Include in Spotlight Search", systemImage: "magnifyingglass")
                }
            } header: {
                Text("Spotlight")
            } footer: {
                Text("Make your cutlings searchable from Spotlight. Sensitive content (credit cards, API keys, JWT tokens, seed phrases, private keys) is never indexed.")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 360, idealWidth: 400, maxWidth: 400, minHeight: 200, idealHeight: 250)
    }
}

#Preview {
    PreferencesView()
        .frame(width: 400, height: 300)
}
