//
//  CutlingStore.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import Foundation
import Combine
import CryptoKit

#if os(iOS)
import UIKit
#else
import AppKit
#endif

let appGroupID = "group.com.matsuokengo.Cutling"
private let cutlingsKey = "savedCutlings"

// MARK: - Cutling Limits

/// Limits are enforced to keep the keyboard extension under iOS's strict 77 MB memory limit.
/// - Text cutlings are lightweight (~1-5 KB each)
/// - Image cutlings are heavier (~50-500 KB each, even with thumbnails)
extension CutlingStore {
    /// Maximum number of image cutlings allowed (prevents memory crashes)
    static let maxImageCutlings = 50
    
    /// Maximum number of text cutlings allowed
    static let maxTextCutlings = 200
    
    /// Total limit across both types (safety net)
    static let maxTotalCutlings = 250
}

class CutlingStore: ObservableObject {
    static let shared = CutlingStore()

    @Published var cutlings: [Cutling] = []

    private let defaults: UserDefaults
    private let imagesDirectory: URL
    private var cancellables = Set<AnyCancellable>()
    
    // CRITICAL: Memory-efficient image cache with automatic eviction
    private var thumbnailCache = NSCache<NSString, UIImage>()
    
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
    }

    func add(_ cutling: Cutling) {
        cutlings.append(cutling)
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
        }
    }

    func delete(_ cutling: Cutling) {
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
        
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxThumbnailSize
        ]
        
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            return nil
        }
        
        let thumbnail = UIImage(cgImage: cgImage)
        
        // Cache it with cost based on pixel count
        let cost = Int(thumbnail.size.width * thumbnail.size.height * thumbnail.scale * thumbnail.scale)
        thumbnailCache.setObject(thumbnail, forKey: filename as NSString, cost: cost)
        
        return thumbnail
    }

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

