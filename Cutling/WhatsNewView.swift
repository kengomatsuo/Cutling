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
        VStack(spacing: 0) {
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
                            color: .blue,
                            title: "Cutling for Mac",
                            detail: "Cutling now runs on your Mac with a global hotkey and menu bar picker."
                        )
                        featureRow(
                            icon: "mic.fill",
                            color: .purple,
                            title: "Siri & Shortcuts",
                            detail: "Ask Siri to add, copy, or search your cutlings hands-free."
                        )
                        featureRow(
                            icon: "rectangle.3.group.fill",
                            color: .pink,
                            title: "Widgets & Controls",
                            detail: "Pin favorite cutlings to your Home Screen, Lock Screen, or Control Center for one-tap copy."
                        )
                        featureRow(
                            icon: "square.and.arrow.up.fill",
                            color: .orange,
                            title: "Save from Anywhere",
                            detail: "Send text, links, or images to Cutling straight from any app's Share Sheet or the Action extension."
                        )
                        featureRow(
                            icon: "icloud.fill",
                            color: .cyan,
                            title: "Sync Across Devices",
                            detail: "Turn on iCloud Sync to keep your cutlings up to date on every device signed in to your Apple Account."
                        )
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            }

            Button {
                onComplete?()
                dismiss()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .padding(.top, 8)
            .background(.bar)
        }
        .interactiveDismissDisabled()
    }

    private func featureRow(
        icon: String,
        color: Color,
        title: LocalizedStringKey,
        detail: LocalizedStringKey
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .regular))
                .foregroundStyle(color)
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

#Preview {
    WhatsNewView()
}

#endif
