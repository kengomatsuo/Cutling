//
//  CutlingStore.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import Foundation
import Combine
import CryptoKit

#if os(iOS)
import UIKit
import SwiftUI
#endif
#if os(macOS)
import AppKit
import SwiftUI
#endif

let appGroupID = "group.com.matsuokengo.Cutling"

/// A list the store keeps as a JSON file in the App Group container. iOS refuses an app's
/// UserDefaults past about 4 MB, and 1,000 full-length text cutlings in CJK or emoji reach
/// that alone, so the lists left UserDefaults; `legacyKey` is where they lived before.
private enum StoredList: String {
    case cutlings = "cutlings.json"
    case recentlyDeleted = "recently-deleted.json"
    case history = "history.json"

    var legacyKey: String {
        switch self {
        case .cutlings: "savedCutlings"
        case .recentlyDeleted: "recentlyDeletedCutlings"
        case .history: "cutlingHistory"
        }
    }
}

// MARK: - Cutling Limits

/// The caps keep the keyboard extension under the memory iOS gives keyboards: 77 MB of
/// phys_footprint on every supported iPhone (com.apple.keyboard-service in the jetsam
/// properties of iOS 18.0 and 27.2.1, docs/research/keyboard-memory-limits.md). The keyboard
/// decodes every text cutling (up to about 4.3 KB of JSON each at full length). Measured in the
/// iOS 27.2 simulator with every text at full length and 12 MP photos, scrolling the whole grid
/// (scripts/keyboard-memory.sh): 1,000 text alone peaks at 53 MB, with 25 photos 66 MB, with 50
/// photos 69 MB, and with 100 photos 95 MB, past the limit. Images stop at 50.
extension CutlingStore {
    /// Maximum number of image cutlings allowed
    nonisolated static let maxImageCutlings = 50

    /// Maximum number of text cutlings allowed
    nonisolated static let maxTextCutlings = 1000

    /// Maximum character length for a single text cutling's value
    nonisolated static let maxTextLength = 1000

    /// Total limit across both types
    nonisolated static let maxTotalCutlings = maxTextCutlings + maxImageCutlings

    /// Maximum number of clipboard history entries to retain (FIFO, device-local).
    nonisolated static let maxHistoryCutlings = 50
    
    /// Check if a text value exceeds the character limit.
    func isTextTooLong(_ text: String) -> Bool {
        text.count > Self.maxTextLength
    }
}

@MainActor
class CutlingStore: ObservableObject {
    static let shared = CutlingStore()

    #if DEBUG && os(macOS)
    /// Screenshot runs on Mac use a throwaway store.
    nonisolated static var isMacSnapshotMode: Bool {
        ProcessInfo.processInfo.arguments.contains("-SNAPSHOT_MODE")
    }
    #endif

    @Published var cutlings: [Cutling] = []
    @Published var lastAddedCutlingID: UUID?
    /// Auto-captured clipboard history (Mac only). Device-local, not synced via CloudKit.
    @Published var historyCutlings: [Cutling] = []
    #if MAIN_APP
    @Published var isSyncing: Bool = false
    @Published var recentlyDeleted: [DeletedCutling] = []

    /// Set by CutlingApp when iCloud sync is enabled.
    var syncManager: CloudKitSyncManager?

    #if os(macOS)
    /// Starts the CloudKit sync engine at runtime (idempotent). macOS toggles
    /// iCloud from the Welcome wizard and Settings; unlike iOS these live
    /// outside the main scene tree, so they call this directly instead of
    /// relying on a scene-level `.onChange`. Without it, enabling iCloud does
    /// nothing until the next launch.
    @MainActor
    func startCloudSyncIfNeeded() {
        guard syncManager == nil else { return }
        let manager = CloudKitSyncManager(store: self)
        syncManager = manager
        Task { await manager.start() }
        // Mirror to app group + KVS so the keyboard extension and other
        // devices see the enabled state.
        UserDefaults(suiteName: appGroupID)?.set(true, forKey: "iCloudSyncEnabled")
        NSUbiquitousKeyValueStore.default.set(true, forKey: "iCloudSyncEnabled")
    }

    /// Tears down the CloudKit sync engine at runtime and clears the flags.
    @MainActor
    func stopCloudSync() {
        if let manager = syncManager {
            Task { await manager.stop() }
        }
        syncManager = nil
        isSyncing = false
        UserDefaults(suiteName: appGroupID)?.set(false, forKey: "iCloudSyncEnabled")
        NSUbiquitousKeyValueStore.default.set(false, forKey: "iCloudSyncEnabled")
    }
    #endif
    #endif

    private let defaults: UserDefaults
    let imagesDirectory: URL
    /// Holds the StoredList files.
    private let listsDirectory: URL
    
    // CRITICAL: Memory-efficient image cache with automatic eviction
    #if os(iOS)
    private var thumbnailCache = NSCache<NSString, UIImage>()
    #endif
    #if os(macOS)
    private var thumbnailCache = NSCache<NSString, NSImage>()
    #endif
    
    // Maximum thumbnail size for keyboard (reduces memory dramatically)
    private let maxThumbnailSize: CGFloat = 200

    init() {
        #if DEBUG && os(macOS)
        // Mac screenshots run on a real Mac: keep the owner's store untouched
        let snapshotDefaults: UserDefaults? = Self.isMacSnapshotMode
            ? UserDefaults(suiteName: "com.matsuokengo.Cutling.snapshot-store") : nil
        #else
        let snapshotDefaults: UserDefaults? = nil
        #endif
        // Use App Group defaults if available, otherwise fall back to standard
        if let snapshotDefaults {
            defaults = snapshotDefaults
        } else if let groupDefaults = UserDefaults(suiteName: appGroupID) {
            defaults = groupDefaults
        } else {
            print("⚠️ App Group not available, using standard UserDefaults")
            defaults = .standard
        }

        // Use App Group container if available, otherwise fall back to Documents
        let root: URL
        if snapshotDefaults != nil {
            root = FileManager.default.temporaryDirectory.appendingPathComponent("CutlingSnapshot", isDirectory: true)
        } else if let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) {
            root = containerURL
        } else {
            print("⚠️ App Group container not available, using Documents")
            root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
        imagesDirectory = root.appendingPathComponent("Images", isDirectory: true)
        listsDirectory = root.appendingPathComponent("Lists", isDirectory: true)

        for directory in [imagesDirectory, listsDirectory] where !FileManager.default.fileExists(atPath: directory.path) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                print("✅ Created directory: \(directory.path)")
            } catch {
                print("❌ Failed to create directory: \(error)")
            }
        }
        
        // Configure thumbnail cache limits (crucial for keyboard extension memory limits)
        #if os(iOS)
        thumbnailCache.countLimit = 30  // Maximum 30 thumbnails in memory
        thumbnailCache.totalCostLimit = 10 * 1024 * 1024  // 10 MB max for images
        #endif

        load()
        #if MAIN_APP
        loadRecentlyDeleted()
        #endif
        #if os(macOS)
        loadHistory()
        #endif
        
        // Listen for Darwin notifications (cross-process)
        setupDarwinNotification()
        
        // Schedule purge for the next expiring cutling
        schedulePurgeTimer()
    }
    
    private func setupDarwinNotification() {
        let notificationName = "com.matsuokengo.Cutling.cutlingsChanged" as CFString

        let observer = unsafe UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        unsafe CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            observer,
            { _, observer, _, _, _ in
                guard let observer = unsafe observer else { return }
                let store = unsafe Unmanaged<CutlingStore>.fromOpaque(observer).takeUnretainedValue()
                DispatchQueue.main.async {
                    store.loadIfChanged()
                }
            },
            notificationName,
            nil,
            .deliverImmediately
        )
    }

    // MARK: - Real-Time Sync

    /// The digest of the list file last loaded or saved, to skip reloading an unchanged file.
    /// A digest, not the file: holding 10,000 snippets' JSON cost the keyboard 14 MB of its 77.
    private var lastLoadedDigest: SHA256.Digest?

    /// Reads a stored list. The first read after the move copies the list out of UserDefaults
    /// into its file and drops the old key, so the defaults domain shrinks back to settings.
    private func read(_ list: StoredList) -> Data? {
        let url = listsDirectory.appendingPathComponent(list.rawValue)
        // Mapped: the file's pages stay clean and outside the process's footprint.
        if let data = try? Data(contentsOf: url, options: .alwaysMapped) { return data }
        guard let legacy = defaults.data(forKey: list.legacyKey) else { return nil }
        do {
            try legacy.write(to: url, options: .atomic)
            defaults.removeObject(forKey: list.legacyKey)
        } catch {
            print("❌ Failed to move \(list.legacyKey) to \(list.rawValue): \(error)")
        }
        return legacy
    }

    /// Replaces a stored list whole; readers in other processes see the old file or the new one, never part of one.
    private func write(_ data: Data, to list: StoredList) {
        do {
            try data.write(to: listsDirectory.appendingPathComponent(list.rawValue), options: .atomic)
        } catch {
            print("❌ Failed to save \(list.rawValue): \(error)")
        }
    }

    private func loadIfChanged() {
        guard let data = read(.cutlings) else {
            // No file — do NOT clear in-memory cutlings.
            // This can happen transiently if the app group container is
            // briefly inaccessible. Wiping here would cause data loss.
            return
        }

        let digest = SHA256.hash(data: data)
        if digest != lastLoadedDigest {
            lastLoadedDigest = digest
            if let decoded = try? JSONDecoder().decode([Cutling].self, from: data) {
                let deduped = Self.deduplicatedByID(decoded)
                self.cutlings = deduped
                self.purgeExpired()
                if deduped.count != decoded.count {
                    save()
                }
                print("🔄 Reloaded \(self.cutlings.count) cutlings from shared storage")
                #if MAIN_APP
                SpotlightIndexer.shared.reindexAll(from: self)
                #endif
            }
        }
    }

    /// Drops entries that share an `id` with an earlier entry, keeping the
    /// first occurrence. Persisted duplicates can sneak in via races between
    /// CloudKit merges and local writes; once present they cause SwiftUI
    /// `LazyVStack` to reserve a slot for the duplicate that renders empty.
    private static func deduplicatedByID(_ list: [Cutling]) -> [Cutling] {
        var seen = Set<UUID>()
        var result: [Cutling] = []
        result.reserveCapacity(list.count)
        for c in list where seen.insert(c.id).inserted {
            result.append(c)
        }
        return result
    }

    // MARK: - CRUD

    func load() {
        guard let data = read(.cutlings),
              let decoded = try? JSONDecoder().decode([Cutling].self, from: data)
        else { 
            lastLoadedDigest = nil
            return 
        }
        lastLoadedDigest = SHA256.hash(data: data)
        let deduped = Self.deduplicatedByID(decoded)
        cutlings = deduped
        purgeExpired()
        if deduped.count != decoded.count {
            save()
        }
    }

    /// Removes expired cutlings, moving them to recently deleted in the main app.
    func purgeExpired() {
        let expired = cutlings.filter { $0.isExpired }
        guard !expired.isEmpty else { return }
        
        cutlings.removeAll { $0.isExpired }
        save()
        
        #if MAIN_APP
        for item in expired {
            SpotlightIndexer.shared.remove(id: item.id)
        }
        // Soft-delete: move to recently deleted and enqueue CloudKit deletes
        for item in expired {
            let deleted = DeletedCutling(cutling: item, deletedAt: Date())
            recentlyDeleted.insert(deleted, at: 0)
        }
        saveRecentlyDeleted()
        if let sm = syncManager {
            Task {
                for item in expired {
                    await sm.enqueueDelete(item.id)
                }
            }
        }
        #else
        // Keyboard extension: hard-delete image files (no recently-deleted UI)
        for item in expired {
            if let filename = item.imageFilename {
                deleteImageFile(named: filename)
            }
        }
        #endif
        
        // Schedule next purge
        schedulePurgeTimer()
    }
    
    private var purgeTimer: Timer?
    
    /// Schedules a timer to fire at the next cutling's expiration time.
    func schedulePurgeTimer() {
        purgeTimer?.invalidate()
        purgeTimer = nil
        
        // Find the earliest future expiration
        let nextExpiration = cutlings
            .compactMap { $0.expiresAt }
            .filter { $0 > Date() }
            .min()
        
        guard let fireDate = nextExpiration else { return }
        
        // Add a tiny buffer so the cutling is definitely expired when we fire
        let timer = Timer(fireAt: fireDate.addingTimeInterval(0.5), interval: 0, target: self, selector: #selector(purgeTimerFired), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
        purgeTimer = timer
    }
    
    @objc private func purgeTimerFired() {
        purgeExpired()
    }

    func save() {
        guard let encoded = try? JSONEncoder().encode(cutlings) else { return }
        lastLoadedDigest = SHA256.hash(data: encoded)
        write(encoded, to: .cutlings)
        
        // Notify other processes (keyboard extension or main app)
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("com.matsuokengo.Cutling.cutlingsChanged" as CFString),
            nil,
            nil,
            true
        )
    }

    func add(_ cutling: Cutling) {
        var c = cutling
        c.sortOrder = cutlings.count
        c.lastModifiedDate = Date()
        applyInputTypeDetection(&c)
        cutlings.append(c)
        lastAddedCutlingID = c.id
        save()
        schedulePurgeTimer()
        #if MAIN_APP
        SpotlightIndexer.shared.index(c)
        if let sm = syncManager { Task { await sm.enqueueSave(c); await sm.flushPendingChanges() } }
        #endif
    }
    
    func duplicate(_ cutling: Cutling) {
        let canAdd = canAdd(cutling.kind)
        guard canAdd.allowed else { return }

        let newID = UUID()
        var copy = Cutling(
            id: newID,
            name: uniqueDuplicateName(for: cutling.name),
            value: cutling.value,
            icon: cutling.icon,
            kind: cutling.kind,
            imageFilename: nil,
            expiresAt: cutling.expiresAt
        )
        copy.color = cutling.color
        copy.inputTypeTriggers = cutling.inputTypeTriggers
        copy.format = cutling.format

        if let filename = cutling.imageFilename,
           let data = loadImageData(named: filename) {
            copy.imageFilename = saveImageData(data, for: newID)
        }

        add(copy)
    }

    private func uniqueDuplicateName(for name: String) -> String {
        let existingNames = Set(cutlings.map(\.name))
        let copyLabel = String(localized: "copy")

        let baseName: String
        let regex = try? NSRegularExpression(pattern: " \(NSRegularExpression.escapedPattern(for: copyLabel))( \\d+)?$")
        if let regex, let match = regex.firstMatch(in: name, range: NSRange(name.startIndex..., in: name)) {
            baseName = String(name[name.startIndex..<name.index(name.startIndex, offsetBy: match.range.location)])
        } else {
            baseName = name
        }

        let candidate = "\(baseName) \(copyLabel)"
        if !existingNames.contains(candidate) { return candidate }

        var counter = 2
        while existingNames.contains("\(baseName) \(copyLabel) \(counter)") {
            counter += 1
        }
        return "\(baseName) \(copyLabel) \(counter)"
    }

    func sortCutlings(by areInIncreasingOrder: (Cutling, Cutling) -> Bool) {
        cutlings.sort(by: areInIncreasingOrder)
        updateSortOrders()
        save()
        enqueueAllForSync()
    }

    func reverseCutlings() {
        cutlings.reverse()
        updateSortOrders()
        save()
        enqueueAllForSync()
    }
    
    func moveCutlings(fromOffsets source: IndexSet, toOffset destination: Int) {
        cutlings.move(fromOffsets: source, toOffset: destination)
        updateSortOrders()
        save()
        enqueueAllForSync()
    }
    
    // MARK: - Limit Checks
    
    /// Check if adding a new cutling of the given type would exceed limits
    func canAdd(_ kind: CutlingKind) -> (allowed: Bool, reason: String?) {
        let totalCount = cutlings.count
        let imageCount = cutlings.filter { $0.kind == .image }.count
        let textCount = cutlings.filter { $0.kind == .text }.count
        
        // Check total limit first
        if totalCount >= Self.maxTotalCutlings {
            return (false, String(localized: "You've reached the maximum of \(Self.maxTotalCutlings) total cutlings. Delete some to add more."))
        }
        
        // Check type-specific limits
        switch kind {
        case .image:
            if imageCount >= Self.maxImageCutlings {
                return (false, String(localized: "You've reached the maximum of \(Self.maxImageCutlings) image cutlings. Images use significant memory in the keyboard. Delete some images to add more."))
            }
        case .text:
            if textCount >= Self.maxTextCutlings {
                return (false, String(localized: "You've reached the maximum of \(Self.maxTextCutlings) text cutlings. Delete some to add more."))
            }
        }
        
        return (true, nil)
    }
    
    /// Current counts for display purposes
    var imageCutlingsCount: Int {
        cutlings.filter { $0.kind == .image }.count
    }
    
    var textCutlingsCount: Int {
        cutlings.filter { $0.kind == .text }.count
    }
    
    // MARK: - Duplicate Detection
    
    /// Find an existing image cutling with matching image data
    /// Uses SHA256 hash for efficient comparison without loading all images
    func findDuplicateImage(data: Data) -> Cutling? {
        let newHash = data.sha256Hash()
        
        for cutling in cutlings where cutling.kind == .image {
            guard let filename = cutling.imageFilename else { continue }
            
            // Load existing image data and compare hashes
            if let existingData = loadImageData(named: filename),
               existingData.sha256Hash() == newHash {
                return cutling
            }
        }
        
        return nil
    }

    /// Find an existing text cutling with the same value, ignoring surrounding whitespace.
    func findDuplicateText(value: String) -> Cutling? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return cutlings.first {
            $0.kind == .text &&
            $0.plainValue.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed
        }
    }

    func update(_ cutling: Cutling) {
        if let i = cutlings.firstIndex(where: { $0.id == cutling.id }) {
            var c = cutling
            c.lastModifiedDate = Date()
            applyInputTypeDetection(&c)
            cutlings[i] = c
            save()
            schedulePurgeTimer()
            #if MAIN_APP
            SpotlightIndexer.shared.index(c)
            if let sm = syncManager { Task { await sm.enqueueSave(c); await sm.flushPendingChanges() } }
            #endif
        }
    }

    func delete(_ cutling: Cutling) {
        cutlings.removeAll { $0.id == cutling.id }
        save()
        #if MAIN_APP
        SpotlightIndexer.shared.remove(id: cutling.id)
        // Soft-delete: move to recently deleted instead of permanent removal
        let deleted = DeletedCutling(cutling: cutling, deletedAt: Date())
        recentlyDeleted.insert(deleted, at: 0)
        saveRecentlyDeleted()
        // Enqueue CloudKit delete so other devices remove it from their active list
        if let sm = syncManager { Task { await sm.enqueueDelete(cutling.id); await sm.flushPendingChanges() } }
        #else
        // Keyboard extension: permanently delete (no recently deleted UI there)
        if let filename = cutling.imageFilename {
            deleteImageFile(named: filename)
        }
        #endif
    }

    #if MAIN_APP
    /// Restore a soft-deleted cutling back to the active list.
    func restore(_ deleted: DeletedCutling) {
        var cutling = deleted.cutling
        cutling.sortOrder = cutlings.count
        cutling.lastModifiedDate = Date()
        cutlings.append(cutling)
        save()
        recentlyDeleted.removeAll { $0.id == deleted.id }
        saveRecentlyDeleted()
        SpotlightIndexer.shared.index(cutling)
        if let sm = syncManager { Task { await sm.enqueueSave(cutling) } }
    }

    /// Permanently delete a soft-deleted cutling (no recovery).
    func permanentlyDelete(_ deleted: DeletedCutling) {
        if let filename = deleted.cutling.imageFilename {
            deleteImageFile(named: filename)
        }
        recentlyDeleted.removeAll { $0.id == deleted.id }
        saveRecentlyDeleted()
    }

    /// Permanently delete all recently deleted cutlings.
    func emptyRecentlyDeleted() {
        for item in recentlyDeleted {
            if let filename = item.cutling.imageFilename {
                deleteImageFile(named: filename)
            }
        }
        recentlyDeleted.removeAll()
        saveRecentlyDeleted()
    }

    /// Remove items past their 30-day retention.
    func purgeExpiredDeletions() {
        let expired = recentlyDeleted.filter { $0.isPermanentlyExpired }
        guard !expired.isEmpty else { return }
        for item in expired {
            if let filename = item.cutling.imageFilename {
                deleteImageFile(named: filename)
            }
        }
        recentlyDeleted.removeAll { $0.isPermanentlyExpired }
        saveRecentlyDeleted()
    }

    private func loadRecentlyDeleted() {
        guard let data = read(.recentlyDeleted),
              let decoded = try? JSONDecoder().decode([DeletedCutling].self, from: data)
        else { return }
        recentlyDeleted = decoded
        purgeExpiredDeletions()
    }

    private func saveRecentlyDeleted() {
        guard let encoded = try? JSONEncoder().encode(recentlyDeleted) else { return }
        write(encoded, to: .recentlyDeleted)
    }

    /// Called by CloudKitSyncManager after moving remote deletions to recently deleted.
    @MainActor
    func saveRecentlyDeletedFromSync() {
        saveRecentlyDeleted()
    }
    #endif

    // MARK: - Image File Management

    @discardableResult
    func saveImageData(_ data: Data, for cutlingID: UUID) -> String? {
        let filename = cutlingID.uuidString + ".png"
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL)
            print("✅ Saved image: \(fileURL.path) (\(data.count) bytes)")
            return filename
        } catch {
            print("❌ Failed to save image: \(error)")
            return nil
        }
    }

    func loadImageData(named filename: String) -> Data? {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        do {
            // Mapped, so a large file's pages come from disk as they are read instead of all landing in
            // memory at once: the keyboard copies image files whole and has 77 MB in all.
            let data = try Data(contentsOf: fileURL, options: .alwaysMapped)
            return data
        } catch {
            print("❌ Failed to load image \(filename): \(error)")
            return nil
        }
    }
    
    /// CRITICAL: Load downsampled thumbnail instead of full image to save memory
    /// This can reduce memory usage by 10-50x depending on original image size
    #if os(iOS)
    func loadThumbnail(named filename: String) -> UIImage? {
        if let cached = thumbnailCache.object(forKey: filename as NSString) {
            return cached
        }
        // A square thumbnail kept on disk beside the image: the keyboard (77 MB in all) then reads a few
        // kilobytes per key instead of decoding the original, and the first reader to need it writes it.
        let thumbnailURL = thumbnailFileURL(for: filename)
        if let source = CGImageSourceCreateWithURL(thumbnailURL as CFURL, nil),
           let cgImage = CGImageSourceCreateImageAtIndex(source, 0, [kCGImageSourceShouldCacheImmediately: true] as CFDictionary) {
            return cache(UIImage(cgImage: cgImage), as: filename)
        }

        let fileURL = imagesDirectory.appendingPathComponent(filename)
        guard let imageSource = CGImageSourceCreateWithURL(fileURL as CFURL, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
              let height = properties[kCGImagePropertyPixelHeight] as? CGFloat,
              min(width, height) > 0 else {
            return nil
        }
        // Downsample so the short side is maxThumbnailSize, then crop the centre square.
        let downsampleSize = max(width, height) * maxThumbnailSize / min(width, height)
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: downsampleSize
        ]
        guard let downsampled = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            return nil
        }
        // Drawn into its own bitmap: a cropped CGImage would keep the larger downsampled one alive.
        let side = CGFloat(min(downsampled.width, downsampled.height))
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let thumbnail = UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format).image { _ in
            UIImage(cgImage: downsampled).draw(at: CGPoint(x: -(CGFloat(downsampled.width) - side) / 2,
                                                         y: -(CGFloat(downsampled.height) - side) / 2))
        }
        // Lossless, so the key shows the same pixels it drew before thumbnails were kept on disk.
        if let data = thumbnail.pngData() {
            try? FileManager.default.createDirectory(at: thumbnailURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? data.write(to: thumbnailURL, options: .atomic)
        }
        return cache(thumbnail, as: filename)
    }

    /// Caches a thumbnail at its real cost in bytes, so the cache's 10 MB limit holds.
    private func cache(_ thumbnail: UIImage, as filename: String) -> UIImage {
        let cost = thumbnail.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
        thumbnailCache.setObject(thumbnail, forKey: filename as NSString, cost: cost)
        return thumbnail
    }
    #endif
    #if os(macOS)
    func loadThumbnail(named filename: String) -> NSImage? {
        // Check cache first
        if let cached = thumbnailCache.object(forKey: filename as NSString) {
            return cached
        }
        
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        
        // Use ImageIO for efficient downsampling
        guard let imageSource = CGImageSourceCreateWithURL(fileURL as CFURL, nil) else {
            return nil
        }
        
        // Get image properties to determine aspect ratio
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
              let height = properties[kCGImagePropertyPixelHeight] as? CGFloat else {
            return nil
        }
        
        // Calculate size to downsample to (larger dimension to ensure we can crop a square)
        let maxDimension = max(width, height)
        let minDimension = min(width, height)
        let scale = maxThumbnailSize / minDimension
        let downsampleSize = maxDimension * scale
        
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: downsampleSize
        ]
        
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            return nil
        }
        
        // Crop to square from center
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        let squareSize = min(imageWidth, imageHeight)
        let x = (imageWidth - squareSize) / 2
        let y = (imageHeight - squareSize) / 2
        
        guard let croppedCGImage = cgImage.cropping(to: CGRect(x: x, y: y, width: squareSize, height: squareSize)) else {
            return nil
        }
        
        let thumbnail = NSImage(cgImage: croppedCGImage, size: NSSize(width: squareSize, height: squareSize))
        
        // Cache it
        thumbnailCache.setObject(thumbnail, forKey: filename as NSString)
        
        return thumbnail
    }
    #endif

    func deleteImageFile(named filename: String) {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
        try? FileManager.default.removeItem(at: thumbnailFileURL(for: filename))
        
        // Also remove from cache
        thumbnailCache.removeObject(forKey: filename as NSString)
    }
    
    /// The image's square thumbnail on disk, in the shared container so every target reads the same one.
    func thumbnailFileURL(for filename: String) -> URL {
        imagesDirectory.appendingPathComponent("Thumbnails", isDirectory: true).appendingPathComponent(filename + ".png")
    }

    /// Clear thumbnail cache to free memory if needed
    func clearThumbnailCache() {
        thumbnailCache.removeAllObjects()
    }

    // MARK: - Sync Helpers

    #if MAIN_APP
    /// Called by CloudKitSyncManager when remote changes arrive.
    @MainActor
    func applyRemoteChanges(_ updated: [Cutling]) {
        cutlings = updated
        save()
        schedulePurgeTimer()
        SpotlightIndexer.shared.reindexAll(from: self)
    }

    /// Enqueue all cutlings for sync (used after reorder).
    private func enqueueAllForSync() {
        if let sm = syncManager { Task { await sm.enqueueAllCutlings(cutlings) } }
    }
    #else
    private func enqueueAllForSync() {}
    #endif

    /// Update sortOrder to match current array positions.
    private func updateSortOrders() {
        for i in cutlings.indices {
            cutlings[i].sortOrder = i
        }
    }

    // MARK: - Migrations

    /// One-time migration: detect input type categories for existing text cutlings
    /// that were created before the auto-detection feature existed.
    func migrateInputTypeTriggers() {
        var changed = false
        for i in cutlings.indices where cutlings[i].kind == .text && cutlings[i].inputTypeTriggers == nil {
            let detected = InputTypeCategory.detect(from: cutlings[i].plainValue)
            guard !detected.isEmpty else { continue }
            let triggers = detected.flatMap { $0.triggerKeys }
            cutlings[i].inputTypeTriggers = Array(Set(triggers))
            changed = true
        }
        if changed {
            save()
        }
    }

    /// Runs detection on a single cutling about to be persisted, unless the
    /// user has pinned its input types. Backstops the entry points (clipboard
    /// intents, keyboard add-from-clipboard, detail view dismissed before the
    /// 800 ms debounce) where the in-page detector might never have fired.
    private func applyInputTypeDetection(_ cutling: inout Cutling) {
        guard cutling.kind == .text, !cutling.userSetInputType else { return }
        let triggers = InputTypeCategory.detect(from: cutling.plainValue).flatMap { $0.triggerKeys }
        cutling.inputTypeTriggers = triggers.isEmpty ? nil : Array(Set(triggers))
    }

    /// Rescans every text cutling whose input types have NOT been pinned by the
    /// user and replaces `inputTypeTriggers` with the latest detection result.
    /// Covers cases where the in-page debounced detector did not get a chance
    /// to run (user exited the editor immediately after typing).
    func scanInputTypesIfNeeded() {
        var changed = false
        for i in cutlings.indices where cutlings[i].kind == .text && !cutlings[i].userSetInputType {
            let detected = InputTypeCategory.detect(from: cutlings[i].plainValue)
            let newTriggers = detected.isEmpty ? nil : Array(Set(detected.flatMap { $0.triggerKeys }))
            let oldSet = Set(cutlings[i].inputTypeTriggers ?? [])
            let newSet = Set(newTriggers ?? [])
            if oldSet != newSet {
                cutlings[i].inputTypeTriggers = newTriggers
                changed = true
            }
        }
        if changed {
            save()
        }
    }

    // MARK: - Seed

    func seedIfEmpty() {
        // No default cutlings — start with an empty list
    }

    // MARK: - Clipboard History (macOS)

    #if os(macOS)
    private func loadHistory() {
        guard let data = read(.history),
              let decoded = try? JSONDecoder().decode([Cutling].self, from: data)
        else { return }
        historyCutlings = decoded
    }

    private func saveHistory() {
        guard let encoded = try? JSONEncoder().encode(historyCutlings) else { return }
        write(encoded, to: .history)
    }

    /// Append a text item captured from the system pasteboard to the history.
    /// Dedupes against the most recent entry to avoid noise from clipboard re-copies.
    func appendHistoryText(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let last = historyCutlings.first, last.kind == .text, last.value == text { return }
        let preview = String(trimmed.prefix(60))
        let cutling = Cutling(
            id: UUID(),
            name: preview,
            value: text,
            icon: "doc.on.clipboard",
            kind: .text
        )
        historyCutlings.insert(cutling, at: 0)
        enforceHistoryCap()
        saveHistory()
    }

    /// Append an image item captured from the system pasteboard. Dedupes against
    /// the most recent image by exact data equality.
    /// `sourceFilename` carries the original file name when the user copied an
    /// image file from Finder; nil for raw clipboard captures (screenshots),
    /// in which case a macOS-style date name is synthesised.
    func appendHistoryImage(_ data: Data, sourceFilename: String? = nil) {
        guard !data.isEmpty else { return }
        if let last = historyCutlings.first, last.kind == .image,
           let filename = last.imageFilename,
           let lastData = loadImageData(named: filename), lastData == data {
            return
        }
        let id = UUID()
        guard let filename = saveImageData(data, for: id) else { return }
        let displayName = sourceFilename ?? Self.synthesizedScreenshotName(for: Date())
        var cutling = Cutling(
            id: id,
            name: displayName,
            value: "",
            icon: "photo",
            kind: .image
        )
        cutling.imageFilename = filename
        historyCutlings.insert(cutling, at: 0)
        enforceHistoryCap()
        saveHistory()
    }

    /// Mirrors the macOS desktop screenshot naming convention
    /// (`Screenshot 2026-06-16 at 00.34.16`). POSIX locale keeps the date
    /// portion stable across system languages.
    private static func synthesizedScreenshotName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd 'at' HH.mm.ss"
        return "\(String(localized: "Screenshot")) \(formatter.string(from: date))"
    }

    private func enforceHistoryCap() {
        while historyCutlings.count > Self.maxHistoryCutlings {
            let removed = historyCutlings.removeLast()
            if let filename = removed.imageFilename {
                deleteImageFile(named: filename)
            }
        }
    }

    /// Move a history item into the user-curated cutlings list (subject to limits).
    @discardableResult
    func promoteHistoryToSaved(_ id: UUID) -> Bool {
        guard let index = historyCutlings.firstIndex(where: { $0.id == id }) else { return false }
        var item = historyCutlings[index]
        // History keeps full text; saved cutlings obey the limit.
        if item.kind == .text, isTextTooLong(item.value) {
            item.value = String(item.value.prefix(Self.maxTextLength))
        }
        let canAddCheck = canAdd(item.kind)
        guard canAddCheck.allowed else { return false }
        historyCutlings.remove(at: index)
        saveHistory()
        add(item)
        return true
    }

    func deleteHistory(_ id: UUID) {
        guard let index = historyCutlings.firstIndex(where: { $0.id == id }) else { return }
        let removed = historyCutlings.remove(at: index)
        if let filename = removed.imageFilename {
            deleteImageFile(named: filename)
        }
        saveHistory()
    }

    func clearHistory() {
        for item in historyCutlings {
            if let filename = item.imageFilename {
                deleteImageFile(named: filename)
            }
        }
        historyCutlings.removeAll()
        saveHistory()
    }
    #endif
}

// MARK: - Data Hashing Extension

extension Data {
    /// Generate SHA256 hash for efficient image comparison
    func sha256Hash() -> String {
        let hashed = SHA256.hash(data: self)
        return hashed.map { byte in
            let hex = String(byte, radix: 16)
            return byte < 16 ? "0" + hex : hex
        }.joined()
    }
}

// MARK: - Text Replacement Import

/// System text replacements, cached by the keyboard (only it can read them).
enum TextReplacementImport {
    nonisolated static let defaultsKey = "textReplacements"
}

extension CutlingStore {
    /// Cached replacements not yet saved as cutlings.
    var pendingTextReplacements: [(shortcut: String, phrase: String)] {
        let pairs = defaults.array(forKey: TextReplacementImport.defaultsKey) as? [[String: String]] ?? []
        let existing = Set(cutlings.map { "\($0.name)\u{1F}\($0.value)" })
        return pairs.compactMap { pair in
            guard let shortcut = pair["shortcut"], let phrase = pair["phrase"],
                  !phrase.isEmpty, phrase.count <= Self.maxTextLength,
                  !existing.contains("\(shortcut)\u{1F}\(phrase)")
            else { return nil }
            return (shortcut, phrase)
        }
    }

    /// Saves pending replacements as cutlings until a limit is hit; returns how many.
    @discardableResult
    func importTextReplacements() -> Int {
        var imported = 0
        for (shortcut, phrase) in pendingTextReplacements {
            guard canAdd(.text).allowed else { break }
            add(Cutling(name: shortcut, value: phrase, icon: "character.cursor.ibeam"))
            imported += 1
        }
        return imported
    }
}
