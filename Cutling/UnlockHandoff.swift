//
//  UnlockHandoff.swift
//  Cutling
//
//  Save Text and Save Image at the free limit: on iOS 26 and later the Shortcut asks to continue in Cutling with the
//  item waiting in Pending/, and the unlock sheet opens with it; earlier systems stop with a message and save nothing.
//  Design: docs/plans/unlock/cards.md U6.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents
#if os(iOS)
import UIKit
#endif

@MainActor
enum UnlockHandoff {
    /// The dialog the intent returns once the free limit has stopped it.
    static func ask(_ intent: some AppIntent, cutling: Cutling, imageData: Data?) async throws -> IntentDialog {
        if #available(iOS 26.0, macOS 26.0, *), intent.systemContext.currentMode.canContinueInForeground || intent.systemContext.currentMode == .foreground {
            // The item goes to Pending/ before the ask; declining writes nothing.
            PendingCutlings.write([cutling], images: imageData.map { [cutling.id: $0] } ?? [:], savesOnUnlock: false)
            if intent.systemContext.currentMode != .foreground {
                do {
                    try await intent.continueInForeground(
                        IntentDialog(stringLiteral: String(localized: "You've used your \(Unlock.freeLimit) free cutlings. Continue in Cutling to unlock and save this.")),
                        alwaysConfirm: true
                    )
                } catch {
                    PendingCutlings.clear()
                    throw error
                }
            }
            #if os(iOS)
            if let url = URL(string: "cutling://unlock") { _ = await UIApplication.shared.open(url) }
            #else
            MacUnlockWindow.shared.show(MacUnlockWaiting(icon: cutling.icon, onUnlocked: { CutlingStore.shared.savePending() }))
            #endif
            return IntentDialog(stringLiteral: String(localized: "Unlock Cutling"))
        }
        return IntentDialog(stringLiteral: String(localized: "You've used your \(Unlock.freeLimit) free cutlings. Open Cutling to unlock more."))
    }
}
