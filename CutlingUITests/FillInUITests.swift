//
//  FillInUITests.swift
//  CutlingUITests
//
//  Types cutlings with a date stamp, a typed blank, a choice and the cursor
//  spot through the Cutling keyboard, the way a person does: Cutling stops
//  at the blank, the person switches to their own keyboard and types it,
//  comes back and taps Next, then taps a choice. Full account: docs/fill-ins.md
//  Screenshots go to $FORMAT_TEST_SHOTS when set.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

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
        app.launchArguments += ["-FILLIN_TEST"]
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
        switchToCutlingKeyboard(in: app, showing: "Reply")
        XCTAssertTrue(cutlingKeyboardIsUp(in: app, showing: "Reply"), "Cutling keyboard did not come up")
        shot("01_keyboard")

        func button(_ name: String) -> XCUICoordinate {
            var frame: CGRect?
            for _ in 0..<10 {
                frame = cutlingKeyFrame(name, in: app)
                if frame != nil { break }
                usleep(500_000)
            }
            XCTAssertNotNil(frame, "No \(name) button on the Cutling keyboard (buttons: \(cutlingKeys(in: app)?.map(\.label) ?? []))")
            let f = frame ?? .zero
            return screenPoint(f.midX, f.midY, in: app)
        }

        // A stamp alone types at once.
        button("Stamp").tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "Today: \(today)")

        // A blank stops typing and shows the panel.
        button("Reply").tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "Today: \(today) Hi ")
        shot("02_panel_name")

        // The person switches to their own keyboard, types the name in place and comes back.
        let globe = button("Next keyboard")
        globe.tap()
        for _ in 0..<6 where !app.keys["a"].exists && !app.keys["A"].exists {
            sleep(1)
            let systemGlobe = keyboardGlobe(in: app)
            if systemGlobe.exists, !app.keys["a"].exists, !app.keys["A"].exists { systemGlobe.tap() }
        }
        XCTAssertTrue(app.keys["a"].exists || app.keys["A"].exists, "No letter keyboard to type the blank with")
        field.typeText("Sarah")
        sleep(1)
        XCTAssertEqual(field.value as? String, "Today: \(today) Hi Sarah")
        switchToCutlingKeyboard(in: app)
        shot("03_back_at_name")
        button("Next").tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "Today: \(today) Hi Sarah, your ")
        shot("04_panel_plan")

        // A choice fills the last blank; the rest is typed and the cursor goes back to {cursor}.
        button("Pro").tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "Today: \(today) Hi Sarah, your Pro order ships \(today). Thanks!")
        shot("05_done")

        // The next key types at the cursor spot, before " Thanks!".
        button("Stamp").tap()
        sleep(1)
        XCTAssertEqual(field.value as? String, "Today: \(today) Hi Sarah, your Pro order ships \(today). Today: \(today) Thanks!")

        // "Sarah" is now a saved value, offered with one tap next time.
        button("Reply").tap()
        sleep(1)
        _ = button("Sarah")
        shot("06_saved_value")
        button("Cancel").tap()
    }

    /// Tapping a card with blanks in the app asks for them in a sheet, then copies the finished text.
    @MainActor
    func testAppSheetFillsBeforeCopying() throws {
        let app = XCUIApplication()
        // Setup and the tutorial count as done, so nothing opens over the grid.
        app.launchArguments += ["-FILLIN_TEST", "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES"]
        app.launch()
        let card = app.descendants(matching: .any).matching(identifier: "cutlingCard").firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 30), "No cards")
        card.tap()
        let field = app.textFields["fillInField"].firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 10), "No fill-in sheet")
        field.tap()
        field.typeText("Sarah")
        app.buttons["Pro"].firstMatch.tap()
        sleep(1)
        shot("app_sheet")
        let preview = app.staticTexts["fillInPreview"].firstMatch
        XCTAssertTrue((preview.label).contains("Hi Sarah, your Pro order ships"), "Preview reads: \(preview.label)")
        app.buttons["fillInDone"].firstMatch.tap()
        sleep(1)
        XCTAssertFalse(field.exists, "Sheet should close after Copy")
    }

    /// The same flow in a real web app's prompt box in Safari, where buyers asked for
    /// "variables in the snippets" for AI prompt templates. $FILLIN_SITE overrides the page.
    @MainActor
    func testKeyboardFillsBlanksInSafari() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FILLIN_TEST"]
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

        button("Reply").tap()
        sleep(2)
        shot("safari_02_panel")
        button("Next keyboard").tap()
        for _ in 0..<6 where !safari.keys["a"].exists && !safari.keys["A"].exists {
            sleep(1)
            let globe = keyboardGlobe(in: safari)
            if globe.exists, !safari.keys["a"].exists, !safari.keys["A"].exists { globe.tap() }
        }
        box.typeText("Sarah")
        sleep(1)
        switchToCutlingKeyboard(in: safari)
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
