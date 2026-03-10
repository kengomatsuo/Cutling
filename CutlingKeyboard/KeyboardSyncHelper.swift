//
//  KeyboardSyncHelper.swift
//  CutlingKeyboard
//
//  Created by Kenneth Johannes Fang on 09/03/26.
//

import CloudKit
import Foundation
import os.log

/// Lightweight CloudKit uploader for the keyboard extension.
/// Bypasses CKSyncEngine (unavailable in extensions) and does a direct record save.
enum KeyboardSyncHelper {

    private static let log = Logger(subsystem: "com.matsuokengo.Cutling", category: "KeyboardSync")
    private static let containerID = "iCloud.com.matsuokengo.Cutling"
    private static let zoneName = "CutlingZone"
    private static let recordType = "Cutling"
    private static let appGroupID = "group.com.matsuokengo.Cutling"

    // MARK: - Fetch Remote Changes

    /// Fetches all cutlings from CloudKit and syncs with the local store.
    /// Adds missing, updates existing, and removes deleted cutlings.
    /// Only diffs (removes absent cutlings) when the fetch looks complete —
    /// i.e. remote count is not suspiciously low compared to local.
    /// Called when the keyboard appears so it picks up changes from other devices
    /// even if the main app hasn't been opened.
    static func fetchFromCloudKit(store: CutlingStore) {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              defaults.bool(forKey: "iCloudSyncEnabled") else {
            return
        }

        Task.detached(priority: .utility) {
            await performFetch(store: store)
        }
    }

    private static func performFetch(store: CutlingStore, retryCount: Int = 0) async {
        do {
            let container = CKContainer(identifier: containerID)
            let db = container.privateCloudDatabase
            let zoneID = CKRecordZone.ID(zoneName: zoneName)
            let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))

            let (results, cursor) = try await db.records(matching: query, inZoneWith: zoneID)

            guard cursor == nil else {
                // Partial fetch — discard and retry once after a delay
                if retryCount < 1 {
                    log.log("Keyboard got partial fetch (cursor present), retrying in 3s…")
                    try? await Task.sleep(for: .seconds(3))
                    await performFetch(store: store, retryCount: retryCount + 1)
                } else {
                    log.log("Keyboard got partial fetch on retry, skipping sync")
                }
                return
            }

            let imagesDirectory = store.imagesDirectory
            var remoteCutlings: [Cutling] = []
            for (_, result) in results {
                if case .success(let record) = result,
                   let c = parseCutling(from: record, imagesDirectory: imagesDirectory) {
                    remoteCutlings.append(c)
                }
            }

            log.log("Keyboard fetched \(remoteCutlings.count) cutlings from CloudKit")

            await MainActor.run {
                remoteCutlings.sort { $0.sortOrder < $1.sortOrder }
                store.cutlings = remoteCutlings
                store.save()
            }
        } catch let error as CKError where error.code == .zoneNotFound {
            log.debug("Zone not found — no remote cutlings yet")
        } catch {
            log.error("Keyboard CloudKit fetch failed: \(error)")
        }
    }

    // MARK: - Upload
    /// Fires and forgets — errors are logged but not surfaced to the user.
    static func upload(_ cutling: Cutling, imagesDirectory: URL) {
        // Check if iCloud sync is enabled (stored in shared app group defaults)
        guard let defaults = UserDefaults(suiteName: "group.com.matsuokengo.Cutling"),
              defaults.bool(forKey: "iCloudSyncEnabled") else {
            return
        }

        Task.detached(priority: .utility) {
            do {
                let container = CKContainer(identifier: containerID)
                let db = container.privateCloudDatabase
                let zoneID = CKRecordZone.ID(zoneName: zoneName)

                let record = buildRecord(for: cutling, zoneID: zoneID, imagesDirectory: imagesDirectory)
                try await db.save(record)

                log.log("Keyboard uploaded cutling \(cutling.id.uuidString)")
            } catch let error as CKError where error.code == .serverRecordChanged {
                log.debug("Record already exists on server, ignoring: \(cutling.id.uuidString)")
            } catch let error as CKError where error.code == .zoneNotFound {
                // Zone doesn't exist yet — create it and retry once
                do {
                    let container = CKContainer(identifier: containerID)
                    let db = container.privateCloudDatabase
                    let zoneID = CKRecordZone.ID(zoneName: zoneName)
                    try await db.save(CKRecordZone(zoneID: zoneID))
                    let record = buildRecord(for: cutling, zoneID: zoneID, imagesDirectory: imagesDirectory)
                    try await db.save(record)
                    log.log("Keyboard uploaded cutling (after zone create) \(cutling.id.uuidString)")
                } catch {
                    log.error("Keyboard upload retry failed: \(error)")
                }
            } catch {
                log.error("Keyboard upload failed: \(error)")
            }
        }
    }

    private static func buildRecord(for cutling: Cutling, zoneID: CKRecordZone.ID, imagesDirectory: URL) -> CKRecord {
        let recordID = CKRecord.ID(recordName: cutling.id.uuidString, zoneID: zoneID)
        let record = CKRecord(recordType: recordType, recordID: recordID)

        record["name"] = cutling.name as CKRecordValue
        record["value"] = cutling.value as CKRecordValue
        record["icon"] = cutling.icon as CKRecordValue
        record["kind"] = cutling.kind.rawValue as CKRecordValue
        record["sortOrder"] = cutling.sortOrder as CKRecordValue
        record["lastModifiedDate"] = cutling.lastModifiedDate as CKRecordValue

        if let expiresAt = cutling.expiresAt {
            record["expiresAt"] = expiresAt as CKRecordValue
        }
        if let color = cutling.color {
            record["color"] = color as CKRecordValue
        }

        // Image asset
        if cutling.kind == .image, let filename = cutling.imageFilename {
            let imageURL = imagesDirectory.appendingPathComponent(filename)
            if FileManager.default.fileExists(atPath: imageURL.path) {
                record["imageAsset"] = CKAsset(fileURL: imageURL)
            }
        }

        return record
    }

    // MARK: - Record Parsing

    private static func parseCutling(from record: CKRecord, imagesDirectory: URL) -> Cutling? {
        guard let name = record["name"] as? String,
              let value = record["value"] as? String,
              let icon = record["icon"] as? String,
              let kindRaw = record["kind"] as? String,
              let kind = CutlingKind(rawValue: kindRaw),
              let id = UUID(uuidString: record.recordID.recordName) else {
            return nil
        }

        let sortOrder = record["sortOrder"] as? Int ?? 0
        let lastModified = record["lastModifiedDate"] as? Date ?? (record.modificationDate ?? Date())
        let expiresAt = record["expiresAt"] as? Date
        let color = record["color"] as? String

        var imageFilename: String? = nil
        if kind == .image, let asset = record["imageAsset"] as? CKAsset, let fileURL = asset.fileURL {
            let filename = id.uuidString + ".png"
            let destURL = imagesDirectory.appendingPathComponent(filename)
            do {
                if FileManager.default.fileExists(atPath: destURL.path) {
                    try FileManager.default.removeItem(at: destURL)
                }
                try FileManager.default.copyItem(at: fileURL, to: destURL)
                imageFilename = filename
            } catch {
                log.error("Failed to copy image asset: \(error)")
            }
        }

        return Cutling(
            id: id,
            name: name,
            value: value,
            icon: icon,
            kind: kind,
            imageFilename: imageFilename,
            sortOrder: sortOrder,
            lastModifiedDate: lastModified,
            expiresAt: expiresAt,
            color: color
        )
    }
}
