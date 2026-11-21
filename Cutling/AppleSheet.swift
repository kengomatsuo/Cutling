//
//  AppleSheet.swift
//  Cutling
//
//  The layout Apple's own apps use on iOS 27 for "Welcome to" and "What's New" sheets,
//  measured from What's New in Calendar and Welcome to Reminders shot on the simulator
//  (docs/research/onboarding/apple/shots/sim): a left-aligned bold title, an optional grey
//  subtitle, rows of a tinted symbol beside a bold title and a grey line, and one
//  full-width Continue at the bottom. Used by What's New, Welcome Back and the setup welcome.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#if os(iOS)
import SwiftUI

struct AppleSheetRow: Identifiable {
    let symbol: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey
    var id: String { symbol }
}

struct AppleSheet<Footer: View>: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey? = nil
    let rows: [AppleSheetRow]
    let buttonTitle: LocalizedStringKey
    let action: () -> Void
    @ViewBuilder var footer: Footer

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AppleSheetHeader(title: title, subtitle: subtitle)
                    .padding(.bottom, 30)
                VStack(alignment: .leading, spacing: 26) {
                    ForEach(rows) { row in
                        AppleSheetRowView(row: row)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 36)
            .padding(.top, 56)
            .padding(.bottom, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 14) {
                footer
                AppleSheetButton(title: buttonTitle, action: action)
            }
            .padding(.horizontal, 36)
            .padding(.bottom, 12)
            .background(.background)
        }
    }
}

extension AppleSheet where Footer == EmptyView {
    init(title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, rows: [AppleSheetRow],
         buttonTitle: LocalizedStringKey = "Continue", action: @escaping () -> Void) {
        self.init(title: title, subtitle: subtitle, rows: rows, buttonTitle: buttonTitle, action: action) { EmptyView() }
    }
}

/// Title and grey subtitle, as Apple sets them at the top of its sheets.
struct AppleSheetHeader: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)
            if let subtitle {
                Text(subtitle)
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct AppleSheetRowView: View {
    let row: AppleSheetRow

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: row.symbol)
                .font(.system(size: 30))
                .foregroundStyle(.tint)
                .frame(width: 40)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(row.title).font(.headline)
                Text(row.detail)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// The one full-width button at the bottom of a sheet, in Cutling's prominent style.
struct AppleSheetButton: View {
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .modifier(ProminentCapsuleButton())
        .accessibilityIdentifier("sheetPrimaryButton")
    }
}

/// `.glassProminent` on iOS 26 and later, `.borderedProminent` before, as every Cutling sheet.
struct ProminentCapsuleButton: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.buttonStyle(.glassProminent)
        } else {
            content.buttonStyle(.borderedProminent).buttonBorderShape(.capsule)
        }
    }
}

// MARK: - What's New and Welcome Back

/// What a sheet for an existing user says: what changed in this version, or, after a long
/// absence, how Cutling works plus what changed.
enum WhatsNewKind {
    case update
    case welcomeBack

    /// Rows for changes people can see in this version. Fill-ins stay out while `FillIns.isOn` is off.
    static let newRows: [AppleSheetRow] = [
        AppleSheetRow(symbol: "square.stack.3d.up.fill", title: "Room for 1,000",
                      detail: "Save up to 1,000 texts and 50 images."),
        AppleSheetRow(symbol: "hand.tap.fill", title: "Every Key Types",
                      detail: "Tap a formatted cutling and it types like the rest. Touch and hold it to copy the formatting."),
    ]

    static let basicsRows: [AppleSheetRow] = [
        AppleSheetRow(symbol: "globe", title: "Switch to Cutling",
                      detail: "Touch and hold the globe key on your keyboard, then choose Cutling."),
        AppleSheetRow(symbol: "character.cursor.ibeam", title: "Tap to Type",
                      detail: "Tap a cutling and it's typed where you're writing."),
        AppleSheetRow(symbol: "square.and.arrow.down", title: "Save from Anywhere",
                      detail: "Share text, links or images to Cutling from any app."),
    ]
}

struct WhatsNewSheet: View {
    let kind: WhatsNewKind
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        switch kind {
        case .update:
            AppleSheet(title: "What's New in Cutling", subtitle: "More room, and every key types.",
                       rows: WhatsNewKind.newRows) { dismiss() }
        case .welcomeBack:
            AppleSheet(title: "Welcome Back to Cutling",
                       rows: WhatsNewKind.basicsRows + WhatsNewKind.newRows) { dismiss() }
        }
    }
}
#endif
