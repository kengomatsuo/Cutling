//
//  CutlingApp.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import CoreSpotlight
import SwiftUI
import TipKit
#if os(iOS)
import BackgroundTasks
#endif

/// Numeric version comparison that handles multi-digit components correctly
/// (e.g. "1.10" > "1.9"). Missing components are treated as 0.
private struct AppVersion: Comparable {
    let components: [Int]

    init(_ string: String) {
        components = string.split(separator: ".").compactMap { Int($0) }
    }

    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        let count = max(lhs.components.count, rhs.components.count)
        for i in 0..<count {
            let l = i < lhs.components.count ? lhs.components[i] : 0
            let r = i < rhs.components.count ? rhs.components[i] : 0
            if l != r { return l < r }
        }
        return false
    }
}

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    var pendingShortcutType: String?

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            pendingShortcutType = shortcutItem.type
        }
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let host: String
        switch shortcutItem.type {
        case "com.matsuokengo.Cutling.addText":
            host = "addText"
        case "com.matsuokengo.Cutling.addImage":
            host = "addImage"
        default:
            completionHandler(false)
            return
        }
        if let url = URL(string: "cutling://\(host)") {
            UIApplication.shared.open(url)
        }
        completionHandler(true)
    }
}
#endif

#if !os(macOS)
@main
struct CutlingApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif
    @StateObject private var store = CutlingStore.shared
    @State private var activeSheet: ActiveSheet?
    @State private var showOnboarding = false
    @State private var limitAlertMessage: String?
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false

    // Version flag for migrations and "What's New" gating.
    @AppStorage("lastVersionOpened") private var lastVersionOpened = ""

    // Last release whose "What's New" sheet the user has seen. Bump
    // `whatsNewVersion` on releases where new content should fire the sheet.
    @AppStorage("lastWhatsNewVersionSeen") private var lastWhatsNewVersionSeen = ""

    @State private var pendingOpenCutlingID: UUID?
    @State private var copiedCutlingName: String?
    @State private var showWhatsNew = false

    /// Releases with new content shown via the "What's New" sheet. Bump this
    /// on every release where you update `WhatsNewView`'s feature list.
    private let whatsNewVersion = "1.5"

    #if os(iOS)
    private static let bgSyncTaskID = "com.matsuokengo.Cutling.sync"
    private static let bgProcessingTaskID = "com.matsuokengo.Cutling.sync.processing"

    private var keyboardNeedsSetup: Bool {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let keyboards = UserDefaults.standard.stringArray(forKey: "AppleKeyboards") ?? []
        let keyboardAdded = keyboards.contains(where: { $0.hasPrefix(bundleID) })
        let fullAccess = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.bool(forKey: "hasFullAccess") ?? false
        return !keyboardAdded || !fullAccess
    }
    #endif

    init() {
        UserDefaults.standard.register(defaults: [
            "autoDetectInputTypes": true,
        ])
        try? Tips.configure()
        #if os(iOS)
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.bgSyncTaskID,
            using: nil
        ) { task in
            guard let task = task as? BGAppRefreshTask else { return }
            Self.handleBackgroundSync(task)
        }
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.bgProcessingTaskID,
            using: nil
        ) { task in
            guard let task = task as? BGProcessingTask else { return }
            Self.handleBackgroundProcessing(task)
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            MainContentView(
                activeSheet: $activeSheet,
                pendingOpenCutlingID: $pendingOpenCutlingID,
                copiedCutlingName: $copiedCutlingName
            )
                .environmentObject(store)
                .onAppear {
                    #if DEBUG
                    if ProcessInfo.processInfo.arguments.contains("-SNAPSHOT_MODE") {
                        store.seedForSnapshots()
                        UserDefaults.standard.removeObject(forKey: "keyboardSetupPage")
                        if let lang = Locale.preferredLanguages.first {
                            UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.set(lang, forKey: "snapshotLanguage")
                        }
                    } else {
                        store.seedIfEmpty()
                        UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.removeObject(forKey: "snapshotLanguage")
                    }
                    #else
                    store.seedIfEmpty()
                    #endif
                    runMigrationsIfNeeded()
                    configureSyncIfNeeded()
                    syncPreferencesToAppGroup()
                    SpotlightIndexer.shared.reindexAll(from: store)
                    let previousVersion = lastVersionOpened
                    lastVersionOpened = currentAppVersion
                    #if os(iOS)
                    #if DEBUG
                    if !ProcessInfo.processInfo.arguments.contains("-SNAPSHOT_MODE"),
                       !hasCompletedSetup || keyboardNeedsSetup {
                        showOnboarding = true
                    }
                    #else
                    if !hasCompletedSetup || keyboardNeedsSetup {
                        showOnboarding = true
                    }
                    #endif
                    evaluateWhatsNew(previousVersion: previousVersion)
                    #endif
                }
                .onChange(of: iCloudSyncEnabled) { _, enabled in
                    if enabled {
                        startSync()
                    } else {
                        stopSync()
                    }
                }
                .onContinueUserActivity(CSSearchableItemActionType) { userActivity in
                    guard let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
                          let uuid = UUID(uuidString: identifier) else { return }
                    let actionID = userActivity.userInfo?[CSActionIdentifier] as? String
                    // Edit action (long-press menu) or fallback row tap → open detail.
                    // Plain row tap is normally handled by the Copy OpenIntent, not this handler.
                    if actionID == SpotlightIndexer.editActionID || actionID == nil {
                        pendingOpenCutlingID = uuid
                    }
                }
                .onOpenURL { url in
                    guard url.scheme == "cutling" else { return }
                    switch url.host {
                    case "settings":
                        #if os(macOS)
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                        #endif
                        #if os(iOS)
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                        #endif
                    case "keyboard":
                        if activeSheet == nil { activeSheet = .keyboardManager }
                    case "addText":
                        requestNewCutling(NewCutlingDraft(kind: .text))
                    case "addImage":
                        requestNewCutling(NewCutlingDraft(kind: .image))
                    default:
                        break
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        syncPreferencesToAppGroup()
                        store.load()
                        // Trigger immediate CloudKit fetch on foreground
                        if let sm = store.syncManager {
                            Task { await sm.fetchChanges() }
                        }
                        handlePendingOpenCutling()
                        handlePendingCopyConfirmation()
                        #if os(iOS)
                        handlePendingShortcut()
                        handlePendingControlAction()
                        #endif
                    }
                    #if os(iOS)
                    if newPhase == .background {
                        Self.scheduleBackgroundSync()
                        Self.scheduleBackgroundProcessing()
                    }
                    #endif
                }
                #if os(iOS)
                .sheet(isPresented: $showOnboarding) {
                    KeyboardSetupView()
                }
                .sheet(isPresented: $showWhatsNew) {
                    WhatsNewView {
                        lastWhatsNewVersionSeen = whatsNewVersion
                    }
                }
                #endif
                .alert(
                    "Limit Reached",
                    isPresented: Binding(
                        get: { limitAlertMessage != nil },
                        set: { if !$0 { limitAlertMessage = nil } }
                    )
                ) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(limitAlertMessage ?? "")
                }
        }
        #if os(macOS)
        .defaultSize(width: 700, height: 550)
        .commands {
            CutlingCommands()
        }
        #endif

        #if os(macOS)
        // Edit existing cutling in a separate window
        WindowGroup("Edit Cutling", id: "editCutling", for: Cutling.ID.self) { $cutlingID in
            if let cutlingID, let cutling = store.cutlings.first(where: { $0.id == cutlingID }) {
                DetailWindowView(cutling: cutling)
                    .environmentObject(store)
            }
        }
        .defaultSize(width: 480, height: 500)

        // Add new text cutling
        WindowGroup("New Text Cutling", id: "addText") {
            TextDetailView(item: nil)
                .environmentObject(store)
        }
        .defaultSize(width: 480, height: 500)

        // Add new image cutling
        WindowGroup("New Image Cutling", id: "addImage") {
            ImageDetailView(item: nil)
                .environmentObject(store)
        }
        .defaultSize(width: 480, height: 500)

        Settings {
            PreferencesView()
                .environmentObject(store)
        }
        #endif
    }

    // MARK: - Spotlight Open

    private func handlePendingOpenCutling() {
        let groupDefaults = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")
        guard let idString = groupDefaults?.string(forKey: "pendingOpenCutlingID"),
              let uuid = UUID(uuidString: idString) else { return }
        groupDefaults?.removeObject(forKey: "pendingOpenCutlingID")
        pendingOpenCutlingID = uuid
    }

    /// Reads the flag the Spotlight Copy intent leaves behind and renders a "Copied" banner.
    private func handlePendingCopyConfirmation() {
        let groupDefaults = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")
        guard let idString = groupDefaults?.string(forKey: "pendingCopiedCutlingID"),
              let uuid = UUID(uuidString: idString) else { return }
        groupDefaults?.removeObject(forKey: "pendingCopiedCutlingID")
        if let cutling = store.cutlings.first(where: { $0.id == uuid }) {
            copiedCutlingName = cutling.name
        }
    }

    // MARK: - Quick Actions

    #if os(iOS)
    private func handlePendingShortcut() {
        guard let type = appDelegate.pendingShortcutType else { return }
        appDelegate.pendingShortcutType = nil
        guard hasCompletedSetup else { return }
        switch type {
        case "com.matsuokengo.Cutling.addText":
            requestNewCutling(NewCutlingDraft(kind: .text))
        case "com.matsuokengo.Cutling.addImage":
            requestNewCutling(NewCutlingDraft(kind: .image))
        default:
            break
        }
    }

    private func handlePendingControlAction() {
        let groupDefaults = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")
        guard let action = groupDefaults?.string(forKey: "pendingControlAction") else { return }
        guard hasCompletedSetup else { return }
        switch action {
        case "newText":
            groupDefaults?.removeObject(forKey: "pendingControlAction")
            requestNewCutling(NewCutlingDraft(kind: .text))
        case "newImage":
            groupDefaults?.removeObject(forKey: "pendingControlAction")
            requestNewCutling(NewCutlingDraft(kind: .image))
        default:
            break
        }
    }
    #endif

    // MARK: - Sheet Management

    private func requestNewCutling(_ draft: NewCutlingDraft) {
        guard activeSheet == nil else { return }
        let canAdd = store.canAdd(draft.kind)
        if canAdd.allowed {
            activeSheet = .newCutling(draft)
        } else {
            limitAlertMessage = canAdd.reason ?? String(localized: "Cannot add more cutlings.")
        }
    }

    // MARK: - Preferences Sync

    /// Copies preferences from standard UserDefaults (where Settings.bundle writes)
    /// to the app group so the keyboard extension can read them.
    private func syncPreferencesToAppGroup() {
        guard let groupDefaults = UserDefaults(suiteName: "group.com.matsuokengo.Cutling") else { return }
        groupDefaults.set(
            UserDefaults.standard.bool(forKey: "iCloudSyncEnabled"),
            forKey: "iCloudSyncEnabled"
        )
        let autoDetect = UserDefaults.standard.object(forKey: "autoDetectInputTypes") as? Bool ?? true
        groupDefaults.set(autoDetect, forKey: "autoDetectInputTypes")
    }

    // MARK: - iCloud Sync

    private func configureSyncIfNeeded() {
        // Restore from iCloud KVS if local UserDefaults was reset (e.g. after reinstall)
        if !iCloudSyncEnabled {
            let kvs = NSUbiquitousKeyValueStore.default
            kvs.synchronize()
            if kvs.bool(forKey: "iCloudSyncEnabled") {
                iCloudSyncEnabled = true
                return
            }
        }
        if iCloudSyncEnabled {
            startSync()
        }
    }

    private func startSync() {
        let manager = CloudKitSyncManager(store: store)
        store.syncManager = manager
        Task { await manager.start() }
        // Mirror to app group so the keyboard extension can read it
        UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.set(true, forKey: "iCloudSyncEnabled")
        NSUbiquitousKeyValueStore.default.set(true, forKey: "iCloudSyncEnabled")
    }

    private func stopSync() {
        if let manager = store.syncManager {
            Task { await manager.stop() }
        }
        store.syncManager = nil
        store.isSyncing = false
        UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.set(false, forKey: "iCloudSyncEnabled")
        NSUbiquitousKeyValueStore.default.set(false, forKey: "iCloudSyncEnabled")
    }

    private var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    // MARK: - Migrations

    private func runMigrationsIfNeeded() {
        let previous = AppVersion(lastVersionOpened)

        // v1.2: auto-detect input type triggers for existing text cutlings
        if previous < AppVersion("1.2") {
            store.migrateInputTypeTriggers()
        }
    }

    // MARK: - What's New

    #if os(iOS)
    /// Decides whether to present the "What's New" sheet for this launch.
    ///
    /// Shown only to **existing** users who upgraded across the
    /// `whatsNewVersion` threshold. Brand-new installers see the full
    /// onboarding instead and have `lastWhatsNewVersionSeen` advanced silently
    /// so they never get retroactively flagged.
    private func evaluateWhatsNew(previousVersion: String) {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-SNAPSHOT_MODE") { return }
        #endif

        let target = AppVersion(whatsNewVersion)

        // Fresh install: no previous version on disk. Advance the seen flag
        // so a future release threshold doesn't fire retroactively for them.
        if previousVersion.isEmpty {
            if AppVersion(lastWhatsNewVersionSeen) < target {
                lastWhatsNewVersionSeen = whatsNewVersion
            }
            return
        }

        // Already seen this release's news (or a later one).
        guard AppVersion(lastWhatsNewVersionSeen) < target else { return }

        // User was already on or past this release before this launch
        // (e.g. reinstall after deleting). Treat as caught up.
        guard AppVersion(previousVersion) < target else {
            lastWhatsNewVersionSeen = whatsNewVersion
            return
        }

        // Defer to onboarding if it will appear — the user is mid-setup,
        // not a returning power user.
        guard hasCompletedSetup, !keyboardNeedsSetup else { return }

        showWhatsNew = true
    }
    #endif

    // MARK: - Background App Refresh (iOS)

    #if os(iOS)
    private static func scheduleBackgroundSync() {
        let request = BGAppRefreshTaskRequest(identifier: bgSyncTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 min
        do {
            try BGTaskScheduler.shared.submit(request)
            print("⏰ Scheduled background refresh")
        } catch {
            print("⏰ Failed to schedule background refresh: \(error)")
        }
    }

    private static func scheduleBackgroundProcessing() {
        let request = BGProcessingTaskRequest(identifier: bgProcessingTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60) // 5 min
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        do {
            try BGTaskScheduler.shared.submit(request)
            print("⏰ Scheduled background processing")
        } catch {
            print("⏰ Failed to schedule background processing: \(error)")
        }
    }

    private static func handleBackgroundSync(_ task: BGAppRefreshTask) {
        scheduleBackgroundSync()
        runBackgroundSync { success in task.setTaskCompleted(success: success) }
        task.expirationHandler = { task.setTaskCompleted(success: false) }
    }

    /// BGProcessingTask — gets several minutes, ideal for image uploads.
    private static func handleBackgroundProcessing(_ task: BGProcessingTask) {
        scheduleBackgroundProcessing()
        runBackgroundSync { success in task.setTaskCompleted(success: success) }
        task.expirationHandler = { task.setTaskCompleted(success: false) }
    }

    private static func runBackgroundSync(completion: @escaping (Bool) -> Void) {
        let iCloudEnabled = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.bool(forKey: "iCloudSyncEnabled") ?? false

        Task { @MainActor in
            let store = CutlingStore.shared
            // Always run housekeeping on a BG wakeup, even with iCloud off.
            store.purgeExpired()

            guard iCloudEnabled else {
                completion(true)
                return
            }

            if store.syncManager == nil {
                let manager = CloudKitSyncManager(store: store)
                store.syncManager = manager
                await manager.start()
            }
            if let sm = store.syncManager {
                await sm.performBackgroundSync()
            }
            completion(true)
        }
    }
    #endif
}
#endif
