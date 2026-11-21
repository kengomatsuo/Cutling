//
//  AppleWelcomeCaptureUITests.swift
//  CutlingUITests
//
//  Shoots the first screen each of Apple's own apps shows on this simulator: the
//  "Welcome to" and "What's New" sheets Cutling's own What's New sheet and setup guide are
//  held against (ASG103, ASG105). Apple publishes no picture of these sheets, so the
//  simulator is the source. An app that is missing or was opened before shows its normal
//  screen, and the shot says so.
//
//  Shots go to $FORMAT_TEST_SHOTS as apple_<app>.png.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class AppleWelcomeCaptureUITests: XCTestCase {

    private let apps: [(name: String, bundle: String)] = [
        ("photos", "com.apple.mobileslideshow"),
        ("reminders", "com.apple.reminders"),
        ("calendar", "com.apple.mobilecal"),
        ("maps", "com.apple.Maps"),
        ("passwords", "com.apple.Passwords"),
        ("freeform", "com.apple.freeform"),
        ("journal", "com.apple.journal"),
        ("shortcuts", "com.apple.shortcuts"),
        ("news", "com.apple.news"),
        ("health", "com.apple.Health"),
        ("wallet", "com.apple.Passbook"),
        ("files", "com.apple.DocumentsApp"),
        ("preview", "com.apple.Preview"),
        ("games", "com.apple.games"),
        ("tips", "com.apple.tips"),
        ("notes", "com.apple.mobilenotes"),
        ("messages", "com.apple.MobileSMS"),
        ("contacts", "com.apple.MobileAddressBook"),
        ("translate", "com.apple.Translate"),
        ("weather", "com.apple.weather"),
        ("clock", "com.apple.mobiletimer"),
        ("safari", "com.apple.mobilesafari"),
    ]

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    @MainActor
    func testAppleFirstScreens() throws {
        let dir = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"]
        for (name, bundle) in apps {
            let app = XCUIApplication(bundleIdentifier: bundle)
            app.launch()
            guard app.wait(for: .runningForeground, timeout: 8) else { continue }
            sleep(4)
            let png = XCUIScreen.main.screenshot().pngRepresentation
            if let dir {
                try? png.write(to: URL(fileURLWithPath: dir).appendingPathComponent("apple_\(name).png"))
            }
            // A second page of a welcome flow, when its button is plainly Continue.
            let cont = app.buttons["Continue"].firstMatch
            if cont.exists, cont.isHittable {
                cont.tap()
                sleep(3)
                if let dir {
                    try? XCUIScreen.main.screenshot().pngRepresentation
                        .write(to: URL(fileURLWithPath: dir).appendingPathComponent("apple_\(name)_2.png"))
                }
            }
            app.terminate()
        }
    }
}
