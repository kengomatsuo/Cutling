//
//  AppleKeyboardReferenceUITests.swift
//  CutlingUITests
//
//  Records Apple's own keyboard for reference (board ASG100, ASG101): how each kind of key looks
//  while held and after release, and whether switching layouts (letters, numbers, emoji) animates.
//  Nothing is asserted; the queued runner's screen recording (run.mp4) and the shots are the result.
//  Findings: docs/research/fill-ins-press-feedback.md
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class AppleKeyboardReferenceUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    @MainActor
    func testRecordApplePresses() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FILLIN_TEST"]
        app.launch()
        _ = openKeyboardTestField(in: app)
        sleep(2)
        // Back to a letter keyboard if another one is up.
        for _ in 0..<8 where !app.keys["q"].exists && !app.keys["Q"].exists {
            let globe = keyboardGlobe(in: app)
            if globe.exists { globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
            sleep(1)
        }
        let dir = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"]
        func shot(_ name: String) {
            if let dir { try? XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: dir).appendingPathComponent("apple_\(name).png")) }
        }
        shot("0_idle")
        // Each key held 1.5 s, then 1.5 s of rest, so the recording shows the held look and the release.
        for name in ["q", "Q", "a", "A", "space", "delete", "Delete", "shift", "Shift", "return", "Return", "more", "123"] {
            let key = app.keys[name].exists ? app.keys[name] : app.buttons[name]
            guard key.exists else { continue }
            key.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 1.5)
            sleep(1)
            shot("after_\(name)")
        }
        // Layout switches: numbers and back, then emoji and back with ABC.
        for name in ["more", "123", "letters", "ABC", "emoji", "Emoji", "Next keyboard"] {
            let key = app.keys[name].exists ? app.keys[name] : app.buttons[name]
            guard key.exists else { continue }
            key.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            sleep(2)
            shot("switched_\(name)")
        }
        print("keys on screen: \(app.keys.allElementsBoundByIndex.prefix(40).map(\.label))")
    }
}
