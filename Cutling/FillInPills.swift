//
//  FillInPills.swift
//  Cutling
//
//  Fill-ins and date stamps show as pills in the editor, the way Shortcuts shows variables:
//  each `{⁠…}` Cutling inserted (marked with Placeholders.marker) is drawn as one tinted pill the
//  cursor steps over and Delete removes whole. Braces a person types carry no marker and stay
//  text. The stored text is unchanged: pills turn back into their tokens before it is saved.
//  Full account: docs/fill-ins.md
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import Foundation
import SwiftUI
#if os(iOS)
import UIKit
typealias PillFont = UIFont
typealias PillColor = UIColor
typealias PillImage = UIImage
#elseif os(macOS)
import AppKit
typealias PillFont = NSFont
typealias PillColor = NSColor
typealias PillImage = NSImage
#endif

/// The styles of the text a pill sits in, drawn on the pill so a variable shows the formatting it will type with.
struct PillLook: Equatable {
    var font: PillFont
    var underline = false
    var strikethrough = false
    var highlight = false

    init(font: PillFont, underline: Bool = false, strikethrough: Bool = false, highlight: Bool = false) {
        self.font = font
        self.underline = underline
        self.strikethrough = strikethrough
        self.highlight = highlight
    }

    /// The look of the text run `attributes` describe; `fallback` when it has no font.
    init(_ attributes: [NSAttributedString.Key: Any], fallback: PillFont) {
        font = attributes[.font] as? PillFont ?? fallback
        underline = (attributes[.underlineStyle] as? Int ?? 0) != 0
        strikethrough = (attributes[.strikethroughStyle] as? Int ?? 0) != 0
        #if os(iOS)
        highlight = TextHighlight.isOn(attributes)
        #else
        highlight = attributes[.backgroundColor] != nil
        #endif
    }
}

/// One pill in the editor; `token` is the text it stands for.
final class FillInAttachment: NSTextAttachment {
    let token: String
    let look: PillLook

    convenience init(token: String, font: PillFont) {
        self.init(token: token, look: PillLook(font: font))
    }

    init(token: String, look: PillLook) {
        self.token = token
        self.look = look
        super.init(data: nil, ofType: nil)
        let font = look.font
        let title = FillInPills.title(of: token)
        // A date or time pill shows what it will type, so a change in its editor shows in the text; VoiceOver hears its name.
        let (image, size) = FillInPills.image(FillInPills.stampValue(of: token) ?? title, look: look)
        self.image = image
        bounds = CGRect(x: 0, y: font.descender - 1, width: size.width, height: size.height)
        #if os(iOS)
        accessibilityLabel = title
        #endif
    }

    required init?(coder: NSCoder) { nil }
}

enum FillInPills {
    private static let green = PillColor(red: 0, green: 190 / 255, blue: 134 / 255, alpha: 1)
    /// Text dark enough to read on the pill's tint (4.5:1 or more), lighter in dark mode.
    private static func ink(dark: Bool) -> PillColor {
        dark ? PillColor(red: 90 / 255, green: 225 / 255, blue: 170 / 255, alpha: 1)
             : PillColor(red: 0, green: 115 / 255, blue: 80 / 255, alpha: 1)
    }
    private static let tokenPattern = try! NSRegularExpression(pattern: "\\{\u{2060}[^{}\\n\\r]*\\}")

    /// What a pill reads: the blank's label (with ▾ for a choice), or the stamp's name.
    static func title(of token: String) -> String {
        let body = token.dropFirst(2).dropLast().trimmingCharacters(in: .whitespaces)
        let head = body.split(whereSeparator: { $0 == ":" || $0 == " " }).first.map(String.init)?.lowercased() ?? ""
        switch head {
        case "date", "datetime", "day", "time":
            #if MAIN_APP
            // The app's editor names the stamp by kind and day (FillInEdit.swift, not built into the extensions).
            if let stamp = stamp(of: token) { return stamp.name() }
            #endif
            return head == "time" ? String(localized: "Time") : String(localized: "Today’s Date")
        case "cursor": return String(localized: "Cursor Position")
        case "clipboard":
            switch body.lowercased() {
            case "clipboard:link": return String(localized: "Link on Clipboard")
            case "clipboard:email": return String(localized: "Email on Clipboard")
            default: return String(localized: "Clipboard Text")
            }
        case "week": return String(localized: "Week Number")
        case "timezone": return String(localized: "Time Zone")
        case "greeting": return String(localized: "Greeting by Hour")
        case "language": return String(localized: "Language")
        case "country": return String(localized: "Country")
        case "currency": return String(localized: "Currency")
        case "counter":
            let name = body.split(separator: ":", maxSplits: 1).dropFirst().first.map { $0.trimmingCharacters(in: .whitespaces) } ?? ""
            return name.isEmpty ? String(localized: "Counter") : name + " #"
        default:
            let label = body.split(separator: ":", maxSplits: 1).first.map { $0.trimmingCharacters(in: .whitespaces) } ?? body
            return body.contains("|") ? label + " ▾" : label
        }
    }

    static func image(_ title: String, font: PillFont) -> (PillImage, CGSize) {
        image(title, look: PillLook(font: font))
    }

    /// The pill for `title` in the text's own font, underlined, struck through or highlighted as the text around it is.
    static func image(_ title: String, look: PillLook) -> (PillImage, CGSize) {
        let font = look.font
        #if os(iOS)
        let dark = UITraitCollection.current.userInterfaceStyle == .dark
        #else
        let dark = NSApp?.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        #endif
        var attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: ink(dark: dark)]
        if look.underline { attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue }
        if look.strikethrough { attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue }
        // Highlighted text in the editor is purple (Notes' default highlight); a highlighted pill takes the same tint.
        let tint = look.highlight ? PillColor.systemPurple : green
        let textSize = (title as NSString).size(withAttributes: attributes)
        // No margin: a pill sits right against the words beside it; line spacing keeps wrapped lines apart.
        let margin: CGFloat = 0
        // Full line height; the editor's line spacing keeps pills on wrapped lines apart.
        let lineHeight = font.ascender - font.descender
        let size = CGSize(width: ceil(textSize.width) + 12 + 2 * margin, height: ceil(lineHeight) + 2)
        let rect = CGRect(x: margin, y: 0, width: size.width - 2 * margin, height: size.height)
        let textOrigin = CGPoint(x: margin + 6, y: (size.height - textSize.height) / 2)
        #if os(iOS)
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            tint.withAlphaComponent(dark ? 0.22 : 0.15).setFill()
            UIBezierPath(roundedRect: rect, cornerRadius: 6).fill()
            (title as NSString).draw(at: textOrigin, withAttributes: attributes)
        }
        #else
        let image = NSImage(size: size, flipped: true) { _ in
            tint.withAlphaComponent(dark ? 0.22 : 0.15).setFill()
            NSBezierPath(roundedRect: rect, xRadius: 6, yRadius: 6).fill()
            (title as NSString).draw(at: textOrigin, withAttributes: attributes)
            return true
        }
        #endif
        return (image, size)
    }

    /// `text` with every marked token drawn as a pill in the font around it.
    static func pilled(_ text: NSAttributedString, font: PillFont) -> NSAttributedString {
        let matches = tokenPattern.matches(in: text.string, range: NSRange(location: 0, length: (text.string as NSString).length))
        guard !matches.isEmpty else { return text }
        let out = NSMutableAttributedString(attributedString: text)
        for match in matches.reversed() {
            let token = (text.string as NSString).substring(with: match.range)
            var attributes = text.attributes(at: match.range.location, effectiveRange: nil)
            attributes[.attachment] = FillInAttachment(token: token, look: PillLook(attributes, fallback: font))
            out.replaceCharacters(in: match.range, with: NSAttributedString(string: "\u{FFFC}", attributes: attributes))
        }
        return out
    }

    /// Redraws every pill whose text has been styled since it was drawn (bold from the bar, a shortcut, the edit menu or
    /// the Format panel), so the pill shows the style it will type with. Returns whether any pill changed.
    @discardableResult
    static func restyle(_ storage: NSMutableAttributedString, fallback font: PillFont) -> Bool {
        var stale: [(NSRange, FillInAttachment)] = []
        storage.enumerateAttribute(.attachment, in: NSRange(location: 0, length: storage.length)) { value, range, _ in
            guard let pill = value as? FillInAttachment else { return }
            let look = PillLook(storage.attributes(at: range.location, effectiveRange: nil), fallback: font)
            if look != pill.look {
                stale.append((range, FillInAttachment(token: pill.token, look: look)))
            }
        }
        guard !stale.isEmpty else { return false }
        storage.beginEditing()
        for (range, pill) in stale { storage.addAttribute(.attachment, value: pill, range: range) }
        storage.endEditing()
        return true
    }

    /// `text` with every pill turned back into its token, to be read as Markdown or plain text.
    static func expanded(_ text: NSAttributedString) -> NSAttributedString {
        let out = NSMutableAttributedString(attributedString: text)
        var pills: [(NSRange, String)] = []
        text.enumerateAttribute(.attachment, in: NSRange(location: 0, length: text.length)) { value, range, _ in
            if let pill = value as? FillInAttachment { pills.append((range, pill.token)) }
        }
        for (range, token) in pills.reversed() {
            var attributes = text.attributes(at: range.location, effectiveRange: nil)
            attributes[.attachment] = nil
            out.replaceCharacters(in: range, with: NSAttributedString(string: token, attributes: attributes))
        }
        return out
    }

    enum Piece {
        case text(String)
        case token(String)
    }

    /// `text` cut into plain runs and the marked tokens between them.
    static func split(_ text: String) -> [Piece] {
        let ns = text as NSString
        var pieces: [Piece] = []
        var last = 0
        for match in tokenPattern.matches(in: text, range: NSRange(location: 0, length: ns.length)) {
            if match.range.location > last { pieces.append(.text(ns.substring(with: NSRange(location: last, length: match.range.location - last)))) }
            pieces.append(.token(ns.substring(with: match.range)))
            last = match.range.location + match.range.length
        }
        if last < ns.length { pieces.append(.text(ns.substring(from: last))) }
        return pieces
    }

    nonisolated(unsafe) private static let inlineCache = NSCache<NSString, PillImage>()

    /// One token as an inline pill for a SwiftUI preview (cards, lists, the keyboard); the cursor spot shows nothing.
    static func inline(_ token: String, size: CGFloat) -> Text {
        let body = token.dropFirst(2).dropLast().trimmingCharacters(in: .whitespaces).lowercased()
        if body == "cursor" { return Text(verbatim: "") }
        let font = PillFont.systemFont(ofSize: size)
        #if os(iOS)
        let dark = UITraitCollection.current.userInterfaceStyle == .dark
        #else
        let dark = NSApp?.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        #endif
        // A date or time reads as today's value, short enough for a one-line preview; a blank keeps its name.
        let shown = previewValue(of: token) ?? title(of: token)
        let key = "\(token)|\(shown)|\(size)|\(dark)" as NSString
        let image = inlineCache.object(forKey: key) ?? {
            let made = Self.image(shown, font: font).0
            inlineCache.setObject(made, forKey: key)
            return made
        }()
        #if os(iOS)
        // Spoken as what it shows: an image in a Text has no label of its own, so VoiceOver skipped every pill.
        return Text(Image(uiImage: image)).baselineOffset(font.descender - 1).accessibilityLabel(Text(verbatim: shown))
        #else
        return Text(Image(nsImage: image)).baselineOffset(font.descender - 1).accessibilityLabel(Text(verbatim: shown))
        #endif
    }

    /// Today's value of a date or time stamp, as the cutling would type it now; nil for anything else.
    static func previewValue(of token: String) -> String? {
        let body = token.dropFirst(2).dropLast().trimmingCharacters(in: .whitespaces).lowercased()
        let live = ["date", "time", "datetime", "day"].contains(where: { body == $0 || body.hasPrefix($0 + ":") || body.hasPrefix($0 + " ") })
            || ["week", "timezone", "greeting", "language", "country", "currency"].contains(body)
        guard live else { return nil }
        let context = Placeholders.Context(values: nil, now: FillInClock.now, locale: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, clipboard: nil)
        let value = Placeholders(token, marked: true).render(context).text
        return value.isEmpty || value == token ? nil : value
    }

    /// Longest value a pill shows; a longer custom pattern shows the stamp's name, so one pill never outgrows a line.
    private static let longestValue = 40

    /// Today's value of a date or time stamp, for its pill in the editor; nil for any other token or a value too long to show.
    static func stampValue(of token: String) -> String? {
        guard stamp(of: token) != nil, let value = previewValue(of: token), value.count <= longestValue else { return nil }
        return value
    }

    /// The date or time stamp a lone marked token stands for; nil for anything else.
    private static func stamp(of token: String) -> Placeholders.Stamp? {
        let pieces = Placeholders(token, marked: true).pieces
        guard pieces.count == 1, case .stamp(let stamp) = pieces[0] else { return nil }
        return stamp
    }

    /// Whether `text` holds a token not yet drawn as a pill (just inserted or pasted).
    static func hasRawToken(_ text: String) -> Bool {
        tokenPattern.firstMatch(in: text, range: NSRange(location: 0, length: (text as NSString).length)) != nil
    }

    /// Where a cursor at `location` in `text` lands once its tokens become one-character pills.
    static func location(afterPilling text: String, at location: Int) -> Int {
        var shift = 0
        for match in tokenPattern.matches(in: text, range: NSRange(location: 0, length: min(location, (text as NSString).length))) {
            shift += match.range.length - 1
        }
        return location - shift
    }
}

// MARK: - How a cutling's text is drawn

extension FillInPills {
    /// A cutling's text with its styles, at `size`, before its fill-ins become pills.
    static func rendered(_ text: String, format: TextFormat, size: CGFloat) -> NSAttributedString {
        RichText.nsAttributed(format == .rich ? text : RichText.escape(text), size: size, editorColors: true)
    }

    /// Just enough room between lines that pills on wrapped lines almost meet but never touch. Never mutated.
    nonisolated(unsafe) static let lines: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        return style
    }()

    /// What the editor and every preview show: the rendered text with its pills at the text's own size and its lines
    /// 3 pt apart. A list line keeps its hanging indent.
    static func display(_ rendered: NSAttributedString, font: PillFont) -> NSAttributedString {
        let out = NSMutableAttributedString(attributedString: pilled(rendered, font: font))
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

/// The moment a cutling's date and time stamps read. A debug build can be told the day a promo film's post goes out
/// (`promoToday`, yyyy-MM-dd, in the App Group, set by the release film's seed from `-PROMO_TODAY`), so a take recorded
/// earlier types that day; a release build always reads the clock.
enum FillInClock {
    static var now: Date {
        #if DEBUG
        if let day = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.string(forKey: "promoToday") {
            let parts = day.split(separator: "-").compactMap { Int($0) }
            if parts.count == 3, let noon = Calendar.current.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2], hour: 12)) { return noon }
        }
        #endif
        return Date()
    }
}
