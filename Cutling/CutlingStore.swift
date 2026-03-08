//
//  CutlingStore.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import Foundation
import Combine
import CryptoKit
import CloudKit

#if os(iOS)
import UIKit
import SwiftUI
#else
import AppKit
import SwiftUI
#endif

let appGroupID = "group.com.matsuokengo.Cutling"
private let cutlingsKey = "savedCutlings"

// Key used in NSUbiquitousKeyValueStore for syncing text cutlings across devices
private let kvsTextCutlingsKey = "syncedTextCutlings"

// MARK: - Cutling Limits

/// Limits are enforced to keep the keyboard extension under iOS's strict memory limit.
/// - Text cutlings are lightweight (~1-5 KB each)
/// - Image cutlings are heavier (~50-500 KB each, even with thumbnails)
extension CutlingStore {
    /// Maximum number of image cutlings allowed (prevents memory crashes)
    static let maxImageCutlings = 25
    
    /// Maximum number of text cutlings allowed
    static let maxTextCutlings = 100
    
    /// Maximum character length for a single text cutling's value
    static let maxTextLength = 2000
    
    /// Total limit across both types (safety net)
    static let maxTotalCutlings = 125
    
    /// Check if a text value exceeds the character limit.
    func isTextTooLong(_ text: String) -> Bool {
        text.count > Self.maxTextLength
    }
}

class CutlingStore: ObservableObject {
    static let shared = CutlingStore()

    @Published var cutlings: [Cutling] = []
    @Published var lastAddedCutlingID: UUID?
    @Published var iCloudSyncEnabled: Bool = true

    private let defaults: UserDefaults
    let imagesDirectory: URL
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - iCloud Sync
    
    /// NSUbiquitousKeyValueStore for syncing text cutlings across devices.
    /// This is Apple's iCloud Key-Value Store — a network-synchronized version
    /// of UserDefaults. It has a 1 MB total limit and max 1024 keys, which is
    /// well within our needs for text cutlings (up to 200 items, ~1-5 KB each).
    /// Both the main app and keyboard extension can share this store using the
    /// same ubiquity-kvstore-identifier in their entitlements.
    private let kvStore = NSUbiquitousKeyValueStore.default
    
    /// CloudSyncManager handles image cutling sync via CKSyncEngine.
    /// CKSyncEngine (iOS 17+ / macOS 14+) manages CloudKit sync operations
    /// including scheduling, retries, conflict resolution, and state persistence.
    /// Images are stored as CKAsset objects within CKRecords in the user's
    /// private CloudKit database. Only the main app runs this — the keyboard
    /// extension reads synced images from the shared App Group container.
    @available(iOS 17.0, macOS 14.0, *)
    private var cloudSyncManager: CloudSyncManager? {
        get { _cloudSyncManager as? CloudSyncManager }
        set { _cloudSyncManager = newValue }
    }
    private var _cloudSyncManager: AnyObject?
    
    // Tracks whether we're currently processing a remote KVS change to avoid feedback loops
    private var isProcessingRemoteKVSChange = false
    
    // CRITICAL: Memory-efficient image cache with automatic eviction
    #if os(iOS)
    private var thumbnailCache = NSCache<NSString, UIImage>()
    #else
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
        
        // Listen for changes from other processes (keyboard extension or main app)
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                self?.loadIfChanged()
            }
            .store(in: &cancellables)
        
        // Listen for Darwin notifications (cross-process)
        setupDarwinNotification()
        
        // Listen for iCloud Key-Value Store changes from other devices.
        // NSUbiquitousKeyValueStore.didChangeExternallyNotification fires when
        // another device updates the KVS. The notification's userInfo contains:
        // - NSUbiquitousKeyValueStoreChangeReasonKey: why the change happened
        //   (server change, initial sync, quota violation, or account change)
        // - NSUbiquitousKeyValueStoreChangedKeysKey: which keys changed
        setupKVSSync()
    }
    
    // MARK: - iCloud KVS Setup
    
    private func setupKVSSync() {
        NotificationCenter.default
            .publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: kvStore)
            .sink { [weak self] notification in
                self?.handleKVSChange(notification)
            }
            .store(in: &cancellables)
        
        // Trigger an initial sync pull from iCloud
        kvStore.synchronize()
    }
    
    private func handleKVSChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        // Check the reason for the change
        let reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int ?? -1
        
        switch reason {
        case NSUbiquitousKeyValueStoreServerChange:
            print("☁️ iCloud KVS: Server change received")
        case NSUbiquitousKeyValueStoreInitialSyncChange:
            print("☁️ iCloud KVS: Initial sync completed")
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            print("⚠️ iCloud KVS: Quota violated — too much data stored (1 MB limit)")
            return
        case NSUbiquitousKeyValueStoreAccountChange:
            print("☁️ iCloud KVS: Account changed")
        default:
            print("☁️ iCloud KVS: Unknown change reason \(reason)")
        }
        
        // Check if our text cutlings key was among the changed keys
        if let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String],
           changedKeys.contains(kvsTextCutlingsKey) {
            mergeRemoteTextCutlings()
        }
    }
    
    /// Merge text cutlings received from iCloud KVS into the local store.
    /// Strategy: Union merge — add any cutlings from the remote that we don't
    /// have locally (by ID). If a cutling exists locally with the same ID,
    /// keep the local version (last-write-wins is handled by KVS at the
    /// whole-key level; within a single device we trust local state).
    private func mergeRemoteTextCutlings() {
        guard !isProcessingRemoteKVSChange else { return }
        isProcessingRemoteKVSChange = true
        defer { isProcessingRemoteKVSChange = false }
        
        guard let data = kvStore.data(forKey: kvsTextCutlingsKey),
              let remoteCutlings = try? JSONDecoder().decode([Cutling].self, from: data) else {
            return
        }
        
        let localIDs = Set(cutlings.map(\.id))
        let localTextCutlings = cutlings.filter { $0.kind == .text }
        let localTextIDs = Set(localTextCutlings.map(\.id))
        let remoteTextIDs = Set(remoteCutlings.map(\.id))
        
        var changed = false
        
        // Add remote cutlings that don't exist locally
        for remote in remoteCutlings where !localIDs.contains(remote.id) {
            cutlings.append(remote)
            changed = true
            print("☁️ Added remote text cutling: \(remote.name)")
        }
        
        // Update existing text cutlings with remote data
        for remote in remoteCutlings {
            if let localIndex = cutlings.firstIndex(where: { $0.id == remote.id && $0.kind == .text }) {
                if cutlings[localIndex] != remote {
                    cutlings[localIndex] = remote
                    changed = true
                    print("☁️ Updated text cutling from remote: \(remote.name)")
                }
            }
        }
        
        // Remove text cutlings that were deleted on the remote (they exist locally
        // but not in the remote set). Only remove if the remote set is non-empty
        // (empty remote set on first sync should not delete local data).
        if !remoteCutlings.isEmpty {
            let removedIDs = localTextIDs.subtracting(remoteTextIDs)
            if !removedIDs.isEmpty {
                cutlings.removeAll { removedIDs.contains($0.id) && $0.kind == .text }
                changed = true
                print("☁️ Removed \(removedIDs.count) text cutlings deleted on remote")
            }
        }
        
        if changed {
            save()
            print("☁️ Merged \(remoteCutlings.count) remote text cutlings")
        }
    }
    
    /// Push current text cutlings to iCloud KVS for cross-device sync.
    private func syncTextCutlingsToKVS() {
        guard !isProcessingRemoteKVSChange else { return }
        
        let textCutlings = cutlings.filter { $0.kind == .text }
        guard let data = try? JSONEncoder().encode(textCutlings) else { return }
        
        kvStore.set(data, forKey: kvsTextCutlingsKey)
        // Note: We don't need to call kvStore.synchronize() after every write.
        // The system coalesces changes and syncs automatically. Calling synchronize()
        // too frequently can cause iCloud to throttle updates (sync time increases
        // from ~10-20s to several minutes). We only call it on initial setup.
    }
    
    // MARK: - CloudKit Image Sync Setup
    
    /// Initialize CloudKit image sync. Call this early in the app lifecycle.
    /// Only the main app should call this — NOT the keyboard extension.
    /// CKSyncEngine requires the CloudKit and Push Notifications entitlements,
    /// and relies on remote notifications for sync, which are not available
    /// in keyboard extensions.
    func setupCloudKitSync() {
        guard iCloudSyncEnabled else { return }
        
        if #available(iOS 17.0, macOS 14.0, *) {
            let manager = CloudSyncManager()
            manager.onRemoteImageChange = { [weak self] received, deletedIDs in
                self?.handleRemoteImageChanges(received: received, deletedIDs: deletedIDs)
            }
            self.cloudSyncManager = manager
            print("☁️ CloudKit image sync initialized")
            
            // Queue any existing local image cutlings that may not have been synced yet
            syncAllLocalImageCutlings()
        }
    }
    
    /// Handle image cutlings that arrived from or were deleted on other devices.
    @available(iOS 17.0, macOS 14.0, *)
    private func handleRemoteImageChanges(received: [ImageCutlingRecord], deletedIDs: [CKRecord.ID]) {
        var changed = false
        
        // Process received image cutlings
        for record in received {
            // Copy the downloaded asset to our images directory
            if let assetURL = record.downloadedAssetURL {
                let destinationURL = imagesDirectory.appendingPathComponent(record.imageFilename)
                do {
                    // Remove existing file if present
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    try FileManager.default.copyItem(at: assetURL, to: destinationURL)
                    print("☁️ Downloaded image asset: \(record.imageFilename)")
                } catch {
                    print("❌ Failed to copy downloaded image: \(error)")
                    continue
                }
            }
            
            // Add or update the cutling in our local store
            if let existingIndex = cutlings.firstIndex(where: { $0.id == record.cutlingID }) {
                cutlings[existingIndex].name = record.name
                cutlings[existingIndex].icon = record.icon
                cutlings[existingIndex].imageFilename = record.imageFilename
            } else {
                let cutling = Cutling(
                    id: record.cutlingID,
                    name: record.name,
                    value: "",
                    icon: record.icon,
                    kind: .image,
                    imageFilename: record.imageFilename
                )
                cutlings.append(cutling)
            }
            changed = true
        }
        
        // Process deletions
        for recordID in deletedIDs {
            if let cutlingID = UUID(uuidString: recordID.recordName),
               let index = cutlings.firstIndex(where: { $0.id == cutlingID }) {
                let cutling = cutlings[index]
                if let filename = cutling.imageFilename {
                    deleteImageFile(named: filename)
                }
                cutlings.remove(at: index)
                changed = true
                print("☁️ Deleted image cutling from remote: \(cutlingID)")
            }
        }
        
        if changed {
            DispatchQueue.main.async {
                self.save()
            }
        }
    }
    
    /// Queue all local image cutlings for CloudKit sync.
    @available(iOS 17.0, macOS 14.0, *)
    private func syncAllLocalImageCutlings() {
        guard let manager = cloudSyncManager else { return }
        
        for cutling in cutlings where cutling.kind == .image {
            guard let filename = cutling.imageFilename else { continue }
            let record = ImageCutlingRecord(
                cutlingID: cutling.id,
                name: cutling.name,
                icon: cutling.icon,
                imageFilename: filename
            )
            manager.queueImageUpload(record)
        }
    }
    
    /// Queue a single image cutling for CloudKit upload.
    private func syncImageCutlingToCloud(_ cutling: Cutling) {
        guard iCloudSyncEnabled, cutling.kind == .image else { return }
        guard let filename = cutling.imageFilename else { return }
        
        if #available(iOS 17.0, macOS 14.0, *) {
            cloudSyncManager?.queueImageUpload(ImageCutlingRecord(
                cutlingID: cutling.id,
                name: cutling.name,
                icon: cutling.icon,
                imageFilename: filename
            ))
        }
    }
    
    /// Queue an image cutling for CloudKit deletion.
    private func syncImageDeletionToCloud(_ cutling: Cutling) {
        guard iCloudSyncEnabled, cutling.kind == .image else { return }
        
        if #available(iOS 17.0, macOS 14.0, *) {
            cloudSyncManager?.queueImageDeletion(cutlingID: cutling.id)
        }
    }
    
    private func setupDarwinNotification() {
        let notificationName = "com.matsuokengo.Cutling.cutlingsChanged" as CFString
        
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            observer,
            { _, observer, _, _, _ in
                guard let observer = observer else { return }
                let store = Unmanaged<CutlingStore>.fromOpaque(observer).takeUnretainedValue()
                store.loadIfChanged()
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
            // Data was deleted
            if !cutlings.isEmpty {
                cutlings = []
            }
            return
        }
        
        // Only reload if the data actually changed
        if data != lastLoadedData {
            lastLoadedData = data
            if let decoded = try? JSONDecoder().decode([Cutling].self, from: data) {
                DispatchQueue.main.async {
                    self.cutlings = decoded
                    print("🔄 Reloaded \(decoded.count) cutlings from shared storage")
                }
            }
        }
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
        cutlings = decoded
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
        
        // Sync text cutlings to iCloud KVS for cross-device sync
        syncTextCutlingsToKVS()
    }

    func add(_ cutling: Cutling) {
        cutlings.append(cutling)
        lastAddedCutlingID = cutling.id
        save()
        
        // Queue image for CloudKit sync
        if cutling.kind == .image {
            syncImageCutlingToCloud(cutling)
        }
    }
    
    func sortCutlings(by areInIncreasingOrder: (Cutling, Cutling) -> Bool) {
        cutlings.sort(by: areInIncreasingOrder)
        save()
    }

    func reverseCutlings() {
        cutlings.reverse()
        save()
    }
    
    func moveCutlings(fromOffsets source: IndexSet, toOffset destination: Int) {
        cutlings.move(fromOffsets: source, toOffset: destination)
        save()
    }
    
    // MARK: - Limit Checks
    
    /// Check if adding a new cutling of the given type would exceed limits
    func canAdd(_ kind: CutlingKind) -> (allowed: Bool, reason: String?) {
        let totalCount = cutlings.count
        let imageCount = cutlings.filter { $0.kind == .image }.count
        let textCount = cutlings.filter { $0.kind == .text }.count
        
        // Check total limit first
        if totalCount >= Self.maxTotalCutlings {
            return (false, "You've reached the maximum of \(Self.maxTotalCutlings) total cutlings. Delete some to add more.")
        }
        
        // Check type-specific limits
        switch kind {
        case .image:
            if imageCount >= Self.maxImageCutlings {
                return (false, "You've reached the maximum of \(Self.maxImageCutlings) image cutlings. Images use significant memory in the keyboard. Delete some images to add more.")
            }
        case .text:
            if textCount >= Self.maxTextCutlings {
                return (false, "You've reached the maximum of \(Self.maxTextCutlings) text cutlings. Delete some to add more.")
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

    func update(_ cutling: Cutling) {
        if let i = cutlings.firstIndex(where: { $0.id == cutling.id }) {
            cutlings[i] = cutling
            save()
            
            // Queue image for CloudKit sync if it's an image cutling
            if cutling.kind == .image {
                syncImageCutlingToCloud(cutling)
            }
        }
    }

    func delete(_ cutling: Cutling) {
        // Queue CloudKit deletion before removing locally
        if cutling.kind == .image {
            syncImageDeletionToCloud(cutling)
        }
        
        if let filename = cutling.imageFilename {
            deleteImageFile(named: filename)
        }
        cutlings.removeAll { $0.id == cutling.id }
        save()
    }

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
    #else
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

    // MARK: - Seed

    func seedIfEmpty() {
        guard cutlings.isEmpty else { return }
        cutlings = [
            Cutling(name: "Email", value: "email@example.com", icon: "envelope"),
            Cutling(name: "Phone", value: "+1 234 567 8900", icon: "phone"),
            Cutling(name: "Address", value: "123 Main St, Apartment 4A, City, Postal Code, Country", icon: "house"),
        ]
        save()
    }
}

// MARK: - Data Hashing Extension

extension Data {
    /// Generate SHA256 hash for efficient image comparison
    func sha256Hash() -> String {
        let hashed = SHA256.hash(data: self)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
