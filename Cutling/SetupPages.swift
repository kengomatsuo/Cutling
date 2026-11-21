//
//  SetupPages.swift
//  Cutling
//
//  The setup guide's closing pages, What You Can Do, Sync Across Devices and You're All
//  Set, which the owner asked to keep (2026-11-21). They keep their content and their strings,
//  so every language keeps its translation, and take the guide's one page layout
//  (AppleSheetPage), so they match the pages before them.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#if os(iOS)
import SwiftUI

/// Inside the guide's navigation stack the bar sits above the title, so pages start close to it.
let setupPageTopPadding: CGFloat = 8

// MARK: - What You Can Do

struct SetupWhatYouCanDoPage: View {
    let onContinue: () -> Void

    var body: some View {
        AppleSheetPage(title: "What You Can Do", topPadding: setupPageTopPadding, buttonTitle: "Continue",
                       buttonID: "continueButton", requiresReadingToEnd: true, scrollID: "howToUsePage",
                       action: onContinue) {
            VStack(alignment: .leading, spacing: 26) {
                AppleSheetRows(rows: [
                    AppleSheetRow(symbol: "globe", title: "Switch to Cutling Keyboard",
                                  detail: "While typing in any app, tap or hold the 🌐 globe key at the bottom-left of your keyboard, then select Cutling"),
                    AppleSheetRow(symbol: "text.cursor", title: "Insert Text Instantly",
                                  detail: "Tap any text cutling and it will be typed into your current text field immediately"),
                    AppleSheetRow(symbol: "photo", title: "Copy Images",
                                  detail: "Tap an image cutling to copy it to your clipboard, then paste it into the app you're using (usually by tapping and holding, then selecting Paste). Apple currently does not support directly pasting an image on this app."),
                    AppleSheetRow(symbol: "doc.on.clipboard", title: "Add from Clipboard",
                                  detail: "Copy any text, then tap the 'Add from Clipboard' button in the Cutling keyboard to save it as a new cutling"),
                    AppleSheetRow(symbol: "square.and.arrow.up", title: "Save from Anywhere",
                                  detail: "Send text, links, or images to Cutling straight from any app's Share Sheet or the Action extension."),
                ])
                // The same row shape for the limits and the warning, so the page reads as one list.
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "tray.full")
                        .font(.system(size: 30))
                        .foregroundStyle(.tint)
                        .frame(width: 40)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Storage Limits").font(.headline)
                        Text("Up to **\(CutlingStore.maxTextCutlings) text** cutlings").foregroundStyle(.secondary)
                        Text("Up to **\(CutlingStore.maxImageCutlings) image** cutlings").foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.orange)
                        .frame(width: 40)
                        .accessibilityHidden(true)
                    Text("**Not for sensitive data.** Avoid storing passwords, card numbers, private keys or tokens.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

// MARK: - Sync Across Devices

struct SetupICloudPage: View {
    let onContinue: () -> Void
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false

    var body: some View {
        AppleSheetPage(title: "Sync Across Devices", topPadding: setupPageTopPadding, buttonTitle: "Continue",
                       buttonID: "continueButton", action: onContinue) {
            VStack(alignment: .leading, spacing: 26) {
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "icloud")
                        .font(.system(size: 30))
                        .foregroundStyle(.tint)
                        .frame(width: 40)
                        .accessibilityHidden(true)
                    Text("Turn on iCloud Sync to keep your cutlings up to date on every device signed in to your Apple Account.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Toggle(isOn: $iCloudSyncEnabled) {
                    Text("Enable iCloud Sync").font(.headline)
                }
                .padding(.leading, 56)
                .onChange(of: iCloudSyncEnabled) { _, enabled in
                    UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.set(enabled, forKey: "iCloudSyncEnabled")
                }
            }
        }
    }
}

// MARK: - You're All Set

struct SetupDonePage: View {
    var canFinish = true
    let onFinish: () -> Void

    var body: some View {
        AppleSheetPage(title: "You're All Set!", topPadding: setupPageTopPadding, buttonTitle: "Get Started",
                       buttonEnabled: canFinish, buttonID: "continueButton", action: onFinish) {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.green)
                    .frame(width: 40)
                    .accessibilityHidden(true)
                Text("Your Cutling keyboard is ready! While typing anywhere, tap the 🌐 globe icon on your keyboard to switch to Cutling.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
#endif
