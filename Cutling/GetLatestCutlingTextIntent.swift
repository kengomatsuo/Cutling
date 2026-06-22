//
//  GetLatestCutlingTextIntent.swift
//  Cutling
//
//  Returns the value of the most recently modified text cutling. Pairs the
//  string return value with a snippet view that surfaces the icon, name,
//  preview, and Copy / View actions so the result is actually usable when
//  the intent is run standalone instead of being chained into another
//  Shortcut action.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents
import SwiftUI

struct GetLatestCutlingTextIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Latest Cutling"
    static var description = IntentDescription("Get the text from your most recently saved cutling.")

    init() {}

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog & ShowsSnippetView {
        let store = CutlingStore.shared
        let latest = store.cutlings
            .filter { $0.kind == .text && !$0.isExpired }
            .max(by: { $0.lastModifiedDate < $1.lastModifiedDate })

        guard let latest else {
            return .result(
                value: "",
                dialog: IntentDialog(stringLiteral: String(localized: "No Cutlings Yet")),
                view: LatestCutlingSnippetView(item: nil)
            )
        }

        let item = CutlingSnippetItem(
            id: latest.id,
            name: latest.name,
            icon: latest.icon,
            kind: latest.kind,
            preview: latest.value,
            entity: CutlingAppEntity(id: latest.id, name: latest.name)
        )

        return .result(
            value: latest.value,
            dialog: IntentDialog(stringLiteral: latest.value),
            view: LatestCutlingSnippetView(item: item)
        )
    }
}

struct LatestCutlingSnippetView: View {
    let item: CutlingSnippetItem?

    var body: some View {
        if let item {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: item.icon)
                        .font(.title2)
                        .foregroundStyle(.tint)
                        .frame(width: 32, height: 32)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.headline)
                            .lineLimit(1)
                        Text(item.preview)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(4)
                    }
                    Spacer(minLength: 0)
                }

                HStack(spacing: 8) {
                    Button(intent: CopyCutlingIntent(target: item.entity)) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(intent: ViewCutlingIntent(target: item.entity)) {
                        Label("Open", systemImage: "arrow.up.right.square")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        } else {
            VStack(spacing: 8) {
                Image(systemName: "tray")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("No Cutlings Yet")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}

struct CutlingSnippetItem: Identifiable {
    let id: UUID
    let name: String
    let icon: String
    let kind: CutlingKind
    let preview: String
    let entity: CutlingAppEntity
}
