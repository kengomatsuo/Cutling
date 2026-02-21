//
//  CutlingStore.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import Foundation
import Combine

#if os(iOS)
import UIKit
#else
import AppKit
#endif

let appGroupID = "group.com.matsuokengo.Cutling"
private let cutlingsKey = "savedCutlings"

class CutlingStore: ObservableObject {
    static let shared = CutlingStore()

    @Published var cutlings: [Cutling] = []

    private let defaults: UserDefaults
    private let imagesDirectory: URL
    private var cancellables = Set<AnyCancellable>()

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

    func deleteImageFile(named filename: String) {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
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
