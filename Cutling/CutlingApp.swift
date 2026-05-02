//
//  CutlingApp.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import SwiftUI
#if os(iOS)
import BackgroundTasks
#endif

#if os(macOS)
/// Wrapper that routes to the correct detail view based on cutling kind.
struct DetailWindowView: View {
    let cutling: Cutling

    var body: some View {
        switch cutling.kind {
        case .text:
            TextDetailView(item: cutling)
        case .image:
            ImageDetailView(item: cutling)
        }
    }
}

// MARK: - Menu Bar Commands

extension FocusedValues {
    @Entry var mainContentMode: MainContentMode?
    @Entry var mainContentCommands: MainContentCommands?
}

struct CutlingCommands: Commands {
    @Environment(\.openWindow) private var openWindow
    @FocusedValue(\.mainContentMode) var mode
    @FocusedValue(\.mainContentCommands) var commands

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Text Cutling") {
                openWindow(id: "addText")
            }
            .keyboardShortcut("n", modifiers: [.command])

            Button("New Image Cutling") {
                openWindow(id: "addImage")
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])
        }

        CommandMenu("Cutlings") {
            Button("Select Cutlings") {
                commands?.enterSelectMode?()
            }
            .disabled(mode != .browsing)

            Button("Reorder Cutlings") {
                commands?.enterReorderMode?()
            }
            .disabled(mode != .browsing || (commands?.cutlingsCount ?? 0) < 2)

            Divider()

            Button("Delete Selected") {
                commands?.deleteSelected?()
            }
            .keyboardShortcut(.delete, modifiers: [.command])
            .disabled(mode != .selecting || (commands?.selectedCount ?? 0) == 0)
        }
    }
}
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

@main
struct CutlingApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif
    @StateObject private var store = CutlingStore.shared
    @State private var showKeyboard = false
    @State private var pendingNewCutlingKind: CutlingKind?
    @State private var showOnboarding = false
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false

    // Version flag for future use (e.g. "What's New" screen for returning users)
    @AppStorage("lastVersionOpened") private var lastVersionOpened = ""

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
        UserDefaults.standard.register(defaults: ["autoDetectInputTypes": true])
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
            MainContentView(showKeyboard: $showKeyboard, pendingNewCutlingKind: $pendingNewCutlingKind)
                .environmentObject(store)
                .onAppear {
                    #if DEBUG
                    if ProcessInfo.processInfo.arguments.contains("-SNAPSHOT_MODE") {
                        store.seedForSnapshots()
                    } else {
                        store.seedIfEmpty()
                    }
                    #else
                    store.seedIfEmpty()
                    #endif
                    runMigrationsIfNeeded()
                    configureSyncIfNeeded()
                    syncPreferencesToAppGroup()
                    lastVersionOpened = currentAppVersion
                    #if os(iOS)
                    if !hasCompletedSetup || keyboardNeedsSetup {
                        showOnboarding = true
                    }
                    #endif
                }
                .onChange(of: iCloudSyncEnabled) { _, enabled in
                    if enabled {
                        startSync()
                    } else {
                        stopSync()
                    }
                }
                .onOpenURL { url in
                    guard url.scheme == "cutling" else { return }
                    switch url.host {
                    case "settings":
                        #if os(macOS)
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                        #else
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                        #endif
                    case "keyboard":
                        showKeyboard = true
                    case "addText":
                        pendingNewCutlingKind = .text
                    case "addImage":
                        pendingNewCutlingKind = .image
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
                        #if os(iOS)
                        handlePendingShortcut()
                        #endif
                    }
                    #if os(iOS)
                    if newPhase == .background && iCloudSyncEnabled {
                        Self.scheduleBackgroundSync()
                        Self.scheduleBackgroundProcessing()
                    }
                    #endif
                }
                #if os(iOS)
                .sheet(isPresented: $showOnboarding) {
                    KeyboardSetupView()
                }
                #endif
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
        }
        #endif
    }

    // MARK: - Quick Actions

    #if os(iOS)
    private func handlePendingShortcut() {
        guard let type = appDelegate.pendingShortcutType else { return }
        appDelegate.pendingShortcutType = nil
        guard hasCompletedSetup else { return }
        switch type {
        case "com.matsuokengo.Cutling.addText":
            pendingNewCutlingKind = .text
        case "com.matsuokengo.Cutling.addImage":
            pendingNewCutlingKind = .image
        default:
            break
        }
    }
    #endif

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
    }

    private func stopSync() {
        if let manager = store.syncManager {
            Task { await manager.stop() }
        }
        store.syncManager = nil
        store.isSyncing = false
        UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.set(false, forKey: "iCloudSyncEnabled")
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
        guard iCloudEnabled else {
            completion(true)
            return
        }

        let store = CutlingStore.shared
        Task {
            if store.syncManager == nil {
                let manager = CloudKitSyncManager(store: store)
                await MainActor.run { store.syncManager = manager }
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
