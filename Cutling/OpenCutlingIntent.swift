//
//  OpenCutlingIntent.swift
//  Cutling
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents

enum CutlingScreen: String, AppEnum {
    case newText
    case newImage

    static var typeDisplayRepresentation = TypeDisplayRepresentation("Screen")
    static var caseDisplayRepresentations: [CutlingScreen: DisplayRepresentation] = [
        .newText: "New Text Cutling",
        .newImage: "New Image Cutling"
    ]
}

struct OpenCutlingIntent: OpenIntent {
    static var title: LocalizedStringResource = "Open Cutling"

    @Parameter(title: "Screen")
    var target: CutlingScreen

    init() {
        self.target = .newText
    }

    init(target: CutlingScreen) {
        self.target = target
    }

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")
        defaults?.set(target.rawValue, forKey: "pendingControlAction")
        return .result()
    }
}
