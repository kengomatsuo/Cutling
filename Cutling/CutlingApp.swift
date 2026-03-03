//
//  CutlingApp.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import SwiftUI

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
    }
}
