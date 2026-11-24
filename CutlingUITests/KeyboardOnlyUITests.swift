//
//  KeyboardOnlyUITests.swift
//  CutlingUITests
//
//  Walks Cutling 2.0's variables with a keyboard and no touch (ASG88), and records every step that
//  needed one. testHardwareKeyboardOnIPad: the editor, the Text page, Ask Each Time, a date, Save and the
//  fill-in sheet with only key events (run with the simulator's hardware keyboard connected, no software
//  keyboard; scripts/keyboard-only.sh). testFullKeyboardAccess: Tab, arrows, Space and Return through the editor,
//  the Variables list, the Ask Each Time and date editors and the fill-in sheet, with Full Keyboard Access on.
//  Each stop is a screenshot in $FORMAT_TEST_SHOTS and a line in keyboard-only.log there.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class KeyboardOnlyUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    private var shotDir: URL? {
        ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"].map { URL(fileURLWithPath: $0) }
    }

    private func shot(_ name: String) {
        let data = XCUIScreen.main.screenshot().pngRepresentation
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.png")
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let dir = shotDir { try? data.write(to: dir.appendingPathComponent("\(name).png")) }
    }

    private func note(_ line: String) {
        print("KO| \(line)")
        guard let dir = shotDir else { return }
        let file = dir.appendingPathComponent("keyboard-only.log")
        let data = Data((line + "\n").utf8)
        if let handle = try? FileHandle(forWritingTo: file) {
            handle.seekToEndOfFile(); handle.write(data); try? handle.close()
        } else {
            try? data.write(to: file)
        }
    }

    private func any(_ app: XCUIApplication, _ id: String) -> XCUIElement {
        app.descendants(matching: .any)[id].firstMatch
    }

    @MainActor
    private func key(_ app: XCUIApplication, _ key: XCUIKeyboardKey, _ flags: XCUIElement.KeyModifierFlags = [], wait: UInt32 = 1) {
        // Keys go through SpringBoard's proxy: the app's own never reads idle while a focus effect or the grid animates,
        // and each key then waits a minute for it.
        XCUIApplication(bundleIdentifier: "com.apple.springboard").typeKey(key, modifierFlags: flags)
        if wait > 0 { sleep(wait) }
    }

    /// What holds keyboard focus now, as "type|identifier|label", or "none".
    @MainActor
    private func focused(_ app: XCUIApplication) -> String {
        let hit = app.descendants(matching: .any).matching(NSPredicate(format: "hasFocus == 1")).allElementsBoundByIndex
        let named = hit.filter { $0.elementType != .application && $0.elementType != .window }
        let pick = named.last
        guard let e = pick else { return "none" }
        return "\(e.elementType.rawValue)|\(e.identifier)|\(e.label)|\(e.frame.integral)"
    }

    /// Presses Tab (or Shift-Tab) `count` times, shooting each stop and noting the focus. Stops early when the
    /// focus returns to the first stop.
    @MainActor
    private func tabWalk(_ app: XCUIApplication, _ screen: String, count: Int, reverse: Bool = false) -> [String] {
        var seen: [String] = []
        for i in 1...count {
            key(app, .tab, reverse ? .shift : [], wait: 1)
            let f = focused(app)
            note("\(screen) tab \(i): \(f)")
            shot("\(screen)_tab\(String(format: "%02d", i))")
            if let first = seen.first, f == first { note("\(screen): focus came round to the first stop after \(i) tabs"); break }
            seen.append(f)
        }
        return seen
    }

    /// Opens the Cutling's editor from the card's menu (a touch: the card menu is a long press).
    @MainActor
    private func openEditorByTouch(_ app: XCUIApplication) {
        let card = any(app, "cutlingCard")
        XCTAssertTrue(card.waitForExistence(timeout: 30), "No cards")
        let edit = app.buttons.matching(NSPredicate(format: "identifier == 'editButton' OR label == 'Edit'")).firstMatch
        for _ in 0..<3 where !edit.exists {
            card.press(forDuration: 1.6)
            _ = edit.waitForExistence(timeout: 8)
        }
        edit.tap()
        XCTAssertTrue(any(app, "textPageRow").waitForExistence(timeout: 10), "No editor")
        let closeTip = app.buttons["Close"].firstMatch
        if closeTip.waitForExistence(timeout: 2) { closeTip.tap(); sleep(1) }
    }

    /// Turns Full Keyboard Access on in Settings > Accessibility > Keyboards, as a person does (the defaults key alone did not).
    @MainActor
    private func enableFullKeyboardAccess() {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.launch()
        for label in ["Accessibility", "Keyboards", "Full Keyboard Access"] {
            let cell = settings.cells.staticTexts[label].firstMatch
            if !cell.waitForExistence(timeout: 6) { settings.swipeUp() }
            if cell.waitForExistence(timeout: 4) { cell.tap() } else { note("FKA setup: no '\(label)' row"); shot("fka_setup_missing_\(label)") }
            sleep(1)
        }
        let toggle = settings.switches.firstMatch
        if toggle.waitForExistence(timeout: 5) {
            note("FKA setup: switch value before: \(toggle.value as? String ?? "?")")
            if toggle.value as? String == "0" { toggle.tap(); sleep(2) }
            note("FKA setup: switch value after: \(toggle.value as? String ?? "?")")
        }
        shot("fka_setup_settings")
        settings.terminate()
    }

    private func launch(_ extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-FILLIN_TEST", "-hasCompletedSetup", "YES",
                                "-hasSeenInteractiveTutorial", "YES", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"] + extra
        XCUIDevice.shared.appearance = .light
        app.launch()
        return app
    }

    // MARK: Walk 1

    /// Create, type, Ask Each Time, a date, Save, copy and fill in: each by key first, a touch only where no key did it.
    @MainActor
    func testHardwareKeyboardOnIPad() throws {
        let app = launch()
        XCTAssertTrue(any(app, "cutlingCard").waitForExistence(timeout: 30), "No cards")
        note("software keyboard shown at start: \(app.keyboards.count > 0)")
        shot("w1_01_grid")

        // 1. Create a cutling. Keys first: Command-N, then Tab/Space/Return.
        let name = app.textFields.matching(NSPredicate(format: "label != 'Search cutlings' AND placeholderValue != 'Search cutlings'")).firstMatch
        key(app, XCUIKeyboardKey(rawValue: "n"), .command, wait: 2)
        var opened = name.exists
        note("w1 create: Command-N opened the editor: \(opened)")
        if !opened {
            for _ in 0..<12 where !opened {
                key(app, .tab)
                let f = focused(app)
                note("w1 create, tab: \(f)")
                if f.contains("Add cutling") {
                    key(app, .space, wait: 2)
                    opened = name.exists
                    note("w1 create: Tab reached '+' and Space opened the editor: \(opened)")
                    break
                }
            }
        }
        if !opened {
            note("w1 create: TOUCH needed to tap + (no key reached it)")
            app.buttons["Add cutling"].firstMatch.tap()
            sleep(1)
            shot("w1_01b_add_menu")
            // The menu: Down and Return first.
            key(app, .downArrow, wait: 1); key(app, .return, wait: 2)
            if !name.exists {
                note("w1 create: the + menu did not take Down+Return; TOUCH on Text Cutling")
                app.buttons["Text Cutling"].firstMatch.tap()
            } else { note("w1 create: the + menu took Down+Return (menu opened by touch on +)") }
            _ = name.waitForExistence(timeout: 10)
        }
        sleep(1)
        shot("w1_02_new_cutling_editor")
        note("w1 editor: software keyboard shown: \(app.keyboards.count > 0); name field focus: \(focused(app))")

        // 2. A name, typed. The field already has the cursor on a new cutling, or does not.
        name.typeText("Order reply")
        sleep(1)
        shot("w1_03_name_typed")
        note("w1 name typed: value=\(name.value as? String ?? "?")")

        // 3. The Text page: Tab to the text box row, Return or Space on it.
        let page = any(app, "textPage")
        var onPage = false
        for i in 1...12 where !onPage {
            key(app, .tab)
            let f = focused(app)
            note("w1 to text row, tab \(i): \(f)")
            if f.contains("textPageRow") || f.lowercased().contains("variables & formatting") {
                key(app, .return, wait: 2)
                onPage = page.waitForExistence(timeout: 4)
                note("w1 text page: Return on the focused row opened it: \(onPage)")
                break
            }
        }
        if !onPage {
            note("w1 text page: TOUCH needed to tap the Text row (no key reached it)")
            any(app, "textPageRow").tap()
            XCTAssertTrue(page.waitForExistence(timeout: 10), "No Text page")
        }
        let tip = app.buttons["Continue"].firstMatch
        if tip.waitForExistence(timeout: 3) { tip.tap(); sleep(1); note("w1: a one-time tip asked a TOUCH (Continue)") }
        sleep(1)
        shot("w1_04_text_page")
        note("w1 text page: software keyboard shown: \(app.keyboards.count > 0); focus: \(focused(app))")

        // 4. Type the text.
        let text = app.textViews.firstMatch
        text.typeText("Hi ")
        sleep(1)

        // 5. Ask Each Time and Today's Date: the tools are buttons; a key first (Tab from the text), else a touch.
        func pressTool(_ label: String, shotName: String) -> Bool {
            // Tab from the text view to the tool, if focus can leave the text.
            for i in 1...10 {
                key(app, .tab, wait: 1)
                let f = focused(app)
                if f.contains(label) { note("w1 tool \(label): Tab \(i) focused it; pressing Space"); key(app, .space, wait: 2); return true }
            }
            return false
        }
        let blankButton = app.buttons["Ask Each Time"].firstMatch
        if !pressTool("Ask Each Time", shotName: "") {
            note("w1 Ask Each Time: TOUCH needed (Tab never reached the tool; Space/Return on text only types)")
            if !blankButton.exists { note("w1: no Ask Each Time button found at all") }
            blankButton.tap()
        }
        sleep(2)
        shot("w1_05_ask_each_time_editor")
        let nameField = any(app, "fillInName")
        note("w1 ask-each-time editor: name field exists \(nameField.exists); focus: \(focused(app))")
        // The editor's name: typed with the keys if the field has the cursor, else a touch to focus it.
        if nameField.exists {
            if nameField.value as? String == "Name" || (nameField.value as? String)?.isEmpty == false {
                key(app, XCUIKeyboardKey(rawValue: "a"), .command, wait: 0)
            }
            nameField.typeText("Customer")
            note("w1 ask-each-time name: typed by keys (the field is typeable); value=\(nameField.value as? String ?? "?")")
        }
        shot("w1_06_ask_each_time_named")
        // Done in the sheet: Return? Else the checkmark.
        key(app, .return, wait: 1)
        if any(app, "fillInEditorDone").exists {
            note("w1 ask-each-time Done: Return did not close it; Tab to the checkmark")
            var closed = false
            for i in 1...8 where !closed {
                key(app, .tab)
                let f = focused(app)
                if f.contains("Done") { key(app, .space, wait: 2); closed = !any(app, "fillInEditorDone").exists; note("w1 Done via Tab \(i) + Space: closed=\(closed)"); break }
            }
            if !closed {
                note("w1 ask-each-time Done: TOUCH needed on the checkmark")
                any(app, "fillInEditorDone").tap()
                sleep(2)
            }
        }
        shot("w1_07_blank_inserted")

        // The date: the Today's Date tool.
        text.typeText(" on ")
        let dateButton = app.buttons["Today’s Date"].firstMatch
        if !pressTool("Today", shotName: "") {
            note("w1 Today's Date: TOUCH needed (Tab never reached the tool)")
            dateButton.tap()
        }
        sleep(2)
        shot("w1_08_date_inserted")

        // 6. Save: the page's check/back, then the editor's Save.
        note("w1 before save: focus \(focused(app)), text=\(text.value as? String ?? "?")")
        key(app, XCUIKeyboardKey(rawValue: "s"), .command, wait: 2)
        note("w1 save: Command-S: editor name field still there: \(name.exists)")
        if !(any(app, "textPage").exists) == false {
            // Still on the page: leave it by Escape, then Command-Return as a person might.
            key(app, .escape, wait: 2)
            note("w1 page after Escape: \(any(app, "textPage").exists)")
        }
        shot("w1_09_after_save_try")

        // The rest by touch if keys did not finish it: back, Save.
        if any(app, "textPage").exists {
            note("w1 leave the Text page: TOUCH needed on the back button")
            app.navigationBars.buttons.firstMatch.tap(); sleep(2)
        }
        shot("w1_10_editor_back")
        let save = app.buttons.matching(NSPredicate(format: "label == 'Save' OR label == 'Done' OR identifier == 'saveButton'")).firstMatch
        if save.exists {
            note("w1 save: the editor's \(save.label) needs a TOUCH (Command-S did nothing)")
            save.tap(); sleep(3)
        }
        shot("w1_11_after_save")

        // 7. Use it from the app's Copy flow: the card, then the fill-in sheet by keys.
        let filled = app.staticTexts["Order reply"].firstMatch
        note("w1 the new cutling is on the grid: \(filled.waitForExistence(timeout: 10))")
        note("w1 copy: TOUCH needed to tap the card (no key reaches a card, or Tab/Space did?)")
        var viaKey = false
        for i in 1...25 where !viaKey {
            key(app, .tab, wait: 0)
            let f = focused(app)
            if f.contains("Order reply") { note("w1 copy: Tab \(i) focused the card: \(f)"); key(app, .space, wait: 2); viaKey = any(app, "fillInField").exists; break }
        }
        note("w1 copy: Tab+Space on the card opened the fill-in sheet: \(viaKey)")
        if !viaKey { filled.tap(); sleep(2) }
        let field = any(app, "fillInField")
        XCTAssertTrue(field.waitForExistence(timeout: 10), "No fill-in sheet")
        shot("w1_12_fill_in_sheet")
        note("w1 fill-in: software keyboard shown: \(app.keyboards.count > 0); focus: \(focused(app))")
        field.typeText("Sarah")
        sleep(1)
        shot("w1_13_fill_in_typed")
        key(app, .return, wait: 2)
        note("w1 fill-in: Return finished and closed the sheet: \(!field.exists)")
        shot("w1_14_after_copy")
    }

    // MARK: Walk 2

    /// Tab through every screen with Full Keyboard Access on, a shot at each stop.
    @MainActor
    func testFullKeyboardAccess() throws {
        enableFullKeyboardAccess()
        let app = launch()
        XCTAssertTrue(any(app, "cutlingCard").waitForExistence(timeout: 30), "No cards")
        key(app, .tab)
        note("w2 grid: first Tab focus: \(focused(app))")
        shot("w2_00_grid_tab1")

        // The editor, reached by a touch (the card menu); everything inside by keys.
        note("w2: the editor is opened by a TOUCH (long press on a card); Full Keyboard Access has no key for a card's menu here")
        openEditorByTouch(app)
        shot("w2_01_editor")
        _ = tabWalk(app, "w2_02_editor", count: 14)

        // The Text row by Space, then the page's Variables.
        key(app, .tab, .shift)
        var onPage = false
        for i in 1...14 where !onPage {
            key(app, .tab)
            if focused(app).contains("textPageRow") || focused(app).contains("Variables & Formatting") {
                key(app, .space, wait: 2)
                onPage = any(app, "textPage").waitForExistence(timeout: 4)
                note("w2 Text row: Space opened the Text page after \(i) tabs: \(onPage)")
                break
            }
        }
        if !onPage { note("w2 Text row: not reached by Tab; opened by TOUCH"); any(app, "textPageRow").tap() }
        let tip = app.buttons["Continue"].firstMatch
        if tip.waitForExistence(timeout: 3) { tip.tap(); sleep(1) }
        sleep(1)
        shot("w2_03_text_page")
        _ = tabWalk(app, "w2_04_text_page", count: 16)

        // Variables list: press the Variables tool by touch-free means if reachable, else by touch.
        let variables = app.buttons.matching(NSPredicate(format: "identifier == 'editorBar.curlybraces' OR label == 'Variables'")).allElementsBoundByIndex.first { $0.isHittable }
        // Tab until Variables holds focus.
        var viaKey = false
        for i in 1...30 where !viaKey {
            key(app, .tab, wait: 0)
            if focused(app).contains("Variables") {
                key(app, .space, wait: 2)
                viaKey = any(app, "fillInPicker").waitForExistence(timeout: 4)
                note("w2 Variables tool: Tab \(i) + Space opened the list: \(viaKey)")
                break
            }
        }
        if !viaKey { note("w2 Variables tool: TOUCH needed"); variables?.tap() }
        XCTAssertTrue(any(app, "fillInPicker").waitForExistence(timeout: 5), "No Variables list")
        sleep(1)
        shot("w2_05_variables_list")
        _ = tabWalk(app, "w2_06_variables", count: 12)
        // Arrows in the list.
        key(app, .downArrow); note("w2 variables down arrow: \(focused(app))"); shot("w2_07_variables_down")
        key(app, .downArrow); note("w2 variables down arrow 2: \(focused(app))"); shot("w2_07_variables_down2")
        key(app, .upArrow); note("w2 variables up arrow: \(focused(app))")

        // Open the date kind by keys: focus its row and Space.
        let dateRow = any(app, "fillInKind-date")
        var onDate = false
        for i in 1...40 where !onDate {
            if focused(app).contains("Date") || focused(app).contains("fillInKind-date") { key(app, .space, wait: 2); onDate = any(app, "fillInEditorDone").waitForExistence(timeout: 4); note("w2 date row opened by keys: \(onDate)"); break }
            key(app, .tab, wait: 0)
            _ = i
        }
        if !onDate { note("w2 date row: TOUCH needed"); dateRow.tap(); sleep(2) }
        sleep(1)
        shot("w2_08_date_editor")
        _ = tabWalk(app, "w2_09_date_editor", count: 14)
        // Back out of the pushed editor and the list by Escape / the back button's key.
        key(app, .escape, wait: 2)
        note("w2 date editor: Escape left it: picker visible \(any(app, "fillInPicker").exists), editor done visible \(any(app, "fillInEditorDone").exists)")
        shot("w2_10_after_escape")
    }

    /// The Ask Each Time editor and the fill-in sheet, on the iPhone, with Full Keyboard Access on.
    @MainActor
    func testFullKeyboardAccessBlankAndFillIn() throws {
        let app = launch()
        XCTAssertTrue(any(app, "cutlingCard").waitForExistence(timeout: 30), "No cards")
        openEditorByTouch(app)
        any(app, "textPageRow").tap()
        XCTAssertTrue(any(app, "textPage").waitForExistence(timeout: 10), "No Text page")
        let tip = app.buttons["Continue"].firstMatch
        if tip.waitForExistence(timeout: 3) { tip.tap(); sleep(1) }
        sleep(1)
        // Ask Each Time by Tab + Space.
        var viaKey = false
        for i in 1...30 where !viaKey {
            key(app, .tab, wait: 0)
            if focused(app).contains("Ask Each Time") {
                key(app, .space, wait: 2)
                viaKey = any(app, "fillInName").waitForExistence(timeout: 4)
                note("w2 Ask Each Time tool: Tab \(i) + Space opened its editor: \(viaKey)")
                break
            }
        }
        if !viaKey {
            note("w2 Ask Each Time tool: TOUCH needed")
            app.buttons["Ask Each Time"].firstMatch.tap()
        }
        XCTAssertTrue(any(app, "fillInName").waitForExistence(timeout: 5), "No Ask Each Time editor")
        sleep(1)
        shot("w2_20_ask_each_time_editor")
        _ = tabWalk(app, "w2_21_ask_each_time", count: 12)
        key(app, .escape, wait: 2)
        note("w2 ask each time: Escape closed it: \(!any(app, "fillInName").exists)")
        shot("w2_22_ask_each_time_escape")
    }

    @MainActor
    func testFullKeyboardAccessFillInSheet() throws {
        let app = launch()
        let card = any(app, "cutlingCard")
        XCTAssertTrue(card.waitForExistence(timeout: 30), "No cards")
        // The fill-in sheet by touch (card menu > Copy), as the fill-in tests do.
        card.press(forDuration: 1.2)
        let copy = app.buttons["Copy"].firstMatch
        XCTAssertTrue(copy.waitForExistence(timeout: 5), "No Copy in the card's menu")
        copy.tap()
        let field = any(app, "fillInField")
        XCTAssertTrue(field.waitForExistence(timeout: 10), "No fill-in sheet")
        sleep(1)
        shot("w2_30_fill_in_open")
        note("w2 fill-in opens with focus: \(focused(app))")
        _ = tabWalk(app, "w2_31_fill_in", count: 12)
        // Shift-Tab back round.
        _ = tabWalk(app, "w2_32_fill_in_back", count: 3, reverse: true)
    }
}
