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

    private func log(_ message: String) {
        let existing = (try? String(contentsOfFile: "/tmp/cutling_test.log", encoding: .utf8)) ?? ""
        try? (existing + message + "\n").write(toFile: "/tmp/cutling_test.log", atomically: true, encoding: .utf8)
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
        try? "".write(toFile: "/tmp/cutling_test.log", atomically: true, encoding: .utf8)
        log("TEST START")

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments.append("-SNAPSHOT_MODE")

        // ── Step 0a: Launch app briefly to register the keyboard extension ──
        app.launch()
        sleep(2)
        app.terminate()
        sleep(1)

        // ── Step 0b: Enable the Cutling keyboard in Settings ─────
        log("STEP 0: enableKeyboardInSettings")
        enableKeyboardInSettings()
        log("STEP 0: DONE")

        // Now launch the actual app.
        app.launch()
        log("S1: App launched")

        // Wait for the seed-data grid to appear.
        let firstCard = app.descendants(matching: .any)
            .matching(identifier: "cutlingCard").firstMatch
        let cardAppeared = firstCard.waitForExistence(timeout: 15)
        log("S1: Card appeared=\(cardAppeared)")
        XCTAssertTrue(cardAppeared, "Seed data cards did not appear")
        sleep(1)

        // ── Screenshot 1: Main Grid ──────────────────────────────
        snapshot("01_MainGrid")
        log("S1: Screenshot 01 taken")

        // ── Screenshot 2: Detail View ────────────────────────────
        firstCard.press(forDuration: 1.5)
        let editButton = app.buttons["editButton"].firstMatch
        let editExists = editButton.waitForExistence(timeout: 5)
        log("S2: editButton exists=\(editExists)")
        XCTAssertTrue(editExists, "Edit button not found in context menu")
        editButton.tap()
        sleep(1)
        snapshot("02_DetailView")
        log("S2: Screenshot 02 taken")

        // Navigate back to the grid.
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button not found")
        backButton.tap()
        sleep(1)

        // ── Screenshot 3: Keyboard Settings ──────────────────────
        let kbButton = app.buttons["keyboardToolbarButton"].firstMatch
        XCTAssertTrue(kbButton.waitForExistence(timeout: 5), "Keyboard toolbar button not found")
        kbButton.tap()
        sleep(1)
        snapshot("03_KeyboardSettings")
        log("S3: Screenshot 03 taken")

        // ── Screenshot 4: Keyboard Test Page ──────────────────
        let setupGuideButton = app.buttons["keyboardSetupGuide"].firstMatch
        if !setupGuideButton.waitForExistence(timeout: 3) {
            app.swipeUp()
            sleep(1)
        }
        XCTAssertTrue(setupGuideButton.waitForExistence(timeout: 5), "Keyboard Setup Guide not found")
        setupGuideButton.tap()
        sleep(1)
        log("S4: Tapped setup guide")

        // Navigate from Welcome to Test page (2 taps: Welcome → Enable → Test).
        for i in 0..<2 {
            let continueButton = app.buttons["continueButton"].firstMatch
            let contExists = continueButton.waitForExistence(timeout: 3)
            log("S4: continueButton[\(i)] exists=\(contExists)")
            XCTAssertTrue(contExists, "Continue button not found (tap \(i))")
            continueButton.tap()
            sleep(1)
        }
        log("S4: On Test page")

        // Tap the text field to bring up the keyboard.
        let testField = app.textFields.firstMatch
        XCTAssertTrue(testField.waitForExistence(timeout: 5), "Text field not found")
        testField.tap()
        sleep(2)
        log("S4: Tapped text field")

        // Check if the Cutling keyboard is already active (common on iPad or
        // after a previous language run). Its buttons carry id='CutlingKeyboardView'.
        let cutlingKBElement = app.buttons.matching(
            NSPredicate(format: "identifier == 'CutlingKeyboardView'")
        ).firstMatch
        let cutlingAlreadyActive = cutlingKBElement.waitForExistence(timeout: 2)
        log("S4: Cutling keyboard already active=\(cutlingAlreadyActive)")

        if !cutlingAlreadyActive {
            // Switch to Cutling keyboard via globe key long-press.
            let pressedGlobe = longPressGlobeKey(in: app)
            log("S4: Globe key pressed=\(pressedGlobe)")

            if pressedGlobe {
                let selectedCutling = selectCutlingFromPicker(in: app)
                log("S4: Cutling selected=\(selectedCutling)")
                XCTAssertTrue(selectedCutling, "Cutling not found in keyboard picker")
            } else {
                // Dump buttons for debugging.
                log("S4: Globe key not found. Button dump:")
                for (i, btn) in app.buttons.allElementsBoundByIndex.prefix(25).enumerated() {
                    log("  btn[\(i)]: '\(btn.label)' id='\(btn.identifier)'")
                }
                XCTFail("Globe key not found — keyboard may not have appeared")
            }
        } else {
            log("S4: Cutling keyboard already active, skipping switch")
        }
        sleep(1)

        snapshot("04_KeyboardInMessages")
        log("S4: Screenshot 04 taken")

        // ── Screenshot 5: How to Use Your Keyboard ────────────
        // Dismiss keyboard by tapping the header area.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2)).tap()
        sleep(1)
        log("S5: Tapped to dismiss keyboard")

        let continueBtn5 = app.buttons["continueButton"].firstMatch
        let cont5Exists = continueBtn5.waitForExistence(timeout: 5)
        log("S5: continueButton exists=\(cont5Exists)")
        XCTAssertTrue(cont5Exists, "Continue button not found for step 5")
        continueBtn5.tap()
        sleep(1)

        snapshot("05_KeyboardGuide")
        log("S5: Screenshot 05 taken")
        log("TEST COMPLETE")
    }

    // MARK: - Enable Keyboard via Settings App

    @MainActor
    private func enableKeyboardInSettings() {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.launch()
        sleep(1)
        log("S0: Settings launched")

        // General
        let general = settings.cells.staticTexts["General"].firstMatch
        log("S0: General exists=\(general.waitForExistence(timeout: 5))")
        XCTAssertTrue(general.exists, "Settings: 'General' not found")
        general.tap()
        sleep(1)
        log("S0: tapped General")

        // Keyboard
        let keyboard = settings.cells.staticTexts["Keyboard"].firstMatch
        log("S0: Keyboard exists=\(keyboard.waitForExistence(timeout: 5))")
        XCTAssertTrue(keyboard.exists, "Settings: 'Keyboard' not found")
        keyboard.tap()
        sleep(1)
        log("S0: tapped Keyboard")

        // Keyboards
        let keyboards = settings.cells.staticTexts["Keyboards"].firstMatch
        log("S0: Keyboards exists=\(keyboards.waitForExistence(timeout: 5))")
        XCTAssertTrue(keyboards.exists, "Settings: 'Keyboards' not found")
        keyboards.tap()
        sleep(1)
        log("S0: tapped Keyboards")

        // Check if Cutling is already added.
        let cutlingCell = settings.cells.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Cutling'")
        ).firstMatch
        log("S0: Cutling already added=\(cutlingCell.exists)")

        if !cutlingCell.exists {
            let addNew = settings.cells["AddNewKeyboard"].firstMatch
            for swipeAttempt in 0..<3 {
                if addNew.exists { break }
                log("S0: 'Add New' not visible, swipe \(swipeAttempt)")
                settings.swipeUp()
                sleep(1)
            }
            XCTAssertTrue(addNew.exists, "Settings: 'Add New Keyboard' not found")
            addNew.tap()
            sleep(1)
            log("S0: tapped Add New Keyboard")

            let cutlingOption = settings.cells.staticTexts["Cutling"].firstMatch
            if !cutlingOption.waitForExistence(timeout: 3) {
                settings.swipeUp()
                sleep(1)
            }
            XCTAssertTrue(cutlingOption.exists, "Settings: 'Cutling' not in Add list")
            cutlingOption.tap()
            sleep(1)
            log("S0: tapped Cutling to add")
        }

        // Tap Cutling entry to check Full Access.
        let cutlingEntry = settings.cells.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Cutling'")
        ).firstMatch
        log("S0: Cutling entry exists=\(cutlingEntry.waitForExistence(timeout: 5))")
        XCTAssertTrue(cutlingEntry.exists, "Cutling entry not found")
        cutlingEntry.tap()
        sleep(1)
        log("S0: tapped Cutling entry for Full Access")

        // Toggle Full Access if needed.
        let fullAccessSwitch = settings.switches.matching(
            NSPredicate(format: "label CONTAINS[c] 'Allow Full Access'")
        ).firstMatch
        log("S0: Full Access switch exists=\(fullAccessSwitch.waitForExistence(timeout: 3))")
        if fullAccessSwitch.exists {
            let val = fullAccessSwitch.value as? String ?? "?"
            log("S0: Full Access value=\(val)")
            if val == "0" {
                fullAccessSwitch.switches.firstMatch.tap()
                sleep(2)
                let allowButton = settings.alerts.buttons["Allow"].firstMatch
                if allowButton.waitForExistence(timeout: 3) {
                    allowButton.tap()
                    sleep(1)
                    log("S0: tapped Allow in alert")
                }
                let sheetAllow = settings.sheets.buttons["Allow"].firstMatch
                if sheetAllow.waitForExistence(timeout: 2) {
                    sheetAllow.tap()
                    sleep(1)
                    log("S0: tapped Allow in sheet")
                }
                let anyAllow = settings.buttons["Allow Full Access"].firstMatch
                if anyAllow.waitForExistence(timeout: 2) {
                    anyAllow.tap()
                    sleep(1)
                    log("S0: tapped Allow Full Access button")
                }
            }
        }

        settings.terminate()
        sleep(1)
        log("S0: Settings terminated")
    }

    // MARK: - Simulator Command Helper

    private func runSimctl(_ arguments: [String]) {
        guard let taskClass = NSClassFromString("NSTask") as? NSObject.Type else { return }
        let task = taskClass.init()
        task.setValue("/usr/bin/xcrun", forKey: "launchPath")
        task.setValue(["simctl"] + arguments, forKey: "arguments")
        _ = task.perform(NSSelectorFromString("launch"))
        _ = task.perform(NSSelectorFromString("waitUntilExit"))
    }
}
