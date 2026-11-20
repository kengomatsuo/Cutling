//
//  FillInForm.swift
//  Cutling
//
//  The blanks of a cutling, asked before it is copied (iPhone and Mac app)
//  or pasted (Mac picker). One field per blank, saved values one tap away,
//  and the finished text shown as it will paste.
//  Full account: docs/fill-ins.md
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct FillInForm: View {
    let cutling: Cutling
    /// "Copy" in the app, "Paste" in the Mac picker when it pastes directly.
    let actionTitle: LocalizedStringKey
    let onDone: (_ values: [String: String]) -> Void
    let onCancel: () -> Void

    @State private var values: [String: String] = [:]
    @FocusState private var focused: String?

    private var fields: [Placeholders.Field] { cutling.fillInFields }

    private var preview: String {
        cutling.filled(.now(values: values, clipboard: nil)).cutling.plainValue
    }

    var body: some View {
        #if os(iOS)
        NavigationStack {
            Form {
                ForEach(fields, id: \.key) { field in
                    Section(field.label) { fieldEditor(field) }
                }
                Section {
                    Text(preview)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .accessibilityIdentifier("fillInPreview")
                }
            }
            .navigationTitle(cutling.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(actionTitle, action: finish)
                        .accessibilityIdentifier("fillInDone")
                }
            }
        }
        .onAppear(perform: start)
        #else
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: cutling.icon)
                    .foregroundStyle(cutling.tintColor)
                Text(cutling.name)
                    .font(.headline)
                    .lineLimit(1)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(fields, id: \.key) { field in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(field.label)
                                .font(.subheadline.weight(.medium))
                            fieldEditor(field)
                        }
                    }
                    Text(preview)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 6))
                        .accessibilityIdentifier("fillInPreview")
                }
            }
            HStack {
                Spacer()
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Button(actionTitle, action: finish)
                    .keyboardShortcut(.defaultAction)
                    .accessibilityIdentifier("fillInDone")
            }
        }
        .padding(12)
        .onAppear(perform: start)
        #endif
    }

    @ViewBuilder
    private func fieldEditor(_ field: Placeholders.Field) -> some View {
        let binding = Binding(get: { values[field.key] ?? "" }, set: { values[field.key] = $0 })
        TextField(field.label, text: binding)
            .focused($focused, equals: field.key)
            .onSubmit { advance(from: field) }
            #if os(macOS)
            .textFieldStyle(.roundedBorder)
            #endif
            .accessibilityIdentifier("fillInField")
        let choices = FillInMemory.choices(for: field)
        if !choices.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(choices, id: \.self) { choice in
                        Button {
                            values[field.key] = choice
                            advance(from: field)
                        } label: {
                            Text(choice)
                                .lineLimit(1)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.quaternary, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func start() {
        // A choice field starts on its first option, so Return alone takes it.
        for field in fields where values[field.key] == nil {
            if field.options.count > 1 { values[field.key] = field.options[0] }
        }
        DispatchQueue.main.async { focused = fields.first?.key }
    }

    private func advance(from field: Placeholders.Field) {
        guard let index = fields.firstIndex(of: field) else { return }
        if index + 1 < fields.count {
            focused = fields[index + 1].key
        } else {
            finish()
        }
    }

    private func finish() {
        // An empty blank takes its default.
        var out = values
        for field in fields where (out[field.key] ?? "").isEmpty {
            out[field.key] = field.options.first ?? ""
        }
        FillInMemory.remember(out)
        onDone(out)
    }
}

extension CutlingPasteboard {
    /// Copies a cutling with its stamps dated, its blanks filled from `values`
    /// (nil leaves them as written) and the clipboard read in when it asks for it.
    @MainActor
    static func copyFilled(_ cutling: Cutling, values: [String: String]? = nil, plainOnly: Bool = false) {
        var clipboard: String?
        if cutling.placeholders?.usesClipboard == true {
            #if canImport(UIKit)
            clipboard = UIPasteboard.general.string
            #elseif canImport(AppKit)
            clipboard = NSPasteboard.general.string(forType: .string)
            #endif
        }
        copy(cutling.filled(.now(values: values, clipboard: clipboard ?? "")).cutling, plainOnly: plainOnly)
    }
}
