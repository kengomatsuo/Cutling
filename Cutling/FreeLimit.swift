//
//  FreeLimit.swift
//  Cutling
//
//  The free limit's pure rules, apart from the store so a test can compile them alone (Tests/FreeLimit).
//  Every add path asks CutlingStore.canAdd / needsUnlock, which answer from these. Design: docs/plans/unlock/cards.md U1.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import Foundation

enum FreeLimit {
    /// Cutlings that count toward the free limit: the starter "Try Me" cutling is the app's, not the person's.
    nonisolated static func counted(total: Int, starterPresent: Bool) -> Int {
        max(0, total - (starterPresent ? 1 : 0))
    }

    /// True when saving `adding` more would pass the free limit for a person who has not unlocked.
    nonisolated static func blocks(counted: Int, adding: Int = 1, limit: Int, unlocked: Bool) -> Bool {
        !unlocked && counted + adding > limit
    }

    /// What the keyboard's toast says after a clip is saved: how many free saves are left.
    enum SaveNote: Equatable { case plain, oneLeft, last }

    nonisolated static func saveNote(countedAfterSave: Int, limit: Int, unlocked: Bool) -> SaveNote {
        guard !unlocked else { return .plain }
        if countedAfterSave == limit { return .last }
        if countedAfterSave == limit - 1 { return .oneLeft }
        return .plain
    }

    /// A waiting item is dropped this long after it was written.
    nonisolated static let pendingLifetime: TimeInterval = 24 * 60 * 60

    nonisolated static func isStale(createdAt: Date, now: Date) -> Bool {
        now.timeIntervalSince(createdAt) > pendingLifetime
    }
}
