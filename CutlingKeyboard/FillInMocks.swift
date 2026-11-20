//
//  FillInMocks.swift
//  CutlingKeyboard
//
//  Two designs for the keyboard's fill-in screen, drawn at the keyboard's real size for the owner
//  to pick (board ASG86), with sample text; nothing here types into the app. They show only when
//  the App Group key `fillInMock` is set, which only the -FILLIN_TEST seed does (-FILLIN_MOCK keys|abc).
//  References: docs/research/fill-ins-design/README.md
//
//  keys: Apple's letter keys inside Cutling, the blank inline in the sentence (TextExpander's
//        fill-in card, Apple's default keyboard and predictive bar); Insert types the whole text.
//  abc:  Apple's emoji-keyboard pattern: the sentence where the emoji search field sits, saved values
//        and choices as keys, and an ABC key that goes back to the person's own keyboard to type.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI
import UIKit

enum FillInMock {
    enum Design: String { case keys, abc }
    enum Step { case name, plan }
    static let defaultsKey = "fillInMock"
    static var design: Design? {
        UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.string(forKey: defaultsKey).flatMap(Design.init(rawValue:))
    }
}

private let cutlingGreen = Color(hex: 0x00be86)
/// Apple's keyboards draw shift, delete, 123 and ABC darker than the letter keys.
private let functionKeyColor = Color(UIColor { traits in
    traits.userInterfaceStyle == .dark ? UIColor(white: 1, alpha: 0.10) : UIColor(white: 0.52, alpha: 0.30)
})

/// The emoji keyboard's ABC key: back to the keyboard the person types with.
struct PreviousKeyboardKey: View {
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Text(verbatim: "ABC")
            .font(.system(size: 16, weight: .regular))
            .frame(width: width, height: height)
            .background(functionKeyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
            .accessibilityLabel(Text(verbatim: "Back to your keyboard"))
            .accessibilityAddTraits([.isButton, .isKeyboardKey])
            .instantPress(sound: .modifier, action: action)
    }
}

struct FillInMockView: View {
    let design: FillInMock.Design
    let step: FillInMock.Step
    let keyHeight: CGFloat
    let keySpacing: CGFloat
    let gridHeight: CGFloat
    let smallKeyWidth: CGFloat
    let onNext: () -> Void
    let onCancel: () -> Void
    let onSwitchKeyboard: () -> Void

    private var isLast: Bool { step == .plan }

    var body: some View {
        VStack(spacing: keySpacing) {
            Group {
                if design == .keys { keysStrip } else { abcStrip }
            }
            .padding(.horizontal, KeyStyle.horizontalPadding)
            .frame(height: keyHeight + keySpacing)
            .padding(.top, keySpacing)

            Group {
                if design == .keys { letters } else { values }
            }
            .frame(height: gridHeight)

            bottomRow
                .padding(.horizontal, KeyStyle.horizontalPadding)
                .frame(height: keyHeight)
        }
        .accessibilityIdentifier("CutlingKeyboardView")
        .padding(.bottom, 2)
    }

    // MARK: - The sentence, with its blanks inline

    private var sentence: some View {
        HStack(spacing: 0) {
            Text(verbatim: "Hi ")
            switch (design, step) {
            case (.keys, .name): blank("Sar", active: true, caret: true)
            case (.abc, .name): blank("Name", active: true, placeholder: true)
            case (_, .plan): blank("Sarah", active: false)
            }
            Text(verbatim: ", your ")
            blank(step == .plan ? "Basic" : "Plan", active: step == .plan, placeholder: step == .name, chevron: true)
            Text(verbatim: " order ships 21 Nov.")
        }
        .font(.system(size: 17))
        .lineLimit(1)
        .fixedSize()
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
        .accessibilityElement(children: .combine)
    }

    private func blank(_ text: String, active: Bool, placeholder: Bool = false, chevron: Bool = false, caret: Bool = false) -> some View {
        HStack(spacing: 2) {
            Text(verbatim: text)
                .foregroundStyle(placeholder ? AnyShapeStyle(active ? cutlingGreen : Color.secondary) : AnyShapeStyle(Color.primary))
            if caret {
                RoundedRectangle(cornerRadius: 1).fill(cutlingGreen).frame(width: 2, height: 20)
            }
            if chevron {
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(active ? cutlingGreen : Color.secondary)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(active ? cutlingGreen.opacity(0.15) : Color.primary.opacity(0.07), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
        .overlay {
            if active { RoundedRectangle(cornerRadius: 7, style: .continuous).strokeBorder(cutlingGreen.opacity(0.55), lineWidth: 1) }
        }
    }

    /// keys: a cancel button, the sentence, and how many blanks there are.
    private var keysStrip: some View {
        HStack(spacing: 10) {
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
                    .background(functionKeyColor, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(verbatim: "Cancel"))
            sentence
            Text(verbatim: step == .name ? "1 of 2" : "2 of 2")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .fixedSize()
        }
    }

    /// abc: the sentence sits where the emoji keyboard's search field does, with its clear button.
    private var abcStrip: some View {
        HStack(spacing: 8) {
            sentence
            Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(verbatim: "Cancel"))
        }
        .padding(.horizontal, 12)
        .frame(height: keyHeight)
        .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
    }

    // MARK: - keys: Apple's predictive bar and letter keys

    private var letters: some View {
        VStack(spacing: 8) {
            predictiveBar.frame(height: 32)
            GeometryReader { geo in
                let gap: CGFloat = 6
                let rowGap: CGFloat = 10
                let keyWidth = (geo.size.width - 9 * gap) / 10
                let rowHeight = (geo.size.height - 2 * rowGap) / 3
                VStack(spacing: rowGap) {
                    HStack(spacing: gap) { ForEach(Array("qwertyuiop"), id: \.self) { letterKey($0, keyWidth, rowHeight) } }
                    HStack(spacing: gap) { ForEach(Array("asdfghjkl"), id: \.self) { letterKey($0, keyWidth, rowHeight) } }
                    HStack(spacing: gap) {
                        functionKey(Image(systemName: "shift"), label: "Shift", width: keyWidth * 1.3, height: rowHeight)
                        Spacer(minLength: 0)
                        HStack(spacing: gap) { ForEach(Array("zxcvbnm"), id: \.self) { letterKey($0, keyWidth, rowHeight) } }
                        Spacer(minLength: 0)
                        functionKey(Image(systemName: "delete.left"), label: "Delete", width: keyWidth * 1.3, height: rowHeight)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, KeyStyle.horizontalPadding)
        }
    }

    private var predictiveBar: some View {
        let words = step == .name ? ["“Sar”", "Sarah", "Sam"] : ["Basic", "Pro", ""]
        return HStack(spacing: 0) {
            ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                if index > 0 {
                    Rectangle().fill(Color.secondary.opacity(0.35)).frame(width: 0.5, height: 22)
                }
                Text(verbatim: word)
                    .font(.system(size: 16, weight: index == 1 && step == .name ? .semibold : .regular))
                    .frame(maxWidth: .infinity)
                    .accessibilityAddTraits(.isButton)
            }
        }
    }

    private func letterKey(_ letter: Character, _ width: CGFloat, _ height: CGFloat) -> some View {
        Text(verbatim: String(letter))
            .font(.system(size: 23))
            .frame(width: width, height: height)
            .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius - 2, style: .continuous))
            .accessibilityAddTraits(.isKeyboardKey)
    }

    private func functionKey(_ image: Image, label: String, width: CGFloat, height: CGFloat) -> some View {
        image
            .font(.system(size: 18, weight: .regular))
            .frame(width: width, height: height)
            .background(functionKeyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius - 2, style: .continuous))
            .accessibilityLabel(Text(verbatim: label))
            .accessibilityAddTraits(.isKeyboardKey)
    }

    // MARK: - abc: saved values and choices as keys

    private var values: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(verbatim: step == .name ? "NAME" : "PLAN")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(verbatim: step == .name ? "1 of 2" : "2 of 2")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 6)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 6) {
                if step == .name {
                    valueKey("Sarah")
                    valueKey("Sam")
                    valueKey("Paste", icon: "doc.on.clipboard")
                } else {
                    valueKey("Basic", selected: true)
                    valueKey("Pro")
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, KeyStyle.horizontalPadding)
        .padding(.top, 4)
    }

    private func valueKey(_ text: String, icon: String? = nil, selected: Bool = false) -> some View {
        HStack(spacing: 8) {
            if let icon { Image(systemName: icon).font(.system(size: 16)).foregroundStyle(.secondary) }
            Text(verbatim: text).font(.system(size: 17))
            Spacer(minLength: 0)
            if selected { Image(systemName: "checkmark").font(.system(size: 14, weight: .semibold)).foregroundStyle(cutlingGreen) }
        }
        .padding(.horizontal, 14)
        .frame(height: keyHeight)
        .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Bottom row: the default keyboard's, with Next, then Insert, as its return key

    private var bottomRow: some View {
        HStack(spacing: keySpacing) {
            if design == .keys {
                Text(verbatim: "123")
                    .font(.system(size: 16))
                    .frame(width: smallKeyWidth, height: keyHeight)
                    .background(functionKeyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
                    .accessibilityAddTraits(.isKeyboardKey)
            } else {
                PreviousKeyboardKey(width: smallKeyWidth, height: keyHeight, action: onSwitchKeyboard)
                Image(systemName: "delete.left")
                    .font(.system(size: 20, weight: .light))
                    .frame(width: smallKeyWidth, height: keyHeight)
                    .background(functionKeyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
                    .accessibilityLabel(Text(verbatim: "Delete"))
            }
            Text(verbatim: "space")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: keyHeight)
                .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
                .accessibilityLabel(Text(verbatim: "Space"))
            Text(verbatim: isLast ? "Insert" : "Next")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 92, height: keyHeight)
                .background(cutlingGreen, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
                .accessibilityAddTraits([.isButton, .isKeyboardKey])
                .instantPress(sound: .modifier, action: onNext)
        }
    }
}
