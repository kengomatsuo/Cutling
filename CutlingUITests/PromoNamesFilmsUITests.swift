//
//  PromoNamesFilmsUITests.swift
//  CutlingUITests
//
//  The takes of the Five names and Five taps films (undirect docs/plans/app-store-growth, board ASG221), real recordings
//  of Cutling in Apple's Messages: the name is typed on the system keyboard before Cutling opens, and the first reply takes
//  it for its blank; later replies offer the names used before. scripts/names-film-takes.sh records each test on the
//  device queue's simulator and logs `MARK <wall clock> <what>` lines for the cut. NAMES_LANG en|ja picks the language the
//  system, the seed (PromoNamesSeed.swift) and the labels the tests find are in.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

@MainActor
final class PromoNamesFilmsUITests: XCTestCase {
    private let env = ProcessInfo.processInfo.environment
    private let messages = XCUIApplication(bundleIdentifier: "com.apple.MobileSMS")
    private var language: String { env["NAMES_LANG"] ?? "en" }

    private struct Words {
        let locale: String
        /// Five names: the reply's key, the customer whose name is typed, then the customers whose names are picked.
        let order: String
        let typedCustomer: String
        let pickedCustomers: [String]
        /// Five taps: the three keys, the guest, the choice that is tapped.
        let hello, booking, signoff, guest, party: String
    }

    private var words: Words {
        switch language {
        case "ja":
            Words(locale: "ja_JP", order: "発送連絡", typedCustomer: "中村", pickedCustomers: ["小林", "松本", "岡田"],
                  hello: "あいさつ", booking: "予約OK", signoff: "しめの挨拶", guest: "高橋", party: "4名様")
        default:
            Words(locale: "en_US", order: "Order update", typedCustomer: "Maya", pickedCustomers: ["Jonas", "Aiko", "Sam", "Lea"],
                  hello: "Hello", booking: "Booking", signoff: "Sign-off", guest: "Maya", party: "4")
        }
    }

    override func setUpWithError() throws { continueAfterFailure = false }

    private func mark(_ what: String) { print("MARK \(Date().timeIntervalSince1970) \(what)") }

    private func shot(_ name: String) {
        let data = XCUIScreen.main.screenshot().pngRepresentation
        if let dir = env["NAMES_DIR"] { try? data.write(to: URL(fileURLWithPath: dir).appendingPathComponent("\(language)_\(name).png")) }
    }

    /// Seeds Cutling's grid and the Name blank's history, then leaves the app.
    private func seed(kind: String, history: String) {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-PROMO_NAMES", "-PROMO_NAMES_KIND", kind,
                                "-PROMO_NAMES_HISTORY", history, "-hasSeenInteractiveTutorial", "YES", "-hasCompletedSetup", "YES"]
        if language != "en" { app.launchArguments += ["-PROMO_LANG", language, "-AppleLanguages", "(\(language))", "-AppleLocale", words.locale] }
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["cutlingCard"].firstMatch.waitForExistence(timeout: 30), "No cards")
        sleep(2)
        app.terminate()
    }

    private func messageField() -> XCUIElement {
        let body = messages.descendants(matching: .any).matching(identifier: "messageBodyField").firstMatch
        XCTAssertTrue(body.waitForExistence(timeout: 15), "No message field")
        return body
    }

    /// A new message, the cursor in the message field. The simulator's Messages has no service, so a recipient never
    /// resolves and nothing can be sent: the takes end with the reply in the field, and the customer is named by the film.
    private func newMessage() {
        if messages.state != .runningForeground { messages.launch() }
        messages.open(URL(string: "sms:")!)
        XCTAssertTrue(messages.wait(for: .runningForeground, timeout: 15))
        sleep(3)
        let body = messageField()
        for _ in 0..<3 where (body.value(forKey: "hasKeyboardFocus") as? Bool) != true {
            body.tap()
            _ = messages.keyboards.firstMatch.waitForExistence(timeout: 4)
        }
        sleep(1)
    }

    /// The person's own keyboard up, not the Cutling keyboard Messages reopens on (the one used last).
    private func ownKeyboard() {
        for _ in 0..<4 where cutlingKeyboardIsUp(in: messages) {
            keyboardGlobe(in: messages).coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            sleep(2)
        }
        XCTAssertTrue(messages.keys.count > 0, "The person's own keyboard did not come up")
    }

    /// Leaves no draft for the next message.
    private func clearDraft() {
        messageField().typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 200))
        sleep(1)
    }

    private func frame(_ name: String) -> CGRect {
        var found: CGRect?
        for _ in 0..<12 {
            found = cutlingKeyFrame(name, in: messages)
            if found != nil { break }
            usleep(500_000)
        }
        XCTAssertNotNil(found, "No \(name) on the Cutling keyboard (buttons: \(cutlingKeys(in: messages)?.map(\.label) ?? []))")
        return found ?? .zero
    }

    private func press(_ label: String, _ rect: CGRect) {
        mark("\(label) at \(Int(rect.midX)),\(Int(rect.midY))")
        screenPoint(rect.midX, rect.midY, in: messages).press(forDuration: 0.12)
    }

    /// The Cutling keyboard up: one tap on the globe goes back to the keyboard used last, which is Cutling; the slide up its list
    /// is the way when that tap lands elsewhere.
    private func cutlingUp(showing key: String) {
        if !cutlingKeyboardIsUp(in: messages, showing: key) {
            mark("globe")
            keyboardGlobe(in: messages).coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            sleep(2)
        }
        if !cutlingKeyboardIsUp(in: messages, showing: key) {
            continueAfterFailure = true
            switchToCutlingKeyboard(in: messages, showing: key)
            continueAfterFailure = false
        }
        XCTAssertTrue(cutlingKeyboardIsUp(in: messages, showing: key), "Cutling keyboard did not come up in Messages")
    }

    /// The name typed on the system keyboard in the message field, as a person types it, before Cutling is opened: the
    /// fill-in takes the word typed just before the reply for its first blank (KeyboardViewController.use).
    private func typeName(_ name: String) {
        if language == "ja" {
            XCTAssertTrue(messages.keys["な"].waitForExistence(timeout: 10), "The kana keyboard did not come up")
            sleep(1)
            func tapKey(_ label: String) {
                mark("kana \(label)")
                messages.keys[label].tap()
                usleep(450_000)
            }
            func flick(_ label: String, _ dx: CGFloat, _ dy: CGFloat) {
                mark("kana \(label) flick")
                let key = messages.keys[label].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                key.press(forDuration: 0.1, thenDragTo: key.withOffset(CGVector(dx: dx, dy: dy)), withVelocity: .default, thenHoldForDuration: 0.2)
                usleep(450_000)
            }
            switch name {
            case "中村": tapKey("な"); tapKey("か"); flick("ま", 0, -50); tapKey("ら")
            case "高橋": tapKey("た"); tapKey("か"); tapKey("は"); flick("さ", -50, 0)
            default: XCTFail("No kana for \(name)")
            }
            sleep(1)
            func kana(_ names: [String]) -> XCUIElement {
                messages.keyboards.firstMatch.descendants(matching: .any)
                    .matching(NSPredicate(format: "label IN %@ OR identifier IN %@", names, names)).firstMatch
            }
            mark("kana convert")
            kana(["空白", "space", "Space"]).tap()
            usleep(900_000)
            shot("converted")
            mark("kana commit")
            kana(["確定", "Return"]).tap()
        } else {
            XCTAssertTrue(messages.keys["a"].waitForExistence(timeout: 10) || messages.keys["A"].waitForExistence(timeout: 2), "No system keyboard")
            sleep(1)
            for letter in name {
                mark("key \(letter)")
                messages.keys.matching(NSPredicate(format: "label ==[c] %@", String(letter))).firstMatch.tap()
                usleep(380_000)
            }
        }
        sleep(1)
        shot("typed")
    }

    /// The check mark of the fill-in: the right end of the lowest row of Cutling's buttons (delete, space, check).
    private func confirm() {
        let keys = cutlingKeys(in: messages) ?? []
        let lowest = keys.map { Int($0.frame.midY) }.max() ?? 0
        let done = keys.filter { abs(Int($0.frame.midY) - lowest) < 8 }.max(by: { $0.frame.midX < $1.frame.midX })?.frame ?? .zero
        press("check", done)
    }

    /// Five names, the first customer: the name is typed on the system keyboard, then the reply takes it (history empty).
    func test1Typed() throws {
        seed(kind: "names", history: "")
        messages.launch()
        sleep(2)
        newMessage()
        ownKeyboard()
        mark("ready")
        typeName(words.typedCustomer)
        mark("typed")
        cutlingUp(showing: words.order)
        sleep(1)
        press("reply", frame(words.order))
        sleep(2)
        shot("asks")
        mark("asks")
        sleep(1)
        confirm()
        sleep(2)
        shot("filled")
        mark("filled")
        sleep(1)
        mark("end")
        clearDraft()
    }

    /// Five names, the customers after: the names used before are one tap away (history seeded as the app keeps it).
    func test2Picked() throws {
        seed(kind: "names", history: ([words.typedCustomer] + words.pickedCustomers).joined(separator: ","))
        messages.launch()
        sleep(2)
        for customer in words.pickedCustomers {
            newMessage()
            cutlingUp(showing: words.order)
            sleep(1)
            mark("ready \(customer)")
            press("reply", frame(words.order))
            sleep(1)
            let value = frame(customer)
            shot("list-\(customer)")
            mark("list \(customer)")
            usleep(500_000)
            press("name", value)
            sleep(1)
            if cutlingKeyFrame(words.order, in: messages) == nil { confirm(); sleep(1) }
            shot("filled-\(customer)")
            mark("filled \(customer)")
            sleep(2)
            mark("end \(customer)")
            clearDraft()
        }
    }

    /// Five taps: the guest's name typed first, Hello takes it, Booking asks how many (4), Sign-off leaves the cursor above it.
    func test3Taps() throws {
        seed(kind: "taps", history: "")
        messages.launch()
        sleep(2)
        newMessage()
        ownKeyboard()
        mark("ready")
        typeName(words.guest)
        mark("typed")
        cutlingUp(showing: words.hello)
        sleep(1)
        press("hello", frame(words.hello))
        sleep(2)
        shot("hello-asks")
        mark("hello asks")
        sleep(1)
        confirm()
        sleep(2)
        shot("hello-done")
        mark("hello done")
        sleep(1)
        press("booking", frame(words.booking))
        sleep(2)
        let party = frame(words.party)
        shot("booking-asks")
        mark("booking asks")
        sleep(1)
        press("party", party)
        sleep(1)
        if cutlingKeyFrame(words.signoff, in: messages) == nil { confirm(); sleep(1) }
        shot("booking-done")
        mark("booking done")
        sleep(1)
        press("signoff", frame(words.signoff))
        sleep(2)
        shot("signoff-done")
        mark("signoff done")
        sleep(2)
        mark("end")
        clearDraft()
    }
}
