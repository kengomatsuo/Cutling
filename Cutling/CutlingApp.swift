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
#endif

@main
struct CutlingApp: App {
    @StateObject private var store = CutlingStore.shared
    @State private var showSettings = false
    @State private var showOnboarding = false
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            MainContentView(showSettings: $showSettings)
                .environmentObject(store)
                .onAppear {
                    store.seedIfEmpty()
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
                .onOpenURL { url in
                    if url.scheme == "cutling", url.host == "settings" {
                        showSettings = true
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    // Reload when app becomes active (e.g., returning from keyboard)
                    if newPhase == .active {
                        store.load()
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
        #endif
    }
}
