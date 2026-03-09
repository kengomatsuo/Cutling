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

    /// Upload a cutling directly to CloudKit from the keyboard extension.
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
}
