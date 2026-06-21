//
//  OpenNewTextCutlingIntent.swift
//  Cutling
//
//  Parameter-free sibling of OpenCutlingIntent for use in App Shortcuts.
//  AppShortcut phrases can't bind a constant value to an @Parameter, so
//  Siri's "new text in Cutling" surface needs its own zero-parameter intent.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents

struct OpenNewTextCutlingIntent: AppIntent {
    static var title: LocalizedStringResource = "New Text Cutling"
    static var description = IntentDescription("Open Cutling and start a new text cutling.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")
        defaults?.set(CutlingScreen.newText.rawValue, forKey: "pendingControlAction")
        return .result()
    }
}
