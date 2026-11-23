//
//  FillInSheets.swift
//  Cutling
//
//  The two sheets of the text page, drawn after Shortcuts' variables: a searchable picker of fill-in kinds
//  (a row is a symbol, a name and a sample read now) and an editor for one fill-in (a blank's name and
//  choices, a date's format and day), reached from the picker for a new blank and by tapping a pill.
//  Only kinds the engine can fill are listed; the rest of FillInKinds.swift waits for its engine.
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
    /// Only kinds Cutling can fill today; the rest of the catalogue (FillInKinds.swift) waits for its engine.
    @State private var kinds = FillInKind.all().filter { !$0.isSoon }

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
            .searchable(text: $query)
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
/// A one-pick list ticks its row at the trailing end, as Settings and SwiftUI's inline Picker do; only a menu ticks the leading edge
/// (docs/research/fill-ins-editor/checkmarks/).
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
    /// Custom stays picked while its pattern or step is edited, even when they match a preset on the way.
    @State private var customFormat: Bool
    @State private var customMoment: Bool
    @State private var pattern: String

    init(initial: FillInEdit, showsCancel: Bool, onSave: @escaping (FillInEdit) -> Void) {
        self.showsCancel = showsCancel
        self.onSave = onSave
        switch initial {
        case .blank(let label, let choices):
            isBlank = true
            _label = State(initialValue: label)
            _choices = State(initialValue: choices.map { Choice(text: $0) })
            _stamp = State(initialValue: Placeholders.Stamp(kind: .date))
            _customFormat = State(initialValue: false)
            _customMoment = State(initialValue: false)
            _pattern = State(initialValue: "")
        case .stamp(let stamp):
            isBlank = false
            _label = State(initialValue: "")
            _choices = State(initialValue: [])
            _stamp = State(initialValue: stamp)
            _customFormat = State(initialValue: Self.format(of: stamp) == .custom)
            _customMoment = State(initialValue: !Self.moments(stamp.kind).contains { $0.offset == stamp.offset })
            if case .pattern(let written) = stamp.style { _pattern = State(initialValue: written) } else { _pattern = State(initialValue: "") }
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
                .accessibilityLabel("Done")
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
                    TextField("Choice", text: $choice.text)
                    // The default's tick at the trailing end, where a list ticks its picked row.
                    Button { makeDefault(choice) } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                            .opacity(choices.first?.id == choice.id ? 1 : 0)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("Fill In First")
                    .accessibilityAddTraits(choices.first?.id == choice.id ? .isSelected : [])
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

    /// The formats people pick (Shortcuts' Format Date offers Short, Medium, Long, ISO 8601 and Custom), plus Medium and Full
    /// only for a stamp that already uses them. Medium is the date's default, so it is not offered twice.
    private enum Format: Hashable { case standard, short, medium, long, full, iso, custom }

    /// The pattern behind ISO 8601 for a date, or 24-Hour for a time; nil for a weekday.
    private static func isoPattern(_ kind: Placeholders.Stamp.Kind) -> String? {
        switch kind {
        case .date: "yyyy-MM-dd"
        case .datetime: "yyyy-MM-dd HH:mm"
        case .time: "HH:mm"
        case .day: nil
        }
    }

    private static func format(of stamp: Placeholders.Stamp) -> Format {
        switch stamp.style {
        case .standard: .standard
        case .short: .short
        case .medium: .medium
        case .long: .long
        case .full: .full
        case .pattern(let written): written == isoPattern(stamp.kind) ? .iso : .custom
        }
    }

    private func style(for format: Format) -> Placeholders.Stamp.Style {
        switch format {
        case .standard: .standard
        case .short: .short
        case .medium: .medium
        case .long: .long
        case .full: .full
        case .iso: .pattern(Self.isoPattern(stamp.kind) ?? "")
        case .custom: .pattern(pattern)
        }
    }

    private var formats: [Format] {
        var rows: [Format] = switch stamp.kind {
        case .date, .datetime: [.standard, .short, .long, .iso]
        case .time: [.standard, .iso]
        case .day: [.standard]
        }
        let current = Self.format(of: stamp)
        if current != .custom, !rows.contains(current) { rows.append(current) }
        return rows + [.custom]
    }

    private func formatTitle(_ format: Format) -> String {
        switch format {
        case .standard: String(localized: "Default")
        case .short: String(localized: "Short")
        case .medium: String(localized: "Medium")
        case .long: String(localized: "Long")
        case .full: String(localized: "Full")
        case .iso: stamp.kind == .time ? String(localized: "24-Hour") : "ISO 8601"
        case .custom: String(localized: "Custom")
        }
    }

    private var formatChoice: Binding<Format> {
        Binding {
            customFormat ? .custom : Self.format(of: stamp)
        } set: { choice in
            customFormat = choice == .custom
            guard choice == .custom else { stamp.style = style(for: choice); return }
            // Custom starts from the pattern of what the stamp types now, so it is edited, not written from nothing.
            let start = pattern.isEmpty ? currentPattern() : pattern
            pattern = start
            stamp.style = .pattern(start)
        }
    }

    private var patternText: Binding<String> {
        Binding { pattern } set: { written in
            pattern = written
            stamp.style = .pattern(written)
        }
    }

    /// The Unicode pattern the stamp types with now, in the person's locale.
    private func currentPattern() -> String {
        if case .pattern(let written) = stamp.style { return written }
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        let style: DateFormatter.Style = switch stamp.style {
        case .short: .short
        case .long: .long
        case .full: .full
        default: .medium
        }
        switch stamp.kind {
        case .date: formatter.dateStyle = style
        case .time: formatter.timeStyle = stamp.style == .standard ? .short : style
        case .datetime:
            formatter.dateStyle = style
            formatter.timeStyle = stamp.style == .standard ? .short : style
        case .day: formatter.setLocalizedDateFormatFromTemplate("EEEE")
        }
        return formatter.dateFormat
    }

    /// Patterns to start from, each typed into the field by a tap.
    private var examples: [String] {
        stamp.kind == .time ? ["h:mm a", "HH:mm:ss", "h a"] : ["EEEE, d MMMM", "dd/MM/yyyy", "MMMM yyyy", "EEE d MMM, HH:mm"]
    }

    private func sample(_ stamp: Placeholders.Stamp) -> String {
        let context = Placeholders.Context(values: nil, now: now, locale: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, clipboard: nil)
        return Placeholders.format(stamp, context)
    }

    /// A row of a one-pick list: what it is, and below it what it types now. The Picker ticks the picked row at its trailing end.
    private func optionLabel(_ title: String, sample: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
            if let sample {
                Text(sample)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private var kinds: [(String, Placeholders.Stamp.Kind)] {
        [(String(localized: "Date"), .date), (String(localized: "Time"), .time), (String(localized: "Date and Time"), .datetime), (String(localized: "Weekday"), .day)]
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

    private var kindChoice: Binding<Placeholders.Stamp.Kind> {
        Binding { stamp.kind } set: { kind in
            guard kind != stamp.kind else { return }
            let crossesTime = (kind == .time) != (stamp.kind == .time)
            stamp = switching(stamp, to: kind)
            customFormat = false
            if crossesTime { customMoment = false }
        }
    }

    // MARK: Day

    private struct Moment { let id: String; let title: String; let offset: [Placeholders.Offset] }

    /// Where in time, as the editor words it: Today and Tomorrow for dates, Now and In an Hour for a time; Custom does the rest.
    private static func moments(_ kind: Placeholders.Stamp.Kind) -> [Moment] {
        func step(_ amount: Int, _ unit: Placeholders.Offset.Unit) -> [Placeholders.Offset] { [.init(amount: amount, unit: unit)] }
        if kind == .time {
            return [Moment(id: "now", title: String(localized: "Now"), offset: []),
                    Moment(id: "30m", title: String(localized: "In 30 Minutes"), offset: step(30, .minute)),
                    Moment(id: "1h", title: String(localized: "In an Hour"), offset: step(1, .hour))]
        }
        return [Moment(id: "today", title: String(localized: "Today"), offset: []),
                Moment(id: "tomorrow", title: String(localized: "Tomorrow"), offset: step(1, .day)),
                Moment(id: "yesterday", title: String(localized: "Yesterday"), offset: step(-1, .day)),
                Moment(id: "week", title: String(localized: "In a Week"), offset: step(1, .week))]
    }

    private static let customID = "custom"

    private var momentChoice: Binding<String> {
        Binding {
            customMoment ? Self.customID : (Self.moments(stamp.kind).first { $0.offset == stamp.offset }?.id ?? Self.customID)
        } set: { id in
            customMoment = id == Self.customID
            if let preset = Self.moments(stamp.kind).first(where: { $0.id == id }) {
                stamp.offset = preset.offset
            } else if stamp.offset.isEmpty {
                // Custom starts a few steps on, so the stepper has something to move from.
                stamp.offset = stamp.kind == .time ? [.init(amount: 15, unit: .minute)] : [.init(amount: 3, unit: .day)]
            }
        }
    }

    private var units: [Placeholders.Offset.Unit] { stamp.kind == .time ? [.minute, .hour] : [.day, .week, .month, .year] }

    private func unitTitle(_ unit: Placeholders.Offset.Unit) -> String {
        switch unit {
        case .minute: String(localized: "Minutes")
        case .hour: String(localized: "Hours")
        case .day: String(localized: "Days")
        case .week: String(localized: "Weeks")
        case .month: String(localized: "Months")
        case .year: String(localized: "Years")
        }
    }

    /// The custom step, read from the stamp's first step; a stamp written with several steps becomes one when edited here.
    private var stepAmount: Binding<Int> {
        Binding { stamp.offset.first?.amount ?? 0 } set: { amount in
            stamp.offset = [.init(amount: amount, unit: stamp.offset.first?.unit ?? units[0])]
        }
    }

    private var stepUnit: Binding<Placeholders.Offset.Unit> {
        Binding { stamp.offset.first.map(\.unit).flatMap { units.contains($0) ? $0 : nil } ?? units[0] } set: { unit in
            stamp.offset = [.init(amount: stamp.offset.first?.amount ?? 1, unit: unit)]
        }
    }

    @ViewBuilder
    private var stampSections: some View {
        Section("Show") {
            // Each row's sample is what choosing it gives, so a pattern made for a date never shows under Time.
            Picker("Show", selection: kindChoice) {
                ForEach(kinds, id: \.1) { title, kind in
                    optionLabel(title, sample: sample(switching(stamp, to: kind))).tag(kind)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        Section {
            Picker("Format", selection: formatChoice) {
                ForEach(formats, id: \.self) { format in
                    // Custom shows its sample once picked; until then it would repeat the picked row's.
                    optionLabel(formatTitle(format), sample: format == .custom && formatChoice.wrappedValue != .custom ? nil : sample(changing(stamp) { $0.style = style(for: format) }))
                        .tag(format)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
            if formatChoice.wrappedValue == .custom {
                TextField("Pattern", text: patternText)
                    .font(.body.monospaced())
                    .autocorrectionDisabled()
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .accessibilityIdentifier("fillInDatePattern")
            }
        } header: {
            Text("Format")
        } footer: {
            if formatChoice.wrappedValue == .custom {
                Text("y year, M month, d day, E weekday, H or h hour, m minute, a AM or PM. Words in 'single quotes' are typed as written.")
            }
        }
        if formatChoice.wrappedValue == .custom {
            Section("Examples") {
                ForEach(examples, id: \.self) { example in
                    Button { patternText.wrappedValue = example } label: {
                        LabeledContent {
                            Text(sample(changing(stamp) { $0.style = .pattern(example) }))
                        } label: {
                            Text(verbatim: example).font(.body.monospaced())
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
        Section(stamp.kind == .time ? "When" : "Day") {
            Picker(stamp.kind == .time ? "When" : "Day", selection: momentChoice) {
                ForEach(Self.moments(stamp.kind), id: \.id) { moment in
                    optionLabel(moment.title, sample: sample(changing(stamp) { $0.offset = moment.offset })).tag(moment.id)
                }
                optionLabel(String(localized: "Custom"), sample: momentChoice.wrappedValue == Self.customID ? sample(stamp) : nil)
                    .tag(Self.customID)
            }
            .pickerStyle(.inline)
            .labelsHidden()
            if momentChoice.wrappedValue == Self.customID {
                Stepper(value: stepAmount, in: -999...999) {
                    Text(Placeholders.Stamp.moment(stamp.offset) ?? "")
                }
                .accessibilityIdentifier("fillInDateStep")
                Picker("Unit", selection: stepUnit) {
                    ForEach(units, id: \.self) { unit in Text(unitTitle(unit)).tag(unit) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
        }
    }
}
