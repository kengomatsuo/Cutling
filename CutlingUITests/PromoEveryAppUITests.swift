//
//  PromoEveryAppUITests.swift
//  CutlingUITests
//
//  The takes of the "Every app" App Store preview (docs/aso/previews-2.0/directions.md, G): the Cutling keyboard
//  in Apple's own Messages, Maps, Calendar and Safari, in the language EVERY_LANG names (en, id, ja).
//  scripts/every-app-takes.sh runs it on the store simulators: the whole flow once unfilmed to warm it, then
//  again while the simulator records, logging each press's time and place to EVERY_DIR/<device>-<lang>.presses.json.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import UIKit
import XCTest

@MainActor
final class PromoEveryAppUITests: XCTestCase {
    private let env = ProcessInfo.processInfo.environment
    private let cutling = XCUIApplication(bundleIdentifier: "com.matsuokengo.Cutling")
    private let messages = XCUIApplication(bundleIdentifier: "com.apple.MobileSMS")
    private let maps = XCUIApplication(bundleIdentifier: "com.apple.Maps")
    private let calendar = XCUIApplication(bundleIdentifier: "com.apple.mobilecal")
    private let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")

    private var language: String { env["EVERY_LANG"] ?? "en" }
    private var dir: String { env["EVERY_DIR"] ?? NSTemporaryDirectory() }
    private var device: String { UIDevice.current.userInterfaceIdiom == .pad ? "ipad" : "iphone" }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - What the takes type and tap, per language

    /// What the takes tap, per language: docs/aso/previews-2.0/g-words.json, seeded by SnapshotSeedData.swift
    /// (EveryAppSeedCopy) and by scripts/every-app-takes.sh (the contacts).
    private struct Words {
        let locale: String
        /// The first recent name on the keyboard's name screen.
        let name: String
        /// The new event's title in Calendar.
        let event: String
        /// The keys, by the cutlings' names.
        let home, order, account, studio, sizeChart, thanks: String
        let paste: [String]
        /// What finds contact 1 (the order reply) and contact 5 (the photo) in To:, as the job script saved them.
        let first, fifth: String
    }

    private var words: Words {
        switch language {
        case "id":
            Words(locale: "id_ID", name: "Rina", event: "Kelas keramik",
                  home: "Alamat rumah", order: "Jadwal kirim", account: "No. rekening", studio: "Studio keramik",
                  sizeChart: "Tabel ukuran", thanks: "Terima kasih", paste: ["Tempel", "Paste"], first: "Rina", fifth: "Fitri")
        case "ja":
            Words(locale: "ja_JP", name: "中村", event: "陶芸教室",
                  home: "自宅の住所", order: "発送連絡", account: "口座番号", studio: "教室の住所",
                  sizeChart: "サイズ表", thanks: "お礼", paste: ["ペースト", "Paste"], first: "中村", fifth: "原田")
        default:
            Words(locale: "en_US", name: "Maya", event: "Pottery class",
                  home: "Home address", order: "Order update", account: "Account number", studio: "Studio address",
                  sizeChart: "Size chart", thanks: "Thank you", paste: ["Paste"], first: "Maya", fifth: "Lea")
        }
    }

    // MARK: - Log

    private var filming = false
    private var log: [String] = []

    private func mark(_ label: String, at point: CGPoint? = nil) {
        let p = point ?? .zero
        let line = String(format: "{\"label\":\"%@\",\"t\":%.3f,\"x\":%.1f,\"y\":%.1f,\"filmed\":%@}",
                          label, Date().timeIntervalSince1970, p.x, p.y, filming ? "true" : "false")
        log.append(line)
        print("EVERY-MARK \(line)")
        try? ("[\n" + log.joined(separator: ",\n") + "\n]\n")
            .write(toFile: "\(dir)/\(device)-\(language).presses.json", atomically: true, encoding: .utf8)
    }

    private func shot(_ name: String, _ app: XCUIApplication? = nil) {
        let base = "\(dir)/\(device)-\(language)-\(filming ? "film" : "warm")-\(name)"
        try? XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: base + ".png"))
        if let app { try? app.debugDescription.write(toFile: base + ".tree.txt", atomically: true, encoding: .utf8) }
    }

    /// Asks the job script to start or stop the simulator's recording and waits for it.
    private func camera(_ on: Bool) {
        let name = on ? "film" : "cut"
        FileManager.default.createFile(atPath: "\(dir)/\(device)-\(language).\(name)", contents: Data())
        let answer = "\(dir)/\(device)-\(language).\(on ? "rolling" : "stopped")"
        let deadline = Date().addingTimeInterval(60)
        while !FileManager.default.fileExists(atPath: answer) && Date() < deadline { Thread.sleep(forTimeInterval: 0.1) }
        filming = on
    }

    // MARK: - Touches

    private func at(_ point: CGPoint, in app: XCUIApplication) -> XCUICoordinate { screenPoint(point.x, point.y, in: app) }

    /// A tap a viewer can follow: held down long enough to show the key's highlight, logged at its centre.
    private func press(_ label: String, _ point: CGPoint, in app: XCUIApplication, hold: TimeInterval = 0.12) {
        mark(label, at: point)
        at(point, in: app).press(forDuration: hold)
    }

    /// Key frames read in the warm pass, by press label: the filmed pass presses from these, so no accessibility query
    /// (seconds on a loaded Mac) sits between a press and the next.
    private var learned: [String: CGRect] = [:]

    /// Taps a Cutling key by its cutling's name, from the warm pass's frame when filming.
    private func tapKey(_ name: String, label: String, in app: XCUIApplication) {
        if filming, let known = learned[label] {
            press(label, CGPoint(x: known.midX, y: known.midY), in: app)
            return
        }
        var frame = keyFrame(name, in: app)
        for _ in 0..<10 where frame == nil {
            usleep(500_000)
            frame = keyFrame(name, in: app)
        }
        guard let frame else {
            shot("no-key-\(label)", app)
            XCTFail("No Cutling key \(name); keys: \(cutlingKeys(in: app)?.map(\.label) ?? [])")
            return
        }
        learned[label] = frame
        press(label, CGPoint(x: frame.midX, y: frame.midY), in: app)
    }

    /// A key by its cutling's name: the label is the name, then the text after the language's list separator (", " or
    /// "、"); the name screen's buttons are the name alone.
    private func keyFrame(_ name: String, in app: XCUIApplication) -> CGRect? {
        cutlingKeys(in: app)?.first { $0.label == name || $0.label.hasPrefix(name + ",") || $0.label.hasPrefix(name + "、") }?.frame
    }

    private func launch(_ app: XCUIApplication) {
        app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", words.locale]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 20))
        sleep(2)
    }

    /// Taps until a keyboard shows under the element.
    private func focus(_ element: XCUIElement, in app: XCUIApplication, _ name: String) {
        guard element.waitForExistence(timeout: 15) else {
            shot("no-\(name.replacingOccurrences(of: " ", with: "-"))", app)
            XCTFail("\(name) not found")
            return
        }
        for _ in 0..<3 {
            // A field that already holds the caret is left alone: a tap on the caret opens the edit menu (Paste,
            // AutoFill), which the first take filmed over Messages.
            if (element.value(forKey: "hasKeyboardFocus") as? Bool) == true, app.keyboards.firstMatch.exists || cutlingKeys(in: app) != nil { break }
            element.tap()
            if app.keyboards.firstMatch.waitForExistence(timeout: 4) || cutlingKeys(in: app) != nil { break }
        }
        sleep(1)
    }

    /// The keyboard the take starts with: Cutling, or the language's own; two keyboards in the list, so a globe tap flips.
    private func keyboard(cutling want: Bool, in app: XCUIApplication) {
        for _ in 0..<4 {
            let isCutling = cutlingKeyboardIsUp(in: app)
            if isCutling == want { return }
            if want { switchToCutlingKeyboard(in: app); continue }
            if let globe = cutlingKeys(in: app)?.first(where: { $0.label == "Next keyboard" || $0.label.lowercased().contains("globe") }) {
                at(CGPoint(x: globe.frame.midX, y: globe.frame.midY), in: app).tap()
            } else {
                keyboardGlobe(in: app).coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            }
            sleep(2)
        }
    }

    /// Dismisses a first-run sheet or alert an Apple app shows over its first screen, in one query each, since every
    /// query waits for the app's main thread and a busy app makes many queries cost minutes.
    private func clearWelcome(_ app: XCUIApplication) {
        let labels = ["Don’t Allow", "Don't Allow", "Jangan Izinkan", "許可しない", "Continue", "Not Now", "Allow While Using App", "Allow Once", "OK", "Done", "Lanjutkan", "Lain Kali", "Nanti Saja",
                      "Izinkan Saat Menggunakan App", "続ける", "今はしない", "後で", "Appの使用中は許可"]
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for _ in 0..<3 {
            let inApp = app.buttons.matching(NSPredicate(format: "label IN %@", labels)).firstMatch
            let alert = springboard.alerts.buttons.matching(NSPredicate(format: "label IN %@", labels)).firstMatch
            if inApp.exists && inApp.isHittable { inApp.tap(); sleep(1) } else if alert.exists { alert.tap(); sleep(1) } else { return }
        }
    }

    // MARK: - Seed

    private func seed() {
        cutling.launchArguments = ["-SNAPSHOT_MODE", "-PROMO_EVERY", "-PROMO_LANG", language, "-hasSeenInteractiveTutorial", "YES",
                                   "-AppleLanguages", "(\(language))", "-AppleLocale", words.locale]
        cutling.launch()
        let card = cutling.descendants(matching: .any).matching(identifier: "cutlingCard").firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 30), "Seeded cards did not appear")
        sleep(2)
        cutling.terminate()
    }

    // MARK: - Takes

    /// G1 and G4: Messages to Maya on the language's own keyboard, the globe held to Cutling, then the order update
    /// that asks for the name, Maya, and the thank-you.
    private func messagesToMaya() {
        launch(messages)
        newMessage(to: words.first)
        keyboard(cutling: false, in: messages)
        shot("g1-own-keyboard", messages)
        mark("g1 start")
        sleep(2)
        // Hold the globe until its list opens, slide up to Cutling (the row nearest the globe, about 133 pt above it on
        // the store iPhone) and let go there. A loaded Mac can open the list late: the finger waits on the row, and a
        // try that misses is made again, so the take holds one whole gesture that worked.
        // Each try is marked, so the cut shows the one that worked; a miss lets go at the next height (rows of the list
        // measured on the store iPhone at 133 pt above the globe; the iPad's list is a guess, so it is searched).
        let rises: [CGFloat] = device == "ipad" ? [90, 60, 125, 160, 45, 200] : [133, 100, 166, 66, 200]
        for attempt in 0..<rises.count where !cutlingKeyboardIsUp(in: messages) {
            let globe = keyboardGlobe(in: messages)
            XCTAssertTrue(globe.waitForExistence(timeout: 5), "No globe key")
            let start = globe.frame
            let target = CGPoint(x: start.midX + (device == "ipad" ? 80 : 20), y: start.midY - rises[attempt])
            mark("globe down", at: CGPoint(x: start.midX, y: start.midY))
            let from = globe.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            from.press(forDuration: 1.2, thenDragTo: from.withOffset(CGVector(dx: target.x - start.midX, dy: target.y - start.midY)),
                       withVelocity: .slow, thenHoldForDuration: 1.0 + Double(min(attempt, 2)) * 0.6)
            mark("globe up", at: target)
            sleep(2)
        }
        if !cutlingKeyboardIsUp(in: messages) {
            mark("globe missed")
            switchToCutlingKeyboard(in: messages)
        }
        mark("cutling up")
        sleep(2)
        tapKey(words.order, label: "order update", in: messages)
        Thread.sleep(forTimeInterval: 1.4)
        if !filming { shot("g4-asks", messages) }
        tapKey(words.name, label: "name", in: messages)
        Thread.sleep(forTimeInterval: 1.4)
        tapKey(words.thanks, label: "thank you", in: messages)
        sleep(3)
        shot("g4-done", messages)
        mark("g4 end")
        clearDraft()
    }

    /// The message field: Messages names it messageBodyField; its element type has changed across iOS versions.
    private func messageField() -> XCUIElement {
        let named = messages.descendants(matching: .any).matching(identifier: "messageBodyField").firstMatch
        if named.waitForExistence(timeout: 5) { return named }
        return messages.textViews.firstMatch.exists ? messages.textViews.firstMatch : messages.textFields.element(boundBy: messages.textFields.count > 1 ? 1 : 0)
    }

    /// Messages keeps a draft per conversation; the next pass must find the field empty.
    private func clearDraft() {
        let body = messageField()
        guard body.exists else { return }
        body.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 90))
        sleep(1)
    }

    /// Opens a new message to `name` through an sms: link to the number the job script saved for them, and puts the
    /// cursor in the message field.
    private func newMessage(to person: String) {
        messages.open(URL(string: "sms:")!)
        XCTAssertTrue(messages.wait(for: .runningForeground, timeout: 15))
        sleep(3)
        // The person is picked from Contacts with To:'s + button, as one is on a phone. (Typing the name finds nobody on
        // the store simulators: their contact search is off, and an sms: link to the number stays "No Name, Searching".)
        let add = messages.buttons["ComposeRecipientAddButton"].firstMatch
        if add.waitForExistence(timeout: 5) {
            add.tap()
            sleep(3)
            // The contact whose name is exactly `person` first (an older "Maya Brooks" sorts ahead of "Maya"), else
            // the one whose name starts with it (Rina Wulandari, 中村 由美).
            let texts = messages.descendants(matching: .any).matching(NSPredicate(format: "elementType == %d OR elementType == %d",
                XCUIElement.ElementType.cell.rawValue, XCUIElement.ElementType.staticText.rawValue))
            let exact = texts.matching(NSPredicate(format: "label == %@", person)).firstMatch
            let starts = texts.matching(NSPredicate(format: "label BEGINSWITH %@", person)).firstMatch
            if exact.waitForExistence(timeout: 8) { exact.tap() } else if starts.exists { starts.tap() } else {
                shot("no-contact-row", messages)
                let cancel = messages.buttons.matching(NSPredicate(format: "label IN %@", ["Cancel", "Batalkan", "Batal", "キャンセル"])).firstMatch
                if cancel.exists { cancel.tap() }
            }
            sleep(2)
        } else {
            shot("no-add-recipient", messages)
        }
        let body = messageField()
        focus(body, in: messages, "message field")
    }

    /// G2: Maps' search field, the home address typed by one tap.
    private func mapsSearch() {
        launch(maps)
        clearWelcome(maps)
        let search = maps.searchFields.firstMatch
        focus(search, in: maps, "Maps search field")
        keyboard(cutling: true, in: maps)
        shot("g2-ready", maps)
        mark("g2 start")
        sleep(2)
        tapKey(words.home, label: "home address", in: maps)
        sleep(4)
        shot("g2-done", maps)
        mark("g2 end")
    }

    /// G3: a new Calendar event, its location typed by one tap.
    private func calendarLocation() {
        launch(calendar)
        clearWelcome(calendar)
        // The iPad's Calendar names its + button "add" (identifier add-plus-button); the iPhone's says Add.
        let add = [calendar.buttons["add-plus-button"], calendar.buttons["Add"], calendar.buttons["add"], calendar.buttons["Tambah"], calendar.buttons["追加"]].map(\.firstMatch).first { $0.waitForExistence(timeout: 3) }
        guard let add else { shot("no-add", calendar); XCTFail("No Add button in Calendar"); return }
        add.tap()
        sleep(3)
        // New Event opens with its title focused; the title goes in through the edit menu's Paste, since the runner
        // shares the simulator's pasteboard and no hardware typing has to pass the language's input method.
        let title = calendar.descendants(matching: .any).matching(NSPredicate(format: "hasKeyboardFocus == true")).firstMatch
        if title.waitForExistence(timeout: 5) {
            UIPasteboard.general.string = words.event
            title.press(forDuration: 1.0)
            let paste = words.paste.lazy.map { self.calendar.menuItems[$0].firstMatch }.first { $0.waitForExistence(timeout: 3) }
            if let paste { paste.tap() } else { shot("no-title-paste", calendar) }
            sleep(1)
        } else {
            shot("no-title-focus", calendar)
        }
        if !filming { shot("g3-title", calendar) }
        // iOS 27's Location row is a button (its icon's identifier is "location") that opens a search for the place.
        let location = calendar.images["location"].firstMatch
        if location.waitForExistence(timeout: 5) { location.tap() } else { shot("no-location", calendar) }
        sleep(3)
        // The place search opens with its field unfocused and no keyboard: the field is tapped, as a person would.
        let place = calendar.searchFields.firstMatch.exists ? calendar.searchFields.firstMatch : calendar.textFields.firstMatch
        focus(place, in: calendar, "location search field")
        if !filming { shot("g3-location", calendar) }
        keyboard(cutling: true, in: calendar)
        shot("g3-ready", calendar)
        mark("g3 start")
        sleep(2)
        tapKey(words.studio, label: "studio address", in: calendar)
        sleep(4)
        shot("g3-done", calendar)
        mark("g3 end")
    }

    /// G5: a refund form on a local page in Safari, the account number typed by one tap.
    private func safariRefund() {
        // The page opens through the system, as a link would: XCUIApplication.launch() fails the whole take when a
        // loaded simulator's Safari is slow to load accessibility (2026-11-23), and the job already set the language.
        let page = URL(string: "http://localhost:\(env["EVERY_PORT"] ?? "8767")/refund.html?lang=\(language)")!
        for _ in 0..<3 {
            XCUIDevice.shared.system.open(page)
            if safari.wait(for: .runningForeground, timeout: 30) { break }
        }
        sleep(4)
        clearWelcome(safari)
        // The page's last text field: on the iPad, webViews.textFields did not reach the page's fields (2026-11-23), so
        // the address bar (TabBarItemTitleContainer) is left out by identifier instead.
        let pageFields = safari.textFields.matching(NSPredicate(format: "identifier != %@", "TabBarItemTitleContainer"))
        let field = pageFields.element(boundBy: max(0, pageFields.count - 1))
        focus(field, in: safari, "account number field")
        keyboard(cutling: true, in: safari)
        shot("g5-ready", safari)
        mark("g5 start")
        sleep(2)
        tapKey(words.account, label: "account number", in: safari)
        sleep(4)
        shot("g5-done", safari)
        mark("g5 end")
    }

    /// G6: Messages to Lea, the size chart copied by a tap and pasted as a photo.
    private func messagesPhoto() {
        launch(messages)
        newMessage(to: words.fifth)
        keyboard(cutling: true, in: messages)
        shot("g6-ready", messages)
        mark("g6 start")
        sleep(2)
        tapKey(words.sizeChart, label: "size chart", in: messages)
        sleep(2)
        let body = messageField()
        let f = body.frame
        mark("hold field", at: CGPoint(x: f.minX + 60, y: f.midY))
        at(CGPoint(x: f.minX + 60, y: f.midY), in: messages).press(forDuration: 0.8)
        Thread.sleep(forTimeInterval: 0.9)
        if filming, let known = learned["paste"] {
            press("paste", CGPoint(x: known.midX, y: known.midY), in: messages)
        } else if let paste = words.paste.lazy.map({ self.messages.menuItems[$0].firstMatch }).first(where: { $0.waitForExistence(timeout: 2) })
            ?? words.paste.lazy.map({ self.messages.buttons[$0].firstMatch }).first(where: { $0.exists }) {
            let p = paste.frame
            learned["paste"] = p
            press("paste", CGPoint(x: p.midX, y: p.midY), in: messages)
        } else {
            shot("no-paste", messages)
            XCTFail("No Paste in the edit menu")
        }
        sleep(4)
        shot("g6-done", messages)
        mark("g6 end")
        clearDraft()
    }

    /// Leaves each app without a draft or an event: Messages' and Calendar's sheets are cancelled.
    private func cleanUp() {
        for app in [messages, calendar, maps, safari] { app.terminate() }
    }

    private func runAll() {
        // Messages on the store iPad never reports its event loop idle, so every query in it times out (2026-11-23);
        // the iPad film is Maps, Calendar and Safari, the keyboard switched on in Maps.
        if device == "ipad" {
            mapsSearch()
            calendarLocation()
            safariRefund()
            cleanUp()
            return
        }
        messagesToMaya()
        mapsSearch()
        calendarLocation()
        safariRefund()
        messagesPhoto()
        cleanUp()
    }

    /// Every take in one language: seeded, warmed unfilmed, then filmed.
    func testEveryApp() {
        seed()
        runAll()
        seed()
        camera(true)
        mark("film start")
        runAll()
        mark("film end")
        camera(false)
    }

    /// One unfilmed pass with a screenshot and tree at each step, to read the Apple apps' elements.
    func testProbe() {
        seed()
        continueAfterFailure = true
        runAll()
    }
}
