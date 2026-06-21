//
//  GlobalHotkey.swift
//  Cutling — system-wide keyboard shortcut to summon the clipboard picker.
//
//  Apple has never shipped a modern replacement for Carbon's RegisterEventHotKey,
//  so this is still the canonical way to register a global hotkey on macOS
//  (per the sindresorhus/KeyboardShortcuts library, which uses the same path).
//

#if os(macOS)
import AppKit
import Carbon.HIToolbox

extension Notification.Name {
    static let cutlingHotkeyPressed = Notification.Name("com.matsuokengo.Cutling.hotkeyPressed")
}

struct HotkeyCombo: Codable, Equatable, Sendable {
    var keyCode: UInt32
    /// Carbon-style modifier mask (cmdKey | shiftKey | optionKey | controlKey).
    var modifiers: UInt32

    static let `default` = HotkeyCombo(
        keyCode: UInt32(kVK_ANSI_V),
        modifiers: UInt32(cmdKey | shiftKey)
    )

    var displayString: String {
        var parts: [String] = []
        if modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
        if modifiers & UInt32(optionKey)  != 0 { parts.append("⌥") }
        if modifiers & UInt32(shiftKey)   != 0 { parts.append("⇧") }
        if modifiers & UInt32(cmdKey)     != 0 { parts.append("⌘") }
        parts.append(Self.keyName(for: keyCode))
        return parts.joined()
    }

    static func keyName(for keyCode: UInt32) -> String {
        switch Int(keyCode) {
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_Z: return "Z"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_9: return "9"
        case kVK_Space: return "␣"
        case kVK_Return: return "↩"
        case kVK_Tab: return "⇥"
        case kVK_Escape: return "⎋"
        case kVK_Delete: return "⌫"
        case kVK_ForwardDelete: return "⌦"
        case kVK_LeftArrow: return "←"
        case kVK_RightArrow: return "→"
        case kVK_UpArrow: return "↑"
        case kVK_DownArrow: return "↓"
        default: return "?"
        }
    }

    /// Converts a SwiftUI / AppKit NSEvent modifier flags set to a Carbon modifier mask.
    static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var mods: UInt32 = 0
        if flags.contains(.command)  { mods |= UInt32(cmdKey) }
        if flags.contains(.shift)    { mods |= UInt32(shiftKey) }
        if flags.contains(.option)   { mods |= UInt32(optionKey) }
        if flags.contains(.control)  { mods |= UInt32(controlKey) }
        return mods
    }
}

@MainActor
@safe final class GlobalHotkey {
    static let shared = GlobalHotkey()

    private(set) var combo: HotkeyCombo
    @safe private var hotKeyRef: EventHotKeyRef?
    @safe private var eventHandlerRef: EventHandlerRef?
    private let storeKey = "globalHotkey"

    private init() {
        if let data = UserDefaults(suiteName: appGroupID)?.data(forKey: storeKey),
           let decoded = try? JSONDecoder().decode(HotkeyCombo.self, from: data) {
            combo = decoded
        } else {
            combo = .default
        }
    }

    /// Registers the current combo. Idempotent.
    func register() {
        unregister()
        installEventHandlerIfNeeded()

        let signature: OSType = 0x434C5447 // 'CLTG'
        let hotKeyID = EventHotKeyID(signature: signature, id: 1)
        var ref: EventHotKeyRef?
        let status = unsafe RegisterEventHotKey(
            combo.keyCode,
            combo.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &ref
        )
        if status == noErr {
            hotKeyRef = unsafe ref
        } else {
            print("⚠️ Cutling: failed to register global hotkey (\(combo.displayString)): status \(status)")
        }
    }

    func unregister() {
        if let ref = hotKeyRef {
            unsafe UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
    }

    /// Replace the combo, persist it, and re-register.
    func set(_ newCombo: HotkeyCombo) {
        combo = newCombo
        if let data = try? JSONEncoder().encode(newCombo) {
            UserDefaults(suiteName: appGroupID)?.set(data, forKey: storeKey)
        }
        register()
    }

    private func installEventHandlerIfNeeded() {
        guard unsafe eventHandlerRef == nil else { return }
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let handler: EventHandlerUPP = { _, _, _ -> OSStatus in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .cutlingHotkeyPressed, object: nil)
            }
            return noErr
        }
        unsafe InstallEventHandler(
            GetApplicationEventTarget(),
            handler,
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )
    }
}
#endif
