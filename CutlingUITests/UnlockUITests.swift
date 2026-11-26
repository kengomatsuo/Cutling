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
        let text = app.buttons["Text Cutling"].firstMatch
        if text.waitForExistence(timeout: 5) { text.tap() }
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
        sleep(3)
        shot("02_unlock_screen")

        unlock.tap()
        XCTAssertTrue(unlock.waitForNonExistence(timeout: 15), "The unlock screen stayed after buying")
        sleep(2)
        shot("03_unlocked")

        openNewTextCutling(app)
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
