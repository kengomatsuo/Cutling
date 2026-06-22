//
//  MacPickerView.swift
//  Cutling: menu-bar popover content
//

#if os(macOS)
import SwiftUI
import AppKit
import TipKit

enum MacPickerTab: Hashable {
    case saved
    case history
}

struct MacPickerView: View {
    @EnvironmentObject var store: CutlingStore
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow
    /// Which surface is hosting this picker (menu-bar popover vs. floating
    /// hotkey panel). Forwarded to `AppActivationManager.showWindow(source:_:)`
    /// so a save in the add/edit window re-presents the same surface.
    @Environment(\.macWindowSurface) private var surface
    @State private var searchText = ""
    @State private var tab: MacPickerTab = .saved
    @State private var isAccessibilityTrusted: Bool = PasteService.shared.isTrusted
    @State private var trustCheckTimer: Timer?
    @FocusState private var searchFieldFocused: Bool
    @AppStorage("captureClipboardHistory") private var captureClipboardHistory = true

    /// Ordered, single-track tour through every control in the popover.
    /// TipKit's `TipGroup(.ordered)` returns the next eligible tip via
    /// `currentTip` and only advances after the current one invalidates
    /// (the user closes it). ClearHistoryTip is parameter-gated and is
    /// transparently skipped until the user is on the History tab with
    /// at least one row (the Clear button only mounts then).
    private let tipGroup = TipGroup(.ordered) {
        SavedTabTip()
        HistoryTabTip()
        ClearHistoryTip()
        AddButtonTip()
        SettingsButtonTip()
    }

    /// Standalone tip that fires the first time a saved cutling lands in
    /// Recently Deleted. Lives outside the ordered tour because pointing
    /// at an empty list on day-one onboarding made it feel like padding.
    private let recentlyDeletedTip = RecentlyDeletedButtonTip()

    private var filteredSaved: [Cutling] {
        let sorted = store.cutlings.sorted { $0.sortOrder < $1.sortOrder }
        return filter(sorted)
    }

    private var filteredHistory: [Cutling] {
        filter(store.historyCutlings)
    }

    /// True while any tour tip is currently displayed. Row hover popovers
    /// are suppressed during this window because SwiftUI gives a window
    /// only one popover slot and the hover preview was racing the
    /// `.popoverTip` anchored to footer/tab controls.
    private var tourActive: Bool { tipGroup.currentTip != nil }

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
        .onAppear(perform: handleAppear)
        .onDisappear(perform: handleDisappear)
        .onChange(of: tab) { _, newTab in
            syncClearHistoryGate(forTab: newTab)
        }
        .onChange(of: store.historyCutlings.count) { _, _ in
            syncClearHistoryGate(forTab: tab)
        }
        // When the carousel reaches the History tip, programmatically
        // switch to the History tab so the user can actually see what
        // the tip is describing.
        .onChange(of: tipGroup.currentTip is HistoryTabTip) { _, isHistory in
            if isHistory { tab = .history }
        }
    }

    private func handleAppear() {
        isAccessibilityTrusted = PasteService.shared.isTrusted
        // Poll while the picker is visible so the banner disappears
        // the moment the user grants access in System Settings.
        trustCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            Task { @MainActor in
                isAccessibilityTrusted = PasteService.shared.isTrusted
            }
        }
        syncClearHistoryGate(forTab: tab)
    }

    private func handleDisappear() {
        trustCheckTimer?.invalidate()
        trustCheckTimer = nil
    }

    /// Sync the @Parameter gate so the ordered carousel skips Clear
    /// History when the button isn't mounted (i.e. not on history tab,
    /// or history is empty).
    private func syncClearHistoryGate(forTab tab: MacPickerTab) {
        ClearHistoryTip.canShow = tab == .history && !store.historyCutlings.isEmpty
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

    @ViewBuilder
    private func tabButton(_ value: MacPickerTab, title: LocalizedStringKey, count: Int) -> some View {
        let button = Button {
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

        // Each tab gets its own tip anchored to the corresponding pill.
        // The ordered carousel guarantees Saved comes before History.
        if value == .saved, tipGroup.currentTip is SavedTabTip {
            button.popoverTip(tipGroup.currentTip, arrowEdge: .top)
        } else if value == .history, tipGroup.currentTip is HistoryTabTip {
            button.popoverTip(tipGroup.currentTip, arrowEdge: .top)
        } else {
            button
        }
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
                        VStack(spacing: 0) {
                            MacPickerRow(cutling: cutling, compact: tab == .history, tourActive: tourActive) {
                                copy(cutling)
                            } onPromote: {
                                _ = store.promoteHistoryToSaved(cutling.id)
                            } onDelete: {
                                if tab == .history {
                                    store.deleteHistory(cutling.id)
                                } else {
                                    store.delete(cutling)
                                    RecentlyDeletedButtonTip.hasDeletedCutlings = true
                                }
                            }
                            .contextMenu {
                                Button("Copy") { copy(cutling) }
                                if tab == .saved {
                                    Button("Edit\u{2026}") {
                                        AppActivationManager.shared.showWindow(source: surface) {
                                            openWindow(id: "editCutling", value: cutling.id)
                                        }
                                    }
                                    Button("Duplicate") {
                                        store.duplicate(cutling)
                                    }
                                }
                                if tab == .history {
                                    Button("Save as Cutling") {
                                        _ = store.promoteHistoryToSaved(cutling.id)
                                    }
                                }
                                Divider()
                                Button(role: .destructive) {
                                    if tab == .history {
                                        store.deleteHistory(cutling.id)
                                    } else {
                                        store.delete(cutling)
                                        RecentlyDeletedButtonTip.hasDeletedCutlings = true
                                    }
                                } label: {
                                    Text(tab == .history ? "Remove from History" : "Delete")
                                        .foregroundStyle(.red)
                                }
                            }
                            Divider().padding(.leading, 42)
                        }
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
            Menu {
                Button {
                    AppActivationManager.shared.showWindow(source: surface) {
                        openWindow(id: "addText")
                    }
                } label: {
                    Label("New Text Cutling", systemImage: "doc.text")
                }
                Button {
                    AppActivationManager.shared.showWindow(source: surface) {
                        openWindow(id: "addImage")
                    }
                } label: {
                    Label("New Image Cutling", systemImage: "photo")
                }
            } label: {
                Image(systemName: "plus")
            }
            // .buttonStyle(.plain) on the Menu strips the borderless-button
            // chrome's extra horizontal padding so the + matches the other
            // icon buttons in the footer instead of dominating them.
            .menuStyle(.borderlessButton)
            .buttonStyle(.plain)
            .menuIndicator(.hidden)
            .fixedSize()
            .help("New Cutling")
            .popoverTip(tipGroup.currentTip is AddButtonTip ? tipGroup.currentTip : nil, arrowEdge: .bottom)

            Button {
                AppActivationManager.shared.showWindow {
                    openSettings()
                }
            } label: {
                Image(systemName: "gear")
            }
            .buttonStyle(.plain)
            .help("Settings")
            .popoverTip(tipGroup.currentTip is SettingsButtonTip ? tipGroup.currentTip : nil, arrowEdge: .bottom)

            Button {
                NotificationCenter.default.post(name: .cutlingShowRecentlyDeleted, object: nil)
                AppActivationManager.shared.showWindow {
                    openSettings()
                }
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
            .help("Recently Deleted")
            .popoverTip(recentlyDeletedTip, arrowEdge: .bottom)

            Button {
                if let url = URL(string: "https://kengomatsuo.github.io/Cutling") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Image(systemName: "questionmark.circle")
            }
            .buttonStyle(.plain)
            .help("Help")
            
            #if DEBUG
            Text("DEBUG")
            #endif

            Spacer()

            if tab == .history && !store.historyCutlings.isEmpty {
                Button {
                    store.clearHistory()
                } label: {
                    Text("Clear History")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .popoverTip(tipGroup.currentTip is ClearHistoryTip ? tipGroup.currentTip : nil, arrowEdge: .bottom)
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
    @EnvironmentObject private var store: CutlingStore
    let cutling: Cutling
    /// When true, render a single-line content row (used by the History tab,
    /// where the auto-generated "name" is a redundant prefix of the value).
    var compact: Bool = false
    /// When true, the guided tour is showing a tip somewhere in the
    /// popover. Suppress row hover previews for the duration so they
    /// don't fight the `.popoverTip` for the single popover slot.
    var tourActive: Bool = false
    let onTap: () -> Void
    let onPromote: () -> Void
    let onDelete: () -> Void
    @State private var hovered = false
    @State private var showPreview = false
    @State private var previewTask: Task<Void, Never>?

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                leadingIcon
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
        .onHover { handleHover($0) }
        .onChange(of: tourActive) { _, active in
            if active {
                previewTask?.cancel()
                showPreview = false
            }
        }
        .popover(isPresented: $showPreview, arrowEdge: .trailing) {
            if cutling.kind == .image, let filename = cutling.imageFilename {
                ImagePreviewPopover(filename: filename, cutling: cutling, store: store)
            } else if cutling.kind == .text {
                TextPreviewPopover(cutling: cutling)
            }
        }
    }

    /// Long enough or multiline enough that the row's single-line preview
    /// can't show the meaningful bit. We only schedule a hover popover for
    /// these to avoid useless popovers on short snippets like passwords or
    /// short codes that already fit on the row.
    private var textNeedsPopover: Bool {
        let value = cutling.value
        if value.contains("\n") || value.contains("\r") { return true }
        return value.count > 45
    }

    @ViewBuilder
    private var leadingIcon: some View {
        if cutling.kind == .image, let filename = cutling.imageFilename {
            ImageThumbnail(filename: filename, store: store, tint: cutling.tintColor)
                .frame(width: 22, height: 22)
        } else {
            Image(systemName: cutling.icon)
                .font(.system(size: 14))
                .foregroundStyle(cutling.tintColor)
                .frame(width: 22, height: 22)
        }
    }

    private var preview: String {
        switch cutling.kind {
        case .text:
            let trimmed = cutling.value.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? String(localized: "Empty") : trimmed
        case .image:
            // In the History tab the row is single-line, so prefer the
            // source filename / synthesised screenshot name over the
            // relative date that the Saved tab uses as a subtitle.
            return compact ? cutling.name : imagePreview
        }
    }

    private var imagePreview: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: cutling.createdDate, relativeTo: Date())
    }

    private func handleHover(_ hovering: Bool) {
        hovered = hovering
        previewTask?.cancel()
        guard !tourActive else {
            showPreview = false
            return
        }
        let qualifies: Bool
        switch cutling.kind {
        case .image:
            qualifies = cutling.imageFilename != nil
        case .text:
            qualifies = textNeedsPopover
        }
        guard qualifies else {
            showPreview = false
            return
        }
        if hovering {
            previewTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(450))
                guard !Task.isCancelled else { return }
                showPreview = true
            }
        } else {
            showPreview = false
        }
    }
}

/// Popover shown after a brief hover delay over an image row. Loads a
/// preview-sized version (max 640px on the long edge) via ImageIO so we
/// don't slurp a full 4K screenshot into RAM, and reads pixel dimensions
/// from the file's metadata without decoding the bitmap.
private struct ImagePreviewPopover: View {
    let filename: String
    let cutling: Cutling
    let store: CutlingStore
    @State private var image: NSImage?
    @State private var pixelSize: CGSize?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                if let image {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 320, maxHeight: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    ProgressView()
                        .frame(width: 200, height: 140)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                if let size = pixelSize {
                    Text("\(Int(size.width)) × \(Int(size.height)) px")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                Text(cutling.createdDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .frame(minWidth: 220, idealWidth: 320, maxWidth: 360)
        .task(id: filename) {
            let url = store.imagesDirectory.appendingPathComponent(filename)
            let result = await Task.detached { () -> (NSImage?, CGSize?) in
                let preview = Self.loadPreview(url: url, maxDimension: 640)
                let size = Self.pixelDimensions(url: url)
                return (preview, size)
            }.value
            image = result.0
            pixelSize = result.1
        }
    }

    nonisolated static func loadPreview(url: URL, maxDimension: CGFloat) -> NSImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension * 2,
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    }

    nonisolated static func pixelDimensions(url: URL) -> CGSize? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = props[kCGImagePropertyPixelWidth] as? Int,
              let height = props[kCGImagePropertyPixelHeight] as? Int
        else { return nil }
        return CGSize(width: width, height: height)
    }
}

/// Hover popover for text cutlings that don't fit in the single-line row.
/// Shows the full content in a scrollable area with a char count and date.
private struct TextPreviewPopover: View {
    let cutling: Cutling

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView {
                Text(cutling.value)
                    .font(.system(size: 12, design: codeLooking ? .monospaced : .default))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 2)
            }
            .frame(maxHeight: 280)

            HStack {
                Text("\(cutling.value.count) chars")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Spacer()
                Text(cutling.createdDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .frame(minWidth: 280, idealWidth: 360, maxWidth: 420)
    }

    /// Heuristic to render with a monospaced font when the content looks
    /// like source code or structured data. Keeps prose readable in the
    /// default font and code legible in mono.
    private var codeLooking: Bool {
        let v = cutling.value
        return v.contains("{") || v.contains(";") || v.contains("=>") ||
               v.range(of: #"^\s*\w+\s*=\s*"#, options: .regularExpression) != nil
    }
}

/// Loads the on-disk image thumbnail via CutlingStore (which caches and
/// downsamples). Falls back to the SF Symbol if the file is missing.
private struct ImageThumbnail: View {
    let filename: String
    let store: CutlingStore
    let tint: Color
    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 14))
                    .foregroundStyle(tint)
            }
        }
        .task(id: filename) {
            image = store.loadThumbnail(named: filename)
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
            register(unsafe view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            register(unsafe nsView.window)
        }
    }

    private func register(_ window: NSWindow?) {
        // The picker view is also hosted inside CutlingPickerPanel (the
        // hotkey-summoned floating panel). Don't let that overwrite the
        // menu bar popover reference, otherwise the gear button would
        // try to dismiss the wrong window.
        guard let window, !(window is CutlingPickerPanel) else { return }
        AppActivationManager.shared.menuBarPopoverWindow = window
    }
}
#endif
