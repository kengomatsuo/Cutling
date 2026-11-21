//
//  FormatPanel.swift
//  Cutling
//
//  The Aa panel of the text page, after Notes' Format panel (docs/research/editor-notes/shots/iphone-notes-ios26-format-panel.png):
//  a floating card in the keyboard's place with its title at the left and a round close button at the right, then
//  one row of joined cells as Notes joins B I U S. It holds only what a keyboard can type: bold, italic,
//  strikethrough, monospace and a link. The active styles are filled; nothing animates.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#if os(iOS)
import SwiftUI

enum EditorStyle: CaseIterable {
    case bold, italic, strikethrough, monospace, link
}

/// Which styles the text at the cursor or selection has; the panel draws from it.
@Observable
final class EditorStyles {
    var active: Set<EditorStyle> = []
    /// Turns a style on or off at the cursor or selection; the editor sets it.
    @ObservationIgnored var toggle: (EditorStyle) -> Void = { _ in }
}

struct FormatPanel: View {
    let styles: EditorStyles
    /// The keyboard's stand-in on iPhone closes with its own button; nil on iPad, where the panel is a popover.
    var close: (() -> Void)? = nil

    /// The card (title row, one row of cells, Notes' padding) and its margins, down to the screen's edge.
    static let height: CGFloat = 6 + 12 + 44 + 14 + 42 + 34 + 9

    private let cells: [(EditorStyle, String, LocalizedStringKey)] = [
        (.bold, "bold", "Bold"),
        (.italic, "italic", "Italic"),
        (.strikethrough, "strikethrough", "Strikethrough"),
        (.monospace, "chevron.left.forwardslash.chevron.right", "Monospace"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Format").font(.title3.weight(.semibold))
                Spacer()
                if let close {
                    Button(action: close) {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Color.primary)
                            .frame(width: 44, height: 44)
                            .background(Color(.tertiarySystemFill), in: Circle())
                    }
                    .buttonStyle(FlatPressStyle(shape: Circle()))
                    .accessibilityLabel("Close")
                    .accessibilityIdentifier("formatPanelClose")
                }
            }
            .frame(minHeight: 44)
            // Two groups on one row, as Notes sets B I U S beside highlight and colour.
            HStack(spacing: 14) {
                HStack(spacing: 1.5) {
                    ForEach(cells, id: \.0) { cell in
                        cellButton(cell.0) { Image(systemName: cell.1) }
                            .accessibilityLabel(cell.2)
                    }
                }
                .clipShape(Capsule())
                cellButton(.link) { Image(systemName: "link") }
                    .frame(maxWidth: 72)
                    .clipShape(Capsule())
                    .accessibilityLabel(styles.active.contains(.link) ? Text("Remove Link") : Text("Add Link"))
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 12)
        .padding(.top, 12)
        .padding(.bottom, close == nil ? 16 : 34)
        .modifier(PanelCard(floating: close != nil))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("formatPanel")
    }

    private func cellButton<Content: View>(_ style: EditorStyle, @ViewBuilder content: () -> Content) -> some View {
        Button { styles.toggle(style) } label: {
            content()
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 42)
                .foregroundStyle(styles.active.contains(style) ? Color.white : Color.primary)
                .background(styles.active.contains(style) ? Color.accentColor : Color(.tertiarySystemFill))
                .contentShape(Rectangle())
        }
        .buttonStyle(FlatPressStyle(shape: Rectangle()))
        .accessibilityAddTraits(styles.active.contains(style) ? .isSelected : [])
    }
}

/// Notes' panel is a glass card with the sheet's large corners on iOS 26 and later; earlier systems get the page colour.
private struct PanelCard: ViewModifier {
    /// False inside a popover, which is its own card.
    let floating: Bool

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 38, style: .continuous)
        if !floating {
            content.frame(width: 340)
        } else if #available(iOS 26, *) {
            content.glassEffect(.regular, in: shape).padding(EdgeInsets(top: 6, leading: 9, bottom: 9, trailing: 9))
        } else {
            content.background(Color(.secondarySystemGroupedBackground), in: shape).padding(EdgeInsets(top: 6, leading: 9, bottom: 9, trailing: 9))
        }
    }
}

/// Apple's press: the surface darkens while held, with no scale and no fade in or out.
struct FlatPressStyle<S: Shape>: ButtonStyle {
    let shape: S

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(Color.primary.opacity(configuration.isPressed ? 0.12 : 0).clipShape(shape))
    }
}
#endif
