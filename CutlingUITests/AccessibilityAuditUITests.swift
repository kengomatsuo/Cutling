//
//  AccessibilityAuditUITests.swift
//  CutlingUITests
//
//  Apple's accessibility audit (XCUIApplication.performAccessibilityAudit) on every Cutling 2.0 screen: the
//  grid, the editor form, the Text page with its bar, the Variables list, a blank's editor and the app's
//  fill-in sheet, at the default text size and at the largest accessibility size. A failure names the
//  element and the issue (missing label, clipped text, contrast, hit region, Dynamic Type).
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

@MainActor
final class AccessibilityAuditUITests: XCTestCase {
    override func setUp() async throws {
        continueAfterFailure = true
        // Each audit walks six screens; at the largest text size on Xcode Cloud that took past the 10-minute default.
        executionTimeAllowance = 1500
    }

    private func any(_ app: XCUIApplication, _ id: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: id).firstMatch
    }

    private func audit(_ app: XCUIApplication, _ screen: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = "audit_\(screen)"
        shot.lifetime = .keepAlways
        add(shot)
        do {
            try app.performAccessibilityAudit { issue in
                print("AUDIT \(screen): \(issue.auditType) — \(issue.compactDescription) — \(issue.element?.debugDescription.prefix(160) ?? "no element")")
                return false
            }
        } catch {
            XCTFail("Audit of \(screen) failed: \(error)")
        }
    }

    private func walk(textSize: String?) throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST", "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES"]
        if let textSize { app.launchArguments += ["-UIPreferredContentSizeCategoryName", textSize] }
        app.launch()
        let card = any(app, "cutlingCard")
        XCTAssertTrue(card.waitForExistence(timeout: 30), "No cards")
        sleep(1)
        audit(app, "grid")

        // The fill-in sheet the app shows before copying a cutling with blanks.
        let copy = app.buttons["Copy"].firstMatch
        for _ in 0..<3 where !copy.exists {
            card.press(forDuration: 1.6)
            _ = copy.waitForExistence(timeout: 8)
        }
        if copy.exists {
            copy.tap()
            if app.textFields["fillInField"].firstMatch.waitForExistence(timeout: 8) {
                sleep(1)
                audit(app, "fill_in_sheet")
                app.buttons["Cancel"].firstMatch.tap()
                sleep(1)
            }
        }

        // The editor form, then its text as the full page.
        let edit = app.buttons.matching(NSPredicate(format: "identifier == 'editButton' OR label == 'Edit'")).firstMatch
        for _ in 0..<3 where !edit.exists {
            card.press(forDuration: 1.6)
            _ = edit.waitForExistence(timeout: 8)
        }
        XCTAssertTrue(edit.exists, "The card's menu has no Edit")
        edit.tap()
        let row = any(app, "textPageRow")
        // At the largest text sizes the text box sits below the form's first screen, and a list makes no row it hasn't
        // shown yet: the form is scrolled until it appears.
        if !row.waitForExistence(timeout: 10) {
            for _ in 0..<6 where !row.exists {
                app.swipeUp()
                _ = row.waitForExistence(timeout: 2)
            }
        }
        XCTAssertTrue(row.exists, "No text box in the editor")
        let closeTip = app.buttons["Close"].firstMatch
        if closeTip.waitForExistence(timeout: 2) { closeTip.tap(); sleep(1) }
        sleep(1)
        audit(app, "editor_form")
        row.tap()
        XCTAssertTrue(any(app, "textPage").waitForExistence(timeout: 10), "No Text page")
        sleep(2)
        audit(app, "text_page")

        // The Variables list and a blank's editor.
        let variables = app.buttons["Variables"].firstMatch
        if variables.waitForExistence(timeout: 5) {
            variables.tap()
            if any(app, "fillInPicker").waitForExistence(timeout: 5) {
                sleep(1)
                audit(app, "variables_list")
                any(app, "fillInKind-blank").tap()
                if app.buttons["fillInEditorDone"].waitForExistence(timeout: 5) {
                    sleep(1)
                    audit(app, "blank_editor")
                }
            }
        }
    }

    func testAuditDefaultTextSize() throws { try walk(textSize: nil) }

    func testAuditLargestTextSize() throws { try walk(textSize: "UICTContentSizeCategoryAccessibilityXXXL") }
}
