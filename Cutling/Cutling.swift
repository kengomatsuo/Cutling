//
//  Cutling.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import Foundation

enum CutlingKind: String, Codable, Sendable {
    case text
    case image
}

struct Cutling: Identifiable, Codable, Hashable, Sendable {
    var id: UUID
    var name: String
    var value: String
    var icon: String
    var kind: CutlingKind
    var imageFilename: String?
    var sortOrder: Int
    var lastModifiedDate: Date
    
    nonisolated init(
        id: UUID = UUID(),
        name: String,
        value: String,
        icon: String,
        kind: CutlingKind = .text,
        imageFilename: String? = nil,
        sortOrder: Int = 0,
        lastModifiedDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.icon = icon
        self.kind = kind
        self.imageFilename = imageFilename
        self.sortOrder = sortOrder
        self.lastModifiedDate = lastModifiedDate
    }
    
    /// Decodes gracefully from older data that may lack sortOrder/lastModifiedDate.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        value = try container.decode(String.self, forKey: .value)
        icon = try container.decode(String.self, forKey: .icon)
        kind = try container.decode(CutlingKind.self, forKey: .kind)
        imageFilename = try container.decodeIfPresent(String.self, forKey: .imageFilename)
        sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
        lastModifiedDate = try container.decodeIfPresent(Date.self, forKey: .lastModifiedDate) ?? Date()
    }
}
