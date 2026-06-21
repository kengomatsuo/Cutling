//
//  MacApp.swift
//  Cutling: macOS entry point
//
//  The Mac build of Cutling is a menu-bar-resident utility. The iOS app's
//  CutlingApp scene tree is gated out via `#if !os(macOS)`; on macOS only
//  this scene tree is compiled.
//

#if os(macOS)
import SwiftUI
import TipKit

@main
struct MacApp: App {
    @StateObject private var store = CutlingStore.shared
    @State private var pasteboardMonitor: PasteboardMonitor?
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @AppStorage("captureClipboardHistory") private var captureClipboardHistory = true
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    init() {
        UserDefaults.standard.register(defaults: [
            "autoDetectInputTypes": true,
            "captureClipboardHistory": true,
        ])
        // Configure TipKit before any TipView attempts to render. Errors
        // here are non-fatal (the worst case is no tips appear).
        try? Tips.configure()
    }

    var body: some Scene {
        MenuBarExtra("Cutling", systemImage: "doc.on.clipboard") {
            MacPickerView()
                .environmentObject(store)
                .frame(width: 360)
                .onAppear {
                    store.load()
                    syncPreferencesToAppGroup()
                    configureSyncIfNeeded()
                    configurePasteboardMonitor()
                    registerGlobalHotkey()
                    // Start watching for windows so we can flip activation
                    // policy when Settings or other windows open/close.
                    _ = AppActivationManager.shared
                }
                .onChange(of: captureClipboardHistory) { _, enabled in
                    if enabled {
                        pasteboardMonitor?.start()
                    } else {
                        pasteboardMonitor?.stop()
                    }
                }
        }
        .menuBarExtraStyle(.window)

        Settings {
            MacSettingsView()
                .environmentObject(store)
        }

        // First-launch welcome window. .defaultLaunchBehavior reads
        // hasOnboarded from @AppStorage: presented on first run, suppressed
        // thereafter. Manual reopen from Settings → General is supported
        // via openWindow(id:).
        Window("Welcome to Cutling", id: WelcomeWindow.id) {
            WelcomeView()
        }
        .restorationBehavior(.disabled)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .defaultWindowPlacement { content, context in
            let size = content.sizeThatFits(.unspecified)
            let visible = context.defaultDisplay.visibleRect
            // Centre horizontally; nudge a bit toward the top so the
            // arrow on the menu-bar step lines up closer to the real bar.
            let x = visible.midX - size.width / 2
            let y = visible.midY - size.height / 2 + 60
            return WindowPlacement(CGPoint(x: x, y: y), size: size)
        }
        .defaultLaunchBehavior(hasOnboarded ? .suppressed : .presented)
    }

    private func syncPreferencesToAppGroup() {
        guard let groupDefaults = UserDefaults(suiteName: appGroupID) else { return }
        groupDefaults.set(
            UserDefaults.standard.bool(forKey: "iCloudSyncEnabled"),
            forKey: "iCloudSyncEnabled"
        )
        let autoDetect = UserDefaults.standard.object(forKey: "autoDetectInputTypes") as? Bool ?? true
        groupDefaults.set(autoDetect, forKey: "autoDetectInputTypes")
    }

    private func configureSyncIfNeeded() {
        if !iCloudSyncEnabled {
            let kvs = NSUbiquitousKeyValueStore.default
            kvs.synchronize()
            if kvs.bool(forKey: "iCloudSyncEnabled") {
                iCloudSyncEnabled = true
            }
        }
        if iCloudSyncEnabled, store.syncManager == nil {
            let manager = CloudKitSyncManager(store: store)
            store.syncManager = manager
            Task { await manager.start() }
        }
    }

    private func configurePasteboardMonitor() {
        if pasteboardMonitor == nil {
            pasteboardMonitor = PasteboardMonitor(store: store)
        }
        if captureClipboardHistory {
            pasteboardMonitor?.start()
        }
    }

    private func registerGlobalHotkey() {
        // Touch the controller so it subscribes to .cutlingHotkeyPressed
        // before the hotkey is registered. Otherwise the first press is lost.
        _ = CutlingPickerController.shared
        GlobalHotkey.shared.register()
    }
}
#endif
