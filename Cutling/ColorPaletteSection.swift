//
//  ColorPaletteSection.swift
//  Cutling
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import SwiftUI

// MARK: - Color Palette Section

/// A wrapping grid of preset color circles for picking a cutling's tint color.
struct ColorPaletteSection: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Binding var selectedColor: String?

    private let columns = [GridItem(.adaptive(minimum: 36), spacing: 12)]

    var body: some View {
        Section("Color") {
            LazyVGrid(columns: differentiateWithoutColor ? [GridItem(.adaptive(minimum: 64), spacing: 12)] : columns, spacing: 12) {
                colorCircle(key: nil, color: .accentColor)

                ForEach(Cutling.paletteKeys, id: \.self) { key in
                    colorCircle(key: key, color: Cutling.palette[key]!)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func colorCircle(key: String?, color: Color) -> some View {
        Button {
            withAccessibleAnimation(.easeInOut(duration: 0.15)) {
                selectedColor = key
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 30, height: 30)
                    if selectedColor == key {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                }
                if differentiateWithoutColor {
                    Text(Cutling.localizedColorName(for: key))
                        .font(.system(size: 9))
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Cutling.localizedColorName(for: key))
        .accessibilityValue(selectedColor == key ? String(localized: "Selected") : "")
    }
}
