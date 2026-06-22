//
//  MenuBarHintWindow.swift
//  Cutling: a floating callout pinned just below the Cutling menu bar
//  icon on first launch, with an upward arrow pointing at it.
//
//  Why a custom panel rather than a TipKit popoverTip: SwiftUI's
//  MenuBarExtra hides its underlying NSStatusItem, so there is no
//  SwiftUI anchor view we can attach `.popoverTip(_:)` to. We locate
//  the status item's hosting NSWindow at runtime by scanning
//  NSApp.windows for the `NSStatusBarWindow` private class name — a
//  long-standing community pattern used by every menu-bar utility that
//  needs to position auxiliary UI relative to its icon, since Apple has
//  never shipped a public API for it. Falls back to the trailing-edge
//  position if the status window isn't yet attached when we look.
//

#if os(macOS)
import AppKit
import SwiftUI

@MainActor
final class MenuBarHintController {
    static let shared = MenuBarHintController()

    private var panel: NSPanel?
    private var autoDismissTask: Task<Void, Never>?
    private let appStorageKey = "hasSeenMenuBarHint"

    private init() {}

    /// Show the hint if the user has never seen it AND has never opened
    /// the menu bar popover. Idempotent: a second call while the panel is
    /// already visible is a no-op.
    ///
    /// SwiftUI does not install the MenuBarExtra's NSStatusItem
    /// synchronously, so a call right after `WelcomeView.finish()`
    /// dismisses its window will see a nil status frame even though the
    /// icon is enabled. We poll for up to ~2 seconds before concluding
    /// the icon is genuinely hidden (System Settings → Control Center,
    /// or our own toggle). Only then do we fall back to summoning the
    /// floating picker panel so the TipKit tour can still run.
    func showIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: appStorageKey) else { return }
        guard panel == nil || panel?.isVisible == false else { return }
        Task { @MainActor in
            for _ in 0..<20 {
                if let frame = validStatusItemFrame() {
                    show(statusItemFrame: frame)
                    return
                }
                try? await Task.sleep(for: .milliseconds(100))
            }
            // Icon never materialised. Mark the hint as seen so we don't
            // retry on every launch, and route the tour through the
            // picker panel instead.
            defaults.set(true, forKey: appStorageKey)
            CutlingPickerController.shared.show()
        }
    }

    /// Dismiss the hint and mark it permanently seen, so it never shows
    /// again on this user's machine. Call from the picker view's
    /// `onAppear` so opening the menu bar dismisses the hint.
    func dismissPermanently() {
        UserDefaults.standard.set(true, forKey: appStorageKey)
        autoDismissTask?.cancel()
        autoDismissTask = nil
        panel?.orderOut(nil)
        panel = nil
    }

    private func show(statusItemFrame: NSRect) {
        let p = HintPanel()
        let host = NSHostingView(
            rootView: MenuBarHintView(
                hotkey: GlobalHotkey.shared.combo.displayString,
                onActivate: { [weak self] in
                    Task { @MainActor [weak self] in
                        // Tap the hint → open the menu-bar popover the
                        // hint was pointing at, then retire the hint.
                        AppActivationManager.shared.openMenuBarPopover()
                        self?.dismissPermanently()
                    }
                },
                onDismiss: { [weak self] in
                    Task { @MainActor [weak self] in self?.dismissPermanently() }
                }
            )
        )
        host.translatesAutoresizingMaskIntoConstraints = false
        let container = NSView(frame: .zero)
        container.addSubview(host)
        NSLayoutConstraint.activate([
            host.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            host.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            host.topAnchor.constraint(equalTo: container.topAnchor),
            host.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        p.contentView = container
        let size = host.fittingSize
        p.setContentSize(size)
        positionBelowStatusItem(p, contentSize: size, statusItemFrame: statusItemFrame)
        p.orderFrontRegardless()
        panel = p

        // Auto-dismiss after 10s so a forgotten hint doesn't linger.
        autoDismissTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(10))
            guard !Task.isCancelled else { return }
            dismissPermanently()
        }
    }

    /// Frame of the NSStatusItem's hosting window in screen coordinates,
    /// if and only if the window has non-zero size and sits inside a real
    /// screen. When the user has disabled the menu-bar icon (in System
    /// Settings → Control Center, or our own toggle while the app was
    /// running), the NSStatusBarWindow may still exist with a degenerate
    /// frame; returning nil for those cases stops us from anchoring the
    /// hint to a non-existent icon.
    ///
    /// IMPORTANT: We check against `screen.frame`, not `visibleFrame`.
    /// `visibleFrame` excludes the menu bar, but the status item lives
    /// *inside* the menu bar — so they would never intersect.
    private func validStatusItemFrame() -> NSRect? {
        let candidates = NSApp.windows.filter { $0.className == "NSStatusBarWindow" }
        #if DEBUG
        print("Cutling/MenuBarHint: scanning \(candidates.count) NSStatusBarWindow(s); screens=\(NSScreen.screens.map { $0.frame })")
        for w in candidates {
            print("  • frame=\(w.frame) visible=\(w.isVisible)")
        }
        #endif
        for window in candidates {
            let frame = window.frame
            guard frame.width > 0, frame.height > 0 else { continue }
            guard NSScreen.screens.contains(where: { $0.frame.intersects(frame) }) else { continue }
            return frame
        }
        return nil
    }

    private func positionBelowStatusItem(_ panel: NSPanel, contentSize: NSSize, statusItemFrame item: NSRect) {
        let screen = NSScreen.screens.first(where: { $0.visibleFrame.intersects(item) })
            ?? NSScreen.main
            ?? NSScreen.screens.first
        guard let visible = screen?.visibleFrame else {
            panel.center()
            return
        }
        // Align the arrow glyph (sitting at MenuBarHintView.arrowCenterX
        // from the panel's leading edge) under the icon's midX, so the
        // visual indicator actually points at the Cutling icon. Clamp
        // horizontally so the panel never spills off-screen, even if
        // that means the arrow drifts off the icon by a few pixels on
        // a status item very close to a screen edge.
        let desiredX = item.midX - MenuBarHintView.arrowCenterX
        let minX = visible.minX + 8
        let maxX = visible.maxX - contentSize.width - 8
        let x = min(max(desiredX, minX), maxX)
        let y = visible.maxY - contentSize.height - 8
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}

private final class HintPanel: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 110),
            styleMask: [.nonactivatingPanel, .borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        isFloatingPanel = true
        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        hasShadow = true
        backgroundColor = .clear
        isOpaque = false
        ignoresMouseEvents = false
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

private struct MenuBarHintView: View {
    /// Horizontal distance from the panel's leading edge to the centre
    /// of the arrow glyph. The hint controller positions the panel so
    /// this point sits under the status item's midX.
    /// Derived from: padding(14) + half of the 24pt arrow icon ≈ 26pt.
    static let arrowCenterX: CGFloat = 26

    let hotkey: String
    /// Tap on the body → synthesise a click on the menu-bar icon so the
    /// picker actually opens. Spares the user a second trip up to the
    /// menu bar after reading the hint.
    let onActivate: () -> Void
    /// Tap on the explicit ✕ → dismiss the hint without opening anything.
    let onDismiss: () -> Void
    @State private var pulse = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "arrow.up")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.tint)
                .offset(y: pulse ? -3 : 1)
                .animation(.easeInOut(duration: 0.9).repeatForever(), value: pulse)

            VStack(alignment: .leading, spacing: 4) {
                Text("Cutling is up here")
                    .font(.system(size: 14, weight: .semibold))
                Text("Click the clipboard icon, or press \(hotkey) from any app to open the picker.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(width: 320)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.25), radius: 16, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.separator.opacity(0.5), lineWidth: 0.5)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onAppear { pulse = true }
        .onTapGesture { onActivate() }
    }
}
#endif
