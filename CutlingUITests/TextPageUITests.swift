//
//  TextPageUITests.swift
//  CutlingUITests
//
//  Opens a cutling's text as its own page from the form, then walks it as a person would: the keyboard's bar,
//  the Aa Format panel and back, underline, highlight and a list from the bar's list menu, the Variables picker,
//  a new blank, a pill's editor, and Done putting the
//  keyboard down. Light and dark; one screenshot of each state in $FORMAT_TEST_SHOTS as textpage_<what>_<light|dark>.png.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class TextPageUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDown() {
        XCUIDevice.shared.appearance = .light
    }

    private func shot(_ name: String, dark: Bool) {
        let data = XCUIScreen.main.screenshot().pngRepresentation
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.png")
        attachment.name = "\(name)_\(dark ? "dark" : "light")"
        attachment.lifetime = .keepAlways
        add(attachment)
        if let dir = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"] {
            try? data.write(to: URL(fileURLWithPath: dir).appendingPathComponent("textpage_\(name)_\(dark ? "dark" : "light").png"))
        }
    }

    private func any(_ app: XCUIApplication, _ id: String) -> XCUIElement {
        app.descendants(matching: .any)[id].firstMatch
    }

    /// How many "Name" pills the page's text holds, read as VoiceOver reads it: a pill is its label, or the attachment character.
    @MainActor
    private func pills(_ app: XCUIApplication) -> Int {
        let text = (app.textViews.firstMatch.value as? String) ?? ""
        return text.components(separatedBy: "Name").count - 1 + text.filter { $0 == "\u{FFFC}" }.count
    }

    @MainActor
    private func flow(dark: Bool) throws {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST", "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES"]
        // The device's own appearance; a launch argument does not turn an app dark.
        XCUIDevice.shared.appearance = dark ? .dark : .light
        app.launch()
        let card = any(app, "cutlingCard")
        XCTAssertTrue(card.waitForExistence(timeout: 30), "No cards")
        // The card's menu, not a tap: on iPad a tap copies the cutling and asks for its fill-ins.
        let edit = app.buttons.matching(NSPredicate(format: "identifier == 'editButton' OR label == 'Edit'")).firstMatch
        for _ in 0..<3 where !edit.exists {
            card.press(forDuration: 1.6)
            _ = edit.waitForExistence(timeout: 8)
        }
        XCTAssertTrue(edit.exists, "The card's menu has no Edit")
        edit.tap()

        // The form: its text box shows the text and opens it as a page.
        let row = any(app, "textPageRow")
        XCTAssertTrue(row.waitForExistence(timeout: 10), "The form's text box is not the way into the page")
        let closeTip = app.buttons["Close"].firstMatch
        if closeTip.waitForExistence(timeout: 2) { closeTip.tap(); sleep(1) }
        shot("1_form", dark: dark)
        row.tap()

        // The page: text filling the screen, the bar above the keyboard.
        XCTAssertTrue(any(app, "textPage").waitForExistence(timeout: 10), "The Text page did not open")
        // iOS's one-time "slide to type" tip can cover the keyboard; Continue clears it.
        let tip = app.buttons["Continue"].firstMatch
        if tip.waitForExistence(timeout: 3) { tip.tap(); sleep(1) }
        // iPhone: the bar above the keyboard. iPad: the tools in the top bar, as in Notes on iPad.
        let bar = any(app, "fillInKeyboardBar")
        let wide = any(app, "textPageTools").waitForExistence(timeout: 3)
        if !wide { XCTAssertTrue(bar.waitForExistence(timeout: 10), "No bar above the keyboard on the page") }
        sleep(1)
        shot("2_keyboard_up", dark: dark)

        // Aa opens the Format panel: in the keyboard's place on iPhone, the bar leaving with the keyboard; a popover on iPad.
        // iPad's keyboard has a Format button of its own; the page's is the one in its tools.
        (wide ? any(app, "textPageTools").buttons["Format"].firstMatch : app.buttons["Format"].firstMatch).tap()
        let panel = any(app, "formatPanel")
        XCTAssertTrue(panel.waitForExistence(timeout: 10), "No Format panel")
        sleep(1)
        shot("3_format", dark: dark)
        if wide {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.45)).tap()
        } else {
            XCTAssertFalse(bar.exists, "The bar still stands above the Format panel")
            // Its close button hands the keyboard and the bar back.
            app.buttons["formatPanelClose"].firstMatch.tap()
            XCTAssertTrue(bar.waitForExistence(timeout: 10), "Closing the Format panel did not bring the bar back")
        }
        sleep(1)

        // Further along the same bar, as in Notes: the styles. One that is on is filled; the link asks in a sheet.
        if !wide {
            bar.swipeLeft()
            let bold = app.buttons["Bold"].firstMatch
            XCTAssertTrue(bold.waitForExistence(timeout: 5), "No Bold on the bar after the variables")
            bold.tap()
            sleep(1)
            XCTAssertTrue(bold.isSelected, "Bold does not show as on after a tap")
            shot("4_bar_styles", dark: dark)
            bold.tap()
            // Underline and highlight sit after Bold and Italic, as in Notes; each fills while it is on.
            for name in ["Underline", "Highlight"] {
                let button = app.buttons[name].firstMatch
                XCTAssertTrue(button.waitForExistence(timeout: 5), "No \(name) on the bar")
                button.tap()
                sleep(1)
                XCTAssertTrue(button.isSelected, "\(name) does not show as on after a tap")
            }
            app.typeText(" marked")
            sleep(1)
            shot("4_bar_underline_highlight", dark: dark)
            app.buttons["Underline"].firstMatch.tap()
            app.buttons["Highlight"].firstMatch.tap()
            // The list button ends the bar; its menu grows above it with Bulleted, Dashed and Numbered.
            bar.swipeLeft()
            let list = any(app, "editorBarMenu.list.bullet")
            XCTAssertTrue(list.waitForExistence(timeout: 5), "No list button at the end of the bar")
            list.tap()
            let bulleted = app.buttons["Bulleted"].firstMatch
            XCTAssertTrue(bulleted.waitForExistence(timeout: 5), "The list button opened no menu")
            XCTAssertTrue(app.buttons["Numbered"].firstMatch.exists && app.buttons["Dashed"].firstMatch.exists, "The list menu lacks Dashed or Numbered")
            sleep(1)
            shot("4_list_menu", dark: dark)
            bulleted.tap()
            sleep(1)
            app.typeText("\nMilk\nEggs")
            sleep(1)
            let listed = (app.textViews.firstMatch.value as? String) ?? ""
            XCTAssertTrue(listed.contains("• Milk\n• Eggs"), "Return did not carry the bulleted list on: \(listed.suffix(60))")
            XCTAssertTrue(list.isSelected, "The list button does not show as on inside a list")
            shot("4_list_typed", dark: dark)
            // Return on an empty item ends the list, as in Notes.
            app.typeText("\n\n")
            sleep(1)
            let ended = (app.textViews.firstMatch.value as? String) ?? ""
            XCTAssertFalse(ended.hasSuffix("• "), "Return on an empty item left the list running")
            bar.swipeRight()
            bar.swipeRight()
            app.buttons["Add Link"].firstMatch.tap()
            XCTAssertTrue(any(app, "linkAddress").waitForExistence(timeout: 5), "The link button opened no Add Link sheet")
            sleep(1)
            shot("4_link_sheet", dark: dark)
            app.buttons["linkCancel"].firstMatch.tap()
            XCTAssertTrue(bar.waitForExistence(timeout: 10), "Closing Add Link did not bring the bar back")
            bar.swipeRight()
            sleep(1)
        }

        // The variables button opens the whole picker at once.
        let pillsBefore = pills(app)
        app.buttons["Variables"].firstMatch.tap()
        XCTAssertTrue(any(app, "fillInPicker").waitForExistence(timeout: 5), "No picker")
        sleep(1)
        shot("5_picker", dark: dark)
        // Blank in the picker pushes its editor; Done types the new pill at the cursor.
        any(app, "fillInKind-blank").tap()
        XCTAssertTrue(any(app, "fillInName").waitForExistence(timeout: 5), "Blank in the picker did not open its editor")
        sleep(1)
        shot("6_new_blank", dark: dark)
        app.buttons["fillInEditorDone"].tap()
        sleep(2)
        // One pill for one Done.
        XCTAssertEqual(pills(app), pillsBefore + 1, "Done typed the new blank more or fewer times than once")
        shot("7_after_insert", dark: dark)

        // The first pill, "Name", opens its editor.
        let text = app.textViews.firstMatch
        text.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: 60, dy: 12)).tap()
        XCTAssertTrue(any(app, "fillInName").waitForExistence(timeout: 5), "Tapping a blank's pill did not open its editor")
        sleep(1)
        shot("8_pill_editor", dark: dark)
        app.buttons["fillInEditorDone"].tap()
        sleep(1)

        // The date pill, a line below.
        text.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: 70, dy: 46)).tap()
        if any(app, "fillInEditorDone").waitForExistence(timeout: 5) {
            sleep(1)
            shot("9_date_editor", dark: dark)
            app.buttons["fillInEditorDone"].tap()
            sleep(1)
        }

        // iPad has no Done check and no second bar, as Notes on iPad has neither.
        if wide {
            // Its list menu sits in the top bar beside Aa.
            let list = any(app, "textPageTools").descendants(matching: .any)["editorBarMenu.list.bullet"].firstMatch
            XCTAssertTrue(list.waitForExistence(timeout: 5), "No list button in iPad's top bar")
            list.tap()
            XCTAssertTrue(app.buttons["Numbered"].firstMatch.waitForExistence(timeout: 5), "iPad's list button opened no menu")
            sleep(1)
            shot("9_list_menu", dark: dark)
            app.buttons["Numbered"].firstMatch.tap()
            sleep(1)
            app.typeText("\nSecond")
            sleep(1)
            let numbered = (app.textViews.firstMatch.value as? String) ?? ""
            XCTAssertTrue(numbered.contains("2. Second"), "Return did not number the next item: \(numbered.suffix(60))")
            shot("10_after_edits", dark: dark)
            app.terminate()
            return
        }
        // Done puts the keyboard down: the check and the bar leave, and the short bar stands at the bottom.
        if !bar.exists {
            text.tap()
            XCTAssertTrue(bar.waitForExistence(timeout: 10), "A tap in the text did not bring the keyboard")
        }
        let done = app.buttons["textPageDone"].firstMatch
        XCTAssertTrue(done.waitForExistence(timeout: 5), "No Done check with the keyboard up")
        done.tap()
        sleep(2)
        XCTAssertFalse(bar.exists, "The keyboard's bar stayed after Done")
        XCTAssertFalse(done.exists, "The Done check stayed with the keyboard down")
        XCTAssertTrue(app.buttons["Variables"].firstMatch.waitForExistence(timeout: 5), "No bar at the bottom with the keyboard down")
        shot("10_keyboard_down", dark: dark)
        app.terminate()
    }

    @MainActor
    func testTextPageLight() throws { try flow(dark: false) }

    @MainActor
    func testTextPageDark() throws { try flow(dark: true) }
}
