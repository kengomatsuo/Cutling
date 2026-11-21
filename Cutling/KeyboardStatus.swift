//
//  KeyboardStatus.swift
//  Cutling
//
//  The one reader of whether the Cutling keyboard is added and has Full Access, for every
//  setup screen. "Added" comes from the AppleKeyboards list iOS keeps in the app's defaults
//  (hex, Keyman and voicekey read the same key; docs/research/onboarding/apple/notes.md
//  rows 15-17); Full Access only from the keyboard itself, which writes its
//  `hasFullAccess` into the App Group once it has run.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#if os(iOS)
import SwiftUI

@MainActor @Observable
final class KeyboardStatus {
    private(set) var keyboardAdded = false
    private(set) var fullAccess = false

    @ObservationIgnored private var timer: Timer?

    init() { refresh() }

    func refresh() {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let keyboards = UserDefaults.standard.stringArray(forKey: "AppleKeyboards") ?? []
        let added = keyboards.contains { $0.hasPrefix(bundleID) }
        let access = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.bool(forKey: "hasFullAccess") ?? false
        // Assign only on change, so a poll that finds nothing new redraws nothing.
        if added != keyboardAdded { keyboardAdded = added }
        if access != fullAccess { fullAccess = access }
    }

    /// Polls once a second while a setup screen is up: coming back from Settings and the
    /// keyboard's first run both change the answer without any event the app can observe.
    func startPolling() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
}
#endif
