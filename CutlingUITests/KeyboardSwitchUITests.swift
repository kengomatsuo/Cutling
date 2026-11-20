//
//  KeyboardSwitchUITests.swift
//  CutlingUITests
//
//  Measures where Cutling's globe key (advanceToNextInputMode) sends the person: back to the
//  keyboard they came from, or on to the next one in Settings' order. No public API picks a
//  keyboard (docs/research/fill-ins-keyboard-apis.md, Q1), so a "back to my keyboard" key
//  depends on this answer. Writes what it saw to $FORMAT_TEST_SHOTS/keyboard-switch.txt.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class KeyboardSwitchUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    /// A short name for the keyboard on screen: Cutling, or the first few key labels of a system keyboard.
    @MainActor private func signature(_ app: XCUIApplication) -> String {
        if cutlingKeys(in: app) != nil { return "Cutling" }
        let labels = app.keys.allElementsBoundByIndex.prefix(6).map(\.label).filter { !$0.isEmpty }
        let buttons = app.buttons.allElementsBoundByIndex.map(\.label).filter { ["ABC", "Search Emoji", "emoji"].contains($0) }
        return (labels + buttons).joined(separator: " ")
    }

    @MainActor private func tapGlobe(_ app: XCUIApplication) {
        if cutlingKeys(in: app) != nil, let f = cutlingKeyFrame("Next keyboard", in: app) {
            screenPoint(f.midX, f.midY, in: app).tap()
        } else {
            let globe = keyboardGlobe(in: app)
            if globe.waitForExistence(timeout: 5) { globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
        }
        sleep(2)
    }

    @MainActor
    func testWhereCutlingsGlobeGoes() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FILLIN_TEST"]
        app.launch()
        app.terminate()
        addCutlingKeyboardInSettings()
        app.launch()
        _ = openKeyboardTestField(in: app)
        sleep(2)

        // 1. From the keyboard that came up, globe by globe to Cutling.
        var path = [signature(app)]
        for _ in 0..<12 where path.last != "Cutling" {
            tapGlobe(app)
            path.append(signature(app))
        }
        XCTAssertEqual(path.last, "Cutling", "Never reached Cutling: \(path)")
        let before = path.count >= 2 ? path[path.count - 2] : "?"

        // 2. Cutling's own globe key.
        tapGlobe(app)
        let landed = signature(app)
        let shots = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"]
        if let dir = shots {
            try? XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: dir).appendingPathComponent("switch_after_cutling_globe.png"))
        }

        // 3. From there back to Cutling: one globe tap if it went back, N-1 if it went on.
        var back = 0
        for _ in 0..<12 where signature(app) != "Cutling" {
            tapGlobe(app)
            back += 1
        }

        let report = """
        path to Cutling: \(path.joined(separator: " -> "))
        keyboard before Cutling: \(before)
        Cutling's globe landed on: \(landed)
        returned to the keyboard before: \(landed == before)
        globe taps from there back to Cutling: \(back)
        """
        print(report)
        add(XCTAttachment(string: report))
        if let dir = shots {
            try? report.write(to: URL(fileURLWithPath: dir).appendingPathComponent("keyboard-switch.txt"), atomically: true, encoding: .utf8)
        }
    }
}
