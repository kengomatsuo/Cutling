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
#if os(iOS)
import UIKit
#endif

/// What a promo take's cutlings say in one language. All of it is invented.
private struct PromoSeedCopy {
    typealias Entry = (name: String, value: String)
    let bank, address, notes, deploy, email, signature, wifi, bio, phone, booking, link: Entry
    let history: [String]

    static func forLanguage(_ language: String) -> PromoSeedCopy {
        switch language {
        case "id": indonesian
        case "ja": japanese
        default: english
        }
    }

    private static let english = PromoSeedCopy(
        bank: ("Bank Account", "IBAN: DE89 3704 0044 0532 0130 00"),
        address: ("Home Address", "123 Main Street, Apt 4B\nNew York, NY 10001"),
        notes: ("Meeting Notes", "**Agenda** for Friday, see [the brief](https://example.com/brief)"),
        deploy: ("Deploy", "git push origin main"),
        email: ("Work Email", "alex@example.com"),
        signature: ("Signature", "Best regards,\nAlex Chen\nalex@example.com"),
        wifi: ("Wi-Fi Password", "c0ff33-Sh0p-2024!"),
        bio: ("Social Bio", "Designer & developer. Building things that make life simpler."),
        phone: ("Phone Number", "+1 (555) 234-5678"),
        booking: ("Booking Ref", "FLT-2026-XKCD42"),
        link: ("Meeting Link", "https://meet.example.com/alex-weekly"),
        history: ["1Z 999 AA1 01 2345 6784", "+1 (555) 014-2233", "alex@example.com", "https://example.com/brief", "DE89 3704 0044 0532 0130 00"]
    )

    private static let indonesian = PromoSeedCopy(
        bank: ("Rekening BCA", "BCA 1234567890 a.n. Rangga Wirawan"),
        address: ("Alamat Rumah", "Jl. Flamboyan Asri II No. 17, RT 05/RW 08\nRawamangun, Jakarta Timur 13220"),
        notes: ("Catatan Rapat", "**Agenda** rapat Jumat, cek [briefnya di sini](https://example.com/brief)"),
        deploy: ("Deploy", "git push origin main"),
        email: ("Email Kerja", "rangga@example.com"),
        signature: ("Tanda Tangan", "Salam,\nRangga Wirawan\nrangga@example.com"),
        wifi: ("Password Wi-Fi", "k0pi-Senja-2024!"),
        bio: ("Bio", "Desainer yang doyan ngopi dan bikin hal-hal jadi lebih simpel."),
        phone: ("Nomor HP", "0812-0000-0000"),
        booking: ("Kode Booking", "FLT-2026-XKCD42"),
        link: ("Link Meeting", "https://meet.example.com/rangga-mingguan"),
        history: ["JNE 0000 1234 5678", "0812-0000-0000", "rangga@example.com", "https://example.com/brief", "BCA 1234567890"]
    )

    private static let japanese = PromoSeedCopy(
        bank: ("振込先", "三菱UFJ銀行 渋谷支店\n普通 1234567 タナカ タロウ"),
        address: ("住所", "〒154-0015 東京都世田谷区桜新町9-12-3\nメゾンひなた 305号室"),
        notes: ("議事メモ", "**金曜の議題**は[こちらの資料](https://example.com/brief)をご確認ください"),
        deploy: ("デプロイ", "git push origin main"),
        email: ("仕事のメール", "taro@example.com"),
        signature: ("署名", "よろしくお願いいたします。\n田中 太郎\ntaro@example.com"),
        wifi: ("Wi-Fiパスワード", "k0ban-Cafe-2024!"),
        bio: ("自己紹介", "デザイナー。暮らしをシンプルにするものを作っています。"),
        phone: ("電話番号", "090-0000-0000"),
        booking: ("予約番号", "FLT-2026-XKCD42"),
        link: ("会議リンク", "https://meet.example.com/tanaka-weekly"),
        history: ["ヤマト 0000-1234-5678", "090-0000-0000", "taro@example.com", "https://example.com/brief", "〒154-0015 東京都世田谷区桜新町9-12-3"]
    )
}

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

    /// A promo take's seed, in the language its viewer reads: `-PROMO_LANG id|en|ja`.
    /// `-PROMO_WITHOUT_BANK` leaves the bank card out and keeps the grid short, for the take that saves it.
    /// `-PROMO_CLIP` puts the bank text on the clipboard, written by this app so
    /// "Paste from Clipboard" raises no paste prompt on camera.
    /// Every name, number and address is made up.
    func seedForPromo() {
        let defaults = UserDefaults.standard
        let language = defaults.string(forKey: "PROMO_LANG") ?? Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
        let copy = PromoSeedCopy.forLanguage(language)
        let arguments = ProcessInfo.processInfo.arguments
        var seeded = [
            Cutling(name: copy.bank.name, value: copy.bank.value, icon: "banknote.fill", kind: .text, sortOrder: 0, color: "green"),
            Cutling(name: copy.address.name, value: copy.address.value, icon: "house.fill", kind: .text, sortOrder: 1, color: "blue", inputTypeTriggers: ["content:streetAddressLine1", "content:postalCode"]),
            Cutling(name: copy.notes.name, value: copy.notes.value, icon: "textformat", sortOrder: 2, color: "yellow", format: .rich),
            Cutling(name: copy.deploy.name, value: copy.deploy.value, icon: "chevron.left.forwardslash.chevron.right", sortOrder: 3, color: "brown", format: .code),
            Cutling(name: copy.email.name, value: copy.email.value, icon: "at", sortOrder: 4, color: "cyan", inputTypeTriggers: ["content:emailAddress", "keyboard:emailAddress"]),
            Cutling(name: copy.signature.name, value: copy.signature.value, icon: "envelope.fill", kind: .text, sortOrder: 5, color: "purple", inputTypeTriggers: ["content:emailAddress"]),
            Cutling(name: copy.wifi.name, value: copy.wifi.value, icon: "wifi", kind: .text, sortOrder: 6, color: "orange"),
            Cutling(name: copy.bio.name, value: copy.bio.value, icon: "person.crop.circle.fill", kind: .text, sortOrder: 7, color: "pink"),
            Cutling(name: copy.phone.name, value: copy.phone.value, icon: "phone.fill", kind: .text, sortOrder: 8, color: "teal", inputTypeTriggers: ["content:telephoneNumber"]),
            Cutling(name: copy.booking.name, value: copy.booking.value, icon: "airplane", kind: .text, sortOrder: 9, color: "indigo"),
            Cutling(name: copy.link.name, value: copy.link.value, icon: "video.fill", kind: .text, sortOrder: 10, color: "red", inputTypeTriggers: ["content:URL"])
        ]
        if arguments.contains("-PROMO_WITHOUT_BANK") { seeded = Array(seeded.dropFirst().prefix(6)) }
        cutlings = seeded
        save()
        #if os(iOS)
        if arguments.contains("-PROMO_CLIP") { UIPasteboard.general.string = copy.bank.value }
        #endif
    }

    #if os(macOS)
    /// The Mac History tab of a promo take, in that take's language.
    func seedHistoryForPromo() {
        historyCutlings.removeAll()
        let language = UserDefaults.standard.string(forKey: "PROMO_LANG") ?? "en"
        for text in PromoSeedCopy.forLanguage(language).history { appendHistoryText(text) }
    }
    #endif

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
