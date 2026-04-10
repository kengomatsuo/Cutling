//
//  SnapshotSeedData.swift
//  Cutling
//
//  Provides visually appealing sample data for App Store screenshots.
//  Only loaded when the app is launched with -SNAPSHOT_MODE.
//

import Foundation

#if DEBUG
extension CutlingStore {
    /// Seeds the store with sample cutlings for screenshot automation.
    func seedForSnapshots() {
        // Clear any existing data first
        cutlings.removeAll()

        let samples: [Cutling] = [
            Cutling(
                name: String(localized: "Home Address", comment: "Snapshot seed data"),
                value: String(localized: "123 Main Street, Apt 4B\nNew York, NY 10001", comment: "Snapshot seed data"),
                icon: "house.fill",
                kind: .text,
                sortOrder: 0,
                color: "blue",
                inputTypeTriggers: ["content:streetAddressLine1", "content:postalCode"]
            ),
            Cutling(
                name: String(localized: "Email Signature", comment: "Snapshot seed data"),
                value: String(localized: "Best regards,\nAlex Chen\nalex@example.com", comment: "Snapshot seed data"),
                icon: "envelope.fill",
                kind: .text,
                sortOrder: 1,
                color: "purple",
                inputTypeTriggers: ["content:emailAddress"]
            ),
            Cutling(
                name: String(localized: "Bank Account", comment: "Snapshot seed data"),
                value: String(localized: "IBAN: DE89 3704 0044 0532 0130 00", comment: "Snapshot seed data"),
                icon: "banknote.fill",
                kind: .text,
                sortOrder: 2,
                color: "green"
            ),
            Cutling(
                name: String(localized: "Wi-Fi Password", comment: "Snapshot seed data"),
                value: "c0ff33-Sh0p-2024!",
                icon: "wifi",
                kind: .text,
                sortOrder: 3,
                color: "orange"
            ),
            Cutling(
                name: String(localized: "Social Bio", comment: "Snapshot seed data"),
                value: String(localized: "Designer & developer. Building things that make life simpler.", comment: "Snapshot seed data"),
                icon: "person.crop.circle.fill",
                kind: .text,
                sortOrder: 4,
                color: "pink"
            ),
            Cutling(
                name: String(localized: "Phone Number", comment: "Snapshot seed data"),
                value: "+1 (555) 234-5678",
                icon: "phone.fill",
                kind: .text,
                sortOrder: 5,
                color: "teal",
                inputTypeTriggers: ["content:telephoneNumber"]
            ),
            Cutling(
                name: String(localized: "Booking Ref", comment: "Snapshot seed data"),
                value: "FLT-2026-XKCD42",
                icon: "airplane",
                kind: .text,
                sortOrder: 6,
                color: "indigo"
            ),
            Cutling(
                name: String(localized: "Meeting Link", comment: "Snapshot seed data"),
                value: "https://meet.example.com/alex-weekly",
                icon: "video.fill",
                kind: .text,
                sortOrder: 7,
                color: "red",
                inputTypeTriggers: ["content:URL"]
            ),
        ]

        cutlings = samples
        save()
    }
}
#endif
