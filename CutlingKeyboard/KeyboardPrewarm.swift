//
//  KeyboardPrewarm.swift
//  CutlingKeyboard
//
//  Builds Cutling's keyboard while the person is still choosing it. iOS starts the keyboard's process when the globe
//  key is held, close to a second before the person picks Cutling in the menu, and asks for the keyboard only when they
//  let go; from then until Cutling's first frame it shows a stand-in, the previous keyboard frozen and clipped (ASG207,
//  launch log against the recording; Apple DTS on the forums, thread 808167: known, no workaround). Building the
//  keyboard in that wait leaves only the hand-over for after the release, so the stand-in is gone almost at once.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI
import UIKit

/// Who the keys act on: the controller iOS creates for the keyboard, which can come after the keys are built.
final class KeyboardActionTarget {
    weak var controller: KeyboardViewController?
}

@MainActor
enum KeyboardPrewarm {
    struct Built {
        let hostingController: UIHostingController<KeyboardView>
        let state: KeyboardState
        let target: KeyboardActionTarget
    }

    private static var built: Built?
    private static var asked = false

    /// Builds the keyboard and lays it out at its height, unless iOS has already asked for it.
    static func build() {
        guard !asked, built == nil else { return }
        LaunchMarks.once("prewarm starts")
        KeyboardViewController.applySnapshotLanguage()
        let state = KeyboardState()
        // As the controller found it last time; the controller sets the real value before the keyboard shows.
        state.hasFullAccess = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.bool(forKey: "hasFullAccess") ?? false
        let target = KeyboardActionTarget()
        let hc = KeyboardViewController.makeHostingController(store: CutlingStore.shared, state: state, target: target)
        let screen = UIScreen.main.bounds
        hc.view.frame = CGRect(x: 0, y: 0, width: screen.width,
                               height: KeyboardViewController.height(for: UITraitCollection(horizontalSizeClass: .unspecified)))
        hc.view.layoutIfNeeded()
        built = Built(hostingController: hc, state: state, target: target)
        LaunchMarks.once("prewarm done")
    }

    /// The keyboard built in the wait, once; nil when iOS asked for the keyboard before it was built.
    static func take() -> Built? {
        asked = true
        defer { built = nil }
        return built
    }
}

/// Called from KeyboardPrewarm.m once UIKit has started in the keyboard's process.
@_cdecl("CutlingKeyboardPrewarm")
public func cutlingKeyboardPrewarm() {
    MainActor.assumeIsolated { KeyboardPrewarm.build() }
}
