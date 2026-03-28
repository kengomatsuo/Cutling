//
//  CutlingApp.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import SwiftUI
import StoreKit
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

@main
struct CutlingApp: App {
    @StateObject private var store = CutlingStore.shared
    @State private var showKeyboard = false
    @State private var showOnboarding = false
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false

    // Review request tracking
    @AppStorage("lastVersionPromptedForReview") private var lastVersionPromptedForReview = ""
    // Version flag for future use (e.g. "What's New" screen for returning users)
    @AppStorage("lastVersionOpened") private var lastVersionOpened = ""
    @Environment(\.requestReview) private var requestReview

    #if os(iOS)
    private static let bgSyncTaskID = "com.matsuokengo.Cutling.sync"
    private static let bgProcessingTaskID = "com.matsuokengo.Cutling.sync.processing"
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
            MainContentView(showKeyboard: $showKeyboard)
                .environmentObject(store)
                .onAppear {
                    store.seedIfEmpty()
                    runMigrationsIfNeeded()
                    configureSyncIfNeeded()
                    syncPreferencesToAppGroup()
                    lastVersionOpened = currentAppVersion
                    #if os(iOS)
                    if !hasCompletedOnboarding {
                        showOnboarding = true
                    }
                    #else
                    if !hasCompletedOnboarding {
                        hasCompletedOnboarding = true
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
                        requestReviewIfAppropriate()
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
                    KeyboardSetupView(isOnboarding: true) {
                        hasCompletedOnboarding = true
                    }
                    .interactiveDismissDisabled()
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

    // MARK: - Migrations

    private func runMigrationsIfNeeded() {
        let previous = AppVersion(lastVersionOpened)

        // v1.2: auto-detect input type triggers for existing text cutlings
        if previous < AppVersion("1.2") {
            store.migrateInputTypeTriggers()
        }
    }

    // MARK: - App Review Request

    private var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    private func requestReviewIfAppropriate() {
        let pasteCount = UserDefaults(suiteName: appGroupID)?.integer(forKey: "keyboardPasteCount") ?? 0

        // Only prompt after meaningful engagement (5+ pastes from the keyboard)
        // and only once per app version
        guard pasteCount >= 5,
              currentAppVersion != lastVersionPromptedForReview else {
            return
        }

        // Delay to avoid interrupting the user mid-task
        Task {
            try? await Task.sleep(for: .seconds(2))
            requestReview()
            lastVersionPromptedForReview = currentAppVersion
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
