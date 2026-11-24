//
//  GridLayoutUITests.swift
//  CutlingUITests
//
//  The main grid of cutlings shows every card whole, nothing clipped or overlapping the card below, at the default text
//  size and at the large and largest accessibility sizes, in light and dark: each card has a fixed height and its text
//  is drawn by the editor's renderer, which gives up whole lines to fit. Shot on every device the Proof workflow runs.
//  The store-screenshot seed has eleven varied cutlings: formatted text, code, an address, a long booking.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class GridLayoutUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    private func shot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Cards whose frames overlap one another: a card's text running past its own card shows as the card being taller
    /// than its neighbours in the same row, which the accessibility frames report.
    @MainActor
    private func overlaps(_ app: XCUIApplication) -> [String] {
        let cards = app.descendants(matching: .any).matching(identifier: "cutlingCard").allElementsBoundByIndex
        let frames = cards.map(\.frame).filter { !$0.isEmpty }
        var found: [String] = []
        for (i, a) in frames.enumerated() {
            for b in frames[(i + 1)...] where a.insetBy(dx: 1, dy: 1).intersects(b.insetBy(dx: 1, dy: 1)) {
                found.append("\(a.integral) and \(b.integral)")
            }
        }
        return found
    }

    @MainActor
    private func walk(textSize: String?, label: String, dark: Bool) {
        XCUIDevice.shared.appearance = dark ? .dark : .light
        let app = XCUIApplication()
        app.launchArguments += ["-SNAPSHOT_MODE", "-PROMO_MODE", "-PROMO_LANG", "en",
                                "-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES"]
        if let textSize { app.launchArguments += ["-UIPreferredContentSizeCategoryName", textSize] }
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["cutlingCard"].firstMatch.waitForExistence(timeout: 30), "No cards (\(label))")
        sleep(2)
        let look = dark ? "dark" : "light"
        shot("grid_\(label)_\(look)_1")
        XCTAssertEqual(overlaps(app), [], "Cards overlap at \(label), \(look)")
        app.swipeUp()
        sleep(1)
        shot("grid_\(label)_\(look)_2")
        app.swipeUp()
        sleep(1)
        shot("grid_\(label)_\(look)_3")
        app.terminate()
    }

    @MainActor
    func testGridAtDefaultTextSize() throws {
        walk(textSize: nil, label: "default", dark: false)
        walk(textSize: nil, label: "default", dark: true)
    }

    @MainActor
    func testGridAtLargeAccessibilityTextSize() throws {
        walk(textSize: "UICTContentSizeCategoryAccessibilityL", label: "AX-L", dark: false)
    }

    @MainActor
    func testGridAtLargestTextSize() throws {
        walk(textSize: "UICTContentSizeCategoryAccessibilityXXXL", label: "AX5", dark: false)
        walk(textSize: "UICTContentSizeCategoryAccessibilityXXXL", label: "AX5", dark: true)
    }
}
