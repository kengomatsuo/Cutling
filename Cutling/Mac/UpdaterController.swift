//
//  UpdaterController.swift
//  Cutling: Sparkle auto-update for the direct-download (Developer ID) macOS build.
//
//  Guarded by `#if canImport(Sparkle)` so the file is completely inert until the
//  Sparkle Swift Package is added to the Cutling target (the project uses
//  fileSystemSynchronizedGroups, so an unguarded import would break the build
//  before the package is linked). Once Sparkle is linked, this exposes a shared
//  updater and a drop-in "Check for Updates…" button for Settings.
//
//  The App Store build ignores all of this: SUFeedURL / SUPublicEDKey only take
//  effect when the Sparkle framework is present, and the appcast is only served
//  for the direct-download channel.
//

#if os(macOS) && canImport(Sparkle)
import SwiftUI
import Sparkle

/// Owns the Sparkle updater for the app's lifetime. `startingUpdater: true`
/// begins the automatic background check schedule using the SUFeedURL and
/// SUPublicEDKey from Info.plist.
@MainActor
final class UpdaterController {
    static let shared = UpdaterController()
    let controller: SPUStandardUpdaterController

    private init() {
        controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    var updater: SPUUpdater { controller.updater }

    /// Whether Sparkle checks for updates in the background. Backed by
    /// Sparkle's runtime preference; the initial default comes from
    /// `SUEnableAutomaticChecks` in Info.plist (opt-in / off). Per Sparkle's
    /// guidance, this runtime API is only for reflecting user changes, which
    /// is exactly what the onboarding + Settings toggles do.
    var automaticallyChecksForUpdates: Bool {
        get { updater.automaticallyChecksForUpdates }
        set { updater.automaticallyChecksForUpdates = newValue }
    }
}

/// Drop this into Settings (e.g. the General tab) to give users a manual
/// "Check for Updates…" button. Sparkle no-ops gracefully if a check can't
/// run right now, so the button stays simple and avoids Combine (the project
/// prefers async/await over Combine for observation).
struct CheckForUpdatesView: View {
    var body: some View {
        Button("Check for Updates…") {
            UpdaterController.shared.updater.checkForUpdates()
        }
    }
}
#endif
