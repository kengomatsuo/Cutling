//
//  PromoReleaseUITests.swift
//  CutlingUITests
//
//  The takes of the 2.0 release film (undirect docs/plans/app-store-growth/social/cutling-2-release-posts-brief.md),
//  all inside Cutling: a cutling written like a note on the Text page, the Cutling keyboard typing a date that fills
//  itself in, a reply that asks for the name and a formatted cutling on the setup guide's Try It page, and the grid
//  holding 5,000. scripts/release-film-takes.sh runs it on the device queue; ui-test.sh films the whole run, and each
//  step prints `MARK <wall clock> <what>` to find it in run.mp4. RELEASE_LANG=ja films the Japanese cut: the app, the
//  seed (ReleaseSeedCopy in SnapshotSeedData.swift) and the labels the test finds are Japanese.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class PromoReleaseUITests: XCTestCase {

    private var language: String { ProcessInfo.processInfo.environment["RELEASE_LANG"] ?? "en" }

    /// What the takes tap and type, per language. The typed lines are the Welcome note's own words
    /// (ReleaseSeedCopy), so the note written on camera is the key that types it later.
    private struct Words {
        let add, textCutling, tipContinue, close, bold, highlight, bulleted, variables: String
        let delivery, order, welcome, name: String
        let title, intro, item1, code, items, sent, afterDate: String
    }

    private var words: Words {
        switch language {
        case "ja":
            Words(add: "Cutlingを追加", textCutling: "テキストカットリング", tipContinue: "次へ", close: "閉じる", bold: "ボールド",
                  highlight: "ハイライト", bulleted: "箇条書き", variables: "変数",
                  delivery: "発送完了", order: "発送連絡", welcome: "初回のご案内", name: "中村",
                  title: "陶芸教室へようこそ！", intro: "\nお越しの際は、以下をご確認ください。\n", item1: "入口の暗証番号は ", code: "4815",
                  items: "\nWi-Fi は tougei-guest\n駐車場は隣のパン屋さんの裏", sent: "※", afterDate: "時点の情報です。")
        default:
            Words(add: "Add cutling", textCutling: "Text Cutling", tipContinue: "Continue", close: "Close", bold: "Bold",
                  highlight: "Highlight", bulleted: "Bulleted", variables: "Variables",
                  delivery: "Delivery note", order: "Order update", welcome: "Welcome note", name: "Maya",
                  title: "Welcome to the studio!", intro: "\nEverything for your first visit:\n", item1: "Door code ", code: "4815",
                  items: "\nWi-Fi: studio-guest\nParking behind the bakery", sent: "Sent ", afterDate: "")
        }
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func any(_ app: XCUIApplication, _ id: String) -> XCUIElement {
        app.descendants(matching: .any)[id].firstMatch
    }

    private func shot(_ name: String) {
        let data = XCUIScreen.main.screenshot().pngRepresentation
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.png")
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let dir = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"] {
            try? data.write(to: URL(fileURLWithPath: dir).appendingPathComponent("release_\(name).png"))
        }
    }

    private func mark(_ what: String) {
        print("MARK \(Date().timeIntervalSince1970) \(what)")
    }

    @MainActor
    private func launch(_ extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-PROMO_RELEASE", "-hasSeenInteractiveTutorial", "YES"] + extra
        // RELEASE_TODAY=yyyy-MM-dd: the day the film's post goes out, which a date stamp types (FillInClock).
        if let today = ProcessInfo.processInfo.environment["RELEASE_TODAY"], !today.isEmpty { app.launchArguments += ["-PROMO_TODAY", today] }
        if language != "en" {
            app.launchArguments += ["-PROMO_LANG", language, "-AppleLanguages", "(\(language))", "-AppleLocale", "ja_JP"]
        }
        XCUIDevice.shared.appearance = .light
        app.launch()
        return app
    }

    /// The system's own keyboard on the Text page, not the Cutling keyboard a run may have left up.
    @MainActor
    private func useSystemKeyboard(_ app: XCUIApplication) {
        for _ in 0..<3 where app.keys.count == 0 {
            let globe = keyboardGlobe(in: app)
            guard globe.waitForExistence(timeout: 5) else { return }
            globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            sleep(2)
        }
    }

    /// Types as a person does, a few letters at a time, so the film shows the words arriving.
    @MainActor
    private func type(_ text: String, in app: XCUIApplication) {
        var chunk = ""
        for character in text {
            chunk.append(character)
            if chunk.count == 3 || character == "\n" { app.typeText(chunk); chunk = "" }
        }
        if !chunk.isEmpty { app.typeText(chunk) }
    }

    /// A new cutling written like a note: a bold title, a list, a highlight, and today's date from Variables.
    @MainActor
    func test1Note() throws {
        let app = launch(["-hasCompletedSetup", "YES"])
        XCTAssertTrue(any(app, "cutlingCard").waitForExistence(timeout: 30), "No cards")
        sleep(2)
        shot("grid")
        let add = app.buttons[words.add].firstMatch
        XCTAssertTrue(add.waitForExistence(timeout: 10), "No + button")
        add.tap()
        let text = app.buttons[words.textCutling].firstMatch
        XCTAssertTrue(text.waitForExistence(timeout: 5), "The + menu has no Text Cutling")
        text.tap()
        let row = any(app, "textPageRow")
        XCTAssertTrue(row.waitForExistence(timeout: 10), "No text box on the form")
        sleep(1)
        mark("note open page")
        row.tap()
        if !any(app, "textPage").waitForExistence(timeout: 5) {
            let navBar = app.navigationBars.firstMatch.frame
            let closeTip = app.buttons.matching(NSPredicate(format: "label == %@", words.close)).allElementsBoundByIndex
                .first { !navBar.intersects($0.frame) && $0.isHittable }
            closeTip?.tap()
            sleep(1)
            row.tap()
        }
        XCTAssertTrue(any(app, "textPage").waitForExistence(timeout: 10), "The Text page did not open")
        let tip = app.buttons[words.tipContinue].firstMatch
        if tip.waitForExistence(timeout: 3) { tip.tap(); sleep(1) }
        let bar = any(app, "fillInKeyboardBar")
        XCTAssertTrue(bar.waitForExistence(timeout: 10), "No bar above the keyboard on the page")
        useSystemKeyboard(app)
        sleep(2)
        shot("note_0_empty")

        // The styles sit further along the bar, as in Notes.
        bar.swipeLeft()
        let bold = app.buttons[words.bold].firstMatch
        XCTAssertTrue(bold.waitForExistence(timeout: 5), "No Bold on the bar")
        sleep(1)
        mark("note bold on")
        bold.tap()
        usleep(600_000)
        mark("note title")
        type(words.title, in: app)
        usleep(800_000)
        mark("note bold off")
        bold.tap()
        usleep(400_000)
        mark("note line")
        type(words.intro, in: app)
        sleep(1)
        shot("note_1_title")

        // The list button ends the bar; highlight stays in view beside it.
        bar.swipeLeft()
        let list = any(app, "editorBarMenu.list.bullet")
        XCTAssertTrue(list.waitForExistence(timeout: 5), "No list button at the end of the bar")
        sleep(1)
        mark("note list menu")
        list.tap()
        let bulleted = app.buttons[words.bulleted].firstMatch
        XCTAssertTrue(bulleted.waitForExistence(timeout: 5), "The list button opened no menu")
        sleep(1)
        shot("note_2_list_menu")
        mark("note bulleted")
        bulleted.tap()
        usleep(800_000)
        mark("note item 1")
        type(words.item1, in: app)
        let highlight = app.buttons[words.highlight].firstMatch
        XCTAssertTrue(highlight.waitForExistence(timeout: 5), "No Highlight on the bar")
        mark("note highlight on")
        highlight.tap()
        usleep(500_000)
        type(words.code, in: app)
        usleep(600_000)
        mark("note highlight off")
        highlight.tap()
        usleep(400_000)
        mark("note items")
        type(words.items, in: app)
        sleep(2)
        shot("note_3_written")
        mark("note written")

        // Return on an empty item ends the list; then today's date from Variables, which fills itself in when used.
        type("\n\n" + words.sent, in: app)
        for _ in 0..<3 { bar.swipeRight() }
        let variables = app.buttons[words.variables].firstMatch
        XCTAssertTrue(variables.waitForExistence(timeout: 5), "No Variables on the bar")
        sleep(1)
        mark("note variables")
        variables.tap()
        XCTAssertTrue(any(app, "fillInPicker").waitForExistence(timeout: 5), "No picker")
        sleep(2)
        shot("note_4_variables")
        mark("note pick date")
        any(app, "fillInKind-date").tap()
        sleep(2)
        // The date goes in first and the words after it follow, as a Japanese line reads.
        type(words.afterDate, in: app)
        shot("note_5_date_pill")
        mark("note end")
        sleep(1)
        app.terminate()
    }

    /// The Cutling keyboard on the setup guide's Try It page: a date that fills itself in, a reply that asks for the
    /// name, and a formatted cutling typed by a tap.
    @MainActor
    func test2Keyboard() throws {
        var app = launch()
        app.terminate()
        // Settings' labels are English; the Japanese run starts with the keyboard added by the job script.
        if language == "en" { addCutlingKeyboardInSettings() }
        app = launch()
        var field = openKeyboardTestField(in: app)

        // The first time Cutling's keyboard reports Full Access, the setup guide closes the keyboard; open the field once more.
        continueAfterFailure = true
        switchToCutlingKeyboard(in: app, showing: words.delivery)
        continueAfterFailure = false
        if !cutlingKeyboardIsUp(in: app, showing: words.delivery) {
            app.terminate()
            app = launch()
            field = openKeyboardTestField(in: app)
            switchToCutlingKeyboard(in: app, showing: words.delivery)
        }
        XCTAssertTrue(cutlingKeyboardIsUp(in: app, showing: words.delivery),
                      "Cutling keyboard did not come up (buttons: \(cutlingKeys(in: app)?.map(\.label) ?? []))")

        // Frames read once, so no accessibility query sits between a press and the next on camera.
        func frame(_ name: String) -> CGRect {
            var found: CGRect?
            for _ in 0..<10 {
                found = cutlingKeyFrame(name, in: app)
                if found != nil { break }
                usleep(500_000)
            }
            XCTAssertNotNil(found, "No \(name) on the Cutling keyboard (buttons: \(cutlingKeys(in: app)?.map(\.label) ?? []))")
            return found ?? .zero
        }
        func press(_ label: String, _ rect: CGRect) {
            mark("\(label) at \(Int(rect.midX)),\(Int(rect.midY))")
            screenPoint(rect.midX, rect.midY, in: app).press(forDuration: 0.12)
        }
        func clear() {
            let length = ((field.value as? String) ?? "").count
            if length > 0 { field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: length + 4)) }
            sleep(1)
        }
        let delivery = frame(words.delivery), order = frame(words.order), welcome = frame(words.welcome)
        sleep(2)
        shot("keyboard_0_ready")

        mark("date start")
        sleep(1)
        press("delivery note", delivery)
        sleep(3)
        shot("keyboard_1_date")
        mark("date end")
        clear()

        // The reply asks for the name; the names used before are one tap away.
        mark("ask start")
        sleep(1)
        press("order update", order)
        sleep(2)
        let maya = frame(words.name)
        shot("keyboard_2_asks")
        sleep(1)
        press("name", maya)
        sleep(3)
        shot("keyboard_3_asked")
        mark("ask end")
        clear()

        // A formatted cutling types like the rest.
        mark("formatted start")
        sleep(1)
        press("welcome note", welcome)
        sleep(3)
        shot("keyboard_4_formatted")
        mark("formatted end")
        clear()
        app.terminate()
    }

    /// Messages, the film's first beat: the Cutling keyboard in a new message, the order reply that asks for the name, and
    /// the name's one tap. The recipient is not picked (the beat shows the message field and the keyboard only), and the
    /// keys are the release seed's, so every beat shows one set.
    @MainActor
    func test4Messages() throws {
        let seed = launch(["-hasCompletedSetup", "YES"] + (language == "ja" ? ["-PROMO_NO_RECENT"] : []))
        XCTAssertTrue(any(seed, "cutlingCard").waitForExistence(timeout: 30), "No cards")
        sleep(2)
        seed.terminate()
        let messages = XCUIApplication(bundleIdentifier: "com.apple.MobileSMS")
        messages.launch()
        XCTAssertTrue(messages.wait(for: .runningForeground, timeout: 20))
        sleep(2)
        messages.open(URL(string: "sms:")!)
        XCTAssertTrue(messages.wait(for: .runningForeground, timeout: 15))
        sleep(3)
        let body = messages.descendants(matching: .any).matching(identifier: "messageBodyField").firstMatch
        XCTAssertTrue(body.waitForExistence(timeout: 15), "No message field")
        // The To: field starts with the caret, and its keyboard has no globe: the message field is tapped until it holds it.
        for _ in 0..<3 where (body.value(forKey: "hasKeyboardFocus") as? Bool) != true {
            body.tap()
            _ = messages.keyboards.firstMatch.waitForExistence(timeout: 4)
        }
        sleep(1)
        mark("messages own keyboard")
        continueAfterFailure = true
        switchToCutlingKeyboard(in: messages, showing: words.order)
        continueAfterFailure = false
        XCTAssertTrue(cutlingKeyboardIsUp(in: messages, showing: words.order), "Cutling keyboard did not come up in Messages")
        func frame(_ name: String) -> CGRect {
            var found: CGRect?
            for _ in 0..<10 {
                found = cutlingKeyFrame(name, in: messages)
                if found != nil { break }
                usleep(500_000)
            }
            XCTAssertNotNil(found, "No \(name) on the Cutling keyboard")
            return found ?? .zero
        }
        func press(_ label: String, _ rect: CGRect) {
            mark("\(label) at \(Int(rect.midX)),\(Int(rect.midY))")
            screenPoint(rect.midX, rect.midY, in: messages).press(forDuration: 0.12)
        }
        let order = frame(words.order)
        sleep(2)
        shot("messages_0_ready")
        mark("ask start")
        sleep(1)
        press("order update", order)
        sleep(2)
        shot("messages_1_asks")
        sleep(1)
        if language == "ja" {
            // The first time: the fill-in asks, the name is typed on the kana keyboard (なかむら flicked and converted),
            // the globe goes back to Cutling, which reads the name before the cursor, and the check mark types the reply.
            let own = cutlingKeys(in: messages)?.first { $0.label.contains("キーボード") && $0.label != "次のキーボード" }?.frame ?? frame("いつものキーボードで入力")
            press("type with your keyboard", own)
            XCTAssertTrue(messages.keys["な"].waitForExistence(timeout: 10), "The kana keyboard did not come up")
            sleep(2)
            func tapKey(_ label: String) {
                mark("kana \(label)")
                messages.keys[label].tap()
                usleep(450_000)
            }
            tapKey("な"); tapKey("か")
            mark("kana む flick")
            let ma = messages.keys["ま"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            ma.press(forDuration: 0.1, thenDragTo: ma.withOffset(CGVector(dx: 0, dy: -50)), withVelocity: .default, thenHoldForDuration: 0.2)
            usleep(450_000)
            tapKey("ら")
            sleep(1)
            shot("messages_1b_typed")
            mark("kana convert")
            messages.keys["空白"].tap()
            usleep(900_000)
            mark("kana commit")
            messages.keys["確定"].tap()
            sleep(1)
            shot("messages_1c_converted")
            mark("globe back")
            keyboardGlobe(in: messages).coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            XCTAssertTrue(cutlingKeyboardIsUp(in: messages), "Cutling did not come back")
            sleep(1)
            shot("messages_1d_back")
            // The return key: the right end of the lowest row of Cutling's buttons (delete, space, return).
            let keys = cutlingKeys(in: messages) ?? []
            let lowest = keys.map { Int($0.frame.midY) }.max() ?? 0
            let row = keys.filter { abs(Int($0.frame.midY) - lowest) < 8 }
            let done = row.max(by: { $0.frame.midX < $1.frame.midX })?.frame ?? .zero
            press("insert", done.midX > messages.frame.width * 0.75 ? done : CGRect(x: messages.frame.width * 0.88, y: CGFloat(lowest), width: 0, height: 0))
        } else {
            let name = frame(words.name)
            press("name", name)
        }
        sleep(3)
        shot("messages_2_asked")
        mark("ask end")
        body.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 90))
        sleep(1)
    }

    /// The grid's own count with 5,000 texts saved, then a few flicks through them.
    @MainActor
    func test3Room() throws {
        let app = launch(["-hasCompletedSetup", "YES", "-PROMO_ROOM", "5000"])
        XCTAssertTrue(any(app, "cutlingCard").waitForExistence(timeout: 90), "No cards")
        sleep(4)
        shot("room_0_grid")
        mark("room start")
        sleep(2)
        for index in 0..<5 {
            mark("room flick \(index)")
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.78))
                .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.18)), withVelocity: 5000, thenHoldForDuration: 0)
            usleep(700_000)
        }
        sleep(2)
        shot("room_1_scrolled")
        mark("room end")
        app.terminate()
        // The next run starts from six keys again.
        let reset = launch(["-hasCompletedSetup", "YES"])
        _ = any(reset, "cutlingCard").waitForExistence(timeout: 30)
        reset.terminate()
    }
}
