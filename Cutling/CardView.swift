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
            .overlay(alignment: .center) {
                copiedOverlay
            }
            .animation(reduceMotion ? .easeOut(duration: 0.15) : .spring(), value: copied)
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
        if copied {
            Label("Copied", systemImage: "checkmark")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.thinMaterial)
                .clipShape(Capsule())
                .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var cardContextMenu: some View {
        if !isSelecting {
            ControlGroup {
                Button {
                    copyToClipboard()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }

                Button {
                    shareItem()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }

            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .accessibilityIdentifier("editButton")

            Button {
                store.duplicate(item)
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }

            Button {
                showInfo = true
            } label: {
                Label("Get Info", systemImage: "info.circle")
            }

            Divider()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func handleTap() {
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
        UIAccessibility.post(notification: .announcement, argument: String(localized: "Copied"))
        #endif
        #if os(macOS)
        NSAccessibility.post(element: NSApp as Any, notification: .valueChanged)
        #endif
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            copied = false
        }
    }

    private func shareItem() {
        switch item.kind {
        case .text:
            presentShareSheet(items: [item.value])
        case .image:
            guard let filename = item.imageFilename,
                  let data = store.loadImageData(named: filename) else { return }
            #if os(iOS)
            guard let image = UIImage(data: data) else { return }
            presentShareSheet(items: [image])
            #endif
            #if os(macOS)
            guard let image = NSImage(data: data) else { return }
            presentShareSheet(items: [image])
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
