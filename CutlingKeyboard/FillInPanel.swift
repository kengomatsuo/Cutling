//
//  FillInPanel.swift
//  CutlingKeyboard
//
//  A cutling with blanks asks for them before anything is typed. The top bar shows the cutling's
//  sentence with the waiting blank in green; the grid offers Type with Your Keyboard, the blank's
//  choices, values used before and Paste; the return key moves to the next blank, then inserts.
//  Cutling draws no letter keys, so a value is typed on the person's own keyboard: either before
//  the cutling is tapped (the word before the cursor fills the first blank), or after Type with
//  Your Keyboard, coming back with the globe key. What the person typed into the app is removed
//  when the finished text goes in. Screens change at once and keys press with the keyboard's flat
//  highlight, as Apple's keyboard does (docs/research/fill-ins-press-feedback.md).
//  Full account: docs/fill-ins.md, flow: docs/fill-ins-flow.md
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI
import UIKit

/// One cutling waiting for its blanks. Saved in the App Group, because iOS may tear the keyboard
/// down while the person types in their own keyboard.
struct FillSession: Codable, Equatable {
    var cutlingID: UUID
    /// The cutling's text in pieces, stamps already dated.
    var chunks: [Placeholders.Chunk]
    /// Each blank once, in order.
    var fields: [Placeholders.Field]
    var index = 0
    var values: [String: String] = [:]
    /// Everything the person typed into the app for these blanks, in order, removed when the text goes in.
    var typed = ""
    /// The text before the cursor when the person left to type on their own keyboard.
    var anchor: String?
    var smartSpacing: Bool
    var startedAt = Date()

    var field: Placeholders.Field? { fields.indices.contains(index) ? fields[index] : nil }
    var isLast: Bool { index >= fields.count - 1 }

    /// In the App Group so a test seed can clear a session left from an earlier run.
    static let storeKey = "keyboardFillSession"
    private static var defaults: UserDefaults? { UserDefaults(suiteName: "group.com.matsuokengo.Cutling") }
    /// A session older than this is dropped rather than resumed.
    static let lifetime: TimeInterval = 15 * 60

    static func load() -> FillSession? {
        guard let data = defaults?.data(forKey: storeKey),
              let session = try? JSONDecoder().decode(FillSession.self, from: data),
              Date().timeIntervalSince(session.startedAt) < lifetime
        else { return nil }
        return session
    }

    static func save(_ session: FillSession?) {
        if let session, let data = try? JSONEncoder().encode(session) {
            defaults?.set(data, forKey: storeKey)
        } else {
            defaults?.removeObject(forKey: storeKey)
        }
    }

    /// What was typed after `anchor`, read from the text before the cursor.
    static func typed(after anchor: String, in context: String) -> String? {
        if anchor.isEmpty { return context }
        // The app may hand over only part of the text; a shorter end still finds the spot.
        for length in stride(from: anchor.count, through: min(anchor.count, 4), by: -4) {
            let probe = String(anchor.suffix(length))
            if let range = context.range(of: probe, options: .backwards) {
                return String(context[range.upperBound...])
            }
        }
        return nil
    }

    /// The word just before the cursor, allowing one space after it, and the characters it takes up.
    static func wordTypedFirst(in context: String) -> (word: String, length: Int)? {
        var text = Substring(context)
        var length = 0
        if text.last == " " { text = text.dropLast(); length = 1 }
        let word = String(text.reversed().prefix { $0.isLetter || $0.isNumber || $0 == "-" || $0 == "'" || $0 == "’" }.reversed())
        guard !word.isEmpty, word.count <= FillInMemory.maxValueLength else { return nil }
        return (word, length + word.count)
    }
}

/// The top bar during a fill-in: the sentence with its blanks, and a close button where the open-app button sits.
struct FillInBar: View {
    let session: FillSession
    let keyHeight: CGFloat
    /// The keyboard's strings bundle (another language in store screenshots).
    let bundle: Bundle?
    let onCancel: () -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let green = Color(hex: 0x00be86)

    var body: some View {
        HStack(spacing: 6) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(session.chunks.enumerated()), id: \.offset) { offset, chunk in
                            switch chunk {
                            case .text(let text): Text(verbatim: text.replacingOccurrences(of: "\n", with: " "))
                            case .field(let field): blank(field).id(offset)
                            case .cursor: EmptyView()
                            }
                        }
                    }
                    .font(.system(size: KeyStyle.buttonTextSize(for: horizontalSizeClass)))
                    .lineLimit(1)
                    .padding(.horizontal, 4)
                    .frame(minHeight: keyHeight)
                }
                .onAppear { scroll(proxy) }
                .onChange(of: session.index) { scroll(proxy) }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(spokenSentence))

            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: KeyStyle.buttonIconSize(for: horizontalSizeClass), weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: keyHeight, height: keyHeight)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Cancel", bundle: bundle))
        }
    }

    /// Keeps the waiting blank in view, without animation.
    private func scroll(_ proxy: ScrollViewProxy) {
        guard let key = session.field?.key,
              let offset = session.chunks.firstIndex(where: { if case .field(let f) = $0 { return f.key == key }; return false })
        else { return }
        proxy.scrollTo(offset, anchor: .center)
    }

    private func blank(_ field: Placeholders.Field) -> some View {
        let active = field.key == session.field?.key
        let value = session.values[field.key]
        return Text(verbatim: value ?? field.label)
            .foregroundStyle(active ? green : (value != nil ? Color.primary : Color.secondary))
            .overlay(alignment: .bottom) {
                if active {
                    Capsule().fill(green).frame(height: 2).offset(y: 3)
                } else if value == nil {
                    Rectangle().fill(Color.secondary.opacity(0.5)).frame(height: 1).offset(y: 3)
                }
            }
    }

    private var spokenSentence: String {
        session.chunks.map { chunk -> String in
            switch chunk {
            case .text(let text): return text
            case .field(let field): return session.values[field.key] ?? field.label
            case .cursor: return ""
            }
        }.joined()
    }
}

/// The grid during a fill-in. Its first key sends the person to their own keyboard to type the blank;
/// below it, the blank's choices, values used before and Paste. Same surface, radius and press as
/// Cutling's cards (`KeyStyle`, `KeyboardButtonStyle`).
struct FillInKeys: View {
    let session: FillSession
    let canPaste: Bool
    let bundle: Bundle?
    let keyHeight: CGFloat
    let keySpacing: CGFloat
    let onYourKeyboard: () -> Void
    let onPick: (String) -> Void
    let onPaste: () -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let green = Color(hex: 0x00be86)

    private struct Value: Identifiable {
        let text: String
        var chosen = false
        var id: String { text }
    }

    private var values: [Value] {
        guard let field = session.field else { return [] }
        let current = session.values[field.key]
        if field.options.count > 1 {
            let chosen = current ?? field.options[0]
            var out = field.options.map { Value(text: $0, chosen: $0 == chosen) }
            if let current, !field.options.contains(current) { out.insert(Value(text: current, chosen: true), at: 0) }
            return out
        }
        var texts: [String] = []
        for text in [current].compactMap({ $0 }) + field.options + FillInMemory.recent(for: field) where !texts.contains(text) {
            texts.append(text)
        }
        return texts.prefix(canPaste ? 5 : 6).map { Value(text: $0, chosen: $0 == current) }
    }

    var body: some View {
        VStack(spacing: keySpacing) {
            yourKeyboardKey
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: keySpacing), count: 3), spacing: keySpacing) {
                ForEach(values) { value in
                    key(value.text, chosen: value.chosen) { onPick(value.text) }
                }
                if canPaste, (session.field?.options.count ?? 0) <= 1 {
                    key("Paste", icon: "doc.on.clipboard", action: onPaste)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, KeyStyle.horizontalPadding)
    }

    private var yourKeyboardKey: some View {
        Button(action: onYourKeyboard) {
            HStack(spacing: 8) {
                Image(systemName: "keyboard")
                    .font(.system(size: KeyStyle.buttonIconSize(for: horizontalSizeClass), weight: .medium))
                Text("Type with Your Keyboard", bundle: bundle)
                    .font(.system(size: KeyStyle.buttonTextSize(for: horizontalSizeClass), weight: .semibold))
            }
            .foregroundStyle(green)
            .frame(maxWidth: .infinity, minHeight: keyHeight + 8)
            .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
        }
        .buttonStyle(KeyboardButtonStyle(cornerRadius: KeyStyle.cornerRadius))
        .accessibilityIdentifier("fillInYourKeyboard")
    }

    private func key(_ text: String, icon: String? = nil, chosen: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: KeyStyle.iconSize(for: horizontalSizeClass) + 2))
                        .foregroundStyle(.secondary)
                }
                Text(verbatim: icon == nil ? text : String(localized: "Paste", bundle: bundle ?? .main))
                    .font(.system(size: KeyStyle.buttonTextSize(for: horizontalSizeClass)))
                    .lineLimit(1)
                if chosen {
                    Image(systemName: "checkmark")
                        .font(.system(size: KeyStyle.iconSize(for: horizontalSizeClass), weight: .semibold))
                        .foregroundStyle(green)
                }
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, minHeight: keyHeight)
            .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
        }
        .buttonStyle(KeyboardButtonStyle(cornerRadius: KeyStyle.cornerRadius))
        .accessibilityAddTraits(chosen ? .isSelected : [])
    }
}
