//
//  FillInEdit.swift
//  Cutling
//
//  A fill-in pill read into something a sheet can edit, and written back as its token.
//  Only what Cutling writes itself round-trips: a blank, a choice, and a date or time stamp
//  without a locale. The cursor spot, the clipboard and Raycast's `locale=` have nothing to
//  edit here, so `init?(token:)` answers nil and the pill is left alone.
//  Full account: docs/fill-ins.md
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import Foundation

enum FillInEdit: Equatable {
    /// `choices` empty is a blank, one is its default text, more is a choice (the first is the default).
    case blank(label: String, choices: [String])
    case stamp(Placeholders.Stamp)

    /// Reads one marked token such as `{⁠Plan: Basic | Pro}`; nil when it is not a lone editable fill-in.
    init?(token: String) {
        let pieces = Placeholders(token, marked: true).pieces
        guard pieces.count == 1 else { return nil }
        switch pieces[0] {
        case .field(let field, _):
            self = .blank(label: field.label, choices: field.options)
        case .stamp(let stamp) where stamp.locale == nil:
            self = .stamp(stamp)
        default:
            return nil
        }
    }

    /// Words that read as a stamp or the cursor spot when written as a label.
    private static let reserved: Set<String> = ["date", "time", "datetime", "day", "cursor", "clipboard", "argument"]

    private static func clean(_ text: String) -> String {
        text.filter { !"{}:|\n\r".contains($0) }.trimmingCharacters(in: .whitespaces)
    }

    var isValid: Bool {
        guard case .blank(let label, _) = self else { return true }
        let name = Self.clean(label)
        return !name.isEmpty && !Self.reserved.contains(name.lowercased())
    }

    /// The token as Cutling stores it, marked so it draws as a pill.
    var token: String {
        switch self {
        case .blank(let label, let choices):
            let options = choices.map { Self.clean($0) }.filter { !$0.isEmpty }
            let name = Self.clean(label)
            return Placeholders.marked(options.isEmpty ? name : "\(name): " + options.joined(separator: " | "))
        case .stamp(let stamp):
            var body = stamp.kind.rawValue
            for step in stamp.offset {
                body += " \(step.amount < 0 ? "-" : "+")\(abs(step.amount))\(step.unit.letter)"
            }
            switch stamp.style {
            case .standard: break
            case .short: body += ":short"
            case .medium: body += ":medium"
            case .long: body += ":long"
            case .full: body += ":full"
            case .pattern(let pattern): body += ":" + pattern
            }
            return Placeholders.marked(body)
        }
    }
}

extension Placeholders.Offset.Unit {
    /// The letter the syntax table in docs/fill-ins.md writes (`m` minutes, `M` months).
    var letter: String {
        switch self {
        case .minute: "m"
        case .hour: "h"
        case .day: "d"
        case .week: "w"
        case .month: "M"
        case .year: "y"
        }
    }
}
