//
//  MacPickerView.swift
//  Cutling — menu-bar popover content
//

#if os(macOS)
import SwiftUI
import AppKit

enum MacPickerTab: Hashable {
    case saved
    case history
}

struct MacPickerView: View {
    @EnvironmentObject var store: CutlingStore
    @Environment(\.openSettings) private var openSettings
    @State private var searchText = ""
    @State private var tab: MacPickerTab = .saved
    @State private var isAccessibilityTrusted: Bool = PasteService.shared.isTrusted
    @State private var trustCheckTimer: Timer?
    @FocusState private var searchFieldFocused: Bool
    @AppStorage("captureClipboardHistory") private var captureClipboardHistory = true

    private var filteredSaved: [Cutling] {
        let sorted = store.cutlings.sorted { $0.sortOrder < $1.sortOrder }
        return filter(sorted)
    }

    private var filteredHistory: [Cutling] {
        filter(store.historyCutlings)
    }

    private func filter(_ list: [Cutling]) -> [Cutling] {
        guard !searchText.isEmpty else { return list }
        let q = searchText.lowercased()
        return list.filter {
            $0.name.lowercased().contains(q) || $0.value.lowercased().contains(q)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            tabBar
            Divider()
            content
            if !isAccessibilityTrusted {
                accessibilityBanner
            }
            Divider()
            footer
        }
        .background(.background)
        .background(MenuBarPopoverWindowAccessor())
        .onAppear {
            isAccessibilityTrusted = PasteService.shared.isTrusted
            // Poll while the picker is visible so the banner disappears
            // the moment the user grants access in System Settings.
            trustCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                Task { @MainActor in
                    isAccessibilityTrusted = PasteService.shared.isTrusted
                }
            }
        }
        .onDisappear {
            trustCheckTimer?.invalidate()
            trustCheckTimer = nil
        }
    }

    private var accessibilityBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.system(size: 11))
            Text("Auto-paste needs Accessibility access.")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            Button("Grant…") {
                PasteService.shared.requestTrustIfNeeded()
                PasteService.shared.openAccessibilitySettings()
            }
            .buttonStyle(.plain)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.tint)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(.background.tertiary)
    }

    private var header: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            TextField("Search cutlings", text: $searchText)
                .textFieldStyle(.plain)
                .focused($searchFieldFocused)
                .onAppear { searchFieldFocused = true }
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(.saved, title: "Saved", count: filteredSaved.count)
            tabButton(.history, title: "History", count: filteredHistory.count)
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
    }

    private func tabButton(_ value: MacPickerTab, title: LocalizedStringKey, count: Int) -> some View {
        Button {
            tab = value
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                Text("\(count)")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tab == value ? Color.accentColor.opacity(0.2) : Color.clear)
            .clipShape(Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var content: some View {
        let items = tab == .saved ? filteredSaved : filteredHistory
        if items.isEmpty {
            emptyState
                .frame(height: 160)
        } else {
            // Each row is ~38–42pt with its divider. Size the ScrollView to
            // the content but cap at 420pt so the popover never gets oversized.
            let rowHeight: CGFloat = tab == .history ? 36 : 50
            let listHeight = min(CGFloat(items.count) * rowHeight, 420)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(items) { cutling in
                        MacPickerRow(cutling: cutling, compact: tab == .history) {
                            copy(cutling)
                        } onPromote: {
                            store.promoteHistoryToSaved(cutling.id)
                        } onDelete: {
                            if tab == .history {
                                store.deleteHistory(cutling.id)
                            } else {
                                store.delete(cutling)
                            }
                        }
                        .contextMenu {
                            Button("Copy") { copy(cutling) }
                            if tab == .history {
                                Button("Save as Cutling") {
                                    store.promoteHistoryToSaved(cutling.id)
                                }
                            }
                            Divider()
                            Button(tab == .history ? "Remove from History" : "Delete", role: .destructive) {
                                if tab == .history {
                                    store.deleteHistory(cutling.id)
                                } else {
                                    store.delete(cutling)
                                }
                            }
                        }
                        Divider().padding(.leading, 42)
                    }
                }
            }
            .frame(height: listHeight)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: tab == .saved ? "tray" : "clock")
                .font(.system(size: 36))
                .foregroundStyle(.tertiary)
            Text(emptyMessage)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyMessage: LocalizedStringKey {
        if !searchText.isEmpty { return "No matches" }
        switch tab {
        case .saved:
            return "No saved cutlings yet"
        case .history:
            return captureClipboardHistory
                ? "Copy something to see it here"
                : "Clipboard history is off. Enable it in Settings."
        }
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Button {
                AppActivationManager.shared.dismissMenuBarPopover()
                AppActivationManager.shared.prepareToShowWindow()
                openSettings()
            } label: {
                Image(systemName: "gear")
            }
            .buttonStyle(.plain)
            .help("Settings")

            Button {
                if let url = URL(string: "https://kengomatsuo.github.io/Cutling") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Image(systemName: "questionmark.circle")
            }
            .buttonStyle(.plain)
            .help("Help")

            Spacer()

            if tab == .history && !store.historyCutlings.isEmpty {
                Button {
                    store.clearHistory()
                } label: {
                    Text("Clear History")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
            }

            Button {
                NSApp.terminate(nil)
            } label: {
                Image(systemName: "power")
            }
            .buttonStyle(.plain)
            .help("Quit Cutling")
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.background.secondary)
    }

    private func copy(_ cutling: Cutling) {
        let pb = NSPasteboard.general
        pb.clearContents()
        switch cutling.kind {
        case .text:
            pb.setString(cutling.value, forType: .string)
        case .image:
            if let filename = cutling.imageFilename {
                let path = store.imagesDirectory.appendingPathComponent(filename)
                if let image = NSImage(contentsOf: path) {
                    pb.writeObjects([image])
                }
            }
        }
        NotificationCenter.default.post(
            name: .cutlingDidPickFromPicker,
            object: nil,
            userInfo: ["cutlingID": cutling.id.uuidString]
        )
    }
}

private struct MacPickerRow: View {
    let cutling: Cutling
    /// When true, render a single-line content row (used by the History tab,
    /// where the auto-generated "name" is a redundant prefix of the value).
    var compact: Bool = false
    let onTap: () -> Void
    let onPromote: () -> Void
    let onDelete: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: cutling.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(cutling.tintColor)
                    .frame(width: 22, height: 22)
                if compact {
                    Text(preview)
                        .font(.system(size: 12))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                } else {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(cutling.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Text(preview)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, compact ? 6 : 8)
            .background(hovered ? Color.accentColor.opacity(0.18) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }

    private var preview: String {
        switch cutling.kind {
        case .text:
            let trimmed = cutling.value.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? String(localized: "Empty") : trimmed
        case .image:
            return String(localized: "Image")
        }
    }
}

/// Captures the NSWindow that hosts MacPickerView once it's mounted, and
/// hands it to AppActivationManager so we can dismiss the MenuBarExtra
/// popover programmatically. SwiftUI has no first-party API for this
/// (FB11984872, still open as of Xcode 26).
private struct MenuBarPopoverWindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            AppActivationManager.shared.menuBarPopoverWindow = unsafe view.window
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            AppActivationManager.shared.menuBarPopoverWindow = unsafe nsView.window
        }
    }
}
#endif
