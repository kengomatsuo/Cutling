//
//  KeyboardView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import AppIntents
import SwiftUI
import TipKit

#if !os(macOS)

private let websiteBaseURL = "https://kengomatsuo.github.io/Cutling"

struct KeyboardView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: CutlingStore
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
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

    private let inputTypeMatchTip = InputTypeMatchTip()
    #endif

    #if os(iOS)
    /// Marks the tip eligible once the user owns at least one cutling that
    /// the input-type detector has tagged. Until then the tip would have
    /// no concrete snippet to point at and the explanation lands flat.
    private func syncInputTypeTipParameter() {
        let anyTagged = store.cutlings.contains {
            $0.inputTypeTriggers?.isEmpty == false
        }
        InputTypeMatchTip.hasTaggedCutling = anyTagged
    }
    #endif

    private static func localizedWebURL(path: String) -> URL {
        var code = Locale.preferredLanguages.first?.lowercased() ?? "en-us"
        if code.hasPrefix("nb") { code = "no" }
        let prefix = (code == "en-us" || code == "en") ? "" : "/\(code)"
        return URL(string: "\(websiteBaseURL)\(prefix)/\(path)/")!
    }

    var body: some View {
        NavigationStack {
            Form {
                #if os(iOS)
                #if DEBUG
                Section("Keyboard Setup") {
                    HStack {
                        Label("Keyboard Added", systemImage: "keyboard")
                        Spacer()
                        Image(systemName: isKeyboardAdded ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(isKeyboardAdded ? .green : .secondary)
                    }
                    HStack {
                        Label("Full Access", systemImage: "lock.open")
                        Spacer()
                        Image(systemName: hasFullAccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(hasFullAccess ? .green : .secondary)
                    }

                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Open Settings to Enable", systemImage: "arrow.up.forward.square")
                    }

                    Button {
                        showSetupGuide = true
                    } label: {
                        Label("Keyboard Setup Guide", systemImage: "book.pages")
                    }
                    .accessibilityIdentifier("keyboardSetupGuide")
                }
                #else
                if !isKeyboardAdded || !hasFullAccess {
                    Section("Keyboard Setup") {
                        HStack {
                            Label("Keyboard Added", systemImage: "keyboard")
                            Spacer()
                            Image(systemName: isKeyboardAdded ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(isKeyboardAdded ? .green : .secondary)
                        }
                        HStack {
                            Label("Full Access", systemImage: "lock.open")
                            Spacer()
                            Image(systemName: hasFullAccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(hasFullAccess ? .green : .secondary)
                        }

                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Open Settings to Enable", systemImage: "arrow.up.forward.square")
                        }

                        Button {
                            showSetupGuide = true
                        } label: {
                            Label("Keyboard Setup Guide", systemImage: "book.pages")
                        }
                        .accessibilityIdentifier("keyboardSetupGuide")
                    }
                }
                #endif
                #endif

                #if os(iOS)
                TipView(inputTypeMatchTip)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                #endif

                Section {
                    ForEach(InputTypeCategory.allCases) { category in
                        NavigationLink {
                            InputTypeCutlingPicker(category: category)
                                .environmentObject(store)
                        } label: {
                            HStack {
                                Label(category.displayName, systemImage: category.icon)
                                Spacer()
                                let count = store.cutlings.filter { cutling in
                                    guard let triggers = cutling.inputTypeTriggers else { return false }
                                    return !Set(triggers).isDisjoint(with: category.triggerKeys)
                                }.count
                                if count > 0 {
                                    Text("\(count)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Input Type Suggestions")
                } footer: {
                    Text("Assign cutlings to input types so they appear at the top of the keyboard when you focus a matching text field.")
                }

                Section {
                    LabeledContent("Text Cutlings", value: "\(store.textCutlingsCount) / \(CutlingStore.maxTextCutlings)")
                    LabeledContent("Image Cutlings", value: "\(store.imageCutlingsCount) / \(CutlingStore.maxImageCutlings)")
                    LabeledContent("Max Text Length", value: String(localized: "\(CutlingStore.maxTextLength) chars"))
                } header: {
                    Text("Storage")
                }

                #if os(iOS)
                Section {
                    SiriTipView(intent: AddFromClipboardIntent(), isVisible: .constant(true))

                    ShortcutsLink()
                        .shortcutsLinkStyle(.automaticOutline)
                        .frame(maxWidth: .infinity)
                } header: {
                    Text("Siri & Shortcuts")
                } footer: {
                    Text("Use these phrases with Siri or browse all Cutling shortcuts in the Shortcuts app.")
                }
                #endif

                #if MAIN_APP
                #if os(iOS)
                Section {
                    if iCloudSyncEnabled {
                        HStack {
                            Label("iCloud Sync", systemImage: "icloud")
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
                        Button {
                            Task {
                                await store.syncManager?.fetchChanges()
                            }
                        } label: {
                            Label("Sync Now", systemImage: "arrow.clockwise")
                        }
                        .disabled(store.isSyncing)
                    } else {
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Turn On iCloud Sync", systemImage: "icloud")
                        }
                    }
                } header: {
                    Text("iCloud")
                } footer: {
                    Text("Sync your cutlings across all your devices using iCloud.")
                }
                #endif
                #endif

                Section("About") {
                    LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")

                    Link(destination: URL(string: "mailto:kenneth@matsuokengo.com")!) {
                        Label("Contact Support", systemImage: "envelope")
                    }

                    Link(destination: Self.localizedWebURL(path: "privacy")) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Keyboard")
            .accessibilityIdentifier("keyboardView")
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
                syncInputTypeTipParameter()
            }
            .onChange(of: store.cutlings.count) { _, _ in
                syncInputTypeTipParameter()
            }
            .sheet(isPresented: $showSetupGuide) {
                KeyboardSetupView()
            }
            #endif
        }
        #if os(macOS)
        .frame(minWidth: 360, idealWidth: 400, maxWidth: 400, minHeight: 250, idealHeight: 300)
        #endif
    }
}

struct StorageUsageRow: View {
    let title: LocalizedStringKey
    let icon: String
    let used: Int
    let limit: Int

    private var fraction: Double {
        guard limit > 0 else { return 0 }
        return min(1.0, Double(used) / Double(limit))
    }

    private var tint: Color {
        switch fraction {
        case ..<0.75: return .accentColor
        case ..<0.9: return .orange
        default: return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(title, systemImage: icon)
                Spacer()
                Text("\(used) / \(limit)")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            ProgressView(value: fraction)
                .tint(tint)
        }
        .padding(.vertical, 2)
    }

    /// Sum sizes of regular files in the given directory. Returns 0 on error.
    static func diskUsage(in directory: URL) async -> Int64 {
        await Task.detached(priority: .utility) {
            computeDirectorySize(directory)
        }.value
    }

    nonisolated private static func computeDirectorySize(_ directory: URL) -> Int64 {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return 0 }
        var total: Int64 = 0
        for case let url as URL in enumerator {
            guard let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey]),
                  values.isRegularFile == true,
                  let size = values.fileSize else { continue }
            total += Int64(size)
        }
        return total
    }
}

#Preview {
    KeyboardView()
    #if os(macOS)
    .frame(width: 400, height: 500)
    #endif
}

#endif

