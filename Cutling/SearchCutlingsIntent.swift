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
        let previewItems = matches.map {
            SearchResultsSnippetView.Item(id: $0.id, name: $0.name, icon: $0.icon, kind: $0.kind)
        }

        let dialogText = entities.isEmpty
            ? String(localized: "No Results")
            : String(localized: "\(entities.count) Cutlings")

        return .result(
            value: entities,
            dialog: IntentDialog(stringLiteral: dialogText),
            view: SearchResultsSnippetView(items: previewItems)
        )
    }
}

struct SearchResultsSnippetView: View {
    struct Item: Identifiable {
        let id: UUID
        let name: String
        let icon: String
        let kind: CutlingKind
    }

    let items: [Item]

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
                ForEach(items.prefix(8)) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.kind == .image ? "photo" : item.icon)
                            .frame(width: 22)
                            .foregroundStyle(.tint)
                        Text(item.name)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 8)
                    if item.id != items.prefix(8).last?.id {
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
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}
