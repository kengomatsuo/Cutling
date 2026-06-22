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
private let cutlingsKey = "savedCutlings"
private let recentlyDeletedKey = "recentlyDeletedCutlings"
private let historyKey = "cutlingHistory"

// MARK: - Cutling Limits

/// Limits are enforced to keep the keyboard extension under iOS's strict memory limit.
/// - Text cutlings are lightweight (~1-5 KB each)
/// - Image cutlings are heavier (~50-500 KB each, even with thumbnails)
extension CutlingStore {
    /// Maximum number of image cutlings allowed (prevents memory crashes)
    nonisolated static let maxImageCutlings = 25

    /// Maximum number of text cutlings allowed
    nonisolated static let maxTextCutlings = 100

    /// Maximum character length for a single text cutling's value
    nonisolated static let maxTextLength = 1000

    /// Total limit across both types (safety net)
    nonisolated static let maxTotalCutlings = 125

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

    @Published var cutlings: [Cutling] = []
    @Published var lastAddedCutlingID: UUID?
    /// Auto-captured clipboard history (Mac only). Device-local, not synced via CloudKit.
    @Published var historyCutlings: [Cutling] = []
    #if MAIN_APP
    @Published var isSyncing: Bool = false
    @Published var recentlyDeleted: [DeletedCutling] = []

    /// Set by CutlingApp when iCloud sync is enabled.
    var syncManager: CloudKitSyncManager?
    #endif

    private let defaults: UserDefaults
    let imagesDirectory: URL
    private var cancellables = Set<AnyCancellable>()
    
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
        // Use App Group defaults if available, otherwise fall back to standard
        if let groupDefaults = UserDefaults(suiteName: appGroupID) {
            defaults = groupDefaults
        } else {
            print("⚠️ App Group not available, using standard UserDefaults")
            defaults = .standard
        }

        // Use App Group container if available, otherwise fall back to Documents
        if let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) {
            imagesDirectory = containerURL.appendingPathComponent("Images", isDirectory: true)
        } else {
            print("⚠️ App Group container not available, using Documents/Images")
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            imagesDirectory = docs.appendingPathComponent("Images", isDirectory: true)
        }

        if !FileManager.default.fileExists(atPath: imagesDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
                print("✅ Created images directory: \(imagesDirectory.path)")
            } catch {
                print("❌ Failed to create images directory: \(error)")
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
        
        // Listen for changes from other processes (keyboard extension or main app)
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadIfChanged()
            }
            .store(in: &cancellables)
        
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

    private var lastLoadedData: Data?

    private func loadIfChanged() {
        guard let data = defaults.data(forKey: cutlingsKey) else {
            // Key returned nil — do NOT clear in-memory cutlings.
            // This can happen transiently if the app group container is
            // briefly inaccessible. Wiping here would cause data loss.
            return
        }

        if data != lastLoadedData {
            lastLoadedData = data
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
        guard let data = defaults.data(forKey: cutlingsKey),
              let decoded = try? JSONDecoder().decode([Cutling].self, from: data)
        else { 
            lastLoadedData = nil
            return 
        }
        lastLoadedData = data
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
        lastLoadedData = encoded
        defaults.set(encoded, forKey: cutlingsKey)
        
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
        if let sm = syncManager { Task { await sm.enqueueSave(c) } }
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
            $0.value.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed
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
            if let sm = syncManager { Task { await sm.enqueueSave(c) } }
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
        if let sm = syncManager { Task { await sm.enqueueDelete(cutling.id) } }
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
        guard let data = defaults.data(forKey: recentlyDeletedKey),
              let decoded = try? JSONDecoder().decode([DeletedCutling].self, from: data)
        else { return }
        recentlyDeleted = decoded
        purgeExpiredDeletions()
    }

    private func saveRecentlyDeleted() {
        guard let encoded = try? JSONEncoder().encode(recentlyDeleted) else { return }
        defaults.set(encoded, forKey: recentlyDeletedKey)
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
            let data = try Data(contentsOf: fileURL)
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
        // Check cache first
        if let cached = thumbnailCache.object(forKey: filename as NSString) {
            return cached
        }
        
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        
        // Use ImageIO for efficient downsampling without loading full image into memory
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
        
        let thumbnail = UIImage(cgImage: croppedCGImage)
        
        // Cache it with cost based on pixel count
        let cost = Int(thumbnail.size.width * thumbnail.size.height * thumbnail.scale * thumbnail.scale)
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
        
        // Also remove from cache
        thumbnailCache.removeObject(forKey: filename as NSString)
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
            let detected = InputTypeCategory.detect(from: cutlings[i].value)
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
        let triggers = InputTypeCategory.detect(from: cutling.value).flatMap { $0.triggerKeys }
        cutling.inputTypeTriggers = triggers.isEmpty ? nil : Array(Set(triggers))
    }

    /// Rescans every text cutling whose input types have NOT been pinned by the
    /// user and replaces `inputTypeTriggers` with the latest detection result.
    /// Covers cases where the in-page debounced detector did not get a chance
    /// to run (user exited the editor immediately after typing).
    func scanInputTypesIfNeeded() {
        var changed = false
        for i in cutlings.indices where cutlings[i].kind == .text && !cutlings[i].userSetInputType {
            let detected = InputTypeCategory.detect(from: cutlings[i].value)
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
        guard let data = defaults.data(forKey: historyKey),
              let decoded = try? JSONDecoder().decode([Cutling].self, from: data)
        else { return }
        historyCutlings = decoded
    }

    private func saveHistory() {
        guard let encoded = try? JSONEncoder().encode(historyCutlings) else { return }
        defaults.set(encoded, forKey: historyKey)
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
        let item = historyCutlings[index]
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
