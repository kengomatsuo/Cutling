//
//  KeyboardTestSupport.swift
//  CutlingUITests
//
//  Steps every keyboard UI test shares: add the Cutling keyboard in
//  Settings, open the setup guide's test field, and bring the Cutling
//  keyboard up in it.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

extension XCTestCase {

    /// Adds the Cutling keyboard with Full Access through Settings when it isn't there yet.
    @MainActor
    func addCutlingKeyboardInSettings() {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.launch()
        for label in ["General", "Keyboard", "Keyboards"] {
            let cell = settings.cells.staticTexts[label].firstMatch
            XCTAssertTrue(cell.waitForExistence(timeout: 5), "Settings: '\(label)' not found")
            cell.tap()
            sleep(1)
        }
        let cutling = settings.cells.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Cutling'")).firstMatch
        if !cutling.exists {
            let addNew = settings.cells["AddNewKeyboard"].firstMatch
            if !addNew.exists { settings.swipeUp() }
            addNew.tap()
            let option = settings.cells.staticTexts["Cutling"].firstMatch
            if !option.waitForExistence(timeout: 3) { settings.swipeUp() }
            option.tap()
            sleep(1)
        }
        XCTAssertTrue(cutling.waitForExistence(timeout: 5), "Cutling keyboard not added")
        cutling.tap()
        let fullAccess = settings.switches.matching(NSPredicate(format: "label CONTAINS[c] 'Allow Full Access'")).firstMatch
        if fullAccess.waitForExistence(timeout: 3), fullAccess.value as? String == "0" {
            fullAccess.switches.firstMatch.tap()
            let allow = settings.alerts.buttons["Allow"].firstMatch
            if allow.waitForExistence(timeout: 3) { allow.tap() }
        }
        settings.terminate()
    }

    /// Opens the setup guide's keyboard test field and focuses it.
    /// `onGrid` runs once the seeded grid shows, before the guide opens.
    @MainActor
    func openKeyboardTestField(in app: XCUIApplication, onGrid: () -> Void = {}) -> XCUIElement {
        // A first launch opens the setup guide itself; otherwise open it from the toolbar.
        if !app.buttons["continueButton"].firstMatch.waitForExistence(timeout: 5) {
            let card = app.descendants(matching: .any).matching(identifier: "cutlingCard").firstMatch
            XCTAssertTrue(card.waitForExistence(timeout: 30), "Seeded cards did not appear")
            onGrid()
            let kbButton = app.buttons["keyboardToolbarButton"].firstMatch
            XCTAssertTrue(kbButton.waitForExistence(timeout: 5))
            kbButton.tap()
            let guide = app.buttons["keyboardSetupGuide"].firstMatch
            if !guide.waitForExistence(timeout: 3) { app.swipeUp() }
            XCTAssertTrue(guide.waitForExistence(timeout: 5))
            // The sheet can still be animating in; retry until the guide opens.
            for _ in 0..<3 where !app.buttons["continueButton"].firstMatch.waitForExistence(timeout: 3) {
                guide.tap()
            }
        }
        // The guide reopens on its last page: step back to the first, then forward to the test page.
        let field = app.textFields["keyboardTestField"].firstMatch
        for _ in 0..<6 where !field.exists {
            let back = app.navigationBars.buttons.firstMatch
            guard back.exists else { break }
            back.tap()
            sleep(1)
        }
        for _ in 0..<2 where !field.exists {
            let cont = app.buttons["continueButton"].firstMatch
            XCTAssertTrue(cont.waitForExistence(timeout: 3))
            cont.tap()
            sleep(1)
        }
        XCTAssertTrue(field.waitForExistence(timeout: 3), "Keyboard test field not found")
        field.tap()
        sleep(2)
        return field
    }

    /// Cutling's keys aren't in the tree, so zero keys means Cutling is up.
    /// Keys also read zero mid-switch, so it must hold for two seconds.
    @MainActor
    func cutlingKeyboardIsUp(in app: XCUIApplication) -> Bool {
        var steady = 0
        for _ in 0..<10 {
            steady = app.keys.count == 0 && app.buttons["dictation"].exists ? steady + 1 : 0
            if steady >= 4 { return true }
            usleep(500_000)
        }
        return false
    }

    /// Switches the focused field to the Cutling keyboard through the globe key.
    @MainActor
    func switchToCutlingKeyboard(in app: XCUIApplication) {
        // The globe sits bottom-left under every keyboard; wait for each switch to land.
        let globe = app.coordinate(withNormalizedOffset: CGVector(dx: 0.09, dy: 0.955))
        // Long-pressing the globe lists every keyboard; pick Cutling there first.
        if !cutlingKeyboardIsUp(in: app) {
            globe.press(forDuration: 1.2)
            let entry = app.descendants(matching: .any)
                .matching(NSPredicate(format: "label == 'Cutling' AND elementType != %d", XCUIElement.ElementType.navigationBar.rawValue))
                .allElementsBoundByIndex.last
            if let entry, entry.exists, entry.isHittable { entry.tap() } else { globe.tap() }
            sleep(2)
        }
        for _ in 0..<10 where !cutlingKeyboardIsUp(in: app) {
            globe.tap()
            let tip = app.buttons.matching(NSPredicate(format: "label == 'Continue' AND identifier != 'continueButton'")).firstMatch
            if tip.waitForExistence(timeout: 1) { tip.tap(); sleep(1) }
        }
    }
}
