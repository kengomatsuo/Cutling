//
//  WelcomeWindow.swift
//  Cutling: first-launch onboarding for the macOS app.
//
//  Three steps that teach what HIG calls "the things a user must know
//  up-front for the app to work at all":
//    1. Cutling lives in the menu bar (LSUIElement apps have no Dock icon,
//       which disorients new users).
//    2. The global hotkey to summon it from anywhere.
//    3. Optional Accessibility access for auto-paste, with explanation.
//
//  Gated by @AppStorage("hasOnboarded"). After dismissal we drop the Dock
//  icon via AppActivationManager (the window-close notification it watches
//  fires naturally).
//

#if os(macOS)
import SwiftUI
import AppKit

struct WelcomeView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var step: Int = 0
    @Environment(\.dismissWindow) private var dismissWindow

    private let totalSteps = 4

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch step {
                case 0: StepWelcome()
                case 1: StepMenuBar()
                case 2: StepHotkey()
                default: StepAccessibility()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity.combined(with: .move(edge: .trailing)))

            Divider()

            HStack(spacing: 8) {
                // Step dots
                HStack(spacing: 6) {
                    ForEach(0..<totalSteps, id: \.self) { i in
                        Circle()
                            .fill(i == step ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: 7, height: 7)
                    }
                }
                Spacer()
                if step > 0 {
                    Button("Back") { withAnimation { step -= 1 } }
                        .keyboardShortcut(.leftArrow, modifiers: [])
                }
                if step < totalSteps - 1 {
                    Button(step == 0 ? "Continue" : "Next") {
                        withAnimation { step += 1 }
                    }
                    .keyboardShortcut(.defaultAction)
                } else {
                    Button("Get Started") { finish() }
                        .keyboardShortcut(.defaultAction)
                }
            }
            .padding(16)
        }
        .frame(width: 520, height: 460)
    }

    private func finish() {
        hasOnboarded = true
        dismissWindow(id: WelcomeWindow.id)
    }
}

enum WelcomeWindow {
    static let id = "onboarding"
}

// MARK: - Step 0: Welcome hero

private struct StepWelcome: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 0)
            // App icon at hero size. NSImage.applicationIconName resolves to
            // the running app's icon, which works for both Debug and Release.
            if let icon = NSImage(named: NSImage.applicationIconName) {
                Image(nsImage: icon)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 128, height: 128)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
            }

            VStack(spacing: 10) {
                Text("Welcome to Cutling")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text("Your clipboard, organised.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("Save the snippets, images, and links you reuse. Capture everything you copy. Paste anywhere with one shortcut.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 4)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Step 1: Menu bar location

/// Animated indicator that draws attention upward toward the real macOS
/// menu bar. Because MenuBarExtra hides its underlying NSStatusItem in
/// SwiftUI, we can't reliably point exactly at the icon, so instead we
/// render a mock menu bar with the Cutling icon highlighted so the user
/// learns what to look for, plus an animated arrow above.
private struct StepMenuBar: View {
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 20) {
            // Mini illustration of a menu bar with our icon highlighted.
            menuBarMock
                .padding(.top, 24)

            // Animated arrow.
            Image(systemName: "arrow.up")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(.tint)
                .offset(y: pulse ? -6 : 4)
                .opacity(pulse ? 1.0 : 0.55)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.9).repeatForever()) {
                        pulse.toggle()
                    }
                }

            VStack(spacing: 6) {
                Text("Look up. Cutling lives in your menu bar")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Text("The clipboard icon at the top of your screen opens Cutling any time. Click it to see your saved cutlings and recent clipboard history.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var menuBarMock: some View {
        HStack(spacing: 14) {
            // Leading: Apple menu + app menus
            Image(systemName: "applelogo")
                .foregroundStyle(.secondary)
            Text("App")
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            Text("File")
                .foregroundStyle(.secondary.opacity(0.7))
            Text("Edit")
                .foregroundStyle(.secondary.opacity(0.7))

            Spacer(minLength: 20)

            // Trailing menu bar extras. macOS convention: third-party
            // extras sit to the left of the system indicators, with
            // Control Center / Clock on the far right.
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.accentColor.opacity(0.25))
                    .frame(width: 28, height: 22)
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tint)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.accentColor, lineWidth: 1.5)
            )
            Image(systemName: "wifi")
                .foregroundStyle(.secondary.opacity(0.6))
            Image(systemName: "battery.75percent")
                .foregroundStyle(.secondary.opacity(0.6))
            Image(systemName: "switch.2")
                .foregroundStyle(.secondary.opacity(0.6))
            Text("12:34")
                .foregroundStyle(.secondary.opacity(0.7))
        }
        .font(.system(size: 12))
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(.background.tertiary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(.secondary.opacity(0.3), lineWidth: 0.5)
        )
        .frame(maxWidth: 460)
    }
}

// MARK: - Step 2: Hotkey

private struct StepHotkey: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 6) {
                KeyCap("⌘")
                KeyCap("⇧")
                KeyCap("V")
            }
            .padding(.top, 36)

            VStack(spacing: 6) {
                Text("Summon Cutling from anywhere")
                    .font(.title2.bold())
                Text("Press ⌘⇧V from any app to open a floating picker at your cursor. Pick a cutling and it's ready to paste, no menu bar trip required.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Text("Rebind it later in Settings → Hotkey.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct KeyCap: View {
    let label: String
    init(_ label: String) { self.label = label }
    var body: some View {
        Text(label)
            .font(.system(size: 24, weight: .semibold, design: .rounded))
            .frame(width: 52, height: 52)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.background.tertiary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.secondary.opacity(0.4), lineWidth: 1)
            )
    }
}

// MARK: - Step 3: Accessibility

private struct StepAccessibility: View {
    @State private var isTrusted: Bool = PasteService.shared.isTrusted
    @State private var pollTimer: Timer?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isTrusted ? "checkmark.shield.fill" : "lock.shield")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(isTrusted ? AnyShapeStyle(.green) : AnyShapeStyle(.tint))
                .padding(.top, 24)

            VStack(spacing: 6) {
                Text(isTrusted ? "You're all set" : "One more thing: Accessibility")
                    .font(.title2.bold())
                if isTrusted {
                    Text("Cutling has the access it needs. Picking a cutling will paste it straight into whatever app you were using.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                } else {
                    Text("Grant Accessibility so Cutling can paste a cutling directly into the app you were using. Without it, you'll have to press ⌘V yourself after picking.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Button("Grant Accessibility Access") {
                        PasteService.shared.requestTrustIfNeeded()
                        PasteService.shared.openAccessibilitySettings()
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 4)
                    Text("You can skip this and grant it later from Settings → Paste.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isTrusted = PasteService.shared.isTrusted
            pollTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                Task { @MainActor in isTrusted = PasteService.shared.isTrusted }
            }
        }
        .onDisappear {
            pollTimer?.invalidate()
            pollTimer = nil
        }
    }
}
#endif
