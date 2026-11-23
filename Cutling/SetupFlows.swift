//
//  SetupFlows.swift
//  Cutling
//
//  The setup guide the owner picked (direction A of docs/research/onboarding/directions.md):
//  Welcome, Add the Keyboard with the real Settings video, Try It on the real keyboard, then
//  the guide's own What You Can Do, Sync Across Devices and You're All Set (SetupPages.swift).
//  Full Access stays optional, since a keyboard without it still reads the app's shared
//  container and types text (App Review 4.4.1; docs/research/onboarding/apple/notes.md rows 3-4).
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

/// One numbered line of the setup steps, as the shipped guide draws them.
struct SetupStepLine: View {
    let number: Int
    let text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(verbatim: "\(number)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Color.brandGreen, in: Circle())
                .accessibilityHidden(true)
            Text(text).font(.subheadline)
        }
    }
}

/// A numbered disc that turns into a green check when its step is done (Dictus' badge).
struct StepBadge: View {
    let number: Int
    let done: Bool

    var body: some View {
        ZStack {
            Circle().fill(done ? Color.green : Color.brandGreen)
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
        // In the guide's own frame (the same bar and title place as its pages), as it opens
        // from the Add the Keyboard page.
        NavigationStack {
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
            buttonTitle: "Done",
            topPadding: setupPageTopPadding
        ) { dismiss() }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.visible, for: .navigationBar)
        }
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
                .accessibilityIdentifier("keyboardTestField")
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

struct SetupGuide: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var store: CutlingStore
    @State private var status = KeyboardStatus()
    @State private var path: [Page] = []
    @State private var tryText = ""
    @State private var showFullAccess = false
    // iOS relaunches Cutling when Allow Full Access is switched in Settings (seen in the
    // setup recordings), so the step the buyer reached outlives the process.
    @AppStorage("setupWelcomeSeen") private var welcomeSeen = false

    /// Add, Try It, then the guide's own closing pages, which the owner keeps.
    enum Page: Hashable { case add, tryIt, whatYouCanDo, icloud, done }

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
                ],
                topPadding: setupPageTopPadding,
                buttonID: "continueButton"
            ) {
                welcomeSeen = true
                path.append(status.keyboardAdded ? .tryIt : .add)
            }
            // One bar on every page, so every title starts at the same height.
            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(.visible, for: .navigationBar)
            .navigationDestination(for: Page.self) { page in
                Group {
                    switch page {
                    case .add: addPage
                    case .tryIt: tryPage
                    case .whatYouCanDo: SetupWhatYouCanDoPage { path.append(.icloud) }
                    case .icloud: SetupICloudPage { path.append(.done) }
                    case .done: SetupDonePage { finish() }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarVisibility(.visible, for: .navigationBar)
            }
        }
        .interactiveDismissDisabled()
        .sheet(isPresented: $showFullAccess) { FullAccessSheet() }
        .onAppear {
            StarterCutling.addIfEmpty(to: store)
            status.startPolling()
            // Back after a relaunch: straight to the step the buyer was on, with no push.
            if welcomeSeen, path.isEmpty {
                var restore = Transaction()
                restore.disablesAnimations = true
                withTransaction(restore) { path = status.keyboardAdded ? [.tryIt] : [.add] }
            }
        }
        .onDisappear { status.stopPolling() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { status.refresh() } }
        .onChange(of: status.keyboardAdded) { _, added in
            if added, path.last == .add { path.append(.tryIt) }
        }
    }

    private var addPage: some View {
        AppleSheetPage(title: "Add the Keyboard", subtitle: "Turn on Cutling in Settings, then come back.",
                       topPadding: setupPageTopPadding, buttonTitle: "Open Settings", buttonID: "openSettingsButton",
                       action: SetupLinks.openSettings) {
            VStack(alignment: .leading, spacing: 16) {
                // Short enough that the steps under it sit above the button down to a 678-point-tall screen.
                SettingsDemoVideo()
                    .frame(maxHeight: 210)
                    .frame(maxWidth: .infinity)
                // The guide's own steps, in every language, for anyone the video doesn't reach.
                VStack(alignment: .leading, spacing: 12) {
                    SetupStepLine(number: 1, text: "Open Cutling in your device's **Settings** app.")
                    SetupStepLine(number: 2, text: "Tap **Keyboards** and enable **Cutling**.")
                    SetupStepLine(number: 3, text: "Turn on **Allow Full Access** so the keyboard can copy images to your clipboard.")
                }
            }
        } footer: {
            // Apple sets a sheet's secondary action as a text link over its one button.
            Button("About Full Access") { showFullAccess = true }
                .font(.subheadline)
                .accessibilityIdentifier("aboutFullAccess")
        }
    }

    private var tryPage: some View {
        // The keyboard stays up here; the page is short, so the button above the keyboard
        // never covers the field.
        AppleSheetPage(title: "Try It", subtitle: "Type with Cutling here.", topPadding: setupPageTopPadding,
                       buttonTitle: "Continue", buttonID: "continueButton") {
            path.append(.whatYouCanDo)
        } content: {
            TryField(text: $tryText, worked: typedACutling(tryText, store: store))
        }
    }

    private func finish() {
        UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
        // The 12-step walkthrough no longer starts by itself after setup (owner, 2026-11-21);
        // it stays under How to Use Cutling. This flag also lets the contextual tips show.
        UserDefaults.standard.set(true, forKey: "hasSeenInteractiveTutorial")
        dismiss()
    }
}

// MARK: - Mock switch (DEBUG)

#if DEBUG
/// `-WHATSNEW_MOCK new|back` shows the What's New or Welcome Back sheet on launch, for shots.
enum SetupMock {
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
