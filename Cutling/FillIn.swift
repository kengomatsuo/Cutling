//
//  FillIn.swift
//  Cutling
//
//  Using a cutling that carries placeholders: every path that types, copies
//  or pastes a text cutling takes `filled(_:)`'s copy, so stamps, fields and
//  the cursor behave the same in the keyboard, the app and the Mac picker.
//  Full account: docs/fill-ins.md
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import Foundation

/// Whether placeholders are replaced at all. Off in every shipped build until the redesigned
/// fill-in screens are approved: braces are then typed, copied and pasted as written, as before
/// fill-ins existed. Only the `-FILLIN_TEST` seed turns it on, in the App Group so the keyboard sees it.
enum FillIns {
    static let defaultsKey = "fillInsOn"
    static var isOn: Bool {
        UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.bool(forKey: defaultsKey) ?? false
    }
}

extension Cutling {
    /// The placeholders a cutling carries, or nil. Code is typed byte for byte, so it carries none.
    var placeholders: Placeholders? {
        guard FillIns.isOn, kind == .text, textFormat != .code else { return nil }
        let template = Placeholders(plainValue)
        return template.hasTokens ? template : nil
    }

    /// Blanks the user fills before this cutling is typed or pasted.
    var fillInFields: [Placeholders.Field] { placeholders?.fields ?? [] }

    /// A copy whose text is finished: stamps dated, fields filled, the clipboard read in.
    /// Rich cutlings keep their formatting and get their inserted text escaped.
    func filled(_ context: Placeholders.Context) -> (cutling: Cutling, charactersAfterCursor: Int?) {
        guard FillIns.isOn, kind == .text, textFormat != .code else { return (self, nil) }
        var copy = self
        copy.format = textFormat
        if textFormat == .rich {
            let template = Placeholders(value, markdown: true)
            guard template.hasTokens else { return (self, nil) }
            let rendered = template.render(context, escape: RichText.escape)
            guard let after = rendered.charactersAfterCursor else {
                copy.value = rendered.text
                return (copy, nil)
            }
            // Mark the cursor so it can be found again in the text a reader sees.
            let mark: Character = "\u{E000}"
            var marked = rendered.text
            marked.insert(mark, at: marked.index(marked.endIndex, offsetBy: -after))
            let plain = RichText.plainText(marked)
            let afterInPlain = plain.firstIndex(of: mark).map { plain.distance(from: $0, to: plain.endIndex) - 1 }
            copy.value = rendered.text
            return (copy, afterInPlain)
        }
        let template = Placeholders(value)
        guard template.hasTokens else { return (self, nil) }
        let rendered = template.render(context)
        copy.value = rendered.text
        return (copy, rendered.charactersAfterCursor)
    }
}

extension Placeholders.Context {
    /// Now, in the user's locale, with these field values and (when the cutling asks for it) the clipboard.
    static func now(values: [String: String]? = [:], clipboard: String? = nil) -> Self {
        Self(values: values, now: Date(), locale: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, clipboard: clipboard)
    }
}

/// The last values typed into each fill-in, offered as one-tap choices next time.
/// Kept in the App Group so the keyboard, the app and the Mac picker share them; never synced.
enum FillInMemory {
    static let defaultsKey = "fillInRecentValues"
    static let perField = 5
    static let maxValueLength = 200

    private static var defaults: UserDefaults? { UserDefaults(suiteName: "group.com.matsuokengo.Cutling") }

    /// Recent values for a field, newest first, then its own options.
    static func choices(for field: Placeholders.Field) -> [String] {
        var out: [String] = []
        for value in field.options + recent(for: field) where !value.isEmpty && !out.contains(value) {
            out.append(value)
        }
        return out
    }

    static func recent(for field: Placeholders.Field) -> [String] {
        let all = defaults?.dictionary(forKey: defaultsKey) as? [String: [String]] ?? [:]
        return all[field.key] ?? []
    }

    static func remember(_ values: [String: String]) {
        guard let defaults else { return }
        var all = defaults.dictionary(forKey: defaultsKey) as? [String: [String]] ?? [:]
        for (key, raw) in values {
            let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !value.isEmpty, value.count <= maxValueLength else { continue }
            var list = all[key] ?? []
            list.removeAll { $0 == value }
            list.insert(value, at: 0)
            all[key] = Array(list.prefix(perField))
        }
        defaults.set(all, forKey: defaultsKey)
    }
}
