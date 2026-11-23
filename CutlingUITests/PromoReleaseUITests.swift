//
//  PromoReleaseUITests.swift
//  CutlingUITests
//
//  The takes of the 2.0 release film (undirect docs/plans/app-store-growth/social/cutling-2-release-posts-brief.md),
//  all inside Cutling: a cutling written like a note on the Text page, the Cutling keyboard typing a date that fills
//  itself in, a reply that asks for the name and a formatted cutling on the setup guide's Try It page, and the grid
//  holding 5,000. scripts/release-film-takes.sh runs it on the device queue; ui-test.sh films the whole run, and each
//  step prints `MARK <wall clock> <what>` to find it in run.mp4.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class PromoReleaseUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
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
            try? data.write(to: URL(fileURLWithPath: dir).appendingPathComponent("release_\(name).png"))
        }
    }

    private func mark(_ what: String) {
        print("MARK \(Date().timeIntervalSince1970) \(what)")
    }

    @MainActor
    private func launch(_ extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-PROMO_RELEASE", "-hasSeenInteractiveTutorial", "YES"] + extra
        XCUIDevice.shared.appearance = .light
        app.launch()
        return app
    }

    /// The system's own keyboard on the Text page, not the Cutling keyboard a run may have left up.
    @MainActor
    private func useSystemKeyboard(_ app: XCUIApplication) {
        for _ in 0..<3 where app.keys.count == 0 {
            let globe = keyboardGlobe(in: app)
            guard globe.waitForExistence(timeout: 5) else { return }
            globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            sleep(2)
        }
    }

    /// Types as a person does, a few letters at a time, so the film shows the words arriving.
    @MainActor
    private func type(_ text: String, in app: XCUIApplication) {
        var chunk = ""
        for character in text {
            chunk.append(character)
            if chunk.count == 3 || character == "\n" { app.typeText(chunk); chunk = "" }
        }
        if !chunk.isEmpty { app.typeText(chunk) }
    }

    /// A new cutling written like a note: a bold title, a list, a highlight, and today's date from Variables.
    @MainActor
    func test1Note() throws {
        let app = launch(["-hasCompletedSetup", "YES"])
        XCTAssertTrue(any(app, "cutlingCard").waitForExistence(timeout: 30), "No cards")
        sleep(2)
        shot("grid")
        let add = app.buttons["Add cutling"].firstMatch
        XCTAssertTrue(add.waitForExistence(timeout: 10), "No + button")
        add.tap()
        let text = app.buttons["Text Cutling"].firstMatch
        XCTAssertTrue(text.waitForExistence(timeout: 5), "The + menu has no Text Cutling")
        text.tap()
        let row = any(app, "textPageRow")
        XCTAssertTrue(row.waitForExistence(timeout: 10), "No text box on the form")
        sleep(1)
        mark("note open page")
        row.tap()
        if !any(app, "textPage").waitForExistence(timeout: 5) {
            let navBar = app.navigationBars.firstMatch.frame
            let closeTip = app.buttons.matching(NSPredicate(format: "label == 'Close'")).allElementsBoundByIndex
                .first { !navBar.intersects($0.frame) && $0.isHittable }
            closeTip?.tap()
            sleep(1)
            row.tap()
        }
        XCTAssertTrue(any(app, "textPage").waitForExistence(timeout: 10), "The Text page did not open")
        let tip = app.buttons["Continue"].firstMatch
        if tip.waitForExistence(timeout: 3) { tip.tap(); sleep(1) }
        let bar = any(app, "fillInKeyboardBar")
        XCTAssertTrue(bar.waitForExistence(timeout: 10), "No bar above the keyboard on the page")
        useSystemKeyboard(app)
        sleep(2)
        shot("note_0_empty")

        // The styles sit further along the bar, as in Notes.
        bar.swipeLeft()
        let bold = app.buttons["Bold"].firstMatch
        XCTAssertTrue(bold.waitForExistence(timeout: 5), "No Bold on the bar")
        sleep(1)
        mark("note bold on")
        bold.tap()
        usleep(600_000)
        mark("note title")
        type("Welcome to the studio!", in: app)
        usleep(800_000)
        mark("note bold off")
        bold.tap()
        usleep(400_000)
        mark("note line")
        type("\nEverything for your first visit:\n", in: app)
        sleep(1)
        shot("note_1_title")

        // The list button ends the bar; highlight stays in view beside it.
        bar.swipeLeft()
        let list = any(app, "editorBarMenu.list.bullet")
        XCTAssertTrue(list.waitForExistence(timeout: 5), "No list button at the end of the bar")
        sleep(1)
        mark("note list menu")
        list.tap()
        let bulleted = app.buttons["Bulleted"].firstMatch
        XCTAssertTrue(bulleted.waitForExistence(timeout: 5), "The list button opened no menu")
        sleep(1)
        shot("note_2_list_menu")
        mark("note bulleted")
        bulleted.tap()
        usleep(800_000)
        mark("note item 1")
        type("Door code ", in: app)
        let highlight = app.buttons["Highlight"].firstMatch
        XCTAssertTrue(highlight.waitForExistence(timeout: 5), "No Highlight on the bar")
        mark("note highlight on")
        highlight.tap()
        usleep(500_000)
        type("4815", in: app)
        usleep(600_000)
        mark("note highlight off")
        highlight.tap()
        usleep(400_000)
        mark("note items")
        type("\nWi-Fi: studio-guest\nParking behind the bakery", in: app)
        sleep(2)
        shot("note_3_written")
        mark("note written")

        // Return on an empty item ends the list; then today's date from Variables, which fills itself in when used.
        type("\n\nSent ", in: app)
        for _ in 0..<3 { bar.swipeRight() }
        let variables = app.buttons["Variables"].firstMatch
        XCTAssertTrue(variables.waitForExistence(timeout: 5), "No Variables on the bar")
        sleep(1)
        mark("note variables")
        variables.tap()
        XCTAssertTrue(any(app, "fillInPicker").waitForExistence(timeout: 5), "No picker")
        sleep(2)
        shot("note_4_variables")
        mark("note pick date")
        any(app, "fillInKind-date").tap()
        sleep(2)
        shot("note_5_date_pill")
        mark("note end")
        sleep(1)
        app.terminate()
    }

    /// The Cutling keyboard on the setup guide's Try It page: a date that fills itself in, a reply that asks for the
    /// name, and a formatted cutling typed by a tap.
    @MainActor
    func test2Keyboard() throws {
        var app = launch()
        app.terminate()
        addCutlingKeyboardInSettings()
        app = launch()
        var field = openKeyboardTestField(in: app)

        // The first time Cutling's keyboard reports Full Access, the setup guide closes the keyboard; open the field once more.
        continueAfterFailure = true
        switchToCutlingKeyboard(in: app, showing: "Delivery note")
        continueAfterFailure = false
        if !cutlingKeyboardIsUp(in: app, showing: "Delivery note") {
            app.terminate()
            app = launch()
            field = openKeyboardTestField(in: app)
            switchToCutlingKeyboard(in: app, showing: "Delivery note")
        }
        XCTAssertTrue(cutlingKeyboardIsUp(in: app, showing: "Delivery note"), "Cutling keyboard did not come up")

        // Frames read once, so no accessibility query sits between a press and the next on camera.
        func frame(_ name: String) -> CGRect {
            var found: CGRect?
            for _ in 0..<10 {
                found = cutlingKeyFrame(name, in: app)
                if found != nil { break }
                usleep(500_000)
            }
            XCTAssertNotNil(found, "No \(name) on the Cutling keyboard (buttons: \(cutlingKeys(in: app)?.map(\.label) ?? []))")
            return found ?? .zero
        }
        func press(_ label: String, _ rect: CGRect) {
            mark("\(label) at \(Int(rect.midX)),\(Int(rect.midY))")
            screenPoint(rect.midX, rect.midY, in: app).press(forDuration: 0.12)
        }
        func clear() {
            let length = ((field.value as? String) ?? "").count
            if length > 0 { field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: length + 4)) }
            sleep(1)
        }
        let delivery = frame("Delivery note"), order = frame("Order update"), welcome = frame("Welcome note")
        sleep(2)
        shot("keyboard_0_ready")

        mark("date start")
        sleep(1)
        press("delivery note", delivery)
        sleep(3)
        shot("keyboard_1_date")
        mark("date end")
        clear()

        // The reply asks for the name; the names used before are one tap away.
        mark("ask start")
        sleep(1)
        press("order update", order)
        sleep(2)
        let maya = frame("Maya")
        shot("keyboard_2_asks")
        sleep(1)
        press("name", maya)
        sleep(3)
        shot("keyboard_3_asked")
        mark("ask end")
        clear()

        // A formatted cutling types like the rest.
        mark("formatted start")
        sleep(1)
        press("welcome note", welcome)
        sleep(3)
        shot("keyboard_4_formatted")
        mark("formatted end")
        clear()
        app.terminate()
    }

    /// The grid's own count with 5,000 texts saved, then a few flicks through them.
    @MainActor
    func test3Room() throws {
        let app = launch(["-hasCompletedSetup", "YES", "-PROMO_ROOM", "5000"])
        XCTAssertTrue(any(app, "cutlingCard").waitForExistence(timeout: 90), "No cards")
        sleep(4)
        shot("room_0_grid")
        mark("room start")
        sleep(2)
        for index in 0..<5 {
            mark("room flick \(index)")
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.78))
                .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.18)), withVelocity: 5000, thenHoldForDuration: 0)
            usleep(700_000)
        }
        sleep(2)
        shot("room_1_scrolled")
        mark("room end")
        app.terminate()
        // The next run starts from six keys again.
        let reset = launch(["-hasCompletedSetup", "YES"])
        _ = any(reset, "cutlingCard").waitForExistence(timeout: 30)
        reset.terminate()
    }
}
