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

/// Whether placeholders are replaced at all: on, unless the App Group key `fillInsOff` is set, which only
/// the `-FILLIN_OFF` test seed does, to check that braces are then typed, copied and pasted as written.
enum FillIns {
    static let offKey = "fillInsOff"
    static var isOn: Bool {
        !(UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.bool(forKey: offKey) ?? false)
    }
}

extension Cutling {
    /// The placeholders a cutling carries, or nil. Code is typed byte for byte, so it carries none.
    var placeholders: Placeholders? {
        guard FillIns.isOn, kind == .text, textFormat != .code else { return nil }
        let template = Placeholders(plainValue, marked: true)
        return template.hasTokens ? template : nil
    }

    /// Blanks the user fills before this cutling is typed or pasted.
    var fillInFields: [Placeholders.Field] { placeholders?.fields ?? [] }

    /// A copy whose text is finished: stamps dated, fields filled, the clipboard read in.
    /// Rich cutlings keep their formatting and get their inserted text escaped.
    func filled(_ context: Placeholders.Context) -> (cutling: Cutling, charactersAfterCursor: Int?) {
        guard FillIns.isOn, kind == .text, textFormat != .code else {
            // Without fill-ins the template is typed as written, less Cutling's invisible markers.
            var copy = self
            copy.value = value.replacingOccurrences(of: String(Placeholders.marker), with: "")
            return (copy, nil)
        }
        var copy = self
        copy.format = textFormat
        if textFormat == .rich {
            let template = Placeholders(value, markdown: true, marked: true)
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
        let template = Placeholders(value, marked: true)
        guard template.hasTokens else { return (self, nil) }
        let rendered = template.render(context)
        copy.value = rendered.text
        return (copy, rendered.charactersAfterCursor)
    }
}

extension Placeholders.Context {
    /// Now, in the user's locale, with these field values, (when the cutling asks for it) the clipboard, and each counter's next value.
    static func now(values: [String: String]? = [:], clipboard: String? = nil) -> Self {
        Self(values: values, now: FillInClock.now, locale: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, clipboard: clipboard,
             counters: FillInCounters.next)
    }
}

/// Counters a cutling can type ({counter} or {counter:Invoice}): each use moves every counter the cutling holds on by one.
/// Kept in the App Group so the keyboard, the app and the Mac picker count together; never synced.
enum FillInCounters {
    static let defaultsKey = "fillInCounters"
    private static var defaults: UserDefaults? { UserDefaults(suiteName: "group.com.matsuokengo.Cutling") }

    /// Each counter's next value by name.
    static var next: [String: Int] {
        defaults?.dictionary(forKey: defaultsKey) as? [String: Int] ?? [:]
    }

    /// Call once a cutling has been typed, pasted or copied.
    static func advance(after cutling: Cutling) {
        guard let names = cutling.placeholders?.counters, !names.isEmpty, let defaults else { return }
        var all = next
        for name in names { all[name] = (all[name] ?? 1) + 1 }
        defaults.set(all, forKey: defaultsKey)
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
