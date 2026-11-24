//
//  FormatVariablesUITests.swift
//  CutlingUITests
//
//  A variable in a cutling's text takes the formatting the words around it take, by every route the Text page offers:
//  the styles on the bar above the keyboard, the Aa Format panel and the keyboard shortcuts. The pill is selected on
//  its own with the arrow keys (a tap on a pill opens its editor), styled, and shot after each route; the pill's look
//  must change each time, and the style must still be on the pill after the cutling is saved and opened again.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class FormatVariablesUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
        XCUIDevice.shared.orientation = .portrait
        XCUIDevice.shared.appearance = .light
    }

    private func any(_ app: XCUIApplication, _ id: String) -> XCUIElement {
        app.descendants(matching: .any)[id].firstMatch
    }

    private func shot(_ name: String) {
        let data = XCUIScreen.main.screenshot().pngRepresentation
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.png")
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let dir = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"] {
            try? data.write(to: URL(fileURLWithPath: dir).appendingPathComponent("fmtvar_\(name).png"))
        }
    }

    /// The first line of the page's text as drawn, where the "Name" pill sits.
    @MainActor
    private func firstLine(_ app: XCUIApplication) -> Data {
        let text = app.textViews["textPage"].firstMatch
        let frame = text.frame
        let full = XCUIScreen.main.screenshot().image
        let scale = full.scale
        let rect = CGRect(x: frame.minX * scale, y: frame.minY * scale, width: frame.width * scale, height: 30 * scale)
        guard let cg = full.cgImage?.cropping(to: rect) else { return Data() }
        return UIImage(cgImage: cg).pngData() ?? Data()
    }

    @MainActor
    private func openPage(_ app: XCUIApplication) {
        let card = any(app, "cutlingCard")
        XCTAssertTrue(card.waitForExistence(timeout: 30), "No cards")
        let edit = app.buttons.matching(NSPredicate(format: "identifier == 'editButton' OR label == 'Edit'")).firstMatch
        for _ in 0..<3 where !edit.exists {
            card.press(forDuration: 1.6)
            _ = edit.waitForExistence(timeout: 8)
        }
        edit.tap()
        let row = any(app, "textPageRow")
        XCTAssertTrue(row.waitForExistence(timeout: 40), "No text row on the form")
        let closeTip = app.buttons["Close"].firstMatch
        if closeTip.waitForExistence(timeout: 2) { closeTip.tap(); sleep(1) }
        row.tap()
        XCTAssertTrue(any(app, "textPage").waitForExistence(timeout: 40), "The Text page did not open")
        let tip = app.buttons["Continue"].firstMatch
        if tip.waitForExistence(timeout: 3) { tip.tap(); sleep(1) }
        XCTAssertTrue(any(app, "fillInKeyboardBar").waitForExistence(timeout: 40), "No bar above the keyboard")
        sleep(1)
    }

    /// Selects the "Name" pill alone: the text is "Hi {Name}, …", so the pill is the fourth character.
    @MainActor
    private func selectPill(_ app: XCUIApplication) {
        let text = app.textViews["textPage"].firstMatch
        text.typeKey(.upArrow, modifierFlags: .command)
        for _ in 0..<3 { text.typeKey(.rightArrow, modifierFlags: []) }
        text.typeKey(.rightArrow, modifierFlags: .shift)
        sleep(1)
    }

    @MainActor
    private func barButton(_ app: XCUIApplication, _ label: String) -> XCUIElement {
        let bar = any(app, "fillInKeyboardBar")
        let button = bar.buttons[label].firstMatch
        for _ in 0..<3 where !button.isHittable { bar.swipeLeft() }
        return button
    }

    @MainActor
    func testEveryRouteFormatsAVariable() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST", "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES"]
        app.launch()
        openPage(app)
        selectPill(app)
        let plain = firstLine(app)
        shot("0_pill_selected")

        // 1. The bar's styles, each on and off again.
        for label in ["Bold", "Italic", "Underline", "Strikethrough", "Highlight"] {
            let button = barButton(app, label)
            guard button.waitForExistence(timeout: 3) else { XCTFail("No \(label) on the bar"); continue }
            button.tap()
            sleep(1)
            shot("1_bar_\(label)")
            XCTAssertNotEqual(firstLine(app), plain, "\(label) from the bar left the selected pill looking the same")
            barButton(app, label).tap()
            sleep(1)
            selectPill(app)
        }

        // 2. The keyboard shortcuts.
        for (key, name) in [("b", "Bold"), ("i", "Italic"), ("u", "Underline")] {
            app.textViews["textPage"].firstMatch.typeKey(key, modifierFlags: .command)
            sleep(1)
            shot("2_shortcut_\(name)")
            XCTAssertNotEqual(firstLine(app), plain, "⌘\(key.uppercased()) left the selected pill looking the same")
            app.textViews["textPage"].firstMatch.typeKey(key, modifierFlags: .command)
            sleep(1)
            selectPill(app)
        }

        // 3. The Aa Format panel.
        barButton(app, "Format").tap()
        XCTAssertTrue(any(app, "formatPanel").waitForExistence(timeout: 5), "No Format panel")
        any(app, "format.bold").tap()
        sleep(1)
        shot("3_panel_Bold")
        XCTAssertNotEqual(firstLine(app), plain, "Bold from the Format panel left the selected pill looking the same")
        app.buttons["formatPanelClose"].firstMatch.tap()
        sleep(1)

        // 4. Bold kept through saving and opening again.
        let done = app.buttons.matching(NSPredicate(format: "label == 'Done' OR identifier == 'textPageDone'")).firstMatch
        if done.waitForExistence(timeout: 3) { done.tap() }
        app.navigationBars.buttons.element(boundBy: 0).tap()
        sleep(1)
        shot("4_form_after")
        any(app, "textPageRow").tap()
        XCTAssertTrue(any(app, "textPage").waitForExistence(timeout: 10), "The Text page did not open again")
        sleep(2)
        shot("4_page_reopened")
        XCTAssertNotEqual(firstLine(app), plain, "The pill's bold did not survive leaving the page and opening it again")
    }
}
