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
/// Design: docs/plans/unlock (card ASG240).
struct UnlockView: View {
    @ObservedObject private var purchases = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss
    /// Starts near the measured height (about 505 pt on a 6.3-inch iPhone at the limit): a guess far off makes the
    /// sheet rise to the guess and then drop to its content.
    @State private var sheetHeight: CGFloat = 505
    @State private var unlockedHere = false

    private var store: CutlingStore { CutlingStore.shared }
    private var used: Int { min(store.cutlings.count, Unlock.freeLimit) }

    private var subtitle: LocalizedStringKey {
        if unlockedHere { return "Thank you for supporting Cutling." }
        if used >= Unlock.freeLimit { return "You've used your \(Unlock.freeLimit) free cutlings. They stay free and keep working." }
        if used == 0 { return "You have \(Unlock.freeLimit) free cutlings." }
        return "You've used \(used) of your \(Unlock.freeLimit) free cutlings."
    }

    private var buttonTitle: LocalizedStringKey {
        if unlockedHere { return "Done" }
        if let price = purchases.displayPrice { return "Unlock for \(price)" }
        return "Unlock"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            closeButton
                .accessibilityLabel("Not Now")
                .accessibilityIdentifier("notNowButton")
                .padding(.bottom, 18)

            UnlockHero(cutlings: Array(store.cutlings.prefix(Unlock.freeLimit)), unlocked: unlockedHere)
                .padding(.bottom, 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(unlockedHere ? "Cutling Is Unlocked" : "Keep Saving")
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader)
                Text(subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, 26)

            if !unlockedHere {
                VStack(alignment: .leading, spacing: 22) {
                    UnlockRow(symbol: "square.stack.3d.up.fill", title: "Room for \(CutlingStore.maxTextCutlings.formatted())",
                              detail: "Save up to \(CutlingStore.maxTextCutlings.formatted()) texts and \(CutlingStore.maxImageCutlings) images.")
                    UnlockRow(symbol: "laptopcomputer.and.iphone", title: "iPhone, iPad and Mac",
                              detail: "One purchase covers all three on your Apple Account.")
                    UnlockRow(symbol: "checkmark.seal.fill", title: "Pay Once",
                              detail: "No subscription, no ads, no account.")
                }
                .padding(.bottom, 36) // owner, 2026-11-26: 24 sat the link too close to the last row

                Button(purchases.isRestoring ? "Restoring…" : "Restore Purchases") {
                    Task { await purchases.restore(); if purchases.isUnlocked { unlockedHere = true } }
                }
                .buttonStyle(.plain)
                .font(.subheadline)
                .foregroundStyle(.tint)
                .frame(maxWidth: .infinity)
                .disabled(purchases.isPurchasing || purchases.isRestoring)
                .accessibilityIdentifier("restorePurchasesButton")
                .padding(.bottom, 12)
            }

            primaryButton
        }
        .padding(.horizontal, 28)
        .padding(.top, 20)
        .padding(.bottom, 12)
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { sheetHeight = $0 }
        #if os(iOS)
        .presentationDetents([.height(sheetHeight)])
        .presentationDragIndicator(.hidden)
        // The cards' own colour, so the sheet reads as one more card and nothing behind it shows through the words.
        .presentationBackground(Color(uiColor: .secondarySystemGroupedBackground))
        #else
        .frame(width: 440)
        #endif
        .task { await purchases.loadProduct() }
        .alert("Purchase Didn't Go Through", isPresented: Binding(
            get: { purchases.lastError != nil },
            set: { if !$0 { purchases.lastError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchases.lastError ?? "")
        }
    }

    /// The system's own close button (iOS 26 and macOS 26), in Liquid Glass like every sheet's X; before that, the
    /// same xmark in the grey circle iOS sheets used.
    @ViewBuilder private var closeButton: some View {
        if #available(iOS 26, macOS 26, *) {
            Button(role: .close) { dismiss() }
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

    @ViewBuilder private var primaryButton: some View {
        let action = {
            if unlockedHere { dismiss(); return }
            Task {
                if await purchases.purchase() {
                    #if os(iOS)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    #endif
                    withAnimation(.spring(duration: 0.4, bounce: 0.15)) { unlockedHere = true }
                }
            }
        }
        #if os(iOS)
        AppleSheetButton(title: buttonTitle, id: "unlockButton", action: action)
            .disabled(purchases.isPurchasing)
        #else
        Button(action: action) { Text(buttonTitle).frame(maxWidth: .infinity) }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(purchases.isPurchasing)
            .accessibilityIdentifier("unlockButton")
        #endif
    }
}

/// The person's five free cutlings as tiles, a bracket under them, and the sixth tile waiting (dashed, a little
/// tilted) until the unlock fills it in.
private struct UnlockHero: View {
    let cutlings: [Cutling]
    let unlocked: Bool
    private let tile: CGFloat = 48

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(0..<Unlock.freeLimit, id: \.self) { index in
                        if index < cutlings.count {
                            let item = cutlings[index]
                            Image(systemName: item.icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(item.tintColor)
                                .frame(width: tile, height: tile)
                                .background(item.tintColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                        } else {
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .strokeBorder(.quaternary, style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                                .frame(width: tile, height: tile)
                        }
                    }
                }
                .overlay(alignment: .bottom) {
                    UnlockBracket()
                        .stroke(.tertiary, lineWidth: 1)
                        .frame(height: 6)
                        .offset(y: 12)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(Color.accentColor.opacity(unlocked ? 0.9 : 0.12))
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: 1.5, dash: unlocked ? [] : [4, 3]))
                    Image(systemName: unlocked ? "checkmark" : "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(unlocked ? Color.white : Color.accentColor)
                        .contentTransition(.symbolEffect(.replace))
                }
                .frame(width: tile, height: tile)
                .rotationEffect(.degrees(unlocked ? 0 : -5))
            }
            .padding(.bottom, 8)

            Text("\(Unlock.freeLimit) free")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(width: tile * CGFloat(Unlock.freeLimit) + 8 * CGFloat(Unlock.freeLimit - 1))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(cutlings.count) of \(Unlock.freeLimit) free cutlings used")
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
