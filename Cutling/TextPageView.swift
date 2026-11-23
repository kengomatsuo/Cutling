//
//  TextPageView.swift
//  Cutling
//
//  A cutling's text as its own page, built like a Notes note (docs/research/editor-notes/README.md): pushed from
//  the form's text box, the text filling the screen. With the keyboard up: a Done check at the top and one bar above
//  the keyboard with an Aa button (the Format panel) and the fill-ins. With the keyboard down: no check, and a short
//  bar at the bottom with the fill-ins. What Notes does in each state: docs/research/editor-notes/video/README.md.
//  It edits the form's own value; the form still saves it.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#if os(iOS)
import SwiftUI

struct TextPageView: View {
    @Binding var text: String
    @Binding var format: TextFormat
    /// Characters a reader sees; the form counts them the same way.
    let count: Int
    /// This cutling's room, as the form counts it.
    let limit: Int

    @Environment(\.undoManager) private var undoManager
    /// iPad's width: the tools sit in the top bar and Format is a popover, as in Notes on iPad.
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var styles = EditorStyles()
    @State private var formatPopover = false
    @State private var insertion: String?
    @State private var replacement: PillReplacement?
    @State private var formatOpen = false
    @State private var showsPicker = false
    @State private var editing: PillEditRequest?
    /// The cursor is in the text. Notes shows its check and its keyboard bar by this, not by the keyboard itself,
    /// so a hardware keyboard gets the same page.
    @State private var inText = false

    private func stamp(_ title: String, _ icon: String, _ body: String) -> EditorBarItem {
        EditorBarItem(title: title, icon: icon) { insertion = Placeholders.marked(body) }
    }

    private var blank: EditorBarItem {
        EditorBarItem(title: String(localized: "Ask Each Time"), icon: "character.textbox") { editing = .newBlank() }
    }
    private var today: EditorBarItem { stamp(String(localized: "Today’s Date"), "calendar", "date") }
    /// Every variable, in the searchable picker. The bar's own buttons are the three used most; a menu here only repeated them.
    private var allVariables: EditorBarItem {
        EditorBarItem(title: String(localized: "Variables"), icon: "curlybraces") { showsPicker = true }
    }

    private var wide: Bool { sizeClass == .regular }

    /// Above the keyboard, where Notes has Aa, checklist, table, attachment, markup and more: Aa, then the fill-ins.
    private var keyboardBar: [EditorBarItem] {
        guard format != .code, !wide else { return [] }
        let aa = EditorBarItem(title: String(localized: "Format"), icon: "textformat") { formatOpen = true }
        // Notes' order: Aa, its four inserts, then the styles inline (B I U S, highlight, link), then its list menu.
        // Here the inserts are the variables, and monospace, which Notes keeps in its Format card, sits before the link.
        let inserts = FillIns.isOn ? [blank, today, allVariables, stamp(String(localized: "Clipboard Text"), "doc.on.clipboard", "clipboard")] : []
        let styles: [EditorStyle] = [.bold, .italic, .underline, .strikethrough, .highlight, .monospace, .link]
        return [aa] + inserts + styles.map { EditorBarItem(title: $0.title, icon: $0.icon, style: $0) {} } + [list]
    }

    /// Notes' list button: Bulleted, Dashed and Numbered in a menu above the bar.
    private var list: EditorBarItem {
        EditorBarItem(title: String(localized: "List"), icon: "list.bullet", menu: EditorStyle.lists) {}
    }

    /// iPad's top bar, beside Aa, where Notes on iPad keeps checklist, table and attachment.
    private var restingBar: [EditorBarItem] {
        format != .code && FillIns.isOn ? [blank, allVariables, today] : []
    }

    /// At the bottom left with the keyboard down, where Notes keeps checklist, attachment and markup in one capsule.
    private var restingLeft: [EditorBarItem] {
        format != .code && FillIns.isOn ? [blank, today, stamp(String(localized: "Clipboard Text"), "doc.on.clipboard", "clipboard")] : []
    }

    private var nearLimit: Bool { count > limit - 500 }

    var body: some View {
        FormattedTextEditor(text: $text, format: $format, insertion: $insertion, keyboardBar: keyboardBar,
                            onEditPill: { token, range in
                                if let edit = FillInEdit(token: token) { editing = PillEditRequest(edit: edit, range: range) }
                            },
                            replacement: $replacement, formatPanel: $formatOpen, autofocus: true, fullPage: true,
                            editing: $inText, styles: styles)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .safeAreaInset(edge: .bottom) {
                // Notes shows no count; this one appears only when the limit is close.
                if nearLimit {
                    Text("\(count) / \(limit)")
                        .font(.caption)
                        .foregroundStyle(Color.orange)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                }
            }
            .fillInSheets(picker: $showsPicker, editing: $editing,
                          insert: { insertion = $0 },
                          replace: { replacement = PillReplacement(range: $0, token: $1) })
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Undo shows once there is something to undo, as in Notes; redo beside it once something was undone.
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if undoManager?.canUndo == true {
                        Button { undoManager?.undo() } label: { Image(systemName: "arrow.uturn.backward") }
                            .accessibilityLabel("Undo")
                    }
                    if undoManager?.canRedo == true {
                        Button { undoManager?.redo() } label: { Image(systemName: "arrow.uturn.forward") }
                            .accessibilityLabel("Redo")
                    }
                }
                if wide {
                    if format != .code {
                        // Notes on iPad: one capsule of tools in the middle of the top bar, whatever the keyboard does.
                        ToolbarItem(placement: .principal) {
                            HStack(spacing: 6) {
                                EditorBarButton(item: EditorBarItem(title: String(localized: "Format"), icon: "textformat") { formatPopover = true })
                                    .frame(width: 44, height: 40)
                                    .popover(isPresented: $formatPopover) { FormatPanel(styles: styles) }
                                // Notes on iPad keeps its checklist beside Aa; here the list menu, as at the end of the iPhone's bar.
                                EditorBarMenu(item: list, styles: styles)
                                    .frame(width: 44, height: 40)
                                ForEach(restingBar, id: \.title) { item in
                                    EditorBarButton(item: item)
                                        .frame(width: 44, height: 40)
                                }
                            }
                            .padding(.horizontal, 8)
                            .modifier(EditorBarGlass())
                            .accessibilityElement(children: .contain)
                            .accessibilityIdentifier("textPageTools")
                        }
                    }
                } else if inText {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            formatOpen = false
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        } label: {
                            if #available(iOS 26, *) { Image(systemName: "checkmark") } else { Text("Done") }
                        }
                        .modifier(ProminentWhenGlass())
                        .accessibilityLabel("Done")
                        .accessibilityIdentifier("textPageDone")
                    }
                } else if !restingLeft.isEmpty {
                    // The system's own bottom toolbar, laid out as Notes lays out its own: a glass capsule of three at the
                    // left, and one round button at the right (Notes' is New Note; here it lists every variable).
                    ToolbarItemGroup(placement: .bottomBar) {
                        ForEach(restingLeft, id: \.title) { item in
                            EditorBarButton(item: item)
                                .frame(width: 44, height: 44)
                        }
                    }
                    if #available(iOS 26, *) {
                        ToolbarSpacer(.flexible, placement: .bottomBar)
                    } else {
                        ToolbarItem(placement: .bottomBar) { Spacer() }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        EditorBarButton(item: allVariables)
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .accessibilityIdentifier("textPage")
    }
}

/// The filled check Notes and this app's sheets use on iOS 26; earlier systems keep a plain Done.
private struct ProminentWhenGlass: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) { content.buttonStyle(.borderedProminent).tint(.brandGreen) } else { content }
    }
}
#endif
