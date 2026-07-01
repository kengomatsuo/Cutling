//
//  CardView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import SwiftUI
import LinkPresentation
import UniformTypeIdentifiers

#if os(iOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif

// MARK: - Cross-Platform Image Helpers

#if os(iOS)
func loadPlatformImage(from data: Data) -> UIImage? {
    UIImage(data: data)
}

extension Image {
    init(platformImage: UIImage) {
        self.init(uiImage: platformImage)
    }
}
#endif
#if os(macOS)
func loadPlatformImage(from data: Data) -> NSImage? {
    NSImage(data: data)
}

extension Image {
    init(platformImage: NSImage) {
        self.init(nsImage: platformImage)
    }
}
#endif

// MARK: - Card Shape

let cardShape = RoundedRectangle(
    cornerRadius: .init(24),
    style: .continuous
)

/// How a grid card responds while the interactive tutorial is running.
/// `.normal` is also the everyday (non-tutorial) behaviour.
enum CardTutorialMode {
    case normal        // full interaction
    case disabled      // fully inert
    case ellipsisOnly  // only the ⋯ button works (tap-to-copy and menu off)
}

// MARK: - Card View

struct CardView: View {
    @EnvironmentObject var store: CutlingStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let item: Cutling
    let isSelecting: Bool
    let isSelected: Bool
    let onEdit: () -> Void
    let onToggleSelection: () -> Void
    let onDelete: () -> Void
    /// When true, the ⋯ button publishes its frame as the tutorial's edit/delete
    /// spotlight target (the first card in the grid during the walkthrough).
    var isTutorialAnchor: Bool = false
    /// Locks down interaction while the walkthrough runs; `.normal` otherwise.
    var tutorialMode: CardTutorialMode = .normal

    /// Tap-to-copy, the long-press menu, and dragging are all live only in
    /// `.normal`. In `.ellipsisOnly` just the ⋯ button works; `.disabled`
    /// makes the whole card inert.
    private var cardInteractive: Bool { tutorialMode == .normal }
    private var cardFullyDisabled: Bool { tutorialMode == .disabled }

    @State private var copied = false
    @State private var showInfo = false

    #if os(iOS)
    private static let haptic = UIImpactFeedbackGenerator(style: .light)
    #endif

    var body: some View {
        cardContent
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            #if os(iOS)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            #endif
            #if os(macOS)
            .background(.background.secondary)
            #endif
            .contentShape(cardShape)
            .clipShape(cardShape)
            #if os(iOS)
            .contentShape(.contextMenuPreview, cardShape)
            #endif
            .contentShape(.dragPreview, cardShape)
            .overlay(alignment: .center) {
                copiedOverlay
            }
            .animation(reduceMotion ? .easeOut(duration: 0.15) : .spring(), value: copied)
            .modifier(CardDraggableModifier(item: item, isEnabled: !isSelecting && cardInteractive))
            #if os(iOS)
            .contextMenu {
                cardContextMenu
            } preview: {
                previewContent
            }
            #endif
            #if os(macOS)
            .contextMenu {
                cardContextMenu
            }
            #endif
            .accessibilityIdentifier("cutlingCard")
            .accessibilityElement(children: .combine)
            .accessibilityLabel(item.name)
            .accessibilityValue(item.kind == .text ? item.value : String(localized: "Image"))
            .accessibilityHint(isSelecting ? String(localized: "Double tap to toggle selection") : String(localized: "Double tap to copy, long press for options"))
            .accessibilityAddTraits(isSelecting && isSelected ? .isSelected : [])
            .onTapGesture {
                handleTap()
            }
            .sheet(isPresented: $showInfo) {
                CutlingInfoView(item: item)
                    .environmentObject(store)
            }
            // Tutorial: a `.disabled` card ignores taps, the long-press menu,
            // and the ⋯ button. `.ellipsisOnly` keeps the ⋯ live (handled in
            // handleTap / cardContextMenu) so only that one control responds.
            .disabled(cardFullyDisabled)
            #if os(iOS)
            // Publishes the whole-card frame for the "created" celebration step.
            .modifier(ConditionalFrameReporter(target: .card, active: isTutorialAnchor))
            #endif
    }

    // MARK: - Card Content

    @ViewBuilder
    private var cardContent: some View {
        switch item.kind {
        case .text:
            textCard
        case .image:
            imageCard
        }
    }

    @ViewBuilder
    private var copiedOverlay: some View {
        let content = Label("Copied", systemImage: "checkmark")
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

        if #available(iOS 26.0, macOS 26.0, *) {
            // Per Apple's docs, .glassEffectTransition only animates when the
            // glass effect is inside a GlassEffectContainer. Without the
            // container, the transition falls back to a plain fade.
            GlassEffectContainer(spacing: 0) {
                if copied {
                    content
                        .glassEffect(.regular, in: Capsule())
                        .glassEffectTransition(.materialize)
                }
            }
        } else if copied {
            content
                .background(.thinMaterial)
                .clipShape(Capsule())
                .transition(.scale(scale: 0.85).combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var cardContextMenu: some View {
        // Suppressed during the walkthrough so long-press can't bypass the
        // guided ⋯ → editor flow (an empty menu presents no actions).
        if !isSelecting && cardInteractive {
            ControlGroup {
                Button {
                    markContextMenuDiscovered()
                    copyToClipboard()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }

                Button {
                    markContextMenuDiscovered()
                    shareItem()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }

            Button {
                markContextMenuDiscovered()
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .accessibilityIdentifier("editButton")

            Button {
                markContextMenuDiscovered()
                store.duplicate(item)
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }

            Button {
                markContextMenuDiscovered()
                showInfo = true
            } label: {
                Label("Get Info", systemImage: "info.circle")
            }

            Divider()

            Button(role: .destructive) {
                markContextMenuDiscovered()
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    /// Previously flipped a TipKit parameter to hide the long-press hint after
    /// first use. The interactive tutorial now teaches long-press directly and
    /// that tip was removed, so this is intentionally a no-op (call sites kept
    /// for clarity at each context-menu action).
    private func markContextMenuDiscovered() {}

    private func handleTap() {
        // During the walkthrough, tap-to-copy is off; only the ⋯ button is live.
        guard cardInteractive else { return }
        #if os(iOS)
        if !isSelecting {
            Self.haptic.impactOccurred()
        }
        #endif
        if isSelecting {
            onToggleSelection()
        } else {
            copyToClipboard()
        }
    }

    // MARK: - Text Card

    private var textCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Image(systemName: item.icon)
                    .font(.title2)
                    .foregroundStyle(item.tintColor)
                Spacer()
                topRightButton
            }
            Text(item.name)
                .font(.headline)
                .lineLimit(1)
            Text(item.value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .truncationMode(.tail)
            if let expiresAt = item.expiresAt, expiresAt > Date() {
                Spacer(minLength: 0)
                Label {
                    Text(expiresAt, style: .timer)
                } icon: {
                    Image(systemName: "clock")
                }
                .font(.caption2)
                .foregroundStyle(.orange)
                .accessibilityLabel(String(localized: "Expires \(expiresAt.formatted(date: .abbreviated, time: .shortened))"))
            }
        }
        .padding()
    }

    // MARK: - Image Card

    private var imageCard: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                if let filename = item.imageFilename,
                   let thumbnail = store.loadThumbnail(named: filename) {
                    Image(platformImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    Color.secondary.opacity(0.15)
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        .frame(width: geo.size.width, height: geo.size.height)
                }

                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        topRightButton
                            .shadow(radius: 2)
                    }
                    Spacer()
                    HStack {
                        Text(item.name)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                            .lineLimit(1)
                        if let expiresAt = item.expiresAt, expiresAt > Date() {
                            Spacer()
                            Label {
                                Text(expiresAt, style: .timer)
                            } icon: {
                                Image(systemName: "clock")
                            }
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.85))
                            .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                            .accessibilityLabel(String(localized: "Expires \(expiresAt.formatted(date: .abbreviated, time: .shortened))"))
                        }
                    }
                }
                .padding()
                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                .background(
                    LinearGradient(
                        colors: [.clear, .clear, .black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }

    // MARK: - Preview Content

    #if os(iOS)
    @ViewBuilder
    private var previewContent: some View {
        switch item.kind {
        case .text:
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: item.icon)
                        .font(.title2)
                        .foregroundStyle(item.tintColor)
                    Text(item.name)
                        .font(.headline)
                    Spacer()
                }

                Text(item.value)
                    .font(.body)
                    .lineLimit(18)
            }
            .padding()
            .frame(
                width: min(UIScreen.main.bounds.width - 40, 350),
                alignment: .leading
            )
            .fixedSize(horizontal: false, vertical: true)
            .background(.background)

        case .image:
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: item.icon)
                        .foregroundStyle(item.tintColor)
                    Text(item.name)
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(.background)

                if let filename = item.imageFilename,
                   let data = store.loadImageData(named: filename),
                   let img = loadPlatformImage(from: data) {
                    Image(platformImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(minHeight: 100, maxHeight: 500)
                }
            }
            .frame(width: min(UIScreen.main.bounds.width - 40, 350))
            .background(.background)
        }
    }
    #endif

    // MARK: - Shared

    private var topRightButton: some View {
        Button {
            if isSelecting {
                onToggleSelection()
            } else {
                onEdit()
            }
        } label: {
            ZStack {
                if !isSelecting {
                    Circle()
                        .fill(item.kind == .image ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(.quinary))
                }

                if isSelecting {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(
                            isSelected ? Color.white : (item.kind == .image ? Color.white : Color.primary),
                            isSelected ? Color.accentColor : (item.kind == .image ? Color.white : Color.primary)
                        )
                        .scaleEffect(isSelected ? 1.3 : 1.2)
                        .rotationEffect(.degrees(isSelected ? 0 : -15))
                        .animation(reduceMotion ? .easeOut(duration: 0.15) : .spring(duration: 0.15), value: isSelected)
                } else {
                    Image(systemName: "ellipsis")
                        .font(.subheadline)
                        .foregroundStyle(Color.primary)
                        .scaleEffect(1.3)
                }
            }
            .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
        #if os(iOS)
        .modifier(ConditionalFrameReporter(target: .editEllipsis, active: isTutorialAnchor && !isSelecting))
        #endif
    }

    private func copyToClipboard() {
        switch item.kind {
        case .text:
            #if os(iOS)
            UIPasteboard.general.string = item.value
            #endif
            #if os(macOS)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(item.value, forType: .string)
            #endif

        case .image:
            if let filename = item.imageFilename,
               let data = store.loadImageData(named: filename) {
                #if os(iOS)
                if let uiImage = UIImage(data: data) {
                    UIPasteboard.general.image = uiImage
                }
                #endif
                #if os(macOS)
                if let nsImage = NSImage(data: data) {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.writeObjects([nsImage])
                }
                #endif
            }
        }

        copied = true
        #if os(iOS)
        unsafe UIAccessibility.post(notification: .announcement, argument: String(localized: "Copied"))
        #endif
        #if os(macOS)
        unsafe NSAccessibility.post(element: NSApp as Any, notification: .valueChanged)
        #endif
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            copied = false
        }
    }

    private func shareItem() {
        switch item.kind {
        case .text:
            #if os(iOS)
            let cutling = item
            let trimmed = cutling.value.trimmingCharacters(in: .whitespacesAndNewlines)
            if let url = URL(string: trimmed),
               let scheme = url.scheme,
               ["http", "https", "ftp"].contains(scheme.lowercased()) {
                Task { @MainActor in
                    let metadata = await CutlingActivityItemSource.fetchLinkMetadata(for: url)
                    presentShareSheet(items: [CutlingActivityItemSource(cutling: cutling, linkMetadata: metadata)])
                }
            } else {
                presentShareSheet(items: [CutlingActivityItemSource(cutling: cutling)])
            }
            #endif
            #if os(macOS)
            let trimmed = item.value.trimmingCharacters(in: .whitespacesAndNewlines)
            if let url = URL(string: trimmed),
               let scheme = url.scheme,
               ["http", "https", "ftp"].contains(scheme.lowercased()) {
                presentShareSheet(items: [url])
            } else {
                presentShareSheet(items: [item.value])
            }
            #endif
        case .image:
            guard let filename = item.imageFilename,
                  let data = store.loadImageData(named: filename) else { return }
            #if os(iOS)
            presentShareSheet(items: [CutlingActivityItemSource(cutling: item, imageData: data)])
            #endif
            #if os(macOS)
            guard let image = NSImage(data: data) else { return }
            let previewItem = NSPreviewRepresentingActivityItem(item: image, title: item.name, image: image, icon: nil)
            presentShareSheet(items: [previewItem])
            #endif
        }
    }

    private func presentShareSheet(items: [Any]) {
        #if os(iOS)
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              var topController = window.rootViewController else { return }
        while let presented = topController.presentedViewController {
            topController = presented
        }
        activityVC.popoverPresentationController?.sourceView = topController.view
        activityVC.popoverPresentationController?.sourceRect = CGRect(
            x: topController.view.bounds.midX,
            y: topController.view.bounds.midY,
            width: 0, height: 0
        )
        topController.present(activityVC, animated: true)
        #endif
        #if os(macOS)
        let picker = NSSharingServicePicker(items: items)
        guard let window = NSApp.keyWindow,
              let contentView = window.contentView else { return }
        picker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
        #endif
    }
}

// MARK: - Drag Support

private struct CardDraggableModifier: ViewModifier {
    @EnvironmentObject var store: CutlingStore
    let item: Cutling
    let isEnabled: Bool

    func body(content: Content) -> some View {
        if !isEnabled {
            content
        } else {
            content.draggable(payload())
        }
    }

    private func payload() -> CutlingPayload {
        if item.kind == .image,
           let filename = item.imageFilename,
           let data = store.loadImageData(named: filename) {
            return CutlingPayload(cutling: item, imageData: data)
        }
        return CutlingPayload(cutling: item, imageData: nil)
    }
}

// MARK: - Get Info View

struct CutlingInfoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: CutlingStore

    let item: Cutling

    private var imageFileSize: Int? {
        guard let filename = item.imageFilename,
              let data = store.loadImageData(named: filename) else { return nil }
        return data.count
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    LabeledContent("Name", value: item.name)
                    LabeledContent("Kind", value: item.kind == .text ? String(localized: "Text") : String(localized: "Image"))
                    if item.color != nil {
                        LabeledContent("Color") {
                            HStack {
                                Text(Cutling.localizedColorName(for: item.color))
                                Circle()
                                    .fill(item.tintColor)
                                    .frame(width: 14, height: 14)
                            }
                        }
                    }
                }

                Section("Size") {
                    if item.kind == .text {
                        LabeledContent("Characters", value: "\(item.value.count)")
                        LabeledContent("Words", value: "\(wordCount)")
                        LabeledContent("Lines", value: "\(lineCount)")
                    } else if let size = imageFileSize {
                        LabeledContent("File Size", value: ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))
                    }
                }

                Section("Dates") {
                    LabeledContent("Created", value: item.createdDate.formatted(date: .abbreviated, time: .shortened))
                    LabeledContent("Modified", value: item.lastModifiedDate.formatted(date: .abbreviated, time: .shortened))
                    if let expiresAt = item.expiresAt {
                        LabeledContent("Expires", value: expiresAt.formatted(date: .abbreviated, time: .shortened))
                    }
                }

                if !item.assignedCategories.isEmpty {
                    Section("Input Types") {
                        ForEach(Array(item.assignedCategories).sorted(by: { $0.displayName < $1.displayName })) { category in
                            Label(category.displayName, systemImage: category.icon)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Info")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        #if os(iOS)
                        if #available(iOS 26, *) {
                            Image(systemName: "xmark")
                        } else {
                            Text("Done")
                        }
                        #endif
                        #if os(macOS)
                        Text("Done")
                        #endif
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 360, idealWidth: 400, minHeight: 300, idealHeight: 400)
        #endif
    }

    private var wordCount: Int {
        var count = 0
        item.value.enumerateSubstrings(in: item.value.startIndex..., options: [.byWords, .substringNotRequired]) { _, _, _, _ in
            count += 1
        }
        return count
    }

    private var lineCount: Int {
        item.value.isEmpty ? 0 : item.value.components(separatedBy: .newlines).count
    }
}

// MARK: - Share Activity Item Sources

#if os(iOS)
/// Single activity item source that publishes the full Cutling metadata via the
/// custom `.cutling` UTType (so our own share extension can round-trip name,
/// icon, color, triggers, etc.) while still providing standard plainText/url/png
/// representations for foreign apps. Preserves `LPLinkMetadata` so the share
/// sheet UI shows the cutling's name and (for images/URLs) its preview.
class CutlingActivityItemSource: NSObject, UIActivityItemSource {
    let cutling: Cutling
    let imageData: Data?
    let previewImage: UIImage?
    let resolvedURL: URL?
    /// Optional pre-fetched LP metadata from the caller (used for URL cutlings
    /// so the share sheet shows hero/favicon right away).
    let preFetchedLPMetadata: LPLinkMetadata?

    init(cutling: Cutling, imageData: Data? = nil, linkMetadata: LPLinkMetadata? = nil) {
        self.cutling = cutling
        self.imageData = imageData
        if let imageData {
            self.previewImage = UIImage(data: imageData)
        } else {
            self.previewImage = nil
        }
        let trimmed = cutling.value.trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = URL(string: trimmed),
           let scheme = url.scheme,
           ["http", "https", "ftp"].contains(scheme.lowercased()) {
            self.resolvedURL = url
        } else {
            self.resolvedURL = nil
        }
        self.preFetchedLPMetadata = linkMetadata
        super.init()
    }

    /// Fetches `LPLinkMetadata` for a URL with a short timeout. Returns nil if
    /// the URL is unfetchable or the deadline passes.
    static func fetchLinkMetadata(for url: URL, timeout: TimeInterval = 1.5) async -> LPLinkMetadata? {
        let provider = LPMetadataProvider()
        provider.timeout = timeout
        return try? await provider.startFetchingMetadata(for: url)
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        if let image = previewImage { return image }
        if let url = resolvedURL { return url }
        return cutling.value
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        let provider = NSItemProvider()
        provider.suggestedName = cutling.name

        let payload = CutlingPayload(cutling: cutling, imageData: imageData)
        if let payloadData = try? JSONEncoder().encode(payload) {
            provider.registerDataRepresentation(forTypeIdentifier: UTType.cutling.identifier, visibility: .all) { completion in
                completion(payloadData, nil)
                return nil
            }
        }

        if let imageData, let image = previewImage {
            provider.registerDataRepresentation(forTypeIdentifier: UTType.png.identifier, visibility: .all) { completion in
                completion(image.pngData() ?? imageData, nil)
                return nil
            }
        } else if let resolvedURL {
            provider.registerObject(resolvedURL as NSURL, visibility: .all)
        } else {
            provider.registerObject(cutling.value as NSString, visibility: .all)
        }

        return provider
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        // Prefer the pre-fetched LP metadata, but override the title with the
        // cutling's chosen name so the share sheet shows what the user named it.
        if let preFetched = preFetchedLPMetadata {
            preFetched.title = cutling.name
            return preFetched
        }
        let metadata = LPLinkMetadata()
        metadata.title = cutling.name
        if let previewImage {
            metadata.imageProvider = NSItemProvider(object: previewImage)
        } else if let resolvedURL {
            metadata.originalURL = resolvedURL
            metadata.url = resolvedURL
        }
        return metadata
    }
}
#endif
