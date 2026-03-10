//
//  Cutling.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import Foundation
import SwiftUI

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
    var expiresAt: Date?
    var color: String?
    
    /// Whether this cutling has expired and should be purged.
    var isExpired: Bool {
        guard let expiresAt else { return false }
        return expiresAt <= Date()
    }

    /// The app's brand teal, used as the default tint when no color is stored.
    /// Defined here so it resolves identically in the main app and the keyboard extension
    /// (where .accentColor falls back to system blue).
    static let defaultTint = Color(
        red: Double(0x22) / 255,
        green: Double(0xA9) / 255,
        blue: Double(0x8D) / 255
    )

    /// Resolves the stored color key to a SwiftUI Color, falling back to the app tint.
    var tintColor: Color {
        guard let color else { return Self.defaultTint }
        return Self.palette[color] ?? Self.defaultTint
    }

    static let palette: [String: Color] = [
        "red": .red,
        "orange": .orange,
        "yellow": .yellow,
        "green": .green,
        "mint": .mint,
        "teal": .teal,
        "cyan": .cyan,
        "blue": .blue,
        "indigo": .indigo,
        "purple": .purple,
        "pink": .pink,
        "brown": .brown,
    ]

    /// Ordered keys for display in the color picker.
    static let paletteKeys: [String] = [
        "red", "orange", "yellow", "green", "mint", "teal",
        "cyan", "blue", "indigo", "purple", "pink", "brown",
    ]
    
    nonisolated init(
        id: UUID = UUID(),
        name: String,
        value: String,
        icon: String,
        kind: CutlingKind = .text,
        imageFilename: String? = nil,
        sortOrder: Int = 0,
        lastModifiedDate: Date = Date(),
        expiresAt: Date? = nil,
        color: String? = nil
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.icon = icon
        self.kind = kind
        self.imageFilename = imageFilename
        self.sortOrder = sortOrder
        self.lastModifiedDate = lastModifiedDate
        self.expiresAt = expiresAt
        self.color = color
    }
    
    /// Decodes gracefully from older data that may lack sortOrder/lastModifiedDate/expiresAt/color.
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
        expiresAt = try container.decodeIfPresent(Date.self, forKey: .expiresAt)
        color = try container.decodeIfPresent(String.self, forKey: .color)
    }
}

// MARK: - Recently Deleted Wrapper

/// A cutling that was soft-deleted and kept for 30 days before permanent removal.
struct DeletedCutling: Identifiable, Codable, Hashable {
    var cutling: Cutling
    var deletedAt: Date

    var id: UUID { cutling.id }

    /// How long deleted cutlings are retained before permanent removal.
    static let retentionInterval: TimeInterval = 30 * 24 * 60 * 60 // 30 days

    /// Whether this deleted cutling has exceeded the retention period.
    var isPermanentlyExpired: Bool {
        Date().timeIntervalSince(deletedAt) >= Self.retentionInterval
    }

    /// The date at which this cutling will be permanently removed.
    var permanentDeletionDate: Date {
        deletedAt.addingTimeInterval(Self.retentionInterval)
    }

    /// Days remaining before permanent deletion.
    var daysRemaining: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: permanentDeletionDate).day ?? 0)
    }
}
