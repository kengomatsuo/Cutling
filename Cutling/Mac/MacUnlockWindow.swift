//
//  MacUnlockWindow.swift
//  Cutling: the Mac App Store build's unlock window and its Settings section
//
//  Design: docs/plans/unlock (README.md, mac.png, mac-settings.png; celebration card C6). The window is its own
//  NSWindow because the menu-bar popover closes when a purchase sheet takes focus. The direct-download build (Sparkle)
//  is never gated, so nothing here is ever asked for there.
//

#if os(macOS)
import SwiftUI
import AppKit

/// What waits while the person unlocks: the glyph in the sixth tile (nil: the +), what is saved the moment the unlock
/// arrives (a duplicate, a history item, the add window's own save), and what opens after Continue (the add window).
struct MacUnlockWaiting {
    var icon: String?
    var onUnlocked: (() -> Void)?
    var onContinue: (() -> Void)?
}

/// Opens the one unlock window.
@MainActor
final class MacUnlockWindow: NSObject, NSWindowDelegate {
    static let shared = MacUnlockWindow()
    private var window: NSWindow?

    /// True when the free limit stops the next cutling on this build.
    var isNeeded: Bool { CutlingStore.shared.needsUnlock }

    func show(_ waiting: MacUnlockWaiting? = nil, surface: MacWindowSurface = .none) {
        #if DEBUG
        // Screenshot runs never take the keyboard focus (see SnapshotActiveWindows).
        if CutlingStore.isMacSnapshotMode { present(waiting); return }
        #endif
        AppActivationManager.shared.showWindow(source: surface) { [self] in present(waiting) }
    }

    private func present(_ waiting: MacUnlockWaiting?) {
        if let window, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            return
        }
        let host = NSHostingController(rootView: MacUnlockView(waiting: waiting, close: { [weak self] in self?.window?.close() }))
        // The window is as tall as the ask, once: the moment never changes it.
        host.sizingOptions = []
        let made = NSWindow(contentViewController: host)
        made.setContentSize(host.view.fittingSize)
        made.styleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView]
        made.titlebarAppearsTransparent = true
        made.titleVisibility = .hidden
        made.title = String(localized: "Unlock Cutling")
        made.isReleasedWhenClosed = false
        made.isMovableByWindowBackground = true
        made.delegate = self
        made.center()
        window = made
        made.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) { window = nil }
}

/// The window's content: the ask, and from t0 the celebration (the same clock as the iPhone's sheet, UnlockMotion).
/// The ask's views stay in the layout for the whole moment, so the window keeps its height.
struct MacUnlockView: View {
    let waiting: MacUnlockWaiting?
    let close: () -> Void

    @ObservedObject private var purchases = PurchaseManager.shared
    @ObservedObject private var store = CutlingStore.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var unlocking = false
    @State private var moment: UnlockMoment?
    @State private var room: UnlockMotion.Room?
    @State private var roomSize = CGSize.zero
    @State private var restored = false
    @State private var wasUnlocked = PurchaseManager.shared.isUnlocked

    private enum Metrics {
        static let width = 480.0, padTop = 44.0, footerHeight = 60.0
        static let tile = 40.0, gap = 8.0, cells = 8
        static let rowsWidth = 336.0
    }
    private static var heroWidth: Double { Double(Metrics.cells) * Metrics.tile + Double(Metrics.cells - 1) * Metrics.gap }
    private static var sideInset: Double { (Metrics.width - heroWidth) / 2 }

    #if DEBUG
    /// `-UnlockFreezeMs <ms>`: stops the moment at that instant after t0 (below 0: before t0), for screenshots.
    private static let freezeMs: Double? = {
        let args = ProcessInfo.processInfo.arguments
        return args.firstIndex(of: "-UnlockFreezeMs").flatMap { args.indices.contains($0 + 1) ? Double(args[$0 + 1]) : nil }
    }()
    #endif

    private var used: Int { min(store.countedCount, Unlock.freeLimit) }
    private var hasSixth: Bool { used >= Unlock.freeLimit }
    private var landsSixth: Bool { hasSixth && !restored }
    private var capacity: String { CutlingStore.maxTextCutlings.formatted() }
    private var doneTitle: LocalizedStringKey { waiting?.onContinue == nil ? "Done" : "Continue" }

    private var subtitle: LocalizedStringKey {
        if used >= Unlock.freeLimit { return "You've used your \(Unlock.freeLimit) free cutlings. They stay free and keep working." }
        if used == 0 { return "You have \(Unlock.freeLimit) free cutlings." }
        return "You've used \(used) of your \(Unlock.freeLimit) free cutlings."
    }

    private var buyTitle: LocalizedStringKey {
        if let price = purchases.displayPrice { return "Unlock for \(price)" }
        return "Unlock"
    }

    private var doneSubtitle: LocalizedStringKey {
        restored ? "Welcome back. Your purchase is restored." : "Thank you for supporting Cutling."
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: nil, paused: moment?.settled ?? true)) { timeline in
            window(shown(at: timeline.date))
        }
        .frame(width: Metrics.width)
        // The mock's window surface, a step off the system's white so the tiles read; the title bar's inset is not
        // added to the 44 pt above the tiles.
        .background(Color(nsColor: .underPageBackgroundColor))
        .ignoresSafeArea(.container, edges: .top)
        .task { await purchases.loadProduct() }
        // Every way to "unlocked while the window is open" (the purchase, a restore, an approval, the update stream)
        // arrives here; the first one saves what waits and starts the moment, a second changes nothing.
        .task(id: purchases.isUnlocked) {
            if purchases.isUnlocked, !wasUnlocked { try? await celebrate() }
        }
        .alert("Purchase Didn't Go Through", isPresented: Binding(
            get: { purchases.lastError != nil },
            set: { if !$0 { purchases.lastError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchases.lastError ?? "")
        }
    }

    // MARK: Moment

    /// The ask at the Mac's tile and gap (the shared `Frame.ask` is the iPhone's 48 and 10).
    private static func askFrame(reduced: Bool) -> UnlockMotion.Frame {
        var f = UnlockMotion.Frame.ask
        f.pitch = Metrics.tile + Metrics.gap
        f.tileRatio = Metrics.tile / f.pitch
        if reduced { f.sixthRotation = 0 }
        return f
    }

    private func shown(at date: Date) -> UnlockShown {
        var t = moment?.ms(at: date) ?? 0
        #if DEBUG
        if let frozen = Self.freezeMs { t = frozen }
        #endif
        return UnlockShown.at(t, ask: Self.askFrame(reduced: moment?.reduced ?? reduceMotion), moment: moment, room: room)
    }

    /// Saves what waits, waits a beat, then starts the one clock every frame reads. No haptic on the Mac.
    private func celebrate() async throws {
        guard moment == nil, !unlocking else { return }
        unlocking = true
        waiting?.onUnlocked?()
        let reduced = reduceMotion
        room = UnlockMotion.Room(capacity: CutlingStore.maxTextCutlings, limit: Unlock.freeLimit, sixth: landsSixth,
                                 width: roomSize.width, height: roomSize.height, heroTile: Metrics.tile, heroGap: Metrics.gap)
        try await Task.sleep(for: .milliseconds(UnlockMotion.beatMs))
        #if DEBUG
        if let frozen = Self.freezeMs, frozen < 0 { return }
        #endif
        var cut = Transaction(animation: nil)
        cut.disablesAnimations = true
        withTransaction(cut) { moment = UnlockMoment(start: Date(), reduced: reduced) }
        AccessibilityNotification.Announcement(String(localized: "Cutling is unlocked. Room for \(capacity).")).post()
        #if DEBUG
        if Self.freezeMs != nil { self.moment?.settled = true; return }
        #endif
        while let moment, !moment.isOver(at: Date()) { try await Task.sleep(for: .milliseconds(50)) }
        self.moment?.settled = true
    }

    /// A click on the window (not a button) takes every element to its end in 150 ms.
    private func jumpToEnd() { _ = moment?.jumpToEnd(at: Date()) }

    // MARK: Layout

    private func window(_ s: UnlockShown) -> some View {
        let f = s.frame
        let done = moment != nil
        return VStack(spacing: 0) {
            VStack(spacing: 0) {
                hero(s).padding(.top, Metrics.padTop).padding(.bottom, 18)
                Text("Keep Saving")
                    .font(.system(size: 22, weight: .bold))
                    .accessibilityAddTraits(.isHeader)
                    .opacity(f.exit[0])
                    .padding(.bottom, 6)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: Metrics.rowsWidth)
                    .opacity(f.exit[1])
                    .padding(.bottom, 22)
                VStack(alignment: .leading, spacing: 16) {
                    MacUnlockRow(symbol: "square.stack.3d.up.fill", title: "Room for \(capacity)",
                                 detail: "Save up to \(capacity) texts and \(CutlingStore.maxImageCutlings) images.")
                        .opacity(f.exit[2])
                    MacUnlockRow(symbol: "laptopcomputer.and.iphone", title: "iPhone, iPad and Mac",
                                 detail: "One purchase covers all three on your Apple Account.")
                        .opacity(f.exit[3])
                    MacUnlockRow(symbol: "checkmark.seal.fill", title: "Pay Once",
                                 detail: "No subscription, no ads, no account.")
                        .opacity(f.exit[4])
                }
                .frame(width: Metrics.rowsWidth)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity)
            .allowsHitTesting(!unlocking)
            .accessibilityHidden(done)
            .overlay { doneLayer(s) }
            footer(f)
        }
        .contentShape(Rectangle())
        .onTapGesture { jumpToEnd() }
    }

    /// The person's tiles, the sixth, and two spare slots in a row; the stage draws the tiles, so the same views are the
    /// ask before t0 and the room's corner after.
    private func hero(_ s: UnlockShown) -> some View {
        let f = s.frame
        let fiveWidth = Metrics.tile * 5 + Metrics.gap * 4
        return VStack(spacing: 0) {
            Color.clear
                .frame(width: Self.heroWidth, height: Metrics.tile)
                .overlay(alignment: .bottomLeading) {
                    MacUnlockBracket()
                        .stroke(.tertiary, lineWidth: 1)
                        .frame(width: fiveWidth, height: 6)
                        .offset(y: 17)
                        .opacity(f.extras)
                }
                .overlay(alignment: .topLeading) {
                    ZStack(alignment: .topLeading) {
                        ghosts(f)
                        stage(f, slotsAt: s.slotsAt, settle: s.settle)
                            .opacity(s.end == nil ? 1 : f.extras)
                        if let end = s.end {
                            stage(end, slotsAt: UnlockMotion.endMs + UnlockMotion.cellSettledMs, settle: 0)
                                .opacity(end.roomOpacity)
                        }
                    }
                }
            Text("\(Unlock.freeLimit) free")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .frame(width: fiveWidth, height: 14)
                .opacity(f.extras)
                .padding(.top, 20)
                .frame(width: Self.heroWidth, alignment: .leading)
        }
        .zIndex(1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(store.countedCount) of \(Unlock.freeLimit) free cutlings used")
        .accessibilityHidden(moment != nil)
    }

    /// The ask's spare slots after the sixth tile; they go as the room's own slots appear in their place.
    private func ghosts(_ f: UnlockMotion.Frame) -> some View {
        let first = Unlock.freeLimit + (hasSixth ? 1 : 0)
        return ZStack(alignment: .topLeading) {
            ForEach(first..<Metrics.cells, id: \.self) { index in
                RoundedRectangle(cornerRadius: f.tileSize * UnlockSlots.radiusRatio)
                    .strokeBorder(.quaternary, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .frame(width: f.tileSize, height: f.tileSize)
                    .offset(x: Double(index) * f.pitch)
                    .opacity((index == Metrics.cells - 1 ? 0.5 : 1) * f.extras)
            }
        }
        .allowsHitTesting(false)
    }

    private func stage(_ f: UnlockMotion.Frame, slotsAt: Double?, settle: Double) -> some View {
        UnlockStage(cutlings: Array(store.countedCutlings.prefix(Unlock.freeLimit)), hasSixth: hasSixth, sixthLeaves: restored,
                    frame: f, room: room, slotsAt: slotsAt, settle: settle, roomSize: roomSize, trailingPadding: 0,
                    waitingIcon: waiting?.icon)
    }

    /// What the window says after the purchase, in the space the ask's words leave: the room's frame, the title and the
    /// subtitle. The room shows plenty of slots in full rows, never a count. It sits over the ask, so it never changes the
    /// window's height.
    private func doneLayer(_ s: UnlockShown) -> some View {
        let f = s.end ?? s.frame
        return VStack(spacing: 0) {
            Color.clear
                .frame(maxWidth: .infinity, minHeight: UnlockMotion.minRoomHeight, maxHeight: .infinity)
                .onGeometryChange(for: CGSize.self) { $0.size } action: { roomSize = $0 }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(store.cutlings.count) cutlings saved. Room for \(capacity).")
            VStack(spacing: 6) {
                Text("It's All Yours")
                    .font(.system(size: 22, weight: .bold))
                    .accessibilityAddTraits(.isHeader)
                    .opacity(f.titleOpacity)
                    .offset(y: f.titleDY)
                Text(doneSubtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(f.subtitleOpacity)
                    .offset(y: f.subtitleDY)
            }
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .padding(.top, Metrics.padTop)
        .padding(.horizontal, Self.sideInset)
        .accessibilityHidden(moment == nil)
        .allowsHitTesting(false)
    }

    // MARK: Footer

    /// Restore Purchases on the left; Not Now and the default button on the right. Escape closes at any instant, Return
    /// runs the default button once it is live.
    private func footer(_ f: UnlockMotion.Frame) -> some View {
        let live = moment != nil
        return HStack(spacing: 8) {
            Button(purchases.isRestoring ? "Restoring…" : "Restore Purchases") {
                restored = true
                Task { await purchases.restore(); if !purchases.isUnlocked { restored = false } }
            }
            .buttonStyle(.plain)
            .font(.system(size: 13))
            .foregroundStyle(Color.macBrandText)
            .disabled(purchases.isPurchasing || purchases.isRestoring || unlocking)
            .accessibilityIdentifier("restorePurchasesButton")
            .opacity(f.exit[5])
            Spacer(minLength: 12)
            Button("Not Now") { close() }
                .buttonStyle(MacUnlockButtonStyle(prominent: false))
                .disabled(unlocking)
                .opacity(f.exit[5])
                .allowsHitTesting(!live)
                .accessibilityHidden(live)
                .accessibilityIdentifier("notNowButton")
            Button {
                if live {
                    close()
                    waiting?.onContinue?()
                } else {
                    Task { await purchases.purchase() }
                }
            } label: {
                ZStack {
                    Text(buyTitle).opacity(f.buttonBuyLabel)
                    Text(doneTitle).opacity(f.buttonDoneLabel)
                }
            }
            .buttonStyle(MacUnlockButtonStyle(prominent: true))
            .keyboardShortcut(.defaultAction)
            .disabled(!live && (purchases.isPurchasing || unlocking))
            .accessibilityLabel(live ? doneTitle : buyTitle)
            .accessibilityIdentifier("unlockButton")
        }
        .padding(.horizontal, 16)
        .frame(height: Metrics.footerHeight)
        .background(Color.primary.opacity(0.04))
        .overlay(alignment: .top) { Divider() }
        .background {
            // Escape closes the window at any instant, whatever has faded.
            Button("", action: close).keyboardShortcut(.cancelAction).opacity(0).allowsHitTesting(false).accessibilityHidden(true)
        }
    }
}

/// The mock's footer buttons: 28 pt capsules, the default one in the brand green with a white 13 pt semibold label.
private struct MacUnlockButtonStyle: ButtonStyle {
    let prominent: Bool
    @Environment(\.isEnabled) private var enabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: prominent ? .semibold : .regular))
            .foregroundStyle(prominent ? Color.white : Color.primary)
            .padding(.horizontal, 14)
            .frame(height: 28)
            .background {
                if prominent {
                    Capsule().fill(Color.brandGreen)
                } else {
                    Capsule().fill(Color(nsColor: .controlBackgroundColor))
                        .overlay(Capsule().strokeBorder(Color.primary.opacity(0.14), lineWidth: 0.5))
                }
            }
            .opacity(configuration.isPressed ? 0.8 : 1)
            .opacity(enabled || prominent ? 1 : 0.5)
    }
}

private struct MacUnlockRow: View {
    let symbol: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 20))
                .foregroundStyle(Color.brandGreen)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                Text(title).font(.system(size: 13, weight: .semibold))
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// A thin bracket: a line with short ends turned up.
private struct MacUnlockBracket: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return p
    }
}

extension Color {
    /// The brand green as text: #00875F on light (4.5:1 on white), the brand green on dark.
    static var macBrandText: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0, green: 0xBE / 255, blue: 0x86 / 255, alpha: 1)
                : NSColor(red: 0, green: 0x87 / 255, blue: 0x5F / 255, alpha: 1)
        })
    }
}

// MARK: - Settings

/// The "Cutling" section at the top of General: how many free cutlings are used and the way to unlock, or the thanks.
/// Not built into the direct-download build, which is never gated.
struct MacUnlockSettingsSection: View {
    @ObservedObject private var purchases = PurchaseManager.shared
    @ObservedObject private var store = CutlingStore.shared

    private var used: Int { min(store.countedCount, Unlock.freeLimit) }

    var body: some View {
        Section {
            if purchases.isUnlocked {
                Label("Cutling Unlocked", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.primary)
                    .symbolRenderingMode(.hierarchical)
                    .tint(Color.brandGreen)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Label("Free Cutlings", systemImage: "square.stack.3d.up")
                        Spacer()
                        Text("\(used) of \(Unlock.freeLimit)").foregroundStyle(.secondary)
                    }
                    ProgressView(value: Double(used), total: Double(Unlock.freeLimit))
                        .tint(Color.brandGreen)
                        .accessibilityHidden(true)
                }
                HStack(spacing: 8) {
                    Spacer()
                    Button(purchases.isRestoring ? "Restoring…" : "Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .disabled(purchases.isRestoring || purchases.isPurchasing)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    Button("Unlock Cutling…") { MacUnlockWindow.shared.show() }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .tint(Color.brandGreen)
                }
            }
        } header: {
            Text("Cutling")
        } footer: {
            Text(footer)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .alert("Purchase Didn't Go Through", isPresented: Binding(
            get: { purchases.lastError != nil },
            set: { if !$0 { purchases.lastError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchases.lastError ?? "")
        }
    }

    private var footer: LocalizedStringKey {
        if !purchases.isUnlocked { return "One purchase unlocks Cutling on iPhone, iPad and Mac." }
        return purchases.boughtEarly
            ? "You bought Cutling before it went free, so it stays unlocked. Thank you."
            : "Unlocked on iPhone, iPad and Mac with this Apple Account."
    }
}
#endif
