//
//  RecentlyDeletedView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 10/03/26.
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import SwiftUI

#if !os(macOS)

struct RecentlyDeletedView: View {
    @EnvironmentObject var store: CutlingStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showEmptyAllConfirmation = false
    @State private var itemToDelete: DeletedCutling?
    @State private var showDeleteConfirmation = false
    @State private var disappearingIDs: Set<UUID> = []

    private let cardShape = RoundedRectangle(cornerRadius: 24, style: .continuous)

    #if os(iOS)
    let columns = [GridItem(.adaptive(minimum: 160, maximum: 240), spacing: 12)]
    private let cardHeight: CGFloat = 140
    #endif
    #if os(macOS)
    let columns = [GridItem(.adaptive(minimum: 180, maximum: 280), spacing: 14)]
    private let cardHeight: CGFloat = 160
    #endif

    var body: some View {
        ScrollView {
            if store.recentlyDeleted.isEmpty {
                emptyState
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Items will be permanently deleted after 30 days.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(store.recentlyDeleted) { item in
                            let isDisappearing = disappearingIDs.contains(item.id)
                            deletedCard(item)
                                .frame(height: cardHeight)
                                .opacity(isDisappearing ? 0 : 1)
                                .animation(reduceMotion ? .easeOut(duration: 0.15) : .spring(duration: 0.35, bounce: 0.2), value: isDisappearing)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.85).combined(with: .opacity),
                                    removal: .identity
                                ))
                        }
                    }
                    .padding()
                    .animation(reduceMotion ? .easeOut(duration: 0.15) : .spring(duration: 0.35, bounce: 0.2), value: store.recentlyDeleted.map(\.id))
                }
            }
        }
        #if os(iOS)
        .background {
            Color(uiColor: .systemGroupedBackground)
                .padding(-50)
                .ignoresSafeArea()
        }
        #endif
        #if os(macOS)
        .background(.background)
        #endif
        .navigationTitle("Recently Deleted")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Delete All", role: .destructive) {
                    showEmptyAllConfirmation = true
                }
                .foregroundStyle(store.recentlyDeleted.isEmpty ? Color.secondary : Color.red)
                .disabled(store.recentlyDeleted.isEmpty)
                .confirmationDialog(
                    "Delete All Permanently?",
                    isPresented: $showEmptyAllConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete All", role: .destructive) {
                        withAccessibleAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                            store.emptyRecentlyDeleted()
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will permanently delete all \(store.recentlyDeleted.count) items. This action cannot be undone.")
                }
            }
        }
        .alert(
            "Delete Permanently?",
            isPresented: $showDeleteConfirmation,
            presenting: itemToDelete
            ) { item in
                Button("Delete", role: .destructive) {
                    beginDisappear(item) { store.permanentlyDelete($0) }
                    itemToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    itemToDelete = nil
                }
            } message: { item in
                Text("\"\(item.cutling.name)\" will be deleted permanently.")
            }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            "No Recently Deleted Items",
            systemImage: "trash",
            description: Text("Deleted cutlings will appear here for 30 days.")
        )
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: - Deleted Card

    @ViewBuilder
    private func deletedCard(_ item: DeletedCutling) -> some View {
        let cutling = item.cutling

        Group {
            if cutling.kind == .text {
                textDeletedCard(item)
            } else {
                imageDeletedCard(item)
            }
        }
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
        .opacity(0.75)
        #if os(iOS)
        .contextMenu {
            Button {
                beginDisappear(item) { store.restore($0) }
            } label: {
                Label("Recover", systemImage: "arrow.uturn.backward")
            }
            Divider()
            Button(role: .destructive) {
                itemToDelete = item
                showDeleteConfirmation = true
            } label: {
                Label("Delete Permanently", systemImage: "trash")
            }
        } preview: {
            deletedPreviewContent(item)
        }
        #endif
        #if os(macOS)
        .contextMenu {
            Button {
                withAccessibleAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                    store.restore(item)
                }
            } label: {
                Label("Recover", systemImage: "arrow.uturn.backward")
            }
            Divider()
            Button(role: .destructive) {
                itemToDelete = item
                showDeleteConfirmation = true
            } label: {
                Label("Delete Permanently", systemImage: "trash")
            }
        }
        #endif
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(cutling.name), \(item.daysRemaining == 1 ? String(localized: "1 day left") : String(localized: "\(item.daysRemaining) days left"))")
        .accessibilityHint(String(localized: "Double tap to recover"))
        .onTapGesture {
            beginDisappear(item) { store.restore($0) }
        }
    }

    // MARK: - State-driven disappearance

    /// Animate the card out via `disappearingIDs`, then run `action` (which removes
    /// the item from the store) once the animation finishes. Sidesteps the
    /// context-menu / alert dismissal transactions that swallow `withAnimation`.
    private func beginDisappear(_ item: DeletedCutling, perform action: @escaping (DeletedCutling) -> Void) {
        guard !disappearingIDs.contains(item.id) else { return }
        let duration: Double = reduceMotion ? 0.15 : 0.35
        disappearingIDs.insert(item.id)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAccessibleAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                action(item)
            }
            disappearingIDs.remove(item.id)
        }
    }

    // MARK: - Text Deleted Card

    private func textDeletedCard(_ item: DeletedCutling) -> some View {
        let cutling = item.cutling
        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Image(systemName: cutling.icon)
                    .font(.title2)
                    .foregroundStyle(cutling.tintColor)
                Spacer()
                daysLabel(item)
            }
            Text(cutling.name)
                .font(.headline)
                .lineLimit(1)
            Text(cutling.value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .truncationMode(.tail)
        }
        .padding()
    }

    // MARK: - Image Deleted Card

    private func imageDeletedCard(_ item: DeletedCutling) -> some View {
        let cutling = item.cutling
        return GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                if let filename = cutling.imageFilename {
                    thumbnailView(filename: filename, size: geo.size)
                } else {
                    Image(systemName: cutling.icon)
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        .frame(width: geo.size.width, height: geo.size.height)
                }

                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        daysLabel(item)
                            .shadow(radius: 2)
                    }
                    Spacer()
                    Text(cutling.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                        .lineLimit(1)
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

    // MARK: - Context Menu Preview

    #if os(iOS)
    @ViewBuilder
    private func deletedPreviewContent(_ item: DeletedCutling) -> some View {
        let cutling = item.cutling
        switch cutling.kind {
        case .text:
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: cutling.icon)
                        .font(.title2)
                        .foregroundStyle(cutling.tintColor)
                    Text(cutling.name)
                        .font(.headline)
                    Spacer()
                }

                Text(cutling.value)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(width: 300)
            .background(.background)

        case .image:
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: cutling.icon)
                        .foregroundStyle(cutling.tintColor)
                    Text(cutling.name)
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(.background)

                if let filename = cutling.imageFilename,
                   let data = store.loadImageData(named: filename),
                   let img = loadPlatformImage(from: data) {
                    Image(platformImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 500)
                }
            }
            .frame(width: 300)
        }
    }
    #endif

    // MARK: - Helpers

    @ViewBuilder
    private func daysLabel(_ item: DeletedCutling) -> some View {
        let days = item.daysRemaining
        Text(days == 1 ? "1 day left" : "\(days) days left")
            .font(.caption2)
            .foregroundStyle(.secondary)
    }

    @ViewBuilder
    private func thumbnailView(filename: String, size: CGSize) -> some View {
        #if os(iOS)
        if let thumbnail = store.loadThumbnail(named: filename) {
            Image(uiImage: thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipped()
        }
        #endif
        #if os(macOS)
        if let thumbnail = store.loadThumbnail(named: filename) {
            Image(nsImage: thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipped()
        }
        #endif
    }
}

#Preview {
    RecentlyDeletedView()
        .environmentObject(CutlingStore.shared)
}

#endif

