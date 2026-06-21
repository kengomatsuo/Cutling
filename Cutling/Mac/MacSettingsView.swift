//
//  MacSettingsView.swift
//  Cutling: macOS Settings (Cmd+,) window.
//

#if os(macOS)
import SwiftUI
import AppKit
import TipKit

enum MacSettingsTab: Hashable {
    case general
    case hotkey
    case paste
    case sync
    case storage
}

struct MacSettingsView: View {
    @State private var tab: MacSettingsTab = .general
    @State private var isTrusted: Bool = PasteService.shared.isTrusted
    @State private var trustTimer: Timer?

    var body: some View {
        TabView(selection: $tab) {
            GeneralSettingsTab()
                .tabItem { Label("General", systemImage: "gear") }
                .tag(MacSettingsTab.general)

            HotkeySettingsTab()
                .tabItem { Label("Hotkey", systemImage: "command") }
                .tag(MacSettingsTab.hotkey)

            PasteSettingsTab()
                .tabItem { Label("Paste", systemImage: "doc.on.clipboard") }
                .tag(MacSettingsTab.paste)
                .badge(isTrusted ? nil : Text("!"))

            SyncSettingsTab()
                .tabItem { Label("iCloud", systemImage: "icloud") }
                .tag(MacSettingsTab.sync)

            StorageSettingsTab()
                .tabItem { Label("Storage", systemImage: "internaldrive") }
                .tag(MacSettingsTab.storage)
        }
        .frame(width: 480, height: 400)
        .onAppear {
            isTrusted = PasteService.shared.isTrusted
            trustTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                Task { @MainActor in isTrusted = PasteService.shared.isTrusted }
            }
        }
        .onDisappear {
            trustTimer?.invalidate()
            trustTimer = nil
        }
    }
}

private struct PasteSettingsTab: View {
    @State private var isTrusted: Bool = PasteService.shared.isTrusted
    @State private var checkTimer: Timer?

    private var isDebugBuild: Bool {
        Bundle.main.bundlePath.contains("DerivedData")
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Label("Accessibility access", systemImage: isTrusted ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                        .foregroundStyle(isTrusted ? .green : .orange)
                    Spacer()
                    Text(isTrusted ? "Granted" : "Not granted")
                        .foregroundStyle(.secondary)
                }
                if !isTrusted {
                    Button("Grant Access…") {
                        PasteService.shared.requestTrustIfNeeded()
                        // System prompt may already have been used; offer the
                        // System Settings deep link as well.
                        PasteService.shared.openAccessibilitySettings()
                    }
                }
                Button("Show Cutling.app in Finder") {
                    let url = URL(fileURLWithPath: Bundle.main.bundlePath)
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                }
            } header: {
                Text("Auto-Paste")
            } footer: {
                VStack(alignment: .leading, spacing: 6) {
                    Text("With Accessibility access, picking a cutling from the hotkey-summoned picker will paste it directly into the app that was frontmost. Without it, Cutling will copy to the clipboard so you can paste manually.")
                    if isDebugBuild {
                        Text("Debug build detected. macOS treats each rebuild as a different app, so Accessibility access has to be granted to *this* .app bundle. Click \u{201C}Show Cutling.app in Finder\u{201D}, then drag it into System Settings → Privacy & Security → Accessibility and tick the box. For a permanent setup, run the Release build (⌘R → Product › Scheme › Edit Scheme → Run → Release).")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            isTrusted = PasteService.shared.isTrusted
            // Poll while the pane is visible so the row reflects changes the
            // user makes in System Settings without needing a relaunch.
            checkTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                Task { @MainActor in isTrusted = PasteService.shared.isTrusted }
            }
        }
        .onDisappear {
            checkTimer?.invalidate()
            checkTimer = nil
        }
    }
}

private struct GeneralSettingsTab: View {
    @AppStorage("captureClipboardHistory") private var captureClipboardHistory = true
    @AppStorage("autoDetectInputTypes") private var autoDetectInputTypes = true
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $captureClipboardHistory) {
                    Label("Capture clipboard history", systemImage: "doc.on.clipboard")
                }
            } footer: {
                Text("Automatically save everything you copy to the History tab. Items flagged as concealed by password managers are ignored.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Toggle(isOn: $autoDetectInputTypes) {
                    Label("Auto-detect input types", systemImage: "wand.and.stars")
                }
            } footer: {
                Text("Suggest input type categories (email, URL, phone, name, address) when editing text cutlings.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button("Show Welcome Again") {
                    AppActivationManager.shared.prepareToShowWindow()
                    openWindow(id: WelcomeWindow.id)
                }
                Button("Reset Tips") {
                    try? Tips.resetDatastore()
                    try? Tips.configure()
                }
            } header: {
                Text("Help & Tips")
            } footer: {
                Text("Reopen the first-launch welcome flow, or reset TipKit so contextual hints appear again as you use Cutling.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

private struct HotkeySettingsTab: View {
    var body: some View {
        Form {
            Section {
                LabeledContent("Show picker") {
                    HotkeyRecorderView()
                }
            } header: {
                Text("Global Shortcut")
            } footer: {
                Text("Summon the clipboard picker from anywhere with this keyboard shortcut. If it doesn't fire, check System Settings → Keyboard → Keyboard Shortcuts for a collision.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

private struct SyncSettingsTab: View {
    @EnvironmentObject private var store: CutlingStore
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $iCloudSyncEnabled) {
                    Label("iCloud Sync", systemImage: "icloud")
                }
                .onChange(of: iCloudSyncEnabled) { _, enabled in
                    UserDefaults(suiteName: appGroupID)?.set(enabled, forKey: "iCloudSyncEnabled")
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
            } footer: {
                Text("Saved cutlings sync across your devices. Clipboard history stays on this Mac.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

private struct StorageSettingsTab: View {
    @EnvironmentObject private var store: CutlingStore
    @State private var diskUsageBytes: Int64 = 0

    var body: some View {
        Form {
            Section("Saved Cutlings") {
                LabeledContent("Text") {
                    Text("\(store.textCutlingsCount) / \(CutlingStore.maxTextCutlings)")
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Images") {
                    Text("\(store.imageCutlingsCount) / \(CutlingStore.maxImageCutlings)")
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Total") {
                    Text("\(store.cutlings.count) / \(CutlingStore.maxTotalCutlings)")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Clipboard History") {
                LabeledContent("Entries") {
                    Text("\(store.historyCutlings.count) / \(CutlingStore.maxHistoryCutlings)")
                        .foregroundStyle(.secondary)
                }
                Button("Clear History", role: .destructive) {
                    store.clearHistory()
                }
                .disabled(store.historyCutlings.isEmpty)
            }

            Section("Disk") {
                LabeledContent("Image Storage") {
                    Text(ByteCountFormatter.string(fromByteCount: diskUsageBytes, countStyle: .file))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .task {
            diskUsageBytes = await diskUsage(in: store.imagesDirectory)
        }
    }

    private func diskUsage(in directory: URL) async -> Int64 {
        await Task.detached {
            let fm = FileManager.default
            guard let enumerator = fm.enumerator(at: directory,
                                                includingPropertiesForKeys: [.fileSizeKey],
                                                options: [.skipsHiddenFiles]) else { return Int64(0) }
            var total: Int64 = 0
            // `for case let ... in enumerator` would call makeIterator(),
            // which is unavailable in async contexts under Swift 6. Use
            // nextObject() in a while loop instead.
            while let obj = enumerator.nextObject() {
                guard let url = obj as? URL else { continue }
                let values = try? url.resourceValues(forKeys: [.fileSizeKey])
                total += Int64(values?.fileSize ?? 0)
            }
            return total
        }.value
    }
}
#endif
