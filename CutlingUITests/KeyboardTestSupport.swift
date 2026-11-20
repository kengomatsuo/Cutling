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
    /// `onGrid` runs once the seeded grid shows, before the guide opens; pass `seeded: false`
    /// for an empty store, which has no card to wait for.
    @MainActor
    func openKeyboardTestField(in app: XCUIApplication, seeded: Bool = true, onGrid: () -> Void = {}) -> XCUIElement {
        // A first launch opens the setup guide itself; otherwise open it from the toolbar.
        if !app.buttons["continueButton"].firstMatch.waitForExistence(timeout: 5) {
            if seeded {
                let card = app.descendants(matching: .any).matching(identifier: "cutlingCard").firstMatch
                XCTAssertTrue(card.waitForExistence(timeout: 30), "Seeded cards did not appear")
            }
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
        // On a loaded Mac the first tap can land before the field takes focus; tap until a keyboard shows.
        // A retry taps only while no keyboard shows: a rising keyboard scrolls the page, and a tap at the
        // field's old place lands on whatever moved there (Continue, or empty space that closes the keyboard).
        for _ in 0..<3 {
            if field.isHittable { field.tap() }
            if app.keyboards.firstMatch.waitForExistence(timeout: 20) { break }
        }
        sleep(2)
        return field
    }

    /// The globe key, found by name: simulators place it differently (under the keys on most iPhones,
    /// in the bottom row of a wide one's), so no screen fraction finds it everywhere.
    /// Labels for the languages the tests and films run in.
    @MainActor
    func keyboardGlobe(in app: XCUIApplication) -> XCUIElement {
        let label = NSPredicate(format: "label ==[c] 'Next keyboard' OR label ==[c] 'Papan Ketik Berikutnya' OR label ==[c] '次のキーボード'")
        // Buttons and keys only: an any-type match found a non-key element whose press closed the keyboard.
        return onKeyboard(app.buttons.matching(label), in: app) ?? onKeyboard(app.keys.matching(label), in: app)
            ?? app.buttons["no globe key"]
    }

    /// A cutling's key on the Cutling keyboard, by the cutling's name. Its label is the name, then the text
    /// after a comma; an image key's placeholder icon can come first. The app's own cards and their inner parts
    /// can carry the same name, so only a match in the lower half of the screen, where every keyboard sits, counts.
    @MainActor
    func cutlingKey(_ name: String, in app: XCUIApplication) -> XCUIElement {
        let matches = app.buttons.matching(NSPredicate(
            format: "label == %@ OR label BEGINSWITH %@ OR label ENDSWITH %@", name, name + ",", ", " + name
        ))
        return onKeyboard(matches, in: app) ?? app.buttons["no key named \(name)"]
    }

    /// The first element of `query` in the lower half of the screen.
    @MainActor
    func onKeyboard(_ query: XCUIElementQuery, in app: XCUIApplication) -> XCUIElement? {
        let half = app.frame.height / 2
        return query.allElementsBoundByIndex.first { $0.exists && $0.frame.midY > half }
    }

    /// Cutling's keys are buttons, not keys, so zero keys with a globe on screen means Cutling is up; given a
    /// cutling's name, its key must show too. Keys also read zero mid-switch, so it must hold for two seconds.
    @MainActor
    func cutlingKeyboardIsUp(in app: XCUIApplication, showing name: String? = nil) -> Bool {
        var steady = 0
        for _ in 0..<10 {
            let shown = name.map { cutlingKey($0, in: app).exists } ?? keyboardGlobe(in: app).exists
            steady = app.keys.count == 0 && shown ? steady + 1 : 0
            if steady >= 4 { return true }
            usleep(500_000)
        }
        return false
    }

    /// Switches the focused field to the Cutling keyboard through the globe key.
    @MainActor
    func switchToCutlingKeyboard(in app: XCUIApplication, showing name: String? = nil) {
        // Long-pressing the globe lists every keyboard; pick Cutling there first.
        if !cutlingKeyboardIsUp(in: app, showing: name) {
            let globe = keyboardGlobe(in: app)
            XCTAssertTrue(globe.waitForExistence(timeout: 10), "No globe key (keys: \(app.keys.count))")
            globe.press(forDuration: 1.2)
            let entry = app.descendants(matching: .any)
                .matching(NSPredicate(format: "label == 'Cutling' AND elementType != %d", XCUIElement.ElementType.navigationBar.rawValue))
                .allElementsBoundByIndex.last
            if let entry, entry.exists, entry.isHittable { entry.tap() } else { globe.tap() }
            sleep(2)
        }
        // Each tap moves to the next keyboard; wait for each switch to land.
        for _ in 0..<10 where !cutlingKeyboardIsUp(in: app, showing: name) {
            let globe = keyboardGlobe(in: app)
            if globe.waitForExistence(timeout: 5) { globe.tap() }
            let tip = app.buttons.matching(NSPredicate(format: "label == 'Continue' AND identifier != 'continueButton'")).firstMatch
            if tip.waitForExistence(timeout: 1) { tip.tap(); sleep(1) }
        }
    }
}
