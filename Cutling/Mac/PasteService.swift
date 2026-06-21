//
//  PasteService.swift
//  Cutling — synthesizes ⌘V into the frontmost app.
//
//  macOS requires Accessibility permission to post key events into other apps.
//  CGEvent posts to the system HID tap silently fail without it. We expose a
//  trust check + prompt, fall back to copy-only otherwise, and provide a
//  deep link into System Settings → Privacy & Security → Accessibility for
//  the case where the prompt has already been dismissed this launch.
//

#if os(macOS)
import AppKit
import ApplicationServices

@MainActor
final class PasteService {
    static let shared = PasteService()

    /// kVK_ANSI_V — Carbon virtual key code for the V key on a US layout.
    /// Other layouts: posting at the virtual-key level still produces a paste
    /// because ⌘V is layout-independent at the system event level.
    private let vKeyCode: CGKeyCode = 0x09

    private init() {}

    var isTrusted: Bool {
        AXIsProcessTrusted()
    }

    /// Prompts the user (system dialog) to grant Accessibility access.
    /// The system only shows this dialog once per app launch, so callers
    /// should also offer a System Settings deep link as a fallback.
    @discardableResult
    func requestTrustIfNeeded() -> Bool {
        let options = unsafe [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    /// Posts ⌘V to the system event tap. The pasteboard and frontmost app
    /// must already be set up before this is called.
    func performPaste() {
        guard isTrusted else { return }
        let src = CGEventSource(stateID: .hidSystemState)
        let down = CGEvent(keyboardEventSource: src, virtualKey: vKeyCode, keyDown: true)
        down?.flags = .maskCommand
        down?.post(tap: .cghidEventTap)
        let up = CGEvent(keyboardEventSource: src, virtualKey: vKeyCode, keyDown: false)
        up?.flags = .maskCommand
        up?.post(tap: .cghidEventTap)
    }

    /// Opens the Accessibility pane in System Settings.
    func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
#endif
