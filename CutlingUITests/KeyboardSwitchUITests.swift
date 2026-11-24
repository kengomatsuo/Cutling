//
//  KeyboardSwitchUITests.swift
//  CutlingUITests
//
//  Switching keyboards from the globe menu, filmed by scripts/ui-test.sh for frame-by-frame comparison: English to
//  Apple's Japanese Kana, then English to Cutling, each marked in the log so the frames can be found. Then Cutling's
//  own keys: a tapped cutling shows its Inserted mark, and holding the space bar moves the cursor like a trackpad.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

@MainActor
final class KeyboardSwitchUITests: XCTestCase {
    override func setUp() async throws { continueAfterFailure = true }

    private func mark(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "switch_\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
        print("KEYBOARD-SWITCH \(name) at \(Date().timeIntervalSince1970)")
    }

    private func launch() -> XCUIApplication {
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

    /// Adds Apple's Japanese Kana keyboard and the Cutling keyboard in Settings.
    func testAAddKanaAndCutling() throws {
        addCutlingKeyboardInSettings()
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.launch()
        for label in ["General", "Keyboard", "Keyboards"] {
            let cell = settings.cells.staticTexts[label].firstMatch
            XCTAssertTrue(cell.waitForExistence(timeout: 5), "Settings: '\(label)' not found")
            cell.tap()
            sleep(1)
        }
        let kana = settings.cells.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Kana'")).firstMatch
        if !kana.exists {
            let addNew = settings.cells["AddNewKeyboard"].firstMatch
            if !addNew.exists { settings.swipeUp() }
            addNew.tap()
            let japanese = settings.cells.staticTexts["Japanese"].firstMatch
            for _ in 0..<6 where !japanese.isHittable { settings.swipeUp() }
            japanese.tap()
            let kanaOption = settings.cells.staticTexts["Kana"].firstMatch
            XCTAssertTrue(kanaOption.waitForExistence(timeout: 5), "No Kana option")
            kanaOption.tap()
            settings.buttons["Done"].firstMatch.tap()
            sleep(1)
        }
        XCTAssertTrue(kana.waitForExistence(timeout: 5), "Japanese Kana keyboard not added")
        settings.terminate()
    }

    /// English to Japanese Kana, then back, then English to Cutling: the frames show whether the English keys move.
    func testBSwitchEnglishToKanaThenCutling() throws {
        let app = launch()
        _ = openKeyboardTestField(in: app)
        sleep(1)
        backToEnglish(app)
        XCTAssertTrue(englishIsUp(app), "English is not up")
        mark("1_english")
        switchFromGlobe(app) { kanaIsUp(app) }
        mark("2_kana")
        XCTAssertTrue(kanaIsUp(app), "Japanese Kana did not come up")
        backToEnglish(app)
        mark("3_english_again")
        switchFromGlobe(app) { cutlingKeyboardIsUp(in: app, showing: "Reply") }
        mark("4_cutling")
        XCTAssertTrue(cutlingKeyboardIsUp(in: app, showing: "Reply"), "Cutling did not come up")
    }

    /// A tapped cutling shows Inserted, and holding the space bar moves the cursor: a space typed after sliding left
    /// lands inside the text, not at its end.
    func testCInsertedMarkAndTrackpad() throws {
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
}
