//
//  LaunchAtLoginService.swift
//  Cutling: register the app to start when the user logs in.
//
//  Uses the modern ServiceManagement API (`SMAppService.mainApp`) added
//  in macOS 13. The older login-item helper-bundle approach is deprecated.
//
//  Important runtime caveats:
//    1. SMAppService only works on a code-signed bundle. Debug-from-Xcode
//       builds usually work because Xcode applies a development signature,
//       but ad-hoc / unsigned binaries will silently fail to register.
//    2. SMAppService remembers the user's choice in the system's login
//       items database; subsequent app launches read the live status via
//       `SMAppService.mainApp.status` rather than from app-side storage.
//

#if os(macOS)
import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginService {
    static let shared = LaunchAtLoginService()

    private init() {}

    /// True when macOS has the app registered to launch on login.
    var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    /// Toggle login-at-launch. Returns true if the request succeeded.
    /// Failure usually means an unsigned binary or that the user denied
    /// the request in System Settings → General → Login Items.
    @discardableResult
    func setEnabled(_ enabled: Bool) -> Bool {
        let service = SMAppService.mainApp
        do {
            if enabled {
                guard service.status != .enabled else { return true }
                try service.register()
            } else {
                guard service.status == .enabled else { return true }
                try service.unregister()
            }
            return true
        } catch {
            print("⚠️ Cutling: failed to update launch-at-login (\(enabled ? "register" : "unregister")): \(error.localizedDescription)")
            return false
        }
    }

    /// Open System Settings → Login Items so the user can resolve a
    /// "Not approved" state, or just verify the current state visually.
    func openLoginItemsSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
#endif
