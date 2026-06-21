//
//  OpenNewImageCutlingIntent.swift
//  Cutling
//
//  Parameter-free sibling of OpenCutlingIntent for use in App Shortcuts.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents

struct OpenNewImageCutlingIntent: AppIntent {
    static var title: LocalizedStringResource = "New Image Cutling"
    static var description = IntentDescription("Open Cutling and start a new image cutling.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")
        defaults?.set(CutlingScreen.newImage.rawValue, forKey: "pendingControlAction")
        return .result()
    }
}
