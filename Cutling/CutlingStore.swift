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
private let snippetsKey = "savedCutlings"

class CutlingStore: ObservableObject {
    static let shared = CutlingStore()

    @Published var snippets: [Cutling] = []

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
        let notificationName = "com.matsuokengo.Cutling.snippetsChanged" as CFString
        
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
        guard let data = defaults.data(forKey: snippetsKey) else {
            // Data was deleted
            if !snippets.isEmpty {
                snippets = []
            }
            return
        }
        
        // Only reload if the data actually changed
        if data != lastLoadedData {
            lastLoadedData = data
            if let decoded = try? JSONDecoder().decode([Cutling].self, from: data) {
                DispatchQueue.main.async {
                    self.snippets = decoded
                    print("🔄 Reloaded \(decoded.count) snippets from shared storage")
                }
            }
        }
    }

    // MARK: - CRUD

    func load() {
        guard let data = defaults.data(forKey: snippetsKey),
              let decoded = try? JSONDecoder().decode([Cutling].self, from: data)
        else { 
            lastLoadedData = nil
            return 
        }
        lastLoadedData = data
        snippets = decoded
    }

    func save() {
        guard let encoded = try? JSONEncoder().encode(snippets) else { return }
        lastLoadedData = encoded
        defaults.set(encoded, forKey: snippetsKey)
        
        // Notify other processes (keyboard extension or main app)
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("com.matsuokengo.Cutling.snippetsChanged" as CFString),
            nil,
            nil,
            true
        )
    }

    func add(_ snippet: Cutling) {
        snippets.append(snippet)
        save()
    }

    func update(_ snippet: Cutling) {
        if let i = snippets.firstIndex(where: { $0.id == snippet.id }) {
            snippets[i] = snippet
            save()
        }
    }

    func delete(_ snippet: Cutling) {
        if let filename = snippet.imageFilename {
            deleteImageFile(named: filename)
        }
        snippets.removeAll { $0.id == snippet.id }
        save()
    }

    // MARK: - Image File Management

    @discardableResult
    func saveImageData(_ data: Data, for snippetID: UUID) -> String? {
        let filename = snippetID.uuidString + ".png"
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
        guard snippets.isEmpty else { return }
        snippets = [
            Cutling(name: "Email", value: "email@example.com", icon: "envelope"),
            Cutling(name: "Phone", value: "+1 234 567 8900", icon: "phone"),
            Cutling(name: "Address", value: "123 Main St, Apartment 4A, City, Postal Code, Country", icon: "house"),
        ]
        save()
    }
}
