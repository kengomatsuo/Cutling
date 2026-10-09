//
//  CodeTextEditor.swift
//  Cutling
//
//  Native editor for Formatted and Code cutlings. Formatted text is styled
//  through the system's own Format menu (select text → Format → Bold), and
//  anything pasted is cut back to the styles Cutling keeps. Code is
//  monospace with smart quotes and dashes off, which SwiftUI can't do.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI

/// Edits `text` as Markdown when `format` is `.rich`, raw otherwise.
/// Removing every style turns `format` back to `.plain`.
struct FormattedTextEditor {
    @Binding var text: String
    @Binding var format: TextFormat

    fileprivate static func rendered(_ text: String, format: TextFormat, size: CGFloat) -> NSAttributedString {
        RichText.nsAttributed(format == .rich ? text : RichText.escape(text), size: size, editorColors: true)
    }

    fileprivate static let codeFontSizeDelta: CGFloat = -2
}

#if os(iOS)
extension FormattedTextEditor: UIViewRepresentable {
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator
        view.backgroundColor = .clear
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.adjustsFontForContentSizeCategory = true
        context.coordinator.configure(view, for: format)
        context.coordinator.load(view, text: text, format: format)
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self
        if coordinator.configuredFormat != format { coordinator.configure(view, for: format) }
        // Only outside changes (paste button, undo, format switch) reload the view.
        if text != coordinator.lastText || format != coordinator.lastFormat {
            coordinator.load(view, text: text, format: format)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: FormattedTextEditor
        var lastText = ""
        var lastFormat: TextFormat = .plain
        var configuredFormat: TextFormat?

        init(parent: FormattedTextEditor) { self.parent = parent }

        private var bodySize: CGFloat { UIFont.preferredFont(forTextStyle: .body).pointSize }

        func configure(_ view: UITextView, for format: TextFormat) {
            configuredFormat = format
            let code = format == .code
            view.allowsEditingTextAttributes = !code
            view.smartQuotesType = code ? .no : .default
            view.smartDashesType = code ? .no : .default
            view.smartInsertDeleteType = code ? .no : .default
            view.autocorrectionType = code ? .no : .default
            view.autocapitalizationType = code ? .none : .sentences
            view.spellCheckingType = code ? .no : .default
            view.inlinePredictionType = code ? .no : .default
            view.keyboardType = code ? .asciiCapable : .default
        }

        func load(_ view: UITextView, text: String, format: TextFormat) {
            lastText = text
            lastFormat = format
            if format == .code {
                view.attributedText = nil
                view.font = .monospacedSystemFont(ofSize: bodySize + FormattedTextEditor.codeFontSizeDelta, weight: .regular)
                view.textColor = .label
                view.text = text
            } else {
                view.attributedText = FormattedTextEditor.rendered(text, format: format, size: bodySize)
                view.typingAttributes = [.font: UIFont.systemFont(ofSize: bodySize), .foregroundColor: UIColor.label]
            }
        }

        func textViewDidChange(_ view: UITextView) {
            if parent.format == .code {
                report(view.text, format: .code)
                return
            }
            // Leave composing (marked) text alone, or CJK input breaks.
            guard view.markedTextRange == nil else { return }
            let markdown = RichText.markdown(from: view.attributedText, trimTrailingNewlines: false)
            let format: TextFormat = markdown == nil ? .plain : .rich
            let text = markdown ?? view.text ?? ""
            // Pasted fonts and colours are dropped by drawing the kept styles again.
            let normal = FormattedTextEditor.rendered(text, format: format, size: bodySize)
            if normal.string == view.attributedText.string, !normal.isEqual(to: view.attributedText) {
                let selection = view.selectedRange
                view.attributedText = normal
                view.selectedRange = selection
            }
            report(text, format: format)
        }

        private func report(_ text: String, format: TextFormat) {
            lastText = text
            lastFormat = format
            if parent.format != format { parent.format = format }
            if parent.text != text { parent.text = text }
        }
    }
}
#elseif os(macOS)
extension FormattedTextEditor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.drawsBackground = false
        guard let view = scrollView.documentView as? NSTextView else { return scrollView }
        view.delegate = context.coordinator
        view.drawsBackground = false
        view.allowsUndo = true
        context.coordinator.configure(view, for: format)
        context.coordinator.load(view, text: text, format: format)
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let view = scrollView.documentView as? NSTextView else { return }
        let coordinator = context.coordinator
        coordinator.parent = self
        if coordinator.configuredFormat != format { coordinator.configure(view, for: format) }
        if text != coordinator.lastText || format != coordinator.lastFormat {
            coordinator.load(view, text: text, format: format)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: FormattedTextEditor
        var lastText = ""
        var lastFormat: TextFormat = .plain
        var configuredFormat: TextFormat?

        init(parent: FormattedTextEditor) { self.parent = parent }

        private var bodySize: CGFloat { NSFont.systemFontSize }

        func configure(_ view: NSTextView, for format: TextFormat) {
            configuredFormat = format
            let code = format == .code
            view.isRichText = !code
            view.isAutomaticQuoteSubstitutionEnabled = !code
            view.isAutomaticDashSubstitutionEnabled = !code
            view.isAutomaticTextReplacementEnabled = !code
            view.isAutomaticSpellingCorrectionEnabled = !code
            view.isContinuousSpellCheckingEnabled = !code
        }

        func load(_ view: NSTextView, text: String, format: TextFormat) {
            lastText = text
            lastFormat = format
            if format == .code {
                view.string = text
                view.font = .monospacedSystemFont(ofSize: bodySize, weight: .regular)
                view.textColor = .textColor
            } else {
                view.textStorage?.setAttributedString(FormattedTextEditor.rendered(text, format: format, size: bodySize))
                view.typingAttributes = [.font: NSFont.systemFont(ofSize: bodySize), .foregroundColor: NSColor.textColor]
            }
        }

        func textDidChange(_ notification: Notification) {
            guard let view = notification.object as? NSTextView else { return }
            if parent.format == .code {
                report(view.string, format: .code)
                return
            }
            guard !view.hasMarkedText(), let storage = view.textStorage else { return }
            let markdown = RichText.markdown(from: storage, trimTrailingNewlines: false)
            let format: TextFormat = markdown == nil ? .plain : .rich
            let text = markdown ?? view.string
            let normal = FormattedTextEditor.rendered(text, format: format, size: bodySize)
            if normal.string == storage.string, !normal.isEqual(to: storage) {
                let selection = view.selectedRanges
                storage.setAttributedString(normal)
                view.selectedRanges = selection
            }
            report(text, format: format)
        }

        private func report(_ text: String, format: TextFormat) {
            lastText = text
            lastFormat = format
            if parent.format != format { parent.format = format }
            if parent.text != text { parent.text = text }
        }
    }
}
#endif
