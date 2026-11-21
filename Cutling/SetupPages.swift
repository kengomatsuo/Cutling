//
//  SetupPages.swift
//  Cutling
//
//  The setup guide's closing pages, What You Can Do, Sync Across Devices and You're All
//  Set, shared by the shipped guide (KeyboardSetupView) and the remade one (SetupFlowA), which
//  the owner asked to keep (2026-11-21). Their strings are the guide's own, so every language
//  keeps its translation.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#if os(iOS)
import SwiftUI

/// The guide's full-width bottom button: Continue, or Get Started on the last page.
struct SetupContinueButton: View {
    var title: LocalizedStringKey = "Continue"
    var enabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .modifier(ProminentCapsuleButton())
        .disabled(!enabled)
        .accessibilityIdentifier("continueButton")
        .padding(.horizontal)
    }
}

extension View {
    /// `.safeAreaBar` on iOS 26 and later, so content scrolling under the button gets the
    /// system's edge blur; `.safeAreaInset` before.
    @ViewBuilder
    func setupButtonBar<C: View>(@ViewBuilder content: () -> C) -> some View {
        if #available(iOS 26, *) {
            safeAreaBar(edge: .bottom, content: content)
        } else {
            safeAreaInset(edge: .bottom, content: content)
        }
    }
}

// MARK: - What You Can Do

struct SetupWhatYouCanDoPage: View {
    let onContinue: () -> Void
    /// Continue waits until the page has been scrolled to its end, where the limits and the
    /// sensitive-data warning sit.
    @State private var readToEnd = false

    private var isSnapshotMode: Bool { ProcessInfo.processInfo.arguments.contains("-SNAPSHOT_MODE") }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Spacer().frame(height: 8)

                Text("What You Can Do")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                tipRow(icon: "globe", title: "Switch to Cutling Keyboard",
                       detail: "While typing in any app, tap or hold the 🌐 globe key at the bottom-left of your keyboard, then select Cutling")
                tipRow(icon: "text.cursor", title: "Insert Text Instantly",
                       detail: "Tap any text cutling and it will be typed into your current text field immediately")
                tipRow(icon: "photo", title: "Copy Images",
                       detail: "Tap an image cutling to copy it to your clipboard, then paste it into the app you're using (usually by tapping and holding, then selecting Paste). Apple currently does not support directly pasting an image on this app.")
                tipRow(icon: "doc.on.clipboard", title: "Add from Clipboard",
                       detail: "Copy any text, then tap the 'Add from Clipboard' button in the Cutling keyboard to save it as a new cutling")
                tipRow(icon: "square.and.arrow.up", title: "Save from Anywhere",
                       detail: "Send text, links, or images to Cutling straight from any app's Share Sheet or the Action extension.")

                Divider().padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Storage Limits")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text").foregroundStyle(.secondary).frame(width: 20)
                        Text("Up to **\(CutlingStore.maxTextCutlings) text** cutlings").font(.subheadline)
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "photo").foregroundStyle(.secondary).frame(width: 20)
                        Text("Up to **\(CutlingStore.maxImageCutlings) image** cutlings").font(.subheadline)
                    }
                }
                .padding(.horizontal)

                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .frame(width: 20)
                    Text("**Not for sensitive data.** Avoid storing passwords, card numbers, private keys or tokens.")
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
            guard isAtBottom, !readToEnd else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.smooth(duration: 0.25)) { readToEnd = true }
            }
        }
        .setupButtonBar {
            SetupContinueButton(enabled: readToEnd || isSnapshotMode, action: onContinue)
        }
    }

    private func tipRow(icon: String, title: LocalizedStringKey, detail: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
                .font(.title3)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.medium))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Sync Across Devices

struct SetupICloudPage: View {
    let onContinue: () -> Void
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 24)

                Image(systemName: "icloud")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.accentColor)
                    .accessibilityHidden(true)

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
        .setupButtonBar {
            SetupContinueButton(action: onContinue)
        }
    }
}

// MARK: - You're All Set

struct SetupDonePage: View {
    var canFinish = true
    let onFinish: () -> Void
    @State private var iconAppeared = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, options: .nonRepeating, value: iconAppeared)
                .onAppear { iconAppeared = true }
                .accessibilityHidden(true)

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
        .setupButtonBar {
            SetupContinueButton(title: "Get Started", enabled: canFinish, action: onFinish)
        }
    }
}
#endif
