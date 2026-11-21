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

/// The top bar during a fill-in: the sentence with its blanks, and a close button where the open-app button sits.
struct FillInMockBar: View {
    let step: FillInMock.Step
    let keyHeight: CGFloat
    let onCancel: () -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        HStack(spacing: 6) {
            HStack(spacing: 0) {
                Text(verbatim: "Hi ")
                if step == .name { blank("Name", active: true) } else { Text(verbatim: "Sarah") }
                Text(verbatim: ", your ")
                blank(step == .plan ? "Basic" : "Plan", active: step == .plan)
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

    /// The blank waiting for the person is underlined in Cutling's green, the way a marked word is.
    private func blank(_ text: String, active: Bool) -> some View {
        Text(verbatim: text)
            .foregroundStyle(active ? cutlingGreen : Color.secondary)
            .fontWeight(active ? .semibold : .regular)
            .overlay(alignment: .bottom) {
                Rectangle().fill(active ? cutlingGreen : Color.secondary.opacity(0.5)).frame(height: active ? 2 : 1).offset(y: 3)
            }
    }
}

/// The grid during a fill-in: Cutling's own cards. The first goes to the person's keyboard to type the blank.
struct FillInMockCards: View {
    let step: FillInMock.Step
    let store: CutlingStore
    let keySpacing: CGFloat
    let onYourKeyboard: () -> Void
    let onPick: () -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var cards: [Cutling] {
        let label = step == .name ? "Name" : "Plan"
        var out = [Cutling(name: "Your Keyboard", value: "Type the \(label.lowercased()) there, then come back", icon: "keyboard", sortOrder: 0)]
        if step == .name {
            out += [
                Cutling(name: "Sarah", value: "Used before", icon: "clock.arrow.circlepath", sortOrder: 1),
                Cutling(name: "Sam", value: "Used before", icon: "clock.arrow.circlepath", sortOrder: 2),
                Cutling(name: "Paste", value: "Sarah Lee", icon: "doc.on.clipboard", sortOrder: 3),
            ]
        } else {
            out += [
                Cutling(name: "Basic", value: "Choice", icon: "checkmark.circle.fill", sortOrder: 1),
                Cutling(name: "Pro", value: "Choice", icon: "circle", sortOrder: 2),
            ]
        }
        return out
    }

    var body: some View {
        GeometryReader { geo in
            let minWidth = KeyStyle.cardMinWidth(for: horizontalSizeClass)
            let width = geo.size.width - 2 * KeyStyle.horizontalPadding
            let columns = max(1, Int((width + keySpacing) / (minWidth + keySpacing)))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: keySpacing), count: columns), spacing: keySpacing) {
                ForEach(cards) { card in
                    CutlingKeyView(cutling: card, store: store, isCopied: false, isExisted: false,
                                   onTap: card.icon == "keyboard" ? onYourKeyboard : onPick)
                }
            }
            .padding(.horizontal, KeyStyle.horizontalPadding)
        }
    }
}
