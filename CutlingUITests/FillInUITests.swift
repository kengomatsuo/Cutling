//
//  FillInUITests.swift
//  CutlingUITests
//
//  Types cutlings with a date stamp, a typed blank, a choice and the cursor
//  spot through the Cutling keyboard, the way a person does: a name typed
//  first fills the first blank, or Type with Your Keyboard sends them to
//  their own keyboard and back; Next moves on, a choice finishes, and the
//  typed name is replaced by the finished text. Full account: docs/fill-ins.md
//  Screenshots go to $FORMAT_TEST_SHOTS when set.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

/// Marks the current What's New sheet as seen so it doesn't cover the grid (Cutling/AppleSheet.swift, WhatsNewKind.releaseID).
enum WhatsNewSkip {
    static let releaseID = "2026-11 fill-ins and room for more"
}

final class FillInUITests: XCTestCase {

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
            try? data.write(to: URL(fileURLWithPath: dir).appendingPathComponent("fillin_\(name).png"))
        }
    }

    @MainActor
    func testKeyboardFillsBlanksAndStamps() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST"]
        app.launch()
        app.terminate()
        addCutlingKeyboardInSettings()
        app.launch()

        let today: String = {
            let f = DateFormatter()
            f.calendar = Calendar(identifier: .gregorian)
            f.dateFormat = "yyyy-MM-dd"
            return f.string(from: Date())
        }()

        let field = openKeyboardTestField(in: app)
        func letters() {
            for _ in 0..<8 where !app.keys["a"].exists && !app.keys["A"].exists {
                let globe = keyboardGlobe(in: app)
                if globe.exists { globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
                sleep(1)
            }
            XCTAssertTrue(app.keys["a"].exists || app.keys["A"].exists, "No letter keyboard")
        }
        func button(_ name: String) -> XCUICoordinate {
            var frame: CGRect?
            for _ in 0..<10 {
                frame = cutlingKeyFrame(name, in: app)
                if frame != nil { break }
                usleep(500_000)
            }
            XCTAssertNotNil(frame, "No \(name) button on the Cutling keyboard (buttons: \(cutlingKeys(in: app)?.map(\.label) ?? []))")
            let f = frame ?? .zero
            // Reading the screen stalls the keyboard for a moment; a tap sooner can be lost (testReturnKeyInsertsOnLastBlank).
            sleep(2)
            return screenPoint(f.midX, f.midY, in: app)
        }

        // The first time Cutling's keyboard reports Full Access, the setup guide closes the keyboard
        // (KeyboardSetupView.refreshStatus); open the test field once more.
        continueAfterFailure = true
        switchToCutlingKeyboard(in: app, showing: "Reply")
        continueAfterFailure = false
        if !cutlingKeyboardIsUp(in: app, showing: "Reply") {
            app.terminate()
            app.launch()
            _ = openKeyboardTestField(in: app)
            switchToCutlingKeyboard(in: app, showing: "Reply")
        }
        XCTAssertTrue(cutlingKeyboardIsUp(in: app, showing: "Reply"), "Cutling keyboard did not come up")
        shot("01_keyboard")

        // A stamp alone types at once.
        button("Stamp").tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "Today: \(today)")

        // Type first: the name typed on the person's own keyboard fills the first blank.
        letters()
        field.typeText(" Sarah")
        switchToCutlingKeyboard(in: app, showing: "Reply")
        button("Reply").tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "Today: \(today) Sarah", "Nothing is typed before the blanks are filled")
        shot("02_name_typed_first")
        button("Next").tap()
        sleep(1)
        shot("03_plan")
        button("Pro").tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "Today: \(today) Hi Sarah, your Pro order ships \(today). Thanks!")
        shot("04_inserted")

        // Nothing typed first: Type with Your Keyboard, type the name there, come back.
        button("Reply").tap()
        sleep(1)
        _ = button("Sarah")  // used before, one tap away
        shot("05_saved_value")
        button("Type with Your Keyboard").tap()
        sleep(2)
        letters()
        field.typeText("Sam")
        switchToCutlingKeyboard(in: app)
        sleep(1)
        shot("06_back_with_typed_value")
        button("Next").tap()
        sleep(1)
        button("Insert").tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "Today: \(today) Hi Sarah, your Pro order ships \(today). Hi Sam, your Basic order ships \(today). Thanks! Thanks!")
        shot("07_inserted_again")
    }

    /// Tapping a card with blanks in the app asks for them in a sheet, then copies the finished text.
    @MainActor
    func testAppSheetFillsBeforeCopying() throws {
        let app = XCUIApplication()
        // Setup and the tutorial count as done, so nothing opens over the grid.
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST", "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES"]
        app.launch()
        let card = app.descendants(matching: .any).matching(identifier: "cutlingCard").firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 30), "No cards")
        // Copy from the card's menu: a tap's point on the combined card can land on its ⋯ Edit button.
        card.press(forDuration: 1.2)
        let copy = app.buttons["Copy"].firstMatch
        XCTAssertTrue(copy.waitForExistence(timeout: 5), "No Copy in the card's menu")
        copy.tap()
        let field = app.textFields["fillInField"].firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 10), "No fill-in sheet")
        field.tap()
        field.typeText("Sarah")
        sleep(1)
        shot("app_sheet")
        let preview = app.staticTexts["fillInPreview"].firstMatch
        XCTAssertTrue(preview.label.contains("Hi Sarah, your"), "Preview reads: \(preview.label)")
        // A choice on the last blank finishes: the sheet copies and closes.
        app.buttons["Pro"].firstMatch.tap()
        sleep(2)
        XCTAssertFalse(field.exists, "Sheet should close after the last choice")
        shot("app_sheet_copied")
    }

    /// The return key: Next on each blank, then the checkmark inserts the finished text.
    @MainActor
    func testReturnKeyInsertsOnLastBlank() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST"]
        app.launch()
        app.terminate()
        addCutlingKeyboardInSettings()
        app.launch()
        let field = openKeyboardTestField(in: app)
        continueAfterFailure = true
        switchToCutlingKeyboard(in: app, showing: "Reply")
        if !cutlingKeyboardIsUp(in: app, showing: "Reply") {
            app.terminate()
            app.launch()
            _ = openKeyboardTestField(in: app)
            switchToCutlingKeyboard(in: app, showing: "Reply")
        }
        func tap(_ name: String) {
            var frame: CGRect?
            for _ in 0..<10 {
                frame = cutlingKeyFrame(name, in: app)
                if frame != nil { break }
                usleep(500_000)
            }
            XCTAssertNotNil(frame, "No \(name) key (keys: \(cutlingKeys(in: app)?.map(\.label) ?? []))")
            guard let f = frame else { return }
            sleep(2)
            screenPoint(f.midX, f.midY, in: app).tap()
            sleep(2)
        }
        sleep(2)
        shot("keyboard_grid_previews")
        // A long cutling: the bar trims the words around the waiting blank, never the blank.
        tap("Order")
        shot("long_bar_first_blank")
        tap("Next")
        shot("long_bar_second_blank")
        tap("Cancel")
        tap("Reply")
        tap("Next")
        tap("Insert")
        var text = (field.value as? String) ?? ""
        if !text.contains("your Basic order ships") {
            print("RETURN-KEY: first checkmark tap did nothing; field reads: \(text)")
            shot("return_key_first_tap_missed")
            tap("Insert")
            text = (field.value as? String) ?? ""
            print("RETURN-KEY: after a second tap: \(text)")
        }
        XCTAssertTrue(text.contains("your Basic order ships"), "Field reads: \(text)")
    }

    /// The editor's Add Fill-in or Date menu, where a person puts blanks and dates into a cutling.
    @MainActor
    func testEditorMenuOffersFillIns() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST", "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES"]
        app.launch()
        let card = app.descendants(matching: .any).matching(identifier: "cutlingCard").firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 30), "No cards")
        // tap() lands on the card's ⋯ Edit button.
        card.tap()
        let menu = app.descendants(matching: .any)["addPlaceholderMenu"].firstMatch
        XCTAssertTrue(menu.waitForExistence(timeout: 10), "No Add Fill-in or Date menu in the editor")
        shot("editor_text_section")
        // While writing, the same menu sits on the bar above the keyboard.
        let text = app.textViews.firstMatch
        if text.waitForExistence(timeout: 5) {
            // The one-time tip may be up; its close button first, so the tap reaches the text.
            let closeTip = app.buttons["Close"].firstMatch
            if closeTip.waitForExistence(timeout: 2) { closeTip.tap(); sleep(1) }
            text.tap()
            sleep(2)
            shot("editor_keyboard_bar")
            XCTAssertTrue(app.descendants(matching: .any)["fillInKeyboardBar"].firstMatch.exists, "No fill-in buttons on the keyboard bar")
            // A new blank from the bar asks for its name, then shows as a pill.
            let fieldButton = app.buttons["Fill-in Field"].firstMatch
            if fieldButton.exists {
                fieldButton.tap()
                let nameField = app.alerts.textFields.firstMatch
                if nameField.waitForExistence(timeout: 5) {
                    // The name starts as "Name"; Done keeps it (typing needs a letter keyboard the queue may not show).
                    shot("editor_new_field_alert")
                    app.alerts.buttons["Done"].tap()
                    sleep(1)
                    shot("editor_new_field_pill")
                }
            }
        }
        menu.tap()
        sleep(1)
        shot("editor_menu_open")
        XCTAssertTrue(app.buttons["Fill-in Field"].firstMatch.waitForExistence(timeout: 5), "Menu has no Fill-in Field item")
    }

    /// With the fill-ins switch off, as in shipped builds until the redesign is approved, a card
    /// with blanks copies at once with its braces as written and the editor offers no fill-in menu.
    @MainActor
    func testSwitchOffAppKeepsBracesAsWritten() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST", "-FILLIN_OFF", "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES"]
        app.launch()
        let card = app.descendants(matching: .any).matching(identifier: "cutlingCard").firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 30), "No cards")
        card.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.75)).tap()
        XCTAssertFalse(app.textFields["fillInField"].firstMatch.waitForExistence(timeout: 4), "Fill-in sheet opened with the switch off")
        shot("switch_off_copied")
        // The editor (tap() lands on the card's ⋯ Edit button): its Text section, without the fill-in menu.
        card.tap()
        XCTAssertTrue(app.buttons["Paste from Clipboard"].firstMatch.waitForExistence(timeout: 10), "Editor's Text section did not load")
        shot("switch_off_editor")
        XCTAssertFalse(app.descendants(matching: .any)["addPlaceholderMenu"].exists, "Editor shows the fill-in menu with the switch off")
    }

    @MainActor
    func testSwitchOffKeyboardTypesBracesAsWritten() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST", "-FILLIN_OFF"]
        app.launch()
        app.terminate()
        addCutlingKeyboardInSettings()
        app.launch()
        let field = openKeyboardTestField(in: app)
        switchToCutlingKeyboard(in: app, showing: "Reply")
        XCTAssertTrue(cutlingKeyboardIsUp(in: app, showing: "Reply"), "Cutling keyboard did not come up")
        func button(_ name: String) -> XCUICoordinate {
            var frame: CGRect?
            for _ in 0..<10 {
                frame = cutlingKeyFrame(name, in: app)
                if frame != nil { break }
                usleep(500_000)
            }
            XCTAssertNotNil(frame, "No \(name) button on the Cutling keyboard")
            let f = frame ?? .zero
            return screenPoint(f.midX, f.midY, in: app)
        }
        button("Stamp").tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "Today: {date:yyyy-MM-dd}")
        button("Reply").tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "Today: {date:yyyy-MM-dd} Hi {Name}, your {Plan: Basic | Pro} order ships {date:yyyy-MM-dd}.{cursor} Thanks!")
        shot("switch_off_keyboard")
    }

    /// The same flow in a real web app's prompt box in Safari, where buyers asked for
    /// "variables in the snippets" for AI prompt templates. $FILLIN_SITE overrides the page.
    @MainActor
    func testKeyboardFillsBlanksInSafari() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST"]
        app.launch()
        app.terminate()
        addCutlingKeyboardInSettings()
        app.launch()
        sleep(3)

        let site = ProcessInfo.processInfo.environment["FILLIN_SITE"] ?? "https://chatgpt.com"
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.open(URL(string: site)!)
        XCTAssertTrue(safari.wait(for: .runningForeground, timeout: 20))
        sleep(8)
        shot("safari_01_page")

        // The page's prompt box: a contenteditable shows as a text view.
        let box = safari.webViews.textViews.firstMatch.exists ? safari.webViews.textViews.firstMatch : safari.webViews.textFields.firstMatch
        XCTAssertTrue(box.waitForExistence(timeout: 20), "No text box on \(site)")
        box.tap()
        XCTAssertTrue(safari.keyboards.firstMatch.waitForExistence(timeout: 20) || cutlingKeys(in: safari) != nil, "No keyboard in Safari")
        sleep(2)
        switchToCutlingKeyboard(in: safari, showing: "Reply")
        XCTAssertTrue(cutlingKeyboardIsUp(in: safari, showing: "Reply"), "Cutling keyboard did not come up in Safari")

        func button(_ name: String) -> XCUICoordinate {
            var frame: CGRect?
            for _ in 0..<10 {
                frame = cutlingKeyFrame(name, in: safari)
                if frame != nil { break }
                usleep(500_000)
            }
            XCTAssertNotNil(frame, "No \(name) button (buttons: \(cutlingKeys(in: safari)?.map(\.label) ?? []))")
            let f = frame ?? .zero
            return screenPoint(f.midX, f.midY, in: safari)
        }

        // Type first on the person's own keyboard, then fill the rest from Cutling.
        for _ in 0..<8 where !safari.keys["a"].exists && !safari.keys["A"].exists {
            let globe = keyboardGlobe(in: safari)
            if globe.exists { globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
            sleep(1)
        }
        box.typeText("Sarah")
        sleep(1)
        switchToCutlingKeyboard(in: safari, showing: "Reply")
        button("Reply").tap()
        sleep(2)
        shot("safari_02_panel")
        button("Next").tap()
        sleep(1)
        button("Pro").tap()
        sleep(2)
        shot("safari_03_done")
        let text = (box.value as? String) ?? ""
        XCTAssertTrue(text.contains("Hi Sarah, your Pro order ships"), "Prompt box reads: \(text)")
        XCTAssertTrue(text.contains("Thanks!"), "Prompt box reads: \(text)")
    }
}
