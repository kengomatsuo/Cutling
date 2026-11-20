//
//  FillInPanel.swift
//  CutlingKeyboard
//
//  A cutling with fill-ins is typed piece by piece: Cutling types up to a
//  blank and waits. The user types the blank with their own keyboard (any
//  language, autocorrect, dictation), or taps a saved value, then Next types
//  the rest. A keyboard can't open the system keyboard for a field of its
//  own, so the blank is filled in the app's own text field.
//  Full account: docs/fill-ins.md
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI
import UIKit

/// One cutling being typed with fill-ins. Saved between keyboard switches,
/// because iOS may tear the keyboard down while the user types in another one.
struct FillSession: Codable, Equatable {
    var cutlingID: UUID
    var title: String
    /// What is still to type.
    var pending: [Placeholders.Chunk]
    /// The blank waiting for the user, if any.
    var field: Placeholders.Field?
    var values: [String: String] = [:]
    var fieldNumber = 0
    var fieldCount: Int
    /// The end of what Cutling last typed, to find what the user typed after it.
    var tail = ""
    /// Characters typed since `{cursor}`; nil before it, or when a typed value could not be read.
    var afterCursor: Int?
    var cursorLost = false
    var startedAt = Date()

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

    /// What the user typed after Cutling's last text, read from the text before the cursor.
    func typedValue(in context: String) -> String? {
        guard !tail.isEmpty else { return nil }
        // The host may hand over only part of the text; a shorter end still finds the spot.
        for length in stride(from: tail.count, through: min(tail.count, 4), by: -4) {
            let probe = String(tail.suffix(length))
            if let range = context.range(of: probe, options: .backwards) {
                return String(context[range.upperBound...])
            }
        }
        return nil
    }
}

struct FillInPanel: View {
    let session: FillSession
    let field: Placeholders.Field
    let canPaste: Bool
    let onPick: (String) -> Void
    let onNext: () -> Void
    let onCancel: () -> Void
    let bundle: Bundle?

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isLast: Bool {
        !session.pending.contains { if case .field(let f) = $0 { session.values[f.key] == nil && f.key != field.key } else { false } }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 30, height: 30)
                        .background(KeyStyle.keyColor, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Cancel", bundle: bundle))
                .accessibilityIdentifier("fillInCancel")

                Text(session.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer(minLength: 4)
                if session.fieldCount > 1 {
                    Text("\(session.fieldNumber) of \(session.fieldCount)", bundle: bundle)
                        .font(.system(size: 13).monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }

            Text(field.label)
                .font(.system(size: horizontalSizeClass == .regular ? 24 : 20, weight: .semibold))
                .lineLimit(1)
                .accessibilityIdentifier("fillInLabel")
            Label {
                Text("Type it with your keyboard", bundle: bundle)
            } icon: {
                Image(systemName: "globe")
            }
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .lineLimit(2)

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        if canPaste {
                            chip(Label { Text("Paste", bundle: bundle) } icon: { Image(systemName: "doc.on.clipboard") }) {
                                if let text = UIPasteboard.general.string, !text.isEmpty { onPick(text) }
                            }
                            .accessibilityIdentifier("fillInPaste")
                        }
                        ForEach(FillInMemory.choices(for: field), id: \.self) { value in
                            chip(Text(value).lineLimit(1)) { onPick(value) }
                                .accessibilityIdentifier("fillInChoice")
                        }
                    }
                }
                Button(action: onNext) {
                    HStack(spacing: 4) {
                        Text(isLast ? "Done" : "Next", bundle: bundle)
                        if !isLast { Image(systemName: "chevron.right").accessibilityHidden(true) }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 40)
                    .background(Color(hex: 0x01be86), in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("fillInNext")
            }
        }
        .padding(.horizontal, KeyStyle.horizontalPadding + 6)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityIdentifier("fillInPanel")
    }

    private func chip<Content: View>(_ content: Content, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            content
                .font(.system(size: 15))
                .padding(.horizontal, 12)
                .frame(height: 40)
                .frame(maxWidth: 180)
                .background(KeyStyle.keyColor, in: Capsule())
        }
        .buttonStyle(KeyboardButtonStyle())
    }
}
