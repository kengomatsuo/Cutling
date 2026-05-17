//
//  OpenCutlingByIDIntent.swift
//  Cutling
//
//  System-invoked when the user taps a Cutling result in Spotlight
//  (via `associateAppEntity` on the indexed item) or from Shortcuts.
//  Writes the target ID to the shared app group so the main app
//  consumes it on the next scene-active pass.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents
import Foundation

struct OpenCutlingByIDIntent: OpenIntent {
    static var title: LocalizedStringResource = "Open Cutling"
    static var description = IntentDescription("Open a specific cutling for editing.")

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
