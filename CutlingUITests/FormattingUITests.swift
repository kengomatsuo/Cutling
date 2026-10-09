//
//  FormattingUITests.swift
//  CutlingUITests
//
//  Checks what the Cutling keyboard types for Plain, Formatted and Code
//  cutlings, and how the editor shows each format. Adds the keyboard
//  through Settings first.
//  Screenshots go to $FORMAT_TEST_SHOTS when set.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class FormattingUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func shot(_ name: String) {
        let data = XCUIScreen.main.screenshot().pngRepresentation
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.png")
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let dir = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"] {
            try? data.write(to: URL(fileURLWithPath: dir).appendingPathComponent("\(name).png"))
        }
    }

    /// Adds the Cutling keyboard with Full Access through Settings when it isn't there yet.
    @MainActor
    private func addKeyboardInSettings() {
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

    @MainActor
    func testKeyboardInsertsByFormat() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FORMAT_TEST"]
        // Launch once so iOS registers the keyboard extension, then add it.
        app.launch()
        app.terminate()
        addKeyboardInSettings()
        app.launch()

        // A first launch opens the setup guide itself; otherwise open it from the toolbar.
        if !app.buttons["continueButton"].firstMatch.waitForExistence(timeout: 5) {
            let card = app.descendants(matching: .any).matching(identifier: "cutlingCard").firstMatch
            XCTAssertTrue(card.waitForExistence(timeout: 15), "Seeded cards did not appear")
            shot("01_grid")
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

        // Cutling's keys aren't in the tree, so zero keys means Cutling is up.
        // The globe sits bottom-left under every keyboard; wait for each switch to land.
        // Keys also read zero mid-switch, so require it to hold for two seconds.
        func cutlingIsUp() -> Bool {
            var steady = 0
            for _ in 0..<10 {
                steady = app.keys.count == 0 && app.buttons["dictation"].exists ? steady + 1 : 0
                if steady >= 4 { return true }
                usleep(500_000)
            }
            return false
        }
        let globe = app.coordinate(withNormalizedOffset: CGVector(dx: 0.09, dy: 0.955))
        // Long-pressing the globe lists every keyboard; pick Cutling there first.
        if !cutlingIsUp() {
            globe.press(forDuration: 1.2)
            let entry = app.descendants(matching: .any)
                .matching(NSPredicate(format: "label == 'Cutling' AND elementType != %d", XCUIElement.ElementType.navigationBar.rawValue))
                .allElementsBoundByIndex.last
            if let entry, entry.exists, entry.isHittable { entry.tap() } else { globe.tap() }
            sleep(2)
        }
        for _ in 0..<10 where !cutlingIsUp() {
            globe.tap()
            let tip = app.buttons.matching(NSPredicate(format: "label == 'Continue' AND identifier != 'continueButton'")).firstMatch
            if tip.waitForExistence(timeout: 1) { tip.tap(); sleep(1) }
        }
        shot("02_keyboard")
        XCTAssertTrue(cutlingIsUp(), "Cutling keyboard did not come up (keys: \(app.keys.count))")

        // Two-column grid: Rich, Code / Plain.
        let rich = app.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.71))
        let code = app.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.71))
        let plain = app.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.80))

        // A Formatted tap copies the styled version (keyboards can't type styles).
        rich.tap()
        sleep(1)
        shot("03a_rich_copied")
        XCTAssertFalse((field.value as? String ?? "").contains("Bold"), "Formatted tap should copy, not type")

        code.tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "print(\"a_b\")", "Code should go in exactly")

        plain.tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "print(\"a_b\") Hello", "Plain should be spaced from the word before")
        shot("03_typed")

        // Long-press offers Type as Plain Text; the menu sits under the key.
        rich.press(forDuration: 1.2)
        sleep(1)
        shot("04_rich_menu")
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.33, dy: 0.97)).tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "print(\"a_b\") Hello Bold and link", "Long-press should type plain text")
        shot("04b_typed_plain")
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15)).tap()
        sleep(1)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15)).tap()
        sleep(1)

        // Finish the guide so the grid is reachable.
        for _ in 0..<6 {
            let cont = app.buttons["continueButton"].firstMatch
            guard cont.waitForExistence(timeout: 2), cont.isEnabled else { break }
            cont.tap()
            sleep(1)
        }

        // Opened from the toolbar, the Keyboard sheet is still on top.
        if app.descendants(matching: .any).matching(identifier: "keyboardView").firstMatch.exists {
            app.navigationBars.buttons.firstMatch.tap()
            sleep(1)
        }

        // Pasting three times can trigger the App Store rating prompt.
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for notNow in [app.buttons["Not Now"], springboard.buttons["Not Now"]] where notNow.waitForExistence(timeout: 2) {
            notNow.tap()
            sleep(1)
        }

        // The editor shows each cutling's format.
        let cards = app.descendants(matching: .any).matching(identifier: "cutlingCard")
        XCTAssertTrue(cards.firstMatch.waitForExistence(timeout: 10), "Grid not reachable")
        for (index, name) in ["05_editor_rich", "07_editor_code"].enumerated() {
            // The card's ⋯ button opens its editor.
            // Nested views share the card id, so place the tap on screen.
            app.coordinate(withNormalizedOffset: CGVector(dx: index == 0 ? 0.398 : 0.876, dy: 0.271)).tap()
            let detail = app.descendants(matching: .any).matching(identifier: "detailView").firstMatch
            XCTAssertTrue(detail.waitForExistence(timeout: 5), "Editor did not open")
            sleep(1)
            shot(name)
            // Formatted and Code show a chip; Plain shows none.
            let chip = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", index == 0 ? "Formatted" : "Code")).firstMatch
            XCTAssertTrue(chip.waitForExistence(timeout: 5), "Format chip missing")
            if index == 0 {
                chip.tap()
                sleep(1)
                shot("06_editor_chip_menu")
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
                sleep(1)
            }
            // The grid stays in the tree under a pushed editor, so wait for the editor to go.
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.092, dy: 0.096)).tap()
            sleep(2)
            XCTAssertFalse(detail.exists, "Editor did not close")
        }
    }

    /// Formats are detected, never picked: the chip only appears when the text isn't plain.
    @MainActor
    func testEditorDetectsFormat() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FORMAT_TEST"]
        app.launch()
        let cards = app.descendants(matching: .any).matching(identifier: "cutlingCard")
        XCTAssertTrue(cards.firstMatch.waitForExistence(timeout: 15), "Grid not reachable")
        let detail = app.descendants(matching: .any).matching(identifier: "detailView").firstMatch
        // Scoped to the editor: grid cards behind a sheet also carry these words.
        func chip(_ prefix: String) -> XCUIElement {
            detail.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).firstMatch
        }
        func closeEditor() {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.092, dy: 0.096)).tap()
            sleep(2)
        }

        // Seeded Formatted cutling: chip offers Plain Text / Formatted / Code.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.398, dy: 0.271)).tap()
        XCTAssertTrue(detail.waitForExistence(timeout: 5), "Editor did not open")
        XCTAssertTrue(chip("Formatted").waitForExistence(timeout: 5), "Formatted chip missing")
        // First Formatted text: a tip explains copy, then paste.
        let tip = app.staticTexts["Due to iOS keyboard limits, formatted text is copied, not typed."].firstMatch
        XCTAssertTrue(tip.waitForExistence(timeout: 5), "Paste tip missing")
        shot("10_editor_formatted")
        let closeTip = app.buttons.matching(NSPredicate(format: "label == 'Close'")).firstMatch
        if closeTip.exists { closeTip.tap(); sleep(1) }
        chip("Formatted").tap()
        sleep(1)
        shot("11_chip_menu")
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
        sleep(1)
        closeEditor()

        // Seeded Plain cutling: no chip.
        shot("11b_grid_after_close")
        // Tapping a card copies it; the card's ⋯ button opens the editor.
        // Cards share one id and the ⋯ is merged into the card element, so place the tap on screen.
        for _ in 0..<3 where !detail.exists {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.41, dy: 0.408)).tap()
            _ = detail.waitForExistence(timeout: 3)
        }
        shot("11c_after_plain_tap")
        XCTAssertTrue(detail.waitForExistence(timeout: 5))
        sleep(2)
        XCTAssertFalse(chip("Code").exists || chip("Formatted").exists, "Plain text should show no chip")
        shot("12_editor_plain")
        closeEditor()

        // A cutling saved before formats existed is detected as Code.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.887, dy: 0.408)).tap()
        XCTAssertTrue(detail.waitForExistence(timeout: 5))
        XCTAssertTrue(chip("Code").waitForExistence(timeout: 10), "Undecided code was not detected")
        shot("13_legacy_code")
        closeEditor()

        // Paste detection isn't covered here: on the iOS 27 simulator the app
        // reads an empty clipboard whatever the runner or `simctl pbcopy` puts there.
    }
}
