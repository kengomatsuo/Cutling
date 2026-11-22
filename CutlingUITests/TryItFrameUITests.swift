//
//  TryItFrameUITests.swift
//  CutlingUITests
//
//  Store frame 04: the setup guide's Try It page in dark mode, with the Cutling keyboard up and
//  the first seeded cutling typed into the try field. One run per store language and device:
//
//    FRAME_LANGUAGE=de-DE FRAME_SHOTS=<dir> scripts/frame04.sh
//
//  The keyboard is added in Settings once per simulator; Settings stays in English, as fastlane
//  snapshot leaves it, and only the app runs in the store language.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class TryItFrameUITests: SetupMockTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Turns the keyboard on the way a buyer does, once per simulator: a fresh install opens the setup guide, whose
    /// Open Settings lands on Cutling's page in Settings (Keyboards, the Cutling switch, Full Access). Writing iOS's
    /// keyboard list directly left a store simulator showing only the Emoji key (2026-11-22).
    @MainActor func testAddKeyboard() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-hasSeenInteractiveTutorial", "YES"]
        app.launch()
        let next = app.buttons["continueButton"].firstMatch
        XCTAssertTrue(next.waitForExistence(timeout: 30), "Setup guide did not open")
        next.tap()
        sleep(2)
        let open = app.buttons["openSettingsButton"].firstMatch
        XCTAssertTrue(open.waitForExistence(timeout: 10), "No Open Settings button")
        open.tap()
        walkSettings("frame04")
        XCUIApplication(bundleIdentifier: "com.apple.Preferences").terminate()
    }

    @MainActor func testTryItFrame() throws {
        let env = ProcessInfo.processInfo.environment
        let language = env["FRAME_LANGUAGE"] ?? "en-US"
        // scripts/frame04.sh puts Cutling into iOS's keyboard list; Settings is the fallback.
        if env["FRAME_SETTINGS"] == "1" { addCutlingKeyboardInSettings() }

        let app = XCUIApplication()
        app.launchArguments += ["-SNAPSHOT_MODE", "-SNAPSHOT_DARK", "YES", "-hasSeenInteractiveTutorial", "YES",
                                "-AppleLanguages", "(\(language))", "-AppleLocale", language.replacingOccurrences(of: "-", with: "_")]
        app.launch()
        _ = openKeyboardTestField(in: app)
        if !keyboardGlobe(in: app).waitForExistence(timeout: 5), let dir = env["FRAME_SHOTS"] {
            // What the keyboard offers when the globe is not found by name, for the next fix.
            let half = app.frame.height / 2
            let named = (app.buttons.allElementsBoundByIndex + app.keys.allElementsBoundByIndex)
                .filter { $0.frame.minY > half && $0.label.count > 1 }
                .map { "\($0.elementType.rawValue) \($0.label) \($0.identifier) \($0.frame)" }
            try? named.joined(separator: "\n").write(toFile: "\(dir)/\(language)-keys.txt", atomically: true, encoding: .utf8)
            try? XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: "\(dir)/\(language)-no-globe.png"))
        }
        switchToCutlingKeyboard(in: app)
        if !cutlingKeyboardIsUp(in: app), let dir = env["FRAME_SHOTS"] {
            try? XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: "\(dir)/\(language)-no-cutling.png"))
            try? app.debugDescription.write(toFile: "\(dir)/\(language)-tree.txt", atomically: true, encoding: .utf8)
        }
        XCTAssertTrue(cutlingKeyboardIsUp(in: app), "Cutling keyboard did not come up")

        // The first seeded cutling (Home Address in every language) is the grid's first key.
        let keys = cutlingKeys(in: app) ?? []
        let first = try XCTUnwrap(keys.filter { !$0.label.isEmpty }.min { ($0.frame.minY, $0.frame.minX) < ($1.frame.minY, $1.frame.minX) },
                                  "No Cutling keys")
        screenPoint(first.frame.midX, first.frame.midY, in: app).tap()
        sleep(3)

        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.lifetime = .keepAlways
        add(attachment)
        if let dir = env["FRAME_SHOTS"] {
            try shot.pngRepresentation.write(to: URL(fileURLWithPath: dir).appendingPathComponent("\(language).png"))
        }
    }
}
