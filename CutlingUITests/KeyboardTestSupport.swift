//
//  KeyboardTestSupport.swift
//  CutlingUITests
//
//  Steps every keyboard UI test shares: add the Cutling keyboard in
//  Settings, open the setup guide's test field, and bring the Cutling
//  keyboard up in it.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

extension XCTestCase {

    /// Adds the Cutling keyboard with Full Access through Settings when it isn't there yet.
    @MainActor
    func addCutlingKeyboardInSettings() {
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
            if !addNew.exists { settings.swipeUp() }
            addNew.tap()
            let option = settings.cells.staticTexts["Cutling"].firstMatch
            if !option.waitForExistence(timeout: 3) { settings.swipeUp() }
            option.tap()
            sleep(1)
        }
        XCTAssertTrue(cutling.waitForExistence(timeout: 5), "Cutling keyboard not added")
        cutling.tap()
        let fullAccess = settings.switches.matching(NSPredicate(format: "label CONTAINS[c] 'Allow Full Access'")).firstMatch
        if fullAccess.waitForExistence(timeout: 3), fullAccess.value as? String == "0" {
            settingsSwitch(fullAccess).tap()
            let allow = settings.alerts.buttons["Allow"].firstMatch
            if allow.waitForExistence(timeout: 3) { allow.tap() }
        }
        settings.terminate()
    }

    /// A simulator with no Apple Account signed in can raise the system's "Sign in with Apple ID" alert over any app, and it
    /// takes the keyboard; a person cancels it, and so does every tap it blocks.
    @MainActor
    func cancelsSystemSignIn() {
        addUIInterruptionMonitor(withDescription: "Sign in with Apple ID") { alert in
            let cancel = alert.buttons["Cancel"]
            guard alert.label.localizedCaseInsensitiveContains("Apple ID") || alert.staticTexts["Sign in with Apple ID"].exists,
                  cancel.exists else { return false }
            cancel.tap()
            return true
        }
    }

    /// The part of a Settings switch row that takes a tap: iOS 27 nests the control inside the labelled switch, iOS 17
    /// reports the labelled switch alone.
    @MainActor
    func settingsSwitch(_ row: XCUIElement) -> XCUIElement {
        let inner = row.switches.firstMatch
        return inner.exists ? inner : row
    }

    /// Opens the setup guide's keyboard test field and focuses it.
    /// `onGrid` runs once the seeded grid shows, before the guide opens; pass `seeded: false`
    /// for an empty store, which has no card to wait for.
    @MainActor
    func openKeyboardTestField(in app: XCUIApplication, seeded: Bool = true, onGrid: () -> Void = {}) -> XCUIElement {
        // A first launch opens the setup guide itself; otherwise open it from the toolbar.
        if !app.buttons["continueButton"].firstMatch.waitForExistence(timeout: 5) {
            if seeded {
                let card = app.descendants(matching: .any).matching(identifier: "cutlingCard").firstMatch
                XCTAssertTrue(card.waitForExistence(timeout: 30), "Seeded cards did not appear")
            }
            onGrid()
            let kbButton = app.buttons["keyboardToolbarButton"].firstMatch
            XCTAssertTrue(kbButton.waitForExistence(timeout: 5))
            let guide = app.buttons["keyboardSetupGuide"].firstMatch
            // A tap while a large seeded store is still loading can open nothing; tap again.
            for _ in 0..<3 where !guide.exists {
                kbButton.tap()
                if guide.waitForExistence(timeout: 4) { break }
            }
            if !guide.waitForExistence(timeout: 3) { app.swipeUp() }
            XCTAssertTrue(guide.waitForExistence(timeout: 5))
            // The sheet can still be animating in; retry until the guide opens.
            for _ in 0..<3 where !app.buttons["continueButton"].firstMatch.waitForExistence(timeout: 3) {
                guide.tap()
            }
        }
        // The guide reopens on its last page: step back to the first, then forward to the test page.
        let field = app.textFields["keyboardTestField"].firstMatch
        for _ in 0..<6 where !field.exists {
            // The guide's own Back: on iOS 17 the Keyboard sheet's bar behind the guide comes first in the tree.
            let back = app.navigationBars.buttons.matching(NSPredicate(format: "identifier == 'BackButton' OR label == 'Back'")).firstMatch
            guard back.exists else { break }
            back.tap()
            sleep(1)
        }
        for _ in 0..<2 where !field.exists {
            let cont = app.buttons["continueButton"].firstMatch
            XCTAssertTrue(cont.waitForExistence(timeout: 3))
            cont.tap()
            sleep(1)
        }
        XCTAssertTrue(field.waitForExistence(timeout: 3), "Keyboard test field not found")
        // On a loaded Mac the first tap can land before the field takes focus; tap until a keyboard shows.
        // A retry taps only while no keyboard shows: a rising keyboard scrolls the page, and a tap at the
        // field's old place lands on whatever moved there (Continue, or empty space that closes the keyboard).
        for _ in 0..<3 {
            if field.isHittable { field.tap() }
            if app.keyboards.firstMatch.waitForExistence(timeout: 20) { break }
        }
        sleep(2)
        return field
    }

    /// The globe key, found by name: simulators place it differently (under the keys on most iPhones,
    /// in the bottom row of a wide one's), so no screen fraction finds it everywhere.
    /// Labels for the languages the tests and films run in.
    @MainActor
    func keyboardGlobe(in app: XCUIApplication) -> XCUIElement {
        let label = NSPredicate(format: "label ==[c] 'Next keyboard' OR label ==[c] 'Papan Ketik Berikutnya' OR label ==[c] '次のキーボード'")
        // Buttons and keys only: an any-type match found a non-key element whose press closed the keyboard.
        return onKeyboard(app.buttons.matching(label), in: app) ?? onKeyboard(app.keys.matching(label), in: app)
            ?? app.buttons["no globe key"]
    }

    /// The Cutling keyboard's buttons, with their frames on screen, read from one accessibility snapshot; nil while
    /// Cutling is not up. The root's `CutlingKeyboardView` identifier lands on its leaves (the clipboard bar, the grid,
    /// the globe), not on the keys or the root itself. iOS 27 reports the keyboard's elements in its own coordinates (the
    /// root reads 0,0), so a tap at a key's frame lands on the app above; the host of the root's size gives the offset.
    @MainActor
    func cutlingKeys(in app: XCUIApplication) -> [(label: String, frame: CGRect)]? {
        guard let tree = try? app.snapshot() else { return nil }
        func find(_ node: XCUIElementSnapshot, _ ancestors: [XCUIElementSnapshot]) -> [(label: String, frame: CGRect)]? {
            if node.identifier == "CutlingKeyboardView" {
                // Up from the first marked element: the keyboard's root reads 0,0, and the first element above it
                // of the same size with a real origin is its host on screen. Without such a pair the frames are
                // already on screen.
                var rootSize: CGSize?
                var host: XCUIElementSnapshot?
                for ancestor in ancestors.reversed() {
                    if ancestor.frame.origin == .zero { rootSize = ancestor.frame.size; continue }
                    guard let size = rootSize else { continue }
                    if ancestor.frame.size == size { host = ancestor }
                    break
                }
                let scope = host ?? ancestors.last ?? node
                let dx = host?.frame.minX ?? 0, dy = host?.frame.minY ?? 0
                var keys: [(label: String, frame: CGRect)] = []
                func collect(_ element: XCUIElementSnapshot) {
                    if element.elementType == .button { keys.append((element.label, element.frame.offsetBy(dx: dx, dy: dy))) }
                    element.children.forEach(collect)
                }
                // The host's own frame is on screen; only what sits under it is in keyboard coordinates.
                scope.children.forEach(collect)
                return keys
            }
            for child in node.children {
                if let found = find(child, ancestors + [node]) { return found }
            }
            return nil
        }
        return find(tree, [])
    }

    /// A cutling's key on screen, by the cutling's name. Its label is the name, then the text after a comma (「、」 in Japanese);
    /// an image key's placeholder icon can come first.
    @MainActor
    func cutlingKeyFrame(_ name: String, in app: XCUIApplication) -> CGRect? {
        cutlingKeys(in: app)?.first { $0.label == name || $0.label.hasPrefix(name + ",") || $0.label.hasPrefix(name + "、") || $0.label.hasSuffix(", " + name) }?.frame
    }

    /// A point on screen, in points from the top-left corner.
    @MainActor
    func screenPoint(_ x: CGFloat, _ y: CGFloat, in app: XCUIApplication) -> XCUICoordinate {
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: x, dy: y))
    }

    /// The first element of `query` in the lower half of the screen.
    @MainActor
    func onKeyboard(_ query: XCUIElementQuery, in app: XCUIApplication) -> XCUIElement? {
        let half = app.frame.height / 2
        return query.allElementsBoundByIndex.first { $0.exists && $0.frame.midY > half }
    }

    /// Cutling's keys are buttons, not keys, so zero keys with Cutling's root in the tree means Cutling is up;
    /// given a cutling's name, its key must show too. Keys also read zero mid-switch, so it must hold for two seconds.
    @MainActor
    func cutlingKeyboardIsUp(in app: XCUIApplication, showing name: String? = nil) -> Bool {
        var steady = 0
        for _ in 0..<10 {
            let shown = name.map { cutlingKeyFrame($0, in: app) != nil } ?? (cutlingKeys(in: app) != nil)
            steady = app.keys.count == 0 && shown ? steady + 1 : 0
            if steady >= 4 { return true }
            usleep(500_000)
        }
        return false
    }

    /// Switches the focused field to the Cutling keyboard through the globe key; `hold` is how long the finger rests on
    /// a row of the globe menu before letting go.
    @MainActor
    func switchToCutlingKeyboard(in app: XCUIApplication, showing name: String? = nil, hold: TimeInterval = 0.4) {
        // A tap on iOS 27's globe goes back to the keyboard used last, never on down the list, so taps alone reach
        // Cutling only when it was one of the last two keyboards used.
        XCTAssertTrue(cutlingKeyboardIsUp(in: app, showing: name) || keyboardGlobe(in: app).waitForExistence(timeout: 10),
                      "No globe key (keys: \(app.keys.count))")
        // The keyboard's own buttons, named in the log, so a run that never reaches Cutling shows what it tapped.
        print("KEYBOARD-BUTTONS: " + app.keyboards.buttons.allElementsBoundByIndex.map { "\($0.identifier)|\($0.label)" }.joined(separator: ", "))
        // As a person does it: hold the globe and, in the same touch, slide up its list and let go on Cutling. The list
        // grows up from the globe in Settings' order, Cutling last, so its row is the first one above the globe; each
        // try lets go one row higher until the Cutling keyboard is up.
        for row in 1...10 where !cutlingKeyboardIsUp(in: app, showing: name) {
            let globe = keyboardGlobe(in: app)
            guard globe.waitForExistence(timeout: 5) else { break }
            let start = globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            start.press(forDuration: 1.0, thenDragTo: start.withOffset(CGVector(dx: 70, dy: -44 * CGFloat(row))),
                        withVelocity: .slow, thenHoldForDuration: hold)
            sleep(2)
        }
        // Each tap moves to the next keyboard; wait for each switch to land.
        for _ in 0..<15 where !cutlingKeyboardIsUp(in: app, showing: name) {
            let globe = keyboardGlobe(in: app)
            // A screen-point tap: the system globe under a Face ID iPhone's keyboard refuses scroll-to-visible.
            if globe.waitForExistence(timeout: 5) { globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
            let tip = app.buttons.matching(NSPredicate(format: "label IN {'Continue', '次へ'} AND identifier != 'continueButton'")).firstMatch
            if tip.waitForExistence(timeout: 1) { tip.tap(); sleep(1) }
        }
    }
}
