//
//  UnlockUITests.swift
//  CutlingUITests
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

/// A free copy with its 5 cutlings full tries to add a 6th: the unlock screen opens, Unlock buys (the debug demo
/// store, no Apple sheet), and the 6th cutling then saves. Recorded by scripts/ui-test.sh as the unlock preview.
final class UnlockUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func shot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let dir = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"] {
            try? XCUIScreen.main.screenshot().pngRepresentation
                .write(to: URL(fileURLWithPath: dir).appendingPathComponent("unlock_\(name).png"))
        }
    }

    @MainActor
    private func openNewTextCutling(_ app: XCUIApplication) {
        let add = app.buttons["Add cutling"].firstMatch
        XCTAssertTrue(add.waitForExistence(timeout: 30), "No + button")
        add.tap()
        let text = app.descendants(matching: .any)["Text Cutling"].firstMatch
        if text.waitForExistence(timeout: 5) { text.tap() }
    }

    /// The celebration stopped at instants after t0 (debug build, `-UnlockFreezeMs`), one launch each, for comparing with
    /// the design's contact sheet. `TEST_RUNNER_UNLOCK_FRAMES=-1,0,840` picks the instants (-1: before t0, the button in
    /// flight) and `TEST_RUNNER_UNLOCK_ARGS` adds launch arguments (`-UnlockReduceMotion`, a Dynamic Type size, a language).
    @MainActor
    func testCelebrationFrames() throws {
        let env = ProcessInfo.processInfo.environment
        let frames = (env["UNLOCK_FRAMES"] ?? "-1,0,120,360,600,840,1200,1440,2200").split(separator: ",").map(String.init)
        let extra = (env["UNLOCK_ARGS"] ?? "").split(separator: " ").map(String.init)
        let tag = env["UNLOCK_TAG"] ?? "frame"
        for ms in frames {
            let app = XCUIApplication()
            app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-UNLOCK_TEST", "-UnlockAsNewUser", "-UnlockDemoStore",
                                    "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES", "-UnlockFreezeMs", ms] + extra
            app.launch()
            XCTAssertTrue(app.descendants(matching: .any)["cutlingCard"].firstMatch.waitForExistence(timeout: 30), "No cards")
            openNewTextCutling(app)
            let unlock = app.buttons["unlockButton"].firstMatch
            XCTAssertTrue(unlock.waitForExistence(timeout: 10), "The 6th cutling did not open the unlock screen")
            sleep(1)
            unlock.tap()
            sleep(3) // the demo purchase takes 1 s, then the 250 ms beat
            shot("\(tag)_\(ms)")
            let title = app.staticTexts["It's All Yours"].firstMatch
            let thanks = app.staticTexts["Thank you for supporting Cutling."].firstMatch
            NSLog("UNLOCKFRAME %@ button=%@ title=%@ subtitle=%@ close=%@", ms, "\(unlock.frame)", "\(title.frame)", "\(thanks.frame)", "\(app.buttons["notNowButton"].firstMatch.frame)")
            app.terminate()
        }
    }

    /// Plays the moment for real, unfrozen, with `TEST_RUNNER_UNLOCK_ARGS` as extra launch arguments (`-UnlockFrameMeter` writes
    /// /tmp/unlock-frames.json; `-UnlockReduceMotion`), and taps the sheet mid-moment when `TEST_RUNNER_UNLOCK_TAP_AT` (seconds
    /// after the tap on Unlock) is set, to check the jump to the end.
    @MainActor
    func testCelebrationPlays() throws {
        let env = ProcessInfo.processInfo.environment
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-UNLOCK_TEST", "-UnlockAsNewUser", "-UnlockDemoStore",
                                "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES"] + (env["UNLOCK_ARGS"] ?? "").split(separator: " ").map(String.init)
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["cutlingCard"].firstMatch.waitForExistence(timeout: 30), "No cards")
        openNewTextCutling(app)
        let unlock = app.buttons["unlockButton"].firstMatch
        XCTAssertTrue(unlock.waitForExistence(timeout: 10), "The 6th cutling did not open the unlock screen")
        sleep(1)
        unlock.tap()
        if let tapAt = env["UNLOCK_TAP_AT"].flatMap(Double.init) {
            Thread.sleep(forTimeInterval: tapAt)
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.62)).tap()
            Thread.sleep(forTimeInterval: 0.6)
            shot("tapped")
        }
        XCTAssertTrue(app.staticTexts["It's All Yours"].waitForExistence(timeout: 15), "No thank-you after buying")
        sleep(4)
        shot("played")
    }

    @MainActor
    func testSixthCutlingAsksToUnlockThenSaves() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-UNLOCK_TEST", "-UnlockAsNewUser", "-UnlockDemoStore",
                                "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES"]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["cutlingCard"].firstMatch.waitForExistence(timeout: 30), "No cards")
        sleep(2)
        shot("01_five_free")

        openNewTextCutling(app)
        let unlock = app.buttons["unlockButton"].firstMatch
        XCTAssertTrue(unlock.waitForExistence(timeout: 10), "The 6th cutling did not open the unlock screen")
        sleep(5) // long enough to read in the preview film
        shot("02_unlock_screen")

        unlock.tap()
        XCTAssertTrue(app.staticTexts["It's All Yours"].waitForExistence(timeout: 15), "No thank-you after buying")
        shot("03_unlocking")
        sleep(3) // the moment is 2.2 s
        shot("03_unlocked")
        unlock.tap() // Continue: from +, it opens the new cutling's editor
        XCTAssertTrue(unlock.waitForNonExistence(timeout: 10), "The unlock screen stayed after Continue")
        let name = app.textFields.matching(NSPredicate(format: "label != 'Search cutlings' AND placeholderValue != 'Search cutlings'")).firstMatch
        XCTAssertTrue(name.waitForExistence(timeout: 10), "The editor did not open after unlocking")
        name.tap()
        name.typeText("Wi-Fi password")
        // The text is written on its own page: the row opens it, Back returns to the form.
        let row = app.descendants(matching: .any)["textPageRow"].firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10), "No text row on the form")
        row.tap()
        let page = app.textViews["textPage"].firstMatch
        XCTAssertTrue(page.waitForExistence(timeout: 10), "The text page did not open")
        let tip = app.buttons["Continue"].firstMatch
        if tip.waitForExistence(timeout: 2) { tip.tap(); sleep(1) }
        page.tap()
        page.typeText("sunflower-garden-42")
        sleep(1)
        app.navigationBars.buttons.firstMatch.tap()
        sleep(1)
        shot("04_sixth_cutling")
        let save = app.buttons.matching(NSPredicate(format: "label == 'Save' OR label == 'Done' OR identifier == 'saveButton'")).firstMatch
        if save.waitForExistence(timeout: 5) { save.tap() }
        sleep(3)
        shot("05_six_cutlings")
        XCTAssertGreaterThanOrEqual(app.descendants(matching: .any).matching(identifier: "cutlingCard").count, 6, "The 6th cutling was not saved")
    }
}
