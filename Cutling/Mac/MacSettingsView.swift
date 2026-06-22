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
    case recentlyDeleted
}

extension Notification.Name {
    /// Posted by the picker footer to make Settings open directly to the
    /// Recently Deleted tab.
    static let cutlingShowRecentlyDeleted = Notification.Name("com.matsuokengo.Cutling.showRecentlyDeleted")
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

            RecentlyDeletedTab()
                .tabItem { Label("Recently Deleted", systemImage: "trash") }
                .tag(MacSettingsTab.recentlyDeleted)
        }
        .frame(width: 520, height: 440)
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
        .onReceive(NotificationCenter.default.publisher(for: .cutlingShowRecentlyDeleted)) { _ in
            tab = .recentlyDeleted
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
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon = true
    @Environment(\.openWindow) private var openWindow
    @State private var launchAtLogin = LaunchAtLoginService.shared.isEnabled

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $launchAtLogin) {
                    Label("Launch Cutling at login", systemImage: "power")
                }
                .onChange(of: launchAtLogin) { _, newValue in
                    _ = LaunchAtLoginService.shared.setEnabled(newValue)
                    // Read back the live state in case the system denied
                    // the change (e.g. user blocked login items in System
                    // Settings) so the toggle stays in sync with reality.
                    launchAtLogin = LaunchAtLoginService.shared.isEnabled
                }
                Button("Open Login Items in System Settings\u{2026}") {
                    LaunchAtLoginService.shared.openLoginItemsSettings()
                }
            } header: {
                Text("Startup")
            } footer: {
                Text("Cutling starts automatically when you log in to your Mac. macOS may ask for approval on first registration.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Toggle(isOn: $showMenuBarIcon) {
                    Label("Show menu bar icon", systemImage: "menubar.rectangle")
                }
            } header: {
                Text("Menu Bar")
            } footer: {
                Text("Hide the menu bar icon if you prefer summoning Cutling only with the global hotkey. The app stays running in the background and the hotkey keeps working.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

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
                    AppActivationManager.shared.showWindow {
                        openWindow(id: WelcomeWindow.id)
                    }
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

private struct DiskUsageBreakdown: Sendable {
    var saved: Int64 = 0
    var history: Int64 = 0
    var deleted: Int64 = 0
    var orphaned: Int64 = 0
    var total: Int64 { saved + history + deleted + orphaned }
    nonisolated init() {}
}

private struct StorageSettingsTab: View {
    @EnvironmentObject private var store: CutlingStore
    @State private var usage = DiskUsageBreakdown()

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
                    Task { await refresh() }
                }
                .disabled(store.historyCutlings.isEmpty)
            }

            Section {
                LabeledContent("Saved cutlings") {
                    Text(format(usage.saved))
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Clipboard history") {
                    Text(format(usage.history))
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Recently deleted") {
                    Text(format(usage.deleted))
                        .foregroundStyle(.secondary)
                }
                if usage.orphaned > 0 {
                    LabeledContent("Orphaned files") {
                        Text(format(usage.orphaned))
                            .foregroundStyle(.orange)
                    }
                    Button("Clean Up Orphaned Files") {
                        Task {
                            await cleanOrphans()
                            await refresh()
                        }
                    }
                }
                LabeledContent("Total") {
                    Text(format(usage.total))
                        .foregroundStyle(.primary)
                        .fontWeight(.semibold)
                }
            } header: {
                Text("Image Storage on Disk")
            } footer: {
                Text("Image files captured from the clipboard and saved cutlings live in this app's container. Recently deleted images are kept until permanent removal or until you empty Recently Deleted.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
        .task { await refresh() }
    }

    private func format(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }

    private func refresh() async {
        let savedIDs = Set(store.cutlings.compactMap { $0.kind == .image ? $0.id : nil })
        let historyIDs = Set(store.historyCutlings.compactMap { $0.kind == .image ? $0.id : nil })
        let deletedIDs = Set(store.recentlyDeleted.compactMap { $0.cutling.kind == .image ? $0.cutling.id : nil })
        usage = await Self.measure(directory: store.imagesDirectory, savedIDs: savedIDs, historyIDs: historyIDs, deletedIDs: deletedIDs)
    }

    private func cleanOrphans() async {
        let savedIDs = Set(store.cutlings.compactMap { $0.kind == .image ? $0.id : nil })
        let historyIDs = Set(store.historyCutlings.compactMap { $0.kind == .image ? $0.id : nil })
        let deletedIDs = Set(store.recentlyDeleted.compactMap { $0.cutling.kind == .image ? $0.cutling.id : nil })
        let dir = store.imagesDirectory
        await Task.detached {
            let fm = FileManager.default
            guard let enumerator = fm.enumerator(at: dir,
                                                includingPropertiesForKeys: nil,
                                                options: [.skipsHiddenFiles]) else { return }
            while let obj = enumerator.nextObject() {
                guard let url = obj as? URL else { continue }
                let stem = url.deletingPathExtension().lastPathComponent
                guard let uuid = UUID(uuidString: stem) else {
                    try? fm.removeItem(at: url)
                    continue
                }
                if !savedIDs.contains(uuid) && !historyIDs.contains(uuid) && !deletedIDs.contains(uuid) {
                    try? fm.removeItem(at: url)
                }
            }
        }.value
    }

    nonisolated private static func measure(
        directory: URL,
        savedIDs: Set<UUID>,
        historyIDs: Set<UUID>,
        deletedIDs: Set<UUID>
    ) async -> DiskUsageBreakdown {
        await Task.detached {
            let fm = FileManager.default
            guard let enumerator = fm.enumerator(at: directory,
                                                includingPropertiesForKeys: [.fileSizeKey],
                                                options: [.skipsHiddenFiles]) else { return DiskUsageBreakdown() }
            var result = DiskUsageBreakdown()
            while let obj = enumerator.nextObject() {
                guard let url = obj as? URL else { continue }
                let size = Int64((try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0)
                let stem = url.deletingPathExtension().lastPathComponent
                guard let uuid = UUID(uuidString: stem) else {
                    result.orphaned += size
                    continue
                }
                if savedIDs.contains(uuid) {
                    result.saved += size
                } else if historyIDs.contains(uuid) {
                    result.history += size
                } else if deletedIDs.contains(uuid) {
                    result.deleted += size
                } else {
                    result.orphaned += size
                }
            }
            return result
        }.value
    }
}

private struct RecentlyDeletedTab: View {
    @EnvironmentObject private var store: CutlingStore
    @State private var confirmEmptyAll = false
    @State private var itemToHardDelete: DeletedCutling?

    var body: some View {
        Form {
            if store.recentlyDeleted.isEmpty {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "trash")
                                .font(.system(size: 40, weight: .light))
                                .foregroundStyle(.tertiary)
                            Text("No recently deleted cutlings")
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 24)
                }
            } else {
                Section {
                    ForEach(store.recentlyDeleted) { deleted in
                        DeletedCutlingRow(
                            deleted: deleted,
                            onRestore: { store.restore(deleted) },
                            onDelete: { itemToHardDelete = deleted }
                        )
                    }
                } header: {
                    HStack {
                        Text("Deleted cutlings")
                        Spacer()
                        Text("\(store.recentlyDeleted.count)")
                            .foregroundStyle(.secondary)
                    }
                } footer: {
                    Text("Cutlings stay here for 30 days before permanent removal. iCloud syncs deletions across devices.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button(role: .destructive) {
                        confirmEmptyAll = true
                    } label: {
                        Text("Empty All")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .confirmationDialog(
            "Permanently delete all recently deleted cutlings?",
            isPresented: $confirmEmptyAll,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                store.emptyRecentlyDeleted()
            } label: {
                Text("Empty All")
                    .foregroundStyle(.red)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
        .confirmationDialog(
            "Delete this cutling forever?",
            isPresented: Binding(
                get: { itemToHardDelete != nil },
                set: { if !$0 { itemToHardDelete = nil } }
            ),
            titleVisibility: .visible,
            presenting: itemToHardDelete
        ) { item in
            Button(role: .destructive) {
                store.permanentlyDelete(item)
                itemToHardDelete = nil
            } label: {
                Text("Delete Forever")
                    .foregroundStyle(.red)
            }
            Button("Cancel", role: .cancel) {
                itemToHardDelete = nil
            }
        } message: { item in
            Text("\(item.cutling.name) will be permanently removed.")
        }
    }
}

private struct DeletedCutlingRow: View {
    let deleted: DeletedCutling
    let onRestore: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: deleted.cutling.icon)
                .font(.system(size: 14))
                .foregroundStyle(deleted.cutling.tintColor)
                .frame(width: 22, height: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(deleted.cutling.name)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(preview)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Text("\(deleted.daysRemaining)d left")
                        .font(.system(size: 11))
                        .foregroundStyle(deleted.daysRemaining <= 3 ? AnyShapeStyle(.orange) : AnyShapeStyle(.tertiary))
                }
            }

            Spacer(minLength: 8)

            Button("Restore", action: onRestore)
                .controlSize(.small)
            Button(role: .destructive, action: onDelete) {
                Text("Delete")
                    .foregroundStyle(.red)
            }
            .controlSize(.small)
        }
        .padding(.vertical, 2)
    }

    private var preview: String {
        switch deleted.cutling.kind {
        case .text:
            let trimmed = deleted.cutling.value.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? String(localized: "Empty") : trimmed
        case .image:
            return String(localized: "Image")
        }
    }
}
#endif
