//
//  UnlockView.swift
//  Cutling
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI

/// Asks a free copy to unlock unlimited cutlings with the one-time purchase. Opened by LimitAlert at the
/// free limit, by the `cutling://unlock` link from the keyboard and the Share sheet, and from Settings.
struct UnlockView: View {
    @ObservedObject private var purchases = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss

    private var buttonTitle: LocalizedStringKey {
        if let price = purchases.displayPrice { return "Unlock for \(price)" }
        return "Unlock Cutling"
    }

    var body: some View {
        AppleSheetPage(
            title: "Keep Everything You Type",
            subtitle: "Your 5 free cutlings are full. Unlock Cutling once to save as many as you like.",
            buttonTitle: buttonTitle,
            buttonEnabled: !purchases.isPurchasing,
            buttonID: "unlockButton",
            action: { Task { if await purchases.purchase() { dismiss() } } }
        ) {
            AppleSheetRows(rows: [
                AppleSheetRow(symbol: "square.stack.3d.up.fill", title: "Room for Thousands",
                              detail: "Up to 5,000 text and 500 image cutlings: addresses, account numbers, replies and photos."),
                AppleSheetRow(symbol: "laptopcomputer.and.iphone", title: "iPhone, iPad and Mac",
                              detail: "One purchase unlocks Cutling on every device signed in to your Apple Account."),
                AppleSheetRow(symbol: "checkmark.seal", title: "Yours for Good",
                              detail: "Pay once. No subscription, no ads, no account."),
            ])
        } footer: {
            HStack(spacing: 24) {
                Button("Restore Purchases") { Task { await purchases.restore(); if purchases.isUnlocked { dismiss() } } }
                    .accessibilityIdentifier("restorePurchasesButton")
                Button("Not Now") { dismiss() }
                    .accessibilityIdentifier("notNowButton")
            }
            .font(.subheadline)
            .disabled(purchases.isPurchasing)
        }
        .task { await purchases.loadProduct() }
        .alert("Purchase", isPresented: Binding(
            get: { purchases.lastError != nil },
            set: { if !$0 { purchases.lastError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchases.lastError ?? "")
        }
    }
}
