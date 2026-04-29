//
//  InputTypePickerSection.swift
//  Cutling
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import SwiftUI

/// A Form section that lets the user toggle which input type categories
/// a cutling should be suggested for in the keyboard.
struct InputTypePickerSection: View {
    @Binding var selectedTriggers: Set<String>
    @Binding var autoDetectedCategories: Set<InputTypeCategory>

    var body: some View {
        Section {
            ForEach(InputTypeCategory.allCases) { category in
                let isOn = !category.triggerKeys.isDisjoint(with: selectedTriggers)
                Button {
                    withAccessibleAnimation(.easeInOut(duration: 0.15)) {
                        // Any manual toggle removes this category from auto-detected tracking.
                        autoDetectedCategories.remove(category)
                        if isOn {
                            selectedTriggers.subtract(category.triggerKeys)
                        } else {
                            selectedTriggers.formUnion(category.triggerKeys)
                        }
                    }
                } label: {
                    HStack {
                        Label(category.displayName, systemImage: category.icon)
                        Spacer()
                        if isOn {
                            Image(systemName: "checkmark")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.tint)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .foregroundStyle(.primary)
                #if os(macOS)
                .buttonStyle(.plain)
                #endif
            }
        } header: {
            Text("Suggest for Input Types")
        } footer: {
            Text("When you focus a text field of a matching type, this cutling will appear at the top of the keyboard.")
        }
    }
}
