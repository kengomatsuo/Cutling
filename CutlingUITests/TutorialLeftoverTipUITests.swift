//
//  TutorialLeftoverTipUITests.swift
//  CutlingUITests
//
//  A walkthrough the app was killed in leaves nothing behind. Its editor tips ("Give your cutling a name.", "Now type the
//  text you want to save.", "Tap here to save your cutling.") show by a parameter the walkthrough sets while it runs;
//  TipKit keeps a parameter between launches unless it is transient, so a killed walkthrough put its tip on every editor
//  after it, and the tip took the first tap and drag (found in ASG63, where a test stopped mid-walkthrough did this).
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class TutorialLeftoverTipUITests: XCTestCase {

    private static let walkthroughTips = [
        "Give your cutling a name.", "Now type the text you want to save.", "Tap here to save your cutling.",
    ]

    override func setUpWithError() throws { continueAfterFailure = false }

    @MainActor
    func testKilledWalkthroughLeavesNoTipOnLaterEditors() throws {
        // The walkthrough as a new person starts it, to its name step, where its tip is up.
        let first = XCUIApplication()
        first.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-hasCompletedSetup", "YES",
                                  "-hasSeenInteractiveTutorial", "NO"]
        first.launch()
        sleep(4)
        let next = first.buttons.matching(NSPredicate(format: "identifier == 'tutorialNext' OR (label == 'Next' AND identifier == '')")).firstMatch
        XCTAssertTrue(next.waitForExistence(timeout: 10), "No Next on the walkthrough's first step")
        next.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        sleep(2)
        let add = first.buttons.matching(NSPredicate(format: "label == 'Add cutling'")).firstMatch
        XCTAssertTrue(add.waitForExistence(timeout: 10), "No + on the add step")
        add.tap()
        XCTAssertTrue(first.staticTexts["Give your cutling a name."].firstMatch.waitForExistence(timeout: 10),
                      "The walkthrough's name tip never showed, so the test did not reach the state it is about")
        // Killed, as by the system or a crash: no step of the walkthrough runs again.
        first.terminate()

        // The same install, no walkthrough running: a new cutling's editor.
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-hasCompletedSetup", "YES",
                                "-hasSeenInteractiveTutorial", "YES"]
        app.launch()
        sleep(3)
        let plus = app.buttons.matching(NSPredicate(format: "label == 'Add cutling'")).firstMatch
        XCTAssertTrue(plus.waitForExistence(timeout: 10), "No + on the list")
        plus.tap()
        let text = app.buttons["Text Cutling"].firstMatch
        if text.waitForExistence(timeout: 3) { text.tap() }
        XCTAssertTrue(app.descendants(matching: .any)["detailView"].firstMatch.waitForExistence(timeout: 10), "The editor did not open")
        // A tip appears a moment after its view does.
        sleep(4)
        for tip in Self.walkthroughTips {
            XCTAssertFalse(app.staticTexts[tip].firstMatch.exists, "The killed walkthrough's tip \"\(tip)\" is on a new cutling's editor")
        }
    }
}
