//
//  KeyboardSwitchCompareUITests.swift
//  CutlingUITests
//
//  Cutling's own keys: a tapped cutling shows its Inserted mark, and holding the space bar moves the cursor like a
//  trackpad. Then the stand-in iOS shows while switching back to Cutling with the globe, filmed with the keyboard's
//  height constraint as shipped and with it required, to see whether iOS sizes the stand-in from Cutling.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

@MainActor
final class KeyboardSwitchCompareUITests: XCTestCase {
    override func setUp() async throws { continueAfterFailure = true }

    private func mark(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "switch_\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
        print("KEYBOARD-SWITCH \(name) at \(Date().timeIntervalSince1970)")
    }

    private func launch() -> XCUIApplication {
        // A fresh simulator has no Cutling keyboard; the setup guide's test field needs it added with Full Access.
        addCutlingKeyboardInSettings()
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST"]
        app.launch()
        sleep(2)
        return app
    }

    /// Apple's Japanese Kana keyboard shows its あ key.
    private func kanaIsUp(_ app: XCUIApplication) -> Bool {
        app.keys["あ"].exists || app.buttons["あ"].exists
    }

    /// English is up: letter keys, and neither Kana nor Cutling.
    private func englishIsUp(_ app: XCUIApplication) -> Bool {
        app.keys["Q"].exists || app.keys["q"].exists
    }

    /// Taps the globe until English is up (a tap goes back to the keyboard used before).
    private func backToEnglish(_ app: XCUIApplication) {
        for _ in 0..<4 where !englishIsUp(app) {
            let globe = keyboardGlobe(in: app)
            if globe.waitForExistence(timeout: 5) { globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
            sleep(2)
        }
    }

    /// As a person does it: holds the globe, slides up its list and lets go on a row, one row higher each try.
    private func switchFromGlobe(_ app: XCUIApplication, until isUp: () -> Bool) {
        for row in 1...10 where !isUp() {
            let globe = keyboardGlobe(in: app)
            guard globe.waitForExistence(timeout: 5) else { break }
            let start = globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            start.press(forDuration: 1.0, thenDragTo: start.withOffset(CGVector(dx: 70, dy: -44 * CGFloat(row))),
                        withVelocity: .slow, thenHoldForDuration: 0.4)
            sleep(2)
            if !isUp() && !englishIsUp(app) { backToEnglish(app) }
        }
    }

    /// A tapped cutling shows Inserted, and holding the space bar moves the cursor: a space typed after sliding left
    /// lands inside the text, not at its end.
    func testAInsertedMarkAndTrackpad() throws {
        let app = launch()
        let field = openKeyboardTestField(in: app)
        switchToCutlingKeyboard(in: app, showing: "Order")
        XCTAssertTrue(cutlingKeyboardIsUp(in: app, showing: "Order"), "Cutling did not come up")
        guard let order = cutlingKeyFrame("Order", in: app) else { return XCTFail("No Order key") }
        screenPoint(order.midX, order.midY, in: app).tap()
        let inserted = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS 'Inserted'")).firstMatch
        XCTAssertTrue(inserted.waitForExistence(timeout: 1), "No Inserted mark after typing a cutling")
        mark("5_inserted")
        sleep(2)
        let typed = field.value as? String ?? ""
        XCTAssertFalse(typed.isEmpty, "The cutling was not typed")

        let space = app.descendants(matching: .any).matching(identifier: "spaceKey").firstMatch
        XCTAssertTrue(space.waitForExistence(timeout: 5), "No space key")
        let start = space.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        // Hold, then slide 90 pt left: about ten characters.
        start.press(forDuration: 0.9, thenDragTo: start.withOffset(CGVector(dx: -90, dy: 0)), withVelocity: .slow, thenHoldForDuration: 0.3)
        sleep(1)
        mark("6_after_trackpad")
        space.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        sleep(1)
        let after = field.value as? String ?? ""
        XCTAssertEqual(after.count, typed.count + 1, "The tap did not type one space")
        XCTAssertFalse(after.hasSuffix(" ") && after.dropLast() == typed[...], "The space landed at the end: the trackpad did not move the cursor")
        mark("7_space_inside")
        print("TRACKPAD before '\(typed)' after '\(after)'")
    }

    /// Cutling up, the globe back to the keyboard before, the globe to Cutling again: the recording between the second
    /// tap and Cutling's first frame shows iOS's stand-in. `trial` is the keyboard's height trial, nil as shipped.
    private func standIn(_ name: String, trial: String?) {
        addCutlingKeyboardInSettings()
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST"]
        if let trial { app.launchArguments += ["-KEYBOARD_HEIGHT_TRIAL", trial] }
        app.launch()
        sleep(2)
        _ = openKeyboardTestField(in: app)
        switchToCutlingKeyboard(in: app, showing: "Reply")
        XCTAssertTrue(cutlingKeyboardIsUp(in: app, showing: "Reply"), "Cutling did not come up (\(name))")
        mark("\(name)_1_cutling")
        for step in ["2_back", "3_cutling_again"] {
            let globe = keyboardGlobe(in: app)
            XCTAssertTrue(globe.waitForExistence(timeout: 5), "No globe (\(name))")
            print("KEYBOARD-SWITCH \(name)_\(step) tap at \(Date().timeIntervalSince1970)")
            globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            sleep(4)
            let tip = app.buttons.matching(NSPredicate(format: "label == 'Continue' AND identifier != 'continueButton'")).firstMatch
            if tip.exists { tip.tap(); sleep(1) }
            mark("\(name)_\(step)")
        }
        XCTAssertTrue(cutlingKeyboardIsUp(in: app, showing: "Reply"), "Cutling did not come back (\(name))")
        app.terminate()
    }

    func testBStandInAsShipped() throws { standIn("shipped", trial: nil) }

    func testCStandInHeightRequired() throws { standIn("required", trial: "required") }
}
