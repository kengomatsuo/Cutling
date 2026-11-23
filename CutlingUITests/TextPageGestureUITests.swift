//
//  TextPageGestureUITests.swift
//  CutlingUITests
//
//  The Text page against Notes' own behaviour, from the owner's TestFlight report (card ASG158):
//  a drag in the text scrolls it and pulls the keyboard down as Notes does, and never closes the editor around the page,
//  whether the editor is the New sheet or an existing cutling opened from its card; the back button and a swipe from
//  the left edge still go back to the form. A second test opens and closes the Aa Format card with pauses around each,
//  so the run's screen recording (run.mp4) holds each transition alone for a frame-by-frame sheet against Notes.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class TextPageGestureUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        // A run before this one can leave the simulator turned sideways.
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDown() {
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
            try? data.write(to: URL(fileURLWithPath: dir).appendingPathComponent("textpage_gesture_\(name).png"))
        }
    }

    /// A marker in the log with the wall clock, to find each step in run.mp4.
    private func mark(_ what: String) {
        print("MARK \(Date().timeIntervalSince1970) \(what)")
    }

    @MainActor
    private func launch(dark: Bool) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST", "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES"]
        XCUIDevice.shared.appearance = dark ? .dark : .light
        app.launch()
        return app
    }

    /// An existing cutling's editor, pushed from its card with the zoom transition.
    @MainActor
    private func openExisting(_ app: XCUIApplication) {
        let card = any(app, "cutlingCard")
        XCTAssertTrue(card.waitForExistence(timeout: 30), "No cards")
        let edit = app.buttons.matching(NSPredicate(format: "identifier == 'editButton' OR label == 'Edit'")).firstMatch
        for _ in 0..<3 where !edit.exists {
            card.press(forDuration: 1.6)
            _ = edit.waitForExistence(timeout: 8)
        }
        XCTAssertTrue(edit.exists, "The card's menu has no Edit")
        edit.tap()
    }

    /// A new cutling's editor: the New sheet from the + menu.
    @MainActor
    private func openNew(_ app: XCUIApplication) {
        XCTAssertTrue(any(app, "cutlingCard").waitForExistence(timeout: 30), "No cards")
        let add = app.buttons["Add cutling"].firstMatch
        XCTAssertTrue(add.waitForExistence(timeout: 10), "No + button")
        add.tap()
        let text = app.buttons["Text Cutling"].firstMatch
        XCTAssertTrue(text.waitForExistence(timeout: 5), "The + menu has no Text Cutling")
        text.tap()
    }

    /// Taps the form's text box. A tip over the form (TipKit's "Now type the text you want to save") takes a tap outside it
    /// as its dismissal and passes nothing on: then its Close, never the New sheet's own close button in the bar, and again.
    @MainActor
    private func tapRow(_ app: XCUIApplication, _ row: XCUIElement) {
        row.tap()
        if !any(app, "textPage").waitForExistence(timeout: 5) {
            let navBar = app.navigationBars.firstMatch.frame
            let closeTip = app.buttons.matching(NSPredicate(format: "label == 'Close'")).allElementsBoundByIndex
                .first { !navBar.intersects($0.frame) && $0.isHittable }
            closeTip?.tap()
            sleep(1)
            row.tap()
        }
    }

    /// From the form to the Text page with the keyboard up. Returns what stands with the keyboard and leaves with it:
    /// iPhone's bar above it, iPad's keyboard itself (the tools stay in the top bar).
    @MainActor
    private func openPage(_ app: XCUIApplication) -> XCUIElement {
        let row = any(app, "textPageRow")
        XCTAssertTrue(row.waitForExistence(timeout: 10), "No text box on the form")
        tapRow(app, row)
        XCTAssertTrue(any(app, "textPage").waitForExistence(timeout: 10), "The Text page did not open")
        let tip = app.buttons["Continue"].firstMatch
        if tip.waitForExistence(timeout: 3) { tip.tap(); sleep(1) }
        // The page's layout follows its width, not the device: iPad's pushed page is wide (tools in the top bar, no bar of
        // its own above the keyboard, as Notes on iPad has none), but the New sheet there is a narrow form sheet with
        // iPhone's layout, the bar above the keyboard.
        let tools = any(app, "textPageTools")
        let bar = any(app, "fillInKeyboardBar")
        let deadline = Date().addingTimeInterval(10)
        while !tools.exists && !bar.exists && Date() < deadline { usleep(250_000) }
        if tools.exists {
            useSystemKeyboard(app)
            let keyboard = app.keyboards.firstMatch
            XCTAssertTrue(keyboard.waitForExistence(timeout: 10), "No keyboard on the page")
            return keyboard
        }
        XCTAssertTrue(bar.exists, "No bar above the keyboard and no tools in the top bar on the page")
        useSystemKeyboard(app)
        return bar
    }

    /// The system's own keyboard, as Notes was filmed with, not the Cutling keyboard a run may have left up:
    /// Cutling's keys are buttons, so no keys means Cutling; a tap on the globe goes back to the keyboard used last.
    @MainActor
    private func useSystemKeyboard(_ app: XCUIApplication) {
        for _ in 0..<3 where app.keys.count == 0 {
            let globe = keyboardGlobe(in: app)
            guard globe.waitForExistence(timeout: 5) else { return }
            globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            sleep(2)
        }
    }

    /// A slow drag and a quick flick, top to bottom, through the middle of the text, as a person scrolls a note.
    @MainActor
    private func dragDown(_ app: XCUIApplication, slow: Bool) {
        let from = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.25))
        let to = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.92))
        from.press(forDuration: 0.05, thenDragTo: to, withVelocity: slow ? 600 : 2500, thenHoldForDuration: 0.05)
    }

    /// Drags in the text never close the editor; the drag pulls the keyboard down as in Notes; the left edge goes back.
    @MainActor
    private func swipes(new: Bool) throws {
        let app = launch(dark: true)
        if new { openNew(app) } else { openExisting(app) }
        let bar = openPage(app)
        if new {
            // Enough lines that the text scrolls, as a long cutling does.
            app.typeText((1...30).map { "Line \($0)" }.joined(separator: "\n"))
        }
        sleep(1)
        shot("\(new ? "new" : "edit")_1_keyboard_up")

        mark("slow drag down \(new ? "new" : "edit")")
        dragDown(app, slow: true)
        sleep(2)
        shot("\(new ? "new" : "edit")_2_after_slow_drag")
        XCTAssertTrue(any(app, "textPage").exists, "A slow drag down in the text closed the editor")
        // Notes: the drag carried the keyboard down with the finger, and the bar went with it.
        XCTAssertFalse(bar.exists, "A drag through the keyboard did not pull it down, as Notes' does")

        mark("flick down \(new ? "new" : "edit")")
        dragDown(app, slow: false)
        sleep(2)
        XCTAssertTrue(any(app, "textPage").exists, "A flick down in the text closed the editor")
        mark("flick up \(new ? "new" : "edit")")
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
            .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2)), withVelocity: 2500, thenHoldForDuration: 0.05)
        sleep(2)
        XCTAssertTrue(any(app, "textPage").exists, "A flick up in the text closed the editor")
        shot("\(new ? "new" : "edit")_3_after_flicks")

        // A swipe from the left edge goes back one step, to the form, and no further.
        mark("edge swipe \(new ? "new" : "edit")")
        // From the navigation bar's left edge, which is the sheet's own edge: on iPad the New sheet is a form sheet in the
        // middle of the screen, and the screen's edge is outside it. (The page's own frame starts 20 pt inside the edge.)
        // The last bar in the tree is the top one: the form sheet's, not the list's behind it.
        let barFrame = app.navigationBars.allElementsBoundByIndex.last?.frame ?? app.frame
        let origin = app.coordinate(withNormalizedOffset: .zero)
        // A flick, lifted while moving right. The system finishes a back swipe by where it is let go and which way the finger
        // moves; a drag that stopped and held before the lift was cancelled at 77% in 6 of 9 runs ("pop interaction changed:
        // cancelled 1 percent 0.77 velocity -0.77") and a flick was never (3 of 3), the same recognizer winning the touch each time.
        origin.withOffset(CGVector(dx: barFrame.minX + 2, dy: app.frame.midY))
            .press(forDuration: 0.05, thenDragTo: origin.withOffset(CGVector(dx: barFrame.minX + barFrame.width * 0.8, dy: app.frame.midY)), withVelocity: 1500, thenHoldForDuration: 0)
        sleep(2)
        XCTAssertFalse(any(app, "textPage").exists, "A swipe from the left edge did not leave the Text page")
        XCTAssertTrue(any(app, "textPageRow").waitForExistence(timeout: 5), "A swipe from the left edge went past the form")
        shot("\(new ? "new" : "edit")_4_after_edge_swipe")

        // The back button too.
        tapRow(app, any(app, "textPageRow"))
        XCTAssertTrue(any(app, "textPage").waitForExistence(timeout: 10), "The Text page did not open again")
        sleep(1)
        // The bar's back chevron; a foldable's wide layout keeps it outside a navigation bar.
        let back = app.navigationBars.buttons.firstMatch.exists ? app.navigationBars.buttons.firstMatch
            : app.buttons.matching(NSPredicate(format: "identifier == 'BackButton' OR label == 'Back' OR label == 'Edit' OR label == 'New'")).firstMatch
        back.tap()
        XCTAssertTrue(any(app, "textPageRow").waitForExistence(timeout: 5), "Back did not return to the form")
        if new {
            // Back on the form, the New sheet's own drag down closes it again, as before the page was opened.
            sleep(1)
            // TipKit keeps the walkthrough's "Now type the text you want to save." for a run that was stopped mid-walkthrough on
            // this simulator; a drag outside a tip only dismisses it, so its Close first.
            let navBar = app.navigationBars.allElementsBoundByIndex.last?.frame ?? .zero
            app.buttons.matching(NSPredicate(format: "label == 'Close'")).allElementsBoundByIndex
                .first { !navBar.intersects($0.frame) && $0.isHittable }?.tap()
            sleep(1)
            mark("drag down on the form")
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
                .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.95)), withVelocity: 1500, thenHoldForDuration: 0.05)
            sleep(2)
            XCTAssertFalse(any(app, "textPageRow").exists, "The form's drag down no longer closes the New sheet after the page")
        }
        app.terminate()
    }

    @MainActor
    func testSwipesInTextOfNewSheet() throws { try swipes(new: true) }

    @MainActor
    func testSwipesInTextOfExistingCutling() throws { try swipes(new: false) }

    /// Aa then the card's close, twice, each with three still seconds around it, dark as in the owner's Notes recording.
    @MainActor
    func testFormatCardMotion() throws {
        // The card rising in the keyboard's place is iPhone's; on iPad an existing cutling's page is wide and Aa opens a
        // popover from the top bar.
        try XCTSkipIf(UIDevice.current.userInterfaceIdiom == .pad, "Format is a popover on iPad's page, not the card that replaces the keyboard")
        let app = launch(dark: true)
        openExisting(app)
        let bar = openPage(app)
        sleep(3)
        for round in 1...2 {
            useSystemKeyboard(app)
            sleep(2)
            mark("format open \(round)")
            any(app, "editorBar.textformat").tap()
            XCTAssertTrue(any(app, "formatPanel").waitForExistence(timeout: 10), "No Format card")
            sleep(3)
            if round == 1 { shot("format_open") }
            mark("format close \(round)")
            any(app, "formatPanelClose").tap()
            XCTAssertTrue(bar.waitForExistence(timeout: 10), "Closing the Format card did not bring the bar back")
            sleep(3)
            if round == 1 { shot("format_closed") }
        }
        app.terminate()
    }
}
