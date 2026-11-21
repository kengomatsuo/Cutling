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
        for design in ["own"] {
            for dark in [false, true] {
                XCUIDevice.shared.appearance = dark ? .dark : .light
                let app = XCUIApplication()
                app.launchArguments += ["-FILLIN_TEST", "-FILLIN_MOCK", design]
                app.launch()
                if !keyboardAdded {
                    app.terminate()
                    addCutlingKeyboardInSettings()
                    keyboardAdded = true
                    app.launch()
                }
                _ = openKeyboardTestField(in: app)
                switchToCutlingKeyboard(in: app, showing: "Reply")
                // The keyboard sometimes stays down on a fresh launch; one more launch brings it up.
                if !cutlingKeyboardIsUp(in: app, showing: "Reply") {
                    app.terminate()
                    app.launch()
                    _ = openKeyboardTestField(in: app)
                    switchToCutlingKeyboard(in: app, showing: "Reply")
                }
                let mode = dark ? "dark" : "light"
                shot("\(design)_0_grid_\(mode)")
                tapKey("Reply", in: app)
                shot("\(design)_1_name_\(mode)")
                tapKey("Sarah", in: app)
                shot("\(design)_2_plan_\(mode)")
                tapKey("Basic", in: app)
                app.terminate()
            }
        }
        XCUIDevice.shared.appearance = .light
    }
}
