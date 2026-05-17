//
//  CutlingAppEntity.swift
//  Cutling
//
//  AppEntity representation of a Cutling so the system can associate
//  indexed Spotlight items with an OpenIntent (and surface them in
//  Shortcuts / suggestions).
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents
import CoreSpotlight

struct CutlingAppEntity: AppEntity, IndexedEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Cutling")
    static var defaultQuery = CutlingEntityQuery()

    var id: UUID
    var name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct CutlingEntityQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [CutlingAppEntity] {
        let cutlings = await CutlingStore.shared.cutlings
        let ids = Set(identifiers)
        return cutlings
            .filter { ids.contains($0.id) }
            .map { CutlingAppEntity(id: $0.id, name: $0.name) }
    }

    func suggestedEntities() async throws -> [CutlingAppEntity] {
        await MainActor.run {
            CutlingStore.shared.cutlings
                .filter { !$0.isExpired }
                .prefix(10)
                .map { CutlingAppEntity(id: $0.id, name: $0.name) }
        }
    }
}
