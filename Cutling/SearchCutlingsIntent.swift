//
//  SearchCutlingsIntent.swift
//  Cutling
//
//  Returns an array of CutlingAppEntity matching a free-text query
//  across name and value. Returned entities can be piped into
//  OpenCutlingByIDIntent (Copy) or GetCutlingTextIntent (read value)
//  for chained Shortcuts workflows. Pairs the array with a dialog +
//  snippet view so standalone Siri / Shortcuts runs visibly surface
//  the results instead of silently completing.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents
import SwiftUI

struct SearchCutlingsIntent: AppIntent {
    static var title: LocalizedStringResource = "Search Cutlings"
    static var description = IntentDescription("Find cutlings whose name or contents match a search query.")

    @Parameter(title: "Query")
    var query: String

    init() {}

    init(query: String) {
        self.query = query
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<[CutlingAppEntity]> & ProvidesDialog & ShowsSnippetView {
        let store = CutlingStore.shared
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !needle.isEmpty else {
            return .result(
                value: [],
                dialog: IntentDialog(stringLiteral: String(localized: "No Results")),
                view: SearchResultsSnippetView(items: [])
            )
        }

        let matches = store.cutlings
            .filter { !$0.isExpired }
            .filter {
                $0.name.lowercased().contains(needle) ||
                $0.value.lowercased().contains(needle)
            }
            .prefix(25)

        let entities = matches.map { CutlingAppEntity(id: $0.id, name: $0.name) }
        let snippetItems = matches.map { cutling in
            CutlingSnippetItem(
                id: cutling.id,
                name: cutling.name,
                icon: cutling.icon,
                kind: cutling.kind,
                preview: cutling.kind == .image ? "" : cutling.value,
                entity: CutlingAppEntity(id: cutling.id, name: cutling.name)
            )
        }

        let dialogText = entities.isEmpty
            ? String(localized: "No Results")
            : String(localized: "\(entities.count) Cutlings")

        return .result(
            value: entities,
            dialog: IntentDialog(stringLiteral: dialogText),
            view: SearchResultsSnippetView(items: snippetItems)
        )
    }
}

struct SearchResultsSnippetView: View {
    let items: [CutlingSnippetItem]

    private var visibleItems: ArraySlice<CutlingSnippetItem> { items.prefix(8) }

    var body: some View {
        if items.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("No Results")
                    .font(.headline)
                Text("Try a different search term.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
        } else {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(visibleItems)) { item in
                    SearchResultRow(item: item)
                    if item.id != visibleItems.last?.id {
                        Divider()
                    }
                }
                if items.count > 8 {
                    Text("+\(items.count - 8)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)
                }
            }
            .padding()
        }
    }
}

private struct SearchResultRow: View {
    let item: CutlingSnippetItem

    var body: some View {
        HStack(spacing: 12) {
            Button(intent: ViewCutlingIntent(target: item.entity)) {
                HStack(spacing: 12) {
                    Image(systemName: item.kind == .image ? "photo" : item.icon)
                        .frame(width: 24)
                        .foregroundStyle(.tint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)
                            .foregroundStyle(.primary)
                        if !item.preview.isEmpty {
                            Text(item.preview)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(intent: CopyCutlingIntent(target: item.entity)) {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.vertical, 8)
    }
}
