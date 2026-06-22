//
//  AppActivationManager.swift
//  Cutling: toggles the app's activation policy between .accessory
//  (menu-bar only, no Dock icon) and .regular (Dock icon present, windows
//  can be brought to the front) depending on whether any real window is
//  currently visible.
//
//  Why: with LSUIElement=YES the app is an "agent". macOS agents can show
//  NSWindows but those windows can't be activated or focused via the
//  standard click-to-front behavior. Promoting to .regular while a window
//  is open is the documented workaround for SwiftUI MenuBarExtra apps
//  (see Peter Steinberger's "5-hour journey" writeup, Aug 2025).
//
//  This implementation polls NSApp.windows on every window notification
//  rather than maintaining a hand-tracked counter. That counter goes out
//  of sync the moment a window opens or closes without firing the exact
//  notification pair we expected (which Settings windows are known to do).
//

#if os(macOS)
import AppKit
import SwiftUI

/// Which surface the user clicked from when triggering an add/edit window.
/// `AppActivationManager` records this in `showWindow(source:_:)` and reads
/// it back in `reopenSource()` so we can return the user to the list they
/// came from (popover or floating panel) after a successful save.
enum MacWindowSurface: Sendable {
    case popover
    case pickerPanel
    case none
}

private struct MacWindowSurfaceKey: EnvironmentKey {
    static let defaultValue: MacWindowSurface = .popover
}

extension EnvironmentValues {
    /// Surface that hosts the current `MacPickerView`. Read by the picker's
    /// + and Edit actions so they can tell `AppActivationManager` which
    /// surface to re-present after the user saves.
    var macWindowSurface: MacWindowSurface {
        get { self[MacWindowSurfaceKey.self] }
        set { self[MacWindowSurfaceKey.self] = newValue }
    }
}

extension Notification.Name {
    /// Posted by `TextDetailView` / `ImageDetailView` (macOS only) when the
    /// user completes a save from an add or edit window. `AppActivationManager`
    /// observes this and re-presents the surface that originally opened the
    /// window so the user sees their fresh row immediately.
    static let cutlingDidSaveFromMacWindow = Notification.Name("com.matsuokengo.Cutling.didSaveFromMacWindow")
}

@MainActor
final class AppActivationManager {
    static let shared = AppActivationManager()

    private var observers: [NSObjectProtocol] = []
    /// Weak reference to the NSWindow that hosts the MenuBarExtra(.window)
    /// popover. Captured via WindowAccessor in MacPickerView so we can
    /// programmatically dismiss the popover when opening Settings. There
    /// is no first-party SwiftUI API for this as of Xcode 26 (see
    /// FB11984872).
    weak var menuBarPopoverWindow: NSWindow?

    /// Surface that opened the most recent add/edit window. Reset to `.none`
    /// after `reopenSource()` consumes it.
    private var lastSource: MacWindowSurface = .none

    /// Order the menu bar extra's popover window out, if it's visible.
    /// Useful when transitioning to a real window (Settings, etc.) so the
    /// popover doesn't linger over the new window.
    func dismissMenuBarPopover() {
        menuBarPopoverWindow?.orderOut(nil)
    }

    private init() {
        let nc = NotificationCenter.default
        let events: [NSNotification.Name] = [
            NSWindow.didBecomeKeyNotification,
            NSWindow.didBecomeMainNotification,
            NSWindow.willCloseNotification,
            NSWindow.didChangeOcclusionStateNotification,
            NSApplication.didFinishLaunchingNotification,
        ]
        for name in events {
            observers.append(nc.addObserver(
                forName: name,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor [weak self] in self?.reevaluateSoon() }
            })
        }
        // Save → reopen the surface the user came from.
        observers.append(nc.addObserver(
            forName: .cutlingDidSaveFromMacWindow,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in self?.reopenSource() }
        })
    }

    /// Promote the app to .regular so its windows can be focused. Call
    /// before triggering openSettings() (or before showing any other real
    /// window). The policy will drop back to .accessory automatically when
    /// the user closes the last real window.
    func prepareToShowWindow() {
        if NSApp.activationPolicy() != .regular {
            NSApp.setActivationPolicy(.regular)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    /// Full window-show flow for LSUIElement (agent) apps. macOS won't
    /// reliably bring a SwiftUI window to the front just because we called
    /// `openSettings()` or `openWindow(id:)`.
    ///
    /// The sequence here is load-bearing:
    ///   1. Hide the picker panel (if it was the source) so it doesn't
    ///      linger behind the new window.
    ///   2. Promote to .regular policy so the window can become key.
    ///   3. Activate the app BEFORE opening — gives the new NSWindow a
    ///      chance to inherit key status as it materialises.
    ///   4. Open the window.
    ///   5. Poll for it to appear, then lift it.
    ///   6. Activate again — the policy change + window open can re-enter
    ///      the system's app-switch logic, and a second pass pins focus
    ///      to us reliably.
    ///   7. Dismiss the menu-bar popover LAST so its close doesn't briefly
    ///      hand focus to the previously frontmost app mid-transition.
    ///
    /// `ignoringOtherApps: true` is deprecated but is the only API that
    /// reliably activates from `.accessory`; the cooperative `activate()`
    /// will politely yield to the frontmost app and leave our window
    /// visible-but-inactive.
    ///
    /// `source` records which surface (menu-bar popover, hotkey picker
    /// panel, or none) triggered this open so `reopenSource()` can return
    /// the user there after a save.
    func showWindow(source: MacWindowSurface = .none, _ opener: @escaping @MainActor () -> Void) {
        lastSource = source
        Task { @MainActor in
            if source == .pickerPanel {
                CutlingPickerController.shared.hide()
            }
            if NSApp.activationPolicy() != .regular {
                NSApp.setActivationPolicy(.regular)
                try? await Task.sleep(for: .milliseconds(50))
            }
            NSApp.activate(ignoringOtherApps: true)
            opener()
            await bringUserWindowsToFrontWithRetry()
            NSApp.activate(ignoringOtherApps: true)
            dismissMenuBarPopover()
        }
    }

    /// Re-present the surface that opened the last add/edit window. Called
    /// after `.cutlingDidSaveFromMacWindow` so the user sees their freshly
    /// saved row without having to click the menu-bar icon again.
    ///
    /// If the original surface was the popover but the menu-bar icon is no
    /// longer on screen (user disabled it in System Settings → Control
    /// Center, or in our own toggle), we fall back to the floating picker
    /// panel so there's always a list to return to.
    func reopenSource() {
        let source = lastSource
        lastSource = .none
        switch source {
        case .popover:
            if !openMenuBarPopover() {
                CutlingPickerController.shared.show()
            }
        case .pickerPanel:
            CutlingPickerController.shared.show()
        case .none:
            break
        }
    }

    /// True if the MenuBarExtra's status item is currently on screen.
    /// Returns false when the user hid the icon either via our `showMenuBarIcon`
    /// toggle or via System Settings → Control Center → Menu Bar Items.
    ///
    /// Uses `screen.frame` (not `visibleFrame`) for the intersection test —
    /// `visibleFrame` excludes the menu bar, where the status item lives.
    func isMenuBarIconOnScreen() -> Bool {
        for window in NSApp.windows where window.className == "NSStatusBarWindow" {
            let frame = window.frame
            guard frame.width > 0, frame.height > 0 else { continue }
            if NSScreen.screens.contains(where: { $0.frame.intersects(frame) }) {
                return true
            }
        }
        return false
    }

    /// Synthesise a click on the MenuBarExtra's status-item button to
    /// re-open its popover. Returns true if a valid status item was found
    /// and clicked; false if the icon is hidden or unreachable.
    @discardableResult
    func openMenuBarPopover() -> Bool {
        for window in NSApp.windows where window.className == "NSStatusBarWindow" {
            let frame = window.frame
            guard frame.width > 0, frame.height > 0,
                  NSScreen.screens.contains(where: { $0.frame.intersects(frame) })
            else { continue }
            if let button = findFirstButton(in: window.contentView) {
                button.performClick(nil)
                return true
            }
        }
        return false
    }

    private func findFirstButton(in view: NSView?) -> NSButton? {
        guard let view else { return nil }
        if let button = view as? NSButton { return button }
        for sub in view.subviews {
            if let button = findFirstButton(in: sub) { return button }
        }
        return nil
    }

    /// Poll for a user-facing window to appear, then lift it. SwiftUI may
    /// take longer than a single fixed delay to materialise the NSWindow
    /// behind an `openWindow(id:)` call (cold scene, slow launch, debug
    /// builds, etc.). Up to ~500ms of polling, then a final lift attempt
    /// regardless so we never leave the user staring at a stale popover.
    private func bringUserWindowsToFrontWithRetry() async {
        for _ in 0..<10 {
            try? await Task.sleep(for: .milliseconds(50))
            if bringUserWindowsToFront() { return }
        }
        _ = bringUserWindowsToFront()
    }

    /// Iterates NSApp.windows and lifts every visible, titled, user-facing
    /// window to the front. NSPanels (our floating picker, menu bar extras)
    /// are explicitly skipped. Returns true if at least one window was lifted.
    @discardableResult
    private func bringUserWindowsToFront() -> Bool {
        var lifted = false
        for window in NSApp.windows {
            guard window.isVisible,
                  !(window is NSPanel),
                  window.styleMask.contains(.titled)
            else { continue }
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
            lifted = true
        }
        return lifted
    }

    /// Schedule a re-evaluation. The 50ms delay lets a closing window
    /// actually leave NSApp.windows before we count survivors.
    private func reevaluateSoon() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            Task { @MainActor [weak self] in self?.reevaluate() }
        }
    }

    private func reevaluate() {
        let target: NSApplication.ActivationPolicy = hasUserFacingWindow() ? .regular : .accessory
        if NSApp.activationPolicy() != target {
            NSApp.setActivationPolicy(target)
        }
    }

    /// A user-facing window is one with a real title bar that isn't our
    /// floating picker panel. Settings windows, About windows, and any
    /// future regular WindowGroup all qualify. Menu bar extra popovers
    /// and NSPanels do not.
    private func hasUserFacingWindow() -> Bool {
        for window in NSApp.windows {
            guard window.isVisible else { continue }
            if window is NSPanel { continue }
            // The menu bar extra popover and small system-owned windows
            // typically lack .titled or have no content view controller.
            guard window.styleMask.contains(.titled) else { continue }
            return true
        }
        return false
    }
}
#endif
