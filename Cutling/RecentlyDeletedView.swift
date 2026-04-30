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

struct RecentlyDeletedView: View {
    @EnvironmentObject var store: CutlingStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showEmptyAllConfirmation = false
    @State private var itemToDelete: DeletedCutling?
    @State private var showDeleteConfirmation = false

    private let cardShape = RoundedRectangle(cornerRadius: 24, style: .continuous)

    #if os(iOS)
    let columns = [GridItem(.adaptive(minimum: 160, maximum: 240), spacing: 12)]
    private let cardHeight: CGFloat = 140
    #else
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
                            deletedCard(item)
                                .frame(height: cardHeight)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.85).combined(with: .opacity),
                                    removal: .scale(scale: 0.85).combined(with: .opacity)
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
        #else
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
                    withAccessibleAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                        store.permanentlyDelete(item)
                    }
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
        VStack(spacing: 12) {
            Image(systemName: "trash")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(.tertiary)
            Text("No Recently Deleted Items")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("Deleted cutlings will appear here for 30 days.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
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
        #else
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
        } preview: {
            deletedPreviewContent(item)
        }
        #else
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
            withAccessibleAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                store.restore(item)
            }
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
        #else
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
