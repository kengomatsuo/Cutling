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

    @MainActor
    func testKeyboardInsertsByFormat() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FORMAT_TEST"]
        // Launch once so iOS registers the keyboard extension, then add it.
        app.launch()
        app.terminate()
        addCutlingKeyboardInSettings()
        app.launch()

        let field = openKeyboardTestField(in: app) { shot("01_grid") }
        switchToCutlingKeyboard(in: app)
        shot("02_keyboard")
        XCTAssertTrue(cutlingKeyboardIsUp(in: app), "Cutling keyboard did not come up (keys: \(app.keys.count))")

        // Two-column grid: Rich, Code / Plain.
        let rich = app.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.71))
        let code = app.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.71))
        let plain = app.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.80))

        // Every tap types: a Formatted key types its text plain, like the others.
        rich.tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "Bold and link", "Formatted tap should type its text")

        code.tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "Bold and linkprint(\"a_b\")", "Code should go in exactly")

        plain.tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "Bold and linkprint(\"a_b\") Hello", "Plain should be spaced from the word before")
        shot("03_typed")

        // Long-press on the Formatted key offers Copy, which copies the styled version.
        rich.press(forDuration: 1.2)
        sleep(1)
        shot("04_rich_menu")
        let copy = app.buttons["Copy"].firstMatch
        XCTAssertTrue(copy.waitForExistence(timeout: 3), "Long-press should offer Copy")
        copy.tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "Bold and linkprint(\"a_b\") Hello", "Copy should not type")
        shot("04b_rich_copied")
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
        shot("10_editor_formatted")
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
