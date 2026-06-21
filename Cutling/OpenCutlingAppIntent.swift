//
//  OpenCutlingAppIntent.swift
//  Cutling
//
//  Plain "open the app" intent. Used as the lowest-priority App Shortcut
//  so users who say "Open Cutling" get a deterministic match instead of
//  Siri guessing among the other shortcuts.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents

struct OpenCutlingAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Cutling"
    static var description = IntentDescription("Open the Cutling app.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
