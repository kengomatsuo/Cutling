//
//  GetLatestCutlingTextIntent.swift
//  Cutling
//
//  Returns the value of the most recently modified text cutling. Useful
//  for "what was the last thing I saved?" style automations and as a
//  zero-friction Siri command.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents

struct GetLatestCutlingTextIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Latest Cutling"
    static var description = IntentDescription("Get the text from your most recently saved cutling.")

    init() {}

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let store = CutlingStore.shared
        let latest = store.cutlings
            .filter { $0.kind == .text && !$0.isExpired }
            .max(by: { $0.lastModifiedDate < $1.lastModifiedDate })

        guard let latest else {
            return .result(
                value: "",
                dialog: IntentDialog(stringLiteral: String(localized: "No Cutlings Yet"))
            )
        }
        return .result(
            value: latest.value,
            dialog: IntentDialog(stringLiteral: latest.value)
        )
    }
}
