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

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $iCloudSyncEnabled) {
                    Label("iCloud Sync", systemImage: "icloud")
                }
                .onChange(of: iCloudSyncEnabled) { _, enabled in
                    UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.set(enabled, forKey: "iCloudSyncEnabled")
                }
            } header: {
                Text("iCloud")
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
