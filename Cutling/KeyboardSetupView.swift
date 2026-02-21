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

// MARK: - Keyboard Setup View

struct KeyboardSetupView: View {
    @Environment(\.dismiss) var dismiss

    var isOnboarding: Bool = false
    var onComplete: (() -> Void)? = nil

    @State private var keyboardDetected = false
    @State private var fullAccessDetected = false
    @State private var checkTimer: Timer?
    @State private var testText = ""
    @FocusState private var testFieldFocused: Bool

    private var allDone: Bool { keyboardDetected && fullAccessDetected }

    // MARK: - Detection

    private func checkKeyboardAdded() -> Bool {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let keyboards = UserDefaults.standard.stringArray(forKey: "AppleKeyboards") ?? []
        return keyboards.contains(where: { $0.hasPrefix(bundleID) })
    }

    private func checkFullAccess() -> Bool {
        guard let defaults = UserDefaults(suiteName: "group.com.matsuokengo.Cutling") else {
            return false
        }
        print(defaults.bool(forKey: "hasFullAccess"))
        return defaults.bool(forKey: "hasFullAccess")
    }

    private func refreshStatus() {
        withAnimation(.easeInOut(duration: 0.3)) {
            keyboardDetected = checkKeyboardAdded()
            fullAccessDetected = checkFullAccess()
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // Header
                Section {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(allDone ? Color.green.opacity(0.12) : Color.accentColor.opacity(0.12))
                                .frame(width: 72, height: 72)
                            Image(systemName: allDone ? "checkmark.seal.fill" : "keyboard.badge.ellipsis")
                                .font(.system(size: 32))
                                .foregroundStyle(allDone ? .green : Color.accentColor)
                        }

                        Text(allDone ? "You're All Set!" : "Set Up Your Keyboard")
                            .font(.title3.bold())

                        Text(allDone
                             ? "Your Cutling keyboard is ready! While typing anywhere, tap the 🌐 globe icon on your keyboard to switch to Cutling."
                             : "Follow the two simple steps below to start using your custom keyboard. This page will automatically update as you complete each step."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }

                // Status
                Section {
                    HStack {
                        Label("Keyboard Added", systemImage: "keyboard")
                        Spacer()
                        Image(systemName: keyboardDetected ? "checkmark.circle.fill" : "circle.dashed")
                            .foregroundStyle(keyboardDetected ? .green : .secondary)
                            .font(.title3)
                    }

                    HStack {
                        Label("Full Access", systemImage: fullAccessDetected ? "lock.open.fill" : "lock.fill")
                        Spacer()
                        Image(systemName: fullAccessDetected ? "checkmark.circle.fill" : "circle.dashed")
                            .foregroundStyle(fullAccessDetected ? .green : .secondary)
                            .font(.title3)
                    }
                } header: {
                    Text("Setup Progress")
                } footer: {
                    if !keyboardDetected {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("**Step 1:** Tap 'Open Cutling Settings' below, go to **Keyboards** and select **Cutling** from the list.")
                            Text("**Step 2:** Make sure **Allow Full Access** is ON. This lets the keyboard copy images to your clipboard. Your data stays private and is never sent anywhere.")
                        }
                    }
                }

                // Actions
                Section {
                    Button {
                        #if os(iOS)
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                        #endif
                    } label: {
                        Label("Open Cutling Settings", systemImage: "arrow.up.forward.square")
                    }

                    HStack {
                        Image(systemName: "character.cursor.ibeam")
                            .foregroundStyle(.secondary)
                        TextField("Tap here, then switch to Cutling", text: $testText)
                            .focused($testFieldFocused)
                    }
                } footer: {
                    Text("**Step 3:** Tap on the text input and choose \"Cutling\" using the 🌐 globe icon on your keyboard to update the \"Full Access\" status.")
                }

                // How to use (shown when done)
                if allDone {
                    Section {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Switch to Cutling Keyboard")
                                    .font(.subheadline.weight(.medium))
                                Text("While typing in any app, tap or hold the 🌐 globe key at the bottom-left of your keyboard, then select Cutling")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "globe")
                                .foregroundStyle(Color.accentColor)
                        }

                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Insert Text Instantly")
                                    .font(.subheadline.weight(.medium))
                                Text("Tap any text cutling and it will be typed into your current text field immediately")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "text.cursor")
                                .foregroundStyle(Color.accentColor)
                        }

                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Copy Images")
                                    .font(.subheadline.weight(.medium))
                                Text("Tap an image cutling to copy it to your clipboard, then paste it into the app you're using (usually by tapping and holding, then selecting Paste). Apple currently does not support directly pasting an image on this app.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "photo")
                                .foregroundStyle(Color.accentColor)
                        }
                        
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Add from Clipboard")
                                    .font(.subheadline.weight(.medium))
                                Text("Copy any text, then tap the 'Add from Clipboard' button in the Cutling keyboard to save it as a new cutling")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundStyle(Color.accentColor)
                        }
                    } header: {
                        Text("How to Use Your Keyboard")
                    } footer: {
                        Text("You can manage all your cutlings in the main Cutling app. Changes you make will instantly appear in your keyboard.")
                    }
                }
            }
            .navigationTitle("Keyboard Setup")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            #endif
            .toolbar {
                if allDone {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            finish()
                        } label: {
                            #if os(macOS)
                            Text("Done")
                            #elseif os(iOS)
                            if #available(iOS 26, *) {
                                Image(systemName: "checkmark")
                            } else {
                                Text("Done")
                            }
                            #endif
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            finish()
                        } label: {
                            #if os(macOS)
                            Text("Cancel")
                            #elseif os(iOS)
                            if #available(iOS 26, *) {
                                Image(systemName: "xmark")
                            } else {
                                Text("Cancel")
                            }
                            #endif
                        }
                    }
                }
            }
            .onAppear {
                refreshStatus()
                startPolling()
            }
            .onDisappear {
                stopPolling()
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, idealWidth: 440, minHeight: 400, idealHeight: 480)
        #endif
    }

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

// MARK: - Preview

#Preview("Onboarding") {
    KeyboardSetupView(isOnboarding: true)
}

#Preview("Re-open") {
    KeyboardSetupView(isOnboarding: false)
}
