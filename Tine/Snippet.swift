//
//  Snippet.swift
//  Tine
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import Foundation

enum SnippetKind: String, Codable {
    case text
    case image
}

struct Snippet: Identifiable, Codable {
    var id: UUID
    var name: String
    var value: String
    var icon: String
    var kind: SnippetKind
    var imageFilename: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        value: String,
        icon: String,
        kind: SnippetKind = .text,
        imageFilename: String? = nil
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.icon = icon
        self.kind = kind
        self.imageFilename = imageFilename
    }
}
