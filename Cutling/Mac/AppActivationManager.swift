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
