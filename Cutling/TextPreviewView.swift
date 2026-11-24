//
//  TextPreviewView.swift
//  Cutling
//
//  The editor form's look at a cutling's text: drawn by the Text page's own renderer
//  (FormattedTextEditor.rendered and .display), so pills are the text's size and wrapped lines sit
//  3 pt apart exactly as on the page. A SwiftUI Text can't: an inline pill image as tall as the line
//  pushes every wrapped line apart. Read-only; a tap goes to the row around it.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#if os(iOS)
import SwiftUI
import UIKit

struct TextPreviewView: UIViewRepresentable {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let text: String
    let format: TextFormat
    var maxLines = 8

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
        return view
    }

    /// What the text view last drew, so a pass that changes nothing leaves it alone.
    final class Coordinator { var drawn = "" }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func updateUIView(_ view: UITextView, context: Context) {
        // Follows the person's text size: a change of dynamicTypeSize calls this again with the body style's new size.
        let size = UIFont.preferredFont(forTextStyle: .body).pointSize
        // Drawn again only when what it shows changes. Each assignment made a new text with new pill images, which
        // re-measured the form's row inside the layout pass that asked for it: with the Text page open, the editor's
        // navigation view was laid out again and again (UIKit's observation feedback loop) and stalled the page.
        let drawn = "\(text)|\(format)|\(size)|\(maxLines)|\(view.traitCollection.userInterfaceStyle.rawValue)"
        guard drawn != context.coordinator.drawn else { return }
        context.coordinator.drawn = drawn
        let source = Cutling.previewSource(text)
        let rendered = FormattedTextEditor.rendered(source, format: format, size: size)
        view.attributedText = FormattedTextEditor.display(rendered, font: UIFont.systemFont(ofSize: size))
        view.textContainer.maximumNumberOfLines = maxLines
        // Spoken with each pill read as its name or today's value, as the cards read them.
        view.isAccessibilityElement = true
        view.accessibilityLabel = FillInPills.split(format == .rich ? RichText.plainText(source) : source).map { piece in
            switch piece {
            case .text(let run): run
            case .token(let token): FillInPills.previewValue(of: token) ?? FillInPills.title(of: token)
            }
        }.joined()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let width = proposal.width ?? 320
        let fit = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: ceil(fit.height))
    }
}
#endif
