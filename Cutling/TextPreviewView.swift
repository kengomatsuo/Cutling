//
//  TextPreviewView.swift
//  Cutling
//
//  Every look at a cutling's text outside its editor (cards, a card's long-press preview, list rows, Recently Deleted,
//  keyboard keys, the Mac picker and the editor's form) draws with the editor's own renderer (FillInPills.display):
//  each variable a pill in the text's own size, wrapped lines 3 pt apart, exactly as on the Text page. A SwiftUI Text
//  can't: an inline pill image as tall as the line pushes every wrapped line apart, which is why previews once drew
//  smaller pills. Read-only; a tap goes to whatever holds it.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI
#if os(iOS)
import UIKit
typealias PreviewTextStyle = UIFont.TextStyle
#elseif os(macOS)
import AppKit
typealias PreviewTextStyle = NSFont.TextStyle
#endif

struct TextPreviewView {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let text: String
    let format: TextFormat
    /// The text style the words take, following the person's text size; `size` replaces it with a fixed size.
    var style: PreviewTextStyle = .body
    var size: CGFloat? = nil
    /// Secondary ink, as a card's text under its name.
    var secondary = false
    var maxLines = 8
    /// The Mac picker's popover lets its text be selected and copied.
    var selectable = false
    /// Cards and rows show where the caret will land as nothing, as they always have; the editor's form shows its pill.
    var hidesCursor = false

    private var pointSize: CGFloat { size ?? PillFont.preferredFont(forTextStyle: style).pointSize }

    /// The start of the text a preview draws, without the cursor spot where the preview hides it.
    private var source: String {
        let head = Cutling.previewSource(text)
        guard hidesCursor, format != .code else { return head }
        return FillInPills.split(head).map { piece in
            switch piece {
            case .text(let run): run
            case .token(let token):
                token.dropFirst(2).dropLast().trimmingCharacters(in: .whitespaces).lowercased() == "cursor" ? "" : token
            }
        }.joined()
    }

    /// The text as drawn: pills at the text's size, lines 3 pt apart, in the preview's ink. Code is monospaced, as typed.
    private func drawn() -> NSAttributedString {
        #if os(iOS)
        let ink: PillColor = secondary ? .secondaryLabel : .label
        let primary: PillColor = .label
        #else
        let ink: PillColor = secondary ? .secondaryLabelColor : .labelColor
        let primary: PillColor = .textColor
        #endif
        if format == .code {
            return NSAttributedString(string: source, attributes: [
                .font: PillFont.monospacedSystemFont(ofSize: pointSize, weight: .regular), .foregroundColor: ink,
            ])
        }
        let shown = NSMutableAttributedString(attributedString: FillInPills.display(
            FillInPills.rendered(source, format: format, size: pointSize), font: PillFont.systemFont(ofSize: pointSize)))
        // The renderer writes the editor's ink; a secondary preview takes its own, leaving links and highlights alone.
        if secondary {
            shown.enumerateAttribute(.foregroundColor, in: NSRange(location: 0, length: shown.length)) { value, range, _ in
                if (value as? PillColor) == primary { shown.addAttribute(.foregroundColor, value: ink, range: range) }
            }
        }
        return shown
    }

    /// Spoken with each pill read as its name or today's value, as the cards read them.
    private var spoken: String {
        guard format != .code else { return source }
        return FillInPills.split(format == .rich ? RichText.plainText(source) : source).map { piece in
            switch piece {
            case .text(let run): run
            case .token(let token): FillInPills.previewValue(of: token) ?? FillInPills.title(of: token)
            }
        }.joined()
    }

    /// What the view last drew, so a pass that changes nothing leaves it alone. Each assignment made a new text with
    /// new pill images and re-measured the row inside the layout pass that asked for it, which once laid the editor's
    /// navigation view out again and again (UIKit's observation feedback loop) until the Text page stalled.
    final class Coordinator { var drawn = "" }

    func makeCoordinator() -> Coordinator { Coordinator() }

    private func key(dark: Bool) -> String {
        "\(text)|\(format)|\(pointSize)|\(secondary)|\(maxLines)|\(hidesCursor)|\(dark)"
    }
}

#if os(iOS)
extension TextPreviewView: UIViewRepresentable {
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = false
        view.isSelectable = false
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.textContainer.lineBreakMode = .byTruncatingTail
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.isAccessibilityElement = true
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        // Follows the person's text size: a change of dynamicTypeSize calls this again with the style's new size.
        let key = key(dark: view.traitCollection.userInterfaceStyle == .dark)
        guard key != context.coordinator.drawn else { return }
        context.coordinator.drawn = key
        view.attributedText = drawn()
        view.textContainer.maximumNumberOfLines = maxLines
        view.accessibilityLabel = spoken
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let width = proposal.width ?? 320
        let bound = CGSize(width: width, height: .greatestFiniteMagnitude)
        // A SwiftUI Text gives up whole lines when its frame is short (a card in the grid has a fixed height); so does
        // this, down to one line, where reporting all its lines let a card's text run over the card below it.
        var lines = maxLines
        uiView.textContainer.maximumNumberOfLines = lines
        var fit = uiView.sizeThatFits(bound)
        if let height = proposal.height, height.isFinite {
            while fit.height > height + 0.5, lines > 1 {
                lines -= 1
                uiView.textContainer.maximumNumberOfLines = lines
                fit = uiView.sizeThatFits(bound)
            }
        }
        return CGSize(width: width, height: ceil(fit.height))
    }
}
#elseif os(macOS)
extension TextPreviewView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSTextView {
        let view = NSTextView(usingTextLayoutManager: false)
        view.isEditable = false
        view.isSelectable = selectable
        view.drawsBackground = false
        view.textContainerInset = .zero
        view.textContainer?.lineFragmentPadding = 0
        view.textContainer?.lineBreakMode = .byTruncatingTail
        view.textContainer?.widthTracksTextView = true
        view.isVerticallyResizable = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }

    func updateNSView(_ view: NSTextView, context: Context) {
        let key = key(dark: view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua)
        guard key != context.coordinator.drawn else { return }
        context.coordinator.drawn = key
        view.isSelectable = selectable
        view.textStorage?.setAttributedString(drawn())
        view.textContainer?.maximumNumberOfLines = maxLines
        view.setAccessibilityLabel(spoken)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, nsView: NSTextView, context: Context) -> CGSize? {
        let width = proposal.width ?? 300
        guard let container = nsView.textContainer, let layout = nsView.layoutManager else { return nil }
        container.containerSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        // Whole lines dropped to fit a short frame, as a SwiftUI Text does (see the iOS twin).
        var lines = maxLines
        container.maximumNumberOfLines = lines
        layout.ensureLayout(for: container)
        var height = layout.usedRect(for: container).height
        if let limit = proposal.height, limit.isFinite {
            while height > limit + 0.5, lines > 1 {
                lines -= 1
                container.maximumNumberOfLines = lines
                layout.ensureLayout(for: container)
                height = layout.usedRect(for: container).height
            }
        }
        return CGSize(width: width, height: ceil(height))
    }
}
#endif
