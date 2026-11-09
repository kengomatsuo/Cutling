//
//  PromoFilmUITests.swift
//  CutlingUITests
//
//  Drives the takes of the keyboard explainer and the store previews, one story
//  per test, in the language PROMO_LANG names. takes-app/job.sh films each take
//  with simctl: a test warms the flow up off camera, then asks for the camera
//  through files in PROMO_DIR, and logs every press with its time and place.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import UIKit
import XCTest

@MainActor
final class PromoFilmUITests: XCTestCase {
    private let env = ProcessInfo.processInfo.environment
    private let cutling = XCUIApplication(bundleIdentifier: "com.matsuokengo.Cutling")
    private let prop = XCUIApplication(bundleIdentifier: "com.matsuokengo.promo.chat")
    private let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
    private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    private var language: String { env["PROMO_LANG"] ?? "en" }
    private var dir: String { env["PROMO_DIR"] ?? "/tmp" }
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var takePrefix: String { isPad ? "ipad" : "iphone" }

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    // MARK: - Labels per language

    private struct Labels {
        let general, keyboard, keyboards, allow: String
        let textCutling, addCutling, pasteFromClipboard, paste: String
        let cutlingKeyboardRow: String
        let openSettings: String
        /// What the save take types as the new cutling's name, key by key.
        let bankNameKeys: [String]
        /// The candidate that finishes `bankNameKeys`, for a keyboard that converts.
        let bankNameCandidate: String?
        /// What the find take types: the start of the address cutling's name.
        let findKeys: [String]
        let findCandidate: String?
    }

    private var labels: Labels {
        switch language {
        case "id":
            Labels(general: "Umum", keyboard: "Papan Ketik", keyboards: "Papan Ketik", allow: "Izinkan",
                   textCutling: "Cutling teks", addCutling: "Tambah cutling", pasteFromClipboard: "Tempel dari Papan Klip", paste: "Tempel",
                   cutlingKeyboardRow: "Cutling", openSettings: "Buka Pengaturan Cutling",
                   bankNameKeys: ["R", "e", "k", "e", "n", "i", "n", "g", "space", "B", "C", "A"], bankNameCandidate: nil,
                   findKeys: ["a", "l", "a", "m", "a", "t"], findCandidate: nil)
        case "ja":
            Labels(general: "一般", keyboard: "キーボード", keyboards: "キーボード", allow: "許可",
                   textCutling: "テキストカットリング", addCutling: "Cutlingを追加", pasteFromClipboard: "クリップボードから貼り付け", paste: "ペースト",
                   cutlingKeyboardRow: "Cutling", openSettings: "カットリング設定を開く",
                   bankNameKeys: ["f", "u", "r", "i", "k", "o", "m", "i", "s", "a", "k", "i"], bankNameCandidate: "振込先",
                   findKeys: ["j", "u", "u", "s", "h", "o"], findCandidate: "住所")
        default:
            Labels(general: "General", keyboard: "Keyboard", keyboards: "Keyboards", allow: "Allow",
                   textCutling: "Text Cutling", addCutling: "Add cutling", pasteFromClipboard: "Paste from Clipboard", paste: "Paste",
                   cutlingKeyboardRow: "Cutling", openSettings: "Open Cutling Settings",
                   bankNameKeys: ["B", "a", "n", "k", "space", "A", "c", "c", "o", "u", "n", "t"], bankNameCandidate: nil,
                   findKeys: ["h", "o", "m", "e"], findCandidate: nil)
        }
    }

    // MARK: - Camera

    private var takeName = ""
    private var pressLog: [String] = []
    private let formatter = ISO8601DateFormatter()

    /// Asks the host script to start filming and waits until frames are being written.
    private func beginTake(_ name: String, skipSettleGate: Bool = false) {
        takeName = "\(takePrefix)-\(name)"
        pressLog = []
        addTeardownBlock { [self] in
            if !takeName.isEmpty { endTake(hold: 0) }
        }
        FileManager.default.createFile(atPath: "\(dir)/\(takeName).request", contents: skipSettleGate ? Data("skip".utf8) : Data())
        let started = waitForFile("\(dir)/\(takeName).recording", timeout: 240)
        XCTAssertTrue(started, "The camera did not start for \(takeName)")
        Thread.sleep(forTimeInterval: 0.5)
    }

    /// Ends the take after `hold` seconds and writes the press log beside it.
    private func endTake(hold: TimeInterval = 2.5) {
        Thread.sleep(forTimeInterval: hold)
        let json = "[\n" + pressLog.joined(separator: ",\n") + "\n]\n"
        try? json.write(toFile: "\(dir)/\(takeName).presses.json", atomically: true, encoding: .utf8)
        FileManager.default.createFile(atPath: "\(dir)/\(takeName).stop", contents: Data())
        _ = waitForFile("\(dir)/\(takeName).stopped", timeout: 30)
        takeName = ""
    }

    private func waitForFile(_ path: String, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if FileManager.default.fileExists(atPath: path) { return true }
            Thread.sleep(forTimeInterval: 0.1)
        }
        return false
    }

    /// Waits until the host says the machine is quiet, without filming.
    private func waitForQuietMachine(_ name: String) {
        let marker = "\(dir)/\(name).settled"
        try? FileManager.default.removeItem(atPath: marker)
        FileManager.default.createFile(atPath: "\(dir)/\(name).settle-request", contents: Data())
        _ = waitForFile(marker, timeout: 240)
    }

    private func pressRecord(_ label: String, x: CGFloat, y: CGFloat, start: Date, end: Date) {
        guard !takeName.isEmpty else { return }
        let line = String(format: "{\"label\":\"%@\",\"x\":%.4f,\"y\":%.4f,\"t0\":%.3f,\"t1\":%.3f}",
                          label, x, y, start.timeIntervalSince1970, end.timeIntervalSince1970)
        pressLog.append(line)
    }

    // MARK: - Holding the globe

    private struct SwitcherRows: Decodable { let cutling, system: [CGFloat] }

    /// Where the rows of the held globe's keyboard list sit, as fractions of the screen.
    /// They live in a file beside the job so a measured change needs no rebuild.
    private func switcherRows() -> SwitcherRows {
        let device = isPad ? "ipad" : "iphone"
        if let path = env["PROMO_SWITCHER"], let data = FileManager.default.contents(atPath: path),
           let table = try? JSONDecoder().decode([String: [String: SwitcherRows]].self, from: data),
           let rows = table[device]?[language] ?? table[device]?["default"] { return rows }
        return isPad ? SwitcherRows(cutling: [0.12, 0.84], system: [0.12, 0.81]) : SwitcherRows(cutling: [0.30, 0.86], system: [0.30, 0.82])
    }

    /// The list opens about a second after the touch on a busy machine; the finger waits for it, as a person's does.
    private let holdBeforeDrag: TimeInterval = 1.2
    private let dragSpeed: CGFloat = 360

    /// Touches the globe, holds until the list opens, drags to a row and releases.
    private func holdGlobe(to row: [CGFloat], label: String = "globe hold", in app: XCUIApplication, rest: TimeInterval = 1.2) {
        let start = globePoint(in: app)
        let target = CGPoint(x: row[0], y: row[1])
        Thread.sleep(forTimeInterval: rest)
        let begin = Date()
        coordinate(start.x, start.y, in: app).press(
            forDuration: holdBeforeDrag,
            thenDragTo: coordinate(target.x, target.y, in: app),
            withVelocity: XCUIGestureVelocity(rawValue: dragSpeed),
            thenHoldForDuration: 0.28
        )
        guard !takeName.isEmpty else { return }
        let holdEnd = begin.timeIntervalSince1970 + holdBeforeDrag
        let distance = hypot((target.x - start.x) * screen.width, (target.y - start.y) * screen.height)
        let dragTime = Double(distance / dragSpeed)
        let path = (0...4).map { step -> String in
            let fraction = CGFloat(step) / 4
            return String(format: "{\"t\":%.3f,\"x\":%.4f,\"y\":%.4f}", holdEnd + dragTime * Double(fraction),
                          start.x + (target.x - start.x) * fraction, start.y + (target.y - start.y) * fraction)
        }.joined(separator: ",")
        pressLog.append(String(format: "{\"label\":\"%@\",\"x\":%.4f,\"y\":%.4f,\"t0\":%.3f,\"t1\":%.3f,\"holdEnd\":%.3f,\"path\":[%@]}",
                               label, start.x, start.y, begin.timeIntervalSince1970, Date().timeIntervalSince1970, holdEnd, path))
    }

    // MARK: - Touches

    /// The display in points, read once: every query costs seconds on a loaded machine.
    private lazy var screen: CGSize = XCUIApplication(bundleIdentifier: "com.apple.springboard").frame.size

    private func coordinate(_ x: CGFloat, _ y: CGFloat, in app: XCUIApplication) -> XCUICoordinate {
        app.coordinate(withNormalizedOffset: CGVector(dx: x, dy: y))
    }

    /// A press a viewer can follow: rests before the press and holds down long enough to show its highlight.
    private func press(_ label: String, x: CGFloat, y: CGFloat, in app: XCUIApplication, rest: TimeInterval = 0.5, hold: TimeInterval = 0.12) {
        Thread.sleep(forTimeInterval: rest)
        let start = Date()
        coordinate(x, y, in: app).press(forDuration: hold)
        pressRecord(label, x: x, y: y, start: start, end: Date())
    }

    /// Frames read in a warm pass, by press label: the filmed pass presses from these, so no query lands in a take's motion.
    private var learnedFrames: [String: CGRect] = [:]

    /// The element's frame, from the warm pass when this press has been made before.
    private func frame(_ label: String, of element: @autoclosure () -> XCUIElement) -> CGRect {
        if !takeName.isEmpty, let known = learnedFrames[label] { return known }
        let read = element().frame
        if takeName.isEmpty { learnedFrames[label] = read }
        return read
    }

    /// Presses an element at its centre, logging its normalized place.
    private func press(_ label: String, element: @autoclosure () -> XCUIElement, in app: XCUIApplication, rest: TimeInterval = 0.5, hold: TimeInterval = 0.12) {
        let area = frame(label, of: element())
        press(label, x: area.midX / screen.width, y: area.midY / screen.height, in: app, rest: rest, hold: hold)
    }

    private struct PlannedKey { let label: String; let x, y: CGFloat }
    /// The keys a warm pass found, by what it typed: the filmed pass presses from this list, so no query lands between two keys.
    private var typingPlans: [String: [PlannedKey]] = [:]

    /// Types keys one by one at a person's pace; a capital key that is not up gets a shift press first.
    private func typeKeys(_ keys: [String], in app: XCUIApplication, pause: TimeInterval = 0.12) {
        let plan = keys.joined(separator: "|")
        if !takeName.isEmpty, let known = typingPlans[plan] {
            for key in known {
                Thread.sleep(forTimeInterval: 0.2)
                let start = Date()
                coordinate(key.x, key.y, in: app).tap()
                pressRecord("key \(key.label)", x: key.x, y: key.y, start: start, end: Date())
            }
            return
        }
        var learned: [PlannedKey] = []
        for key in keys {
            Thread.sleep(forTimeInterval: pause)
            if key == "space" {
                learned.append(tapKeyboardKey(spaceLabels, in: app, label: "space"))
                continue
            }
            let upper = key.uppercased()
            if key == upper, key.rangeOfCharacter(from: .letters) != nil, !app.keys[upper].firstMatch.exists {
                learned.append(tapKeyboardKey(["shift", "Shift", "シフト"], in: app, label: "shift"))
                Thread.sleep(forTimeInterval: 0.1)
            }
            learned.append(tapKeyboardKey([key, upper, key.lowercased()], in: app, label: key))
        }
        typingPlans[plan] = learned
    }

    private var spaceLabels: [String] { ["space", "Space", "spasi", "空白", "スペース"] }

    @discardableResult
    private func tapKeyboardKey(_ candidates: [String], in app: XCUIApplication, label: String) -> PlannedKey {
        // Letters are keys; shift and return show up as buttons.
        for candidate in candidates + candidates.map({ "button:" + $0 }) {
            let isButton = candidate.hasPrefix("button:")
            let name = isButton ? String(candidate.dropFirst(7)) : candidate
            let element = isButton ? app.buttons[name].firstMatch : app.keys[name].firstMatch
            if element.exists {
                let frame = element.frame
                let x = frame.midX / screen.width, y = frame.midY / screen.height
                let start = Date()
                element.tap()
                pressRecord("key \(label)", x: x, y: y, start: start, end: Date())
                return PlannedKey(label: label, x: x, y: y)
            }
        }
        XCTFail("No key for \(label) among \(candidates)")
        return PlannedKey(label: label, x: 0.5, y: 0.8)
    }

    // MARK: - Keyboards

    private struct CardNames { let bank, address, notes, deploy: String }

    private var cards: CardNames {
        switch language {
        case "id": CardNames(bank: "Rekening BCA", address: "Alamat Rumah", notes: "Catatan Rapat", deploy: "Deploy")
        case "ja": CardNames(bank: "振込先", address: "住所", notes: "議事メモ", deploy: "デプロイ")
        default: CardNames(bank: "Bank Account", address: "Home Address", notes: "Meeting Notes", deploy: "Deploy")
        }
    }

    private func card(_ name: String, in app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", name)).firstMatch
    }

    /// A query during a transition takes the main thread of whatever is animating and drops frames, so a wait sits the transition out first.
    private let transition: TimeInterval = 0.9

    /// After a press: waits for the transition, then for what it brings.
    private func arrive(_ element: XCUIElement, timeout: TimeInterval = 15, _ message: String = "Did not arrive") {
        Thread.sleep(forTimeInterval: transition)
        XCTAssertTrue(element.waitForExistence(timeout: timeout), message)
    }

    private func waitForCutlingKeyboard(_ app: XCUIApplication, timeout: TimeInterval = 30) {
        if !takeName.isEmpty {
            // On camera nothing queries the keyboard as it arrives: a query right after the swap blanks its body for a moment.
            Thread.sleep(forTimeInterval: 2.4)
            return
        }
        Thread.sleep(forTimeInterval: transition)
        if !card(cards.bank, in: app).waitForExistence(timeout: timeout) {
            dump("fail-no-cutling-\(takeName)", app)
            XCTFail("Cutling keyboard did not come up")
        }
    }

    private func waitForSystemKeyboard(_ app: XCUIApplication, timeout: TimeInterval = 20) {
        Thread.sleep(forTimeInterval: transition)
        if !app.keys.firstMatch.waitForExistence(timeout: timeout) {
            dump("fail-no-system-\(takeName)", app)
            XCTFail("System keyboard did not come up")
        }
    }

    private func globePoint(in app: XCUIApplication) -> CGPoint {
        let globe = NSPredicate(format: "label ==[c] 'Next keyboard' OR label ==[c] 'Papan Ketik Berikutnya' OR label ==[c] '次のキーボード'")
        for query in [app.buttons, app.keys] {
            let element = query.matching(globe).firstMatch
            if element.exists {
                let frame = element.frame
                return CGPoint(x: frame.midX / screen.width, y: frame.midY / screen.height)
            }
        }
        return isPad ? CGPoint(x: 0.06, y: 0.95) : CGPoint(x: 0.0966, y: 0.9644)
    }

    /// Lets a rising keyboard finish before the globe is pressed; the iPad's takes longer.
    private func settleKeyboard() {
        Thread.sleep(forTimeInterval: isPad ? 1.8 : 1.0)
    }

    private func pressGlobe(in app: XCUIApplication, rest: TimeInterval = 1.0) {
        let point = globePoint(in: app)
        press("globe", x: point.x, y: point.y, in: app, rest: rest)
    }

    /// Off camera: brings up the keyboard that's wanted, retrying the globe, slow machines included.
    private func showKeyboard(cutling wantCutling: Bool, in app: XCUIApplication) {
        for attempt in 0..<5 {
            let wanted = wantCutling ? card(cards.bank, in: app) : app.keys.firstMatch
            if wanted.waitForExistence(timeout: attempt == 0 ? 2.5 : 15) { return }
            pressGlobe(in: app, rest: 0.2)
        }
        dump("fail-keyboard-\(wantCutling ? "cutling" : "system")-\(takeName)", app)
        XCTFail("Could not bring up the \(wantCutling ? "Cutling" : "system") keyboard")
    }

    private func ensureSystemKeyboard(_ app: XCUIApplication) {
        showKeyboard(cutling: false, in: app)
    }

    /// Off camera: loads the extension once, leaves the system keyboard current and the keyboard closed.
    private func warmKeyboard(field: XCUIElement, in app: XCUIApplication) {
        XCTAssertTrue(field.waitForExistence(timeout: 8), "No field")
        field.tap()
        Thread.sleep(forTimeInterval: 1.5)
        showKeyboard(cutling: true, in: app)
        Thread.sleep(forTimeInterval: 1.0)
        showKeyboard(cutling: false, in: app)
        Thread.sleep(forTimeInterval: 0.8)
        resetProp()
    }

    // MARK: - Launching (from the Home Screen, so no back link shows)

    private func launchFromHome(_ app: XCUIApplication, arguments: [String]) {
        app.terminate()
        XCUIDevice.shared.press(.home)
        Thread.sleep(forTimeInterval: 1.4)
        app.launchArguments = arguments
        app.launch()
    }

    private func seed(_ extra: [String] = []) {
        launchFromHome(cutling, arguments: ["-SNAPSHOT_MODE", "-PROMO_MODE", "-PROMO_LANG", language] + extra)
        XCTAssertTrue(cutling.descendants(matching: .any).matching(identifier: "cutlingCard").firstMatch.waitForExistence(timeout: 25), "Seed did not appear")
        Thread.sleep(forTimeInterval: 1)
    }

    private func launchProp(_ page: String, state: String = "ask1") {
        launchFromHome(prop, arguments: ["-PROP_PAGE", page, "-PROP_LANG", language, "-PROP_STATE", state])
        Thread.sleep(forTimeInterval: 1.2)
    }

    private func candidate(_ text: String, in app: XCUIApplication) -> XCUIElement {
        for query in [app.buttons, app.cells, app.staticTexts, app.collectionViews.cells.staticTexts] {
            let element = query[text].firstMatch
            if element.waitForExistence(timeout: 1.5) { return element }
        }
        return app.buttons[text].firstMatch
    }

    // MARK: - Takes

    /// Puts the stand-in page back as it started: a Darwin notification the prop listens for, so nothing is touched.
    private func resetProp() {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName("com.matsuokengo.promo.reset" as CFString), nil, nil, true)
        Thread.sleep(forTimeInterval: 1.4)
    }

    /// Off camera: after a warm pass, the system keyboard is current again and the page is back at its start.
    private func readyForTake(field: XCUIElement) {
        field.tap()
        Thread.sleep(forTimeInterval: 1.2)
        showKeyboard(cutling: false, in: prop)
        Thread.sleep(forTimeInterval: 0.7)
        resetProp()
    }

    private func openEnablePage() {
        let keyboard = cutling.buttons["keyboardToolbarButton"].firstMatch
        XCTAssertTrue(keyboard.waitForExistence(timeout: 12))
        keyboard.tap()
        let guide = cutling.buttons["keyboardSetupGuide"].firstMatch
        if !guide.waitForExistence(timeout: 4) { cutling.swipeUp(); Thread.sleep(forTimeInterval: 1) }
        XCTAssertTrue(guide.waitForExistence(timeout: 5))
        guide.tap()
        let next = cutling.buttons["continueButton"].firstMatch
        XCTAssertTrue(next.waitForExistence(timeout: 8))
        Thread.sleep(forTimeInterval: 1.0)
        next.tap()
        Thread.sleep(forTimeInterval: 1.4)
    }

    private func cutlingKeyboardSwitch() -> XCUIElement { settings.switches.element(boundBy: 0) }

    /// Cutling's Open Settings button, then Keyboards, the Cutling switch, and Allow Full Access with its alert.
    private func runSettingsRoute() {
        Thread.sleep(forTimeInterval: 1.2)
        let open = cutling.buttons[labels.openSettings].firstMatch
        XCTAssertTrue(open.waitForExistence(timeout: 8), "No Open Settings button")
        press("Open Cutling Settings", element: open, in: cutling, rest: 0.7)
        let keyboards = settings.descendants(matching: .any)["KEYBOARDS"].firstMatch
        arrive(keyboards, timeout: 25, "Settings did not open at Cutling")
        if !keyboards.exists { dump("fail-route-\(takeName.isEmpty ? "warm" : takeName)", settings) }
        Thread.sleep(forTimeInterval: 0.6)
        press("Keyboards", element: keyboards, in: settings, rest: 0.7)
        let toggle = cutlingKeyboardSwitch()
        arrive(toggle, "No Cutling switch")
        Thread.sleep(forTimeInterval: 0.5)
        press("Cutling switch", element: toggle.switches.firstMatch, in: settings, rest: 0.8)
        let fullAccess = fullAccessSwitch()
        arrive(fullAccess, "No Allow Full Access switch")
        Thread.sleep(forTimeInterval: 0.5)
        press("Allow Full Access", element: fullAccess.switches.firstMatch, in: settings, rest: 0.8)
        let allow = settings.alerts.buttons[labels.allow].firstMatch
        arrive(allow, "No Full Access alert")
        Thread.sleep(forTimeInterval: 0.5)
        press("Allow", element: allow, in: settings, rest: 0.8)
        waitForSwitchOn(fullAccess)
    }

    private func fullAccessSwitch() -> XCUIElement { settings.switches.element(boundBy: 1) }

    /// The switch reads on once the system has taken the alert's answer.
    private func waitForSwitchOn(_ toggle: XCUIElement, timeout: TimeInterval = 10) {
        Thread.sleep(forTimeInterval: transition)
        let deadline = Date().addingTimeInterval(timeout)
        while (toggle.value as? String) != "1", Date() < deadline { Thread.sleep(forTimeInterval: 0.4) }
        XCTAssertEqual(toggle.value as? String, "1", "The switch did not turn on")
    }

    /// The Simulator's Settings ignores where this button asks to go and comes up on its last page,
    /// so that page is walked to off camera first. On a device the button itself goes to Cutling's page.
    private func walkSettingsToCutlingPage() {
        settings.activate()
        Thread.sleep(forTimeInterval: 2.5)
        // A Settings the system kept alive is already on the page; one it ended has restarted at its root.
        if settings.descendants(matching: .any)["KEYBOARDS"].firstMatch.exists { return }
        let apps = settings.descendants(matching: .any)["com.apple.settings.apps"].firstMatch
        for _ in 0..<6 where !apps.isHittable {
            settings.swipeUp()
            Thread.sleep(forTimeInterval: 1.2)
        }
        XCTAssertTrue(apps.waitForExistence(timeout: 5), "No Apps row in Settings")
        apps.tap()
        Thread.sleep(forTimeInterval: 2.5)
        let row = settings.staticTexts.matching(NSPredicate(format: "label == 'Cutling' OR label == 'カットリング'")).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 8), "Cutling is not in the Apps list")
        row.tap()
        Thread.sleep(forTimeInterval: 2.0)
    }

    /// The short way to add the keyboard, filmed through to Full Access switched on.
    func test0SetupKeyboard() {
        seed()
        openEnablePage()
        // Cutling stays open on this page from here on: relaunching it lets the system end Settings in the background.
        walkSettingsToCutlingPage()
        cutling.activate()
        Thread.sleep(forTimeInterval: 1.5)
        // Warm: the whole route once, both switches turned back off after, Settings left on Cutling's page.
        runSettingsRoute()
        Thread.sleep(forTimeInterval: 1.5)
        let warmFullAccess = fullAccessSwitch()
        if warmFullAccess.waitForExistence(timeout: 6), (warmFullAccess.value as? String) == "1" { warmFullAccess.switches.firstMatch.tap() }
        Thread.sleep(forTimeInterval: 1.2)
        let warmToggle = cutlingKeyboardSwitch()
        if warmToggle.waitForExistence(timeout: 6), (warmToggle.value as? String) == "1" { warmToggle.switches.firstMatch.tap() }
        Thread.sleep(forTimeInterval: 1.2)
        settings.navigationBars[labels.keyboards].buttons.firstMatch.tap()
        Thread.sleep(forTimeInterval: 1.2)
        // Allowing Full Access made the system end Cutling; it comes back at its first screen, not on the guide.
        seed()
        openEnablePage()
        // The machine settles first; the visit to Settings comes last, so nothing ends Settings before the press.
        waitForQuietMachine("before-setup")
        walkSettingsToCutlingPage()
        cutling.activate()
        Thread.sleep(forTimeInterval: 1.5)
        beginTake("setup-settings", skipSettleGate: true)
        runSettingsRoute()
        endTake(hold: 2.5)
        settings.terminate()
    }

    /// The chat before anything happens: the friend's question arrives.
    func test1ChatIdle() {
        launchProp("chat", state: "arrive")
        XCTAssertTrue(prop.textViews["chatInput"].firstMatch.waitForExistence(timeout: 25), "Chat did not appear")
        Thread.sleep(forTimeInterval: 1)
        // Warm: the arrival once, then the page back as it was.
        let headerPoint = (x: CGFloat(isPad ? 0.62 : 0.5), y: CGFloat(isPad ? 0.04 : 0.075))
        coordinate(headerPoint.x, headerPoint.y, in: prop).tap()
        Thread.sleep(forTimeInterval: 3.5)
        resetProp()
        beginTake("chat-idle")
        Thread.sleep(forTimeInterval: 1.2)
        coordinate(headerPoint.x, headerPoint.y, in: prop).tap() // the header starts the friend's typing
        pressLog.removeAll()
        endTake(hold: 4.5)
    }

    private func runSaveFlow(filming: Bool) {
        let add = cutling.buttons[labels.addCutling].firstMatch
        let textCutling = cutling.buttons[labels.textCutling].firstMatch
        XCTAssertTrue(add.waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: filming ? 1.0 : 0.3)
        press("plus", element: add, in: cutling, rest: 0.8)
        arrive(textCutling, timeout: 8, "No Text Cutling in the menu")
        press("Text Cutling", element: textCutling, in: cutling, rest: 0.8)
        let paste = cutling.buttons[labels.pasteFromClipboard].firstMatch
        arrive(paste, timeout: 8, "No Paste from Clipboard")
        Thread.sleep(forTimeInterval: 0.4)
        press("Paste from Clipboard", element: paste, in: cutling, rest: 1.0)
        Thread.sleep(forTimeInterval: 1.2)
        let name = cutling.textFields.firstMatch
        press("name field", element: name, in: cutling, rest: 0.9)
        waitForSystemKeyboard(cutling)
        Thread.sleep(forTimeInterval: 0.8)
        // Pasted digits can auto-name the card (a phone number): select that name so typing replaces it.
        if let current = name.value as? String, !current.isEmpty, current != name.placeholderValue {
            name.tap(withNumberOfTaps: 3, numberOfTouches: 1)
            Thread.sleep(forTimeInterval: 0.9)
        }
        typeKeys(labels.bankNameKeys, in: cutling)
        if let word = labels.bankNameCandidate {
            Thread.sleep(forTimeInterval: 0.9)
            press("candidate \(word)", element: candidate(word, in: cutling), in: cutling, rest: 0.6)
        }
        Thread.sleep(forTimeInterval: 0.8)
    }

    /// In Cutling: new text, paste the number, name it, save, the card lands.
    func test2Save() {
        seed(["-PROMO_WITHOUT_BANK", "-PROMO_CLIP"])
        // Warm: the whole flow once, closed without saving; the last-used keyboard ends as the system one.
        let add = cutling.buttons[labels.addCutling].firstMatch
        XCTAssertTrue(add.waitForExistence(timeout: 10))
        add.tap()
        let textCutling = cutling.buttons[labels.textCutling].firstMatch
        XCTAssertTrue(textCutling.waitForExistence(timeout: 8))
        textCutling.tap()
        Thread.sleep(forTimeInterval: 2)
        let name = cutling.textFields.firstMatch
        XCTAssertTrue(name.waitForExistence(timeout: 8))
        name.tap()
        Thread.sleep(forTimeInterval: 1.5)
        ensureSystemKeyboard(cutling)
        cutling.navigationBars.buttons["xmark"].firstMatch.tap()
        Thread.sleep(forTimeInterval: 1.5)
        runSaveFlow(filming: false)
        cutling.navigationBars.buttons["xmark"].firstMatch.tap()
        Thread.sleep(forTimeInterval: 2.0)
        beginTake("save")
        runSaveFlow(filming: true)
        let save = cutling.navigationBars.buttons["checkmark"].firstMatch
        press("save", element: save, in: cutling, rest: 0.8)
        endTake(hold: 3.5)
    }

    /// Cutling's own setup guide, for the store previews.
    func test3SetupApp() {
        seed()
        let keyboard = cutling.buttons["keyboardToolbarButton"].firstMatch
        XCTAssertTrue(keyboard.waitForExistence(timeout: 8))
        keyboard.tap()
        let guide = cutling.buttons["keyboardSetupGuide"].firstMatch
        if !guide.waitForExistence(timeout: 4) { cutling.swipeUp(); Thread.sleep(forTimeInterval: 1) }
        XCTAssertTrue(guide.waitForExistence(timeout: 5))
        guide.tap()
        Thread.sleep(forTimeInterval: 1.5)
        dump("setup-guide", cutling)
        let close = cutling.navigationBars.buttons.firstMatch
        if close.exists { close.tap(); Thread.sleep(forTimeInterval: 1.2) }
        seedAgainIfNeeded()
        beginTake("setup-app")
        Thread.sleep(forTimeInterval: 1.0)
        press("keyboard page", element: keyboard, in: cutling)
        arrive(guide, timeout: 6, "No setup guide")
        Thread.sleep(forTimeInterval: 0.5)
        press("setup guide", element: guide, in: cutling, rest: 1.0)
        let next = cutling.buttons["continueButton"].firstMatch
        arrive(next, timeout: 6, "No continue button")
        Thread.sleep(forTimeInterval: 1.0)
        press("continue", element: next, in: cutling, rest: 1.5)
        endTake(hold: 3.0)
    }

    private func seedAgainIfNeeded() {
        if !cutling.buttons["keyboardToolbarButton"].firstMatch.waitForExistence(timeout: 2) {
            seed()
        }
    }

    // MARK: - Keyboard takes, each flow run once warm and once filmed

    private func runTapFlow(_ input: XCUIElement) {
        Thread.sleep(forTimeInterval: 1.2)
        press("field", element: input, in: prop, rest: 0.8)
        waitForSystemKeyboard(prop)
        settleKeyboard()
        holdGlobe(to: switcherRows().cutling, in: prop)
        waitForCutlingKeyboard(prop)
        Thread.sleep(forTimeInterval: 1.0)
        press("bank card", element: card(cards.bank, in: prop), in: prop, rest: 1.2)
    }

    /// The chat: hold the globe, slide to Cutling, the bank number lands.
    func test4Tap() {
        seed()
        launchProp("chat")
        let input = prop.textViews["chatInput"].firstMatch
        warmKeyboard(field: input, in: prop)
        runTapFlow(input)
        Thread.sleep(forTimeInterval: 1.8)
        resetProp()
        readyForTake(field: input)
        beginTake("tap")
        runTapFlow(input)
        endTake(hold: 3.5)
    }

    private func runFindFlow(_ input: XCUIElement) {
        let rows = switcherRows()
        Thread.sleep(forTimeInterval: 1.2)
        press("field", element: input, in: prop, rest: 0.8)
        waitForSystemKeyboard(prop)
        settleKeyboard()
        holdGlobe(to: rows.cutling, in: prop)
        waitForCutlingKeyboard(prop)
        Thread.sleep(forTimeInterval: 0.9)
        press("address card", element: card(cards.address, in: prop), in: prop, rest: 1.2)
        Thread.sleep(forTimeInterval: 1.6)
        let send = prop.buttons["send"].firstMatch
        XCTAssertTrue(send.waitForExistence(timeout: 6))
        press("send", element: send, in: prop, rest: 0.9)
        Thread.sleep(forTimeInterval: 1.4)
        if isPad {
            pressGlobe(in: prop, rest: 0.9) // Cutling's own globe key on iPad is a plain tap
        } else {
            holdGlobe(to: rows.system, in: prop, rest: 0.9)
        }
        waitForSystemKeyboard(prop)
        Thread.sleep(forTimeInterval: 0.9)
        typeKeys(labels.findKeys, in: prop)
        if let word = labels.findCandidate {
            press("candidate \(word)", element: candidate(word, in: prop), in: prop, rest: 0.9)
        }
        Thread.sleep(forTimeInterval: 0.8)
        holdGlobe(to: rows.cutling, in: prop, rest: 0.9)
        waitForCutlingKeyboard(prop)
        Thread.sleep(forTimeInterval: 1.1)
        press("suggestion", element: card(cards.address, in: prop), in: prop, rest: 1.2)
    }

    /// The address, one more tap; then its name typed and its suggestion tapped.
    func test5Find() {
        seed()
        launchProp("chat", state: "ask2")
        let input = prop.textViews["chatInput"].firstMatch
        warmKeyboard(field: input, in: prop)
        runFindFlow(input)
        Thread.sleep(forTimeInterval: 1.8)
        resetProp()
        readyForTake(field: input)
        beginTake("find")
        runFindFlow(input)
        endTake(hold: 3.5)
    }

    private func runRichFlow(_ body: XCUIElement) {
        Thread.sleep(forTimeInterval: 1.0)
        press("body", element: body, in: prop, rest: 0.8)
        waitForSystemKeyboard(prop)
        settleKeyboard()
        holdGlobe(to: switcherRows().cutling, in: prop)
        waitForCutlingKeyboard(prop)
        Thread.sleep(forTimeInterval: 1.0)
        // The preview text carries a real link: press on the card's name, not on the link.
        let richFrame = frame("rich card", of: card(cards.notes, in: prop))
        press("rich card", x: (richFrame.minX + richFrame.width * 0.3) / screen.width, y: (richFrame.minY + richFrame.height * 0.28) / screen.height, in: prop, rest: 1.2)
        Thread.sleep(forTimeInterval: 1.8)
        let frame = body.frame
        let start = Date()
        body.press(forDuration: 1.0)
        pressRecord("long press body", x: frame.midX / screen.width, y: frame.midY / screen.height, start: start, end: Date())
        let paste = [prop.menuItems[labels.paste], prop.buttons[labels.paste], prop.staticTexts[labels.paste]].map(\.firstMatch).first { $0.waitForExistence(timeout: 2) } ?? prop.menuItems[labels.paste].firstMatch
        press("Paste", element: paste, in: prop, rest: 1.0)
    }

    /// A rich cutling copies; Paste keeps the bold and the link.
    func test6FormatRich() {
        seed()
        launchProp("mail")
        let body = prop.textViews["mailBody"].firstMatch
        warmKeyboard(field: body, in: prop)
        runRichFlow(body)
        Thread.sleep(forTimeInterval: 2.0)
        resetProp()
        readyForTake(field: body)
        beginTake("format-rich")
        runRichFlow(body)
        Thread.sleep(forTimeInterval: 2.5)
        dump("format-rich-after-paste-\(language)", prop)
        endTake(hold: 2.0)
    }

    private func runCodeFlow(_ input: XCUIElement) {
        Thread.sleep(forTimeInterval: 1.0)
        press("field", element: input, in: prop, rest: 0.8)
        waitForSystemKeyboard(prop)
        settleKeyboard()
        holdGlobe(to: switcherRows().cutling, in: prop)
        waitForCutlingKeyboard(prop)
        Thread.sleep(forTimeInterval: 1.0)
        press("code card", element: card(cards.deploy, in: prop), in: prop, rest: 1.2)
    }

    /// A code cutling goes in exactly.
    func test7FormatCode() {
        seed()
        launchProp("code")
        let input = prop.textViews["codeInput"].firstMatch
        warmKeyboard(field: input, in: prop)
        runCodeFlow(input)
        Thread.sleep(forTimeInterval: 1.8)
        resetProp()
        readyForTake(field: input)
        beginTake("format-code")
        runCodeFlow(input)
        endTake(hold: 3.0)
    }

    /// Share from a page into Cutling's sheet, saved, still in the same app.
    func test8Capture() {
        guard !isPad else { return }
        seed()
        launchProp("page")
        let share = prop.buttons["share"].firstMatch
        XCTAssertTrue(share.waitForExistence(timeout: 6))
        // Warm: the share sheet and Cutling's compose view, off camera.
        share.tap()
        Thread.sleep(forTimeInterval: 2.5)
        let cutlingCell = prop.cells.matching(identifier: "shareCell").matching(NSPredicate(format: "label == 'Cutling' OR label == 'カットリング'")).firstMatch
        if cutlingCell.waitForExistence(timeout: 6) { cutlingCell.tap() }
        Thread.sleep(forTimeInterval: 4)
        dump("capture-compose-prop", prop)
        dump("capture-compose-springboard", springboard)
        // Leave Cutling's sheet, whichever process draws it.
        let close = shareSheetButton("xmark")
        if close.exists { close.tap() } else { coordinate(0.09, 0.09, in: prop).tap() }
        Thread.sleep(forTimeInterval: 2.0)
        // Cutling's sheet closed back to the share sheet; a tap on the page closes that one too.
        coordinate(0.5, 0.82, in: prop).tap()
        // Staying in this process keeps the share sheet warm for the filmed run.
        Thread.sleep(forTimeInterval: 2.5)
        XCTAssertTrue(share.waitForExistence(timeout: 8))
        beginTake("capture")
        Thread.sleep(forTimeInterval: 1.2)
        press("share", element: share, in: prop, rest: 0.8)
        arrive(cutlingCell, timeout: 8, "Cutling not in the share sheet")
        Thread.sleep(forTimeInterval: 1.0)
        press("Cutling", element: cutlingCell, in: prop, rest: 1.0)
        Thread.sleep(forTimeInterval: 3.5)
        let save = shareSheetButton("checkmark")
        XCTAssertTrue(save.waitForExistence(timeout: 6), "No save button in Cutling's sheet")
        let frame = save.frame
        press("save", x: frame.midX / screen.width, y: frame.midY / screen.height, in: prop, rest: 1.0)
        endTake(hold: 3.5)
    }

    /// Cutling's share view is an extension; its toolbar shows in the host's tree or SpringBoard's.
    private func shareSheetButton(_ identifier: String) -> XCUIElement {
        // The extension's view can take many seconds to load on a busy machine.
        for _ in 0..<14 {
            for app in [prop, springboard] {
                let button = app.navigationBars.buttons[identifier].firstMatch
                if button.exists { return button }
            }
            Thread.sleep(forTimeInterval: 1.5)
        }
        return prop.navigationBars.buttons[identifier].firstMatch
    }

    // MARK: - Debug dumps

    private func dump(_ name: String, _ app: XCUIApplication) {
        try? app.debugDescription.write(toFile: "\(dir)/\(takePrefix)-\(name).txt", atomically: true, encoding: .utf8)
        try? XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: "\(dir)/\(takePrefix)-\(name).png"))
    }
}
