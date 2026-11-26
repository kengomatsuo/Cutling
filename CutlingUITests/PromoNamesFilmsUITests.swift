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

import Contacts
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

    /// How fast the name is typed, from a measured mean of flick typists (Yokoyama, Kato, Yamamoto, IPSJ 2019 5H-03:
    /// 87 kana a minute) and, in English, Palin et al. 2019 (36.2 words of five characters a minute).
    private var slot: Double { language == "ja" ? 60.0 / 87 : 60.0 / (36.2 * 5) }

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
        // NAMES_TODAY=yyyy-MM-dd: the day the film's post goes out, which a date stamp types (FillInClock, debug builds).
        if let today = env["NAMES_TODAY"], !today.isEmpty { app.launchArguments += ["-PROMO_TODAY", today] }
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

    /// The stock thread of +1 (555) 564-8583 is the only one the simulator's Messages can show (no imagent makes another), so
    /// every customer is that thread: the contact that owns the number is swapped to the customer before Messages opens, and
    /// the thread shows the customer's avatar beside the number. The customer's question is the film's caption.
    private static let threadNumber = "+15555648583"

    private func assignThread(to customer: String) throws {
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        var all: [CNContact] = []
        try store.enumerateContacts(with: CNContactFetchRequest(keysToFetch: keys)) { contact, _ in all.append(contact) }
        let digits = { (n: CNPhoneNumber) in n.stringValue.filter(\.isNumber) }
        let want = Self.threadNumber.filter(\.isNumber)
        let isCustomer = { (c: CNContact) in self.language == "ja" ? c.familyName == customer : (c.givenName == customer && c.familyName.isEmpty) }
        let request = CNSaveRequest()
        var given = false
        for contact in all {
            let owns = contact.phoneNumbers.contains { digits($0.value) == want }
            let gets = isCustomer(contact) && !given
            if gets { given = true }
            guard owns != gets else { continue }
            let edit = contact.mutableCopy() as! CNMutableContact
            edit.phoneNumbers = contact.phoneNumbers.filter { digits($0.value) != want }
            if gets { edit.phoneNumbers.append(CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: Self.threadNumber))) }
            request.update(edit)
        }
        if !given, language == "en" {
            // A customer the simulator has no card for yet gets one, first name only, as the others are saved.
            let card = CNMutableContact()
            card.givenName = customer
            card.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: Self.threadNumber))]
            request.add(card, toContainerWithIdentifier: nil)
            given = true
        }
        XCTAssertTrue(given, "No contact for \(customer)")
        try store.execute(request)
    }

    /// The customer's thread, the cursor in the message field: Messages' own conversation view, not the New Message sheet.
    private func thread(_ customer: String) throws {
        try assignThread(to: customer)
        messages.terminate()
        messages.launch()
        let row = messages.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS '564-8583'")).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 15), "No thread list")
        sleep(2)
        if !row.isHittable {
            // Messages reopens on the New Message sheet it was left on, over the list: its close button is the top right circle
            messages.coordinate(withNormalizedOffset: CGVector(dx: 397.0 / 440, dy: 104.0 / 956)).tap()
            sleep(2)
            XCTAssertTrue(row.isHittable, "The New Message sheet did not close")
        }
        mark("thread \(customer)")
        row.tap()
        let body = messageField()
        for _ in 0..<3 where (body.value(forKey: "hasKeyboardFocus") as? Bool) != true {
            body.tap()
            _ = messages.keyboards.firstMatch.waitForExistence(timeout: 4)
        }
        sleep(1)
    }

    /// The send button pressed on camera, and whatever Messages then does: the simulator has no imagent, so the take
    /// only records the press and a frame 0.4 s and 2 s on (shots sent-*), and the film claims no more than that frame shows.
    private func send(_ tag: String) {
        let button = messages.buttons["sendButton"]
        let at = button.waitForExistence(timeout: 5) ? screenPoint(button.frame.midX, button.frame.midY, in: messages)
            : messages.coordinate(withNormalizedOffset: CGVector(dx: 386.0 / 440, dy: 907.0 / 956))
        mark("send press \(tag)")
        at.press(forDuration: 0.12)
        usleep(400_000)
        shot("sent-\(tag)-a")
        sleep(2)
        shot("sent-\(tag)-b")
        mark("sent \(tag)")
    }

    /// The person's own keyboard up, not the Cutling keyboard Messages reopens on (the one used last).
    private func ownKeyboard() {
        for _ in 0..<4 where cutlingKeyboardIsUp(in: messages) {
            let g = keyboardGlobe(in: messages).coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            mark("own-globe at \(Int(g.screenPoint.x)),\(Int(g.screenPoint.y))")
            g.tap()
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
            let g = keyboardGlobe(in: messages).coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            mark("globe at \(Int(g.screenPoint.x)),\(Int(g.screenPoint.y))")
            g.tap()
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
            func kana(_ names: [String]) -> XCUIElement {
                messages.descendants(matching: .any)
                    .matching(NSPredicate(format: "label IN %@ OR identifier IN %@", names, names)).firstMatch
            }
            // Key centres are read before the first touch, so a kana costs a touch and no lookup; one touch every `slot`.
            let kanaKeys = Set(name == "中村" ? ["な", "か", "ま", "ら"] : ["た", "か", "は", "さ"])
            var centres: [String: XCUICoordinate] = [:]
            for label in kanaKeys {
                let frame = messages.keys[label].frame
                centres[label] = screenPoint(frame.midX, frame.midY, in: messages)
            }
            let convertKey = kana(["空白", "\u{3000}", "space", "Space"]), commitKey = kana(["確定", "Return", "改行", "\n"])
            XCTAssertTrue(convertKey.waitForExistence(timeout: 15) && commitKey.waitForExistence(timeout: 5),
                          "No space or return key (keys: \(messages.keys.allElementsBoundByIndex.map(\.label)), buttons: \(messages.keyboards.buttons.allElementsBoundByIndex.map(\.label)))")
            let convert = convertKey.frame, commit = commitKey.frame
            // Each touch starts at its own place on a fixed clock, so one that runs long (a flick) is made up by the next.
            let start = Date().addingTimeInterval(0.3)
            var index = 0
            func touch(_ what: String, _ at: XCUICoordinate, flick: CGVector? = nil) {
                let rest = start.addingTimeInterval(Double(index) * slot).timeIntervalSinceNow - 0.09   // 0.09 s: the mark comes that long before the touch lands (read from the MARK lines)
                if rest > 0 { usleep(UInt32(rest * 1_000_000)) }
                index += 1
                let p = at.screenPoint
                mark("kana \(what) at \(Int(p.x)),\(Int(p.y))")
                if let flick { at.press(forDuration: 0.05, thenDragTo: at.withOffset(flick), withVelocity: .fast, thenHoldForDuration: 0.05) } else { at.tap() }
            }
            func key(_ label: String, flick: CGVector? = nil) { touch(flick == nil ? label : "\(label) flick", centres[label]!, flick: flick) }
            switch name {
            case "中村": key("な"); key("か"); key("ま", flick: CGVector(dx: 0, dy: -50)); key("ら")
            case "高橋": key("た"); key("か"); key("は"); key("さ", flick: CGVector(dx: -50, dy: 0))
            default: XCTFail("No kana for \(name)")
            }
            touch("convert", screenPoint(convert.midX, convert.midY, in: messages))
            shot("converted")
            touch("commit", screenPoint(commit.midX, commit.midY, in: messages))
        } else {
            // XCUITest's touch costs 0.43 s, more than a key gets at 36.2 words a minute: the points of the keys go to
            // scripts/names-type-helper.py, which touches them with axe at `slot` and logs the MARK lines.
            XCTAssertTrue(messages.keys["a"].waitForExistence(timeout: 10) || messages.keys["A"].waitForExistence(timeout: 2), "No system keyboard")
            let dir = env["NAMES_DIR"] ?? NSTemporaryDirectory()
            let request = "\(dir)/type-request-\(language).json", done = "\(dir)/type-done-\(language)"
            try? FileManager.default.removeItem(atPath: done)
            try? FileManager.default.removeItem(atPath: request)
            let keys: [[String: Any]] = name.map { letter in
                let frame = messages.keys.matching(NSPredicate(format: "label ==[c] %@", String(letter))).firstMatch.frame
                return ["label": String(letter), "x": frame.midX, "y": frame.midY]
            }
            try? JSONSerialization.data(withJSONObject: ["slot": slot, "keys": keys]).write(to: URL(fileURLWithPath: request))
            for _ in 0..<300 where !FileManager.default.fileExists(atPath: done) { usleep(100_000) }
            XCTAssertTrue(FileManager.default.fileExists(atPath: done), "The typing helper did not finish")
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
        try thread(words.typedCustomer)
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
        send("1")
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
            try thread(customer)
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
            sleep(1)
            send(customer)
            sleep(1)
            mark("end \(customer)")
            clearDraft()
        }
    }

    /// Five taps: the guest's name typed first, Hello takes it, Booking asks how many (4), Sign-off leaves the cursor above it.
    func test3Taps() throws {
        seed(kind: "taps", history: "")
        messages.launch()
        sleep(2)
        try thread(words.guest)
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
        sleep(1)
        send("1")
        sleep(1)
        mark("end")
        clearDraft()
    }

    /// The 2.0 film: four customers one after another. Each name is typed on the system keyboard, the order reply takes it for
    /// its first blank and asks Basic or Pro, and the typed reply carries the counter (248 and on), the weekday and the date.
    func test4Reply() throws {
        seed(kind: "reply", history: "")
        messages.launch()
        sleep(2)
        for (index, customer) in ["Maya", "Tom", "Aiko", "Budi"].enumerated() {
            let plan = index % 2 == 0 ? "Pro" : "Basic"
            try thread(customer)
            ownKeyboard()
            sleep(1)
            mark("ready \(customer)")
            typeName(customer)
            mark("typed \(customer)")
            sleep(1)
            cutlingUp(showing: words.order)
            sleep(2)
            press("reply \(customer)", frame(words.order))
            sleep(2)
            let choice = frame(plan)
            shot("asks-\(customer)")
            mark("asks \(customer)")
            sleep(1)
            press("plan \(customer) \(plan)", choice)
            sleep(1)
            if cutlingKeyFrame(words.order, in: messages) == nil { confirm(); sleep(1) }
            shot("filled-\(customer)")
            mark("filled \(customer)")
            sleep(3)
            send(customer)
            sleep(1)
            mark("end \(customer)")
            clearDraft()
        }
    }
}
