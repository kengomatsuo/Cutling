//
//  Cutling.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import CoreTransferable
import Darwin
import Foundation
import LinkPresentation
import NaturalLanguage
import SwiftUI
import UniformTypeIdentifiers
#if os(iOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif

// MARK: - Accessible Animation

/// Wraps `withAnimation`, substituting a simple cross-dissolve when Reduce Motion is enabled.
@MainActor func withAccessibleAnimation<Result>(_ animation: Animation = .default, _ body: () throws -> Result) rethrows -> Result {
    #if os(iOS)
    if unsafe UIAccessibility.isReduceMotionEnabled {
        return try withAnimation(.easeOut(duration: 0.15), body)
    }
    #endif
    #if os(macOS)
    if NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
        return try withAnimation(.easeOut(duration: 0.15), body)
    }
    #endif
    return try withAnimation(animation, body)
}

// MARK: - Developer Mode Detection

/// Detects if iOS Developer Mode is enabled on the device (iOS 16+).
/// This is an undocumented but working API used to detect if a user has enabled
/// Developer Mode in Settings > Privacy & Security > Developer Mode.
/// Source: https://github.com/apple/security-pcc/blob/main/CloudAttestation/CloudAttestation/DeviceMode.swift
var isDeveloperModeEnabled: Bool {
    var value = Int32(0)
    var size = MemoryLayout<Int32>.size
    return unsafe sysctlbyname("security.mac.amfi.developer_mode_status", &value, &size, nil, 0) == 0 && value == 1
}

// MARK: - Sensitive Content Detection

enum SensitiveContentType: String, CaseIterable, Sendable, Hashable {
    case creditCard
    case privateKey
    case apiKey
    case jwtToken
    case seedPhrase

    var warningMessage: String {
        switch self {
        case .creditCard:  return String(localized: "This looks like a payment card number. Cutling is not designed for secure storage of financial data.")
        case .privateKey:  return String(localized: "This looks like a private key or certificate. Store private keys in a secure keychain or vault.")
        case .apiKey:      return String(localized: "This looks like an API key or secret token. Avoid storing credentials outside a secure vault.")
        case .jwtToken:    return String(localized: "This looks like an authentication token. Tokens should be stored securely, not in a clipboard manager.")
        case .seedPhrase:  return String(localized: "This looks like a recovery phrase. Store seed phrases in a secure, offline location.")
        }
    }

    var dismissalKey: String { "warningsDisabled_\(rawValue)" }

    static func detect(in text: String) -> Set<SensitiveContentType> {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        var result = Set<SensitiveContentType>()

        let stripped = trimmed.replacingOccurrences(of: "[ \\-.]", with: "", options: .regularExpression)
        if stripped.allSatisfy(\.isNumber) && (13...19).contains(stripped.count) && isLuhnValid(stripped) {
            result.insert(.creditCard)
        }

        if trimmed.contains("-----BEGIN") && trimmed.lowercased().contains("private key") {
            result.insert(.privateKey)
        }

        let apiPrefixes = [
            "sk-", "sk_live_", "sk_test_", "rk_live_", "rk_test_",
            "ghp_", "gho_", "ghs_", "github_pat_",
            "AKIA", "xoxb-", "xoxp-", "xoxs-",
            "AIza", "glpat-", "GOCSPX-",
        ]
        if apiPrefixes.contains(where: { trimmed.hasPrefix($0) }) && trimmed.count >= 20 {
            result.insert(.apiKey)
        }

        let jwtParts = trimmed.split(separator: ".")
        if jwtParts.count == 3 &&
            jwtParts[0].hasPrefix("eyJ") &&
            jwtParts[1].hasPrefix("eyJ") &&
            jwtParts.allSatisfy({ $0.count >= 4 }) {
            result.insert(.jwtToken)
        }

        let words = trimmed.split(separator: " ").map(String.init)
        if (words.count == 12 || words.count == 24) &&
            trimmed.allSatisfy({ $0.isLetter || $0 == " " }) &&
            words.allSatisfy({ (3...8).contains($0.count) && $0 == $0.lowercased() }) {
            result.insert(.seedPhrase)
        }

        return result
    }

    private static func isLuhnValid(_ digits: String) -> Bool {
        var sum = 0
        for (i, ch) in digits.reversed().enumerated() {
            guard let digit = ch.wholeNumberValue else { return false }
            if i % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        return sum > 0 && sum % 10 == 0
    }
}

struct SensitiveContentWarning: View {
    let types: Set<SensitiveContentType>
    @State private var didHaptic = false

    private var visibleType: SensitiveContentType? {
        let allDisabled = UserDefaults.standard.bool(forKey: "warningsDisabled_all")
        return types.first { !allDisabled && !UserDefaults.standard.bool(forKey: $0.dismissalKey) }
    }

    var body: some View {
        if let type = visibleType {
            Section {
                Label {
                    Text(type.warningMessage)
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
                .font(.subheadline)
            }
            .transition(AsymmetricTransition(insertion: .scale(0.95).combined(with: .opacity), removal: .opacity))
            .task(id: type) {
                guard !didHaptic else { return }
                didHaptic = true
                #if os(iOS)
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                #endif
            }
        }
    }
}

enum CutlingKind: String, Codable, Sendable, Identifiable {
    case text
    case image

    var id: String { rawValue }
}

struct NewCutlingDraft: Identifiable, Equatable {
    let id = UUID()
    let kind: CutlingKind
    var name: String = ""
    var text: String = ""
    var imageData: Data? = nil
    var icon: String? = nil
    var color: String? = nil
    var inputTypeTriggers: [String]? = nil
    var expiresAt: Date? = nil
}

// MARK: - Cutling Drag & Drop Payload

extension UTType {
    static let cutling = UTType(exportedAs: "com.matsuokengo.Cutling.cutling")
}

/// Wire format for cutling drag-and-drop. The custom `.cutling` UTType lets us
/// preserve full metadata (name, icon, color, triggers, etc.) on round-trip,
/// while String/PNG proxy representations let other apps still receive the
/// underlying value or image.
struct CutlingPayload: Codable, Transferable {
    let cutling: Cutling
    let imageData: Data?

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .cutling)
        ProxyRepresentation { (payload: CutlingPayload) -> String in
            payload.cutling.value
        }
        DataRepresentation(exportedContentType: .png) { payload in
            guard let data = payload.imageData else {
                throw CocoaError(.featureUnsupported)
            }
            #if os(iOS)
            if let image = UIImage(data: data), let png = image.pngData() {
                return png
            }
            #endif
            #if os(macOS)
            if let image = NSImage(data: data),
               let tiff = image.tiffRepresentation,
               let rep = NSBitmapImageRep(data: tiff),
               let png = rep.representation(using: .png, properties: [:]) {
                return png
            }
            #endif
            return data
        }
    }
}

enum ActiveSheet: Identifiable, Equatable {
    case newCutling(NewCutlingDraft)
    case keyboardManager
    case keyboardSetup

    var id: String {
        switch self {
        case .newCutling(let draft):
            return "newCutling-\(draft.id)"
        case .keyboardManager:
            return "keyboardManager"
        case .keyboardSetup:
            return "keyboardSetup"
        }
    }
}

// MARK: - Input Type Triggers

/// User-facing input type categories that group related UIKeyboardType / UITextContentType values.
/// Each category maps to one or more raw trigger keys stored on the cutling.
enum InputTypeCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    case email
    case url
    case phoneNumber
    case name
    case address

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .email:       return String(localized: "Email")
        case .url:         return String(localized: "URL")
        case .phoneNumber: return String(localized: "Phone Number")
        case .name:        return String(localized: "Name")
        case .address:     return String(localized: "Address")
        }
    }

    var icon: String {
        switch self {
        case .email:       return "envelope"
        case .url:         return "link"
        case .phoneNumber: return "phone"
        case .name:        return "person"
        case .address:     return "mappin.and.ellipse"
        }
    }

    /// The raw trigger keys that belong to this category.
    var triggerKeys: Set<String> {
        switch self {
        case .email:
            return ["content:emailAddress", "keyboard:emailAddress"]
        case .url:
            return ["content:URL", "keyboard:URL", "keyboard:webSearch"]
        case .phoneNumber:
            return ["content:telephoneNumber", "keyboard:phonePad", "keyboard:namePhonePad", "keyboard:numberPad", "keyboard:decimalPad", "keyboard:numbersAndPunctuation"]
        case .name:
            return ["content:name", "content:givenName", "content:familyName", "content:nickname"]
        case .address:
            return ["content:streetAddressLine1", "content:streetAddressLine2", "content:addressCity", "content:addressState", "content:postalCode", "content:location"]
        }
    }

    /// Returns the category that contains the given trigger key, if any.
    static func category(for triggerKey: String) -> InputTypeCategory? {
        allCases.first { $0.triggerKeys.contains(triggerKey) }
    }

    /// Returns all categories whose trigger keys overlap with the given set.
    static func matchingCategories(for triggerKeys: Set<String>) -> [InputTypeCategory] {
        allCases.filter { !$0.triggerKeys.isDisjoint(with: triggerKeys) }
    }

    /// Detects which input type categories the given text likely represents.
    /// Uses NSDataDetector for robust detection of emails, URLs, phone numbers, and addresses.
    static func detect(from text: String) -> Set<InputTypeCategory> {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        var result = Set<InputTypeCategory>()

        // Email: simple heuristic — contains @ with a dot after it
        if let atIndex = trimmed.firstIndex(of: "@"),
           trimmed[atIndex...].contains(".") {
            result.insert(.email)
        }

        // URL, Phone, Address via NSDataDetector
        let detectorTypes: NSTextCheckingResult.CheckingType = [.link, .phoneNumber, .address]
        guard let detector = try? NSDataDetector(types: detectorTypes.rawValue) else { return result }
        let range = NSRange(trimmed.startIndex..., in: trimmed)
        let matches = detector.matches(in: trimmed, range: range)

        for match in matches {
            if match.resultType == .link {
                if let url = match.url, url.scheme == "mailto" {
                    result.insert(.email)
                } else {
                    result.insert(.url)
                }
            } else if match.resultType == .phoneNumber {
                result.insert(.phoneNumber)
            } else if match.resultType == .address {
                result.insert(.address)
            }
        }

        // Name detection via NLTagger
        if result.isEmpty {
            let tagger = NLTagger(tagSchemes: [.nameType])
            tagger.string = trimmed
            let tagRange = trimmed.startIndex..<trimmed.endIndex
            let tags = tagger.tags(in: tagRange, unit: .word, scheme: .nameType, options: [.omitPunctuation, .omitWhitespace, .joinNames])
            for (tag, _) in tags {
                if tag == .personalName {
                    result.insert(.name)
                    break
                }
            }
        }

        return result
    }

    struct Suggestion {
        var icon: String
        var name: String
        var triggers: Set<String>
        var categories: Set<InputTypeCategory>
    }

    static func suggest(from text: String, defaultIcon: String = "document", defaultName: String = "") -> Suggestion {
        let detected = detect(from: text)
        return Suggestion(
            icon: detected.first?.icon ?? defaultIcon,
            name: detected.first?.displayName ?? defaultName,
            triggers: Set(detected.flatMap { $0.triggerKeys }),
            categories: detected
        )
    }

    static func fetchURLTitle(from text: String) async -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return nil }
        let range = NSRange(trimmed.startIndex..., in: trimmed)
        guard let match = detector.firstMatch(in: trimmed, range: range),
              let url = match.url,
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme) else { return nil }
        let provider = LPMetadataProvider()
        provider.shouldFetchSubresources = false
        provider.timeout = 5
        guard let metadata = try? await provider.startFetchingMetadata(for: url),
              let title = metadata.title, !title.isEmpty else { return nil }
        return title
    }

    #if os(iOS)
    /// Builds the set of active trigger keys from the current text document proxy state.
    static func activeTriggerKeys(keyboardType: UIKeyboardType, textContentType: UITextContentType?) -> Set<String> {
        // Exclude password fields entirely
        if let ct = textContentType, ct == .password || ct == .newPassword {
            return []
        }

        var keys = Set<String>()

        // Map UIKeyboardType to trigger keys
        switch keyboardType {
        case .emailAddress:             keys.insert("keyboard:emailAddress")
        case .URL:                      keys.insert("keyboard:URL")
        case .phonePad:                 keys.insert("keyboard:phonePad")
        case .namePhonePad:             keys.insert("keyboard:namePhonePad")
        case .numberPad:                keys.insert("keyboard:numberPad")
        case .decimalPad:               keys.insert("keyboard:decimalPad")
        case .numbersAndPunctuation:    keys.insert("keyboard:numbersAndPunctuation")
        case .webSearch:                keys.insert("keyboard:webSearch")
        default: break
        }

        // Map UITextContentType to trigger keys
        if let ct = textContentType {
            switch ct {
            case .emailAddress:         keys.insert("content:emailAddress")
            case .URL:                  keys.insert("content:URL")
            case .telephoneNumber:      keys.insert("content:telephoneNumber")
            case .name:                 keys.insert("content:name")
            case .givenName:            keys.insert("content:givenName")
            case .familyName:           keys.insert("content:familyName")
            case .nickname:             keys.insert("content:nickname")
            case .streetAddressLine1:   keys.insert("content:streetAddressLine1")
            case .streetAddressLine2:   keys.insert("content:streetAddressLine2")
            case .addressCity:          keys.insert("content:addressCity")
            case .addressState:         keys.insert("content:addressState")
            case .postalCode:           keys.insert("content:postalCode")
            case .location:             keys.insert("content:location")
            default: break
            }
        }

        return keys
    }
    #endif
}

struct Cutling: Identifiable, Codable, Hashable, Sendable {
    var id: UUID
    var name: String
    var value: String
    var icon: String
    var kind: CutlingKind
    var imageFilename: String?
    var sortOrder: Int
    var createdDate: Date
    var lastModifiedDate: Date
    var expiresAt: Date?
    var color: String?
    var inputTypeTriggers: [String]?
    
    /// The input type categories this cutling is assigned to.
    var assignedCategories: Set<InputTypeCategory> {
        guard let triggers = inputTypeTriggers, !triggers.isEmpty else { return [] }
        return Set(triggers.compactMap { InputTypeCategory.category(for: $0) })
    }

    /// Whether this cutling has expired and should be purged.
    var isExpired: Bool {
        guard let expiresAt else { return false }
        return expiresAt <= Date()
    }

    /// The app's brand teal, used as the default tint when no color is stored.
    /// Defined here so it resolves identically in the main app and the keyboard extension
    /// (where .accentColor falls back to system blue).
    static let defaultTint = Color(
        red: Double(0x00) / 255,
        green: Double(0xBE) / 255,
        blue: Double(0x86) / 255
    )

    /// Resolves the stored color key to a SwiftUI Color, falling back to the app tint.
    var tintColor: Color {
        guard let color else { return Self.defaultTint }
        if let paletteColor = Self.palette[color] { return paletteColor }
        if let hexColor = Self.color(fromHex: color) { return hexColor }
        return Self.defaultTint
    }

    static func color(fromHex hex: String) -> Color? {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard cleaned.count == 6, let rgbValue = UInt64(cleaned, radix: 16) else { return nil }
        return Color(
            red: Double((rgbValue >> 16) & 0xFF) / 255,
            green: Double((rgbValue >> 8) & 0xFF) / 255,
            blue: Double(rgbValue & 0xFF) / 255
        )
    }

    static func hexString(from color: Color) -> String {
        let resolved = color.resolve(in: EnvironmentValues())
        func hexByte(_ value: Float) -> String {
            let byte = max(0, min(255, Int(round(Double(value) * 255))))
            let hex = String(byte, radix: 16, uppercase: true)
            return byte < 16 ? "0" + hex : hex
        }
        return hexByte(resolved.red) + hexByte(resolved.green) + hexByte(resolved.blue)
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

    /// Returns a localized display name for a color key (e.g. "red" → "Red" in English, "Rot" in German).
    static func localizedColorName(for key: String?) -> String {
        guard let key else { return String(localized: "Default") }
        switch key {
        case "red":    return String(localized: "Red")
        case "orange": return String(localized: "Orange")
        case "yellow": return String(localized: "Yellow")
        case "green":  return String(localized: "Green")
        case "mint":   return String(localized: "Mint")
        case "teal":   return String(localized: "Teal")
        case "cyan":   return String(localized: "Cyan")
        case "blue":   return String(localized: "Blue")
        case "indigo": return String(localized: "Indigo")
        case "purple": return String(localized: "Purple")
        case "pink":   return String(localized: "Pink")
        case "brown":  return String(localized: "Brown")
        default:       return key.capitalized
        }
    }
    
    nonisolated init(
        id: UUID = UUID(),
        name: String,
        value: String,
        icon: String,
        kind: CutlingKind = .text,
        imageFilename: String? = nil,
        sortOrder: Int = 0,
        createdDate: Date = Date(),
        lastModifiedDate: Date = Date(),
        expiresAt: Date? = nil,
        color: String? = nil,
        inputTypeTriggers: [String]? = nil
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.icon = icon
        self.kind = kind
        self.imageFilename = imageFilename
        self.sortOrder = sortOrder
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
        self.expiresAt = expiresAt
        self.color = color
        self.inputTypeTriggers = inputTypeTriggers
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
        let decodedLastModified = try container.decodeIfPresent(Date.self, forKey: .lastModifiedDate) ?? Date()
        lastModifiedDate = decodedLastModified
        createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? decodedLastModified
        expiresAt = try container.decodeIfPresent(Date.self, forKey: .expiresAt)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        inputTypeTriggers = try container.decodeIfPresent([String].self, forKey: .inputTypeTriggers)
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
