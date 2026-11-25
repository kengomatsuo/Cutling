//
//  RichText.swift
//  Cutling
//
//  Text cutling formats. Rich cutlings store an inline Markdown subset (bold, italic,
//  strikethrough, inline code, links, and Apple's `^[text](underline: true)` and
//  `^[text](highlight: true)`) in `value`, with lists as their plain markers at the
//  start of a line ("• ", "- ", "1. ").
//  Full account: docs/formatting-plan.md
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import Foundation
import UniformTypeIdentifiers
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum TextFormat: String, Codable, CaseIterable, Sendable {
    case plain, rich, code

    /// Suggests Code for text that looks like source.
    static func suggested(for text: String) -> TextFormat {
        looksLikeCode(text) ? .code : .plain
    }

    static func looksLikeCode(_ text: String) -> Bool {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
        guard !lines.isEmpty else { return false }
        let codeLines = lines.filter { line in
            line.hasSuffix(";") || line.hasSuffix("{") || line.hasSuffix("}")
                || line.contains("=>") || line.contains("->")
                || line.hasPrefix("    ") || line.hasPrefix("\t")
                || line.range(of: #"^\s*(func|def|class|let|const|var|import|return|if|for|while|public|private|#include|SELECT|select)\b"#, options: .regularExpression) != nil
        }
        // A single short line needs a strong signal; longer text needs most lines.
        if lines.count == 1 { return text.contains("=>") || text.hasSuffix(";") || text.contains("();") }
        return Double(codeLines.count) / Double(lines.count) >= 0.5
    }
}

/// A paragraph a formatted cutling keeps as a list, as Notes offers them: Bulleted, Dashed, Numbered.
/// The marker is stored at the start of the line and is what a plain-text host shows, so a list reads
/// the same with its formatting gone, and an older Cutling shows it as the same text.
nonisolated enum ListKind: String, CaseIterable, Codable, Hashable, Sendable {
    case bulleted, dashed, numbered

    func marker(_ number: Int = 1) -> String {
        switch self {
        case .bulleted: "• "
        case .dashed: "- "
        case .numbered: "\(number). "
        }
    }

    /// The list a line starts with, and its marker's length in UTF-16 units.
    static func leading<S: StringProtocol>(_ line: S) -> (kind: ListKind, length: Int)? {
        if line.hasPrefix("• ") { return (.bulleted, 2) }
        if line.hasPrefix("- ") { return (.dashed, 2) }
        let digits = line.prefix { $0.isASCII && $0.isNumber }
        guard (1...3).contains(digits.count), line.dropFirst(digits.count).hasPrefix(". ") else { return nil }
        return (.numbered, digits.count + 2)
    }

    #if canImport(UIKit) || canImport(AppKit)
    /// The list Apple's text system draws for this kind (TextEdit, Notes, Pages and Mail read and write it).
    var textListFormat: NSTextList.MarkerFormat {
        switch self {
        case .bulleted: .disc
        case .dashed: .hyphen
        case .numbered: .decimal
        }
    }

    init(_ list: NSTextList) {
        if list.isOrdered { self = .numbered } else { self = list.markerFormat == .hyphen ? .dashed : .bulleted }
    }
    #endif
}

/// Underline, stored with Apple's own Markdown attribute syntax, `^[text](underline: true)`, which
/// `AttributedString(markdown:)` reads; a reader that doesn't know the attribute shows the text plain.
nonisolated enum CutlingUnderlineAttribute: CodableAttributedStringKey, MarkdownDecodableAttributedStringKey {
    typealias Value = Bool
    static let name = "CutlingUnderline"
    static let markdownName = "underline"
}

/// Highlight, stored as `^[text](highlight: true)`; drawn as Notes draws its own (NSTextHighlightStyle, purple).
nonisolated enum CutlingHighlightAttribute: CodableAttributedStringKey, MarkdownDecodableAttributedStringKey {
    typealias Value = Bool
    static let name = "CutlingHighlight"
    static let markdownName = "highlight"
}

extension AttributeScopes {
    nonisolated struct CutlingAttributes: AttributeScope {
        let underline: CutlingUnderlineAttribute
        let highlight: CutlingHighlightAttribute
        let foundation: FoundationAttributes
    }
}

extension NSAttributedString.Key {
    /// On the marker characters of a list line in the editor: the list's kind. A line that only looks
    /// like a list ("- " typed by hand) has none and stays text.
    nonisolated static let cutlingListMarker = NSAttributedString.Key("CutlingListMarker")
}

enum RichText {
    nonisolated static let maxStoredLength = 1500

    private nonisolated static let options = AttributedString.MarkdownParsingOptions(
        interpretedSyntax: .inlineOnlyPreservingWhitespace,
        failurePolicy: .returnPartiallyParsedIfPossible
    )

    /// Rendered rich text, underline and highlight included; falls back to the raw string.
    nonisolated static func attributed(_ markdown: String) -> AttributedString {
        (try? AttributedString(markdown: markdown, including: AttributeScopes.CutlingAttributes.self, options: options))
            ?? AttributedString(markdown)
    }

    /// The text a reader sees, markers removed. A list keeps its "• ", "- " or "1. ".
    nonisolated static func plainText(_ markdown: String) -> String {
        String(attributed(markdown).characters)
    }

    /// The list each line of stored text belongs to. A line whose marker is escaped is text.
    nonisolated static func listKinds(_ markdown: String) -> [ListKind?] {
        markdown.split(separator: "\n", omittingEmptySubsequences: false).map { ListKind.leading($0)?.kind }
    }

    /// Escapes plain text so Markdown shows it literally, and so a line that starts like a list stays text.
    nonisolated static func escape(_ plain: String) -> String {
        plain.split(separator: "\n", omittingEmptySubsequences: false)
            .map { escapeLineStart(escapeInline($0)) }
            .joined(separator: "\n")
    }

    private nonisolated static func escapeInline<S: StringProtocol>(_ plain: S) -> String {
        var out = ""
        out.reserveCapacity(plain.count)
        for ch in plain {
            if "\\`*_~[]<>&".contains(ch) { out.append("\\") }
            out.append(ch)
        }
        return out
    }

    /// A line of Markdown that would read as a list item, written so it reads as text: `\- `, `1\. `,
    /// and the bullet as its HTML entity, all of which CommonMark (and an older Cutling) shows as typed.
    private nonisolated static func escapeLineStart(_ line: String) -> String {
        guard let (kind, length) = ListKind.leading(line) else { return line }
        switch kind {
        case .bulleted: return "&#8226;" + line.dropFirst()
        case .dashed: return "\\" + line
        case .numbered: return line.prefix(length - 2) + "\\" + line.dropFirst(length - 2)
        }
    }

    // MARK: Attributed → Markdown

    private nonisolated struct Style: Equatable {
        var bold = false, italic = false, strike = false, code = false, underline = false, highlight = false
        var link: URL?
    }

    /// Markdown for an attributed string, or nil when it carries no supported formatting.
    /// A list comes from the editor's own markers or from a pasted list (`NSTextList`, as Notes, Mail and Safari write it).
    nonisolated static func markdown(from attributed: NSAttributedString, trimTrailingNewlines: Bool = true) -> String? {
        let string = attributed.string as NSString
        var lines: [String] = []
        var formatted = false
        var number = 0
        var location = 0
        while true {
            let newline = string.range(of: "\n", range: NSRange(location: location, length: string.length - location))
            let end = newline.location == NSNotFound ? string.length : newline.location
            var content = NSRange(location: location, length: end - location)
            let kind = listItem(in: attributed, paragraph: content)
            if let kind {
                content = NSRange(location: content.location + kind.length, length: content.length - kind.length)
                number = kind.kind == .numbered ? number + 1 : 0
                formatted = true
            } else {
                number = 0
            }
            var segments: [(String, Style)] = []
            if content.length > 0 {
                attributed.enumerateAttributes(in: content) { attrs, range, _ in
                    let style = Self.style(attrs)
                    let text = string.substring(with: range)
                    if let last = segments.last, last.1 == style {
                        segments[segments.count - 1].0 += text
                    } else {
                        segments.append((text, style))
                    }
                }
            }
            if segments.contains(where: { $0.1 != Style() }) { formatted = true }
            let body = segments.map { wrap($0.0, $0.1) }.joined()
            lines.append(kind.map { $0.kind.marker(number) + body } ?? escapeLineStart(body))
            if newline.location == NSNotFound { break }
            location = end + 1
        }
        guard formatted else { return nil }
        var out = lines.joined(separator: "\n")
        // Paragraph-based sources end in a newline the user never typed.
        while trimTrailingNewlines, out.hasSuffix("\n") { out.removeLast() }
        return out
    }

    /// The list a paragraph belongs to, and how many of its leading characters are the marker to drop.
    private nonisolated static func listItem(in attributed: NSAttributedString, paragraph: NSRange) -> (kind: ListKind, length: Int)? {
        let string = attributed.string as NSString
        let text = string.substring(with: paragraph)
        // The editor's own list: its marker characters say so.
        if paragraph.length > 0, let raw = attributed.attribute(.cutlingListMarker, at: paragraph.location, effectiveRange: nil) as? String,
           let kind = ListKind(rawValue: raw), let found = ListKind.leading(text) {
            return (kind, found.length)
        }
        // A pasted list: the paragraph style names it, and the marker may be in the text as "\t•\t".
        // An empty paragraph's style sits on its newline; the empty end after a last newline has none.
        guard paragraph.location < attributed.length,
              let style = attributed.attribute(.paragraphStyle, at: paragraph.location, effectiveRange: nil) as? NSParagraphStyle,
              let list = style.textLists.last else { return nil }
        var marker = 0
        if text.hasPrefix("\t"), let second = text.dropFirst().firstIndex(of: "\t"), text.distance(from: text.startIndex, to: second) <= 8 {
            marker = (String(text[...second]) as NSString).length
        }
        return (ListKind(list), marker)
    }

    private nonisolated static func style(_ attrs: [NSAttributedString.Key: Any]) -> Style {
        var style = Style()
        #if canImport(UIKit)
        if let font = attrs[.font] as? UIFont {
            let traits = font.fontDescriptor.symbolicTraits
            style.bold = traits.contains(.traitBold)
            style.italic = traits.contains(.traitItalic)
            style.code = traits.contains(.traitMonoSpace)
        }
        #elseif canImport(AppKit)
        if let font = attrs[.font] as? NSFont {
            let traits = font.fontDescriptor.symbolicTraits
            style.bold = traits.contains(.bold)
            style.italic = traits.contains(.italic)
            style.code = traits.contains(.monoSpace)
        }
        #endif
        if let strike = attrs[.strikethroughStyle] as? Int, strike != 0 { style.strike = true }
        if let url = attrs[.link] as? URL {
            style.link = url
        } else if let string = attrs[.link] as? String {
            style.link = URL(string: string)
        }
        // A link is drawn underlined by most hosts already, and web pages underline every one.
        if style.link == nil, let underline = attrs[.underlineStyle] as? Int, underline != 0 { style.underline = true }
        style.highlight = attrs[.textHighlightStyle] != nil || isHighlight(attrs[.backgroundColor])
        return style
    }

    /// A pasted background colour reads as a highlight only when it is a colour: web pages paint
    /// white, grey and black boxes behind text that nobody meant as a highlight.
    private nonisolated static func isHighlight(_ value: Any?) -> Bool {
        #if canImport(UIKit)
        guard let color = value as? UIColor else { return false }
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        guard color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return false }
        #elseif canImport(AppKit)
        guard let color = (value as? NSColor)?.usingColorSpace(.deviceRGB) else { return false }
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        #endif
        return alpha >= 0.1 && saturation > 0.25 && brightness > 0.25
    }

    private nonisolated static func wrap(_ text: String, _ style: Style) -> String {
        let core = text.trimmingCharacters(in: .whitespaces)
        guard !core.isEmpty, style != Style() else { return style.code ? text : escapeInline(text) }
        let leading = String(text.prefix { $0 == " " || $0 == "\t" })
        let trailing = String(text.reversed().prefix { $0 == " " || $0 == "\t" }.reversed())

        var body: String
        if style.code {
            let fence = core.contains("`") ? "``" : "`"
            body = fence + (core.hasPrefix("`") || core.hasSuffix("`") ? " \(core) " : core) + fence
        } else {
            body = escapeInline(core)
        }
        if style.strike { body = "~~\(body)~~" }
        if style.italic { body = "*\(body)*" }
        if style.bold { body = "**\(body)**" }
        if let link = style.link { body = "[\(body)](\(link.absoluteString.replacingOccurrences(of: ")", with: "%29")))" }
        var attributes: [String] = []
        if style.underline { attributes.append("underline: true") }
        if style.highlight { attributes.append("highlight: true") }
        if !attributes.isEmpty { body = "^[\(body)](\(attributes.joined(separator: ", ")))" }
        return leading + body + trailing
    }

    // MARK: Markdown → RTF / HTML

    #if canImport(UIKit)
    private typealias PlatformFont = UIFont
    private typealias PlatformColor = UIColor
    #elseif canImport(AppKit)
    private typealias PlatformFont = NSFont
    private typealias PlatformColor = NSColor
    #endif

    private nonisolated static func font(bold: Bool, italic: Bool, code: Bool, size: CGFloat) -> PlatformFont {
        let base = code
            ? PlatformFont.monospacedSystemFont(ofSize: size, weight: bold ? .bold : .regular)
            : PlatformFont.systemFont(ofSize: size, weight: bold ? .bold : .regular)
        guard italic else { return base }
        #if canImport(UIKit)
        let traits = base.fontDescriptor.symbolicTraits.union(.traitItalic)
        return base.fontDescriptor.withSymbolicTraits(traits).map { UIFont(descriptor: $0, size: size) } ?? base
        #else
        let descriptor = base.fontDescriptor.withSymbolicTraits(base.fontDescriptor.symbolicTraits.union(.italic))
        return NSFont(descriptor: descriptor, size: size) ?? base
        #endif
    }

    /// Platform attributed string: 12 pt with no colour for export, or the editor's size and text colour.
    /// For export a list is Apple's own list (`NSTextList`) with its markers taken out of the text, as RTF and
    /// Notes expect; in the editor the markers stay as text, marked as the list's, with wrapped lines hung under the text.
    nonisolated static func nsAttributed(_ markdown: String, size: CGFloat = 12, editorColors: Bool = false) -> NSAttributedString {
        let source = attributed(markdown)
        let out = NSMutableAttributedString()
        for run in source.runs {
            let text = String(source[run.range].characters)
            let intent = run.inlinePresentationIntent ?? []
            var attrs: [NSAttributedString.Key: Any] = [
                .font: font(bold: intent.contains(.stronglyEmphasized),
                            italic: intent.contains(.emphasized),
                            code: intent.contains(.code),
                            size: size)
            ]
            #if canImport(UIKit)
            if editorColors { attrs[.foregroundColor] = UIColor.label }
            #elseif canImport(AppKit)
            if editorColors { attrs[.foregroundColor] = NSColor.textColor }
            #endif
            if intent.contains(.strikethrough) { attrs[.strikethroughStyle] = NSUnderlineStyle.single.rawValue }
            if run[CutlingUnderlineAttribute.self] == true { attrs[.underlineStyle] = NSUnderlineStyle.single.rawValue }
            if run[CutlingHighlightAttribute.self] == true {
                // Notes' own highlight in its first colour, purple: Notes and Pages keep it as a highlight, and WebKit
                // (Mail and web pages on iOS read the RTF) draws it as Notes' copy does, tinted text on a light tint.
                attrs[.textHighlightStyle] = NSAttributedString.TextHighlightStyle.default
                attrs[.textHighlightColorScheme] = NSAttributedString.TextHighlightColorScheme.purple
            }
            if let link = run.link { attrs[.link] = link }
            out.append(NSAttributedString(string: text, attributes: attrs))
        }
        applyLists(listKinds(markdown), to: out, size: size, editor: editorColors)
        return out
    }

    private nonisolated static func applyLists(_ kinds: [ListKind?], to out: NSMutableAttributedString, size: CGFloat, editor: Bool) {
        guard kinds.contains(where: { $0 != nil }) else { return }
        let string = out.string as NSString
        var paragraphs: [NSRange] = []
        var location = 0
        while true {
            let newline = string.range(of: "\n", range: NSRange(location: location, length: string.length - location))
            let end = newline.location == NSNotFound ? string.length : newline.location
            paragraphs.append(NSRange(location: location, length: end - location))
            if newline.location == NSNotFound { break }
            location = end + 1
        }
        // A code span can join lines; then the stored lines no longer say which paragraph is which.
        guard paragraphs.count == kinds.count else { return }
        var markers: [NSRange] = []
        var current: (ListKind, NSTextList)?
        for (paragraph, kind) in zip(paragraphs, kinds) {
            guard let kind, let found = ListKind.leading(string.substring(with: paragraph)), found.kind == kind else {
                current = nil
                continue
            }
            let marker = NSRange(location: paragraph.location, length: found.length)
            let whole = NSRange(location: paragraph.location, length: min(paragraph.upperBound + 1, string.length) - paragraph.location)
            let style = NSMutableParagraphStyle()
            if editor {
                out.addAttribute(.cutlingListMarker, value: kind.rawValue, range: marker)
                let width = string.substring(with: marker).size(withAttributes: [.font: PlatformFont.systemFont(ofSize: size)]).width
                style.headIndent = ceil(width)
            } else {
                if current?.0 != kind { current = (kind, NSTextList(markerFormat: kind.textListFormat, options: 0)) }
                style.textLists = [current!.1]
                markers.append(marker)
            }
            if whole.length > 0 { out.addAttribute(.paragraphStyle, value: style, range: whole) }
        }
        for marker in markers.reversed() { out.deleteCharacters(in: marker) }
    }

    nonisolated static func rtfData(_ markdown: String) -> Data? {
        let ns = nsAttributed(markdown)
        return try? ns.data(from: NSRange(location: 0, length: ns.length),
                            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
    }

    /// Minimal HTML with no fonts, so the destination keeps its own style. Lists are real lists, with Notes'
    /// own class on a dashed one.
    nonisolated static func html(_ markdown: String) -> String {
        let source = attributed(markdown)
        let kinds = listKinds(markdown)
        var lines: [String] = [""]
        var plainLines: [String] = [""]
        for run in source.runs {
            let parts = String(source[run.range].characters).components(separatedBy: "\n")
            for (index, part) in parts.enumerated() {
                if index > 0 { lines.append(""); plainLines.append("") }
                plainLines[plainLines.count - 1] += part
                // A list line's marker is the list's to draw; it leaves the text.
                var text = Substring(part)
                let line = lines.count - 1
                if line < kinds.count, let kind = kinds[line], let found = ListKind.leading(plainLines[line]), found.kind == kind {
                    let drawn = (plainLines[line] as NSString).length - (part as NSString).length
                    let skip = max(0, found.length - drawn)
                    text = Substring((part as NSString).substring(from: min(skip, (part as NSString).length)))
                }
                guard !text.isEmpty else { continue }
                lines[line] += htmlPiece(String(text), run)
            }
        }
        guard lines.count == kinds.count, kinds.contains(where: { $0 != nil }) else {
            return "<meta charset=\"utf-8\"><span style=\"white-space:pre-wrap\">\(lines.joined(separator: "<br>"))</span>"
        }
        var body = ""
        var open: ListKind?
        for (index, (line, kind)) in zip(lines, kinds).enumerated() {
            if kind != open, let open { body += open == .numbered ? "</ol>" : "</ul>" }
            if let kind {
                if kind != open {
                    switch kind {
                    case .bulleted: body += "<ul>"
                    case .dashed: body += "<ul class=\"Apple-dash-list\" style=\"list-style-type:'- '\">"
                    case .numbered: body += "<ol>"
                    }
                }
                body += "<li>\(line)</li>"
            } else {
                // A list ends its own block, so only a line after a line breaks.
                if open == nil, index > 0 { body += "<br>" }
                body += line
            }
            open = kind
        }
        if let open { body += open == .numbered ? "</ol>" : "</ul>" }
        return "<meta charset=\"utf-8\"><div style=\"white-space:pre-wrap\">\(body)</div>"
    }

    private nonisolated static func htmlPiece(_ text: String, _ run: AttributedString.Runs.Run) -> String {
        var piece = text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        let intent = run.inlinePresentationIntent ?? []
        if intent.contains(.code) { piece = "<code>\(piece)</code>" }
        if intent.contains(.strikethrough) { piece = "<s>\(piece)</s>" }
        if intent.contains(.emphasized) { piece = "<i>\(piece)</i>" }
        if intent.contains(.stronglyEmphasized) { piece = "<b>\(piece)</b>" }
        if run[CutlingUnderlineAttribute.self] == true { piece = "<u>\(piece)</u>" }
        // Apple's HTML writer draws Notes' purple highlight as tinted text on a 15 % tint; the <mark> keeps the meaning.
        if run[CutlingHighlightAttribute.self] == true { piece = "<mark style=\"color:#9d33d6;background-color:rgba(157,51,214,0.15)\">\(piece)</mark>" }
        if let link = run.link {
            let href = link.absoluteString.replacingOccurrences(of: "\"", with: "%22")
            piece = "<a href=\"\(href)\">\(piece)</a>"
        }
        return piece
    }

    // MARK: Capture

    /// Markdown from RTF data, or nil when it has no supported formatting.
    nonisolated static func markdown(fromRTF data: Data) -> String? {
        guard let ns = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
        ) else { return nil }
        return markdown(from: ns)
    }

    /// Markdown from HTML. WebKit-backed: main thread, main app only.
    @MainActor
    static func markdown(fromHTML data: Data) -> String? {
        guard let ns = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil
        ) else { return nil }
        return markdown(from: ns)
    }
}

// MARK: - Cutling helpers

extension Cutling {
    /// The stored format; undecided cutlings are read by the code rules.
    var textFormat: TextFormat {
        get { format ?? (kind == .text && TextFormat.looksLikeCode(value) ? .code : .plain) }
        set { format = newValue }
    }

    /// What a reader sees: Rich markers removed.
    var plainValue: String {
        textFormat == .rich ? RichText.plainText(value) : value
    }

    /// The text as written, for anything that leaves Cutling unfilled (share, drag, Spotlight, VoiceOver):
    /// fill-ins keep their braces, without the invisible marker that tells Cutling's own braces from typed ones.
    var writtenText: String {
        plainValue.replacingOccurrences(of: String(Placeholders.marker), with: "")
    }
}

// MARK: - Pasteboard

enum CutlingPasteboard {
    nonisolated static let alwaysPlainKey = "alwaysPastePlainText"

    nonisolated static var alwaysPastesPlain: Bool {
        UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.bool(forKey: alwaysPlainKey) ?? false
    }

    /// Copies a text cutling; Rich adds RTF and HTML flavours unless plain is forced.
    @MainActor
    static func copy(_ cutling: Cutling, plainOnly: Bool = false) {
        let plain = cutling.plainValue
        let rich = cutling.textFormat == .rich && !plainOnly && !alwaysPastesPlain
        #if canImport(UIKit)
        if rich {
            var item: [String: Any] = [
                UTType.utf8PlainText.identifier: plain,
                UTType.html.identifier: RichText.html(cutling.value)
            ]
            if let rtf = RichText.rtfData(cutling.value) { item[UTType.rtf.identifier] = rtf }
            UIPasteboard.general.setItems([item])
        } else {
            UIPasteboard.general.string = plain
        }
        #elseif canImport(AppKit)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        if rich {
            let item = NSPasteboardItem()
            if let rtf = RichText.rtfData(cutling.value) { item.setData(rtf, forType: .rtf) }
            item.setString(RichText.html(cutling.value), forType: .html)
            item.setString(plain, forType: .string)
            pasteboard.writeObjects([item])
        } else {
            pasteboard.setString(plain, forType: .string)
        }
        #endif
    }

    #if canImport(UIKit)
    /// Plain text and any formatting on the pasteboard, in one read so iOS asks to paste once.
    @MainActor
    static func readText(allowHTML: Bool) -> (plain: String?, markdown: String?) {
        guard let item = UIPasteboard.general.items.first else { return (nil, nil) }
        func data(_ type: UTType) -> Data? {
            (item[type.identifier] as? Data) ?? (item[type.identifier] as? String)?.data(using: .utf8)
        }
        // Text can come back as a String or as UTF-8 bytes, under any plain-text type.
        let plain = item.first { key, _ in UTType(key)?.conforms(to: .plainText) == true }.flatMap { _, value in
            (value as? String) ?? (value as? Data).flatMap { String(data: $0, encoding: .utf8) }
        }
        var markdown: String?
        if let rtf = data(.rtf) { markdown = RichText.markdown(fromRTF: rtf) }
        if markdown == nil, allowHTML, let html = data(.html) { markdown = RichText.markdown(fromHTML: html) }
        return (plain, markdown)
    }

    /// Formatted text on the pasteboard as Markdown; HTML only where WebKit may run.
    @MainActor
    static func formattedMarkdown(allowHTML: Bool) -> String? {
        readText(allowHTML: allowHTML).markdown
    }
    #elseif canImport(AppKit)
    @MainActor
    static func readText(allowHTML: Bool) -> (plain: String?, markdown: String?) {
        (NSPasteboard.general.string(forType: .string), formattedMarkdown(allowHTML: allowHTML))
    }

    @MainActor
    static func formattedMarkdown(allowHTML: Bool) -> String? {
        let pasteboard = NSPasteboard.general
        if let rtf = pasteboard.data(forType: .rtf), let markdown = RichText.markdown(fromRTF: rtf) {
            return markdown
        }
        if allowHTML, let html = pasteboard.data(forType: .html) {
            return RichText.markdown(fromHTML: html)
        }
        return nil
    }
    #endif
}

#if canImport(SwiftUI)
import SwiftUI

extension Cutling {
    /// The value as display text, styled by format, each fill-in drawn as the editor's pill
    /// (FillInPills.swift) so a preview reads like the cutling, never like its braces.
    var displayText: Text { displayText(pillSize: 13) }

    /// How much of a value a preview draws: well past the few lines any card, key or list row shows.
    /// Laying out a whole 10,000-character cutling in every visible card costs the keyboard megabytes
    /// it doesn't have, and makes each card's spoken label the whole text.
    static let previewLength = 400

    /// The start of `value` a preview draws, never cut inside a fill-in's token.
    static func previewSource(_ value: String) -> String {
        guard value.count > previewLength else { return value }
        var head = String(value.prefix(previewLength))
        let open = "{\u{2060}"
        if let start = head.range(of: open, options: .backwards), head[start.upperBound...].firstIndex(of: "}") == nil {
            head = String(head[..<start.lowerBound])
        }
        return head
    }

    func displayText(pillSize: CGFloat) -> Text {
        guard textFormat != .code else { return Text(Self.previewSource(value)).monospaced() }
        return Self.previewPieces(value, format: textFormat).reduce(Text(verbatim: "")) { text, piece in
            switch piece {
            case .text(let run): text + Text(run)
            case .token(let token): text + FillInPills.inline(token, size: pillSize)
            }
        }
    }

    enum PreviewPiece {
        case text(AttributedString)
        case token(String)
    }

    /// What a preview draws of a value: its runs of text, styled, and its fill-ins between them, cut to `previewLength`
    /// characters of what a reader sees. Formatted text is parsed whole before the cut, so the cut never lands inside
    /// a marker (a key once showed "^[an underlined phra"); a fill-in is never cut. Plain text is cut first, since it
    /// has no markers and may be 10,000 characters long.
    static func previewPieces(_ value: String, format: TextFormat) -> [PreviewPiece] {
        let source = format == .rich ? RichText.display(value) : AttributedString(previewSource(value))
        var pieces: [PreviewPiece] = []
        var index = source.startIndex
        var shown = 0
        for piece in FillInPills.split(String(source.characters)) {
            guard shown < previewLength else { break }
            switch piece {
            case .token(let token):
                pieces.append(.token(token))
                shown += token.count
                index = source.characters.index(index, offsetBy: token.count)
            case .text(let run):
                let take = min(run.count, previewLength - shown)
                pieces.append(.text(AttributedString(source[index..<source.characters.index(index, offsetBy: take)])))
                shown += take
                index = source.characters.index(index, offsetBy: run.count)
            }
        }
        return pieces
    }
}

extension RichText {
    /// Rich text for SwiftUI's `Text`, which draws underline and a background but knows neither stored attribute.
    /// The highlight is Notes' purple one, as the editor draws it: purple text on a light purple.
    static func display(_ markdown: String) -> AttributedString {
        var text = attributed(markdown)
        let marked = text.runs.compactMap { run -> (Range<AttributedString.Index>, Bool, Bool)? in
            let underline = run[CutlingUnderlineAttribute.self] == true
            let highlight = run[CutlingHighlightAttribute.self] == true
            return underline || highlight ? (run.range, underline, highlight) : nil
        }
        for (range, underline, highlight) in marked {
            if underline { text[range].swiftUI.underlineStyle = .single }
            if highlight {
                text[range].swiftUI.foregroundColor = Color.purple
                text[range].swiftUI.backgroundColor = Color.purple.opacity(0.18)
            }
        }
        return text
    }
}
#endif
