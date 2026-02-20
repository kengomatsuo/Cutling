//
//  TineApp.swift
//  Tine
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import SwiftUI

@main
struct TineApp: App {
    @StateObject private var store = SnippetStore.shared
    @State private var showSettings = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            MainContentView(showSettings: $showSettings)
                .environmentObject(store)
                .onAppear { store.seedIfEmpty() }
                .onOpenURL { url in
                    if url.scheme == "tine", url.host == "settings" {
                        showSettings = true
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    // Reload when app becomes active (e.g., returning from keyboard)
                    if newPhase == .active {
                        store.load()
                    }
                }
        }
        #if os(macOS)
        .defaultSize(width: 600, height: 500)
        #endif
    }
}
