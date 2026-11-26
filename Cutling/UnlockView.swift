//
//  UnlockView.swift
//  Cutling
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI

/// "Keep Saving": asks a free copy to unlock Cutling once. The person's own five cutlings stand in a row with a sixth,
/// dashed tile waiting, so the ask shows what they have and what the purchase adds. Opened by LimitAlert at the free
/// limit, by the `cutling://unlock` link from the keyboard and the Share sheet, and from Settings.
/// After the purchase the sheet plays the celebration (docs/plans/unlock/celebration): the sixth tile lands, the room
/// opens to 5,000 slots, "It's All Yours" rises in, 2.2 seconds from one clock. The ask's views stay in the layout for
/// the whole moment, so the sheet keeps its height and the button stays under the thumb.
/// Design: docs/plans/unlock (card ASG240).
struct UnlockView: View {
    /// Runs after the sheet has left, when the button reads Continue (opened from +, so the new cutling's editor opens).
    var onContinue: (() -> Void)?

    @ObservedObject private var purchases = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var scheme
    /// Start near the measured heights (about 505 pt in all on a 6.3-inch iPhone at the limit): a guess far off makes
    /// the sheet rise to the guess and then drop to its content.
    @State private var contentHeight: CGFloat = 449
    @State private var buttonHeight: CGFloat = 56
    /// The detent is the ask's own height plus the button; the system caps it at the screen, and the ask then scrolls.
    /// The moment never changes it, because the ask's views stay in the layout.
    private var sheetHeight: CGFloat { contentHeight + buttonHeight }
    /// The purchase went through and t0 has not come: the button keeps its purchase-in-flight look.
    @State private var unlocking = false
    @State private var moment: UnlockMoment?
    @State private var room: UnlockMotion.Room?
    @State private var roomSize = CGSize.zero
    @State private var restored = false
    @State private var wasUnlocked = PurchaseManager.shared.isUnlocked
    @AccessibilityFocusState private var titleFocused: Bool

    private static let padding: CGFloat = 28

    #if DEBUG
    /// `-UnlockFreezeMs <ms>`: a debug build stops the moment at that instant after t0 (below 0: before t0, the button
    /// still in flight), for screenshots at the instants of the design's contact sheet.
    private static let freezeMs: Double? = {
        let args = ProcessInfo.processInfo.arguments
        return args.firstIndex(of: "-UnlockFreezeMs").flatMap { args.indices.contains($0 + 1) ? Double(args[$0 + 1]) : nil }
    }()
    #endif

    private var store: CutlingStore { CutlingStore.shared }
    private var used: Int { min(store.cutlings.count, Unlock.freeLimit) }
    /// The sixth tile waits only when the five are full; below the limit the ask shows spare slots instead.
    private var hasSixth: Bool { used >= Unlock.freeLimit }
    private var landsSixth: Bool { hasSixth && !restored }

    private var subtitle: LocalizedStringKey {
        if used >= Unlock.freeLimit { return "You've used your \(Unlock.freeLimit) free cutlings. They stay free and keep working." }
        if used == 0 { return "You have \(Unlock.freeLimit) free cutlings." }
        return "You've used \(used) of your \(Unlock.freeLimit) free cutlings."
    }

    private var doneSubtitle: LocalizedStringKey {
        restored ? "Welcome back. Your purchase is restored." : "Thank you for supporting Cutling."
    }

    private var buyTitle: LocalizedStringKey {
        if let price = purchases.displayPrice { return "Unlock for \(price)" }
        return "Unlock"
    }

    private var doneTitle: LocalizedStringKey { onContinue == nil ? "Done" : "Continue" }

    private var capacity: String { CutlingStore.maxTextCutlings.formatted() }

    var body: some View {
        TimelineView(.animation(minimumInterval: nil, paused: moment?.settled ?? true)) { timeline in
            sheet(shown(at: timeline.date))
        }
        #if os(iOS)
        .presentationDetents([.height(sheetHeight)])
        .presentationDragIndicator(.hidden)
        // The cards' own colour, so the sheet reads as one more card and nothing behind it shows through the words.
        .presentationBackground(Color(uiColor: .secondarySystemGroupedBackground))
        #else
        .frame(width: 440)
        #endif
        #if os(iOS)
        // Compiles the room's shader now, off the main thread, so t0 never waits for it. Measured in the simulator: waiting
        // 600 ms first put a 100 ms main-thread gap right after the slide in all four runs; CutlingApp warms it at launch too.
        .task { await Task.detached { _ = UnlockMetal.shared }.value }
        #endif
        #if DEBUG && os(iOS)
        .onAppear { UnlockFrameMeter.shared.slide() }
        #endif
        .task { await purchases.loadProduct() }
        // Every way to "unlocked while the sheet is open" (the purchase, a restore, an approval, the update stream) arrives
        // here; the first one starts the moment and a second changes nothing.
        .task(id: purchases.isUnlocked) {
            if purchases.isUnlocked, !wasUnlocked { try? await celebrate() }
        }
        #if os(iOS)
        .onChange(of: scenePhase) { _, phase in if phase != .active { UnlockHaptics.shared.stop(hit: false) } }
        .onDisappear { UnlockHaptics.shared.stop(hit: false) }
        #endif
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

    private func shown(at date: Date) -> UnlockShown {
        var ask = UnlockMotion.Frame.ask
        if moment?.reduced ?? (reduceMotion || Self.prefersCrossFade) { ask.sixthRotation = 0 }
        var t = moment?.ms(at: date) ?? 0
        #if DEBUG
        if let frozen = Self.freezeMs { t = frozen }
        #endif
        return UnlockShown.at(t, ask: ask, moment: moment, room: room)
    }

    private static var prefersCrossFade: Bool {
        #if os(iOS)
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-UnlockReduceMotion") { return true }
        #endif
        return UIAccessibility.prefersCrossFadeTransitions
        #else
        false
        #endif
    }

    /// Waits for the scene to be active after Apple's sheet and a beat, then starts the one clock every frame reads.
    private func celebrate() async throws {
        guard moment == nil, !unlocking else { return }
        unlocking = true
        let reduced = reduceMotion || Self.prefersCrossFade
        // The room is laid out while the beat runs, from the frame the done words leave.
        let laid = UnlockMotion.Room(capacity: CutlingStore.maxTextCutlings, limit: Unlock.freeLimit, sixth: landsSixth,
                                     width: roomSize.width, height: roomSize.height)
        #if DEBUG && os(iOS)
        UnlockFrameMeter.shared.noted(laid, size: roomSize)
        #endif
        room = laid
        #if os(iOS)
        while UIApplication.shared.applicationState != .active { try await Task.sleep(for: .milliseconds(50)) }
        #endif
        try await Task.sleep(for: .milliseconds(UnlockMotion.beatMs))
        #if DEBUG
        if let frozen = Self.freezeMs, frozen < 0 { return }
        #endif
        var cut = Transaction(animation: nil)
        cut.disablesAnimations = true
        withTransaction(cut) { moment = UnlockMoment(start: Date(), reduced: reduced) }
        #if os(iOS)
        UnlockHaptics.shared.play(reduceMotion: reduced)
        // After t0's first frame has been drawn: the announcement is not part of the picture.
        let announcement = String(localized: "Cutling is unlocked. Room for \(capacity).")
        Task { try? await Task.sleep(for: .milliseconds(100)); AccessibilityNotification.Announcement(announcement).post() }
        #endif
        #if DEBUG && os(iOS)
        UnlockFrameMeter.shared.begin()
        #endif
        #if DEBUG
        if Self.freezeMs != nil { self.moment?.settled = true; return }
        #endif
        while let moment, !moment.isOver(at: Date()) { try await Task.sleep(for: .milliseconds(50)) }
        self.moment?.settled = true
        titleFocused = true
        #if DEBUG && os(iOS)
        UnlockFrameMeter.shared.end()
        #endif
    }

    /// A tap on the sheet (not the X or the button) takes every element to its end in 150 ms.
    private func jumpToEnd() {
        guard let t = moment?.jumpToEnd(at: Date()) else { return }
        #if os(iOS)
        UnlockHaptics.shared.stop(hit: t < UnlockMotion.landMs)
        #else
        _ = t
        #endif
    }

    // MARK: Layout

    private func sheet(_ s: UnlockShown) -> some View {
        let f = s.frame
        let done = moment != nil
        return VStack(alignment: .leading, spacing: 0) {
            // The ask scrolls only when it is taller than the screen (the largest text sizes) and does not bounce when
            // it fits; the button stays below it, always reachable.
            ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                closeButton.hidden().padding(.bottom, 18)
                hero(s).padding(.bottom, 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Keep Saving")
                        .font(.title.bold())
                        .accessibilityAddTraits(.isHeader)
                        .opacity(f.exit[0])
                    Text(subtitle)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(f.exit[1])
                }
                .padding(.bottom, 26)

                VStack(alignment: .leading, spacing: 22) {
                    UnlockRow(symbol: "square.stack.3d.up.fill", title: "Room for \(capacity)",
                              detail: "Save up to \(capacity) texts and \(CutlingStore.maxImageCutlings) images.")
                        .opacity(f.exit[2])
                    UnlockRow(symbol: "laptopcomputer.and.iphone", title: "iPhone, iPad and Mac",
                              detail: "One purchase covers all three on your Apple Account.")
                        .opacity(f.exit[3])
                    UnlockRow(symbol: "checkmark.seal.fill", title: "Pay Once",
                              detail: "No subscription, no ads, no account.")
                        .opacity(f.exit[4])
                }
                .padding(.bottom, 36) // owner, 2026-11-26: 24 sat the link too close to the last row

                Button(purchases.isRestoring ? "Restoring…" : "Restore Purchases") {
                    restored = true
                    #if os(iOS)
                    UnlockHaptics.shared.prepare()
                    #endif
                    Task { await purchases.restore(); if !purchases.isUnlocked { restored = false } }
                }
                .buttonStyle(.plain)
                .font(.subheadline)
                .foregroundStyle(.tint)
                .frame(maxWidth: .infinity)
                .disabled(purchases.isPurchasing || purchases.isRestoring || unlocking)
                .accessibilityIdentifier("restorePurchasesButton")
                .opacity(f.exit[5])
                .padding(.bottom, 12)
            }
            .allowsHitTesting(!unlocking)
            .accessibilityHidden(done)
            .overlay { doneLayer(s) }
            .overlay(alignment: .topLeading) {
                closeButton
                    .accessibilityLabel("Not Now")
                    .accessibilityIdentifier("notNowButton")
            }
            .padding(.horizontal, Self.padding)
            .padding(.top, 20)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { contentHeight = $0 }
            }
            .scrollBounceBehavior(.basedOnSize)

            primaryButton(f)
                .padding(.horizontal, Self.padding)
                .padding(.bottom, 12)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { buttonHeight = $0 }
        }
        .contentShape(Rectangle())
        .onTapGesture { jumpToEnd() }
    }

    /// The person's tiles and the sixth, as a row in the ask. Their space is reserved here and the stage draws them, so the
    /// same views are the ask before t0 and the room's corner after.
    private func hero(_ s: UnlockShown) -> some View {
        let fiveWidth = UnlockMotion.heroTile * 5 + UnlockMotion.heroGap * 4
        let f = s.frame
        return VStack(alignment: .leading, spacing: 6) {
            Color.clear
                .frame(maxWidth: .infinity, minHeight: UnlockMotion.heroTile, maxHeight: UnlockMotion.heroTile)
                .overlay(alignment: .bottomLeading) {
                    UnlockBracket()
                        .stroke(.tertiary, lineWidth: 1)
                        .frame(width: fiveWidth, height: 6)
                        .offset(y: 12)
                        .opacity(f.extras)
                }
                .overlay(alignment: .topLeading) {
                    ZStack(alignment: .topLeading) {
                        stage(f, slotsAt: s.slotsAt, settle: s.settle)
                            .opacity(s.end == nil ? 1 : f.extras)
                        if let end = s.end {
                            stage(end, slotsAt: UnlockMotion.endMs + UnlockMotion.cellSettledMs, settle: 0)
                                .opacity(end.roomOpacity)
                        }
                    }
                }
                .padding(.bottom, 8)

            Text("\(Unlock.freeLimit) free")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(width: fiveWidth)
                .opacity(f.extras)
        }
        .zIndex(1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(store.cutlings.count) of \(Unlock.freeLimit) free cutlings used")
        .accessibilityHidden(moment != nil)
    }

    private func stage(_ f: UnlockMotion.Frame, slotsAt: Double?, settle: Double) -> some View {
        UnlockStage(cutlings: Array(store.cutlings.prefix(Unlock.freeLimit)), hasSixth: hasSixth, sixthLeaves: restored,
                    frame: f, room: room, slotsAt: slotsAt, settle: settle, roomSize: roomSize, trailingPadding: Self.padding)
    }

    /// What the sheet says after the purchase, in the space the ask's words leave: the room's frame, the title and the
    /// subtitle. The room shows plenty of slots in full rows, never a count (owner, 2026-11-26). It sits over the ask, so it never changes the sheet's height.
    private func doneLayer(_ s: UnlockShown) -> some View {
        let f = s.end ?? s.frame
        return VStack(alignment: .leading, spacing: 0) {
            closeButton.hidden().padding(.bottom, 18)
            Color.clear
                .frame(maxWidth: .infinity, minHeight: UnlockMotion.minRoomHeight, maxHeight: .infinity)
                .onGeometryChange(for: CGSize.self) { $0.size } action: { roomSize = $0 }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(store.cutlings.count) cutlings saved. Room for \(capacity).")
            VStack(alignment: .leading, spacing: 4) {
                Text("It's All Yours")
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("unlockDoneTitle")
                    .accessibilityFocused($titleFocused)
                    .opacity(f.titleOpacity)
                    .offset(y: f.titleDY)
                Text(doneSubtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(f.subtitleOpacity)
                    .offset(y: f.subtitleDY)
            }
            .padding(.top, 28)
            .padding(.bottom, 28)
        }
        .accessibilityHidden(moment == nil)
        .allowsHitTesting(false)
    }

    /// The system's own close button (iOS 26 and macOS 26), in Liquid Glass like every sheet's X; before that, the
    /// same xmark in the grey circle iOS sheets used.
    @ViewBuilder private var closeButton: some View {
        if #available(iOS 26, macOS 26, *) {
            // The role-only init draws the word "Close" beside the xmark outside a toolbar on iOS 27; icon only, as sheets show it.
            Button(role: .close) { dismiss() } label: { Label("Close", systemImage: "xmark").labelStyle(.iconOnly) }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
        } else {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
                    .background(.quaternary, in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    /// The buy label and the done label are two texts that cross-fade, so they are never both visible. Until t0 the button
    /// is disabled, the purchase-in-flight look; from t0 it is live.
    @ViewBuilder private func primaryButton(_ f: UnlockMotion.Frame) -> some View {
        let live = moment != nil
        let action = {
            if live {
                dismiss()
                onContinue?()
                return
            }
            #if os(iOS)
            UnlockHaptics.shared.prepare()
            #endif
            Task { await purchases.purchase() }
        }
        let label = ZStack {
            Text(buyTitle).opacity(f.buttonBuyLabel)
            Text(doneTitle).opacity(f.buttonDoneLabel)
        }
        #if os(iOS)
        Button(action: action) {
            label
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .modifier(ProminentCapsuleButton())
        .disabled(!live && (purchases.isPurchasing || unlocking))
        .animation(.timingCurve(0, 0, 0.58, 1, duration: UnlockMotion.buttonMs / 1000), value: live)
        .accessibilityLabel(live ? doneTitle : buyTitle)
        .accessibilityIdentifier("unlockButton")
        #else
        Button(action: action) { label.frame(maxWidth: .infinity) }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!live && (purchases.isPurchasing || unlocking))
            .accessibilityIdentifier("unlockButton")
        #endif
    }
}

/// A thin bracket: a line with short ends turned up.
private struct UnlockBracket: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return p
    }
}

private struct UnlockRow: View {
    let symbol: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 28))
                .foregroundStyle(.tint)
                .frame(width: 40)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
