//
//  AddFromClipboardIntent.swift
//  Cutling
//
//  Mirrors the Control Center "Add from Clipboard" flow exactly: foreground
//  the app, set the pendingControlAction flag, and let MainContentView's
//  didBecomeActive handler do the pasteboard read + review-sheet present.
//  This keeps Siri and Control Center behaviour identical and avoids the
//  background-pasteboard-read failure mode entirely.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents

struct AddFromClipboardIntent: AppIntent {
    static var title: LocalizedStringResource = "Add from Clipboard"
    static var description = IntentDescription("Save clipboard contents as a new cutling.")

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")
        defaults?.set(CutlingScreen.addFromClipboard.rawValue, forKey: "pendingControlAction")
        return .result()
    }
}
