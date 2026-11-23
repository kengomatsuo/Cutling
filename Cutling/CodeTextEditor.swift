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
    /// The text is a whole page, as a Notes note (iPhone, iPad): a drag anywhere in it scrolls, however short the text,
    /// and a drag down through the keyboard carries the keyboard with it.
    var fullPage = false
    /// Whether the text is being edited: the cursor is in it, with a software keyboard or a hardware one (iPhone, iPad).
    var editing: Binding<Bool> = .constant(false)
    #if os(iOS)
    /// The styles at the cursor and the way to toggle one, for a Format panel drawn outside the editor (iPad's popover).
    var styles: EditorStyles? = nil
    #endif

    static func rendered(_ text: String, format: TextFormat, size: CGFloat) -> NSAttributedString {
        RichText.nsAttributed(format == .rich ? text : RichText.escape(text), size: size, editorColors: true)
    }

    fileprivate static let codeFontSizeDelta: CGFloat = -2

    /// Just enough room between lines that pills on wrapped lines almost meet but never touch (FillInPills.swift).
    fileprivate static let lines: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        return style
    }()

    /// What the view shows: the rendered text with its pills and line spacing. A list line keeps its hanging indent.
    static func display(_ rendered: NSAttributedString, font: PillFont) -> NSAttributedString {
        let out = NSMutableAttributedString(attributedString: FillInPills.pilled(rendered, font: font))
        let full = NSRange(location: 0, length: out.length)
        var styled: [(NSRange, NSParagraphStyle)] = []
        out.enumerateAttribute(.paragraphStyle, in: full) { value, range, _ in
            guard let style = value as? NSParagraphStyle else { return }
            styled.append((range, style))
        }
        out.addAttribute(.paragraphStyle, value: lines, range: full)
        for (range, style) in styled {
            let merged = (style.mutableCopy() as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
            merged.lineSpacing = lines.lineSpacing
            out.addAttribute(.paragraphStyle, value: merged, range: range)
        }
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
    /// A button with choices, as Notes' list button: its menu grows above the bar and the button is filled while one is on.
    var menu: [EditorStyle] = []
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
    /// The bar blurs away as the Format card comes in and blurs back as the keyboard returns, as Notes' does.
    var motion: FormatCardMotion? = nil
    static let barHeight: CGFloat = 48
    /// Capsule height plus the gap above the keyboard.
    static let height: CGFloat = barHeight + 10
    /// Notes' insert buttons sit about 70 pt apart, the first 30 pt in from the capsule's edge;
    /// its formatting glyphs, further along the same bar, about 58 pt apart.
    static let step: CGFloat = 70
    static let styleStep: CGFloat = 58

    private var shown: Bool { motion?.barIn ?? true }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(items, id: \.title) { item in
                    if !item.menu.isEmpty {
                        EditorBarMenu(item: item, styles: styles)
                            .frame(width: Self.styleStep, height: Self.barHeight)
                    } else if let style = item.style {
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
        .blur(radius: shown ? 0 : FormatCardMotion.barBlur)
        .opacity(shown ? 1 : 0)
        .allowsHitTesting(shown)
        .accessibilityHidden(!shown)
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
            EditorBarGlyph(icon: item.icon, active: active)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(active ? .isSelected : [])
        .accessibilityIdentifier("editorBar.\(item.icon)")
    }
}

/// The face of a bar button, shared by plain buttons and menus.
struct EditorBarGlyph: View {
    let icon: String
    let active: Bool

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(active ? Color.white : Color.primary)
            .frame(width: 42, height: 42)
            .background(active ? Color.brandGreen : Color.clear, in: Circle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
    }
}

/// Notes' list button: a menu of Bulleted, Dashed and Numbered that grows above the bar, icon then name,
/// the one the cursor is in ticked. The button is filled while the cursor is in a list.
struct EditorBarMenu: View {
    let item: EditorBarItem
    let styles: EditorStyles

    var body: some View {
        let active = item.menu.contains { styles.active.contains($0) }
        Menu {
            ForEach(item.menu, id: \.self) { style in
                Toggle(isOn: Binding(get: { styles.active.contains(style) }, set: { _ in styles.toggle(style) })) {
                    Label(style.title, systemImage: style.icon)
                }
            }
        } label: {
            EditorBarGlyph(icon: item.icon, active: active)
        }
        .menuOrder(.fixed)
        .buttonStyle(.plain)
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(active ? .isSelected : [])
        .accessibilityIdentifier("editorBarMenu.\(item.icon)")
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

/// The Format panel's place in the keyboard's stead; it tells once when it is on screen, so the card's rise starts there.
final class FormatPanelSlot: UIView {
    var onWindow: (() -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil, let start = onWindow else { return }
        onWindow = nil
        // A turn later: iOS places input views with animations off, which would end the card's rise at once.
        DispatchQueue.main.async(execute: start)
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
        context.coordinator.followTextSize(of: view)
        context.coordinator.setBar(keyboardBar, on: view)
        context.coordinator.styles.toggle = { [weak coordinator = context.coordinator, weak view] style in
            guard let coordinator, let view else { return }
            coordinator.toggle(style, in: view)
        }
        if fullPage {
            // Notes' note: the text bounces under the finger even when it fits, so a drag is the text's own scroll;
            // a drag that runs into the keyboard pulls it down.
            view.alwaysBounceVertical = true
            view.keyboardDismissMode = .interactive
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
        /// The Format card's way in and out, and the bar's with it.
        private let motion = FormatCardMotion()
        /// The keyboard's stand-in is the keyboard's height while the card comes in, then the card's.
        private var panelHeight: NSLayoutConstraint?

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
            let host = UIHostingController(rootView: EditorKeyboardBar(items: items, styles: styles, motion: motion))
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

        private var textSizeObserver: NSObjectProtocol?

        /// Redraws the text at the new size when the person changes their text size: the text carries fonts sized
        /// from the body style when it was drawn, which adjustsFontForContentSizeCategory alone leaves as they were.
        func followTextSize(of view: UITextView) {
            textSizeObserver = NotificationCenter.default.addObserver(
                forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: .main
            ) { [weak self, weak view] _ in
                MainActor.assumeIsolated {
                    guard let self, let view else { return }
                    let selection = view.selectedRange
                    self.load(view, text: self.parent.text, format: self.parent.format)
                    let length = (view.text as NSString).length
                    view.selectedRange = NSRange(location: min(selection.location, length), length: 0)
                }
            }
        }

        deinit {
            if let textSizeObserver { NotificationCenter.default.removeObserver(textSizeObserver) }
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
        /// The motion is Notes' own, read frame by frame from the owner's recording (FormatCardMotion): opening, the keyboard
        /// goes at once and the bar stays where it was, then the card rises from below the screen while the bar blurs away;
        /// closing, the keyboard comes back up in front of the card while the bar blurs back in.
        func setPanel(open: Bool, on view: UITextView) {
            if open, view.inputView == nil {
                refreshStyles(view)
                let host = UIHostingController(rootView: FormatPanel(styles: styles, close: { [weak self] in self?.parent.formatPanel.wrappedValue = false }))
                host.view.backgroundColor = .clear
                host.safeAreaRegions = []
                host.view.translatesAutoresizingMaskIntoConstraints = false
                // A plain view, not a keyboard-style UIInputView: that style draws the keyboard's grey tray around the
                // card, where Notes shows its Format card floating alone over the note.
                // The keyboard's own height first, so the bar above stays where it was while it blurs away, as Notes' does.
                // iOS takes an input view's height from its frame, so the frame carries it as well as the constraint.
                let start = max(FormatPanel.height, keyboardHeight() ?? 0)
                let panel = FormatPanelSlot(frame: CGRect(x: 0, y: 0, width: 0, height: start))
                // The page's own background, so the system's keyboard backdrop behind an input view never shows
                // as a grey tray around the card.
                panel.backgroundColor = .systemBackground
                panel.addSubview(host.view)
                let height = panel.heightAnchor.constraint(equalToConstant: start)
                NSLayoutConstraint.activate([
                    host.view.heightAnchor.constraint(equalToConstant: FormatPanel.height),
                    host.view.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
                    host.view.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
                    host.view.bottomAnchor.constraint(equalTo: panel.bottomAnchor),
                    height,
                ])
                let reduced = FormatCardMotion.reduced
                // The card waits just below the screen (or, with Reduce Motion, unseen in its place).
                if reduced { host.view.alpha = 0 } else { host.view.transform = CGAffineTransform(translationX: 0, y: FormatPanel.height) }
                panelHost = host
                panelHeight = height
                // Once the panel stands in the keyboard's place: iOS puts an input view in its window a moment after
                // reloadInputViews, and an animation started before then ends at once.
                panel.onWindow = { [weak self, weak view, weak panel, weak host] in
                    guard let self, let host else { return }
                    host.view.superview?.layoutIfNeeded()
                    let settle = { [weak self] in
                        // Closed again before the card settled: the keyboard and its bar are already back.
                        guard let self, let view, let panel, view.inputView === panel else { return }
                        // The Format panel stands alone, as in Notes: no bar above it, and the page down to the card.
                        self.panelHeight?.constant = FormatPanel.height
                        panel.frame.size.height = FormatPanel.height
                        view.inputAccessoryView = nil
                        view.reloadInputViews()
                    }
                    if reduced {
                        UIView.animate(withDuration: FormatCardMotion.reducedDuration, delay: 0, options: .curveEaseOut,
                                       animations: { host.view.alpha = 1 }, completion: { _ in settle() })
                    } else {
                        UIView.animate(springDuration: FormatCardMotion.duration, bounce: 0,
                                       animations: { host.view.transform = .identity }, completion: { _ in settle() })
                    }
                    withAnimation(FormatCardMotion.animation) { self.motion.barIn = false }
                }
                view.inputView = panel
                view.reloadInputViews()
            } else if !open, view.inputView != nil {
                view.inputView = nil
                view.inputAccessoryView = barContainer
                panelHost = nil
                panelHeight = nil
                view.reloadInputViews()
                withAnimation(FormatCardMotion.animation) { motion.barIn = true }
            }
        }

        /// The software keyboard's height below the bar, read in screen points from where the bar stands (the keyboard's
        /// own window is not the screen's size); nil with no bar on screen.
        private func keyboardHeight() -> CGFloat? {
            guard let bar = barContainer, let screen = bar.window?.windowScene?.screen else { return nil }
            let height = screen.bounds.height - bar.convert(bar.bounds, to: screen.coordinateSpace).maxY
            return height > 0 ? height : nil
        }

        func textViewDidBeginEditing(_ view: UITextView) {
            DispatchQueue.main.async { self.parent.editing.wrappedValue = true }
        }

        func textViewDidEndEditing(_ view: UITextView) {
            DispatchQueue.main.async { self.parent.editing.wrappedValue = false }
            if parent.formatPanel.wrappedValue { DispatchQueue.main.async { self.parent.formatPanel.wrappedValue = false } }
        }

        func textViewDidChangeSelection(_ view: UITextView) {
            // A list's marker is the list's, as in Notes: the cursor never stands inside or before it.
            if view.markedTextRange == nil, view.selectedRange.length == 0,
               let item = listItem(containing: view.selectedRange.location, in: view.textStorage),
               view.selectedRange.location < item.paragraph.location + item.marker {
                view.selectedRange = NSRange(location: item.paragraph.location + item.marker, length: 0)
                return
            }
            // Text typed after a marker is not part of it.
            if view.typingAttributes[.cutlingListMarker] != nil {
                var typing = view.typingAttributes
                typing[.cutlingListMarker] = nil
                view.typingAttributes = typing
            }
            refreshStyles(view)
        }

        // MARK: Lists

        /// The list item a location sits in: its kind, its paragraph without the newline, and its marker's length.
        private func listItem(containing location: Int, in storage: NSTextStorage) -> (kind: ListKind, paragraph: NSRange, marker: Int)? {
            let string = storage.string as NSString
            var paragraph = string.paragraphRange(for: NSRange(location: min(location, string.length), length: 0))
            if paragraph.length > 0, string.character(at: paragraph.upperBound - 1) == 10 { paragraph.length -= 1 }
            guard paragraph.length > 0,
                  let raw = storage.attribute(.cutlingListMarker, at: paragraph.location, effectiveRange: nil) as? String,
                  let kind = ListKind(rawValue: raw),
                  let found = ListKind.leading(string.substring(with: paragraph)) else { return nil }
            return (kind, paragraph, found.length)
        }

        private func marker(_ kind: ListKind, _ number: Int) -> NSAttributedString {
            NSAttributedString(string: kind.marker(number), attributes: [
                .font: UIFont.systemFont(ofSize: bodySize), .foregroundColor: UIColor.label,
                .paragraphStyle: FormattedTextEditor.lines, .cutlingListMarker: kind.rawValue,
            ])
        }

        /// Makes every paragraph the selection touches this list, or takes them out when they all are, as Notes' list menu does.
        private func setList(_ kind: ListKind, in view: UITextView) {
            let storage = view.textStorage
            let string = storage.string as NSString
            let selection = view.selectedRange
            let span = string.paragraphRange(for: selection)
            var paragraphs: [NSRange] = []
            string.enumerateSubstrings(in: span, options: [.byParagraphs, .substringNotRequired]) { _, range, _, _ in paragraphs.append(range) }
            if paragraphs.isEmpty { paragraphs = [NSRange(location: span.location, length: 0)] }
            let items = paragraphs.map { listItem(containing: $0.location, in: storage) }
            let removing = items.allSatisfy { $0?.kind == kind }
            edit(view) { storage in
                var delta = 0
                var firstMarker = 0
                for (index, paragraph) in paragraphs.enumerated().reversed() {
                    let old = items[index]?.marker ?? 0
                    let made = removing ? NSAttributedString() : marker(kind, index + 1)
                    storage.replaceCharacters(in: NSRange(location: paragraph.location, length: old), with: made)
                    delta += made.length - old
                    if index == 0 { firstMarker = made.length - old }
                }
                if selection.length == 0, paragraphs.count == 1 {
                    let start = paragraphs[0].location + (removing ? 0 : marker(kind, 1).length)
                    return NSRange(location: max(start, selection.location + firstMarker), length: 0)
                }
                let start = paragraphs[0].location
                return NSRange(location: start, length: paragraphs[paragraphs.count - 1].upperBound + delta - start)
            }
        }

        /// Return in a list starts the next item, and on an empty item ends the list; Backspace just after a marker
        /// takes the line out of the list. Each as Notes does it.
        func textView(_ view: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            guard parent.format != .code, view.markedTextRange == nil else { return true }
            let storage = view.textStorage
            if text == "\n", let item = listItem(containing: range.location, in: storage),
               range.location >= item.paragraph.location + item.marker {
                if item.paragraph.length == item.marker, range.length == 0 {
                    edit(view) { storage in
                        storage.replaceCharacters(in: NSRange(location: item.paragraph.location, length: item.marker), with: "")
                        return NSRange(location: item.paragraph.location, length: 0)
                    }
                    return false
                }
                let digits = (storage.string as NSString).substring(with: NSRange(location: item.paragraph.location, length: item.marker)).prefix { $0.isNumber }
                let next = marker(item.kind, (Int(digits) ?? 0) + 1)
                edit(view) { storage in
                    var typing = view.typingAttributes
                    typing[.cutlingListMarker] = nil
                    let inserted = NSMutableAttributedString(string: "\n", attributes: typing)
                    inserted.append(next)
                    storage.replaceCharacters(in: range, with: inserted)
                    return NSRange(location: range.location + inserted.length, length: 0)
                }
                return false
            }
            if text.isEmpty, range.length == 1, let item = listItem(containing: range.location, in: storage),
               range.location == item.paragraph.location + item.marker - 1 {
                edit(view) { storage in
                    storage.replaceCharacters(in: NSRange(location: item.paragraph.location, length: item.marker), with: "")
                    return NSRange(location: item.paragraph.location, length: 0)
                }
                return false
            }
            return true
        }

        /// Numbers each numbered list from 1, as markdown(from:) stores it.
        private func renumber(_ storage: NSTextStorage) {
            let string = storage.string as NSString
            var edits: [(NSRange, String)] = []
            var number = 0
            string.enumerateSubstrings(in: NSRange(location: 0, length: string.length), options: [.byParagraphs, .substringNotRequired]) { _, range, _, _ in
                guard range.length > 0,
                      storage.attribute(.cutlingListMarker, at: range.location, effectiveRange: nil) as? String == ListKind.numbered.rawValue,
                      let found = ListKind.leading(string.substring(with: range)), found.kind == .numbered else {
                    number = 0
                    return
                }
                number += 1
                let digits = NSRange(location: range.location, length: found.length - 2)
                if string.substring(with: digits) != "\(number)" { edits.append((digits, "\(number)")) }
            }
            for (range, text) in edits.reversed() { storage.replaceCharacters(in: range, with: text) }
        }

        /// A list edit made in the text storage, with its own undo: the whole text and selection as they were.
        private func edit(_ view: UITextView, _ body: (NSTextStorage) -> NSRange) {
            let before = NSAttributedString(attributedString: view.attributedText)
            let selection = view.selectedRange
            let storage = view.textStorage
            storage.beginEditing()
            let after = body(storage)
            renumber(storage)
            storage.endEditing()
            let location = min(after.location, storage.length)
            view.selectedRange = NSRange(location: location, length: min(after.length, storage.length - location))
            registerRestore(view, to: before, selection: selection)
            textViewDidChange(view)
            refreshStyles(view)
        }

        /// Undo puts the text back as it was, and registers the way back for redo.
        private func registerRestore(_ view: UITextView, to snapshot: NSAttributedString, selection: NSRange) {
            view.undoManager?.registerUndo(withTarget: self) { [weak view] coordinator in
                guard let view else { return }
                coordinator.registerRestore(view, to: NSAttributedString(attributedString: view.attributedText), selection: view.selectedRange)
                view.attributedText = snapshot
                view.selectedRange = selection
                coordinator.textViewDidChange(view)
                coordinator.refreshStyles(view)
            }
        }

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
            if let underline = attributes[.underlineStyle] as? Int, underline != 0 { active.insert(.underline) }
            if attributes[.textHighlightStyle] != nil { active.insert(.highlight) }
            if attributes[.link] != nil { active.insert(.link) }
            if let item = listItem(containing: view.selectedRange.location, in: view.textStorage) { active.insert(.list(item.kind)) }
            if styles.active != active { styles.active = active }
        }

        func toggle(_ style: EditorStyle, in view: UITextView) {
            let turnOn = !styles.active.contains(style)
            switch style {
            case .list(let kind):
                setList(kind, in: view)
                return
            case .bold: view.toggleBoldface(nil)
            case .italic: view.toggleItalics(nil)
            case .underline:
                change(view) { $0[.underlineStyle] = turnOn ? NSUnderlineStyle.single.rawValue : nil }
            case .highlight:
                change(view) {
                    $0[.textHighlightStyle] = turnOn ? NSAttributedString.TextHighlightStyle.default : nil
                    $0[.textHighlightColorScheme] = turnOn ? NSAttributedString.TextHighlightColorScheme.purple : nil
                }
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
            } else if normal.string != source.string, RichText.listKinds(text).contains(where: { $0 != nil }) {
                // A list pasted from another app takes the list's own markers, and numbers go back in order:
                // the text itself changes, and the cursor keeps its place from the end.
                let fromEnd = view.attributedText.length - view.selectedRange.upperBound
                view.attributedText = shown
                view.selectedRange = NSRange(location: max(0, shown.length - fromEnd), length: 0)
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
            } else if normal.string != source.string, RichText.listKinds(text).contains(where: { $0 != nil }) {
                // A list from Format › List or another app takes Cutling's markers; the cursor keeps its place from the end.
                let fromEnd = storage.length - view.selectedRange().upperBound
                storage.setAttributedString(shown)
                view.setSelectedRange(NSRange(location: max(0, shown.length - fromEnd), length: 0))
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
