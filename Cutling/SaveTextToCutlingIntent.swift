//
//  SaveTextToCutlingIntent.swift
//  Cutling
//
//  Save an arbitrary string parameter as a new text cutling. The phrase
//  "Save <text> to Cutling" makes this composable inside Shortcuts —
//  users can chain it after "Get Text from Input" or any text-producing
//  action.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents

struct SaveTextToCutlingIntent: AppIntent {
    static var title: LocalizedStringResource = "Save Text"
    static var description = IntentDescription("Save text as a new cutling.")

    @Parameter(title: "Text", inputOptions: String.IntentInputOptions(multiline: true))
    var text: String

    init() {}

    init(text: String) {
        self.text = text
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .result(dialog: IntentDialog(stringLiteral: String(localized: "Nothing to save.")))
        }

        let store = CutlingStore.shared

        if store.findDuplicateText(value: trimmed) != nil {
            return .result(dialog: IntentDialog(stringLiteral: String(localized: "Already saved.")))
        }

        let check = store.canAdd(.text)
        guard check.allowed else {
            return .result(dialog: IntentDialog(stringLiteral: check.reason ?? String(localized: "Cannot add more text cutlings.")))
        }

        let suggestion = InputTypeCategory.suggest(from: trimmed)
        let cutling = Cutling(
            name: String(trimmed.prefix(50)),
            value: String(trimmed.prefix(CutlingStore.maxTextLength)),
            icon: suggestion.icon,
            kind: .text,
            inputTypeTriggers: suggestion.triggers.isEmpty ? nil : Array(suggestion.triggers)
        )
        store.add(cutling)

        return .result(dialog: IntentDialog(stringLiteral: String(localized: "Saved!")))
    }
}
