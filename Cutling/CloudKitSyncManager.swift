//
//  CloudKitSyncManager.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 08/03/26.
//

import CloudKit
import Foundation
import os.log

/// Manages CloudKit synchronization using CKSyncEngine.
/// Designed as an actor to isolate all CloudKit work from the main thread,
/// avoiding the "Publishing changes from background threads" issue.
final actor CloudKitSyncManager {

    // MARK: - Constants

    private static let log = Logger(subsystem: "com.matsuokengo.Cutling", category: "CloudKitSync")
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
            forSecurityApplicationGroupIdentifier: "group.com.matsuokengo.Cutling"
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
    }

    /// Must be called after init to load persisted metadata.
    private func ensureMetadataLoaded() {
        if lastKnownRecordMetadata.isEmpty {
            loadRecordMetadata()
        }
    }

    // MARK: - KVS Poke (fast cross-device notification)

    private static let kvsPokeKey = "lastChangeTimestamp"
    private var kvsObserver: NSObjectProtocol?

    private func startKVSObserver() {
        Task { @MainActor in
            let kvs = NSUbiquitousKeyValueStore.default
            kvs.synchronize()
            let observer = NotificationCenter.default.addObserver(
                forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: kvs,
                queue: .main
            ) { [weak self] notification in
                print("📡 KVS didChangeExternally received")
                guard let self else { return }
                Task {
                    await self.directFetchFromCloudKit()
                }
            }
            await self.setKVSObserver(observer)
            print("📡 KVS observer registered")
        }
    }

    private func setKVSObserver(_ observer: NSObjectProtocol) {
        kvsObserver = observer
    }

    private func stopKVSObserver() {
        if let obs = kvsObserver {
            NotificationCenter.default.removeObserver(obs)
            kvsObserver = nil
        }
    }

    /// Notify other devices that we made a change, via KVS (faster than waiting for CK silent push).
    private func pokeOtherDevices() {
        Task { @MainActor in
            let kvs = NSUbiquitousKeyValueStore.default
            kvs.set(Date().timeIntervalSince1970, forKey: CloudKitSyncManager.kvsPokeKey)
            kvs.synchronize()
            print("📡 KVS poke sent: \(Date())")
        }
    }

    // MARK: - Lifecycle

    func start() {
        ensureMetadataLoaded()
        _ = syncEngine // Triggers lazy init
        startKVSObserver()
        Self.log.log("CloudKitSyncManager started")

        // Upload any local cutlings the keyboard extension added while we weren't running
        Task { await uploadUnsyncedCutlings() }
    }

    func stop() {
        stopKVSObserver()
        _syncEngine = nil
        Self.log.log("CloudKitSyncManager stopped")
    }

    /// Manually trigger a fetch — call on app foreground for faster sync.
    func fetchChanges() async {
        guard _syncEngine != nil else { return }
        try? await syncEngine.fetchChanges()
    }

    /// Finds local cutlings never uploaded to CloudKit and enqueues them.
    private func uploadUnsyncedCutlings() async {
        ensureMetadataLoaded()
        let localCutlings = await MainActor.run { store.cutlings }
        let syncedIDs = Set(lastKnownRecordMetadata.keys)
        let unsynced = localCutlings.filter { !syncedIDs.contains($0.id.uuidString) }

        guard !unsynced.isEmpty else { return }
        Self.log.log("Found \(unsynced.count) unsynced cutlings — enqueuing upload")

        syncEngine.state.add(pendingDatabaseChanges: [
            .saveZone(CKRecordZone(zoneName: Self.zoneName))
        ])
        for c in unsynced {
            enqueueSave(c)
        }
    }

    /// Full bidirectional sync for BGAppRefreshTask / BGProcessingTask.
    func performBackgroundSync() async {
        Self.log.log("Background sync: starting")

        // 1. Reload store to pick up keyboard-written changes
        await MainActor.run { store.load() }

        // 2. Upload cutlings that have never been synced to CloudKit
        await uploadUnsyncedCutlings()

        // 3. Send pending changes (uploads + any explicitly-enqueued deletes)
        try? await syncEngine.sendChanges()

        // 4. Fetch remote changes
        try? await syncEngine.fetchChanges()

        Self.log.log("Background sync: completed")
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
        Self.log.log("Initialized CKSyncEngine")
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

    /// Direct CloudKit query, bypassing CKSyncEngine (for KVS-triggered fast sync).
    /// Merges remote records INTO local — adds missing and updates existing, but NEVER deletes.
    /// Deletions are only handled through CKSyncEngine's proper change-tracking mechanism.
    private func directFetchFromCloudKit() async {
        print("📡 directFetchFromCloudKit: starting")
        setSyncing(true)
        let zoneID = CKRecordZone.ID(zoneName: Self.zoneName)
        let query = CKQuery(recordType: Self.cutlingRecordType, predicate: NSPredicate(value: true))
        
        do {
            let (results, _) = try await container.privateCloudDatabase.records(
                matching: query,
                inZoneWith: zoneID
            )
            
            var remoteCutlings: [Cutling] = []
            for (_, result) in results {
                if case .success(let record) = result {
                    setLastKnownRecord(record, for: record.recordID.recordName)
                    if let c = cutling(from: record) {
                        remoteCutlings.append(c)
                    }
                }
            }
            print("📡 directFetchFromCloudKit: got \(remoteCutlings.count) cutlings")
            
            // Merge remote into local: add missing, update existing, never delete.
            // This prevents data loss from partial query results or race conditions.
            let remoteByID = Dictionary(remoteCutlings.map { ($0.id.uuidString, $0) }, uniquingKeysWith: { _, last in last })
            
            await MainActor.run {
                var local = self.store.cutlings
                let localIDs = Set(local.map { $0.id.uuidString })
                
                // Update existing cutlings with remote data
                for i in local.indices {
                    if let remote = remoteByID[local[i].id.uuidString] {
                        local[i] = remote
                    }
                }
                
                // Add cutlings that exist remotely but not locally
                for (id, remote) in remoteByID where !localIDs.contains(id) {
                    local.append(remote)
                }
                
                local.sort { $0.sortOrder < $1.sortOrder }
                self.store.applyRemoteChanges(local)
            }
        } catch {
            Self.log.error("directFetchFromCloudKit failed: \(error)")
        }
        setSyncing(false)
    }

    private func loadStateSerialization() -> CKSyncEngine.State.Serialization? {
        guard let data = try? Data(contentsOf: stateURL) else { return nil }
        return try? JSONDecoder().decode(CKSyncEngine.State.Serialization.self, from: data)
    }

    private func saveStateSerialization(_ state: CKSyncEngine.State.Serialization) {
        do {
            let data = try JSONEncoder().encode(state)
            try data.write(to: stateURL)
        } catch {
            Self.log.error("Failed to save engine state: \(error)")
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
        if let expiresAt = cutling.expiresAt {
            record["expiresAt"] = expiresAt as CKRecordValue
        } else {
            record["expiresAt"] = nil
        }
        if let color = cutling.color {
            record["color"] = color as CKRecordValue
        } else {
            record["color"] = nil
        }

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
            Self.log.error("Failed to decode cutling from record \(record.recordID)")
            return nil
        }

        guard let id = UUID(uuidString: record.recordID.recordName) else {
            Self.log.error("Invalid UUID in record name: \(record.recordID.recordName)")
            return nil
        }

        let sortOrder = record["sortOrder"] as? Int ?? 0
        let lastModified = record["lastModifiedDate"] as? Date ?? (record.modificationDate ?? Date())
        let expiresAt = record["expiresAt"] as? Date
        let color = record["color"] as? String

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
                Self.log.error("Failed to copy image asset: \(error)")
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

    // MARK: - Apply Remote Changes to Local Store

    private func applyRemoteChanges(
        modifications: [CKDatabase.RecordZoneChange.Modification],
        deletions: [CKDatabase.RecordZoneChange.Deletion]
    ) async {
        print("📡 Applying \(modifications.count) remote modifications, \(deletions.count) deletions")

        // Process modifications: decode records and update metadata (actor-isolated work)
        var modifiedCutlings: [(String, Cutling)] = []
        for modification in modifications {
            let record = modification.record
            let id = record.recordID.recordName
            setLastKnownRecord(record, for: id)
            if let c = cutling(from: record) {
                modifiedCutlings.append((id, c))
            }
        }

        // Process deletions: clean up metadata and image files (actor-isolated work)
        let deletedIDs = Set(deletions.map { $0.recordID.recordName })
        for id in deletedIDs {
            removeLastKnownRecord(for: id)
        }

        // Apply all changes atomically on MainActor to prevent races
        let mods = modifiedCutlings
        let dels = deletedIDs
        await MainActor.run {
            var current = self.store.cutlings

            // Apply modifications (add or update)
            for (id, remoteCutling) in mods {
                if let idx = current.firstIndex(where: { $0.id.uuidString == id }) {
                    current[idx] = remoteCutling
                } else {
                    current.append(remoteCutling)
                }
            }

            // Apply deletions — move to recently deleted instead of permanent removal
            for id in dels {
                if let idx = current.firstIndex(where: { $0.id.uuidString == id }) {
                    let deleted = DeletedCutling(cutling: current[idx], deletedAt: Date())
                    self.store.recentlyDeleted.insert(deleted, at: 0)
                    current.remove(at: idx)
                }
            }

            current.sort { $0.sortOrder < $1.sortOrder }
            self.store.applyRemoteChanges(current)
            self.store.saveRecentlyDeletedFromSync()
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
        print("📡 CKSyncEngine event: \(event)")
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
            Self.log.info("Unknown sync event: \(event)")
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
            Self.log.info("Unknown account change: \(event)")
        }
    }

    private func handleFetchedDatabaseChanges(_ event: CKSyncEngine.Event.FetchedDatabaseChanges) {
        for deletion in event.deletions {
            if deletion.zoneID.zoneName == Self.zoneName {
                Self.log.log("Zone deleted — clearing metadata but preserving local cutlings")
                lastKnownRecordMetadata.removeAll()
                saveRecordMetadata()
                // Re-upload all local cutlings to recreate the zone
                Task {
                    let cutlings = await MainActor.run { self.store.cutlings }
                    if !cutlings.isEmpty {
                        self.enqueueAllCutlings(cutlings)
                    }
                }
            }
        }
    }

    private func handleFetchedRecordZoneChanges(_ event: CKSyncEngine.Event.FetchedRecordZoneChanges) async {
        if !event.modifications.isEmpty || !event.deletions.isEmpty {
            await applyRemoteChanges(modifications: event.modifications, deletions: event.deletions)
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

        // Poke other devices now that records are on the server
        if !event.savedRecords.isEmpty || !event.deletedRecordIDs.isEmpty {
            pokeOtherDevices()
        }

        // Handle failed saves
        for failure in event.failedRecordSaves {
            let failedRecord = failure.record
            let id = failedRecord.recordID.recordName

            switch failure.error.code {
            case .serverRecordChanged:
                // Conflict: merge using last-writer-wins
                guard let serverRecord = failure.error.serverRecord else {
                    Self.log.error("No server record for conflict on \(id)")
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
                Self.log.debug("Retryable error for \(id): \(failure.error)")

            default:
                Self.log.fault("Unhandled error saving \(id): \(failure.error)")
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
