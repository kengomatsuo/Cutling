//
//  KeyboardColdLaunchUITests.swift
//  CutlingUITests
//
//  A cold launch of the Cutling keyboard, filmed by scripts/ui-test.sh in two calls: testA leaves Cutling as the
//  active keyboard; the second call installs the app again, which ends the keyboard's process, and testB focuses
//  the field so the keyboard starts from nothing. Judge testB's frames: the keyboard should rise at full height.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

@MainActor
final class KeyboardColdLaunchUITests: XCTestCase {
    override func setUp() async throws { continueAfterFailure = false }

    private func mark(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "cold_\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
        print("COLD-LAUNCH \(name) at \(Date().timeIntervalSince1970)")
    }

    /// Run first: leaves Cutling as the keyboard iOS shows next.
    func testAMakeCutlingTheActiveKeyboard() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST"]
        app.launch()
        app.terminate()
        addCutlingKeyboardInSettings()
        app.launch()
        sleep(3)
        _ = openKeyboardTestField(in: app)
        switchToCutlingKeyboard(in: app, showing: "Reply")
        XCTAssertTrue(cutlingKeyboardIsUp(in: app, showing: "Reply"), "Cutling keyboard did not come up")
        mark("warm")
        app.terminate()
    }

    /// Run in a second ui-test.sh call: installing the app again ends the keyboard's process, so focusing
    /// the field starts Cutling from nothing, as a person's first use after a restart or an update does.
    func testBColdLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST"]
        app.launch()
        sleep(2)
        mark("before_focus")
        _ = openKeyboardTestField(in: app)
        mark("focused")
        sleep(4)
        mark("settled")
        XCTAssertTrue(cutlingKeyboardIsUp(in: app, showing: "Reply"), "Cutling keyboard did not come up on the cold launch")
    }
}
