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

    func updateUIView(_ view: UITextView, context: Context) {
        let size = UIFont.preferredFont(forTextStyle: .body).pointSize
        let source = Cutling.previewSource(text)
        let rendered = FormattedTextEditor.rendered(source, format: format, size: size)
        view.attributedText = FormattedTextEditor.display(rendered, font: UIFont.systemFont(ofSize: size))
        view.textContainer.maximumNumberOfLines = maxLines
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let width = proposal.width ?? 320
        let fit = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: ceil(fit.height))
    }
}
#endif
