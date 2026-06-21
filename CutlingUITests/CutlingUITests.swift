//
//  CutlingUITests.swift
//  CutlingUITests
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import XCTest

final class CutlingUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private let logPath = "/Users/hafang/Repositories/Cutling/fastlane/screenshots/cutling_test.log"
    private let testStartTime = Date()

    private func log(_ message: String) {
        let elapsed = "\(Date().timeIntervalSince(testStartTime).formatted(.number.precision(.fractionLength(1))))s"
        let line = "[\(elapsed)] \(message)\n"
        let existing = (try? String(contentsOfFile: logPath, encoding: .utf8)) ?? ""
        try? (existing + line).write(toFile: logPath, atomically: true, encoding: .utf8)
    }

    /// Finds and long-presses the globe (keyboard switch) key.
    /// The globe key's label is localized ("Next keyboard", "次のキーボード", etc.),
    /// so we find it by its position: it's always the button immediately before the
    /// dictation button (id='dictation') in the accessibility hierarchy.
    @MainActor
    private func longPressGlobeKey(in app: XCUIApplication) -> Bool {
        // Wait for keyboard to appear via the dictation button (stable identifier).
        let dictation = app.buttons["dictation"].firstMatch
        guard dictation.waitForExistence(timeout: 5) else {
            log("GLOBE: dictation button not found — keyboard may not be visible")
            return false
        }

        // The globe key is the button right before dictation in the hierarchy.
        let allButtons = app.buttons.allElementsBoundByIndex
        for i in 0..<allButtons.count {
            if allButtons[i].identifier == "dictation" && i > 0 {
                let globe = allButtons[i - 1]
                log("GLOBE: Found at index \(i-1), label='\(globe.label)'")
                globe.press(forDuration: 1.0)
                sleep(1)
                return true
            }
        }

        log("GLOBE: Could not find globe key before dictation button")
        return false
    }

    /// Selects "Cutling" from the keyboard picker that appears after long-pressing globe.
    @MainActor
    private func selectCutlingFromPicker(in app: XCUIApplication) -> Bool {
        // Try as button first.
        let cutlingBtn = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Cutling'")
        ).firstMatch
        if cutlingBtn.waitForExistence(timeout: 2) {
            log("PICKER: Found Cutling as button")
            cutlingBtn.tap()
            sleep(1)
            return true
        }
        // Try as static text.
        let cutlingTxt = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Cutling'")
        ).firstMatch
        if cutlingTxt.waitForExistence(timeout: 2) {
            log("PICKER: Found Cutling as staticText")
            cutlingTxt.tap()
            sleep(1)
            return true
        }
        // Try as any element.
        let cutlingAny = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS[c] 'Cutling'")
        ).firstMatch
        if cutlingAny.waitForExistence(timeout: 2) {
            log("PICKER: Found Cutling as \(cutlingAny.elementType.rawValue)")
            cutlingAny.tap()
            sleep(1)
            return true
        }
        log("PICKER: Cutling not found")
        return false
    }

    @MainActor
    func testTakeScreenshots() throws {
        try? "".write(toFile: logPath, atomically: true, encoding: .utf8)
        log("========== TEST START ==========")

        // ── Step 0: Setup ────────────────────────────────────────
        log("S0: Disabling hardware keyboard")
        runHostCommand("/usr/bin/defaults", ["write", "com.apple.iphonesimulator", "ConnectHardwareKeyboard", "-bool", "false"])
        log("S0: Hardware keyboard disabled")

        log("S0: Setting simulator system language to English")
        runSimctl(["spawn", "booted", "defaults", "write", "-globalDomain", "AppleLanguages", "-array", "en"])
        runSimctl(["spawn", "booted", "defaults", "write", "-globalDomain", "AppleLocale", "en_US"])
        log("S0: Simulator language set to English")

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments.append("-SNAPSHOT_MODE")
        log("S0: Configured app with SNAPSHOT_MODE")

        log("S0: Launching app briefly to register keyboard extension")
        app.launch()
        sleep(2)
        app.terminate()
        sleep(1)
        log("S0: App terminated after registration launch")

        log("S0: Enabling Cutling keyboard in Settings")
        enableKeyboardInSettings()
        log("S0: Settings setup complete")

        // ── Screenshot 1: Main Grid ──────────────────────────────
        log("S1: Launching app")
        app.launch()
        log("S1: App launched, waiting for seed data")

        let firstCard = app.descendants(matching: .any)
            .matching(identifier: "cutlingCard").firstMatch
        let cardAppeared = firstCard.waitForExistence(timeout: 15)
        log("S1: cutlingCard appeared=\(cardAppeared)")
        XCTAssertTrue(cardAppeared, "Seed data cards did not appear")
        sleep(1)

        log("S1: Taking screenshot 02_MainGrid")
        snapshot("02_MainGrid")
        log("S1: Screenshot 02 done")

        // ── Screenshot 2: Detail View ────────────────────────────
        log("S2: Long-pressing first card for context menu")
        firstCard.press(forDuration: 1.5)

        let editButton = app.buttons["editButton"].firstMatch
        let editExists = editButton.waitForExistence(timeout: 5)
        log("S2: editButton exists=\(editExists)")
        XCTAssertTrue(editExists, "Edit button not found in context menu")

        log("S2: Tapping edit button")
        editButton.tap()
        sleep(1)

        let detailView = app.descendants(matching: .any).matching(identifier: "detailView").firstMatch
        let detailVisible = detailView.waitForExistence(timeout: 5)
        log("S2: detailView visible=\(detailVisible)")
        XCTAssertTrue(detailVisible, "Detail view not visible for screenshot 2")

        log("S2: Taking screenshot 03_DetailView")
        snapshot("03_DetailView")
        log("S2: Screenshot 03 done")

        log("S2: Navigating back to grid")
        let backButton = app.navigationBars.buttons.firstMatch
        let backExists = backButton.waitForExistence(timeout: 5)
        log("S2: Back button exists=\(backExists)")
        XCTAssertTrue(backExists, "Back button not found")
        backButton.tap()
        sleep(1)
        log("S2: Back at grid")

        // ── Screenshot 3: Keyboard Settings ──────────────────────
        log("S3: Looking for keyboard toolbar button")
        let kbButton = app.buttons["keyboardToolbarButton"].firstMatch
        let kbExists = kbButton.waitForExistence(timeout: 5)
        log("S3: keyboardToolbarButton exists=\(kbExists)")
        XCTAssertTrue(kbExists, "Keyboard toolbar button not found")

        log("S3: Tapping keyboard toolbar button")
        kbButton.tap()
        sleep(1)

        let keyboardView = app.descendants(matching: .any).matching(identifier: "keyboardView").firstMatch
        let keyboardViewVisible = keyboardView.waitForExistence(timeout: 5)
        log("S3: keyboardView visible=\(keyboardViewVisible)")
        XCTAssertTrue(keyboardViewVisible, "Keyboard view not visible for screenshot 3")

        log("S3: Taking screenshot 05_KeyboardSettings")
        snapshot("05_KeyboardSettings")
        log("S3: Screenshot 05 done")

        // ── Screenshot 4: Keyboard Test Page ─────────────────────
        log("S4: Looking for keyboardSetupGuide button")
        let setupGuideButton = app.buttons["keyboardSetupGuide"].firstMatch
        if !setupGuideButton.waitForExistence(timeout: 3) {
            log("S4: keyboardSetupGuide not visible, swiping up")
            app.swipeUp()
            sleep(1)
        }
        let guideExists = setupGuideButton.waitForExistence(timeout: 5)
        log("S4: keyboardSetupGuide exists=\(guideExists)")
        XCTAssertTrue(guideExists, "Keyboard Setup Guide not found")

        log("S4: Tapping setup guide")
        setupGuideButton.tap()
        sleep(1)

        log("S4: Navigating Welcome → Enable → Test (2 continue taps)")
        for i in 0..<2 {
            let continueButton = app.buttons["continueButton"].firstMatch
            let contExists = continueButton.waitForExistence(timeout: 3)
            log("S4: Continue tap \(i + 1)/2: button exists=\(contExists)")
            XCTAssertTrue(contExists, "Continue button not found (tap \(i))")
            continueButton.tap()
            sleep(1)
        }

        log("S4: Looking for keyboardTestField")
        let testField = app.textFields["keyboardTestField"].firstMatch
        let fieldExists = testField.waitForExistence(timeout: 3)
        log("S4: keyboardTestField exists=\(fieldExists)")
        if fieldExists {
            log("S4: Tapping test field")
            testField.tap()
        } else {
            log("S4: Test field not found, relying on auto-focus")
        }
        sleep(2)

        let cutlingKBElement = app.buttons.matching(
            NSPredicate(format: "identifier == 'CutlingKeyboardView'")
        ).firstMatch
        let cutlingAlreadyActive = cutlingKBElement.waitForExistence(timeout: 2)
        log("S4: CutlingKeyboardView already active=\(cutlingAlreadyActive)")

        if !cutlingAlreadyActive {
            log("S4: Attempting to switch keyboard via globe key")
            let pressedGlobe = longPressGlobeKey(in: app)
            log("S4: Globe key long-pressed=\(pressedGlobe)")

            if pressedGlobe {
                let selectedCutling = selectCutlingFromPicker(in: app)
                log("S4: Selected Cutling from picker=\(selectedCutling)")
            } else {
                log("S4: Globe key not found, proceeding with current keyboard")
            }
        }
        sleep(1)

        let testPage = app.descendants(matching: .any).matching(identifier: "testPage").firstMatch
        let testPageVisible = testPage.waitForExistence(timeout: 5)
        log("S4: testPage visible=\(testPageVisible)")
        XCTAssertTrue(testPageVisible, "Test page not visible for screenshot 4")

        log("S4: Taking screenshot 01_KeyboardInMessages")
        snapshot("01_KeyboardInMessages")
        log("S4: Screenshot 01 done")

        // ── Screenshot 5: How to Use Your Keyboard ───────────────
        // Always dismiss keyboard by tapping header area — the Return key
        // label is localized ("Return", "إرجاع", etc.) so matching by label is unreliable.
        log("S5: Dismissing keyboard by tapping header area")
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2)).tap()
        sleep(1)

        let continueBtn5 = app.buttons["continueButton"].firstMatch
        let cont5Visible = continueBtn5.waitForExistence(timeout: 3)
        log("S5: continueButton visible after dismiss=\(cont5Visible)")
        if !cont5Visible {
            log("S5: Keyboard may still be up, tapping header area again")
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15)).tap()
            sleep(1)
            let cont5Retry = continueBtn5.waitForExistence(timeout: 5)
            log("S5: continueButton visible after second dismiss=\(cont5Retry)")
        }

        let cont5Exists = continueBtn5.waitForExistence(timeout: 5)
        log("S5: continueButton final check=\(cont5Exists)")
        XCTAssertTrue(cont5Exists, "Continue button not found for step 5")

        log("S5: Tapping continue (Test → How to Use)")
        continueBtn5.tap()
        sleep(1)

        let howToUse = app.descendants(matching: .any).matching(identifier: "howToUsePage").firstMatch
        let howToUseVisible = howToUse.waitForExistence(timeout: 5)
        log("S5: howToUsePage visible=\(howToUseVisible)")
        XCTAssertTrue(howToUseVisible, "How to Use page not visible for screenshot 5")

        log("S5: Taking screenshot 04_KeyboardGuide")
        snapshot("04_KeyboardGuide")
        log("S5: Screenshot 04 done")

        log("========== TEST COMPLETE ==========")
    }

    // MARK: - Enable Keyboard via Settings App

    @MainActor
    private func enableKeyboardInSettings() {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        log("S0: Launching Settings app")
        settings.launch()
        sleep(1)
        log("S0: Settings app launched")

        // General
        let general = settings.cells.staticTexts["General"].firstMatch
        let generalExists = general.waitForExistence(timeout: 5)
        log("S0: 'General' cell exists=\(generalExists)")
        XCTAssertTrue(generalExists, "Settings: 'General' not found")
        log("S0: Tapping 'General'")
        general.tap()
        sleep(1)

        // Keyboard
        let keyboard = settings.cells.staticTexts["Keyboard"].firstMatch
        let keyboardExists = keyboard.waitForExistence(timeout: 5)
        log("S0: 'Keyboard' cell exists=\(keyboardExists)")
        XCTAssertTrue(keyboardExists, "Settings: 'Keyboard' not found")
        log("S0: Tapping 'Keyboard'")
        keyboard.tap()
        sleep(1)

        // Keyboards
        let keyboards = settings.cells.staticTexts["Keyboards"].firstMatch
        let keyboardsExists = keyboards.waitForExistence(timeout: 5)
        log("S0: 'Keyboards' cell exists=\(keyboardsExists)")
        XCTAssertTrue(keyboardsExists, "Settings: 'Keyboards' not found")
        log("S0: Tapping 'Keyboards'")
        keyboards.tap()
        sleep(1)

        // Check if Cutling is already added.
        let cutlingCell = settings.cells.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Cutling'")
        ).firstMatch
        let alreadyAdded = cutlingCell.exists
        log("S0: Cutling keyboard already added=\(alreadyAdded)")

        if !alreadyAdded {
            log("S0: Need to add Cutling keyboard")
            let addNew = settings.cells["AddNewKeyboard"].firstMatch
            for swipeAttempt in 0..<3 {
                if addNew.exists { break }
                log("S0: 'Add New Keyboard' not visible, swiping up (attempt \(swipeAttempt + 1)/3)")
                settings.swipeUp()
                sleep(1)
            }
            log("S0: 'Add New Keyboard' exists=\(addNew.exists)")
            XCTAssertTrue(addNew.exists, "Settings: 'Add New Keyboard' not found")
            log("S0: Tapping 'Add New Keyboard'")
            addNew.tap()
            sleep(1)

            let cutlingOption = settings.cells.staticTexts["Cutling"].firstMatch
            let optionExists = cutlingOption.waitForExistence(timeout: 3)
            log("S0: 'Cutling' in add list exists=\(optionExists)")
            if !optionExists {
                log("S0: 'Cutling' not visible, swiping up")
                settings.swipeUp()
                sleep(1)
            }
            log("S0: 'Cutling' in add list exists (after scroll)=\(cutlingOption.exists)")
            XCTAssertTrue(cutlingOption.exists, "Settings: 'Cutling' not in Add list")
            log("S0: Tapping 'Cutling' to add")
            cutlingOption.tap()
            sleep(1)
            log("S0: Cutling keyboard added")
        }

        // Tap Cutling entry to check Full Access.
        let cutlingEntry = settings.cells.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Cutling'")
        ).firstMatch
        let entryExists = cutlingEntry.waitForExistence(timeout: 5)
        log("S0: Cutling entry in keyboard list exists=\(entryExists)")
        XCTAssertTrue(entryExists, "Cutling entry not found")
        log("S0: Tapping Cutling entry to check Full Access")
        cutlingEntry.tap()
        sleep(1)

        // Toggle Full Access if needed.
        let fullAccessSwitch = settings.switches.matching(
            NSPredicate(format: "label CONTAINS[c] 'Allow Full Access'")
        ).firstMatch
        let switchExists = fullAccessSwitch.waitForExistence(timeout: 3)
        log("S0: 'Allow Full Access' switch exists=\(switchExists)")
        if switchExists {
            let val = fullAccessSwitch.value as? String ?? "?"
            log("S0: Full Access switch value=\(val) (0=off, 1=on)")
            if val == "0" {
                log("S0: Toggling Full Access on")
                fullAccessSwitch.switches.firstMatch.tap()
                sleep(2)

                let allowButton = settings.alerts.buttons["Allow"].firstMatch
                let alertExists = allowButton.waitForExistence(timeout: 3)
                log("S0: Alert 'Allow' button exists=\(alertExists)")
                if alertExists {
                    log("S0: Tapping 'Allow' in alert")
                    allowButton.tap()
                    sleep(1)
                }

                let sheetAllow = settings.sheets.buttons["Allow"].firstMatch
                let sheetExists = sheetAllow.waitForExistence(timeout: 2)
                log("S0: Sheet 'Allow' button exists=\(sheetExists)")
                if sheetExists {
                    log("S0: Tapping 'Allow' in sheet")
                    sheetAllow.tap()
                    sleep(1)
                }

                let anyAllow = settings.buttons["Allow Full Access"].firstMatch
                let anyExists = anyAllow.waitForExistence(timeout: 2)
                log("S0: 'Allow Full Access' button exists=\(anyExists)")
                if anyExists {
                    log("S0: Tapping 'Allow Full Access'")
                    anyAllow.tap()
                    sleep(1)
                }

                let finalVal = fullAccessSwitch.value as? String ?? "?"
                log("S0: Full Access switch value after toggle=\(finalVal)")
            } else {
                log("S0: Full Access already enabled, skipping toggle")
            }
        } else {
            log("S0: Full Access switch not found (may already be enabled)")
        }

        log("S0: Terminating Settings app")
        settings.terminate()
        sleep(1)
        log("S0: Settings app terminated")
    }

    // MARK: - Command Helpers

    private func runHostCommand(_ launchPath: String, _ arguments: [String]) {
        guard let taskClass = NSClassFromString("NSTask") as? NSObject.Type else { return }
        let task = taskClass.init()
        task.setValue(launchPath, forKey: "launchPath")
        task.setValue(arguments, forKey: "arguments")
        _ = unsafe task.perform(NSSelectorFromString("launch"))
        _ = unsafe task.perform(NSSelectorFromString("waitUntilExit"))
    }

    private func runSimctl(_ arguments: [String]) {
        runHostCommand("/usr/bin/xcrun", ["simctl"] + arguments)
    }
}
