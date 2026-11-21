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
    /// Text to type at the cursor, such as a placeholder from the editor's menu; cleared once typed.
    var insertion: Binding<String?> = .constant(nil)
    /// Buttons on the bar above the keyboard (iPhone, iPad) that type their token at the cursor.
    var keyboardBar: [EditorBarItem] = []

    fileprivate static func rendered(_ text: String, format: TextFormat, size: CGFloat) -> NSAttributedString {
        RichText.nsAttributed(format == .rich ? text : RichText.escape(text), size: size, editorColors: true)
    }

    fileprivate static let codeFontSizeDelta: CGFloat = -2

    /// Just enough room between lines that pills on wrapped lines almost meet but never touch (FillInPills.swift).
    fileprivate static let lines: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        return style
    }()

    /// What the view shows: the rendered text with its pills and line spacing.
    fileprivate static func display(_ rendered: NSAttributedString, font: PillFont) -> NSAttributedString {
        let out = NSMutableAttributedString(attributedString: FillInPills.pilled(rendered, font: font))
        out.addAttribute(.paragraphStyle, value: lines, range: NSRange(location: 0, length: out.length))
        return out
    }
}

/// One button on the editor's keyboard bar.
struct EditorBarItem {
    let title: String
    let icon: String
    let action: () -> Void
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
        context.coordinator.setBar(keyboardBar, on: view)
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self
        if coordinator.configuredFormat != format { coordinator.configure(view, for: format) }
        coordinator.setBar(keyboardBar, on: view)
        // Only outside changes (paste button, undo, format switch) reload the view.
        if text != coordinator.lastText || format != coordinator.lastFormat {
            coordinator.load(view, text: text, format: format)
        }
        if let pending = insertion.wrappedValue {
            // Typed like a key press, so undo, the delegate and the binding all see it.
            view.insertText(pending)
            coordinator.textViewDidChange(view)
            DispatchQueue.main.async { insertion.wrappedValue = nil }
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
        private var barItems: [EditorBarItem] = []

        /// The bar above the keyboard: a system UIToolbar as the text view's input accessory, as Notes has,
        /// which iOS draws itself (glass on iOS 26). SwiftUI's keyboard toolbar never reaches a UIKit text view.
        func setBar(_ items: [EditorBarItem], on view: UITextView) {
            guard items.map(\.title) != barItems.map(\.title) else { return }
            barItems = items
            guard !items.isEmpty else {
                view.inputAccessoryView = nil
                view.reloadInputViews()
                return
            }
            let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
            // Side by side, centred: iOS 26 draws adjacent items as one glass group, as Notes' bar is.
            var buttons: [UIBarButtonItem] = [.flexibleSpace()]
            for item in items {
                let button = UIBarButtonItem(image: UIImage(systemName: item.icon), primaryAction: UIAction(title: item.title) { _ in item.action() })
                button.accessibilityLabel = item.title
                buttons.append(button)
            }
            buttons.append(.flexibleSpace())
            toolbar.items = buttons
            toolbar.sizeToFit()
            toolbar.accessibilityIdentifier = "fillInKeyboardBar"
            view.inputAccessoryView = toolbar
            view.reloadInputViews()
        }

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
                view.attributedText = FormattedTextEditor.display(FormattedTextEditor.rendered(text, format: format, size: bodySize), font: .systemFont(ofSize: bodySize))
                view.typingAttributes = [.font: UIFont.systemFont(ofSize: bodySize), .foregroundColor: UIColor.label, .paragraphStyle: FormattedTextEditor.lines]
            }
        }

        func textViewDidChange(_ view: UITextView) {
            if parent.format == .code {
                report(view.text, format: .code)
                return
            }
            // Leave composing (marked) text alone, or CJK input breaks.
            guard view.markedTextRange == nil else { return }
            // Pills (FillInPills.swift) are read back as their tokens.
            let source = FillInPills.expanded(view.attributedText)
            let markdown = RichText.markdown(from: source, trimTrailingNewlines: false)
            let format: TextFormat = markdown == nil ? .plain : .rich
            let text = markdown ?? source.string
            let font = UIFont.systemFont(ofSize: bodySize)
            // Pasted fonts and colours are dropped by drawing the kept styles again.
            let normal = FormattedTextEditor.rendered(text, format: format, size: bodySize)
            let shown = FormattedTextEditor.display(normal, font: font)
            if FillInPills.hasRawToken(view.attributedText.string) {
                // A fill-in just inserted or pasted becomes a pill, the cursor kept after it.
                let location = FillInPills.location(afterPilling: view.attributedText.string, at: view.selectedRange.location)
                view.attributedText = shown
                view.selectedRange = NSRange(location: location, length: 0)
            } else if normal.string == source.string, !FillInPills.expanded(shown).isEqual(to: source) {
                let selection = view.selectedRange
                view.attributedText = shown
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
        if let pending = insertion.wrappedValue {
            view.insertText(pending, replacementRange: view.selectedRange())
            coordinator.textDidChange(Notification(name: NSText.didChangeNotification, object: view))
            DispatchQueue.main.async { insertion.wrappedValue = nil }
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
                view.textStorage?.setAttributedString(FormattedTextEditor.display(FormattedTextEditor.rendered(text, format: format, size: bodySize), font: .systemFont(ofSize: bodySize)))
                view.typingAttributes = [.font: NSFont.systemFont(ofSize: bodySize), .foregroundColor: NSColor.textColor, .paragraphStyle: FormattedTextEditor.lines]
            }
        }

        func textDidChange(_ notification: Notification) {
            guard let view = notification.object as? NSTextView else { return }
            if parent.format == .code {
                report(view.string, format: .code)
                return
            }
            guard !view.hasMarkedText(), let storage = view.textStorage else { return }
            // Pills (FillInPills.swift) are read back as their tokens.
            let source = FillInPills.expanded(storage)
            let markdown = RichText.markdown(from: source, trimTrailingNewlines: false)
            let format: TextFormat = markdown == nil ? .plain : .rich
            let text = markdown ?? source.string
            let font = NSFont.systemFont(ofSize: bodySize)
            let normal = FormattedTextEditor.rendered(text, format: format, size: bodySize)
            let shown = FormattedTextEditor.display(normal, font: font)
            if FillInPills.hasRawToken(storage.string) {
                // A fill-in just inserted or pasted becomes a pill, the cursor kept after it.
                let location = FillInPills.location(afterPilling: storage.string, at: view.selectedRange().location)
                storage.setAttributedString(shown)
                view.setSelectedRange(NSRange(location: location, length: 0))
            } else if normal.string == source.string, !FillInPills.expanded(shown).isEqual(to: source) {
                let selection = view.selectedRanges
                storage.setAttributedString(shown)
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
