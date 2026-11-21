//
//  SetupFlows.swift
//  Cutling
//
//  Three ways to take a new buyer from first launch to typing with the Cutling keyboard,
//  built for the owner to pick from (docs/research/onboarding/directions.md):
//    A  three short pages: Welcome, Add the Keyboard, Try It (Grammarly's steps, Wispr's
//       picture of Settings, Apple's welcome sheet)
//    B  no wizard: a Finish Setting Up card on the grid (Apple Games' Home card,
//       TypeWhisper's setup row, hex's "Finish setup")
//    C  one sheet with three numbered steps that tick themselves (Dictus' checklist)
//  All three keep Full Access optional, since a keyboard without it still reads the app's
//  shared container and types text (App Review 4.4.1; apple/notes.md rows 3-4).
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#if os(iOS)
import SwiftUI
import UIKit

// MARK: - Shared parts

enum SetupLinks {
    static func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

/// The first cutling a new buyer can tap in the keyboard, so the keyboard is never empty
/// on its first open (ClipKeyboard keeps sample cutlings for the same reason).
enum StarterCutling {
    static let name = String(localized: "Try Me")
    static let value = String(localized: "Cutling typed this for me.")

    @MainActor static func addIfEmpty(to store: CutlingStore) {
        guard store.cutlings.isEmpty else { return }
        store.add(Cutling(name: name, value: value, icon: "hand.wave.fill"))
    }
}

/// Apple's grouped Settings rows on Cutling's page, drawn as the buyer will meet them,
/// with the number of each touch (Wispr's "Set up in Settings", Grammarly's step 2).
/// VoiceOver reads it as one sentence, not as controls that do nothing.
struct SettingsPicture: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Settings › Apps › Cutling")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.leading, 16)
            VStack(spacing: 0) {
                pictureRow(number: 1, symbol: "keyboard", title: "Keyboards", trailing: .chevron)
                Divider().padding(.leading, 56)
                pictureRow(number: 2, symbol: nil, title: "Cutling", trailing: .toggle)
                Divider().padding(.leading, 56)
                pictureRow(number: 3, symbol: nil, title: "Allow Full Access", trailing: .toggle, note: "Optional")
            }
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("In Settings, open Keyboards, turn on Cutling, and if you like, Allow Full Access.")
    }

    private enum Trailing { case chevron, toggle }

    private func pictureRow(number: Int, symbol: String?, title: LocalizedStringKey, trailing: Trailing,
                            note: LocalizedStringKey? = nil) -> some View {
        HStack(spacing: 12) {
            StepBadge(number: number, done: false)
            if let symbol {
                Image(systemName: symbol)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Color(.systemGray), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                if let note {
                    Text(note).font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 8)
            switch trailing {
            case .chevron:
                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            case .toggle:
                Toggle("", isOn: .constant(true)).labelsHidden().allowsHitTesting(false)
            }
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
    }
}

/// A numbered disc that turns into a green check when its step is done (Dictus' badge).
struct StepBadge: View {
    let number: Int
    let done: Bool

    var body: some View {
        ZStack {
            Circle().fill(done ? Color.green : Color.accentColor)
            if done {
                Image(systemName: "checkmark").font(.caption.weight(.bold))
            } else {
                Text(verbatim: "\(number)").font(.subheadline.weight(.bold))
            }
        }
        .foregroundStyle(.white)
        .frame(width: 26, height: 26)
        .accessibilityHidden(true)
    }
}

/// Why Cutling asks for Full Access, what it opens and what Cutling never does. Answers the
/// fear buyers name (cutling-voice-of-customer.md pain 4) off the main path, as Dictus moved
/// its explainer from a step to a sheet after testers refused at Apple's alert.
struct FullAccessSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AppleSheet(
            title: "About Full Access",
            subtitle: "Cutling types your text without it.",
            rows: [
                AppleSheetRow(symbol: "photo.on.rectangle", title: "Images and Clipboard",
                              detail: "Full Access lets the keyboard copy a saved image and add what you copied."),
                AppleSheetRow(symbol: "wifi.slash", title: "Nothing Leaves Your iPhone",
                              detail: "Cutling has no account and never connects to the internet. It doesn't read what you type."),
                AppleSheetRow(symbol: "exclamationmark.shield", title: "Apple's Warning",
                              detail: "iOS shows the same warning for every keyboard that asks, whatever it does."),
            ],
            buttonTitle: "Done"
        ) { dismiss() }
    }
}

/// The try step: a real field with the keyboard up and Apple's words for switching
/// (Grammarly's step 3, Wispr's globe step). It knows the keyboard works when a cutling's
/// text lands in it (hex's self-completing test).
struct TryField: View {
    @Binding var text: String
    let worked: Bool
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Tap here", text: $text, axis: .vertical)
                .focused($focused)
                .lineLimit(2...4)
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .accessibilityIdentifier("setupTryField")
            if worked {
                Label("Cutling typed it. You're set.", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
            } else {
                Text("Touch and hold \(Image(systemName: "globe")) below, choose Cutling, then tap Try Me.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear { focused = true }
    }
}

private func typedACutling(_ text: String, store: CutlingStore) -> Bool {
    guard !text.isEmpty else { return false }
    return store.cutlings.contains { $0.kind == .text && !$0.value.isEmpty && text.contains($0.value) }
}

// MARK: - A: three short pages

struct SetupFlowA: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var store: CutlingStore
    @State private var status = KeyboardStatus()
    @State private var path: [Page] = []
    @State private var tryText = ""
    @State private var showFullAccess = false

    enum Page: Hashable { case add, tryIt }

    var body: some View {
        NavigationStack(path: $path) {
            AppleSheet(
                title: "Welcome to Cutling",
                rows: [
                    AppleSheetRow(symbol: "character.cursor.ibeam", title: "Tap to Type",
                                  detail: "Save what you type over and over, then tap it on the keyboard in any app."),
                    AppleSheetRow(symbol: "photo.on.rectangle", title: "Images Too",
                                  detail: "Copy a saved image with one tap and paste it anywhere."),
                    AppleSheetRow(symbol: "lock.fill", title: "Stays on Your iPhone",
                                  detail: "No account, no internet. Your cutlings sync only through your own iCloud."),
                ]
            ) { path.append(status.keyboardAdded ? .tryIt : .add) }
            .navigationDestination(for: Page.self) { page in
                switch page {
                case .add: addPage
                case .tryIt: tryPage
                }
            }
        }
        .interactiveDismissDisabled()
        .sheet(isPresented: $showFullAccess) { FullAccessSheet() }
        .onAppear { StarterCutling.addIfEmpty(to: store); status.startPolling() }
        .onDisappear { status.stopPolling() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { status.refresh() } }
        .onChange(of: status.keyboardAdded) { _, added in
            if added, path.last == .add { path.append(.tryIt) }
        }
    }

    private var addPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                AppleSheetHeader(title: "Add the Keyboard", subtitle: "Turn on Cutling in Settings, then come back.")
                SettingsPicture()
                Button("About Full Access") { showFullAccess = true }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            AppleSheetButton(title: "Open Settings") { SetupLinks.openSettings() }
                .padding(.horizontal, 36)
                .padding(.bottom, 12)
        }
    }

    private var tryPage: some View {
        let worked = typedACutling(tryText, store: store)
        return ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                AppleSheetHeader(title: "Try It", subtitle: "Type with Cutling here.")
                TryField(text: $tryText, worked: worked)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { finish() }
                    .fontWeight(.semibold)
                    .accessibilityIdentifier("setupDone")
            }
        }
    }

    private func finish() {
        UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
        dismiss()
    }
}

// MARK: - B: setup on the grid

/// Sits at the top of the grid until the keyboard is added and has typed once; never a
/// sheet in the way of the app (Apple Games' welcome card, TypeWhisper's setup row).
struct SetupCard: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var store: CutlingStore
    @State private var status = KeyboardStatus()
    @State private var showFullAccess = false
    @State private var showTry = false
    @AppStorage("setupTried") private var tried = false
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false

    var body: some View {
        if !hasCompletedSetup {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Finish Setting Up Cutling").font(.headline)
                    Text("Two steps, then Cutling types in any app.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(16)
                Divider().padding(.leading, 56)
                stepRow(number: 1, done: status.keyboardAdded, title: "Add the Keyboard",
                        detail: "Settings › Apps › Cutling › Keyboards", action: SetupLinks.openSettings,
                        actionTitle: "Open")
                Divider().padding(.leading, 56)
                stepRow(number: 2, done: tried, title: "Try It",
                        detail: "Type with Cutling once", action: { showTry = true }, actionTitle: "Try")
                Divider().padding(.leading, 56)
                Button { showFullAccess = true } label: {
                    HStack(spacing: 14) {
                        Image(systemName: status.fullAccess ? "checkmark.circle.fill" : "photo.on.rectangle")
                            .foregroundStyle(status.fullAccess ? Color.green : Color.secondary)
                            .frame(width: 26)
                        Text(status.fullAccess ? "Full Access is on" : "Images and clipboard need Full Access")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Image(systemName: "info.circle").foregroundStyle(.tint)
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)
            }
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .padding(.horizontal)
            .padding(.bottom, 12)
            .sheet(isPresented: $showFullAccess) { FullAccessSheet() }
            .sheet(isPresented: $showTry) { TrySheet(tried: $tried) }
            .onAppear { StarterCutling.addIfEmpty(to: store); status.startPolling() }
            .onDisappear { status.stopPolling() }
            .onChange(of: scenePhase) { _, phase in if phase == .active { status.refresh() } }
            .onChange(of: tried) { _, done in if done && status.keyboardAdded { hasCompletedSetup = true } }
            .accessibilityIdentifier("setupCard")
        }
    }

    private func stepRow(number: Int, done: Bool, title: LocalizedStringKey, detail: LocalizedStringKey,
                         action: @escaping () -> Void, actionTitle: LocalizedStringKey) -> some View {
        HStack(spacing: 14) {
            StepBadge(number: number, done: done)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.body.weight(.medium))
                Text(detail).font(.footnote).foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            if !done {
                Button(actionTitle, action: action)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }
}

/// B's try step as its own small sheet over the grid.
private struct TrySheet: View {
    @Binding var tried: Bool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: CutlingStore
    @State private var text = ""

    var body: some View {
        let worked = typedACutling(text, store: store)
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                TryField(text: $text, worked: worked)
                Spacer()
            }
            .padding(20)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Try It")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.fontWeight(.semibold)
                }
            }
            .onChange(of: worked) { _, ok in if ok { tried = true } }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - C: one live checklist

struct SetupFlowC: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var store: CutlingStore
    @State private var status = KeyboardStatus()
    @State private var tryText = ""
    @State private var showFullAccess = false

    var body: some View {
        let worked = typedACutling(tryText, store: store)
        NavigationStack {
            Form {
                Section {
                    AppleSheetHeader(title: "Set Up Cutling", subtitle: "Each step ticks itself when it's done.")
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 8, trailing: 4))
                }
                Section {
                    checkRow(number: 1, done: status.keyboardAdded, title: "Add the Cutling keyboard",
                             detail: "Settings › Apps › Cutling › Keyboards") {
                        if !status.keyboardAdded {
                            Button("Open Settings") { SetupLinks.openSettings() }
                                .buttonStyle(.bordered).buttonBorderShape(.capsule).fontWeight(.semibold)
                        }
                    }
                    checkRow(number: 2, done: status.fullAccess, title: "Allow Full Access",
                             detail: "Optional, for images and clipboard") {
                        Button { showFullAccess = true } label: { Image(systemName: "info.circle") }
                            .buttonStyle(.borderless)
                            .accessibilityLabel("About Full Access")
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        checkRow(number: 3, done: worked, title: "Try it", detail: nil) { EmptyView() }
                        if status.keyboardAdded {
                            TryField(text: $tryText, worked: worked)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                AppleSheetButton(title: "Done") {
                    UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
                    dismiss()
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 12)
            }
        }
        .interactiveDismissDisabled()
        .sheet(isPresented: $showFullAccess) { FullAccessSheet() }
        .onAppear { StarterCutling.addIfEmpty(to: store); status.startPolling() }
        .onDisappear { status.stopPolling() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { status.refresh() } }
    }

    private func checkRow<Trailing: View>(number: Int, done: Bool, title: LocalizedStringKey, detail: LocalizedStringKey?,
                                          @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack(spacing: 14) {
            StepBadge(number: number, done: done)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.body.weight(.medium))
                if let detail { Text(detail).font(.footnote).foregroundStyle(.secondary) }
            }
            Spacer(minLength: 8)
            trailing()
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityValue(done ? Text("Done") : Text("Not done"))
    }
}

// MARK: - Mock switch (DEBUG)

#if DEBUG
/// `-ONBOARDING_MOCK A|B|C` runs that direction on launch; `-WHATSNEW_MOCK new|back` shows
/// the What's New or Welcome Back sheet. For the owner's pick; nothing here ships.
enum SetupMock {
    enum Direction: String { case a = "A", b = "B", c = "C" }

    static var direction: Direction? {
        UserDefaults.standard.string(forKey: "ONBOARDING_MOCK").flatMap { Direction(rawValue: $0.uppercased()) }
    }

    static var whatsNew: WhatsNewKind? {
        switch UserDefaults.standard.string(forKey: "WHATSNEW_MOCK") {
        case "new": return .update
        case "back": return .welcomeBack
        default: return nil
        }
    }
}
#endif
#endif
