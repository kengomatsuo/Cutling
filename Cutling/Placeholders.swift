//
//  Placeholders.swift
//  Cutling
//
//  Fill-in fields, date stamps, the cursor spot and the clipboard inside a
//  text cutling, written in braces as Raycast and Alfred write theirs:
//  {date}, {time}, {date +3d}, {date:yyyy-MM-dd}, {cursor}, {clipboard},
//  {Name} (a fill-in), {Plan: Basic | Pro} (a fill-in with choices).
//  Foundation only, so the keyboard, the Mac app and the tests share it.
//  Full account: docs/fill-ins.md
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import Foundation

struct Placeholders: Sendable {

    /// A blank the user fills when the cutling is used. Fields with the same
    /// label (ignoring case) share one value, as TextExpander's do.
    struct Field: Hashable, Codable, Sendable {
        let label: String
        /// The first is the default; more than one makes it a choice.
        let options: [String]
        var key: String { Self.key(label) }
        static func key(_ label: String) -> String { label.lowercased() }
    }

    struct Stamp: Equatable, Sendable {
        enum Kind: String, Sendable { case date, time, datetime, day }
        enum Style: Equatable, Sendable { case standard, short, medium, long, full, pattern(String) }
        var kind: Kind
        var offset: [Offset] = []
        var style: Style = .standard
        /// A BCP 47 tag from Raycast's `locale=`; nil follows the user's.
        var locale: String? = nil
    }

    struct Offset: Equatable, Sendable {
        let amount: Int
        let unit: Unit
        /// Raycast's letters, case-sensitive like theirs (`m` minutes, `M` months), plus `w`, `min` and `mo`.
        enum Unit: CaseIterable, Sendable {
            case minute, hour, day, week, month, year
            init?(_ text: Substring) {
                switch text {
                case "m", "min", "mins": self = .minute
                case "h", "H": self = .hour
                case "d", "D": self = .day
                case "w", "W": self = .week
                case "M", "mo": self = .month
                case "y", "Y": self = .year
                default: return nil
                }
            }
            var component: Calendar.Component {
                switch self {
                case .minute: .minute
                case .hour: .hour
                case .day: .day
                case .week: .weekOfYear
                case .month: .month
                case .year: .year
                }
            }
        }
    }

    enum Piece: Sendable {
        case text(String)
        case field(Field, source: String)
        case stamp(Stamp)
        case cursor
        case clipboard
    }

    /// What a cutling becomes, split at its fields, with stamps and the clipboard resolved.
    enum Chunk: Equatable, Codable, Sendable {
        case text(String)
        case field(Field)
        case cursor
    }

    struct Context {
        /// Field values by `Field.key`. nil leaves every field as written.
        var values: [String: String]? = [:]
        var now = Date()
        var locale = Locale.autoupdatingCurrent
        var timeZone = TimeZone.autoupdatingCurrent
        /// nil leaves `{clipboard}` as written.
        var clipboard: String? = nil
    }

    let pieces: [Piece]

    /// The invisible character (WORD JOINER) after the opening brace of a fill-in Cutling inserted, `{⁠Name}`.
    /// With `marked`, only such braces are fill-ins, so braces a person types (LaTeX, "Hello {name}") stay text.
    static let marker: Character = "\u{2060}"

    /// A fill-in or stamp as Cutling stores it: `{`, the marker, the body, `}`.
    static func marked(_ body: String) -> String { "{\(marker)\(body)}" }

    /// Parses `source`. `markdown` keeps backslash escapes for the Markdown
    /// parser and reads labels through them; plain text turns `\{` into `{`.
    /// `marked` reads only braces that carry `marker` (Cutling's own storage); without it every brace counts,
    /// as Raycast and Alfred write theirs.
    init(_ source: String, markdown: Bool = false, marked: Bool = false) {
        pieces = Self.parse(source, markdown: markdown, marked: marked)
    }

    // MARK: Questions

    var hasTokens: Bool {
        pieces.contains { if case .text = $0 { false } else { true } }
    }

    /// Unique fields in the order they first appear.
    var fields: [Field] {
        var seen = Set<String>()
        var out: [Field] = []
        for case .field(let field, _) in pieces where seen.insert(field.key).inserted {
            out.append(field)
        }
        return out
    }

    var usesClipboard: Bool {
        pieces.contains { if case .clipboard = $0 { true } else { false } }
    }

    // MARK: Rendering

    /// The finished text and how many characters sit after `{cursor}` (nil without one).
    /// `escape` is applied to everything the tokens produce (Markdown escaping for Formatted cutlings).
    func render(_ context: Context, escape: (String) -> String = { $0 }) -> (text: String, charactersAfterCursor: Int?) {
        var text = ""
        var cursorMark: Int?
        for piece in pieces {
            switch piece {
            case .text(let literal):
                text += literal
            case .field(let field, let source):
                if let values = context.values {
                    text += escape(values[field.key] ?? field.options.first ?? "")
                } else {
                    text += source
                }
            case .stamp(let stamp):
                text += escape(Self.format(stamp, context))
            case .cursor:
                if cursorMark == nil { cursorMark = text.count }
            case .clipboard:
                text += context.clipboard.map(escape) ?? "{clipboard}"
            }
        }
        return (text, cursorMark.map { text.count - $0 })
    }

    /// The cutling split at its fields, for the keyboard to type piece by piece.
    func chunks(_ context: Context) -> [Chunk] {
        var out: [Chunk] = []
        func append(_ string: String) {
            guard !string.isEmpty else { return }
            if case .text(let previous)? = out.last {
                out[out.count - 1] = .text(previous + string)
            } else {
                out.append(.text(string))
            }
        }
        var seenCursor = false
        for piece in pieces {
            switch piece {
            case .text(let literal): append(literal)
            case .field(let field, _): out.append(.field(field))
            case .stamp(let stamp): append(Self.format(stamp, context))
            case .cursor:
                if !seenCursor { out.append(.cursor); seenCursor = true }
            case .clipboard: append(context.clipboard ?? "")
            }
        }
        return out
    }

    // MARK: Dates

    static func format(_ stamp: Stamp, _ context: Context) -> String {
        var calendar = context.locale.calendar
        calendar.timeZone = context.timeZone
        var date = context.now
        for step in stamp.offset {
            date = calendar.date(byAdding: step.unit.component, value: step.amount, to: date) ?? date
        }
        let formatter = DateFormatter()
        formatter.locale = stamp.locale.map { Locale(identifier: $0) } ?? context.locale
        formatter.timeZone = context.timeZone
        formatter.calendar = calendar
        func style(_ s: Stamp.Style, fallback: DateFormatter.Style) -> DateFormatter.Style {
            switch s {
            case .short: .short
            case .medium: .medium
            case .long: .long
            case .full: .full
            case .standard, .pattern: fallback
            }
        }
        if case .pattern(let pattern) = stamp.style {
            // A written pattern means fixed digits and the Gregorian year, as ISO dates expect.
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.calendar.timeZone = context.timeZone
            formatter.dateFormat = pattern
            return formatter.string(from: date)
        }
        switch stamp.kind {
        case .date:
            formatter.dateStyle = style(stamp.style, fallback: .medium)
            formatter.timeStyle = .none
        case .time:
            formatter.dateStyle = .none
            formatter.timeStyle = style(stamp.style, fallback: .short)
        case .datetime:
            formatter.dateStyle = style(stamp.style, fallback: .medium)
            formatter.timeStyle = style(stamp.style == .standard ? .short : stamp.style, fallback: .short)
        case .day:
            formatter.setLocalizedDateFormatFromTemplate("EEEE")
        }
        return formatter.string(from: date)
    }

    // MARK: Parsing

    /// Longest token body read; longer braces are text.
    static let maxTokenLength = 120
    static let maxLabelLength = 40

    private static func parse(_ source: String, markdown: Bool, marked: Bool) -> [Piece] {
        var pieces: [Piece] = []
        var literal = ""
        func flush() {
            if !literal.isEmpty { pieces.append(.text(literal)); literal = "" }
        }
        var i = source.startIndex
        while i < source.endIndex {
            let ch = source[i]
            if ch == "\\", let next = source.index(i, offsetBy: 1, limitedBy: source.endIndex), next < source.endIndex,
               source[next] == "{" || source[next] == "}" {
                // An escaped brace is never a token.
                if markdown { literal += "\\" }
                literal.append(source[next])
                i = source.index(after: next)
                continue
            }
            if ch == "{", let close = closingBrace(in: source, from: i),
               let bodyStart = Self.bodyStart(in: source, brace: i, close: close, marked: marked),
               let piece = token(String(source[bodyStart..<close]), markdown: markdown) {
                flush()
                if case .field = piece {
                    pieces.append(.field(fieldOf(piece), source: String(source[i...close])))
                } else {
                    pieces.append(piece)
                }
                i = source.index(after: close)
                continue
            }
            literal.append(ch)
            i = source.index(after: i)
        }
        flush()
        return pieces
    }

    /// Where a token's body begins: after the brace, and after the marker when only marked braces count.
    private static func bodyStart(in source: String, brace: String.Index, close: String.Index, marked: Bool) -> String.Index? {
        let start = source.index(after: brace)
        guard marked else { return start }
        guard start < close, source[start] == marker else { return nil }
        return source.index(after: start)
    }

    private static func fieldOf(_ piece: Piece) -> Field {
        if case .field(let field, _) = piece { return field }
        preconditionFailure("not a field")
    }

    /// The `}` that closes the brace at `open`, on the same line, with no brace between.
    private static func closingBrace(in source: String, from open: String.Index) -> String.Index? {
        var j = source.index(after: open)
        var length = 0
        while j < source.endIndex, length <= maxTokenLength {
            let c = source[j]
            if c == "}" { return j }
            if c == "{" || c == "\n" || c == "\r" { return nil }
            j = source.index(after: j)
            length += 1
        }
        return nil
    }

    /// Reads a brace body, or nil when it is ordinary text such as code or JSON.
    private static func token(_ rawBody: String, markdown: Bool) -> Piece? {
        let body = (markdown ? unescapeMarkdown(rawBody) : rawBody).trimmingCharacters(in: .whitespaces)
        guard !body.isEmpty else { return nil }
        let lower = body.lowercased()
        switch lower {
        case "cursor": return .cursor
        case "clipboard": return .clipboard
        default: break
        }
        if let stamp = stamp(body) { return .stamp(stamp) }
        if let piece = raycastToken(body) { return piece }
        // A blank touches both braces, as people write `{Name}`; code spaces them: `{ return x }`.
        guard rawBody.first?.isWhitespace == false, rawBody.last?.isWhitespace == false else { return nil }
        return field(body).map { .field($0, source: "") }
    }

    /// `date`, `time`, `datetime` or `day`, then offsets such as `+3d -1w`, then `:style` or `:pattern`.
    private static func stamp(_ body: String) -> Stamp? {
        var head = body
        var styleText: String?
        if let colon = body.firstIndex(of: ":") {
            head = String(body[..<colon])
            styleText = String(body[body.index(after: colon)...]).trimmingCharacters(in: .whitespaces)
        }
        var scanner = Substring(head.trimmingCharacters(in: .whitespaces))
        let name = scanner.prefix { $0.isLetter }
        guard let kind = Stamp.Kind(rawValue: name.lowercased()) else { return nil }
        scanner = scanner.dropFirst(name.count)
        guard let offsets = offsets(scanner) else { return nil }
        var stamp = Stamp(kind: kind, offset: offsets)
        if let styleText {
            guard !styleText.isEmpty else { return nil }
            stamp.style = style(styleText)
        }
        return stamp
    }

    private static func style(_ text: String) -> Stamp.Style {
        switch text.lowercased() {
        case "short": .short
        case "medium": .medium
        case "long": .long
        case "full": .full
        default: .pattern(text)
        }
    }

    /// Parses `+3d -1w +2h` (spaces optional); nil when anything else is there.
    private static func offsets<S: StringProtocol>(_ text: S) -> [Offset]? {
        var out: [Offset] = []
        var rest = Substring(text)
        while true {
            rest = rest.drop { $0 == " " }
            guard let sign = rest.first else { return out }
            guard sign == "+" || sign == "-" else { return nil }
            rest = rest.dropFirst().drop { $0 == " " }
            let digits = rest.prefix { $0.isASCII && $0.isNumber }
            guard !digits.isEmpty, let amount = Int(digits) else { return nil }
            rest = rest.dropFirst(digits.count)
            let unitText = rest.prefix { $0.isLetter }
            guard let unit = Offset.Unit(unitText) else { return nil }
            rest = rest.dropFirst(unitText.count)
            out.append(Offset(amount: sign == "-" ? -amount : amount, unit: unit))
        }
    }

    /// Raycast's own forms, so pasted Raycast snippets work:
    /// `{argument name="Name" default="x" options="a, b"}` and `{date format="yyyy-MM-dd" offset="+3d"}`.
    private static func raycastToken(_ body: String) -> Piece? {
        let lower = body.lowercased()
        let isArgument = lower.hasPrefix("argument")
        let stampKind = Stamp.Kind.allCasesForRaycast.first { lower.hasPrefix($0.rawValue + " ") }
        guard isArgument || stampKind != nil else { return nil }
        let head = isArgument ? "argument" : stampKind!.rawValue
        let attributes = attributes(String(body.dropFirst(head.count)))
        guard let attributes else { return nil }
        if isArgument {
            let label = attributes["name"] ?? "Text"
            var options = attributes["options"].map { $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty } } ?? []
            if let fallback = attributes["default"] {
                options.removeAll { $0 == fallback }
                options.insert(fallback, at: 0)
            }
            return .field(Field(label: label, options: options), source: "")
        }
        guard let stampKind else { return nil }
        var stamp = Stamp(kind: stampKind)
        if let offset = attributes["offset"] {
            guard let parsed = offsets(offset) else { return nil }
            stamp.offset = parsed
        }
        if let format = attributes["format"], !format.isEmpty { stamp.style = style(format) }
        if let locale = attributes["locale"], !locale.isEmpty { stamp.locale = locale }
        return .stamp(stamp)
    }

    /// `key="value"` pairs; nil when the text is anything else.
    private static func attributes(_ text: String) -> [String: String]? {
        var out: [String: String] = [:]
        var rest = Substring(text)
        while true {
            rest = rest.drop { $0 == " " }
            if rest.isEmpty { return out }
            let key = rest.prefix { $0.isLetter }
            guard !key.isEmpty else { return nil }
            rest = rest.dropFirst(key.count).drop { $0 == " " }
            guard rest.first == "=" else { return nil }
            rest = rest.dropFirst().drop { $0 == " " }
            guard let quote = rest.first, quote == "\"" || quote == "“" || quote == "”" else { return nil }
            rest = rest.dropFirst()
            guard let end = rest.firstIndex(where: { $0 == "\"" || $0 == "”" || $0 == "“" }) else { return nil }
            out[key.lowercased()] = String(rest[..<end])
            rest = rest[rest.index(after: end)...]
        }
    }

    /// `Label` or `Label: default` or `Label: one | two | three`.
    private static func field(_ body: String) -> Field? {
        var label = body
        var options: [String] = []
        if let colon = body.firstIndex(of: ":") {
            label = String(body[..<colon]).trimmingCharacters(in: .whitespaces)
            options = body[body.index(after: colon)...]
                .split(separator: "|", omittingEmptySubsequences: false)
                .map { $0.trimmingCharacters(in: .whitespaces) }
            if options.allSatisfy(\.isEmpty) { options = [] }
        }
        guard isLabel(label) else { return nil }
        return Field(label: label, options: options)
    }

    /// Words a person would write for a blank, never code: `{Name}`, `{Order #}`, `{名前}`.
    static func isLabel(_ label: String) -> Bool {
        guard (1...maxLabelLength).contains(label.count),
              let first = label.unicodeScalars.first,
              CharacterSet.alphanumerics.contains(first)
        else { return false }
        let allowed = CharacterSet.alphanumerics
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "-_.'’#/&()?!,"))
            .union(.nonBaseCharacters)
        return label.unicodeScalars.allSatisfy { allowed.contains($0) }
    }

    /// `\_` -> `_`: Formatted cutlings store Markdown, which escapes punctuation.
    private static func unescapeMarkdown(_ text: String) -> String {
        var out = ""
        var escaping = false
        for ch in text {
            if escaping { out.append(ch); escaping = false; continue }
            if ch == "\\" { escaping = true; continue }
            out.append(ch)
        }
        if escaping { out.append("\\") }
        return out
    }
}

private extension Placeholders.Stamp.Kind {
    static let allCasesForRaycast: [Self] = [.datetime, .date, .time, .day]
}
