//
//  CloudSyncManager.swift
//  Cutling
//
//  Manages iCloud sync for image cutlings using CKSyncEngine.
//  Text cutlings are synced via NSUbiquitousKeyValueStore in CutlingStore.
//
//  Only the main app should instantiate this manager. The keyboard extension
//  reads synced data from the shared App Group container — it does NOT run
//  its own CKSyncEngine instance. Running CKSyncEngine from both the app
//  and an extension simultaneously can cause data corruption because you
//  don't control the extension's lifecycle.
//

import Foundation
import CloudKit
import os.log

// MARK: - ImageCutlingRecord

/// A lightweight representation of an image cutling for sync purposes.
struct ImageCutlingRecord {
    let cutlingID: UUID
    let name: String
    let icon: String
    let imageFilename: String
    /// Set when receiving from the server — the temp file URL of the downloaded asset.
    var downloadedAssetURL: URL?
}

// MARK: - CloudSyncManager

/// Syncs image cutlings to iCloud using CKSyncEngine (iOS 17+ / macOS 14+).
/// Each image cutling becomes a CKRecord with metadata fields and a CKAsset
/// for the actual image file.
@available(iOS 17.0, macOS 14.0, *)
final class CloudSyncManager: NSObject, CKSyncEngineDelegate, @unchecked Sendable {
    
    // MARK: - Constants
    
    static let zoneName = "CutlingImages"
    static let recordType = "ImageCutling"
    
    private static let stateSerializationKey = "CKSyncEngineState"
    
    // MARK: - Properties
    
    private let container: CKContainer
    private let database: CKDatabase
    let zoneID: CKRecordZone.ID
    private let logger = Logger(subsystem: "com.matsuokengo.Cutling", category: "CloudSync")
    
    /// The CKSyncEngine instance — lazily initialized so `self` is available as delegate.
    private lazy var syncEngine: CKSyncEngine = {
        let config = CKSyncEngine.Configuration(
            database: database,
            stateSerialization: loadStateSerialization(),
            delegate: self
        )
        return CKSyncEngine(config)
    }()
    
    /// Callback to notify CutlingStore when remote image cutlings arrive or are deleted.
    var onRemoteImageChange: (([ImageCutlingRecord], [CKRecord.ID]) -> Void)?
    
    /// Maps cutling UUID -> CKRecord.ID for quick lookup.
    var cutlingIDToRecordID: [UUID: CKRecord.ID] = [:]
    
    /// Stores the last known server records for conflict resolution.
    var lastKnownRecords: [CKRecord.ID: CKRecord] = [:]
    
    /// Local cache of image cutling data to send.
    var pendingImageData: [CKRecord.ID: ImageCutlingRecord] = [:]
    
    private let defaults: UserDefaults
    
    // MARK: - Init
    
    override init() {
        self.container = CKContainer(identifier: "iCloud.com.matsuokengo.Cutling")
        self.database = container.privateCloudDatabase
        self.zoneID = CKRecordZone.ID(zoneName: Self.zoneName)
        
        if let groupDefaults = UserDefaults(suiteName: appGroupID) {
            self.defaults = groupDefaults
        } else {
            self.defaults = .standard
        }
        
        super.init()
        
        // Load cutling ID mapping from disk
        loadRecordIDMapping()
        
        // Force lazy init of syncEngine so it starts listening for changes
        _ = syncEngine
        
        logger.info("CloudSyncManager initialized")
    }
    
    // MARK: - Public API
    
    /// Queue a new or updated image cutling for upload.
    func queueImageUpload(_ record: ImageCutlingRecord) {
        let recordID = recordID(for: record.cutlingID)
        cutlingIDToRecordID[record.cutlingID] = recordID
        pendingImageData[recordID] = record
        
        syncEngine.state.add(pendingRecordZoneChanges: [
            .saveRecord(recordID)
        ])
        
        saveRecordIDMapping()
        logger.info("Queued image upload for cutling \(record.cutlingID)")
    }
    
    /// Queue an image cutling for deletion from iCloud.
    func queueImageDeletion(cutlingID: UUID) {
        guard let recordID = cutlingIDToRecordID[cutlingID] else {
            logger.warning("No record ID found for cutling \(cutlingID) — skipping deletion")
            return
        }
        
        cutlingIDToRecordID.removeValue(forKey: cutlingID)
        pendingImageData.removeValue(forKey: recordID)
        lastKnownRecords.removeValue(forKey: recordID)
        
        syncEngine.state.add(pendingRecordZoneChanges: [
            .deleteRecord(recordID)
        ])
        
        saveRecordIDMapping()
        logger.info("Queued image deletion for cutling \(cutlingID)")
    }
    
    /// Force a fetch of changes from the server.
    func fetchChanges() async throws {
        try await syncEngine.fetchChanges()
    }
    
    // MARK: - Record ID Helpers
    
    private func recordID(for cutlingID: UUID) -> CKRecord.ID {
        if let existing = cutlingIDToRecordID[cutlingID] {
            return existing
        }
        let id = CKRecord.ID(recordName: cutlingID.uuidString, zoneID: zoneID)
        cutlingIDToRecordID[cutlingID] = id
        return id
    }
    
    func cutlingID(for recordID: CKRecord.ID) -> UUID? {
        UUID(uuidString: recordID.recordName)
    }
    
    // MARK: - State Persistence
    
    private func loadStateSerialization() -> CKSyncEngine.State.Serialization? {
        guard let data = defaults.data(forKey: Self.stateSerializationKey) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(
            ofClass: CKSyncEngine.State.Serialization.self,
            from: data
        )
    }
    
    func saveStateSerialization(_ serialization: CKSyncEngine.State.Serialization) {
        if let data = try? NSKeyedArchiver.archivedData(
            withRootObject: serialization,
            requiringSecureCoding: true
        ) {
            defaults.set(data, forKey: Self.stateSerializationKey)
        }
    }
    
    // MARK: - Record ID Mapping Persistence
    
    private static let mappingKey = "CKRecordIDMapping"
    
    func saveRecordIDMapping() {
        var mapping: [String: String] = [:]
        for (cutlingID, recordID) in cutlingIDToRecordID {
            mapping[cutlingID.uuidString] = recordID.recordName
        }
        defaults.set(mapping, forKey: Self.mappingKey)
    }
    
    private func loadRecordIDMapping() {
        guard let mapping = defaults.dictionary(forKey: Self.mappingKey) as? [String: String] else { return }
        for (cutlingUUIDString, recordName) in mapping {
            if let uuid = UUID(uuidString: cutlingUUIDString) {
                cutlingIDToRecordID[uuid] = CKRecord.ID(recordName: recordName, zoneID: zoneID)
            }
        }
    }
    
    // MARK: - Record Conversion
    
    func populateRecord(_ record: CKRecord, from imageRecord: ImageCutlingRecord, imagesDirectory: URL) {
        record["name"] = imageRecord.name as CKRecordValue
        record["icon"] = imageRecord.icon as CKRecordValue
        record["cutlingID"] = imageRecord.cutlingID.uuidString as CKRecordValue
        record["imageFilename"] = imageRecord.imageFilename as CKRecordValue
        
        // Attach image as CKAsset
        let imageURL = imagesDirectory.appendingPathComponent(imageRecord.imageFilename)
        if FileManager.default.fileExists(atPath: imageURL.path) {
            record["imageAsset"] = CKAsset(fileURL: imageURL)
        }
    }
    
    func parseRecord(_ record: CKRecord) -> ImageCutlingRecord? {
        guard let name = record["name"] as? String,
              let icon = record["icon"] as? String,
              let cutlingIDString = record["cutlingID"] as? String,
              let cutlingID = UUID(uuidString: cutlingIDString),
              let imageFilename = record["imageFilename"] as? String else {
            return nil
        }
        
        let assetURL = (record["imageAsset"] as? CKAsset)?.fileURL
        
        return ImageCutlingRecord(
            cutlingID: cutlingID,
            name: name,
            icon: icon,
            imageFilename: imageFilename,
            downloadedAssetURL: assetURL
        )
    }
    
    // MARK: - CKSyncEngineDelegate
    
    func handleEvent(_ event: CKSyncEngine.Event, syncEngine: CKSyncEngine) {
        switch event {
            
        case .stateUpdate(let stateUpdate):
            saveStateSerialization(stateUpdate.stateSerialization)
            
        case .accountChange(let accountChange):
            handleAccountChange(accountChange)
            
        case .fetchedDatabaseChanges(let fetchedChanges):
            handleFetchedDatabaseChanges(fetchedChanges)
            
        case .fetchedRecordZoneChanges(let fetchedChanges):
            handleFetchedRecordZoneChanges(fetchedChanges)
            
        case .sentRecordZoneChanges(let sentChanges):
            handleSentRecordZoneChanges(sentChanges)
            
        case .willFetchChanges, .willFetchRecordZoneChanges, .didFetchRecordZoneChanges,
             .didFetchChanges, .willSendChanges, .didSendChanges:
            break
            
        @unknown default:
            logger.warning("Unknown CKSyncEngine event: \(String(describing: event))")
        }
    }
    
    func nextRecordZoneChangeBatch(
        _ context: CKSyncEngine.SendChangesContext,
        syncEngine: CKSyncEngine
    ) async -> CKSyncEngine.RecordZoneChangeBatch? {
        let scope = context.options.scope
        let pendingChanges = syncEngine.state.pendingRecordZoneChanges.filter { change in
            scope.contains(change)
        }
        
        guard !pendingChanges.isEmpty else { return nil }
        
        // Get the images directory from the App Group container
        let imagesDirectory: URL
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            imagesDirectory = containerURL.appendingPathComponent("Images", isDirectory: true)
        } else {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            imagesDirectory = docs.appendingPathComponent("Images", isDirectory: true)
        }
        
        return CKSyncEngine.RecordZoneChangeBatch(pendingChanges: pendingChanges) { [self] recordID in
            if let imageRecord = pendingImageData[recordID] {
                let record = lastKnownRecords[recordID] ?? CKRecord(recordType: CloudSyncManager.recordType, recordID: recordID)
                populateRecord(record, from: imageRecord, imagesDirectory: imagesDirectory)
                return record
            }
            return nil
        }
    }
    
    // MARK: - Event Handlers
    
    private func handleAccountChange(_ change: CKSyncEngine.Event.AccountChange) {
        switch change.changeType {
        case .signIn:
            logger.info("iCloud account signed in")
        case .signOut:
            logger.info("iCloud account signed out — local data preserved")
        case .switchAccounts:
            logger.info("iCloud account switched")
        @unknown default:
            break
        }
    }
    
    private func handleFetchedDatabaseChanges(_ changes: CKSyncEngine.Event.FetchedDatabaseChanges) {
        for deletion in changes.deletions {
            if deletion.zoneID == zoneID {
                logger.warning("Our record zone was deleted from the server")
            }
        }
    }
    
    private func handleFetchedRecordZoneChanges(_ changes: CKSyncEngine.Event.FetchedRecordZoneChanges) {
        var receivedRecords: [ImageCutlingRecord] = []
        var deletedRecordIDs: [CKRecord.ID] = []
        
        // Process modifications
        for modification in changes.modifications {
            let record = modification.record
            lastKnownRecords[record.recordID] = record
            
            if let imageRecord = parseRecord(record) {
                cutlingIDToRecordID[imageRecord.cutlingID] = record.recordID
                receivedRecords.append(imageRecord)
                logger.info("Received image cutling from cloud: \(imageRecord.name)")
            }
        }
        
        // Process deletions
        for deletion in changes.deletions {
            let recordID = deletion.recordID
            lastKnownRecords.removeValue(forKey: recordID)
            deletedRecordIDs.append(recordID)
            
            if let cutlingID = cutlingID(for: recordID) {
                cutlingIDToRecordID.removeValue(forKey: cutlingID)
            }
            logger.info("Image cutling deleted from cloud: \(recordID.recordName)")
        }
        
        saveRecordIDMapping()
        
        if !receivedRecords.isEmpty || !deletedRecordIDs.isEmpty {
            onRemoteImageChange?(receivedRecords, deletedRecordIDs)
        }
    }
    
    private func handleSentRecordZoneChanges(_ changes: CKSyncEngine.Event.SentRecordZoneChanges) {
        // Handle successful saves
        for savedRecord in changes.savedRecords {
            lastKnownRecords[savedRecord.recordID] = savedRecord
            pendingImageData.removeValue(forKey: savedRecord.recordID)
            logger.info("Successfully synced image cutling: \(savedRecord.recordID.recordName)")
        }
        
        // Handle failures
        for failedSave in changes.failedRecordSaves {
            let recordID = failedSave.record.recordID
            let error = failedSave.error
            
            switch error.code {
            case .serverRecordChanged:
                // Conflict — the server has a newer version.
                // Accept the server's version for simplicity.
                if let serverRecord = error.serverRecord {
                    lastKnownRecords[recordID] = serverRecord
                    if let imageRecord = parseRecord(serverRecord) {
                        onRemoteImageChange?([imageRecord], [])
                    }
                }
                logger.warning("Conflict for \(recordID.recordName) — accepted server version")
                
            case .zoneNotFound:
                // CKSyncEngine handles zone creation automatically
                logger.info("Zone not found — CKSyncEngine will create it")
                
            default:
                logger.error("Failed to save record \(recordID.recordName): \(error.localizedDescription)")
            }
        }
    }
}
