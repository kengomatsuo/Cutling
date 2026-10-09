//
//  PromoTakesUITests.swift
//  CutlingUITests
//
//  Drives one promo take per test while `simctl io recordVideo` films it.
//  Pages come from cutling-promo/takes-web, served on localhost:8766.
//  Markers go to $PROMO_LOG so the edit can cut dead time.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

@MainActor
final class PromoTakesUITests: XCTestCase {
    private let started = Date()
    private let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
    private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    private func mark(_ text: String) {
        guard let path = ProcessInfo.processInfo.environment["PROMO_LOG"] else { return }
        let line = String(format: "%.2f %@\n", Date().timeIntervalSince(started), text)
        let old = (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
        try? (old + line).write(toFile: path, atomically: true, encoding: .utf8)
    }

    private func shot(_ name: String) {
        guard let dir = ProcessInfo.processInfo.environment["PROMO_SHOTS"] else { return }
        try? XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: dir).appendingPathComponent("\(name).png"))
    }

    /// A point on screen as fractions of its size.
    private func point(_ x: CGFloat, _ y: CGFloat, in app: XCUIApplication) -> XCUICoordinate {
        app.coordinate(withNormalizedOffset: CGVector(dx: x, dy: y))
    }

    // MARK: - Setup

    /// Seeds the store, adds the keyboard with Full Access.
    func test0Setup() {
        let app = XCUIApplication()
        app.launchArguments += ["-SNAPSHOT_MODE", "-PROMO_MODE"]
        app.launch()
        sleep(3)
        app.terminate()

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
            for _ in 0..<3 where !addNew.exists { settings.swipeUp(); sleep(1) }
            addNew.tap()
            sleep(1)
            let option = settings.cells.staticTexts["Cutling"].firstMatch
            if !option.waitForExistence(timeout: 3) { settings.swipeUp() }
            option.tap()
            sleep(1)
        }
        XCTAssertTrue(cutling.waitForExistence(timeout: 5), "Cutling keyboard not added")
        cutling.tap()
        sleep(1)
        let fullAccess = settings.switches.matching(NSPredicate(format: "label CONTAINS[c] 'Allow Full Access'")).firstMatch
        if fullAccess.waitForExistence(timeout: 3), fullAccess.value as? String == "0" {
            fullAccess.switches.firstMatch.tap()
            sleep(2)
            for allow in [settings.alerts.buttons["Allow"].firstMatch, settings.sheets.buttons["Allow"].firstMatch, settings.buttons["Allow Full Access"].firstMatch]
            where allow.waitForExistence(timeout: 2) {
                allow.tap()
                sleep(1)
            }
        }
        shot("setup-full-access")
        XCTAssertEqual(fullAccess.value as? String, "1", "Full Access not granted")
        settings.terminate()
    }

    // MARK: - Keyboard helpers

    private func openPage(_ name: String) {
        safari.launch()
        safari.open(URL(string: "http://localhost:8766/\(name).html")!)
        sleep(3)
    }

    /// Cutling's keys aren't in the tree; zero keys plus the dictation row means Cutling.
    private func cutlingIsUp(_ app: XCUIApplication) -> Bool {
        guard app.keys.count == 0, app.buttons["dictation"].exists else { return false }
        sleep(1)
        return app.keys.count == 0 && app.buttons["dictation"].exists
    }

    private func switchToCutling(_ app: XCUIApplication) {
        for _ in 0..<6 where !cutlingIsUp(app) {
            let globe = app.buttons.allElementsBoundByIndex
                .firstIndex { $0.identifier == "dictation" }
                .flatMap { $0 > 0 ? app.buttons.element(boundBy: $0 - 1) : nil }
            guard let globe else { return }
            globe.tap()
            sleep(1)
            let tip = app.buttons.matching(NSPredicate(format: "label == 'Continue'")).firstMatch
            if tip.exists { tip.tap(); sleep(1) }
        }
    }

    private func switchToSystem(_ app: XCUIApplication) {
        for _ in 0..<6 where app.keys.count < 20 || app.keys["😀"].exists {
            point(0.09, 0.955, in: app).tap()
            sleep(1)
        }
    }

    /// Taps until a keyboard is up.
    private func focus(_ x: CGFloat, _ y: CGFloat, in app: XCUIApplication) {
        for _ in 0..<4 {
            point(x, y, in: app).tap()
            if app.keyboards.firstMatch.waitForExistence(timeout: 3) || app.buttons["dictation"].exists { return }
        }
        XCTFail("No keyboard after tapping \(x), \(y)")
    }

    /// Types on the system keyboard key by key; web views refuse typeText.
    private func typeKeys(_ text: String, in app: XCUIApplication) {
        switchToSystem(app)
        for character in text {
            if character == "\n" {
                let key = [app.buttons["Return"], app.keys["return"], app.keys["Return"]].map(\.firstMatch).first { $0.exists }
                key?.tap()
                continue
            }
            let label = character == " " ? "space" : String(character)
            // Auto-capitals relabel the letter keys.
            let key = [label, label.uppercased(), label.lowercased()].lazy.map { app.keys[$0].firstMatch }.first { $0.exists }
            key?.tap()
            usleep(120_000)
        }
    }

    /// Probe: Cutling keyboard over the mail page, for key coordinates.
    func test1Probe() {
        openPage("mail")
        point(0.5, 0.144, in: safari).tap() // the To field
        sleep(1)
        switchToCutling(safari)
        shot("probe-keyboard")
    }

    /// Probe: the keyboard over the message body and the code page.
    func test2ProbeBody() {
        openPage("mail")
        focus(0.5, 0.32, in: safari)
        typeKeys("thanks for today. sig", in: safari)
        switchToCutling(safari)
        sleep(1)
        shot("probe-body")
        openPage("code")
        focus(0.5, 0.2, in: safari)
        switchToCutling(safari)
        shot("probe-code")
    }

    /// Probe: share sheet, Control Center, Siri and Spotlight, one shot per step.
    func test3ProbeSystem() {
        openPage("mail")
        point(0.26, 0.92, in: safari).tap() // the page menu left of the address
        sleep(2)
        shot("sys-1-menu")
        let share = safari.buttons["Share"].firstMatch
        if share.waitForExistence(timeout: 3) { share.tap() }
        sleep(3)
        shot("sys-2-share")
        XCUIDevice.shared.press(.home)
        sleep(2)

        let top = point(0.88, 0.003, in: springboard)
        top.press(forDuration: 0.1, thenDragTo: point(0.88, 0.6, in: springboard))
        sleep(2)
        shot("sys-3-control")
        point(0.5, 0.97, in: springboard).tap()
        XCUIDevice.shared.press(.home)
        sleep(2)

        XCUIDevice.shared.siriService.activate(voiceRecognitionText: "Copy Home Address from Cutling")
        sleep(6)
        shot("sys-4-siri")
        XCUIDevice.shared.press(.home)
        sleep(2)

        point(0.5, 0.45, in: springboard).press(forDuration: 0.1, thenDragTo: point(0.5, 0.75, in: springboard))
        sleep(2)
        springboard.typeText("iban")
        sleep(3)
        shot("sys-5-spotlight")
        XCUIDevice.shared.press(.home)
    }

    // MARK: - Takes

    /// Probe: Cutling's grid over the message body, nothing typed.
    func test4ProbeGrid() {
        openPage("mail")
        focus(0.5, 0.32, in: safari)
        switchToCutling(safari)
        sleep(1)
        shot("probe-grid")
    }

    /// e3: an email field puts the email cutlings first.
    func testE3Suggest() {
        openPage("mail")
        focus(0.5, 0.144, in: safari)
        switchToSystem(safari)
        sleep(2)
        mark("e3 start")
        switchToCutling(safari)
        sleep(2)
        mark("e3 tap")
        point(0.25, 0.74, in: safari).tap()
        sleep(3)
        shot("e3-done")
        mark("e3 end")
    }

    /// e4: type the start of a name, get the whole cutling.
    func testE4Expand() {
        openPage("mail")
        focus(0.5, 0.32, in: safari)
        typeKeys("thanks for today\n\n", in: safari)
        mark("e4 start")
        typeKeys("sig", in: safari)
        switchToCutling(safari)
        sleep(1)
        mark("e4 tap")
        point(0.25, 0.74, in: safari).tap()
        sleep(3)
        shot("e4-done")
        mark("e4 end")
    }

    /// e5: tap a Formatted cutling, paste: bold and the link survive.
    func testE5Formatted() {
        openPage("mail")
        focus(0.5, 0.32, in: safari)
        switchToCutling(safari)
        sleep(2)
        mark("e5 start")
        point(0.25, 0.72, in: safari).tap() // Meeting Notes
        sleep(2)
        mark("e5 paste")
        point(0.3, 0.27, in: safari).press(forDuration: 1.0)
        let paste = safari.menuItems["Paste"].firstMatch
        if paste.waitForExistence(timeout: 3) { paste.tap() } else { safari.buttons["Paste"].firstMatch.tap() }
        sleep(3)
        shot("e5-done")
        mark("e5 end")
    }

    /// e6: tap a Code cutling into a terminal; it lands exactly.
    func testE6Code() {
        openPage("code")
        focus(0.6, 0.2, in: safari)
        switchToCutling(safari)
        sleep(2)
        shot("e6-grid")
        mark("e6 start")
        point(0.75, 0.72, in: safari).tap() // Deploy
        sleep(3)
        shot("e6-done")
        mark("e6 end")
    }

    /// Probe 2: Control Center editing, a finished Siri answer, Spotlight.
    func test5ProbeSystem2() {
        XCUIDevice.shared.press(.home)
        sleep(1)
        point(0.88, 0.003, in: springboard).press(forDuration: 0.1, thenDragTo: point(0.88, 0.6, in: springboard))
        sleep(2)
        point(0.06, 0.04, in: springboard).tap() // +
        sleep(2)
        shot("sys2-1-edit")
        let add = springboard.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Add a Control'")).firstMatch
        if add.waitForExistence(timeout: 3) { add.tap() }
        sleep(2)
        shot("sys2-2-gallery")
        for key in "cutling" { springboard.keys[String(key)].firstMatch.tap() }
        sleep(2)
        shot("sys2-3-search")
        XCUIDevice.shared.press(.home)
        XCUIDevice.shared.press(.home)
        sleep(2)

        XCUIDevice.shared.siriService.activate(voiceRecognitionText: "Copy Home Address from Cutling")
        sleep(14)
        shot("sys2-4-siri")
        XCUIDevice.shared.press(.home)
        sleep(2)

        point(0.5, 0.45, in: springboard).press(forDuration: 0.1, thenDragTo: point(0.5, 0.75, in: springboard))
        sleep(2)
        shot("sys2-5-spotlight-open")
        for key in "iban" { springboard.keys[String(key)].firstMatch.tap(); usleep(150_000) }
        sleep(3)
        shot("sys2-6-spotlight")
        XCUIDevice.shared.press(.home)
    }

    private func openControlCenter() {
        point(0.9, 0.001, in: springboard).press(forDuration: 0.2, thenDragTo: point(0.9, 0.7, in: springboard))
        sleep(3)
    }

    private func goHome() {
        for _ in 0..<3 { XCUIDevice.shared.press(.home); sleep(1) }
    }

    /// Spotlight's keys aren't in SpringBoard's tree; tap them by place.
    private func typeIbanInSpotlight() {
        for (x, y) in [(0.745, 0.714), (0.6, 0.83), (0.105, 0.772), (0.695, 0.83)] { // i b a n
            point(x, y, in: springboard).tap()
            usleep(250_000)
        }
    }

    /// Adds Cutling's New Text control to Control Center.
    func test7SetupControl() {
        openPage("article")
        openControlCenter()
        point(0.135, 0.039, in: springboard).tap() // + enters editing
        sleep(3)
        let add = springboard.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Add a Control'")).firstMatch
        if add.waitForExistence(timeout: 3) { add.tap(); sleep(3) }
        point(0.375, 0.815, in: springboard).tap() // New Text Cutling
        sleep(3)
        shot("cc-added")
        point(0.5, 0.95, in: springboard).tap()
        sleep(2)
        goHome()
    }

    /// e7: Safari, Share, Cutling, the save sheet.
    func testE7Share() {
        openPage("article")
        sleep(2)
        mark("e7 start")
        point(0.26, 0.92, in: safari).tap()
        sleep(2)
        let share = safari.buttons["Share"].firstMatch
        if share.waitForExistence(timeout: 3) { share.tap() }
        sleep(4)
        shot("e7-sheet")
        point(0.825, 0.773, in: springboard).tap() // Cutling in the app row
        sleep(6)
        shot("e7-cutling-6s")
        sleep(8)
        shot("e7-cutling")
        mark("e7 end")
    }

    /// e8: the Cutling control in Control Center.
    func testE8Control() {
        openPage("article")
        sleep(2)
        mark("e8 start")
        openControlCenter()
        sleep(1)
        mark("e8 tap")
        point(0.19, 0.21, in: springboard).tap() // New Text Cutling
        sleep(9)
        shot("e8-opened")
        mark("e8 end")
        goHome()
    }

    /// e9: Cutling's App Shortcuts in the Shortcuts app (Siri needs a network the simulator lacks).
    func testE9Siri() {
        goHome()
        let shortcuts = XCUIApplication(bundleIdentifier: "com.apple.shortcuts")
        shortcuts.launch()
        sleep(4)
        let next = shortcuts.buttons["Continue"].firstMatch
        if next.waitForExistence(timeout: 3) { next.tap(); sleep(3) }
        point(0.06, 0.088, in: shortcuts).tap() // back to the sidebar
        sleep(3)
        shot("e9-1-sidebar")
        let cutling = shortcuts.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS[c] 'Cutling'")).firstMatch
        mark("e9 start")
        if cutling.waitForExistence(timeout: 3) { cutling.tap(); sleep(3) }
        shot("e9-2-cutling")
        mark("e9 end")
        goHome()
    }

    /// e10: Spotlight finds a cutling.
    func testE10Spotlight() {
        goHome()
        sleep(2)
        mark("e10 start")
        point(0.5, 0.813, in: springboard).tap() // the Search pill
        sleep(2)
        let spotlight = XCUIApplication(bundleIdentifier: "com.apple.Spotlight")
        for _ in 0..<3 where spotlight.keys.count < 20 {
            point(0.098, 0.957, in: springboard).tap() // globe until letters show
            sleep(2)
        }
        shot("e10-keyboard")
        let clear = spotlight.buttons["Clear text"].firstMatch
        if clear.exists { clear.tap(); sleep(1) }
        for key in ProcessInfo.processInfo.environment["PROMO_QUERY"] ?? "deploy" {
            let k = spotlight.keys[String(key)].firstMatch
            if k.waitForExistence(timeout: 2) { k.tap() }
            usleep(250_000)
        }
        sleep(4)
        shot("e10-results")
        mark("e10 end")
    }

    // MARK: - Smooth keyboard takes (extension warmed before the action)

    /// Loads the Cutling extension once off camera, then leaves it up.
    private func warmCutling(_ app: XCUIApplication) {
        switchToCutling(app)
        sleep(2)
        switchToSystem(app)
        sleep(1)
        switchToCutling(app)
        sleep(4)
    }

    /// Types slowly, like a person.
    private func typeSlowly(_ text: String, in app: XCUIApplication) {
        for character in text {
            let label = character == " " ? "space" : String(character)
            let key = [label, label.uppercased(), label.lowercased()].lazy.map { app.keys[$0].firstMatch }.first { $0.exists }
            key?.tap()
            usleep(260_000)
        }
    }

    func testK1Pain() {
        openPage("address")
        focus(0.5, 0.255, in: safari)
        switchToSystem(safari)
        let tip = safari.buttons["Continue"].firstMatch
        if tip.waitForExistence(timeout: 2) { tip.tap() }
        sleep(3)
        mark("k1 go")
        typeSlowly("123 Main Str", in: safari)
        sleep(2)
        shot("k1-done")
    }

    func testK2Tap() {
        openPage("address")
        focus(0.5, 0.255, in: safari)
        warmCutling(safari)
        shot("k2-ready")
        mark("k2 go")
        sleep(2)
        point(0.25, 0.74, in: safari).tap() // Home Address under Suggestions
        sleep(4)
        shot("k2-done")
    }

    func testK3Suggest() {
        openPage("mail")
        focus(0.5, 0.144, in: safari)
        warmCutling(safari)
        shot("k3-ready")
        mark("k3 go")
        sleep(2)
        point(0.25, 0.74, in: safari).tap() // Work Email
        sleep(4)
        shot("k3-done")
    }

    func testK4Expand() {
        openPage("mail")
        focus(0.5, 0.32, in: safari)
        warmCutling(safari)
        switchToSystem(safari)
        typeKeys("thanks for today\n\n", in: safari)
        sleep(2)
        mark("k4 go")
        typeSlowly("sig", in: safari)
        sleep(1)
        switchToCutling(safari)
        sleep(2)
        point(0.25, 0.74, in: safari).tap() // Signature
        sleep(4)
        shot("k4-done")
    }

    func testK5Formatted() {
        openPage("mail")
        focus(0.5, 0.32, in: safari)
        warmCutling(safari)
        mark("k5 go")
        sleep(2)
        point(0.25, 0.72, in: safari).tap() // Meeting Notes: copies with formatting
        sleep(3)
        point(0.3, 0.27, in: safari).press(forDuration: 1.0)
        let paste = safari.menuItems["Paste"].firstMatch
        if paste.waitForExistence(timeout: 3) { paste.tap() } else { safari.buttons["Paste"].firstMatch.tap() }
        sleep(9)
        shot("k5-done")
    }

    func testK6Code() {
        openPage("code")
        focus(0.6, 0.2, in: safari)
        warmCutling(safari)
        mark("k6 go")
        sleep(2)
        point(0.75, 0.72, in: safari).tap() // Deploy
        sleep(4)
        shot("k6-done")
    }
}
