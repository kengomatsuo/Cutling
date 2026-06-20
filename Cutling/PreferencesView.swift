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
    @EnvironmentObject private var store: CutlingStore
    @State private var diskUsageBytes: Int64 = 0

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $iCloudSyncEnabled) {
                    Label("iCloud Sync", systemImage: "icloud")
                }
                .onChange(of: iCloudSyncEnabled) { _, enabled in
                    UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.set(enabled, forKey: "iCloudSyncEnabled")
                }
                if iCloudSyncEnabled {
                    HStack {
                        Label("Status", systemImage: "arrow.triangle.2.circlepath")
                        Spacer()
                        if store.isSyncing {
                            ProgressView()
                                .controlSize(.small)
                            Text("Syncing…")
                                .foregroundStyle(.secondary)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Up to date")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("iCloud")
            } footer: {
                Text("Sync your cutlings across all your devices using iCloud.")
            }

            Section {
                StorageUsageRow(
                    title: "Text Cutlings",
                    icon: "doc.text",
                    used: store.textCutlingsCount,
                    limit: CutlingStore.maxTextCutlings
                )
                StorageUsageRow(
                    title: "Image Cutlings",
                    icon: "photo",
                    used: store.imageCutlingsCount,
                    limit: CutlingStore.maxImageCutlings
                )
                StorageUsageRow(
                    title: "Total Cutlings",
                    icon: "tray.full",
                    used: store.cutlings.count,
                    limit: CutlingStore.maxTotalCutlings
                )
                LabeledContent {
                    Text(ByteCountFormatter.string(fromByteCount: diskUsageBytes, countStyle: .file))
                        .foregroundStyle(.secondary)
                } label: {
                    Label("Disk Usage", systemImage: "internaldrive")
                }
                LabeledContent("Max Text Length", value: String(localized: "\(CutlingStore.maxTextLength) chars"))
            } header: {
                Text("Storage")
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

        }
        .formStyle(.grouped)
        .frame(minWidth: 360, idealWidth: 420, maxWidth: 460, minHeight: 320, idealHeight: 420)
        .task {
            diskUsageBytes = await StorageUsageRow.diskUsage(in: store.imagesDirectory)
        }
    }
}

#Preview {
    PreferencesView()
        .environmentObject(CutlingStore.shared)
        .frame(width: 420, height: 500)
}
