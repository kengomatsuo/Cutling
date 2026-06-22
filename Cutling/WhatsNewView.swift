//
//  WhatsNewView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 22/06/26.
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import SwiftUI

#if !os(macOS)

/// Native-style "What's New" sheet shown once to existing users after a
/// significant release. New users skip this — they see the full onboarding.
struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss
    var onComplete: (() -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("What's New in Cutling")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                    .padding(.top, 48)
                    .padding(.bottom, 40)
                    .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 28) {
                    featureRow(
                        icon: "laptopcomputer",
                        title: "Cutling for Mac",
                        detail: "Cutling now runs on your Mac with a global hotkey and menu bar picker."
                    )
                    featureRow(
                        icon: "mic.fill",
                        title: "Siri & Shortcuts",
                        detail: "Ask Siri to add, copy, or search your cutlings hands-free."
                    )
                    featureRow(
                        icon: "rectangle.3.group.fill",
                        title: "Widgets & Controls",
                        detail: "Pin favorite cutlings to your Home Screen, Lock Screen, or Control Center for one-tap copy."
                    )
                    featureRow(
                        icon: "square.and.arrow.up.fill",
                        title: "Save from Anywhere",
                        detail: "Send text, links, or images to Cutling straight from any app's Share Sheet or the Action extension."
                    )
                    featureRow(
                        icon: "icloud.fill",
                        title: "Sync Across Devices",
                        detail: "Turn on iCloud Sync to keep your cutlings up to date on every device signed in to your Apple Account."
                    )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .continueButtonBar {
            Button {
                onComplete?()
                dismiss()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .modifier(GlassProminentButtonModifier())
            .padding(.horizontal)
        }
        .interactiveDismissDisabled()
    }

    private func featureRow(
        icon: String,
        title: LocalizedStringKey,
        detail: LocalizedStringKey
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .regular))
                .foregroundStyle(.tint)
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
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

#Preview {
    WhatsNewView()
}

#endif
