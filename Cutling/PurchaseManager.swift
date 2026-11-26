//
//  PurchaseManager.swift
//  Cutling
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import Foundation
import StoreKit
import Combine

/// Works out whether this copy is unlocked (Unlock in CutlingStore.swift) and sells the one-time unlock.
/// Unlocked means the unlock was bought on any device signed in to the same Apple Account, or the app itself was
/// acquired before `Unlock.freeSince`, when it still cost money. App Store's AppTransaction carries that original
/// purchase date, which survives deletes and reinstalls. In the sandbox it is always 2013-08-01, so TestFlight
/// copies count as bought; the `-UnlockAsNewUser` launch argument (debug builds) shows the free state instead.
@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published private(set) var isUnlocked = Unlock.isUnlocked
    @Published private(set) var product: Product?
    @Published private(set) var isPurchasing = false
    @Published var lastError: String?

    private var updates: Task<Void, Never>?

    private init() {}

    /// Called once at launch: listens for purchases made elsewhere (Ask to Buy, another device, a refund) and
    /// refreshes the answer.
    func start() {
        #if !canImport(Sparkle)
        guard updates == nil else { return }
        updates = Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result { await transaction.finish() }
                await self?.refresh()
            }
        }
        Task { await refresh(); await loadProduct() }
        #endif
    }

    func loadProduct() async {
        guard product == nil else { return }
        product = try? await Product.products(for: [Unlock.productID]).first
    }

    /// The price as the customer's own App Store shows it, such as "$4.99" or "Rp 79.000".
    var displayPrice: String? {
        #if DEBUG
        if product == nil, Self.demoStore { return "$4.99" }
        #endif
        return product?.displayPrice
    }

    #if DEBUG
    /// `-UnlockDemoStore`: a debug build with no App Store product (simulator recordings, UI tests) shows the US price
    /// and treats Unlock as an instant test purchase, without Apple's purchase sheet.
    static let demoStore = ProcessInfo.processInfo.arguments.contains("-UnlockDemoStore")
    #endif

    func refresh() async {
        if await ownsUnlock() { return apply(true) }
        guard let early = await boughtBeforeFree() else { return } // offline: keep what is stored
        apply(early)
    }

    private func ownsUnlock() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result, t.productID == Unlock.productID, t.revocationDate == nil { return true }
        }
        return false
    }

    /// nil when the App Store could not be asked (offline on first launch); the stored answer then stands.
    private func boughtBeforeFree() async -> Bool? {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-UnlockAsNewUser") { return false }
        #endif
        guard let result = try? await AppTransaction.shared else { return nil }
        guard case .verified(let app) = result else { return false }
        return app.originalPurchaseDate < Unlock.freeSince
    }

    private func apply(_ unlocked: Bool) {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-UnlockAsNewUser"), !unlocked {
            Unlock.record(false); isUnlocked = false; return
        }
        #endif
        Unlock.record(unlocked)
        isUnlocked = Unlock.isUnlocked
    }

    /// Runs the App Store purchase sheet. Returns true once the unlock is owned.
    @discardableResult
    func purchase() async -> Bool {
        await loadProduct()
        #if DEBUG
        if product == nil, Self.demoStore {
            isPurchasing = true
            try? await Task.sleep(for: .seconds(1))
            isPurchasing = false
            Unlock.record(true); isUnlocked = true
            return true
        }
        #endif
        guard let product else {
            lastError = String(localized: "The App Store can't be reached right now. Try again in a moment.")
            return false
        }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            switch try await product.purchase() {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    lastError = String(localized: "The App Store couldn't confirm this purchase.")
                    return false
                }
                await transaction.finish()
                apply(true)
                return true
            case .pending, .userCancelled:
                return false
            @unknown default:
                return false
            }
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    /// Restore Purchases: asks the App Store for this Apple Account's purchases again.
    func restore() async {
        isPurchasing = true
        defer { isPurchasing = false }
        try? await AppStore.sync()
        await refresh()
        if !isUnlocked {
            lastError = String(localized: "No Cutling purchase was found for this Apple Account.")
        }
    }
}
