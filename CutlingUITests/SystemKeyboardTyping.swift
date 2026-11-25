//
//  SystemKeyboardTyping.swift
//  CutlingUITests
//
//  Types on the iPhone's own English keyboard by touching its keys, as a person does. XCUITest's typeText arrives as
//  hardware key events, so a film of it shows letters appear with no key going down; a promo take that shows typing
//  uses this instead.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

extension XCTestCase {

    /// Touches the keys that type `text` on the US keyboard in `app`, one touch every `slot` seconds: shift for a capital
    /// the keyboard has not capitalised itself, the 123 key for punctuation, space back to the letters. Key centres are
    /// read before the first touch, so a keystroke costs a touch and no lookup. `mark` gets one line per touch.
    @MainActor
    func pressKeys(_ text: String, in app: XCUIApplication, slot: Double, mark: (String) -> Void = { _ in }) {
        XCTAssertTrue(app.keys["a"].waitForExistence(timeout: 10) || app.keys["A"].waitForExistence(timeout: 2), "No system keyboard")
        func point(_ frame: CGRect) -> XCUICoordinate { screenPoint(frame.midX, frame.midY, in: app) }
        func find(_ query: XCUIElementQuery, _ format: String, _ args: [Any]) -> XCUICoordinate? {
            let element = query.matching(NSPredicate(format: format, argumentArray: args)).firstMatch
            return element.waitForExistence(timeout: 5) ? point(element.frame) : nil
        }
        var letters: [Character: XCUICoordinate] = [:]
        for letter in Set(text.lowercased().filter(\.isLetter)) {
            letters[letter] = find(app.keys, "label ==[c] %@", [String(letter)])
            XCTAssertNotNil(letters[letter], "No \(letter) key")
        }
        let space = find(app.keys, "identifier ==[c] 'space' OR label ==[c] 'space'", [])
        let shift = find(app.buttons, "identifier ==[c] 'shift' OR label ==[c] 'shift'", []) ?? find(app.keys, "label ==[c] 'shift'", [])
        let more = find(app.keys, "identifier ==[c] 'more' OR label ==[c] 'numbers'", [])
        // punctuation sits on the 123 plane: its keys are read there before the first touch, then the letters come back
        var symbols: [Character: XCUICoordinate] = [:]
        let marks = Set(text.filter { !$0.isLetter && $0 != " " })
        if !marks.isEmpty, let more {
            more.tap()
            for sign in marks { symbols[sign] = find(app.keys, "label == %@", [String(sign)]) }
            more.tap()
            _ = app.keys["a"].waitForExistence(timeout: 3) || app.keys["A"].waitForExistence(timeout: 2)
        }

        var shifted = true  // an empty field starts capitalised
        var onNumbers = false
        var previous: Character = " "
        func touch(_ what: String, _ at: XCUICoordinate?) {
            guard let at else { return XCTFail("No key for \(what)") }
            let began = Date()
            mark("key \(what)")
            at.tap()
            let rest = slot - Date().timeIntervalSince(began)
            if rest > 0 { usleep(UInt32(rest * 1_000_000)) }
        }
        for character in text {
            if character == " " {
                touch("space", space)
                // iOS goes back to the letters after a space typed on the 123 plane; checked, since a miss types digits
                if onNumbers { onNumbers = !(app.keys["a"].exists || app.keys["A"].exists) }
                shifted = previous == "." || previous == "!" || previous == "?"
            } else if character.isLetter {
                if onNumbers { touch("letters", more); onNumbers = false }
                if character.isUppercase != shifted { touch("shift", shift); shifted.toggle() }
                touch(String(character), letters[Character(character.lowercased())])
                shifted = false
            } else {
                if !onNumbers { touch("123", more); onNumbers = true }
                if symbols[character] == nil { symbols[character] = find(app.keys, "label == %@", [String(character)]) }
                touch(String(character), symbols[character])
            }
            previous = character
        }
    }
}
