//
//  KeyboardSetupView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

// MARK: - Setup Page

private enum SetupPage: Int, CaseIterable {
    case welcome = 0
    case enable = 1
    case test = 2
    case howToUse = 3
    case icloud = 4
    case done = 5
}

// MARK: - Keyboard Setup View

struct KeyboardSetupView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    var isOnboarding: Bool = false
    var onComplete: (() -> Void)? = nil

    @State private var currentPage: Int = SetupPage.welcome.rawValue
    @State private var keyboardDetected = false
    @State private var fullAccessDetected = false
    @State private var checkTimer: Timer?
    @State private var testText = ""
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @FocusState private var testFieldFocused: Bool

    private var allDone: Bool { keyboardDetected && fullAccessDetected }

    /// Whether the current step's requirement is met, enabling the Continue button.
    private var canContinue: Bool {
        guard isOnboarding else { return true }
        switch SetupPage(rawValue: currentPage) {
        case .enable: return keyboardDetected
        case .test: return allDone
        default: return true
        }
    }

    // MARK: - Detection

    private func checkKeyboardAdded() -> Bool {
        #if os(iOS)
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let keyboards = UserDefaults.standard.stringArray(forKey: "AppleKeyboards") ?? []
        return keyboards.contains(where: { $0.hasPrefix(bundleID) })
        #else
        return false
        #endif
    }

    private func checkFullAccess() -> Bool {
        guard let defaults = UserDefaults(suiteName: "group.com.matsuokengo.Cutling") else {
            return false
        }
        return defaults.bool(forKey: "hasFullAccess")
    }

    private func refreshStatus() {
        let wasFullAccess = fullAccessDetected
        withAnimation(.easeInOut(duration: 0.3)) {
            keyboardDetected = checkKeyboardAdded()
            fullAccessDetected = checkFullAccess()
        }
        if !wasFullAccess && fullAccessDetected && currentPage == SetupPage.test.rawValue {
            #if DEBUG
            if !ProcessInfo.processInfo.arguments.contains("-SNAPSHOT_MODE") {
                testFieldFocused = false
            }
            #else
            testFieldFocused = false
            #endif
        }
    }

    private func advancePage() {
        testFieldFocused = false
        withAnimation {
            currentPage = min(currentPage + 1, SetupPage.done.rawValue)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            #if os(iOS)
            pagedContent
            #else
            macOSFormContent
            #endif
        }
        #if os(macOS)
        .frame(minWidth: 400, idealWidth: 440, minHeight: 400, idealHeight: 480)
        #endif
    }

    // MARK: - iOS Paged Content

    #if os(iOS)
    private var pagedContent: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                welcomePage.tag(SetupPage.welcome.rawValue)
                enablePage.tag(SetupPage.enable.rawValue)
                testPage.tag(SetupPage.test.rawValue)
                howToUsePage.tag(SetupPage.howToUse.rawValue)
                icloudPage.tag(SetupPage.icloud.rawValue)
                donePage.tag(SetupPage.done.rawValue)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .animation(.easeInOut(duration: 0.3), value: currentPage)

            continueButton
        }
        .ignoresSafeArea(.keyboard)
        .navigationTitle("Keyboard Setup")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { pagedToolbarContent }
        .onAppear {
            refreshStatus()
            startPolling()
        }
        .onDisappear {
            stopPolling()
        }
        .onChange(of: currentPage) { _, _ in
            testFieldFocused = false
        }
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        let isLastPage = currentPage == SetupPage.done.rawValue
        return Button(action: isLastPage ? finish : advancePage) {
            Text(isLastPage ? (isOnboarding ? "Get Started" : "Done") : "Continue")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .modifier(GlassProminentButtonModifier())
        .disabled(!canContinue)
        .accessibilityIdentifier("continueButton")
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        VStack(spacing: 20) {
            Spacer()

            Image("AppIcon-Default")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

            Text("Set Up Your Keyboard")
                .font(.title2.bold())

            Text("Follow a few simple steps to start using your custom Cutling keyboard.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Page 2: Enable

    private var enablePage: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 16)

                Image(systemName: "gearshape")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)

                Text("Enable Cutling Keyboard")
                    .font(.title3.bold())

                VStack(alignment: .leading, spacing: 12) {
                    instructionRow(number: 1, text: "Open Cutling in your device's **Settings** app.")
                    instructionRow(number: 2, text: "Tap **Keyboards** and enable **Cutling**.")
                    instructionRow(number: 3, text: "Turn on **Allow Full Access** so the keyboard can copy images to your clipboard.")
                }
                .padding(.horizontal, 24)

                Text("Your data stays private and is never sent anywhere.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open Cutling Settings", systemImage: "arrow.up.forward.square")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .modifier(GlassProminentButtonModifier())
                .padding(.horizontal, 32)

                Spacer()
            }
        }
    }

    // MARK: - Page 3: Test

    private var testPage: some View {
        Form {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)

                    Text("Test Your Keyboard")
                        .font(.title3.bold())

                    Text("Tap the text field below, then use the 🌐 globe key to switch to **Cutling**. This verifies that everything is set up correctly.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { testFieldFocused = false }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            Section {
                HStack {
                    Image(systemName: "character.cursor.ibeam")
                        .foregroundStyle(.secondary)
                    TextField("Tap here, then switch to Cutling", text: $testText)
                        .focused($testFieldFocused)
                }
                .listRowBackground(testPageSectionBackground)
            }

            Section {
                HStack {
                    Label("Keyboard Added", systemImage: "keyboard")
                    Spacer()
                    Image(systemName: keyboardDetected ? "checkmark.circle.fill" : "circle.dashed")
                        .foregroundStyle(keyboardDetected ? .green : .secondary)
                        .font(.title3)
                }
                .listRowBackground(testPageSectionBackground)

                HStack {
                    Label("Full Access", systemImage: fullAccessDetected ? "lock.open.fill" : "lock.fill")
                    Spacer()
                    Image(systemName: fullAccessDetected ? "checkmark.circle.fill" : "circle.dashed")
                        .foregroundStyle(fullAccessDetected ? .green : .secondary)
                        .font(.title3)
                }
                .listRowBackground(testPageSectionBackground)
            } header: {
                Text("Status")
            }
        }
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }

    private var testPageSectionBackground: Color {
        colorScheme == .dark
            ? Color(.secondarySystemGroupedBackground)
            : Color(.systemGroupedBackground)
    }

    // MARK: - Page 4: How to Use

    private var howToUsePage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Spacer().frame(height: 8)

                Text("How to Use Your Keyboard")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, alignment: .center)

                tipRow(
                    icon: "globe",
                    title: "Switch to Cutling Keyboard",
                    detail: "While typing in any app, tap or hold the 🌐 globe key at the bottom-left of your keyboard, then select Cutling"
                )

                tipRow(
                    icon: "text.cursor",
                    title: "Insert Text Instantly",
                    detail: "Tap any text cutling and it will be typed into your current text field immediately"
                )

                tipRow(
                    icon: "photo",
                    title: "Copy Images",
                    detail: "Tap an image cutling to copy it to your clipboard, then paste it into the app you're using (usually by tapping and holding, then selecting Paste). Apple currently does not support directly pasting an image on this app."
                )

                tipRow(
                    icon: "doc.on.clipboard",
                    title: "Add from Clipboard",
                    detail: "Copy any text, then tap the 'Add from Clipboard' button in the Cutling keyboard to save it as a new cutling"
                )

                Divider()
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Storage Limits")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Text("Up to **\(CutlingStore.maxTextCutlings) text** cutlings")
                            .font(.subheadline)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Text("Up to **\(CutlingStore.maxImageCutlings) image** cutlings")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)

                Spacer().frame(height: 16)
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Page 5: iCloud

    private var icloudPage: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 24)

                Image(systemName: "icloud")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.accentColor)

                Text("iCloud Sync")
                    .font(.title2.bold())

                Text("Keep your cutlings in sync across all your devices.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Toggle(isOn: $iCloudSyncEnabled) {
                    Label("Enable iCloud Sync", systemImage: "arrow.triangle.2.circlepath.icloud")
                }
                .padding(.horizontal, 32)
                .onChange(of: iCloudSyncEnabled) { _, enabled in
                    UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.set(enabled, forKey: "iCloudSyncEnabled")
                }

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                    Text("iCloud Sync is an **experimental feature**. It may not work correctly in all situations, which may lead to data loss. You can always change this later in Settings.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 32)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Page 6: Done

    private var donePage: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)

            Text("You're All Set!")
                .font(.title2.bold())

            Text("Your Cutling keyboard is ready! While typing anywhere, tap the 🌐 globe icon on your keyboard to switch to Cutling.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helper Views

    private func instructionRow(number: Int, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Color.accentColor, in: Circle())
            Text(text)
                .font(.subheadline)
        }
    }

    private func tipRow(icon: String, title: LocalizedStringKey, detail: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
                .font(.title3)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var pagedToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            if currentPage > SetupPage.welcome.rawValue && currentPage < SetupPage.done.rawValue {
                // Back button
                Button {
                    testFieldFocused = false
                    withAnimation {
                        currentPage = max(currentPage - 1, 0)
                    }
                } label: {
                    if #available(iOS 26, *) {
                        Image(systemName: "chevron.left")
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            } else if !isOnboarding {
                // Close button (welcome or done page, non-onboarding)
                Button {
                    finish()
                } label: {
                    if #available(iOS 26, *) {
                        Image(systemName: "xmark")
                    } else {
                        Text("Done")
                    }
                }
            }
        }
    }
    #endif

    // MARK: - macOS Form Content

    #if os(macOS)
    private var macOSFormContent: some View {
        Form {
            Section {
                Toggle(isOn: .constant(false)) {
                    Label("iCloud Sync", systemImage: "icloud")
                }
            } header: {
                Text("iCloud")
            }

            Section("About") {
                LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Keyboard Setup")
    }
    #endif

    // MARK: - Polling

    private func startPolling() {
        checkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            refreshStatus()
        }
    }

    private func stopPolling() {
        checkTimer?.invalidate()
        checkTimer = nil
    }

    // MARK: - Finish

    private func finish() {
        stopPolling()
        testFieldFocused = false
        onComplete?()
        dismiss()
    }
}

// MARK: - Glass Button Modifier

/// Applies `.glassProminent` on iOS 26+ and `.borderedProminent` on earlier versions.
private struct GlassProminentButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, *) {
            content.buttonStyle(.glassProminent)
        } else {
            content.buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Preview

#Preview("Onboarding") {
    KeyboardSetupView(isOnboarding: true)
}

#Preview("Re-open") {
    KeyboardSetupView(isOnboarding: false)
}
