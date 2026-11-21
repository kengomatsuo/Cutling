//
//  FillInMockUITests.swift
//  CutlingUITests
//
//  Shoots the two fill-in design mocks (CutlingKeyboard/FillInMocks.swift) in the real keyboard,
//  light and dark, for the owner's contact sheet (board ASG86). Screenshots go to $FORMAT_TEST_SHOTS.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class FillInMockUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    @MainActor
    private func shot(_ name: String) {
        let data = XCUIScreen.main.screenshot().pngRepresentation
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.png")
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let dir = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"] {
            try? data.write(to: URL(fileURLWithPath: dir).appendingPathComponent("mock_\(name).png"))
        }
    }

    @MainActor
    private func tapKey(_ name: String, in app: XCUIApplication) {
        var frame: CGRect?
        for _ in 0..<10 {
            frame = cutlingKeyFrame(name, in: app)
            if frame != nil { break }
            usleep(500_000)
        }
        XCTAssertNotNil(frame, "No \(name) key (keys: \(cutlingKeys(in: app)?.map(\.label) ?? []))")
        guard let f = frame else { return }
        screenPoint(f.midX, f.midY, in: app).tap()
        sleep(1)
    }

    @MainActor
    func testShootDesigns() throws {
        var keyboardAdded = false
        // Light, light with a word typed first, and dark. Each step waits 2 s so the recording shows it.
        for (dark, typeFirst) in [(false, false), (false, true), (true, false)] {
            XCUIDevice.shared.appearance = dark ? .dark : .light
            let app = XCUIApplication()
            app.launchArguments += ["-FILLIN_TEST", "-FILLIN_MOCK", "own"]
            app.launch()
            if !keyboardAdded {
                app.terminate()
                addCutlingKeyboardInSettings()
                keyboardAdded = true
                app.launch()
            }
            let field = openKeyboardTestField(in: app)
            if typeFirst {
                // The person types the name with their own keyboard first.
                for _ in 0..<8 where !app.keys["a"].exists && !app.keys["A"].exists {
                    let globe = keyboardGlobe(in: app)
                    if globe.exists { globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
                    sleep(1)
                }
                field.typeText("Sarah")
                sleep(1)
            }
            switchToCutlingKeyboard(in: app, showing: "Reply")
            if !cutlingKeyboardIsUp(in: app, showing: "Reply") {
                app.terminate()
                app.launch()
                _ = openKeyboardTestField(in: app)
                switchToCutlingKeyboard(in: app, showing: "Reply")
            }
            let mode = (dark ? "dark" : "light") + (typeFirst ? "_typed" : "")
            sleep(2)
            shot("own_0_grid_\(mode)")
            tapKey("Reply", in: app)
            sleep(2)
            shot("own_1_name_\(mode)")
            tapKey(typeFirst ? "Sam" : "Sarah", in: app)
            sleep(2)
            shot("own_2_plan_\(mode)")
            tapKey("Basic", in: app)
            sleep(2)
            shot("own_3_back_\(mode)")
            app.terminate()
        }
        XCUIDevice.shared.appearance = .light
    }
}
