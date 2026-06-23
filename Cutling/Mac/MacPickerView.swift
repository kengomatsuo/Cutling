//
//  MacPickerView.swift
//  Cutling: menu-bar popover content
//

#if os(macOS)
import SwiftUI
import AppKit
import TipKit
import UniformTypeIdentifiers

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
    /// Content-area height captured the first time the picker appears.
    /// Used as the fixed height while searching, so the host NSWindow
    /// doesn't resize per keystroke as the match counts change.
    @State private var stableContentHeight: CGFloat?
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

    /// When the search field has text, the picker switches to a unified
    /// "find anywhere" layout: tabs are hidden and matches from both
    /// Saved and History are shown together in two labelled sections.
    private var searchActive: Bool { !searchText.isEmpty }

    /// Rendered height of `tabBar`: text(12) + vertical padding 4*2 = 22pt
    /// for the pill, plus the HStack's `.padding(.bottom, 4)` = 26pt total.
    /// Used to donate that space to the content area while searching so
    /// the popover doesn't visibly change size.
    private let tabBarHeight: CGFloat = 26

    var body: some View {
        VStack(spacing: 0) {
            header
            if !searchActive {
                tabBar
            }
            Divider()
            // During search the tab bar is gone; donate its vertical space
            // to the content so the total popover height stays constant
            // (no NSWindow resize when search activates or deactivates).
            content
                .frame(height: (stableContentHeight ?? 420) + (searchActive ? tabBarHeight : 0))
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
        if stableContentHeight == nil {
            stableContentHeight = initialContentHeight()
        }
    }

    /// Height the content area takes on first appear, matching the
    /// `singleSectionContent` formula on the default Saved tab. We freeze
    /// this and reuse it for the search results so the popover keeps a
    /// constant height instead of resizing per keystroke.
    private func initialContentHeight() -> CGFloat {
        let items = filteredSaved
        if items.isEmpty { return 160 }
        return min(CGFloat(items.count) * 50, 420)
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
                .onAppear {
                    // Defer to the next runloop tick so the host NSWindow
                    // (menu-bar popover or floating panel) is key by the
                    // time we assign @FocusState. Otherwise focus is
                    // dropped on the floor for the panel surface.
                    DispatchQueue.main.async {
                        searchFieldFocused = true
                    }
                }
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
            tabButton(.history, title: "History", count: nil)
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func tabButton(_ value: MacPickerTab, title: LocalizedStringKey, count: Int?) -> some View {
        let button = Button {
            tab = value
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                if let count {
                    Text("\(count)")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
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
        if searchActive {
            searchResultsContent
        } else {
            singleSectionContent
        }
    }

    @ViewBuilder
    private var singleSectionContent: some View {
        let items = tab == .saved ? filteredSaved : filteredHistory
        if items.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(items) { cutling in
                        cutlingRow(cutling, isHistory: tab == .history)
                    }
                }
            }
        }
    }

    /// "Find anywhere" layout used while the search field has text. Shows
    /// matching Saved and History rows together with section headers, so
    /// the user doesn't have to think about which tab their hit lives on.
    @ViewBuilder
    private var searchResultsContent: some View {
        let saved = filteredSaved
        let history = filteredHistory
        if saved.isEmpty && history.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    if !saved.isEmpty {
                        Section(header: sectionHeader("Saved", count: saved.count)) {
                            ForEach(saved) { cutling in
                                cutlingRow(cutling, isHistory: false)
                            }
                        }
                    }
                    if !history.isEmpty {
                        Section(header: sectionHeader("History", count: history.count)) {
                            ForEach(history) { cutling in
                                cutlingRow(cutling, isHistory: true)
                            }
                        }
                    }
                }
            }
        }
    }

    private func sectionHeader(_ title: LocalizedStringKey, count: Int) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("\(count)")
                .font(.system(size: 11).monospacedDigit())
                .foregroundStyle(.tertiary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary)
    }

    @ViewBuilder
    private func cutlingRow(_ cutling: Cutling, isHistory: Bool) -> some View {
        VStack(spacing: 0) {
            MacPickerRow(cutling: cutling, compact: isHistory, tourActive: tourActive) {
                copy(cutling)
            } onPromote: {
                _ = store.promoteHistoryToSaved(cutling.id)
            } onDelete: {
                if isHistory {
                    store.deleteHistory(cutling.id)
                } else {
                    store.delete(cutling)
                    RecentlyDeletedButtonTip.hasDeletedCutlings = true
                }
            } onSaveImageToDisk: {
                saveImageToDisk(cutling)
            }
            .contextMenu {
                Button("Copy") { copy(cutling) }
                if cutling.kind == .image {
                    Button("Save as File\u{2026}") {
                        saveImageToDisk(cutling)
                    }
                }
                if !isHistory {
                    Button("Edit\u{2026}") {
                        AppActivationManager.shared.showWindow(source: surface) {
                            openWindow(id: "editCutling", value: cutling.id)
                        }
                    }
                    Button("Duplicate") {
                        store.duplicate(cutling)
                    }
                }
                if isHistory {
                    Button("Save as Cutling") {
                        _ = store.promoteHistoryToSaved(cutling.id)
                    }
                }
                Divider()
                Button(role: .destructive) {
                    if isHistory {
                        store.deleteHistory(cutling.id)
                    } else {
                        store.delete(cutling)
                        RecentlyDeletedButtonTip.hasDeletedCutlings = true
                    }
                } label: {
                    Text(isHistory ? "Remove from History" : "Delete")
                        .foregroundStyle(.red)
                }
            }
            Divider().padding(.leading, 42)
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        Group {
            if searchActive {
                ContentUnavailableView.search(text: searchText)
            } else {
                switch tab {
                case .saved:
                    ContentUnavailableView(
                        "No saved cutlings yet",
                        systemImage: "tray"
                    )
                case .history:
                    ContentUnavailableView(
                        captureClipboardHistory
                            ? "Copy something to see it here"
                            : "Clipboard history is off. Enable it in Settings.",
                        systemImage: "clock"
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        // Tell the monitor we caused this changeCount bump so it does not
        // echo the just-picked item back into history.
        CutlingAppDelegate.pasteboardMonitor?.acknowledgeCurrentPasteboardChange()
        NotificationCenter.default.post(
            name: .cutlingDidPickFromPicker,
            object: nil,
            userInfo: ["cutlingID": cutling.id.uuidString]
        )
    }

    fileprivate func saveImageToDisk(_ cutling: Cutling) {
        guard cutling.kind == .image,
              let filename = cutling.imageFilename,
              let data = store.loadImageData(named: filename)
        else { return }
        let suggested = cutling.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = suggested.isEmpty ? "Cutling" : suggested
        // Defer to the next runloop tick so the context menu (or popover
        // button) finishes dismissing before the save logic runs and
        // potentially presents a modal panel.
        DispatchQueue.main.async {
            _ = ImageSaveService.shared.save(data: data, suggestedName: base)
        }
    }
}

private struct MacPickerRow: View {
    @EnvironmentObject private var store: CutlingStore
    let cutling: Cutling
    /// When true, render a single-line content row (used by the History tab,
    /// where the auto-generated "name" is a redundant prefix of the value).
    var compact: Bool = false
    /// When true, the guided tour is showing a tip somewhere in the
    /// popover. Suppress row preview controls for the duration so they
    /// don't fight the `.popoverTip` for the single popover slot.
    var tourActive: Bool = false
    let onTap: () -> Void
    let onPromote: () -> Void
    let onDelete: () -> Void
    let onSaveImageToDisk: () -> Void
    @State private var hovered = false
    @State private var showPreview = false

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
                // Reserve trailing space so the row text never slides under
                // the edge button when it appears on hover.
                if previewQualifies {
                    Color.clear.frame(width: 22, height: 22)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, compact ? 6 : 8)
            .background(hovered ? Color.accentColor.opacity(0.18) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .trailing) { previewButton }
        .onHover { hovered = $0 }
        .onChange(of: tourActive) { _, active in
            if active { showPreview = false }
        }
    }

    /// Trailing toggle for the preview popover. Anchors the popover so the
    /// preview never overlaps the row itself (the previous hover popover
    /// blocked click-throughs back to the row).
    @ViewBuilder
    private var previewButton: some View {
        if previewQualifies, !tourActive, hovered || showPreview {
            Button {
                showPreview.toggle()
            } label: {
                Image(systemName: "eye")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.trailing, 8)
            .help("Preview")
            .popover(isPresented: $showPreview, arrowEdge: .trailing) {
                if cutling.kind == .image, let filename = cutling.imageFilename {
                    ImagePreviewPopover(
                        filename: filename,
                        cutling: cutling,
                        store: store,
                        onSaveToDisk: onSaveImageToDisk
                    )
                } else if cutling.kind == .text {
                    TextPreviewPopover(cutling: cutling)
                }
            }
        }
    }

    /// True when the row has more content than the single-line preview can
    /// show, so the edge button is worth surfacing. Images always qualify
    /// (the preview shows pixels and dimensions); text only qualifies when
    /// it's multiline or longer than the row can render.
    private var previewQualifies: Bool {
        switch cutling.kind {
        case .image:
            return cutling.imageFilename != nil
        case .text:
            let value = cutling.value
            if value.contains("\n") || value.contains("\r") { return true }
            return value.count > 45
        }
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
}

/// Popover shown after a brief hover delay over an image row. Loads a
/// preview-sized version (max 640px on the long edge) via ImageIO so we
/// don't slurp a full 4K screenshot into RAM, and reads pixel dimensions
/// from the file's metadata without decoding the bitmap.
private struct ImagePreviewPopover: View {
    let filename: String
    let cutling: Cutling
    let store: CutlingStore
    let onSaveToDisk: () -> Void
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
            HStack(alignment: .bottom) {
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
                Spacer(minLength: 8)
                Button {
                    onSaveToDisk()
                } label: {
                    Label("Save as File\u{2026}", systemImage: "square.and.arrow.down")
                        .labelStyle(.titleAndIcon)
                        .font(.system(size: 11))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
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
