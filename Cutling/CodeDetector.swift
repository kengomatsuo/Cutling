//
//  CodeDetector.swift
//  Cutling
//
//  Decides whether text is code. Fast rules answer clear cases everywhere;
//  on Apple Intelligence devices the on-device model settles unclear ones
//  and names the language. Main app only, never the keyboard.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

enum CodeDetector {
    struct Verdict: Equatable {
        var isCode: Bool
        var language: String?
    }

    /// true or false when the rules are sure, nil when they aren't.
    static func ruleVerdict(_ text: String) -> Bool? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 3 else { return false }
        if TextFormat.looksLikeCode(text) || isJSON(trimmed) || isMarkup(trimmed) { return true }
        let symbols = trimmed.filter { "{}()[];=<>$`|&\\/#*".contains($0) }.count
        if Double(symbols) / Double(trimmed.count) < 0.02 {
            // Two to four lowercase words may be a command (`npm i react`); let the model look.
            let words = trimmed.split(whereSeparator: \.isWhitespace)
            let commandLike = (2...4).contains(words.count) && trimmed.first?.isLowercase == true
                && !trimmed.contains("\n") && !".!?,".contains(trimmed.last ?? " ")
            return commandLike ? nil : false
        }
        return nil
    }

    private static func isJSON(_ text: String) -> Bool {
        guard text.first == "{" || text.first == "[", let data = text.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: data)) != nil
    }

    private static func isMarkup(_ text: String) -> Bool {
        text.range(of: #"<([A-Za-z][A-Za-z0-9-]*)\b[^>]*>[\s\S]*</\1>"#, options: .regularExpression) != nil
    }

    static func detect(_ text: String) async -> Verdict {
        let rule = ruleVerdict(text)
        if rule == false { return Verdict(isCode: false) }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *), SystemLanguageModel.default.isAvailable,
           let verdict = await modelVerdict(text) {
            // The model may only upgrade an unsure case; rules keep a sure "code".
            return rule == true ? Verdict(isCode: true, language: verdict.language) : verdict
        }
        #endif
        return Verdict(isCode: rule == true)
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, macOS 26.0, *)
    @Generable(description: "Whether a snippet is source code")
    struct ModelVerdict {
        @Guide(description: "True for source code, shell commands, SQL, markup or config files; false for prose, addresses, names or lists")
        var isCode: Bool
        @Guide(description: "The language name, such as Swift, Python, Bash or JSON; empty when not code")
        var language: String
    }

    @available(iOS 26.0, macOS 26.0, *)
    private static func modelVerdict(_ text: String) async -> Verdict? {
        let session = LanguageModelSession(instructions: "You classify short text snippets a user saved for pasting later.")
        do {
            let response = try await session.respond(
                to: "Snippet:\n\(text.prefix(600))",
                generating: ModelVerdict.self
            )
            let language = response.content.language.trimmingCharacters(in: .whitespacesAndNewlines)
            // Naming a language counts as code even when the flag disagrees.
            return Verdict(isCode: response.content.isCode || !language.isEmpty, language: language.isEmpty ? nil : language)
        } catch {
            return nil
        }
    }
    #endif
}
