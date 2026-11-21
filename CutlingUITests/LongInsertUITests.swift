//
//  LongInsertUITests.swift
//  CutlingUITests
//
//  A text cutling may hold 10,000 characters (CutlingStore.maxTextLength). This checks that the
//  keyboard types one whole into the app's own test field and into a web page's text box in Safari.
//  LONG_INSERT_PAGE: the page Safari opens (scripts/fixtures/long-insert.html served from the Mac).
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

@MainActor
final class LongInsertUITests: XCTestCase {
    override func setUp() async throws { continueAfterFailure = false }

    /// The memory seed's text at its full length, as `seedForMemoryTest` builds it.
    private var expected: String {
        let mixed = "Invoice 2026-118 for **Alex Chen**, see [terms](https://example.com/terms). "
            + "お振込みは月末までにお願いいたします。 Überweisung bis Monatsende 🙂 "
            + "func pay(_ amount: Int) -> Bool { amount > 0 } "
        return String(String(repeating: mixed, count: 10_000 / mixed.count + 1).prefix(10_000))
    }

    private func shot(_ name: String, _ app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "long_insert_\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func tapCutling(_ name: String, in app: XCUIApplication) {
        var frame: CGRect?
        for _ in 0..<10 {
            frame = cutlingKeyFrame(name, in: app)
            if frame != nil { break }
            usleep(500_000)
        }
        XCTAssertNotNil(frame, "No \(name) key (keys: \(cutlingKeys(in: app)?.map(\.label) ?? []))")
        let f = frame ?? .zero
        screenPoint(f.midX, f.midY, in: app).tap()
    }

    private func check(_ text: String, where place: String) {
        let full = expected
        XCTAssertEqual(text.count, full.count, "\(place) holds \(text.count) characters, expected \(full.count)")
        XCTAssertEqual(String(text.suffix(60)), String(full.suffix(60)), "\(place) ends differently")
    }

    @MainActor
    func testTenThousandCharactersArriveWhole() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-MEMORY_TEST", "-MEMTEST_TEXT", "1", "-MEMTEST_IMAGES", "0"]
        app.launch()
        app.terminate()
        addCutlingKeyboardInSettings()
        app.launch()
        sleep(3)

        // The app's own test field.
        let field = openKeyboardTestField(in: app)
        switchToCutlingKeyboard(in: app, showing: "Snippet 1")
        let started = Date()
        tapCutling("Snippet 1", in: app)
        sleep(4)
        shot("app_field", app)
        check((field.value as? String) ?? "", where: "The app's test field")
        print("LONG_INSERT app field: \(String(format: "%.1f", Date().timeIntervalSince(started))) s")

        // A web page's text box in Safari.
        let page = ProcessInfo.processInfo.environment["LONG_INSERT_PAGE"] ?? "http://localhost:8765/long-insert.html"
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.open(URL(string: page)!)
        XCTAssertTrue(safari.wait(for: .runningForeground, timeout: 20))
        let box = safari.webViews.textViews.firstMatch
        XCTAssertTrue(box.waitForExistence(timeout: 30), "No text box on \(page)")
        box.tap()
        XCTAssertTrue(safari.keyboards.firstMatch.waitForExistence(timeout: 20) || cutlingKeys(in: safari) != nil, "No keyboard in Safari")
        sleep(2)
        switchToCutlingKeyboard(in: safari, showing: "Snippet 1")
        let startedWeb = Date()
        tapCutling("Snippet 1", in: safari)
        sleep(6)
        shot("safari_box", safari)
        check((box.value as? String) ?? "", where: "Safari's text box")
        print("LONG_INSERT safari: \(String(format: "%.1f", Date().timeIntervalSince(startedWeb))) s")
    }
}
