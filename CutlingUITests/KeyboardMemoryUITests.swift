//
//  KeyboardMemoryUITests.swift
//  CutlingUITests
//
//  Drives the Cutling keyboard through its heaviest moments with a store
//  filled past the caps, so scripts/keyboard-memory.sh can read the
//  keyboard process's memory from the host while it runs.
//
//  Runner environment (xcodebuild passes TEST_RUNNER_<NAME> as <NAME>):
//  MEMTEST_TEXT, MEMTEST_IMAGES  cutlings to seed (see seedForMemoryTest)
//  MEMTEST_FLINGS                flings each way through the grid (default 40)
//  MEMTEST_LOG                   host file that gets "<phase> <epoch seconds>" lines
//  MEMTEST_SHOTS                 host folder for a screenshot per phase
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class KeyboardMemoryUITests: XCTestCase {

    private let environment = ProcessInfo.processInfo.environment

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Notes the moment a phase starts, for the host's memory samples.
    private func mark(_ phase: String) {
        if let dir = environment["MEMTEST_SHOTS"] {
            let data = XCUIScreen.main.screenshot().pngRepresentation
            try? data.write(to: URL(fileURLWithPath: dir).appendingPathComponent("\(phase).png"))
        }
        guard let path = environment["MEMTEST_LOG"] else { return }
        let line = "\(phase) \(Date().timeIntervalSince1970)\n"
        if let handle = FileHandle(forWritingAtPath: path) {
            handle.seekToEndOfFile()
            handle.write(Data(line.utf8))
            try? handle.close()
        } else {
            FileManager.default.createFile(atPath: path, contents: Data(line.utf8))
        }
    }

    @MainActor
    func testKeyboardMemory() throws {
        let textCount = environment["MEMTEST_TEXT"] ?? "0"
        let imageCount = environment["MEMTEST_IMAGES"] ?? "0"
        let flings = Int(environment["MEMTEST_FLINGS"] ?? "") ?? 40

        let app = XCUIApplication()
        app.launchArguments += ["-MEMORY_TEST", "-MEMTEST_TEXT", textCount, "-MEMTEST_IMAGES", imageCount]
        // The first launch seeds and registers the keyboard extension; the second finds the store filled.
        app.launch()
        let card = app.descendants(matching: .any).matching(identifier: "cutlingCard").firstMatch
        // The seed renders a 12-megapixel photo on the main thread, which takes minutes on a loaded Mac;
        // ending the app before it saves makes the second launch seed again from nothing.
        XCTAssertTrue(card.waitForExistence(timeout: 600) || (textCount == "0" && imageCount == "0"), "Seeding did not finish")
        app.terminate()
        addCutlingKeyboardInSettings()
        app.launch()

        _ = openKeyboardTestField(in: app, seeded: textCount != "0" || imageCount != "0")
        switchToCutlingKeyboard(in: app)
        XCTAssertTrue(cutlingKeyboardIsUp(in: app), "Cutling keyboard did not come up (keys: \(app.keys.count))")
        mark("keyboard_up")
        sleep(3)

        // Fling through the whole grid and back, so every card and thumbnail is built once.
        let low = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.86))
        let high = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.64))
        mark("scroll_down")
        for _ in 0..<flings {
            low.press(forDuration: 0.05, thenDragTo: high, withVelocity: .fast, thenHoldForDuration: 0)
        }
        sleep(2)
        mark("scroll_up")
        for _ in 0..<flings {
            high.press(forDuration: 0.05, thenDragTo: low, withVelocity: .fast, thenHoldForDuration: 0)
        }
        sleep(2)

        // Images are seeded first, so the first card copies a full-size image.
        if imageCount != "0" {
            mark("copy_image")
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.71)).tap()
            sleep(3)
        }
        mark("end")
        sleep(2)
    }
}
