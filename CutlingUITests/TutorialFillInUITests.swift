//
//  TutorialFillInUITests.swift
//  CutlingUITests
//
//  The walkthrough from its first step to the fill-in step and past it, as a new person
//  meets it: the + opens the editor, the name is typed, the fill-in tip shows, and the
//  text opens on its own page, whose bar puts a blank in. Shots after every step
//  ($FORMAT_TEST_SHOTS), and the accessibility tree at the fill-in step and on the page.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class TutorialFillInUITests: SetupMockTestCase {

    @MainActor private func dump(_ app: XCUIApplication, _ name: String) {
        if let dir = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"] {
            try? app.debugDescription.write(to: URL(fileURLWithPath: dir).appendingPathComponent("a11y-\(name).txt"),
                                            atomically: true, encoding: .utf8)
        }
    }

    @MainActor private func any(_ app: XCUIApplication, _ id: String) -> XCUIElement {
        app.descendants(matching: .any)[id].firstMatch
    }

    @MainActor private func tapNext(_ app: XCUIApplication) -> Bool {
        let next = app.buttons.matching(NSPredicate(format: "label == 'Next'")).firstMatch
        guard next.waitForExistence(timeout: 6) else { return false }
        // The walkthrough's bar floats in its own layer, which XCUITest calls unhittable with the keyboard up.
        next.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        sleep(2)
        return true
    }

    @MainActor func testWalkthroughReachesABlank() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-hasCompletedSetup", "YES",
                                "-hasSeenInteractiveTutorial", "NO"]
        app.launch()
        sleep(4)
        shot("intro")
        XCTAssertTrue(tapNext(app), "No Next on the walkthrough's first step")
        shot("add_step")

        let add = app.buttons.matching(NSPredicate(format: "label == 'Add cutling'")).firstMatch
        XCTAssertTrue(add.waitForExistence(timeout: 6), "No + on the add step")
        add.tap()
        sleep(3)
        shot("name_step")
        app.typeText("Thanks")
        sleep(1)
        shot("name_typed")
        XCTAssertTrue(tapNext(app), "No Next after the name")
        // The step's tip, with the blank button's icon, before the person taps the box.
        let tip = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'As you type'")).firstMatch
        XCTAssertTrue(tip.waitForExistence(timeout: 8), "The fill-in step shows no tip")
        sleep(1)
        shot("fill_in_step")
        dump(app, "fill-in-step")

        // The walkthrough types in the form's own box (TextDetailView.textBox), with the variables bar above the keyboard.
        let box = app.textViews.firstMatch
        XCTAssertTrue(box.waitForExistence(timeout: 6), "No text box on the fill-in step")
        box.tap()
        sleep(2)
        app.typeText("Thanks for your order, ")
        sleep(1)
        shot("typing")
        dump(app, "typing")

        let blank = app.buttons["Ask Each Time"].firstMatch
        XCTAssertTrue(blank.waitForExistence(timeout: 6), "No Ask Each Time on the bar above the keyboard")
        blank.tap()
        sleep(2)
        shot("blank_sheet")
        dump(app, "blank-sheet")
        let done = app.buttons["fillInEditorDone"].firstMatch
        XCTAssertTrue(done.waitForExistence(timeout: 4), "No confirm on the blank's sheet")
        done.tap()
        sleep(2)
        shot("blank_in")
        dump(app, "blank-in")
        // The step is done once a blank is in: the walkthrough moves on to the save step by itself.
        XCTAssertTrue(app.staticTexts["Now type the text you want to save."].firstMatch.waitForExistence(timeout: 4)
                      || app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS '5 / 13' OR label CONTAINS '5/13'")).firstMatch.exists,
                      "The walkthrough did not move past the fill-in step after a blank went in")
    }
}
