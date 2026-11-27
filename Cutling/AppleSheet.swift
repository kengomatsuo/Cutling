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

/// One page in Apple's sheet layout: title (and grey subtitle) at the top left, the page's
/// content, and one full-width button at the bottom with an optional link over it. Every page
/// of the setup guide and every sheet uses it, so title, background, rows and button sit in
/// the same place on each.
struct AppleSheetPage<Content: View, Footer: View>: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey? = nil
    /// 56 for a sheet of its own; 8 inside a navigation stack, whose bar gives the rest.
    var topPadding: CGFloat = 56
    let buttonTitle: LocalizedStringKey
    var buttonEnabled = true
    var buttonID = "sheetPrimaryButton"
    /// Keeps the button off until the page has been scrolled to its end.
    var requiresReadingToEnd = false
    /// Accessibility identifier of the scrolling area, for UI tests (not the whole page, which
    /// would override the button's own).
    var scrollID: String? = nil
    let action: () -> Void
    let content: Content
    let footer: Footer
    @State private var readToEnd = false

    init(title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, topPadding: CGFloat = 56,
         buttonTitle: LocalizedStringKey, buttonEnabled: Bool = true, buttonID: String = "sheetPrimaryButton",
         requiresReadingToEnd: Bool = false, scrollID: String? = nil, action: @escaping () -> Void,
         @ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer) {
        self.scrollID = scrollID
        self.title = title
        self.subtitle = subtitle
        self.topPadding = topPadding
        self.buttonTitle = buttonTitle
        self.buttonEnabled = buttonEnabled
        self.buttonID = buttonID
        self.requiresReadingToEnd = requiresReadingToEnd
        self.action = action
        self.content = content()
        self.footer = footer()
    }

    private var snapshotMode: Bool { ProcessInfo.processInfo.arguments.contains("-SNAPSHOT_MODE") }

    private var scroll: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AppleSheetHeader(title: title, subtitle: subtitle)
                    .padding(.bottom, 28)
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 36)
            .padding(.top, topPadding)
            .padding(.bottom, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    /// The scroll area, named for UI tests only when the page asks.
    @ViewBuilder private var namedScroll: some View {
        if let scrollID { scroll.accessibilityIdentifier(scrollID) } else { scroll }
    }

    var body: some View {
        namedScroll
        .modifier(ReadToEndTracker(required: requiresReadingToEnd, readToEnd: $readToEnd))
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                footer
                AppleSheetButton(title: buttonTitle, id: buttonID, action: action)
                    .disabled(!buttonEnabled || (requiresReadingToEnd && !readToEnd && !snapshotMode))
            }
            .padding(.horizontal, 36)
            .padding(.bottom, 12)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
    }
}

extension AppleSheetPage where Footer == EmptyView {
    init(title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, topPadding: CGFloat = 56,
         buttonTitle: LocalizedStringKey, buttonEnabled: Bool = true, buttonID: String = "sheetPrimaryButton",
         requiresReadingToEnd: Bool = false, scrollID: String? = nil, action: @escaping () -> Void,
         @ViewBuilder content: () -> Content) {
        self.init(title: title, subtitle: subtitle, topPadding: topPadding, buttonTitle: buttonTitle,
                  buttonEnabled: buttonEnabled, buttonID: buttonID, requiresReadingToEnd: requiresReadingToEnd,
                  scrollID: scrollID, action: action, content: content, footer: { EmptyView() })
    }
}

/// Marks a page read once its scroll reaches the end. iOS 17 has no scroll geometry to watch, so there a page that asks
/// for reading to the end counts as read from the start and its button never waits.
private struct ReadToEndTracker: ViewModifier {
    let required: Bool
    @Binding var readToEnd: Bool

    func body(content: Content) -> some View {
        if #available(iOS 18, *) {
            content.onScrollGeometryChange(for: Bool.self) { geo in
                geo.contentOffset.y + geo.containerSize.height >= geo.contentSize.height - 1
            } action: { _, atEnd in
                if atEnd, required, !readToEnd { readToEnd = true }
            }
        } else {
            content.onAppear { if required { readToEnd = true } }
        }
    }
}

/// A page of icon rows, Apple's "Welcome to" and "What's New" sheet.
struct AppleSheet: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey? = nil
    let rows: [AppleSheetRow]
    var buttonTitle: LocalizedStringKey = "Continue"
    var topPadding: CGFloat = 56
    var buttonID = "sheetPrimaryButton"
    let action: () -> Void

    var body: some View {
        AppleSheetPage(title: title, subtitle: subtitle, topPadding: topPadding, buttonTitle: buttonTitle,
                       buttonID: buttonID, action: action) {
            AppleSheetRows(rows: rows)
        }
    }
}

struct AppleSheetRows: View {
    let rows: [AppleSheetRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            ForEach(rows) { row in
                AppleSheetRowView(row: row)
            }
        }
    }
}

/// Title and grey subtitle, as Apple sets them at the top of its sheets.
struct AppleSheetHeader: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Apple's iOS 27 sheets set the title near .title, not .largeTitle: "What's New in
            // Calendar" fits one line (apple/shots/sim/apple_calendar.png).
            Text(title)
                .font(.title.bold())
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
    var id = "sheetPrimaryButton"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .modifier(ProminentCapsuleButton())
        .accessibilityIdentifier(id)
    }
}

/// `.glassProminent` on iOS 26 and later, `.borderedProminent` before, as every Cutling sheet.
struct ProminentCapsuleButton: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.buttonStyle(.glassProminent).tint(.brandGreen)
        } else {
            content.buttonStyle(.borderedProminent).buttonBorderShape(.capsule).tint(.brandGreen)
        }
    }
}

// MARK: - What's New and Welcome Back

/// What a sheet for an existing user says: what changed in this version, or, after a long
/// absence, how Cutling works plus what changed.
enum WhatsNewKind {
    case update
    case welcomeBack

    /// Names the rows below. Change it in the release whose rows change, and every existing
    /// user sees What's New once on that release.
    static let releaseID = "2026-11 fill-ins and room for more"

    /// Rows for changes people can see in this version, the biggest first. The fill-ins row
    /// shows only while `FillIns.isOn`.
    /// The numbers come from the store's own limits, so the sheet can never promise more
    /// room than `CutlingStore` allows.
    static var newRows: [AppleSheetRow] {
        let texts = CutlingStore.maxTextCutlings.formatted()
        let images = CutlingStore.maxImageCutlings.formatted()
        let fillIns = AppleSheetRow(symbol: "curlybraces", title: "Variables",
                                    detail: "Edit a cutling and open Variables to add a blank you fill in each time, today’s date, a choice and more.")
        return (FillIns.isOn ? [fillIns] : []) + [
        AppleSheetRow(symbol: "note.text", title: "Write as You Do in Notes",
                      detail: "A cutling’s text now opens on a page of its own, with bold, underline, highlight and lists."),
        AppleSheetRow(symbol: "square.stack.3d.up.fill", title: "Room for \(texts)",
                      detail: "Save up to \(texts) texts and \(images) images."),
        AppleSheetRow(symbol: "hand.tap.fill", title: "Every Key Types",
                      detail: "Tap a formatted cutling and it types like the rest. Touch and hold it to copy the formatting."),
        ]
    }

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
            AppleSheet(title: "What's New in Cutling",
                       subtitle: FillIns.isOn ? "Variables, writing as in Notes, and far more room." : "Far more room, and every key types.",
                       rows: WhatsNewKind.newRows) { dismiss() }
        case .welcomeBack:
            // At most four rows, as Apple's sheets keep them (Reminders has four).
            AppleSheet(title: "Welcome Back to Cutling",
                       rows: WhatsNewKind.basicsRows + WhatsNewKind.newRows.prefix(1)) { dismiss() }
        }
    }
}
#endif
