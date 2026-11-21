//
//  FillInSheets.swift
//  Cutling
//
//  The two sheets of the text page, drawn after Shortcuts' variables: a searchable picker of fill-in kinds
//  (a row is a symbol, a name and a sample read now) and an editor for one fill-in (a blank's name and
//  choices, a date's format and day), reached from the picker for a new blank and by tapping a pill.
//  Kinds the engine does not know yet are listed with "Soon" and do nothing.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI

/// A fill-in to edit in the sheet: a pill already in the text (`range`), or a new one to type at the cursor (`range` nil).
struct PillEditRequest: Identifiable {
    let id = UUID()
    let edit: FillInEdit
    let range: NSRange?

    static func newBlank() -> PillEditRequest {
        PillEditRequest(edit: .blank(label: String(localized: "Name"), choices: []), range: nil)
    }

    static func newChoice() -> PillEditRequest {
        PillEditRequest(edit: .blank(label: String(localized: "Plan"), choices: [String(localized: "Option 1"), String(localized: "Option 2")]), range: nil)
    }
}

extension View {
    /// The picker and the editor as sheets over this view. `insert` types a token at the cursor;
    /// `replace` rewrites the pill at the request's range.
    func fillInSheets(picker: Binding<Bool>, editing: Binding<PillEditRequest?>,
                      insert: @escaping (String) -> Void, replace: @escaping (NSRange, String) -> Void) -> some View {
        sheet(isPresented: picker) {
            FillInPicker(onInsert: insert)
        }
        .sheet(item: editing) { request in
            NavigationStack {
                FillInEditorForm(initial: request.edit, showsCancel: true) { edit in
                    if let range = request.range { replace(range, edit.token) } else { insert(edit.token) }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Picker

struct FillInPicker: View {
    @Environment(\.dismiss) private var dismiss
    let onInsert: (String) -> Void
    @State private var query = ""
    @State private var pushed: FillInEdit?
    /// Read once when the sheet opens, so samples hold still while it is up.
    @State private var kinds = FillInKind.all()

    private var matches: [FillInKind] {
        let text = query.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return kinds }
        return kinds.filter { $0.name.localizedCaseInsensitiveContains(text) || $0.group.title.localizedCaseInsensitiveContains(text) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(FillInKind.Group.allCases, id: \.self) { group in
                    let rows = matches.filter { $0.group == group }
                    if !rows.isEmpty {
                        Section(group.title) {
                            ForEach(rows) { kind in
                                if kind.isSoon {
                                    row(kind)
                                } else {
                                    Button { choose(kind) } label: { row(kind) }
                                        .foregroundStyle(.primary)
                                        .accessibilityIdentifier("fillInKind-\(kind.id)")
                                }
                            }
                        }
                    }
                }
            }
            .overlay {
                if matches.isEmpty { ContentUnavailableView.search(text: query) }
            }
            .searchable(text: $query, prompt: "Search")
            .navigationTitle("Variables")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        if #available(iOS 26, macOS 26, *) { Image(systemName: "xmark") } else { Text("Cancel") }
                    }
                }
            }
            .navigationDestination(isPresented: Binding(get: { pushed != nil }, set: { if !$0 { pushed = nil } })) {
                if let edit = pushed {
                    FillInEditorForm(initial: edit, showsCancel: false) { saved in
                        onInsert(saved.token)
                        dismiss()
                    }
                }
            }
        }
        .accessibilityIdentifier("fillInPicker")
    }

    private func row(_ kind: FillInKind) -> some View {
        HStack(spacing: 12) {
            Image(systemName: kind.icon)
                .font(.body)
                .foregroundStyle(kind.isSoon ? Color.secondary : Color.accentColor)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(kind.name)
                    .foregroundStyle(kind.isSoon ? .secondary : .primary)
                Text(kind.sample)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            if kind.isSoon {
                Text("Soon")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private func choose(_ kind: FillInKind) {
        switch kind.action {
        case .token(let token)?:
            onInsert(token)
            dismiss()
        case .blank?:
            pushed = .blank(label: String(localized: "Name"), choices: [])
        case .choice?:
            pushed = .blank(label: String(localized: "Plan"), choices: [String(localized: "Option 1"), String(localized: "Option 2")])
        case nil:
            break
        }
    }
}

// MARK: - Editor

/// One fill-in's settings as Shortcuts' variable editor lays them out: a list of what it can be, the current one ticked.
struct FillInEditorForm: View {
    @Environment(\.dismiss) private var dismiss
    let showsCancel: Bool
    let onSave: (FillInEdit) -> Void

    private struct Choice: Identifiable { let id = UUID(); var text: String }

    @State private var label: String
    @State private var choices: [Choice]
    @State private var stamp: Placeholders.Stamp
    private let isBlank: Bool
    /// One moment for every sample, so rows do not tick over while the sheet is open.
    @State private var now = Date()

    init(initial: FillInEdit, showsCancel: Bool, onSave: @escaping (FillInEdit) -> Void) {
        self.showsCancel = showsCancel
        self.onSave = onSave
        switch initial {
        case .blank(let label, let choices):
            isBlank = true
            _label = State(initialValue: label)
            _choices = State(initialValue: choices.map { Choice(text: $0) })
            _stamp = State(initialValue: Placeholders.Stamp(kind: .date))
        case .stamp(let stamp):
            isBlank = false
            _label = State(initialValue: "")
            _choices = State(initialValue: [])
            _stamp = State(initialValue: stamp)
        }
    }

    private var title: LocalizedStringKey {
        isBlank ? (choices.count > 1 ? "Choice" : "Ask Each Time") : "Date and Time"
    }

    private var draft: FillInEdit {
        isBlank ? .blank(label: label, choices: choices.map(\.text)) : .stamp(stamp)
    }

    var body: some View {
        Form {
            if isBlank { blankSections } else { stampSections }
        }
        .navigationTitle(title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            if showsCancel {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        if #available(iOS 26, macOS 26, *) { Image(systemName: "xmark") } else { Text("Cancel") }
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    onSave(draft)
                    if showsCancel { dismiss() }
                } label: {
                    if #available(iOS 26, macOS 26, *) { Image(systemName: "checkmark") } else { Text("Done") }
                }
                .disabled(!draft.isValid)
                .accessibilityIdentifier("fillInEditorDone")
            }
        }
    }

    // MARK: Blank and choice

    @ViewBuilder
    private var blankSections: some View {
        Section("Name") {
            TextField("Name", text: $label)
                .accessibilityIdentifier("fillInName")
        }
        Section {
            ForEach($choices) { $choice in
                HStack {
                    Button { makeDefault(choice) } label: {
                        Image(systemName: "checkmark")
                            .opacity(choices.first?.id == choice.id ? 1 : 0)
                            .frame(width: 24)
                    }
                    .buttonStyle(.borderless)
                    TextField("Choice", text: $choice.text)
                }
            }
            .onDelete { choices.remove(atOffsets: $0) }
            Button {
                choices.append(Choice(text: ""))
            } label: {
                Label("Add Choice", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Choices")
        } footer: {
            Text("The ticked choice is filled in first.")
        }
    }

    private func makeDefault(_ choice: Choice) {
        guard let index = choices.firstIndex(where: { $0.id == choice.id }), index > 0 else { return }
        choices.move(fromOffsets: IndexSet(integer: index), toOffset: 0)
    }

    // MARK: Date and time

    private func sample(_ stamp: Placeholders.Stamp) -> String {
        let context = Placeholders.Context(values: nil, now: now, locale: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, clipboard: nil)
        return Placeholders.format(stamp, context)
    }

    @ViewBuilder
    private func option(_ title: String, sample: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: "checkmark").opacity(selected ? 1 : 0).frame(width: 24)
                Text(title)
                Spacer()
                Text(sample).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .foregroundStyle(.primary)
    }

    private var kinds: [(String, Placeholders.Stamp.Kind)] {
        [(String(localized: "Date"), .date), (String(localized: "Time"), .time), (String(localized: "Date and Time"), .datetime), (String(localized: "Weekday"), .day)]
    }

    /// The named styles; the ISO row is the pattern a person most often writes by hand.
    private var styles: [(String, Placeholders.Stamp.Style)] {
        var rows: [(String, Placeholders.Stamp.Style)] = [
            (String(localized: "Default"), .standard), (String(localized: "Short"), .short), (String(localized: "Medium"), .medium),
            (String(localized: "Long"), .long), (String(localized: "Full"), .full),
        ]
        switch stamp.kind {
        case .date: rows.append(("ISO 8601", .pattern("yyyy-MM-dd")))
        case .datetime: rows.append(("ISO 8601", .pattern("yyyy-MM-dd HH:mm")))
        case .time: rows.append((String(localized: "24-Hour"), .pattern("HH:mm")))
        case .day: break
        }
        if case .pattern = stamp.style, !rows.contains(where: { $0.1 == stamp.style }) { rows.append((String(localized: "Custom"), stamp.style)) }
        return rows
    }

    /// The stamp as another kind: a time moves by minutes and hours and a date by days, so the other's steps
    /// are dropped, and a hand-written pattern made for one kind falls back to the standard style.
    private func switching(_ stamp: Placeholders.Stamp, to kind: Placeholders.Stamp.Kind) -> Placeholders.Stamp {
        guard kind != stamp.kind else { return stamp }
        var copy = stamp
        copy.kind = kind
        if (kind == .time) != (stamp.kind == .time) { copy.offset = [] }
        if case .pattern = copy.style { copy.style = .standard }
        return copy
    }

    private func changing(_ stamp: Placeholders.Stamp, _ change: (inout Placeholders.Stamp) -> Void) -> Placeholders.Stamp {
        var copy = stamp
        change(&copy)
        return copy
    }

    private func offsets(_ amount: Int, _ unit: Placeholders.Offset.Unit) -> [Placeholders.Offset] { [.init(amount: amount, unit: unit)] }

    /// Where in time, as the editor words it: Today and Tomorrow for dates, Now and In an Hour for a time.
    private var moments: [(String, [Placeholders.Offset])] {
        if stamp.kind == .time {
            return [(String(localized: "Now"), []), (String(localized: "In 15 Minutes"), offsets(15, .minute)), (String(localized: "In 30 Minutes"), offsets(30, .minute)), (String(localized: "In an Hour"), offsets(1, .hour))]
        }
        var rows: [(String, [Placeholders.Offset])] = [
            (String(localized: "Today"), []), (String(localized: "Tomorrow"), offsets(1, .day)), (String(localized: "Yesterday"), offsets(-1, .day)),
            (String(localized: "In 3 Days"), offsets(3, .day)), (String(localized: "In a Week"), offsets(1, .week)), (String(localized: "In a Month"), offsets(1, .month)),
        ]
        if !rows.contains(where: { $0.1 == stamp.offset }) { rows.append((String(localized: "Custom"), stamp.offset)) }
        return rows
    }

    @ViewBuilder
    private var stampSections: some View {
        Section("Show") {
            ForEach(kinds, id: \.1) { title, kind in
                // Each row's sample is what choosing it gives, so a pattern made for a date never shows under Time.
                option(title, sample: sample(switching(stamp, to: kind)), selected: stamp.kind == kind) {
                    stamp = switching(stamp, to: kind)
                }
            }
        }
        if stamp.kind != .day {
            Section("Format") {
                ForEach(styles, id: \.0) { title, style in
                    option(title, sample: sample(changing(stamp) { $0.style = style }), selected: stamp.style == style) { stamp.style = style }
                }
            }
        }
        Section(stamp.kind == .time ? "When" : "Day") {
            ForEach(moments, id: \.0) { title, steps in
                option(title, sample: sample(changing(stamp) { $0.offset = steps }), selected: stamp.offset == steps) { stamp.offset = steps }
            }
        }
    }
}
