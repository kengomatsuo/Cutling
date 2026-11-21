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
    /// A pill was tapped: its token and where it sits (iPhone, iPad).
    var onEditPill: ((String, NSRange) -> Void)? = nil
    /// A pill's new token, to be typed over the old one (iPhone, iPad).
    var replacement: Binding<PillReplacement?> = .constant(nil)
    /// Whether the Format panel stands in for the keyboard (iPhone, iPad).
    var formatPanel: Binding<Bool> = .constant(false)
    /// Opens with the keyboard up (iPhone, iPad).
    var autofocus = false
    /// Whether the text is being edited: the cursor is in it, with a software keyboard or a hardware one (iPhone, iPad).
    var editing: Binding<Bool> = .constant(false)
    #if os(iOS)
    /// The styles at the cursor and the way to toggle one, for a Format panel drawn outside the editor (iPad's popover).
    var styles: EditorStyles? = nil
    #endif

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
    #if os(iOS)
    /// A formatting button: it toggles this style at the cursor and shows filled while the style is on, as Notes' B does.
    var style: EditorStyle? = nil
    #endif
    let action: () -> Void
}

/// The token that takes a pill's place, found by the pill's range when it was tapped.
struct PillReplacement: Equatable {
    let range: NSRange
    let token: String
}

#if os(iOS)
/// The editor's bar above the keyboard, drawn to Notes' own on iOS 27 (docs/research/editor-notes/owner-recording):
/// one glass capsule 48 pt tall, 10 pt in from each side and 10 pt above the keyboard, its buttons a fixed
/// step apart and scrolling sideways, so one more is always cut off at the edge.
struct EditorKeyboardBar: View {
    let items: [EditorBarItem]
    /// Which styles are on at the cursor; a formatting button reads it and toggles through it.
    let styles: EditorStyles
    static let barHeight: CGFloat = 48
    /// Capsule height plus the gap above the keyboard.
    static let height: CGFloat = barHeight + 10
    /// Notes' insert buttons sit about 70 pt apart, the first 30 pt in from the capsule's edge;
    /// its formatting glyphs, further along the same bar, about 58 pt apart.
    static let step: CGFloat = 70
    static let styleStep: CGFloat = 58

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(items, id: \.title) { item in
                    if let style = item.style {
                        EditorBarButton(item: EditorBarItem(title: item.title, icon: item.icon) { styles.toggle(style) },
                                        active: styles.active.contains(style))
                            .frame(width: Self.styleStep, height: Self.barHeight)
                    } else {
                        EditorBarButton(item: item)
                            .frame(width: Self.step, height: Self.barHeight)
                    }
                }
            }
            .padding(.leading, -5)
            .padding(.trailing, 4)
        }
        .frame(height: Self.barHeight)
        .clipShape(Capsule())
        .modifier(EditorBarGlass())
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("fillInKeyboardBar")
    }
}

/// One button of the editor's bars: a symbol in the label colour, at the size Notes draws its own.
/// A style that is on stands on a filled circle in the app's tint, its glyph white, as Notes fills B.
struct EditorBarButton: View {
    let item: EditorBarItem
    var active = false

    var body: some View {
        Button(action: item.action) {
            Image(systemName: item.icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(active ? Color.white : Color.primary)
                .frame(width: 42, height: 42)
                .background(active ? Color.accentColor : Color.clear, in: Circle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(active ? .isSelected : [])
    }
}

/// Notes' bar is a glass capsule on iOS 26 and later; earlier systems get the bar material.
struct EditorBarGlass: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.glassEffect(.regular.interactive(), in: Capsule())
        } else {
            content.background(.bar, in: Capsule())
        }
    }
}

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
        context.coordinator.styles.toggle = { [weak coordinator = context.coordinator, weak view] style in
            guard let coordinator, let view else { return }
            coordinator.toggle(style, in: view)
        }
        if autofocus { DispatchQueue.main.async { view.becomeFirstResponder() } }
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self
        if coordinator.configuredFormat != format { coordinator.configure(view, for: format) }
        coordinator.setBar(keyboardBar, on: view)
        coordinator.setPanel(open: formatPanel.wrappedValue, on: view)
        // Only outside changes (paste button, undo, format switch) reload the view.
        if text != coordinator.lastText || format != coordinator.lastFormat {
            coordinator.load(view, text: text, format: format)
        }
        // The binding is cleared a turn later, and this runs again before then: each token is typed once.
        if let pending = insertion.wrappedValue, !coordinator.typing {
            coordinator.typing = true
            // On the page a fill-in picked with the keyboard down starts typing, as Notes' bottom bar does.
            if autofocus, !view.isFirstResponder { view.becomeFirstResponder() }
            // Typed like a key press, so undo, the delegate and the binding all see it.
            view.insertText(pending)
            coordinator.textViewDidChange(view)
            DispatchQueue.main.async {
                insertion.wrappedValue = nil
                coordinator.typing = false
            }
        }
        if let swap = replacement.wrappedValue, !coordinator.replacing {
            coordinator.replacing = true
            coordinator.replacePill(in: view, with: swap)
            DispatchQueue.main.async {
                replacement.wrappedValue = nil
                coordinator.replacing = false
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: FormattedTextEditor
        var lastText = ""
        var lastFormat: TextFormat = .plain
        var configuredFormat: TextFormat?
        /// An insertion or a pill's replacement is typed and its binding not yet cleared.
        var typing = false
        var replacing = false

        init(parent: FormattedTextEditor) { self.parent = parent }

        private var bodySize: CGFloat { UIFont.preferredFont(forTextStyle: .body).pointSize }
        private var barItems: [EditorBarItem] = []
        private var barHost: UIHostingController<EditorKeyboardBar>?
        private var barContainer: UIView?
        private let ownStyles = EditorStyles()
        var styles: EditorStyles { parent.styles ?? ownStyles }
        private var panelHost: UIHostingController<FormatPanel>?

        /// The bar above the keyboard (`EditorKeyboardBar`). SwiftUI's keyboard toolbar never reaches a UIKit text view,
        /// so the bar is the text view's input accessory and comes and goes with the keyboard.
        func setBar(_ items: [EditorBarItem], on view: UITextView) {
            let sameButtons = items.map(\.title) == barItems.map(\.title)
            barItems = items
            guard !items.isEmpty else {
                guard barContainer != nil else { return }
                barHost = nil
                barContainer = nil
                view.inputAccessoryView = nil
                view.reloadInputViews()
                return
            }
            // The same buttons: left as they are, so typing never redraws the bar or moves the keyboard.
            if sameButtons, barHost != nil { return }
            let host = UIHostingController(rootView: EditorKeyboardBar(items: items, styles: styles))
            host.view.backgroundColor = .clear
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: EditorKeyboardBar.height))
            container.backgroundColor = .clear
            host.view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(host.view)
            NSLayoutConstraint.activate([
                host.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                host.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                host.view.topAnchor.constraint(equalTo: container.topAnchor),
                host.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ])
            barHost = host
            barContainer = container
            // The Format panel stands alone, as in Notes: no bar above it.
            if view.inputView == nil {
                view.inputAccessoryView = container
                view.reloadInputViews()
            }
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

        // MARK: Pills

        /// A tap on a pill opens its editor (iOS 17 text items); other items keep their default.
        func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
            guard case .textAttachment(let attachment) = textItem.content, let pill = attachment as? FillInAttachment,
                  let edit = parent.onEditPill, FillInEdit(token: pill.token) != nil else { return defaultAction }
            let range = textItem.range
            return UIAction { _ in edit(pill.token, range) }
        }

        /// Types `swap.token` over the pill at `swap.range`; the token then draws as a pill again.
        func replacePill(in view: UITextView, with swap: PillReplacement) {
            guard swap.range.upperBound <= view.textStorage.length else { return }
            view.selectedRange = swap.range
            // The selection's own attributes carry the old pill's attachment; the new token must not.
            var typing = view.typingAttributes
            typing[.attachment] = nil
            view.typingAttributes = typing
            view.insertText(swap.token)
            textViewDidChange(view)
        }

        // MARK: Format panel

        /// The Format panel takes the keyboard's place and the bar leaves with the keyboard; closing it brings both back.
        func setPanel(open: Bool, on view: UITextView) {
            if open, view.inputView == nil {
                refreshStyles(view)
                let host = UIHostingController(rootView: FormatPanel(styles: styles, close: { [weak self] in self?.parent.formatPanel.wrappedValue = false }))
                host.view.backgroundColor = .clear
                host.safeAreaRegions = []
                host.view.translatesAutoresizingMaskIntoConstraints = false
                // A plain view, not a keyboard-style UIInputView: that style draws the keyboard's grey tray around the
                // card, where Notes shows its Format card floating alone over the note.
                let panel = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: FormatPanel.height))
                // The page's own background, so the system's keyboard backdrop behind an input view never shows
                // as a grey tray around the card.
                panel.backgroundColor = .systemBackground
                panel.addSubview(host.view)
                NSLayoutConstraint.activate([
                    host.view.topAnchor.constraint(equalTo: panel.topAnchor),
                    host.view.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
                    host.view.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
                    host.view.bottomAnchor.constraint(equalTo: panel.bottomAnchor),
                    panel.heightAnchor.constraint(equalToConstant: FormatPanel.height),
                ])
                panelHost = host
                view.inputView = panel
                view.inputAccessoryView = nil
                view.reloadInputViews()
            } else if !open, view.inputView != nil {
                view.inputView = nil
                view.inputAccessoryView = barContainer
                panelHost = nil
                view.reloadInputViews()
            }
        }

        func textViewDidBeginEditing(_ view: UITextView) {
            DispatchQueue.main.async { self.parent.editing.wrappedValue = true }
        }

        func textViewDidEndEditing(_ view: UITextView) {
            DispatchQueue.main.async { self.parent.editing.wrappedValue = false }
            if parent.formatPanel.wrappedValue { DispatchQueue.main.async { self.parent.formatPanel.wrappedValue = false } }
        }

        func textViewDidChangeSelection(_ view: UITextView) { refreshStyles(view) }

        private func currentAttributes(_ view: UITextView) -> [NSAttributedString.Key: Any] {
            let range = view.selectedRange
            if range.length > 0, range.upperBound <= view.textStorage.length { return view.textStorage.attributes(at: range.location, effectiveRange: nil) }
            return view.typingAttributes
        }

        private func refreshStyles(_ view: UITextView) {
            let attributes = currentAttributes(view)
            var active: Set<EditorStyle> = []
            if let font = attributes[.font] as? UIFont {
                let traits = font.fontDescriptor.symbolicTraits
                if traits.contains(.traitBold) { active.insert(.bold) }
                if traits.contains(.traitItalic) { active.insert(.italic) }
                if traits.contains(.traitMonoSpace) { active.insert(.monospace) }
            }
            if let strike = attributes[.strikethroughStyle] as? Int, strike != 0 { active.insert(.strikethrough) }
            if attributes[.link] != nil { active.insert(.link) }
            if styles.active != active { styles.active = active }
        }

        func toggle(_ style: EditorStyle, in view: UITextView) {
            let turnOn = !styles.active.contains(style)
            switch style {
            case .bold: view.toggleBoldface(nil)
            case .italic: view.toggleItalics(nil)
            case .strikethrough:
                change(view) { $0[.strikethroughStyle] = turnOn ? NSUnderlineStyle.single.rawValue : nil }
            case .monospace:
                change(view) { attributes in
                    guard let font = attributes[.font] as? UIFont else { return }
                    let traits = font.fontDescriptor.symbolicTraits
                    let weight: UIFont.Weight = traits.contains(.traitBold) ? .bold : .regular
                    var made = turnOn ? UIFont.monospacedSystemFont(ofSize: font.pointSize, weight: weight) : UIFont.systemFont(ofSize: font.pointSize, weight: weight)
                    if traits.contains(.traitItalic), let italic = made.fontDescriptor.withSymbolicTraits(made.fontDescriptor.symbolicTraits.union(.traitItalic)) {
                        made = UIFont(descriptor: italic, size: font.pointSize)
                    }
                    attributes[.font] = made
                }
            case .link:
                if turnOn { askForLink(in: view) } else { change(view) { $0[.link] = nil } }
            }
            textViewDidChange(view)
            refreshStyles(view)
        }

        /// Sets or clears an attribute on the selection, or on what is typed next when nothing is selected.
        private func change(_ view: UITextView, _ edit: (inout [NSAttributedString.Key: Any]) -> Void) {
            let range = view.selectedRange
            if range.length == 0 {
                var attributes = view.typingAttributes
                edit(&attributes)
                view.typingAttributes = attributes
                return
            }
            let storage = view.textStorage
            storage.beginEditing()
            storage.enumerateAttributes(in: range) { attributes, run, _ in
                var made = attributes
                edit(&made)
                storage.setAttributes(made, range: run)
            }
            storage.endEditing()
        }

        /// Notes asks in an Add Link sheet (Link To, Name); so does this.
        private func askForLink(in view: UITextView) {
            let range = view.selectedRange
            let sheet = UIHostingController(rootView: LinkSheet(asksName: range.length == 0) { [weak self, weak view] url, name in
                guard let self, let view else { return }
                if range.length == 0 {
                    // Nothing selected: the name, or the address itself, becomes the linked text.
                    let shown = name.isEmpty ? url.absoluteString : name
                    view.selectedRange = range
                    view.insertText(shown)
                    view.selectedRange = NSRange(location: range.location, length: (shown as NSString).length)
                } else {
                    view.selectedRange = range
                }
                self.change(view) { $0[.link] = url }
                self.textViewDidChange(view)
                self.refreshStyles(view)
            })
            var top = view.window?.rootViewController
            while let next = top?.presentedViewController { top = next }
            top?.present(sheet, animated: true)
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
