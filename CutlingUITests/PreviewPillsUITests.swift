//
//  PreviewPillsUITests.swift
//  CutlingUITests
//
//  Every preview of a cutling's text draws its variables at the text's own size with wrapped lines 3 pt apart, as the
//  Text page does: the grid card, the card's long-press preview and the editor's form. Each is shot whole; the sizes
//  and gaps are measured from the shots.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class PreviewPillsUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
        XCUIDevice.shared.orientation = .portrait
        XCUIDevice.shared.appearance = .light
    }

    private func any(_ app: XCUIApplication, _ id: String) -> XCUIElement {
        app.descendants(matching: .any)[id].firstMatch
    }

    private func shot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testPreviewsDrawPillsAtTextSize() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST", "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES"]
        app.launch()
        let card = any(app, "cutlingCard")
        XCTAssertTrue(card.waitForExistence(timeout: 30), "No cards")
        sleep(2)
        shot("1_grid")

        // The long-press preview: the card lifted with its whole text.
        let edit = app.buttons.matching(NSPredicate(format: "identifier == 'editButton' OR label == 'Edit'")).firstMatch
        for _ in 0..<3 where !edit.exists {
            card.press(forDuration: 1.6)
            _ = edit.waitForExistence(timeout: 8)
        }
        sleep(1)
        shot("2_long_press_preview")

        // The editor's form, its text box.
        edit.tap()
        XCTAssertTrue(any(app, "textPageRow").waitForExistence(timeout: 40), "No text row on the form")
        sleep(2)
        shot("3_form")

        // The Text page itself, the reference.
        any(app, "textPageRow").tap()
        XCTAssertTrue(any(app, "textPage").waitForExistence(timeout: 40), "The Text page did not open")
        let tip = app.buttons["Continue"].firstMatch
        if tip.waitForExistence(timeout: 3) { tip.tap() }
        sleep(2)
        shot("4_text_page")
    }
}
