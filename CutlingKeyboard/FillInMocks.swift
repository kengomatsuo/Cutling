//
//  FillInMocks.swift
//  CutlingKeyboard
//
//  The fill-in screen's design mock, drawn in the real keyboard from Cutling's own parts for the
//  owner to approve (board ASG86), with sample text; nothing here types into the app. It shows only
//  when the App Group key `fillInMock` is set, which only the -FILLIN_TEST seed does (-FILLIN_MOCK own).
//
//  Cutling stays a compact keyboard: a blank is typed on the person's own keyboard (any language,
//  dictation), so the screen's first card says so and switches to it. The top bar shows the sentence
//  with the blank where "Add from Clipboard" sits, the cards are Cutling's cards, and the bottom row
//  is Cutling's, its return key turned into Next (arrow) and, on the last blank, Insert (checkmark).
//  References: docs/research/fill-ins-design/README.md, docs/fill-ins-flow.md
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI
import UIKit

enum FillInMock {
    enum Step { case name, plan }
    static let defaultsKey = "fillInMock"
    static var isOn: Bool {
        UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.string(forKey: defaultsKey) != nil
    }
}

private let cutlingGreen = Color(hex: 0x00be86)

/// How the fill-in screen moves: the grid keys' own spring (scale from 0.8 and fade, 0.4 s), opacity alone with Reduce Motion.
extension FillInMock {
    static func animation(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeOut(duration: 0.2) : .spring(duration: 0.4, bounce: 0)
    }
    static func keyTransition(reduceMotion: Bool) -> AnyTransition {
        reduceMotion ? .opacity : .scale(scale: 0.8).combined(with: .opacity)
    }
}

/// The top bar during a fill-in: the sentence with its blanks, and a close button where the open-app button sits.
struct FillInMockBar: View {
    let step: FillInMock.Step
    let keyHeight: CGFloat
    let onCancel: () -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Namespace private var blankLine

    var body: some View {
        HStack(spacing: 6) {
            HStack(spacing: 0) {
                Text(verbatim: "Hi ")
                blank(step == .name ? "Name" : "Sarah", active: step == .name, filled: step != .name)
                Text(verbatim: ", your ")
                blank(step == .plan ? "Basic" : "Plan", active: step == .plan, filled: false)
                Text(verbatim: " order ships 21 Nov.")
            }
            .font(.system(size: KeyStyle.buttonTextSize(for: horizontalSizeClass)))
            .lineLimit(1)
            .fixedSize()
            .frame(maxWidth: .infinity)
            .clipped()
            .accessibilityElement(children: .combine)

            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: KeyStyle.buttonIconSize(for: horizontalSizeClass), weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: keyHeight, height: keyHeight)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(verbatim: "Cancel"))
        }
    }

    /// The blank waiting for the person is green and underlined; the line glides to the next blank.
    private func blank(_ text: String, active: Bool, filled: Bool) -> some View {
        Text(verbatim: text)
            .foregroundStyle(active ? cutlingGreen : (filled ? Color.primary : Color.secondary))
            .contentTransition(.opacity)
            .overlay(alignment: .bottom) {
                if active {
                    Capsule().fill(cutlingGreen).frame(height: 2).offset(y: 3)
                        .matchedGeometryEffect(id: "line", in: blankLine)
                } else if !filled {
                    Rectangle().fill(Color.secondary.opacity(0.5)).frame(height: 1).offset(y: 3)
                }
            }
    }
}

/// The grid during a fill-in. Its first key sends the person to their own keyboard to type the blank;
/// below it, values used before, the clipboard, or the blank's choices. Same surface, radius, press
/// and spring as Cutling's cards (`KeyStyle`, `KeyboardButtonStyle`).
struct FillInMockKeys: View {
    let step: FillInMock.Step
    let keyHeight: CGFloat
    let keySpacing: CGFloat
    let onYourKeyboard: () -> Void
    let onPick: () -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private struct Value: Identifiable {
        let text: String
        var icon: String? = nil
        var chosen = false
        var id: String { text }
    }

    private var values: [Value] {
        step == .name
            ? [Value(text: "Sarah"), Value(text: "Sam"), Value(text: "Sarah Lee", icon: "doc.on.clipboard")]
            : [Value(text: "Basic", chosen: true), Value(text: "Pro")]
    }

    var body: some View {
        VStack(spacing: keySpacing) {
            yourKeyboardKey
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: keySpacing), count: 3), spacing: keySpacing) {
                ForEach(values) { value in valueKey(value) }
            }
            .id(step)
            .transition(FillInMock.keyTransition(reduceMotion: reduceMotion))
            Spacer(minLength: 0)
        }
        .padding(.horizontal, KeyStyle.horizontalPadding)
    }

    private var yourKeyboardKey: some View {
        Button(action: onYourKeyboard) {
            HStack(spacing: 8) {
                Image(systemName: "keyboard")
                    .font(.system(size: KeyStyle.buttonIconSize(for: horizontalSizeClass), weight: .medium))
                Text(verbatim: "Type with Your Keyboard")
                    .font(.system(size: KeyStyle.buttonTextSize(for: horizontalSizeClass), weight: .semibold))
            }
            .foregroundStyle(cutlingGreen)
            .frame(maxWidth: .infinity, minHeight: keyHeight + 8)
            .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
        }
        .buttonStyle(KeyboardButtonStyle(cornerRadius: KeyStyle.cornerRadius))
        .accessibilityHint(Text(verbatim: "Switches to your keyboard to type this blank"))
    }

    private func valueKey(_ value: Value) -> some View {
        Button(action: onPick) {
            HStack(spacing: 6) {
                if let icon = value.icon {
                    Image(systemName: icon)
                        .font(.system(size: KeyStyle.iconSize(for: horizontalSizeClass) + 2))
                        .foregroundStyle(.secondary)
                }
                Text(verbatim: value.text)
                    .font(.system(size: KeyStyle.buttonTextSize(for: horizontalSizeClass)))
                    .lineLimit(1)
                if value.chosen {
                    Image(systemName: "checkmark")
                        .font(.system(size: KeyStyle.iconSize(for: horizontalSizeClass), weight: .semibold))
                        .foregroundStyle(cutlingGreen)
                }
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, minHeight: keyHeight)
            .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
        }
        .buttonStyle(KeyboardButtonStyle(cornerRadius: KeyStyle.cornerRadius))
        .accessibilityLabel(Text(verbatim: value.icon != nil ? "Paste, \(value.text)" : value.text))
        .accessibilityAddTraits(value.chosen ? .isSelected : [])
    }
}
