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
    private var picker: EditorBarItem {
        EditorBarItem(title: String(localized: "All Variables"), icon: "ellipsis") { showsPicker = true }
    }

    /// The fill-ins as a menu growing from its button, the way Notes' attachment button lists what it can attach.
    private var fillInMenu: EditorBarItem {
        EditorBarItem(title: String(localized: "Add Variable"), icon: "curlybraces", menu: [
            [blank, EditorBarItem(title: String(localized: "Choice"), icon: "filemenu.and.selection") { editing = .newChoice() }],
            [today, stamp(String(localized: "Time"), "clock", "time")],
            // Short enough to show whole between the top bar and the keyboard on a small iPhone.
            [picker],
        ]) {}
    }

    private var wide: Bool { sizeClass == .regular }

    /// Above the keyboard, where Notes has Aa, checklist, table, attachment, markup and more: Aa, then the fill-ins.
    private var keyboardBar: [EditorBarItem] {
        guard format != .code, !wide else { return [] }
        let aa = EditorBarItem(title: String(localized: "Format"), icon: "textformat") { formatOpen = true }
        guard FillIns.isOn else { return [aa] }
        return [aa, blank, today, fillInMenu, stamp(String(localized: "Clipboard Text"), "doc.on.clipboard", "clipboard"),
                stamp(String(localized: "Time"), "clock", "time"), stamp(String(localized: "Cursor Position"), "text.cursor", "cursor")]
    }

    /// iPad's top bar, beside Aa, where Notes on iPad keeps checklist, table and attachment.
    private var restingBar: [EditorBarItem] {
        format != .code && FillIns.isOn ? [blank, fillInMenu, today] : []
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
                            replacement: $replacement, formatPanel: $formatOpen, autofocus: true, editing: $inText, styles: styles)
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
                        EditorBarButton(item: fillInMenu)
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
        if #available(iOS 26, *) { content.buttonStyle(.borderedProminent) } else { content }
    }
}
#endif
