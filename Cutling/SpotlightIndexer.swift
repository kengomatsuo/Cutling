//
//  SpotlightIndexer.swift
//  Cutling
//
//  Bridges CutlingStore mutations to CoreSpotlight so each cutling appears
//  in iOS / macOS Spotlight system search.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#if MAIN_APP

import AppIntents
import CoreSpotlight
import Foundation
import UniformTypeIdentifiers
#if os(iOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif

@MainActor
final class SpotlightIndexer {
    static let shared = SpotlightIndexer()

    static let domain = "com.matsuokengo.Cutling.cutlings"
    static let editActionID = "com.matsuokengo.Cutling.edit"

    private let index = CSSearchableIndex.default()
    private var reindexTask: Task<Void, Never>?

    private init() {}

    // MARK: - Public API

    /// Wipes the index for our domain and re-indexes every eligible cutling.
    /// Coalesces rapid successive calls (e.g. CloudKit fan-in) into a single pass.
    func reindexAll(from store: CutlingStore) {
        reindexTask?.cancel()
        reindexTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
            await self?.performFullReindex(from: store)
        }
    }

    /// Insert-or-update a single cutling in the index. Idempotent.
    func index(_ cutling: Cutling) {
        guard let item = searchableItem(for: cutling) else {
            // Skipped by sensitivity/expiration rules — make sure any stale entry is gone.
            remove(id: cutling.id)
            return
        }
        index.indexSearchableItems([item]) { error in
            if let error = error {
                print("⚠️ Spotlight index failed: \(error.localizedDescription)")
            }
        }
    }

    /// Removes a single cutling from the index.
    func remove(id: UUID) {
        index.deleteSearchableItems(withIdentifiers: [id.uuidString]) { error in
            if let error = error {
                print("⚠️ Spotlight delete failed: \(error.localizedDescription)")
            }
        }
    }

    /// Removes every item this app has indexed.
    func wipeAll() {
        reindexTask?.cancel()
        index.deleteSearchableItems(withDomainIdentifiers: [Self.domain]) { error in
            if let error = error {
                print("⚠️ Spotlight wipe failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Internals

    private func performFullReindex(from store: CutlingStore) async {
        let snapshot = store.cutlings
        let items = snapshot.compactMap { searchableItem(for: $0) }

        do {
            try await index.deleteSearchableItems(withDomainIdentifiers: [Self.domain])
            if !items.isEmpty {
                try await index.indexSearchableItems(items)
            }
        } catch {
            print("⚠️ Spotlight reindex failed: \(error.localizedDescription)")
        }
    }

    private func searchableItem(for cutling: Cutling) -> CSSearchableItem? {
        if cutling.isExpired { return nil }
        if cutling.kind == .text,
           !SensitiveContentType.detect(in: cutling.value).isEmpty {
            return nil
        }

        let contentType: UTType = (cutling.kind == .image) ? .image : .text
        let attributes = CSSearchableItemAttributeSet(contentType: contentType)
        attributes.title = cutling.name
        attributes.displayName = cutling.name

        if cutling.kind == .text {
            let value = cutling.value
            let snippet = value.count > 1000 ? String(value.prefix(1000)) : value
            attributes.contentDescription = snippet
            attributes.textContent = snippet
        } else {
            attributes.contentDescription = String(localized: "Image Cutling")
            if let filename = cutling.imageFilename,
               let thumb = CutlingStore.shared.loadThumbnail(named: filename),
               let data = pngData(from: thumb) {
                attributes.thumbnailData = data
            }
        }

        var keywords: [String] = [cutling.icon, cutling.kind.rawValue]
        keywords.append(contentsOf: cutling.assignedCategories.map(\.displayName))
        attributes.keywords = keywords

        attributes.actionIdentifiers = [Self.editActionID]

        attributes.contentCreationDate = cutling.createdDate
        attributes.contentModificationDate = cutling.lastModifiedDate

        let item = CSSearchableItem(
            uniqueIdentifier: cutling.id.uuidString,
            domainIdentifier: Self.domain,
            attributeSet: attributes
        )
        if let expiresAt = cutling.expiresAt {
            item.expirationDate = expiresAt
        }

        if #available(iOS 17.4, macOS 15.0, *) {
            let entity = CutlingAppEntity(id: cutling.id, name: cutling.name)
            let priority = (cutling.kind == .image) ? 10 : 1
            attributes.associateAppEntity(entity, priority: priority)
        }

        return item
    }

    #if os(iOS)
    private func pngData(from image: UIImage) -> Data? {
        image.pngData()
    }
    #endif
    #if os(macOS)
    private func pngData(from image: NSImage) -> Data? {
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff) else { return nil }
        return rep.representation(using: .png, properties: [:])
    }
    #endif
}

#endif
