//
//  CutlingApp.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import SwiftUI

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

@main
struct CutlingApp: App {
    @StateObject private var store = CutlingStore.shared
    @State private var showSettings = false
    @State private var showOnboarding = false
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false

    var body: some Scene {
        WindowGroup {
            MainContentView(showSettings: $showSettings)
                .environmentObject(store)
                .onAppear {
                    store.seedIfEmpty()
                    configureSyncIfNeeded()
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
                    if url.scheme == "cutling", url.host == "settings" {
                        #if os(macOS)
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                        #else
                        showSettings = true
                        #endif
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        store.load()
                        // Trigger immediate CloudKit fetch on foreground
                        if let sm = store.syncManager {
                            Task { await sm.fetchChanges() }
                        }
                    }
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
            SettingsView()
                .environmentObject(store)
        }
        #endif
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
    }

    private func stopSync() {
        if let manager = store.syncManager {
            Task { await manager.stop() }
        }
        store.syncManager = nil
        store.isSyncing = false
    }
}
