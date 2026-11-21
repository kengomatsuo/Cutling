//
//  SettingsDemoRecordingUITests.swift
//  CutlingUITests
//
//  Walks the real Settings steps a new buyer takes (Cutling's page, Keyboards, the Cutling
//  switch, Allow Full Access, Apple's alert) at a viewer's pace, and writes when and where
//  each tap lands, so scripts/record-settings-demo.sh can cut the screen recording into the
//  setup guide's looping video and draw a touch mark on every tap. The owner asked for the
//  real Settings page, moving, instead of a drawn picture (ASG105).
//
//  Writes $FORMAT_TEST_SHOTS/marks.txt: one line per event, "<name> <epoch seconds> <x> <y>",
//  x and y as fractions of the screen.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class SettingsDemoRecordingUITests: XCTestCase {

    private var marks: [String] = []

    @MainActor private func mark(_ name: String, _ element: XCUIElement? = nil, in app: XCUIApplication) {
        var x = 0.0, y = 0.0
        if let element, element.exists {
            let screen = app.frame
            x = (element.frame.midX - screen.minX) / screen.width
            y = (element.frame.midY - screen.minY) / screen.height
        }
        marks.append(String(format: "%@ %.3f %.4f %.4f", name, Date().timeIntervalSince1970, x, y))
    }

    /// Marks the element, holds still a moment so the viewer's eye finds it, then taps it.
    @MainActor private func showAndTap(_ name: String, _ element: XCUIElement, in app: XCUIApplication) {
        mark(name, element, in: app)
        usleep(700_000)
        element.tap()
    }

    @MainActor
    func testRecordSettingsSteps() throws {
        // Installed by the test run; Settings lists it under Apps.
        XCUIApplication().launch()
        XCUIApplication().terminate()

        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.launch()
        XCTAssertTrue(settings.wait(for: .runningForeground, timeout: 10))
        let apps = settings.cells.staticTexts["Apps"].firstMatch
        if !apps.waitForExistence(timeout: 5) { settings.swipeUp() }
        apps.tap()
        sleep(2)
        var cutling = settings.cells.staticTexts["Cutling"].firstMatch
        for _ in 0..<8 where !cutling.isHittable { settings.swipeUp(); usleep(500_000) }
        cutling.tap()
        let keyboards = settings.cells.staticTexts["Keyboards"].firstMatch
        XCTAssertTrue(keyboards.waitForExistence(timeout: 10), "Cutling's page has no Keyboards row")
        sleep(1)

        // The video starts here: Cutling's page, where Open Settings lands on a device.
        mark("begin", in: settings)
        sleep(2)
        showAndTap("keyboards", keyboards, in: settings)
        sleep(2)
        cutling = settings.switches.matching(NSPredicate(format: "label CONTAINS[c] 'Cutling'")).firstMatch
        XCTAssertTrue(cutling.waitForExistence(timeout: 5))
        showAndTap("cutling", cutling.switches.firstMatch, in: settings)
        sleep(2)
        let fullAccess = settings.switches.matching(NSPredicate(format: "label CONTAINS[c] 'Full Access'")).firstMatch
        XCTAssertTrue(fullAccess.waitForExistence(timeout: 5))
        showAndTap("fullAccess", fullAccess.switches.firstMatch, in: settings)
        let allow = settings.alerts.buttons["Allow"].firstMatch
        XCTAssertTrue(allow.waitForExistence(timeout: 5))
        sleep(2)
        showAndTap("allow", allow, in: settings)
        sleep(2)
        mark("end", in: settings)

        if let dir = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"] {
            try (marks.joined(separator: "\n") + "\n")
                .write(to: URL(fileURLWithPath: dir).appendingPathComponent("marks.txt"), atomically: true, encoding: .utf8)
        }
        print(marks.joined(separator: "\n"))
    }
}
