//
//  FormatPanel.swift
//  Cutling
//
//  The Aa panel of the text page, after Notes' Format panel (docs/research/editor-notes/owner-recording/dark_13s.png):
//  a floating card in the keyboard's place with its title at the left and a round close button at the right, then
//  rows of joined cells as Notes joins them: B I U S beside highlight and monospace, then the three lists beside
//  the link. It holds only what a formatted cutling stores. The active styles are filled; nothing animates.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#if os(iOS)
import SwiftUI

enum EditorStyle: Hashable {
    case bold, italic, underline, strikethrough, highlight, monospace, link
    /// The paragraph is this list; choosing the list it already is takes it out, as in Notes.
    case list(ListKind)

    static let lists: [EditorStyle] = ListKind.allCases.map(EditorStyle.list)

    /// Notes' own glyphs: its bar, its Format card and its list menu.
    var icon: String {
        switch self {
        case .bold: "bold"
        case .italic: "italic"
        case .underline: "underline"
        case .strikethrough: "strikethrough"
        case .highlight: "highlighter"
        case .monospace: "chevron.left.forwardslash.chevron.right"
        case .link: "link"
        case .list(.bulleted): "list.bullet"
        case .list(.dashed): "list.dash"
        case .list(.numbered): "list.number"
        }
    }

    var title: String {
        switch self {
        case .bold: String(localized: "Bold")
        case .italic: String(localized: "Italic")
        case .underline: String(localized: "Underline")
        case .strikethrough: String(localized: "Strikethrough")
        case .highlight: String(localized: "Highlight")
        case .monospace: String(localized: "Monospace")
        case .link: String(localized: "Add Link")
        case .list(.bulleted): String(localized: "Bulleted")
        case .list(.dashed): String(localized: "Dashed")
        case .list(.numbered): String(localized: "Numbered")
        }
    }
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

    /// The card (title row, two rows of cells, Notes' padding) and its margins, down to the screen's edge.
    static let height: CGFloat = 6 + 12 + 44 + 14 + 42 + 14 + 42 + 34 + 9

    /// Notes' rows: B I U S beside its pen and colour; its three lists beside indent and block quote.
    /// Here the pen is the highlight, monospace takes the colour's place, and the link takes the indents'.
    private let styles1: [EditorStyle] = [.bold, .italic, .underline, .strikethrough]
    private let styles2: [EditorStyle] = [.highlight, .monospace]

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
            // Two groups on each row, as Notes sets B I U S beside highlight and colour, and its lists beside the indents.
            HStack(spacing: 14) {
                group(styles1)
                group(styles2)
                    .frame(maxWidth: 124)
            }
            HStack(spacing: 14) {
                group(EditorStyle.lists)
                cellButton(.link)
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

    private func group(_ cells: [EditorStyle]) -> some View {
        HStack(spacing: 1.5) {
            ForEach(cells, id: \.self) { style in
                cellButton(style)
                    .accessibilityLabel(style.title)
            }
        }
        .clipShape(Capsule())
    }

    private func cellButton(_ style: EditorStyle) -> some View {
        Button { styles.toggle(style) } label: {
            Image(systemName: style.icon)
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 42)
                .foregroundStyle(styles.active.contains(style) ? Color.white : Color.primary)
                .background(styles.active.contains(style) ? Color.accentColor : Color(.tertiarySystemFill))
                .contentShape(Rectangle())
        }
        .buttonStyle(FlatPressStyle(shape: Rectangle()))
        .accessibilityAddTraits(styles.active.contains(style) ? .isSelected : [])
        .accessibilityIdentifier("format.\(style.icon)")
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

/// Where a link goes and what it reads, laid out as Notes' Add Link sheet: close at the left, the check at the right,
/// "Link To" and, with nothing selected, an optional "Name".
struct LinkSheet: View {
    @Environment(\.dismiss) private var dismiss
    let asksName: Bool
    let onAdd: (URL, String) -> Void
    @State private var address = ""
    @State private var name = ""
    @FocusState private var inAddress: Bool

    private var url: URL? {
        var text = address.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return nil }
        if !text.contains("://") { text = "https://" + text }
        return URL(string: text)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Link To") {
                    TextField("URL", text: $address)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($inAddress)
                        .accessibilityIdentifier("linkAddress")
                }
                if asksName {
                    Section("Name") {
                        TextField("Optional", text: $name)
                    }
                }
            }
            .navigationTitle("Add Link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        if #available(iOS 26, *) { Image(systemName: "xmark") } else { Text("Cancel") }
                    }
                    .accessibilityLabel("Cancel")
                    .accessibilityIdentifier("linkCancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if let url { onAdd(url, name.trimmingCharacters(in: .whitespaces)) }
                        dismiss()
                    } label: {
                        if #available(iOS 26, *) { Image(systemName: "checkmark") } else { Text("Done") }
                    }
                    .disabled(url == nil)
                    .accessibilityIdentifier("linkDone")
                }
            }
            .onAppear { inAddress = true }
        }
        .accessibilityIdentifier("linkSheet")
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
