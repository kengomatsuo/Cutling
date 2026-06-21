//
//  HotkeyRecorderView.swift
//  Cutling: SwiftUI recorder for the global hotkey combo.
//
//  When recording, attaches an NSEvent local monitor to capture the next
//  key-down chord. Saves to GlobalHotkey on success.
//

#if os(macOS)
import SwiftUI
import AppKit
import Carbon.HIToolbox

struct HotkeyRecorderView: View {
    @State private var combo: HotkeyCombo = GlobalHotkey.shared.combo
    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        HStack(spacing: 8) {
            Text(isRecording ? "Press a key combination…" : combo.displayString)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(isRecording ? .secondary : .primary)
                .lineLimit(1)
                .frame(minWidth: 120, alignment: .center)
                .padding(.horizontal, 10)
                .frame(height: 22)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isRecording ? Color.accentColor : Color.gray.opacity(0.4), lineWidth: 1)
                )

            if isRecording {
                Button("Cancel") { stopRecording() }
                    .keyboardShortcut(.escape, modifiers: [])
            } else {
                Button("Record") { startRecording() }
                Button("Reset") {
                    let d = HotkeyCombo.default
                    combo = d
                    GlobalHotkey.shared.set(d)
                }
            }
        }
        .onDisappear { stopRecording() }
    }

    private func startRecording() {
        guard !isRecording else { return }
        isRecording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            if event.keyCode == kVK_Escape {
                stopRecording()
                return nil
            }
            let mods = HotkeyCombo.carbonModifiers(from: event.modifierFlags)
            // Require at least one non-shift modifier so simple keystrokes
            // don't accidentally become global hotkeys.
            let nonShift = mods & (UInt32(cmdKey) | UInt32(optionKey) | UInt32(controlKey))
            guard nonShift != 0 else { return nil }
            let new = HotkeyCombo(keyCode: UInt32(event.keyCode), modifiers: mods)
            combo = new
            GlobalHotkey.shared.set(new)
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false
        if let m = monitor {
            NSEvent.removeMonitor(m)
            monitor = nil
        }
    }
}
#endif
