//
//  KeyboardPressFeelUITests.swift
//  CutlingUITests
//
//  Films how keys answer a press (card ASG159): Apple's own keyboard, then Cutling's, with the same presses at the
//  same pace, so the queued runner's run.mp4 can be cut into frame sheets from touch-down to release. Each press is
//  held a known time; the frame where the highlight goes away is the release, so touch-down is that minus the hold.
//  The checks are only that each press typed what the key types.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

@MainActor
final class KeyboardPressFeelUITests: XCTestCase {

    override func setUp() async throws { continueAfterFailure = true }

    /// How long each held press lasts, and the rest after it, in seconds.
    private let hold: TimeInterval = 0.8
    private let deleteHold: TimeInterval = 3.0
    private let rest: UInt32 = 2

    private func mark(_ name: String) {
        print("PRESS-FEEL \(name) at \(Date().timeIntervalSince1970)")
        if let dir = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"] {
            try? XCUIScreen.main.screenshot().pngRepresentation
                .write(to: URL(fileURLWithPath: dir).appendingPathComponent("press_\(name).png"))
        }
    }

    private func value(_ field: XCUIElement) -> String { field.value as? String ?? "" }

    /// A tip left showing from an earlier run can cover the toolbar's keyboard button; close it first.
    private func closeTip(in app: XCUIApplication) {
        let close = app.buttons.matching(NSPredicate(format: "label ==[c] 'Close' OR identifier ==[c] 'Close'")).firstMatch
        if close.waitForExistence(timeout: 3) { close.tap() }
    }

    /// Apple's keyboard: letters typed first so delete has text to take, then space, delete (tap and hold) and return.
    func testApplePresses() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FORMAT_TEST"]
        app.launch()
        closeTip(in: app)
        let field = openKeyboardTestField(in: app)
        // Back to Apple's letter keyboard if Cutling or another one is up.
        for _ in 0..<8 where !app.keys["space"].exists {
            let globe = keyboardGlobe(in: app)
            if globe.exists { globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
            sleep(1)
        }
        XCTAssertTrue(app.keys["space"].waitForExistence(timeout: 5), "Apple's keyboard is not up")
        func letter(_ c: String) -> XCUIElement {
            app.keys.matching(NSPredicate(format: "label ==[c] %@", c)).firstMatch
        }
        for word in ["hello", "world", "hello", "world", "hello", "world"] {
            for c in word { letter(String(c)).tap() }
            app.keys["space"].tap()
        }
        let typed = value(field).count
        mark("apple_typed_\(typed)")
        sleep(rest)

        let space = app.keys["space"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let delete = app.keys["delete"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let ret = app.buttons["Return"].exists ? app.buttons["Return"] : app.keys["Return"].exists ? app.keys["Return"] : app.buttons["return"]
        // Held, Apple's space bar turns the keyboard into a trackpad and types nothing; filmed for its look only.
        press(space, "apple_space", hold)
        let beforeTap = value(field).count
        delete.tap(); sleep(rest); mark("apple_delete_tap")
        XCTAssertEqual(value(field).count, beforeTap - 1, "A delete tap should take one character")
        press(delete, "apple_delete_hold", deleteHold)
        print("PRESS-FEEL apple delete hold left \(value(field).count) of \(typed)")
        press(ret.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)), "apple_return", hold)
    }

    /// Apple's delete held 7 s over 96 characters, to time its repeat: the wait before it starts, the pace, and when
    /// it moves from characters to words.
    func testAppleDeleteHoldLong() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FORMAT_TEST"]
        app.launch()
        closeTip(in: app)
        let field = openKeyboardTestField(in: app)
        for _ in 0..<8 where !app.keys["space"].exists {
            let globe = keyboardGlobe(in: app)
            if globe.exists { globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
            sleep(1)
        }
        XCTAssertTrue(app.keys["space"].waitForExistence(timeout: 5), "Apple's keyboard is not up")
        for _ in 0..<8 {
            for word in ["hello", "world"] {
                for c in word { app.keys.matching(NSPredicate(format: "label ==[c] %@", String(c))).firstMatch.tap() }
                app.keys["space"].tap()
            }
        }
        let typed = value(field).count
        mark("apple_long_typed_\(typed)")
        sleep(rest)
        press(app.keys["delete"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)), "apple_delete_hold_long", 7)
        print("PRESS-FEEL apple long delete hold left \(value(field).count) of \(typed)")
    }

    /// Cutling's keyboard: a cutling key held, then space, delete (tap and hold) and return in the bottom row.
    func testCutlingPresses() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FORMAT_TEST"]
        app.launch()
        app.terminate()
        addCutlingKeyboardInSettings()
        app.launch()
        closeTip(in: app)
        let field = openKeyboardTestField(in: app)
        switchToCutlingKeyboard(in: app, showing: "Plain")
        XCTAssertTrue(cutlingKeyboardIsUp(in: app, showing: "Plain"), "Cutling keyboard did not come up")
        guard let board = cutlingKeyboardFrame(in: app), let plain = cutlingKeyFrame("Plain", in: app) else {
            return XCTFail("No Cutling keyboard frame")
        }
        print("PRESS-FEEL keyboard \(board) plain \(plain)")
        // The bottom row as KeyboardView lays it out: 6 pt padding and spacing, globe and delete 52 wide,
        // return 92 wide, the space bar between, 44 tall and 2 pt above the keyboard's bottom.
        let hasGlobe = cutlingKeys(in: app)?.contains { $0.label == "Next keyboard" } ?? false
        let rowY = board.maxY - 2 - 22
        let deleteX = board.minX + 6 + (hasGlobe ? 58 : 0) + 26
        let returnX = board.maxX - 6 - 46
        let spaceX = (deleteX + 26 + 6 + returnX - 46 - 6) / 2
        let plainKey = screenPoint(plain.midX, plain.midY, in: app)

        for _ in 0..<6 { plainKey.tap(); usleep(400_000) }
        let typed = value(field).count
        mark("cutling_typed_\(typed)")
        sleep(rest)

        press(plainKey, "cutling_key", hold)
        let afterKey = value(field).count
        XCTAssertGreaterThan(afterKey, typed, "A held cutling key should type it on release")
        press(screenPoint(spaceX, rowY, in: app), "cutling_space", hold)
        XCTAssertEqual(value(field).count, afterKey + 1, "Space should type one character")
        screenPoint(deleteX, rowY, in: app).tap(); sleep(rest); mark("cutling_delete_tap")
        XCTAssertEqual(value(field).count, afterKey, "A delete tap should take one character")
        press(screenPoint(deleteX, rowY, in: app), "cutling_delete_hold", deleteHold)
        print("PRESS-FEEL cutling delete hold left \(value(field).count) of \(afterKey)")
        press(screenPoint(returnX, rowY, in: app), "cutling_return", hold)
        // A multi-line field takes a new line; 1.6.2's one-line field ends editing instead.
        XCTAssertTrue(value(field).hasSuffix("\n") || (field.value(forKey: "hasKeyboardFocus") as? Bool) == false, "Return should type a new line")

        // Delete held 7 s over about 96 characters, timed against testAppleDeleteHoldLong.
        guard (field.value(forKey: "hasKeyboardFocus") as? Bool) != false else { return }
        for _ in 0..<16 { plainKey.tap(); usleep(400_000) }
        let long = value(field).count
        mark("cutling_long_typed_\(long)")
        sleep(rest)
        press(screenPoint(deleteX, rowY, in: app), "cutling_delete_hold_long", 7)
        print("PRESS-FEEL cutling long delete hold left \(value(field).count) of \(long)")
    }

    private func press(_ point: XCUICoordinate, _ name: String, _ duration: TimeInterval) {
        mark("\(name)_before")
        point.press(forDuration: duration)
        sleep(rest)
        mark(name)
    }

    /// The Cutling keyboard's frame on screen: the host of its root, found as `cutlingKeys(in:)` finds it.
    private func cutlingKeyboardFrame(in app: XCUIApplication) -> CGRect? {
        guard let tree = try? app.snapshot() else { return nil }
        func find(_ node: XCUIElementSnapshot, _ ancestors: [XCUIElementSnapshot]) -> CGRect? {
            if node.identifier == "CutlingKeyboardView" {
                var rootSize: CGSize?
                for ancestor in ancestors.reversed() {
                    if ancestor.frame.origin == .zero { rootSize = ancestor.frame.size; continue }
                    guard let size = rootSize else { continue }
                    return ancestor.frame.size == size ? ancestor.frame : nil
                }
                return nil
            }
            for child in node.children {
                if let found = find(child, ancestors + [node]) { return found }
            }
            return nil
        }
        return find(tree, [])
    }
}
