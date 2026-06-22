//
//  KeyboardSetupView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import SwiftUI
#if os(iOS)
import UIKit
#endif

#if !os(macOS)

// MARK: - Setup Page

private enum SetupPage: Int, CaseIterable, Hashable {
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var onComplete: (() -> Void)? = nil

    @AppStorage("keyboardSetupPage") private var currentPage: Int = SetupPage.welcome.rawValue
    @State private var path: [SetupPage] = []
    @State private var keyboardDetected = false
    @State private var fullAccessDetected = false
    @State private var checkTimer: Timer?
    @State private var testText = ""
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false
    @FocusState private var testFieldFocused: Bool
    @State private var howToUseReadyToContinue = false
    @State private var doneIconAppeared = false

    private var allDone: Bool { keyboardDetected && fullAccessDetected }

    private var isSnapshotMode: Bool {
        ProcessInfo.processInfo.arguments.contains("-SNAPSHOT_MODE")
    }

    // MARK: - Detection

    private func checkKeyboardAdded() -> Bool {
        #if os(iOS)
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let keyboards = UserDefaults.standard.stringArray(forKey: "AppleKeyboards") ?? []
        return keyboards.contains(where: { $0.hasPrefix(bundleID) })
        #endif
        #if os(macOS)
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
        withAccessibleAnimation(.easeInOut(duration: 0.3)) {
            keyboardDetected = checkKeyboardAdded()
            fullAccessDetected = checkFullAccess()
        }
        if !wasFullAccess && fullAccessDetected && path.last == .test {
            #if DEBUG
            if !ProcessInfo.processInfo.arguments.contains("-SNAPSHOT_MODE") {
                testFieldFocused = false
            }
            #else
            testFieldFocused = false
            #endif
        }
    }

    private var lastAllowedPage: Int {
        #if DEBUG
        if isSnapshotMode { return SetupPage.done.rawValue }
        #endif
        if !keyboardDetected { return SetupPage.enable.rawValue }
        if !allDone { return SetupPage.test.rawValue }
        return SetupPage.done.rawValue
    }

    // MARK: - Body

    var body: some View {
        #if os(iOS)
        NavigationStack(path: $path) {
            welcomePage
                .navigationTitle("Keyboard Setup")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: SetupPage.self) { page in
                    pageContent(for: page)
                        .navigationTitle("Keyboard Setup")
                        .navigationBarTitleDisplayMode(.inline)
                }
        }
        .interactiveDismissDisabled(!allDone)
        .onAppear {
            #if DEBUG
            if isSnapshotMode {
                currentPage = SetupPage.welcome.rawValue
            }
            #endif
            refreshStatus()
            restorePath()
            startPolling()
        }
        .onDisappear { stopPolling() }
        .onChange(of: path) { _, newPath in
            currentPage = newPath.last?.rawValue ?? SetupPage.welcome.rawValue
            testFieldFocused = false
        }
        #endif
        #if os(macOS)
        NavigationStack {
            macOSFormContent
        }
        .frame(minWidth: 400, idealWidth: 440, minHeight: 400, idealHeight: 480)
        #endif
    }

    // MARK: - Path Restoration

    #if os(iOS)
    private func restorePath() {
        guard path.isEmpty else { return }
        let target = min(currentPage, lastAllowedPage)
        guard target > SetupPage.welcome.rawValue else { return }
        var newPath: [SetupPage] = []
        for raw in (SetupPage.welcome.rawValue + 1)...target {
            if let page = SetupPage(rawValue: raw) {
                newPath.append(page)
            }
        }
        var txn = Transaction()
        txn.disablesAnimations = true
        withTransaction(txn) {
            path = newPath
        }
    }

    @ViewBuilder
    private func pageContent(for page: SetupPage) -> some View {
        switch page {
        case .welcome: welcomePage
        case .enable: enablePage
        case .test: testPage
        case .howToUse: howToUsePage
        case .icloud: icloudPage
        case .done: donePage
        }
    }

    // MARK: - Continue Button

    private func continueButton(next: SetupPage?, canContinue: Bool) -> some View {
        Button {
            testFieldFocused = false
            if let next = next {
                path.append(next)
            } else {
                finish()
            }
        } label: {
            Text(next == nil ? "Get Started" : "Continue")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .modifier(GlassProminentButtonModifier())
        .disabled(!canContinue)
        .accessibilityIdentifier("continueButton")
        .padding(.horizontal)
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
        .continueButtonBar {
            continueButton(next: .enable, canContinue: true)
        }
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
        .continueButtonBar {
            continueButton(next: .test, canContinue: snapshotOr(keyboardDetected))
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
                        .accessibilityIdentifier("keyboardTestField")
                        .submitLabel(.done)
                        .onSubmit { testFieldFocused = false }
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
                    Label("Full Access", systemImage: "lock.open.fill")
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
        .accessibilityIdentifier("testPage")
        #if DEBUG
        .onAppear {
            if isSnapshotMode {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    testFieldFocused = true
                }
            }
        }
        #endif
        .continueButtonBar {
            continueButton(next: .howToUse, canContinue: snapshotOr(allDone))
                .padding(.bottom, testFieldFocused ? 12 : 0)
                .animation(.smooth(duration: 0.25), value: testFieldFocused)
        }
    }

    private var testPageSectionBackground: Color {
        colorScheme == .dark
            ? Color(.secondarySystemGroupedBackground)
            : Color(.systemGroupedBackground)
    }

    // MARK: - Page 4: What You Can Do

    private var howToUsePage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Spacer().frame(height: 8)

                Text("What You Can Do")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

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

                tipRow(
                    icon: "square.and.arrow.up",
                    title: "Save from Anywhere",
                    detail: "Send text, links, or images to Cutling straight from any app's Share Sheet or the Action extension."
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

                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .frame(width: 20)
                    Text("**Not for sensitive data** — avoid storing passwords, card numbers, private keys, or tokens")
                        .font(.subheadline)
                }
                .padding(.horizontal)

                Spacer().frame(height: 16)
            }
            .padding(.horizontal)
        }
        .accessibilityIdentifier("howToUsePage")
        .onScrollGeometryChange(for: Bool.self) { geo in
            geo.contentOffset.y + geo.containerSize.height >= geo.contentSize.height - 1
        } action: { _, isAtBottom in
            guard isAtBottom, !howToUseReadyToContinue else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.smooth(duration: 0.25)) {
                    howToUseReadyToContinue = true
                }
            }
        }
        .continueButtonBar {
            continueButton(next: .icloud, canContinue: snapshotOr(howToUseReadyToContinue))
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

                Text("Sync Across Devices")
                    .font(.title2.bold())

                Text("Turn on iCloud Sync to keep your cutlings up to date on every device signed in to your Apple Account.")
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

                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .continueButtonBar {
            continueButton(next: .done, canContinue: true)
        }
    }

    // MARK: - Page 6: Done

    private var donePage: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, options: .nonRepeating, value: doneIconAppeared)
                .onAppear { doneIconAppeared = true }

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
        .continueButtonBar {
            continueButton(next: nil, canContinue: snapshotOr(allDone))
        }
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

    private func snapshotOr(_ value: Bool) -> Bool {
        #if DEBUG
        if isSnapshotMode { return true }
        #endif
        return value
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
        hasCompletedSetup = true
        currentPage = SetupPage.welcome.rawValue
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

// MARK: - Bottom Bar Helper

/// Uses `.safeAreaBar` on iOS 26+ so the system applies the scroll edge effect
/// (variable blur) to content scrolling beneath the bar. Falls back to
/// `.safeAreaInset` on earlier versions.
private extension View {
    @ViewBuilder
    func continueButtonBar<C: View>(@ViewBuilder content: () -> C) -> some View {
        if #available(iOS 26, macOS 26, *) {
            self.safeAreaBar(edge: .bottom, content: content)
        } else {
            self.safeAreaInset(edge: .bottom, content: content)
        }
    }
}

// MARK: - Preview

#Preview {
    KeyboardSetupView()
}

#endif

