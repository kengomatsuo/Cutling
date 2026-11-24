//
//  FormatVariablesUITests.swift
//  CutlingUITests
//
//  A variable in a cutling's text takes the formatting the words around it take, by every route the Text page offers:
//  the styles on the bar above the keyboard, the Aa Format panel and the keyboard shortcuts. The pill is selected on
//  its own with the arrow keys (a tap on a pill opens its editor), styled, and shot after each route; the pill's look
//  must change each time, the same route again must leave it plain and still selected, and the style must still be on
//  the pill after the cutling is saved and opened again.
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

    /// The share of pixels that differ between two crops of the same size (1 when they can't be compared).
    private func difference(_ a: Data, _ b: Data) -> Double {
        guard let ia = UIImage(data: a)?.cgImage, let ib = UIImage(data: b)?.cgImage,
              ia.width == ib.width, ia.height == ib.height else { return 1 }
        func pixels(_ image: CGImage) -> [UInt8] {
            var buffer = [UInt8](repeating: 0, count: image.width * image.height * 4)
            let context = CGContext(data: &buffer, width: image.width, height: image.height, bitsPerComponent: 8,
                                    bytesPerRow: image.width * 4, space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
            return buffer
        }
        let pa = pixels(ia), pb = pixels(ib)
        var changed = 0
        for i in stride(from: 0, to: pa.count, by: 4) where abs(Int(pa[i]) - Int(pb[i])) + abs(Int(pa[i + 1]) - Int(pb[i + 1])) + abs(Int(pa[i + 2]) - Int(pb[i + 2])) > 24 {
            changed += 1
        }
        return Double(changed) / Double(pa.count / 4)
    }

    /// The selected pill looks styled: its first line differs from the plain one.
    private func assertStyled(_ line: Data, _ plain: Data, _ what: String) {
        XCTAssertGreaterThan(difference(line, plain), 0.002, "\(what) left the selected pill looking the same")
    }

    /// The pill is plain again and still selected: its first line matches the plain one, handles and all.
    private func assertPlainAndSelected(_ line: Data, _ plain: Data, _ what: String) {
        XCTAssertLessThan(difference(line, plain), 0.002, "\(what): the pill did not go back to plain with its selection kept")
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
        // The page as it opens, nothing selected: what the reopened page is compared with at the end.
        let unselected = firstLine(app)
        selectPill(app)
        let plain = firstLine(app)
        shot("0_pill_selected")

        // 1. The bar's styles, each on, then off again with the pill still selected.
        for label in ["Bold", "Italic", "Underline", "Strikethrough", "Highlight"] {
            let button = barButton(app, label)
            guard button.waitForExistence(timeout: 3) else { XCTFail("No \(label) on the bar"); continue }
            button.tap()
            sleep(1)
            shot("1_bar_\(label)")
            assertStyled(firstLine(app), plain, "\(label) from the bar")
            barButton(app, label).tap()
            sleep(1)
            assertPlainAndSelected(firstLine(app), plain, "\(label) from the bar, tapped again")
            selectPill(app)
        }

        // 2. The keyboard shortcuts.
        for (key, name) in [("b", "Bold"), ("i", "Italic"), ("u", "Underline")] {
            app.textViews["textPage"].firstMatch.typeKey(key, modifierFlags: .command)
            sleep(1)
            shot("2_shortcut_\(name)")
            assertStyled(firstLine(app), plain, "⌘\(key.uppercased())")
            app.textViews["textPage"].firstMatch.typeKey(key, modifierFlags: .command)
            sleep(1)
            assertPlainAndSelected(firstLine(app), plain, "⌘\(key.uppercased()) again")
            selectPill(app)
        }

        // 3. The Aa Format panel: Bold on and off, then on for the save.
        barButton(app, "Format").tap()
        XCTAssertTrue(any(app, "formatPanel").waitForExistence(timeout: 5), "No Format panel")
        any(app, "format.bold").tap()
        sleep(1)
        shot("3_panel_Bold")
        assertStyled(firstLine(app), plain, "Bold from the Format panel")
        any(app, "format.bold").tap()
        sleep(1)
        assertPlainAndSelected(firstLine(app), plain, "Bold from the Format panel, tapped again")
        any(app, "format.bold").tap()
        sleep(1)
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
        assertStyled(firstLine(app), unselected, "Leaving the page and opening it again (the pill's bold)")
    }
}
