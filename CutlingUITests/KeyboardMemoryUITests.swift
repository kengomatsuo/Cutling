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
        // The seed renders a 12-megapixel photo on the main thread, which can take minutes on a loaded Mac;
        // ending the app before it saves makes the second launch seed again from nothing. An empty store has no card to wait for.
        XCTAssertTrue((textCount == "0" && imageCount == "0") || card.waitForExistence(timeout: 600), "Seeding did not finish")
        app.terminate()
        addCutlingKeyboardInSettings()
        app.launch()

        // Images are seeded first, so the first key is Photo 1, or Snippet 1 without images; an empty store has none.
        let firstName: String? = imageCount != "0" ? "Photo 1" : textCount != "0" ? "Snippet 1" : nil
        _ = openKeyboardTestField(in: app, seeded: firstName != nil)
        switchToCutlingKeyboard(in: app, showing: firstName)
        XCTAssertTrue(cutlingKeyboardIsUp(in: app, showing: firstName), "Cutling keyboard did not come up (keys: \(app.keys.count))")
        mark("keyboard_up")
        sleep(3)
        guard let firstName else {
            mark("end")
            sleep(2)
            return
        }

        // Fling through the whole grid and back, so every card and thumbnail is built once. Each fling is a swipe on
        // whichever key shows now: a coordinate drag (press, then drag) moved nothing in the keyboard's grid.
        let first = cutlingKey(firstName, in: app).frame
        let origin = app.coordinate(withNormalizedOffset: .zero)
        let anyKey = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Photo ' OR label BEGINSWITH 'Snippet ' OR label CONTAINS ', Photo '"))
        mark("scroll_down")
        for _ in 0..<flings {
            onKeyboard(anyKey, in: app)?.swipeUp(velocity: .fast)
        }
        sleep(2)
        mark("scroll_up")
        for _ in 0..<flings {
            onKeyboard(anyKey, in: app)?.swipeDown(velocity: .fast)
        }
        sleep(2)

        // Back at the top, the first key copies a full-size image.
        if imageCount != "0" {
            mark("copy_image")
            origin.withOffset(CGVector(dx: first.midX, dy: first.midY)).tap()
            sleep(3)
        }
        mark("end")
        sleep(2)
    }
}
