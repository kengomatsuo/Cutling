//
//  InputTypeCutlingPicker.swift
//  Cutling
//

import SwiftUI

/// Lets the user pick which cutlings should be suggested for a given input type category.
/// Navigated to from Settings → Input Type Suggestions.
struct InputTypeCutlingPicker: View {
    let category: InputTypeCategory
    @EnvironmentObject var store: CutlingStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            let liveCutlings = store.cutlings.filter { !$0.isExpired }
            if liveCutlings.isEmpty {
                Text("No cutlings yet. Add some first.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(liveCutlings) { cutling in
                    let isAssigned = isCutlingAssigned(cutling)
                    Button {
                        toggleCutling(cutling, assigned: isAssigned)
                    } label: {
                        HStack {
                            Image(systemName: cutling.icon)
                                .font(.body)
                                .foregroundStyle(cutling.tintColor)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(cutling.name)
                                    .font(.body)
                                    .lineLimit(1)
                                if cutling.kind == .text && !cutling.value.isEmpty {
                                    Text(cutling.value)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            if isAssigned {
                                Image(systemName: "checkmark")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
        .navigationTitle(category.displayName)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func isCutlingAssigned(_ cutling: Cutling) -> Bool {
        guard let triggers = cutling.inputTypeTriggers else { return false }
        return !Set(triggers).isDisjoint(with: category.triggerKeys)
    }

    private func toggleCutling(_ cutling: Cutling, assigned: Bool) {
        var updated = cutling
        var triggers = Set(cutling.inputTypeTriggers ?? [])
        if assigned {
            triggers.subtract(category.triggerKeys)
        } else {
            triggers.formUnion(category.triggerKeys)
        }
        updated.inputTypeTriggers = triggers.isEmpty ? nil : Array(triggers)
        store.update(updated)
    }
}
