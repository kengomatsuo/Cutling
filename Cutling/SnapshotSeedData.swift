//
//  SnapshotSeedData.swift
//  Cutling
//
//  Provides visually appealing sample data for App Store screenshots.
//  Only loaded when the app is launched with -SNAPSHOT_MODE.
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import Foundation

#if DEBUG
extension CutlingStore {
    /// One cutling per format, for FormattingUITests.
    func seedForFormatTests() {
        cutlings = [
            Cutling(name: "Rich", value: "**Bold** and [link](https://example.com)", icon: "textformat", sortOrder: 0, format: .rich),
            Cutling(name: "Code", value: "print(\"a_b\")", icon: "chevron.left.forwardslash.chevron.right", sortOrder: 1, format: .code),
            Cutling(name: "Plain", value: "Hello", icon: "document", sortOrder: 2),
            // Saved before formats existed: no stored format, detected as code.
            Cutling(name: "Legacy", value: "def greet():\n    return \"hi\"", icon: "document", sortOrder: 3)
        ]
        save()
    }

    /// The screenshot set plus one Formatted and one Code cutling, for promo takes.
    func seedForPromo() {
        seedForSnapshots()
        if let index = cutlings.firstIndex(where: { $0.name == "Email Signature" }) { cutlings[index].name = "Signature" }
        cutlings += [
            Cutling(name: "Work Email", value: "alex@example.com", icon: "at", sortOrder: 10, color: "cyan", inputTypeTriggers: ["content:emailAddress", "keyboard:emailAddress"]),
            Cutling(name: "Meeting Notes", value: "**Agenda** for Friday, see [the brief](https://example.com/brief)", icon: "textformat", sortOrder: 8, color: "yellow", format: .rich),
            Cutling(name: "Deploy", value: "git push origin main", icon: "chevron.left.forwardslash.chevron.right", sortOrder: 9, color: "brown", format: .code)
        ]
        // Both new ones sit in the keyboard's first rows.
        let first = ["Meeting Notes", "Deploy", "Work Email", "Home Address", "Signature"]
        cutlings.sort { (first.firstIndex(of: $0.name) ?? 99, $0.sortOrder) < (first.firstIndex(of: $1.name) ?? 99, $1.sortOrder) }
        for index in cutlings.indices { cutlings[index].sortOrder = index }
        save()
    }

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

    #if os(macOS)
    /// Language-neutral clipboard history for the Mac History frame.
    func seedHistoryForSnapshots() {
        historyCutlings.removeAll()
        for text in [
            "1Z 999 AA1 01 2345 6784",
            "+1 (555) 014-2233",
            "alex@example.com",
            "https://cutling.matsuokengo.com",
            "DE89 3704 0044 0532 0130 00",
        ] {
            appendHistoryText(text)
        }
    }
    #endif
}

#endif
