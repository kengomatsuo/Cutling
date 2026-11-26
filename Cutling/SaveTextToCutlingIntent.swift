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

    /// Starts in the background; at the free limit it continues in the app (iOS 26 and later).
    @available(iOS 26.0, macOS 26.0, *)
    static var supportedModes: IntentModes { [.background, .foreground(.dynamic)] }

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

        let suggestion = InputTypeCategory.suggest(from: trimmed)
        // Code keeps its indentation; only blank edge lines go.
        let isCode = TextFormat.looksLikeCode(text)
        let value = isCode ? text.trimmingCharacters(in: .newlines) : trimmed
        let cutling = Cutling(
            name: String(trimmed.prefix(50)),
            value: String(value.prefix(store.textLimit(excluding: nil))),
            icon: suggestion.icon,
            kind: .text,
            inputTypeTriggers: suggestion.triggers.isEmpty ? nil : Array(suggestion.triggers),
            format: isCode ? .code : nil
        )
        guard store.canAdd(.text).allowed else {
            if store.needsUnlock {
                return .result(dialog: try await UnlockHandoff.ask(self, cutling: cutling, imageData: nil))
            }
            return .result(dialog: IntentDialog(stringLiteral: store.canAdd(.text).reason ?? String(localized: "Cannot add more text cutlings.")))
        }
        store.add(cutling)

        return .result(dialog: IntentDialog(stringLiteral: String(localized: "Saved!")))
    }
}
