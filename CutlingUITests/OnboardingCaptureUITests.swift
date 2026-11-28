//
//  OnboardingCaptureUITests.swift
//  CutlingUITests
//
//  Films the path a new buyer walks, from a fresh install to the first cutling, and the
//  What's New sheet an existing user sees after an update, so the onboarding and What's New
//  redesigns (ASG103, ASG105) are judged against shots of the real screens, Settings
//  included. Run it on a fresh install: the queue command uninstalls Cutling first
//  (docs/research/onboarding/README.md has the command).
//
//  Shots go to $FORMAT_TEST_SHOTS as NN_<what>.png.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class OnboardingCaptureUITests: XCTestCase {

    private var shotIndex = 0

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    @MainActor private func shot(_ name: String) {
        shotIndex += 1
        let png = XCUIScreen.main.screenshot().pngRepresentation
        let file = String(format: "%02d_%@.png", shotIndex, name)
        if let dir = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"] {
            try? png.write(to: URL(fileURLWithPath: dir).appendingPathComponent(file))
        }
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = file
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor private func tapContinue(_ app: XCUIApplication) {
        let cont = app.buttons["continueButton"].firstMatch
        XCTAssertTrue(cont.waitForExistence(timeout: 10), "Continue not found")
        for _ in 0..<10 where !cont.isEnabled { sleep(1) }
        cont.tap()
        sleep(2)
    }

    /// Fresh install to the grid: setup guide, the trip through Settings, the test field, the
    /// remaining pages, and the first tutorial steps.
    @MainActor
    func testFirstRun() throws {
        let app = XCUIApplication()
        app.launch()
        sleep(3)
        shot("setup_welcome")

        tapContinue(app)
        // A simulator whose Settings still lists the Cutling keyboard goes straight to Try It, as the guide should.
        let keyboardAlreadyAdded = app.textFields["keyboardTestField"].firstMatch.waitForExistence(timeout: 3)
        shot(keyboardAlreadyAdded ? "setup_try_it_keyboard_already_added" : "setup_enable")
        if !keyboardAlreadyAdded { addKeyboardFromGuide(app) }
        try walkTryItAndRest(app)
    }

    /// Add the Keyboard: the guide's own button, as a buyer would press it, Settings, and back.
    @MainActor private func addKeyboardFromGuide(_ app: XCUIApplication) {
        let openSettings = app.buttons["openSettingsButton"].firstMatch
        XCTAssertTrue(openSettings.waitForExistence(timeout: 5))
        openSettings.tap()
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        XCTAssertTrue(settings.wait(for: .runningForeground, timeout: 10))
        // Settings draws the app's page a few seconds after it comes forward.
        let keyboardsRow = settings.cells.staticTexts["Keyboards"].firstMatch
        let found = keyboardsRow.waitForExistence(timeout: 15)
        sleep(1)
        shot("settings_app_page")

        // On the app's own Settings page: Keyboards, then the Cutling and Full Access switches.
        if found {
            keyboardsRow.tap()
            sleep(2)
            shot("settings_keyboards_page")
            let cutlingSwitch = settings.switches.matching(NSPredicate(format: "label CONTAINS[c] 'Cutling'")).firstMatch
            if cutlingSwitch.waitForExistence(timeout: 3), cutlingSwitch.value as? String == "0" {
                settingsSwitch(cutlingSwitch).tap()
                sleep(1)
                shot("settings_keyboard_on")
            }
            let fullAccess = settings.switches.matching(NSPredicate(format: "label CONTAINS[c] 'Full Access'")).firstMatch
            if fullAccess.waitForExistence(timeout: 3), fullAccess.value as? String == "0" {
                settingsSwitch(fullAccess).tap()
                sleep(1)
                shot("settings_full_access_alert")
                let allow = settings.alerts.buttons["Allow"].firstMatch
                if allow.waitForExistence(timeout: 3) { allow.tap() }
                sleep(1)
                shot("settings_full_access_on")
            }
        } else {
            // No Keyboards row on the app's page: the General > Keyboard route.
            settings.terminate()
            addCutlingKeyboardInSettings()
        }

        // Back to Cutling, as the status bar's back link or the app switcher would.
        app.activate()
        sleep(3)
        shot("setup_enable_after_settings")
        tapContinue(app)
    }

    /// Try It with the Cutling keyboard, then the guide's remaining pages and the first tutorial steps.
    @MainActor private func walkTryItAndRest(_ app: XCUIApplication) throws {
        shot("setup_test_page")

        let field = app.textFields["keyboardTestField"].firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5), "Try It has no test field")
        field.tap()
        _ = app.keyboards.firstMatch.waitForExistence(timeout: 20)
        sleep(2)
        shot("setup_test_system_keyboard")
        switchToCutlingKeyboard(in: app, showing: "Try Me")
        sleep(2)
        shot("setup_test_cutling_keyboard")
        XCTAssertTrue(cutlingKeyboardIsUp(in: app, showing: "Try Me"), "The Cutling keyboard did not come up (keys: \(app.keys.count))")
        // Its Try Me key types into the field, as the page asks.
        if let key = cutlingKeyFrame("Try Me", in: app) {
            screenPoint(key.midX, key.midY, in: app).tap()
            sleep(2)
        }
        let typed = (field.value as? String) ?? ""
        XCTAssertFalse(typed.isEmpty || typed == field.placeholderValue, "Try Me typed nothing")
        // Full Access is reported by the keyboard itself once it has run.
        sleep(3)
        shot("setup_test_status")
        // Close the keyboard by tapping the page's title.
        app.staticTexts["Try It"].firstMatch.tap()
        sleep(1)
        tapContinue(app)
        shot("setup_what_you_can_do_top")
        let page = app.descendants(matching: .any).matching(identifier: "howToUsePage").firstMatch
        for _ in 0..<4 { page.swipeUp(); usleep(400_000) }
        sleep(2)
        shot("setup_what_you_can_do_bottom")
        tapContinue(app)
        shot("setup_icloud")
        tapContinue(app)
        sleep(1)
        shot("setup_done")
        tapContinue(app)
        sleep(3)
        shot("tutorial_first_step")

        // The tutorial's own Next, a few steps in, to see how it reads.
        for step in 2...4 {
            let next = app.buttons.matching(NSPredicate(format: "label == 'Next'")).firstMatch
            if next.waitForExistence(timeout: 3), next.isHittable {
                next.tap()
            } else {
                let add = app.buttons.matching(NSPredicate(format: "identifier == 'addButton' OR label CONTAINS[c] 'Add'")).firstMatch
                guard add.exists, add.isHittable else { break }
                add.tap()
            }
            sleep(2)
            shot("tutorial_step_\(step)")
        }
    }

    /// An existing user updating from an old version: the What's New sheet over the grid.
    @MainActor
    func testWhatsNewAfterUpdate() throws {
        let app = XCUIApplication()
        // Launch arguments win over stored defaults for this run only.
        app.launchArguments += ["-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES", "-lastVersionOpened", "1.4"]
        app.launch()
        sleep(4)
        shot("whatsnew_light")
        app.terminate()
        app.launchArguments += ["-SNAPSHOT_DARK", "YES"]
        app.launch()
        sleep(4)
        shot("whatsnew_dark")
    }
}
