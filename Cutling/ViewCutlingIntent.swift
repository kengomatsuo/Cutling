//
//  ViewCutlingIntent.swift
//  Cutling
//
//  Opens the app and routes to the chosen cutling's detail view. Drives the
//  "tap row to open" behaviour in snippet views surfaced by Siri / Shortcuts.
//  Uses the same pendingOpenCutlingID handoff that Spotlight already relies on.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents

struct ViewCutlingIntent: AppIntent {
    static var title: LocalizedStringResource = "View Cutling"
    static var description = IntentDescription("Open a cutling in the Cutling app.")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Cutling")
    var target: CutlingAppEntity

    init() {}

    init(target: CutlingAppEntity) {
        self.target = target
    }

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")
        defaults?.set(target.id.uuidString, forKey: "pendingOpenCutlingID")
        return .result()
    }
}
