//
//  CloudKitSyncManager.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 08/03/26.
//

import CloudKit
import Foundation
import os.log

private nonisolated(unsafe) let logger = Logger(subsystem: "com.matsuokengo.Cutling", category: "CloudKitSync")

/// Manages CloudKit synchronization using CKSyncEngine.
/// Designed as an actor to isolate all CloudKit work from the main thread,
/// avoiding the "Publishing changes from background threads" issue.
final actor CloudKitSyncManager {

    // MARK: - Constants

    static let containerID = "iCloud.com.matsuokengo.Cutling"
    static let zoneName = "CutlingZone"
    static let cutlingRecordType = "Cutling"

    // MARK: - Properties

    private let container: CKContainer
    private let store: CutlingStore
    private var _syncEngine: CKSyncEngine?
    private let stateURL: URL
    private let imagesDirectory: URL

    private var syncEngine: CKSyncEngine {
        if _syncEngine == nil {
            initializeSyncEngine()
        }
        return _syncEngine!
    }

    /// Track the last known server record metadata for conflict resolution.
    /// Maps Cutling UUID string → encoded CKRecord system fields.
    private var lastKnownRecordMetadata: [String: Data] = [:]
    private let metadataURL: URL

    // MARK: - Init

    init(store: CutlingStore) {
        self.store = store
        self.container = CKContainer(identifier: Self.containerID)
        self.imagesDirectory = store.imagesDirectory

        // Persist sync engine state and record metadata in the app group container
        let baseURL: URL
        if let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) {
            baseURL = containerURL
        } else {
            baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }

        let syncDir = baseURL.appendingPathComponent("CloudKitSync", isDirectory: true)
        if !FileManager.default.fileExists(atPath: syncDir.path) {
            try? FileManager.default.createDirectory(at: syncDir, withIntermediateDirectories: true)
        }
        self.stateURL = syncDir.appendingPathComponent("SyncEngineState.json")
        self.metadataURL = syncDir.appendingPathComponent("RecordMetadata.json")

        loadRecordMetadata()
    }

    // MARK: - Lifecycle

    func start() {
        _ = syncEngine // Triggers lazy init
        logger.log("CloudKitSyncManager started")
    }

    func stop() {
        _syncEngine = nil
        logger.log("CloudKitSyncManager stopped")
    }

    // MARK: - Engine Init

    private func initializeSyncEngine() {
        let stateSerialization = loadStateSerialization()
        var config = CKSyncEngine.Configuration(
            database: container.privateCloudDatabase,
            stateSerialization: stateSerialization,
            delegate: self
        )
        config.automaticallySync = true
        let engine = CKSyncEngine(config)
        _syncEngine = engine
        logger.log("Initialized CKSyncEngine")
    }

    // MARK: - Public: Enqueue Local Changes

    func enqueueSave(_ cutling: Cutling) {
        let recordID = CKRecord.ID(
            recordName: cutling.id.uuidString,
            zoneID: CKRecordZone.ID(zoneName: Self.zoneName)
        )
        syncEngine.state.add(pendingDatabaseChanges: [
            .saveZone(CKRecordZone(zoneName: Self.zoneName))
        ])
        syncEngine.state.add(pendingRecordZoneChanges: [.saveRecord(recordID)])
    }

    func enqueueDelete(_ cutlingID: UUID) {
        let recordID = CKRecord.ID(
            recordName: cutlingID.uuidString,
            zoneID: CKRecordZone.ID(zoneName: Self.zoneName)
        )
        syncEngine.state.add(pendingRecordZoneChanges: [.deleteRecord(recordID)])
    }

    func enqueueAllCutlings(_ cutlings: [Cutling]) {
        let zoneID = CKRecordZone.ID(zoneName: Self.zoneName)
        syncEngine.state.add(pendingDatabaseChanges: [
            .saveZone(CKRecordZone(zoneName: Self.zoneName))
        ])
        let saves: [CKSyncEngine.PendingRecordZoneChange] = cutlings.map {
            .saveRecord(CKRecord.ID(recordName: $0.id.uuidString, zoneID: zoneID))
        }
        syncEngine.state.add(pendingRecordZoneChanges: saves)
    }

    // MARK: - State Persistence

    private func loadStateSerialization() -> CKSyncEngine.State.Serialization? {
        guard let data = try? Data(contentsOf: stateURL) else { return nil }
        return try? JSONDecoder().decode(CKSyncEngine.State.Serialization.self, from: data)
    }

    private func saveStateSerialization(_ state: CKSyncEngine.State.Serialization) {
        do {
            let data = try JSONEncoder().encode(state)
            try data.write(to: stateURL)
        } catch {
            logger.error("Failed to save engine state: \(error)")
        }
    }

    // MARK: - Record Metadata Persistence

    private func loadRecordMetadata() {
        guard let data = try? Data(contentsOf: metadataURL),
              let decoded = try? JSONDecoder().decode([String: Data].self, from: data) else {
            return
        }
        lastKnownRecordMetadata = decoded
    }

    private func saveRecordMetadata() {
        guard let data = try? JSONEncoder().encode(lastKnownRecordMetadata) else { return }
        try? data.write(to: metadataURL)
    }

    private func setLastKnownRecord(_ record: CKRecord, for id: String) {
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: coder)
        coder.finishEncoding()
        lastKnownRecordMetadata[id] = coder.encodedData
        saveRecordMetadata()
    }

    private func lastKnownRecord(for id: String) -> CKRecord? {
        guard let data = lastKnownRecordMetadata[id] else { return nil }
        guard let coder = try? NSKeyedUnarchiver(forReadingFrom: data) else { return nil }
        coder.requiresSecureCoding = true
        return CKRecord(coder: coder)
    }

    private func removeLastKnownRecord(for id: String) {
        lastKnownRecordMetadata[id] = nil
        saveRecordMetadata()
    }

    // MARK: - Cutling ↔ CKRecord Conversion

    private func record(for cutling: Cutling) -> CKRecord {
        let zoneID = CKRecordZone.ID(zoneName: Self.zoneName)
        let recordID = CKRecord.ID(recordName: cutling.id.uuidString, zoneID: zoneID)

        // Reuse last known server record to include server change tag
        let record = lastKnownRecord(for: cutling.id.uuidString)
            ?? CKRecord(recordType: Self.cutlingRecordType, recordID: recordID)

        record["name"] = cutling.name as CKRecordValue
        record["value"] = cutling.value as CKRecordValue
        record["icon"] = cutling.icon as CKRecordValue
        record["kind"] = cutling.kind.rawValue as CKRecordValue
        record["sortOrder"] = cutling.sortOrder as CKRecordValue
        record["lastModifiedDate"] = cutling.lastModifiedDate as CKRecordValue

        // Image asset
        if cutling.kind == .image, let filename = cutling.imageFilename {
            let imageURL = imagesDirectory.appendingPathComponent(filename)
            if FileManager.default.fileExists(atPath: imageURL.path) {
                record["imageAsset"] = CKAsset(fileURL: imageURL)
            }
        } else {
            record["imageAsset"] = nil
        }

        return record
    }

    private func cutling(from record: CKRecord) -> Cutling? {
        guard let name = record["name"] as? String,
              let value = record["value"] as? String,
              let icon = record["icon"] as? String,
              let kindRaw = record["kind"] as? String,
              let kind = CutlingKind(rawValue: kindRaw) else {
            logger.error("Failed to decode cutling from record \(record.recordID)")
            return nil
        }

        guard let id = UUID(uuidString: record.recordID.recordName) else {
            logger.error("Invalid UUID in record name: \(record.recordID.recordName)")
            return nil
        }

        let sortOrder = record["sortOrder"] as? Int ?? 0
        let lastModified = record["lastModifiedDate"] as? Date ?? (record.modificationDate ?? Date())

        var imageFilename: String? = nil
        if kind == .image, let asset = record["imageAsset"] as? CKAsset, let fileURL = asset.fileURL {
            // Copy asset to local images directory
            let filename = id.uuidString + ".png"
            let destURL = imagesDirectory.appendingPathComponent(filename)
            do {
                if FileManager.default.fileExists(atPath: destURL.path) {
                    try FileManager.default.removeItem(at: destURL)
                }
                try FileManager.default.copyItem(at: fileURL, to: destURL)
                imageFilename = filename
            } catch {
                logger.error("Failed to copy image asset: \(error)")
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
            lastModifiedDate: lastModified
        )
    }

    // MARK: - Apply Remote Changes to Local Store

    private func applyRemoteModifications(_ modifications: [CKDatabase.RecordZoneChange.Modification]) async {
        var currentCutlings = await MainActor.run { store.cutlings }

        for modification in modifications {
            let record = modification.record
            let id = record.recordID.recordName

            setLastKnownRecord(record, for: id)

            guard let remoteCutling = cutling(from: record) else { continue }

            if let idx = currentCutlings.firstIndex(where: { $0.id.uuidString == id }) {
                currentCutlings[idx] = remoteCutling
            } else {
                currentCutlings.append(remoteCutling)
            }
        }

        currentCutlings.sort { $0.sortOrder < $1.sortOrder }

        let updated = currentCutlings
        Task { @MainActor in
            self.store.applyRemoteChanges(updated)
        }
    }

    private func applyRemoteDeletions(_ deletions: [CKDatabase.RecordZoneChange.Deletion]) async {
        let deletedIDs = Set(deletions.map { $0.recordID.recordName })
        var currentCutlings = await MainActor.run { store.cutlings }

        for id in deletedIDs {
            removeLastKnownRecord(for: id)
            if let idx = currentCutlings.firstIndex(where: { $0.id.uuidString == id }) {
                if let filename = currentCutlings[idx].imageFilename {
                    let fileURL = imagesDirectory.appendingPathComponent(filename)
                    try? FileManager.default.removeItem(at: fileURL)
                }
                currentCutlings.remove(at: idx)
            }
        }

        let updated = currentCutlings
        Task { @MainActor in
            self.store.applyRemoteChanges(updated)
        }
    }

    // MARK: - Sync Status

    private func setSyncing(_ value: Bool) {
        Task { @MainActor in
            self.store.isSyncing = value
        }
    }
}

// MARK: - CKSyncEngineDelegate

extension CloudKitSyncManager: CKSyncEngineDelegate {

    nonisolated func handleEvent(_ event: CKSyncEngine.Event, syncEngine: CKSyncEngine) async {
        switch event {

        case .stateUpdate(let stateUpdate):
            await saveStateSerialization(stateUpdate.stateSerialization)

        case .accountChange(let accountChange):
            await handleAccountChange(accountChange)

        case .fetchedDatabaseChanges(let fetched):
            await handleFetchedDatabaseChanges(fetched)

        case .fetchedRecordZoneChanges(let fetched):
            await handleFetchedRecordZoneChanges(fetched)

        case .sentRecordZoneChanges(let sent):
            await handleSentRecordZoneChanges(sent)

        case .sentDatabaseChanges:
            break

        case .willFetchChanges, .willFetchRecordZoneChanges:
            await setSyncing(true)

        case .didFetchRecordZoneChanges:
            break

        case .didFetchChanges:
            await setSyncing(false)

        case .willSendChanges:
            await setSyncing(true)

        case .didSendChanges:
            await setSyncing(false)

        @unknown default:
            logger.info("Unknown sync event: \(event)")
        }
    }

    nonisolated func nextRecordZoneChangeBatch(
        _ context: CKSyncEngine.SendChangesContext,
        syncEngine: CKSyncEngine
    ) async -> CKSyncEngine.RecordZoneChangeBatch? {
        let scope = context.options.scope
        let pendingChanges = syncEngine.state.pendingRecordZoneChanges.filter { scope.contains($0) }

        return await CKSyncEngine.RecordZoneChangeBatch(pendingChanges: pendingChanges) { recordID in
            await self.recordForPendingChange(recordID)
        }
    }

    // MARK: - Internal Event Handlers

    private func recordForPendingChange(_ recordID: CKRecord.ID) async -> CKRecord? {
        let id = recordID.recordName
        let cutlings = await MainActor.run { store.cutlings }
        if let cutling = cutlings.first(where: { $0.id.uuidString == id }) {
            return record(for: cutling)
        } else {
            syncEngine.state.remove(pendingRecordZoneChanges: [.saveRecord(recordID)])
            return nil
        }
    }

    private func handleAccountChange(_ event: CKSyncEngine.Event.AccountChange) async {
        switch event.changeType {
        case .signIn:
            // Re-upload everything
            let cutlings = await MainActor.run { store.cutlings }
            enqueueAllCutlings(cutlings)

        case .switchAccounts:
            // Clear cloud metadata, keep local data
            lastKnownRecordMetadata.removeAll()
            saveRecordMetadata()

        case .signOut:
            lastKnownRecordMetadata.removeAll()
            saveRecordMetadata()

        @unknown default:
            logger.info("Unknown account change: \(event)")
        }
    }

    private func handleFetchedDatabaseChanges(_ event: CKSyncEngine.Event.FetchedDatabaseChanges) {
        for deletion in event.deletions {
            if deletion.zoneID.zoneName == Self.zoneName {
                lastKnownRecordMetadata.removeAll()
                saveRecordMetadata()
                Task { @MainActor in
                    self.store.applyRemoteChanges([])
                }
            }
        }
    }

    private func handleFetchedRecordZoneChanges(_ event: CKSyncEngine.Event.FetchedRecordZoneChanges) async {
        if !event.modifications.isEmpty {
            await applyRemoteModifications(event.modifications)
        }
        if !event.deletions.isEmpty {
            await applyRemoteDeletions(event.deletions)
        }
    }

    private func handleSentRecordZoneChanges(_ event: CKSyncEngine.Event.SentRecordZoneChanges) async {
        var newPendingZoneChanges = [CKSyncEngine.PendingRecordZoneChange]()
        var newPendingDBChanges = [CKSyncEngine.PendingDatabaseChange]()

        // Handle successful saves
        for savedRecord in event.savedRecords {
            let id = savedRecord.recordID.recordName
            setLastKnownRecord(savedRecord, for: id)
        }

        // Handle failed saves
        for failure in event.failedRecordSaves {
            let failedRecord = failure.record
            let id = failedRecord.recordID.recordName

            switch failure.error.code {
            case .serverRecordChanged:
                // Conflict: merge using last-writer-wins
                guard let serverRecord = failure.error.serverRecord else {
                    logger.error("No server record for conflict on \(id)")
                    continue
                }
                if let remoteCutling = cutling(from: serverRecord) {
                    let cutlings = await MainActor.run { store.cutlings }
                    if let local = cutlings.first(where: { $0.id.uuidString == id }) {
                        // Last-writer-wins: pick the one with newer lastModifiedDate
                        if local.lastModifiedDate > remoteCutling.lastModifiedDate {
                            // Local is newer — re-upload with server's change tag
                            setLastKnownRecord(serverRecord, for: id)
                            newPendingZoneChanges.append(.saveRecord(failedRecord.recordID))
                        } else {
                            // Server is newer — accept remote
                            setLastKnownRecord(serverRecord, for: id)
                            let updated = remoteCutling
                            var current = cutlings
                            if let idx = current.firstIndex(where: { $0.id.uuidString == id }) {
                                current[idx] = updated
                            }
                            let final_ = current
                            Task { @MainActor in
                                self.store.applyRemoteChanges(final_)
                            }
                        }
                    } else {
                        setLastKnownRecord(serverRecord, for: id)
                    }
                }

            case .zoneNotFound:
                let zone = CKRecordZone(zoneID: failedRecord.recordID.zoneID)
                newPendingDBChanges.append(.saveZone(zone))
                newPendingZoneChanges.append(.saveRecord(failedRecord.recordID))
                removeLastKnownRecord(for: id)

            case .unknownItem:
                newPendingZoneChanges.append(.saveRecord(failedRecord.recordID))
                removeLastKnownRecord(for: id)

            case .networkFailure, .networkUnavailable, .zoneBusy, .serviceUnavailable,
                 .notAuthenticated, .operationCancelled:
                // Transient — CKSyncEngine auto-retries these
                logger.debug("Retryable error for \(id): \(failure.error)")

            default:
                logger.fault("Unhandled error saving \(id): \(failure.error)")
            }
        }

        if !newPendingDBChanges.isEmpty {
            syncEngine.state.add(pendingDatabaseChanges: newPendingDBChanges)
        }
        if !newPendingZoneChanges.isEmpty {
            syncEngine.state.add(pendingRecordZoneChanges: newPendingZoneChanges)
        }
    }
}
