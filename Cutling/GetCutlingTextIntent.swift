//
//  GetCutlingTextIntent.swift
//  Cutling
//
//  Returns the text contents of a chosen cutling for use as input in
//  downstream Shortcuts actions (e.g. translate, share, set variable).
//  Unlike OpenCutlingByIDIntent (which copies + foregrounds the app),
//  this one returns a value and doesn't open the app — better for
//  composing automations.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents

struct GetCutlingTextIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Cutling Text"
    static var description = IntentDescription("Get the text contents of a cutling as a value for use in other shortcuts.")

    @Parameter(title: "Cutling")
    var target: CutlingAppEntity

    init() {}

    init(target: CutlingAppEntity) {
        self.target = target
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let store = CutlingStore.shared
        guard let cutling = store.cutlings.first(where: { $0.id == target.id }),
              !cutling.isExpired,
              cutling.kind == .text else {
            return .result(
                value: "",
                dialog: IntentDialog(stringLiteral: String(localized: "No Cutlings Yet"))
            )
        }
        return .result(
            value: cutling.value,
            dialog: IntentDialog(stringLiteral: cutling.value)
        )
    }
}
