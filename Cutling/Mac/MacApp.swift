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

/// Routes the edit window to the right detail view based on cutling kind.
/// Both TextDetailView and ImageDetailView are cross-platform; we just
/// pick which one to embed at runtime.
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

/// Wraps a singleton `Window`'s content and forces SwiftUI to rebuild it
/// every time the window closes. Without this, the underlying view's
/// `@State` persists across close→reopen (because `Window` keeps the
/// same scene alive), so opening "New Text Cutling" a second time would
/// show last session's name/value still typed in. By bumping `.id()` on
/// `NSWindow.willClose`, the next open instantiates a fresh view with
/// fresh state.
struct ResetOnWindowCloseHost<Content: View>: View {
    @ViewBuilder let content: () -> Content
    @State private var sessionID = UUID()

    var body: some View {
        content()
            .id(sessionID)
            .background(WindowCloseObserver { sessionID = UUID() })
    }
}

private struct WindowCloseObserver: NSViewRepresentable {
    let onClose: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = CloseTrackingView()
        view.onClose = onClose
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? CloseTrackingView)?.onClose = onClose
    }
}

private final class CloseTrackingView: NSView {
    var onClose: (() -> Void)?
    private var observer: NSObjectProtocol?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let observer { NotificationCenter.default.removeObserver(observer) }
        observer = nil
        guard let window = unsafe window else { return }
        observer = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.onClose?()
        }
    }

    deinit {
        if let observer { NotificationCenter.default.removeObserver(observer) }
    }
}

/// Runs the launch-time bootstrap. Previously this lived in
/// MacPickerView.onAppear, which only fires when the menu-bar popover
/// opens. With the menu-bar icon now hide-able, the popover may never
/// open in a given session, so we run the bootstrap from
/// `applicationDidFinishLaunching` instead. App struct init() can't
/// touch mutating SwiftUI state from an escaping closure, hence the
/// NSApplicationDelegate.
final class CutlingAppDelegate: NSObject, NSApplicationDelegate {
    @MainActor
    func applicationDidFinishLaunching(_ notification: Notification) {
        let store = CutlingStore.shared
        store.load()

        // Restore the iCloud sync preference from iCloud KVS if the local
        // default was wiped (e.g. after a reinstall). Mirrors iOS's
        // configureSyncIfNeeded so a returning user keeps syncing without
        // re-toggling. Must run before the App Group mirror below so the
        // shared default reflects the restored value.
        if !UserDefaults.standard.bool(forKey: "iCloudSyncEnabled") {
            let kvs = NSUbiquitousKeyValueStore.default
            kvs.synchronize()
            if kvs.bool(forKey: "iCloudSyncEnabled") {
                UserDefaults.standard.set(true, forKey: "iCloudSyncEnabled")
            }
        }

        // Mirror UserDefaults into the App Group so the keyboard ext
        // and any other shared consumers see the same values.
        if let groupDefaults = UserDefaults(suiteName: appGroupID) {
            groupDefaults.set(
                UserDefaults.standard.bool(forKey: "iCloudSyncEnabled"),
                forKey: "iCloudSyncEnabled"
            )
            let autoDetect = UserDefaults.standard.object(forKey: "autoDetectInputTypes") as? Bool ?? true
            groupDefaults.set(autoDetect, forKey: "autoDetectInputTypes")
        }

        // iCloud
        if UserDefaults.standard.bool(forKey: "iCloudSyncEnabled") {
            store.startCloudSyncIfNeeded()
        }

        // Pasteboard monitor (persisted in MacApp via @State, but the
        // monitor itself is fine as a one-off since we never need to
        // tear it down at runtime; auto-start respects the toggle).
        if UserDefaults.standard.bool(forKey: "captureClipboardHistory") {
            let monitor = PasteboardMonitor(store: store)
            monitor.start()
            CutlingAppDelegate.pasteboardMonitor = monitor
        }

        // Global hotkey + click-outside controller.
        _ = CutlingPickerController.shared
        GlobalHotkey.shared.register()

        // Activation policy watcher.
        _ = AppActivationManager.shared

        // Sparkle auto-update (direct-download build only; the file is inert
        // until the Sparkle package is linked). Instantiating the controller
        // starts the background update-check schedule.
        #if canImport(Sparkle)
        _ = UpdaterController.shared
        #endif

        // Menu-bar hint only when the icon is visible and the user has
        // cleared the welcome wizard. Fresh installs get the hint from
        // WelcomeView.finish() instead.
        let hasOnboarded = UserDefaults.standard.bool(forKey: "hasOnboarded")
        let showMenuBarIcon = UserDefaults.standard.bool(forKey: "showMenuBarIcon")
        if hasOnboarded && showMenuBarIcon {
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.5))
                MenuBarHintController.shared.showIfNeeded()
            }
        }
    }

    /// Held here so it stays alive for the lifetime of the app even
    /// after the bootstrap function returns.
    @MainActor static var pasteboardMonitor: PasteboardMonitor?
}

@main
struct MacApp: App {
    @NSApplicationDelegateAdaptor(CutlingAppDelegate.self) private var appDelegate
    @StateObject private var store = CutlingStore.shared
    @State private var pasteboardMonitor: PasteboardMonitor?
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @AppStorage("captureClipboardHistory") private var captureClipboardHistory = true
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    /// True when the menu-bar icon should appear. Users can hide the icon
    /// from Settings → General and still drive Cutling entirely via the
    /// global hotkey.
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon = true

    init() {
        UserDefaults.standard.register(defaults: [
            "autoDetectInputTypes": true,
            "captureClipboardHistory": true,
            "showMenuBarIcon": true,
            "pasteDirectly": false,
            "imageSaveBehavior": ImageSaveService.Behavior.ask.rawValue,
        ])
        // Configure TipKit before any TipView attempts to render. Errors
        // here are non-fatal (the worst case is no tips appear). The
        // datastore is persisted across launches so users only see each
        // tip once; Settings → "Reset to Fresh Install" wipes it on demand.
        try? Tips.configure()
    }

    var body: some Scene {
        // Persistence anchor. Per Apple's docs, an app whose only scene
        // is a MenuBarExtra terminates the moment the user removes the
        // extra from the menu bar (or we toggle isInserted off). This
        // invisible 1×1 window scene is suppressed at launch and never
        // shown, but its registration is enough to keep the process
        // alive so the global hotkey + LaunchAtLogin still work when
        // the user hides the menu bar icon.
        Window("", id: "_persistenceAnchor") {
            Color.clear.frame(width: 1, height: 1)
        }
        .restorationBehavior(.disabled)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultLaunchBehavior(.suppressed)
        .commandsRemoved()

        MenuBarExtra("Cutling", systemImage: "doc.on.clipboard", isInserted: $showMenuBarIcon) {
            MacPickerView()
                .environmentObject(store)
                .environment(\.macWindowSurface, .popover)
                .frame(width: 360)
                .onAppear {
                    // Bootstrap has already run from init's Task, but
                    // we still re-load the store on every popover open
                    // so cross-process changes (keyboard ext, share ext)
                    // are reflected immediately.
                    store.load()
                    // First-launch menu-bar callout dismisses permanently
                    // when the user opens the popover, since finding it
                    // proves they don't need the hint anymore.
                    MenuBarHintController.shared.dismissPermanently()
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

        // New Text Cutling window. Opened by the picker's + menu and
        // by the "New Text Cutling" command in the app menu bar.
        // Singleton `Window` (not WindowGroup): per Apple's openWindow
        // docs, reopening an already-open Window brings it forward, but a
        // WindowGroup spawns a duplicate. The latter is brutal in an agent
        // app where stray windows are hard to fish back out.
        //
        // `ResetOnWindowCloseHost` wipes the embedded view's @State each
        // time the window closes — otherwise the singleton would keep
        // last session's draft and pre-fill it on the next "New".
        Window("New Text Cutling", id: "addText") {
            ResetOnWindowCloseHost {
                TextDetailView(item: nil)
                    .environmentObject(store)
            }
        }
        .restorationBehavior(.disabled)
        .defaultSize(width: 480, height: 520)

        // New Image Cutling window. Same singleton rationale as addText.
        Window("New Image Cutling", id: "addImage") {
            ResetOnWindowCloseHost {
                ImageDetailView(item: nil)
                    .environmentObject(store)
            }
        }
        .restorationBehavior(.disabled)
        .defaultSize(width: 480, height: 520)

        // Edit existing cutling, opened with the cutling's UUID.
        WindowGroup("Edit Cutling", id: "editCutling", for: Cutling.ID.self) { $cutlingID in
            if let cutlingID, let cutling = store.cutlings.first(where: { $0.id == cutlingID }) {
                DetailWindowView(cutling: cutling)
                    .environmentObject(store)
            } else {
                Text("Cutling not found")
                    .foregroundStyle(.secondary)
                    .frame(width: 320, height: 160)
            }
        }
        .restorationBehavior(.disabled)
        .defaultSize(width: 480, height: 520)

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
}
#endif
