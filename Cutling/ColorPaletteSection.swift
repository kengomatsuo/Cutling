//
//  ColorPaletteSection.swift
//  Cutling
//

import SwiftUI

// MARK: - Color Palette Section

/// A wrapping grid of preset color circles for picking a cutling's tint color.
struct ColorPaletteSection: View {
    @Binding var selectedColor: String?

    private let columns = [GridItem(.adaptive(minimum: 36), spacing: 12)]

    var body: some View {
        Section("Color") {
            LazyVGrid(columns: columns, spacing: 12) {
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
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedColor = key
            }
        } label: {
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
        }
        .buttonStyle(.plain)
        .accessibilityLabel(key?.capitalized ?? "Default")
    }
}
