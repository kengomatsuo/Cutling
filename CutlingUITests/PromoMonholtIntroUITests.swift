//
//  PromoMonholtIntroUITests.swift
//  CutlingUITests
//
//  The two Cutling takes of Monholt's introduction film (undirect-promo monholt-films-4/storyboard.md, Film 2, shots 5-8):
//  test1TypedByHand, a reply typed letter by letter on the iPhone's own keyboard in Messages (the chore), and
//  test2TypeFirst, the name typed first, one globe tap to Cutling, "Order update" tapped, the reply filled with the
//  name, then the check mark (the fix). Every keystroke is a real touch on a real key, so the film shows each key go
//  down. ui-test.sh films the run; each step prints `MARK <wall clock> <what>` to find it in run.mp4.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class PromoMonholtIntroUITests: XCTestCase {

    private let messages = XCUIApplication(bundleIdentifier: "com.apple.MobileSMS")
    /// The day the intro posts: the seed's "Order update" names the next day ({day +1d}), so the reply typed by hand
    /// in the first take and the one Cutling fills in the second both say Wednesday.
    private static let postDay = "2026-12-01"
    private static let reply = "Hi Maya, your order ships Wednesday."
    /// 60 words a minute, five characters a word: a quick typist on a phone.
    private let slot = 60.0 / (60.0 * 5)

    override func setUpWithError() throws { continueAfterFailure = false }

    private func mark(_ what: String) { print("MARK \(Date().timeIntervalSince1970) \(what)") }

    /// The release seed in English (its "Order update" reply asks for a name), then a new message in Messages with the
    /// caret in the message field.
    @MainActor
    private func openNewMessage() {
        let app = XCUIApplication()
        app.launchArguments += ["-lastWhatsNewSeen", WhatsNewSkip.releaseID, "-PROMO_RELEASE", "-hasSeenInteractiveTutorial", "YES",
                                "-hasCompletedSetup", "YES", "-PROMO_NO_RECENT", "-PROMO_TODAY", Self.postDay]
        XCUIDevice.shared.appearance = .light
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["cutlingCard"].firstMatch.waitForExistence(timeout: 30), "No cards")
        sleep(2)
        app.terminate()
        messages.terminate()
        messages.launch()
        XCTAssertTrue(messages.wait(for: .runningForeground, timeout: 20))
        sleep(2)
        messages.open(URL(string: "sms:")!)
        sleep(3)
        let body = messageField
        XCTAssertTrue(body.waitForExistence(timeout: 15), "No message field")
        for _ in 0..<3 where (body.value(forKey: "hasKeyboardFocus") as? Bool) != true {
            body.tap()
            _ = messages.keyboards.firstMatch.waitForExistence(timeout: 4)
        }
        sleep(1)
    }

    private var messageField: XCUIElement {
        messages.descendants(matching: .any).matching(identifier: "messageBodyField").firstMatch
    }

    /// Cutling up, then back to the iPhone's own keyboard, so Cutling is the keyboard used last and one tap on the globe
    /// reaches it on camera.
    @MainActor
    private func cutlingLastUsed(showing key: String) {
        if !cutlingKeyboardIsUp(in: messages, showing: key) {
            continueAfterFailure = true
            switchToCutlingKeyboard(in: messages, showing: key)
            continueAfterFailure = false
        }
        XCTAssertTrue(cutlingKeyboardIsUp(in: messages, showing: key), "Cutling keyboard did not come up")
        for _ in 0..<4 where messages.keys.count == 0 {
            keyboardGlobe(in: messages).coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            sleep(2)
        }
        XCTAssertGreaterThan(messages.keys.count, 0, "The iPhone's own keyboard did not come back")
    }

    @MainActor
    func test1TypedByHand() throws {
        openNewMessage()
        cutlingLastUsed(showing: "Order update")
        sleep(1)
        mark("type start")
        pressKeys(Self.reply, in: messages, slot: slot, mark: mark)
        mark("type end")
        sleep(2)
        let typed = (messageField.value as? String) ?? ""
        print("TYPED: \(typed)")
        messages.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 60))
        sleep(1)
    }

    @MainActor
    func test2TypeFirst() throws {
        openNewMessage()
        cutlingLastUsed(showing: "Order update")
        sleep(1)
        mark("type name")
        pressKeys("Maya", in: messages, slot: slot, mark: mark)
        sleep(1)
        mark("globe")
        keyboardGlobe(in: messages).coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        sleep(2)
        if !cutlingKeyboardIsUp(in: messages, showing: "Order update") {
            mark("globe tap missed, sliding up the list")
            continueAfterFailure = true
            switchToCutlingKeyboard(in: messages, showing: "Order update")
            continueAfterFailure = false
        }
        XCTAssertTrue(cutlingKeyboardIsUp(in: messages, showing: "Order update"), "Cutling keyboard did not come up")
        guard let order = cutlingKeyFrame("Order update", in: messages) else { return XCTFail("No Order update key") }
        sleep(1)
        mark("order update at \(Int(order.midX)),\(Int(order.midY))")
        screenPoint(order.midX, order.midY, in: messages).press(forDuration: 0.12)
        sleep(2)
        // The check mark: the right end of the lowest row of Cutling's buttons (delete, space, return).
        let keys = cutlingKeys(in: messages) ?? []
        let lowest = keys.map { Int($0.frame.midY) }.max() ?? 0
        let done = keys.filter { abs(Int($0.frame.midY) - lowest) < 8 }.max(by: { $0.frame.midX < $1.frame.midX })?.frame ?? .zero
        mark("insert at \(Int(done.midX)),\(Int(done.midY))")
        screenPoint(done.midX, done.midY, in: messages).press(forDuration: 0.12)
        sleep(4)
        let typed = (messageField.value as? String) ?? ""
        print("TYPED: \(typed)")
        XCTAssertEqual(typed, Self.reply, "The filled reply is not the line the first take typed by hand")
        mark("end")
        messages.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 90))
        sleep(1)
    }
}
