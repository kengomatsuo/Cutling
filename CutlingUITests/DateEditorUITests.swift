//
//  DateEditorUITests.swift
//  CutlingUITests
//
//  A date pill and its editor, walked as a person would on the Text page: the text is cleared, Today's Date is
//  inserted from the Variables list, then the pill is opened and each kind, a day and a format are chosen in turn,
//  with Done after each so the pill in the text shows what it will type. A custom pattern is typed last.
//  One screenshot per state in $FORMAT_TEST_SHOTS as date_<nn>_<editor|text>_<what>.png.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class DateEditorUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDown() {
        XCUIDevice.shared.appearance = .light
    }

    private var step = 0

    private func shot(_ name: String) {
        step += 1
        let data = XCUIScreen.main.screenshot().pngRepresentation
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.png")
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let dir = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"] {
            let file = String(format: "date_%02d_%@.png", step, name)
            try? data.write(to: URL(fileURLWithPath: dir).appendingPathComponent(file))
        }
    }

    private func any(_ app: XCUIApplication, _ id: String) -> XCUIElement {
        app.descendants(matching: .any)[id].firstMatch
    }

    /// The editor's row for `title`, whatever else its label carries (a checkmark, a sample after a comma).
    private func row(_ app: XCUIApplication, _ title: String) -> XCUIElement {
        let escaped = NSRegularExpression.escapedPattern(for: title)
        // One query over buttons and cells, resolved when used, so a row scrolled into view is found.
        let types = [XCUIElement.ElementType.button.rawValue, XCUIElement.ElementType.cell.rawValue]
        let match = NSPredicate(format: "elementType IN %@ AND label MATCHES %@", types, "^(.*, )?\(escaped)(, .*)?$")
        return app.descendants(matching: .any).matching(match).firstMatch
    }

    /// Scrolls the editor until `element` can be tapped; the sheet opens at half height.
    @MainActor
    private func reach(_ app: XCUIApplication, _ element: XCUIElement) {
        for _ in 0..<6 where !(element.exists && element.isHittable) { scrollSheet(app) }
    }

    /// Drags the sheet's content up by its own position: the first collection view on screen can be the keyboard's grid.
    @MainActor
    private func scrollSheet(_ app: XCUIApplication) {
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85))
            .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)))
    }

    @MainActor
    private func openPill(_ app: XCUIApplication) {
        let text = app.textViews.firstMatch
        text.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: 28, dy: 14)).tap()
        XCTAssertTrue(app.buttons["fillInEditorDone"].waitForExistence(timeout: 5), "Tapping the date pill did not open its editor")
        sleep(1)
    }

    @MainActor
    private func choose(_ app: XCUIApplication, _ title: String, as name: String) {
        let option = row(app, title)
        reach(app, option)
        XCTAssertTrue(option.exists, "No \(title) row in the date editor")
        option.tap()
        sleep(1)
        shot("editor_\(name)")
        app.buttons["fillInEditorDone"].tap()
        sleep(2)
        shot("text_\(name)")
    }

    @MainActor
    func testDateEditorKinds() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST", "-hasCompletedSetup", "YES",
                                "-hasSeenInteractiveTutorial", "YES", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        XCUIDevice.shared.appearance = .light
        app.launch()
        let card = any(app, "cutlingCard")
        XCTAssertTrue(card.waitForExistence(timeout: 30), "No cards")
        let edit = app.buttons.matching(NSPredicate(format: "identifier == 'editButton' OR label == 'Edit'")).firstMatch
        for _ in 0..<3 where !edit.exists {
            card.press(forDuration: 1.6)
            _ = edit.waitForExistence(timeout: 8)
        }
        edit.tap()
        let page = any(app, "textPageRow")
        XCTAssertTrue(page.waitForExistence(timeout: 10), "No text box in the form")
        let closeTip = app.buttons["Close"].firstMatch
        if closeTip.waitForExistence(timeout: 2) { closeTip.tap(); sleep(1) }
        page.tap()
        XCTAssertTrue(any(app, "textPage").waitForExistence(timeout: 10), "The Text page did not open")
        let tip = app.buttons["Continue"].firstMatch
        if tip.waitForExistence(timeout: 3) { tip.tap(); sleep(1) }
        sleep(1)

        // An empty text, then one date pill at its start, so the pill is always at the same spot.
        let text = app.textViews.firstMatch
        text.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 200))
        // The bar above the keyboard and the one below the text both carry Variables; only one is on screen.
        let variables = app.buttons.matching(NSPredicate(format: "identifier == 'editorBar.curlybraces' OR label == 'Variables'"))
        sleep(1)
        let onScreen = (0..<variables.count).map { variables.element(boundBy: $0) }.first { $0.isHittable }
        (onScreen ?? variables.firstMatch).tap()
        XCTAssertTrue(any(app, "fillInPicker").waitForExistence(timeout: 5), "No Variables list")
        any(app, "fillInKind-date").tap()
        sleep(2)
        shot("text_inserted")

        openPill(app)
        shot("editor_opened")
        choose(app, "Weekday", as: "weekday")
        openPill(app)
        choose(app, "Date and Time", as: "datetime")
        openPill(app)
        choose(app, "Time", as: "time")
        openPill(app)
        choose(app, "Date", as: "date")
        openPill(app)
        choose(app, "Tomorrow", as: "tomorrow")
        openPill(app)
        choose(app, "Short", as: "short")
        openPill(app)
        choose(app, "ISO 8601", as: "iso")

        // A pattern of one's own: Custom shows a field with the guide under it.
        openPill(app)
        let custom = row(app, "Custom")
        reach(app, custom)
        if custom.exists {
            custom.tap()
            sleep(1)
            let field = any(app, "fillInDatePattern")
            reach(app, field)
            XCTAssertTrue(field.waitForExistence(timeout: 5), "Custom shows no pattern field")
            shot("editor_custom")
            field.tap()
            field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 30) + "EEEE d MMM")
            sleep(1)
            shot("editor_custom_typed")
            app.buttons["fillInEditorDone"].tap()
            sleep(2)
            shot("text_custom")
        } else {
            shot("editor_no_custom")
            app.buttons["fillInEditorDone"].tap()
            sleep(1)
        }

        // A day of one's own: the Day section's Custom, then two steps on with its stepper.
        openPill(app)
        let customs = app.buttons.matching(NSPredicate(format: "label MATCHES %@", "^(.*, )?Custom(, .*)?$"))
        for _ in 0..<6 where !(customs.count > 1 && customs.element(boundBy: 1).isHittable) { scrollSheet(app) }
        if customs.count > 1 {
            customs.element(boundBy: 1).tap()
            sleep(1)
            let stepper = any(app, "fillInDateStep")
            reach(app, stepper)
            shot("editor_custom_day")
            let more = stepper.buttons.element(boundBy: 1)
            if more.exists { more.tap(); more.tap() }
            sleep(1)
            shot("editor_custom_day_stepped")
            app.buttons["fillInEditorDone"].tap()
            sleep(2)
            shot("text_custom_day")
        } else {
            app.buttons["fillInEditorDone"].tap()
            sleep(1)
        }

        // Dark: the same pill and its editor.
        XCUIDevice.shared.appearance = .dark
        sleep(2)
        shot("text_dark")
        openPill(app)
        shot("editor_dark")
        app.terminate()
    }

    /// Apple's own one-pick lists in Settings, for where a list ticks its picked row: the date format, the temperature unit,
    /// Auto-Lock and Calendar's default alert. Each step is skipped if this iOS words or files it differently.
    @MainActor
    func testAppleCheckmarkLists() throws {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        settings.launch()
        @discardableResult
        func open(_ name: String) -> Bool {
            let target = settings.cells.containing(.staticText, identifier: name).firstMatch.exists
                ? settings.cells.containing(.staticText, identifier: name).firstMatch
                : settings.staticTexts[name].firstMatch
            for _ in 0..<8 where !(target.exists && target.isHittable) { settings.swipeUp(velocity: .slow) }
            guard target.exists else { return false }
            target.tap()
            sleep(1)
            return true
        }
        func back() {
            settings.navigationBars.buttons.firstMatch.tap()
            sleep(1)
        }
        func root() {
            settings.terminate()
            settings.launch()
            sleep(2)
        }
        if open("General"), open("Language & Region") {
            if open("Date Format") { shot("apple_settings_date_format"); back() }
            if open("Temperature") { shot("apple_settings_temperature"); back() }
            if open("First Day of Week") { shot("apple_settings_first_day_of_week"); back() }
        }
        root()
        if open("Display & Brightness"), open("Auto-Lock") { shot("apple_settings_auto_lock") }
        root()
        if open("Apps"), open("Calendar"), open("Default Alert Times"), open("Events") { shot("apple_calendar_default_alert") }
        settings.terminate()
    }
}
