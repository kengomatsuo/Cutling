//
//  PickerPanel.swift
//  Cutling: cursor-anchored floating panel summoned by the global hotkey.
//
//  Distinct from the MenuBarExtra popover: this is a true HUD-style panel that
//  appears wherever the cursor is, so the user doesn't have to fly to the
//  menu bar. Uses NSPanel with .nonactivatingPanel + .floating level so it can
//  appear over any app without stealing global focus.
//

#if os(macOS)
import AppKit
import SwiftUI
import TipKit

extension Notification.Name {
    /// Posted by MacPickerView after the user copies an item. The picker panel
    /// listens for this to dismiss itself (and, in Phase 5, to trigger paste).
    static let cutlingDidPickFromPicker = Notification.Name("com.matsuokengo.Cutling.didPickFromPicker")
}

final class CutlingPickerPanel: NSPanel {
    init() {
        // Borderless: no titlebar reserves space, and there is no chrome to
        // hide. The previous `.titled + .fullSizeContentView` combination
        // still reserved a 28pt invisible band at the top.
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 320),
            styleMask: [.nonactivatingPanel, .borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        isMovableByWindowBackground = true
        isFloatingPanel = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        hidesOnDeactivate = false
        becomesKeyOnlyIfNeeded = false
        isReleasedWhenClosed = false
        animationBehavior = .utilityWindow
        hasShadow = true
        backgroundColor = .clear
        isOpaque = false
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func cancelOperation(_ sender: Any?) {
        // ⎋ dismisses the panel.
        orderOut(nil)
        NotificationCenter.default.post(name: .cutlingPickerWillHide, object: nil)
    }
}

extension Notification.Name {
    /// Internal signal that the panel hid itself (cancelOperation / outside click).
    static let cutlingPickerWillHide = Notification.Name("com.matsuokengo.Cutling.pickerWillHide")
}

@MainActor
final class CutlingPickerController {
    static let shared = CutlingPickerController()

    private var panel: CutlingPickerPanel?
    private var clickMonitor: Any?
    private(set) var previousFrontmostBundleID: String?

    private init() {
        NotificationCenter.default.addObserver(
            forName: .cutlingHotkeyPressed,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                // Donate to TipKit so the HotkeyTip retires now that the
                // user has discovered the shortcut on their own.
                HotkeyTip.hotkeyPressed.sendDonation()
                self?.toggle()
            }
        }
        NotificationCenter.default.addObserver(
            forName: .cutlingDidPickFromPicker,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in self?.handleDidPick() }
        }
        NotificationCenter.default.addObserver(
            forName: .cutlingPickerWillHide,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in self?.removeClickOutsideMonitor() }
        }
    }

    /// When the user picks an item: if the panel was the source AND we know
    /// the previous frontmost app AND Accessibility is granted, restore that
    /// app and post ⌘V into it. Otherwise: copy-only.
    private func handleDidPick() {
        let cameFromPanel = panel?.isVisible == true
        hide()
        guard cameFromPanel else { return }
        guard PasteService.shared.isTrusted else {
            print("⚠️ Cutling: auto-paste skipped, Accessibility access not granted. Open Settings → Paste.")
            return
        }
        guard let bid = previousFrontmostBundleID,
              bid != Bundle.main.bundleIdentifier,
              let app = NSRunningApplication.runningApplications(withBundleIdentifier: bid).first
        else {
            print("⚠️ Cutling: auto-paste skipped, could not resolve previous frontmost app (was \(previousFrontmostBundleID ?? "nil")).")
            return
        }
        // Resign key + hide the panel, then reactivate the previous app.
        // The 150ms delay gives the system time to actually transfer
        // frontmost status before the synthetic ⌘V arrives.
        app.activate(options: [.activateAllWindows])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            PasteService.shared.performPaste()
        }
    }

    func toggle() {
        if let panel, panel.isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        previousFrontmostBundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        let panel = panel ?? makePanel()
        self.panel = panel
        positionNearCursor(panel)
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        installClickOutsideMonitor()
    }

    func hide() {
        guard let panel, panel.isVisible else { return }
        panel.orderOut(nil)
        removeClickOutsideMonitor()
    }

    private func makePanel() -> CutlingPickerPanel {
        let panel = CutlingPickerPanel()
        // NSHostingController auto-sizes the window to the SwiftUI view's
        // ideal size. NSHostingView (used previously) doesn't propagate
        // intrinsic size to the panel, which left blank space at the top
        // and clipped content at the bottom.
        let hosting = NSHostingController(
            rootView: MacPickerView()
                .environmentObject(CutlingStore.shared)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.background)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        )
        hosting.sizingOptions = [.preferredContentSize]
        panel.contentViewController = hosting
        return panel
    }

    private func positionNearCursor(_ panel: NSPanel) {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first(where: { $0.frame.contains(mouse) }) ?? NSScreen.main
        guard let visible = screen?.visibleFrame else {
            panel.center()
            return
        }
        let size = panel.frame.size
        var origin = NSPoint(x: mouse.x + 12, y: mouse.y - size.height - 12)
        // Clamp inside the active screen.
        origin.x = max(visible.minX + 4, min(origin.x, visible.maxX - size.width - 4))
        origin.y = max(visible.minY + 4, min(origin.y, visible.maxY - size.height - 4))
        panel.setFrameOrigin(origin)
    }

    private func installClickOutsideMonitor() {
        guard clickMonitor == nil else { return }
        clickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            Task { @MainActor [weak self] in self?.hide() }
        }
    }

    private func removeClickOutsideMonitor() {
        if let m = clickMonitor {
            NSEvent.removeMonitor(m)
            clickMonitor = nil
        }
    }
}
#endif
