//
//  RichText.swift
//  Cutling
//
//  Text cutling formats. Rich cutlings store an inline Markdown subset
//  (bold, italic, strikethrough, inline code, links) in `value`.
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

enum RichText {
    nonisolated static let maxStoredLength = 1500

    private static let options = AttributedString.MarkdownParsingOptions(
        interpretedSyntax: .inlineOnlyPreservingWhitespace,
        failurePolicy: .returnPartiallyParsedIfPossible
    )

    /// Rendered rich text; falls back to the raw string.
    nonisolated static func attributed(_ markdown: String) -> AttributedString {
        (try? AttributedString(markdown: markdown, options: options)) ?? AttributedString(markdown)
    }

    /// The text a reader sees, markers removed.
    nonisolated static func plainText(_ markdown: String) -> String {
        String(attributed(markdown).characters)
    }

    /// Escapes plain text so Markdown shows it literally.
    nonisolated static func escape(_ plain: String) -> String {
        var out = ""
        out.reserveCapacity(plain.count)
        for ch in plain {
            if "\\`*_~[]<>&".contains(ch) { out.append("\\") }
            out.append(ch)
        }
        return out
    }

    // MARK: Attributed → Markdown

    private struct Style: Equatable {
        var bold = false, italic = false, strike = false, code = false
        var link: URL?
    }

    /// Markdown for an attributed string, or nil when it carries no supported formatting.
    nonisolated static func markdown(from attributed: NSAttributedString, trimTrailingNewlines: Bool = true) -> String? {
        var segments: [(String, Style)] = []
        let full = NSRange(location: 0, length: attributed.length)
        attributed.enumerateAttributes(in: full) { attrs, range, _ in
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
            let text = (attributed.string as NSString).substring(with: range)
            if let last = segments.last, last.1 == style {
                segments[segments.count - 1].0 += text
            } else {
                segments.append((text, style))
            }
        }
        guard segments.contains(where: { $0.1 != Style() }) else { return nil }

        var out = ""
        for (text, style) in segments {
            // Markers can't span a line break or touch inner whitespace.
            let lines = text.components(separatedBy: "\n")
            for (i, line) in lines.enumerated() {
                if i > 0 { out += "\n" }
                out += wrap(line, style)
            }
        }
        // Paragraph-based sources end in a newline the user never typed.
        while trimTrailingNewlines, out.hasSuffix("\n") { out.removeLast() }
        return out
    }

    private nonisolated static func wrap(_ text: String, _ style: Style) -> String {
        let core = text.trimmingCharacters(in: .whitespaces)
        guard !core.isEmpty, style != Style() else { return style.code ? text : escape(text) }
        let leading = String(text.prefix { $0 == " " || $0 == "\t" })
        let trailing = String(text.reversed().prefix { $0 == " " || $0 == "\t" }.reversed())

        var body: String
        if style.code {
            let fence = core.contains("`") ? "``" : "`"
            body = fence + (core.hasPrefix("`") || core.hasSuffix("`") ? " \(core) " : core) + fence
        } else {
            body = escape(core)
        }
        if style.strike { body = "~~\(body)~~" }
        if style.italic { body = "*\(body)*" }
        if style.bold { body = "**\(body)**" }
        if let link = style.link { body = "[\(body)](\(link.absoluteString.replacingOccurrences(of: ")", with: "%29")))" }
        return leading + body + trailing
    }

    // MARK: Markdown → RTF / HTML

    #if canImport(UIKit)
    private typealias PlatformFont = UIFont
    #elseif canImport(AppKit)
    private typealias PlatformFont = NSFont
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
            if let link = run.link { attrs[.link] = link }
            out.append(NSAttributedString(string: text, attributes: attrs))
        }
        return out
    }

    nonisolated static func rtfData(_ markdown: String) -> Data? {
        let ns = nsAttributed(markdown)
        return try? ns.data(from: NSRange(location: 0, length: ns.length),
                            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
    }

    /// Minimal HTML with no fonts, so the destination keeps its own style.
    nonisolated static func html(_ markdown: String) -> String {
        let source = attributed(markdown)
        var body = ""
        for run in source.runs {
            var piece = String(source[run.range].characters)
                .replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
                .replacingOccurrences(of: "\n", with: "<br>")
            let intent = run.inlinePresentationIntent ?? []
            if intent.contains(.code) { piece = "<code>\(piece)</code>" }
            if intent.contains(.strikethrough) { piece = "<s>\(piece)</s>" }
            if intent.contains(.emphasized) { piece = "<i>\(piece)</i>" }
            if intent.contains(.stronglyEmphasized) { piece = "<b>\(piece)</b>" }
            if let link = run.link {
                let href = link.absoluteString.replacingOccurrences(of: "\"", with: "%22")
                piece = "<a href=\"\(href)\">\(piece)</a>"
            }
            body += piece
        }
        return "<meta charset=\"utf-8\"><span style=\"white-space:pre-wrap\">\(body)</span>"
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
    /// The value as display text, styled by format.
    var displayText: Text {
        switch textFormat {
        case .plain: Text(value)
        case .rich: Text(RichText.attributed(value))
        case .code: Text(value).monospaced()
        }
    }
}
#endif
