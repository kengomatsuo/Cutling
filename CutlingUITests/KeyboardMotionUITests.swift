//
//  KeyboardMotionUITests.swift
//  CutlingUITests
//
//  Two defects the owner filmed on his iPhone (Cutling 2.0 build 9, ScreenRecording_11-24-2026 07-55-34_1.MP4):
//  1. The keyboard and the bar above it show darkened (grey tray, no suggestions, dark bar) for about 30 frames while
//     the Text page opens, then jump to their normal colours in one frame. Notes' keyboard never does.
//  2. Switching from English to Cutling leaves the English keyboard frozen for 27 frames, then cuts to Cutling, and the
//     bar above jumps up because Cutling is a different height. Apple's own switch between two system keyboards
//     of different heights is the reference (testSwitchToEmoji).
//  The tests print MARK lines with the wall clock and leave the run's screen recording (run.mp4) for a frame-by-frame sheet.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class KeyboardMotionUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        XCUIDevice.shared.appearance = .light
    }

    private func any(_ app: XCUIApplication, _ id: String) -> XCUIElement {
        app.descendants(matching: .any)[id].firstMatch
    }

    private func mark(_ what: String) {
        print("MARK \(Date().timeIntervalSince1970) \(what)")
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST", "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES"]
        app.launch()
        return app
    }

    /// An existing cutling's editor, pushed from its card.
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

    /// The mean brightness (0 to 255) of a rectangle of the screen, in points.
    private func brightness(of screenshot: XCUIScreenshot, _ rect: CGRect) -> Double {
        guard let image = screenshot.image.cgImage else { return -1 }
        let scale = CGFloat(image.width) / screenshot.image.size.width
        let crop = CGRect(x: rect.minX * scale, y: rect.minY * scale, width: rect.width * scale, height: rect.height * scale).integral
        guard let part = image.cropping(to: crop) else { return -1 }
        var pixel = [UInt8](repeating: 0, count: 4)
        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                                space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        context?.interpolationQuality = .medium
        context?.draw(part, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        return (Double(pixel[0]) + Double(pixel[1]) + Double(pixel[2])) / 3
    }

    /// The keyboard's tray (the strip between the globe and the dictation key, under the keys) in every screenshot the run
    /// can take for `seconds`: its brightness at each moment, so a darker grey than its settled colour shows.
    @MainActor
    private func watchTray(_ app: XCUIApplication, seconds: Double, _ what: String) -> (settled: Double, darkest: Double) {
        let screen = app.frame
        let tray = CGRect(x: screen.width * 0.3, y: screen.height * 0.955, width: screen.width * 0.4, height: screen.height * 0.03)
        var samples: [(Double, Double)] = []
        let start = Date()
        while Date().timeIntervalSince(start) < seconds {
            let shot = XCUIScreen.main.screenshot()
            samples.append((Date().timeIntervalSince(start), brightness(of: shot, tray)))
        }
        let settled = samples.last?.1 ?? -1
        print("TRAY \(what): settled \(settled); samples " + samples.map { String(format: "%.2fs=%.0f", $0.0, $0.1) }.joined(separator: " "))
        return (settled, samples.map(\.1).min() ?? -1)
    }

    /// Opens the Text page from the form (the tray is watched from the tap) and goes back to the form.
    @MainActor
    private func openPageAndBack(_ app: XCUIApplication, _ what: String) {
        let row = any(app, "textPageRow")
        XCTAssertTrue(row.waitForExistence(timeout: 10), "No text box on the form")
        mark("\(what): text row tap")
        row.tap()
        let tray = watchTray(app, seconds: 3, what)
        mark("\(what): settled")
        XCTAssertGreaterThan(tray.settled, 0, "No keyboard tray at the end")
        XCTAssertGreaterThanOrEqual(tray.darkest, tray.settled - 8,
                                    "\(what): the keyboard's tray showed darker (\(tray.darkest)) than its settled colour (\(tray.settled)) while the Text page opened")
        let back = app.navigationBars.buttons.firstMatch
        if back.exists { back.tap() }
        sleep(2)
    }

    /// The Text page opened three times from one form: the keyboard's tray never shows darker than its own colour.
    @MainActor
    func testTextPageOpensWithKeyboardInItsColours() throws {
        try XCTSkipIf(UIDevice.current.userInterfaceIdiom == .pad, "The owner's recording is an iPhone")
        continueAfterFailure = true
        let app = launch()
        openExisting(app)
        sleep(2)
        for round in 1...3 { openPageAndBack(app, "page open \(round)") }
        app.terminate()
    }

    /// The control: the first keyboard of the run comes up for the form's Name field, not for the Text page.
    @MainActor
    func testNameFieldKeyboardInItsColours() throws {
        try XCTSkipIf(UIDevice.current.userInterfaceIdiom == .pad, "The owner's recording is an iPhone")
        continueAfterFailure = true
        let app = launch()
        openExisting(app)
        sleep(2)
        let name = app.textFields.firstMatch
        XCTAssertTrue(name.waitForExistence(timeout: 10), "No Name field")
        mark("name field tap")
        name.tap()
        let tray = watchTray(app, seconds: 3, "name field")
        XCTAssertGreaterThan(tray.settled, 0, "No keyboard tray at the end")
        XCTAssertGreaterThanOrEqual(tray.darkest, tray.settled - 8,
                                    "name field: the keyboard's tray showed darker (\(tray.darkest)) than its settled colour (\(tray.settled))")
        app.terminate()
    }

    // MARK: Apple's own

    /// Notes opening a note it has opened before, in a fresh process, with the tray watched as in the Text page: the
    /// reference for the first keyboard of an app run. Run once to leave a note, then again; both runs watch the tray.
    @MainActor
    func testNotesOpensNoteWithKeyboardInItsColours() throws {
        try XCTSkipIf(UIDevice.current.userInterfaceIdiom == .pad, "The owner's recording is an iPhone")
        continueAfterFailure = true
        let notes = XCUIApplication(bundleIdentifier: "com.apple.mobilenotes")
        notes.terminate()
        notes.launch()
        sleep(3)
        for label in ["Continue", "Done", "Not Now", "Skip"] {
            let button = notes.buttons[label].firstMatch
            if button.waitForExistence(timeout: 2) { button.tap(); sleep(1) }
        }
        print("NOTES-TREE-1 " + notes.debugDescription.prefix(3000))
        // A note to open: the first row, or a new one typed once.
        if !notes.cells.firstMatch.waitForExistence(timeout: 5) {
            let compose = notes.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'New Note' OR label CONTAINS[c] 'Compose'")).firstMatch
            XCTAssertTrue(compose.waitForExistence(timeout: 10), "No New Note button in Notes")
            compose.tap()
            sleep(2)
            notes.typeText("A note for the keyboard test")
            sleep(1)
            let back = notes.navigationBars.buttons.firstMatch
            if back.exists { back.tap() }
            sleep(2)
            notes.terminate()
            notes.launch()
            sleep(3)
        }
        let cell = notes.cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 10), "No note in the list")
        sleep(2)
        mark("notes: note tap")
        cell.tap()
        var tray = watchTray(notes, seconds: 3, "notes open (keyboard if the note takes focus)")
        if !notes.keyboards.firstMatch.exists {
            let body = notes.textViews.firstMatch
            if body.exists { body.tap() }
            mark("notes: text tap")
            tray = watchTray(notes, seconds: 3, "notes text tap")
        }
        mark("notes: settled")
        XCTAssertGreaterThan(tray.settled, 0, "No keyboard tray at the end")
        XCTAssertGreaterThanOrEqual(tray.darkest, tray.settled - 8,
                                    "notes: the keyboard's tray showed darker (\(tray.darkest)) than its settled colour (\(tray.settled))")
        notes.terminate()
    }

    // MARK: Switching keyboards under the Text page

    /// The Text page with the system keyboard up and the bar above it, the owner's second scene.
    @MainActor
    private func openTextPageWithEnglish(_ app: XCUIApplication) {
        openExisting(app)
        let row = any(app, "textPageRow")
        XCTAssertTrue(row.waitForExistence(timeout: 10), "No text box on the form")
        row.tap()
        XCTAssertTrue(any(app, "textPage").waitForExistence(timeout: 10), "The Text page did not open")
        let tip = app.buttons["Continue"].firstMatch
        if tip.waitForExistence(timeout: 3) { tip.tap() }
        XCTAssertTrue(any(app, "fillInKeyboardBar").waitForExistence(timeout: 10), "No bar above the keyboard")
        // The system's own keyboard: Cutling's keys are buttons, so no keys means Cutling; the globe goes back to the last used.
        for _ in 0..<3 where app.keys.count == 0 {
            let globe = keyboardGlobe(in: app)
            guard globe.waitForExistence(timeout: 5) else { break }
            globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            sleep(2)
        }
        XCTAssertGreaterThan(app.keys.count, 0, "The English keyboard is not up")
        sleep(3)
    }

    /// As a person does it: hold the globe, slide up its list `row` rows and let go. Returns when the finger is up.
    @MainActor
    private func slideGlobe(_ app: XCUIApplication, row: Int) {
        let globe = keyboardGlobe(in: app)
        XCTAssertTrue(globe.waitForExistence(timeout: 10), "No globe key")
        let start = globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 1.0, thenDragTo: start.withOffset(CGVector(dx: 70, dy: -44 * CGFloat(row))),
                    withVelocity: .slow, thenHoldForDuration: 0.4)
    }

    /// One keyboard's name on screen, so a run says which keyboard each row led to.
    @MainActor
    private func keyboardName(_ app: XCUIApplication) -> String {
        if app.buttons["ABC"].exists || app.keys["ABC"].exists { return "Emoji" }
        if app.keys.count > 0 { return "English" }
        return "Cutling"
    }

    /// English up under the Text page, then to `target` through the globe's list, twice (the second switch finds the
    /// target's process and its screen already made), each with three still seconds around it for the run's recording.
    @MainActor
    private func switchFilm(to target: String) throws {
        try XCTSkipIf(UIDevice.current.userInterfaceIdiom == .pad, "The owner's recording is an iPhone")
        let app = launch()
        openTextPageWithEnglish(app)
        for round in 1...2 {
            var reached = ""
            for row in 1...4 where reached != target {
                mark("\(target) round \(round) globe row \(row)")
                slideGlobe(app, row: row)
                mark("\(target) round \(round) finger up")
                sleep(3)
                reached = keyboardName(app)
                print("KEYBOARD-AFTER row \(row): \(reached)")
                // A wrong keyboard: back to English by the globe's tap before the next row is tried.
                if reached != target, reached != "English" {
                    let globe = keyboardGlobe(in: app)
                    if globe.waitForExistence(timeout: 5) { globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
                    sleep(3)
                }
            }
            XCTAssertEqual(reached, target, "Never reached \(target)")
            XCTAssertTrue(any(app, "fillInKeyboardBar").exists, "The bar is gone after switching to \(target)")
            sleep(2)
            if round == 1 {
                mark("\(target) back to English")
                let globe = keyboardGlobe(in: app)
                if globe.waitForExistence(timeout: 5) { globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
                sleep(3)
                XCTAssertEqual(keyboardName(app), "English", "The globe did not go back to English")
            }
        }
        app.terminate()
    }

    @MainActor
    func testSwitchToCutlingFromEnglish() throws { try switchFilm(to: "Cutling") }

    /// Apple's own switch between two keyboards of different heights, to run with EXTRA_KEYBOARD='emoji@sw=Emoji'.
    @MainActor
    func testSwitchToEmojiFromEnglish() throws { try switchFilm(to: "Emoji") }
}
