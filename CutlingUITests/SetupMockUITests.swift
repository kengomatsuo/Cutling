//
//  SetupMockUITests.swift
//  CutlingUITests
//
//  Walks each onboarding direction (A, B, C in Cutling/SetupFlows.swift) and the new What's
//  New and Welcome Back sheets from a fresh install, through Settings and the first insert,
//  and saves a shot at every screen for the owner's pick. One class per direction, so each
//  runs on a fresh install and keeps its own screen recording:
//
//    xcrun simctl uninstall $UDID com.matsuokengo.Cutling; scripts/ui-test.sh SetupMockAUITests
//
//  Shots go to $FORMAT_TEST_SHOTS.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

class SetupMockTestCase: XCTestCase {
    var shotIndex = 0

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    @MainActor func shot(_ name: String) {
        shotIndex += 1
        let file = String(format: "%02d_%@.png", shotIndex, name)
        if let dir = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"] {
            try? XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: dir).appendingPathComponent(file))
        }
    }

    @MainActor func launch(_ direction: String, dark: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-ONBOARDING_MOCK", direction, "-hasSeenInteractiveTutorial", "YES",
                                "-SNAPSHOT_DARK", dark ? "YES" : "NO"]
        app.launch()
        sleep(3)
        return app
    }

    /// From the Settings app on Cutling's page: Keyboards, the Cutling switch, Full Access and
    /// Apple's alert, with a shot of each.
    @MainActor func walkSettings(_ prefix: String) {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        XCTAssertTrue(settings.wait(for: .runningForeground, timeout: 10))
        let keyboards = settings.cells.staticTexts["Keyboards"].firstMatch
        guard keyboards.waitForExistence(timeout: 15) else {
            shot("\(prefix)_settings_no_keyboards_row")
            settings.terminate()
            addCutlingKeyboardInSettings()
            return
        }
        sleep(1)
        shot("\(prefix)_settings_cutling_page")
        keyboards.tap()
        sleep(2)
        let cutling = settings.switches.matching(NSPredicate(format: "label CONTAINS[c] 'Cutling'")).firstMatch
        if cutling.waitForExistence(timeout: 5), cutling.value as? String == "0" {
            cutling.switches.firstMatch.tap()
            sleep(1)
        }
        shot("\(prefix)_settings_keyboards")
        let fullAccess = settings.switches.matching(NSPredicate(format: "label CONTAINS[c] 'Full Access'")).firstMatch
        if fullAccess.waitForExistence(timeout: 3), fullAccess.value as? String == "0" {
            fullAccess.switches.firstMatch.tap()
            sleep(1)
            shot("\(prefix)_settings_full_access_alert")
            let allow = settings.alerts.buttons["Allow"].firstMatch
            if allow.waitForExistence(timeout: 3) { allow.tap() }
            sleep(1)
        }
    }

    /// With the try field focused: switch to Cutling with the globe and tap the starter cutling.
    @MainActor func typeStarterCutling(_ app: XCUIApplication, _ prefix: String) {
        _ = app.keyboards.firstMatch.waitForExistence(timeout: 15)
        sleep(1)
        shot("\(prefix)_try_system_keyboard")
        switchToCutlingKeyboard(in: app, showing: "Try Me")
        sleep(2)
        shot("\(prefix)_try_cutling_keyboard")
        if let frame = cutlingKeyFrame("Try Me", in: app) {
            screenPoint(frame.midX, frame.midY, in: app).tap()
        }
        sleep(2)
        shot("\(prefix)_try_worked")
    }
}

final class SetupMockAUITests: SetupMockTestCase {
    @MainActor func testDirectionA() throws { try walkA(dark: false) }
}

final class SetupMockADarkUITests: SetupMockTestCase {
    @MainActor func testDirectionADark() throws { try walkA(dark: true) }
}

extension SetupMockTestCase {
    @MainActor func walkA(dark: Bool) throws {
        let app = launch("A", dark: dark)
        shot("A_welcome")
        app.buttons["sheetPrimaryButton"].firstMatch.tap()
        sleep(2)
        shot("A_add_keyboard")
        sleep(10)
        shot("A_add_keyboard_video_later")
        let about = app.buttons["About Full Access"].firstMatch
        if about.waitForExistence(timeout: 3) {
            about.tap()
            sleep(2)
            shot("A_about_full_access")
            app.buttons["sheetPrimaryButton"].firstMatch.tap()
            sleep(1)
        }
        app.buttons["Open Settings"].firstMatch.tap()
        walkSettings("A")
        app.activate()
        sleep(3)
        shot("A_back_from_settings")
        typeStarterCutling(app, "A")
        app.buttons["setupNext"].firstMatch.tap()
        sleep(2)
        shot("A_what_you_can_do")
        let page = app.descendants(matching: .any).matching(identifier: "howToUsePage").firstMatch
        for _ in 0..<4 { page.swipeUp(); usleep(400_000) }
        sleep(2)
        app.buttons["continueButton"].firstMatch.tap()
        sleep(2)
        shot("A_icloud")
        app.buttons["continueButton"].firstMatch.tap()
        sleep(2)
        shot("A_all_set")
        app.buttons["continueButton"].firstMatch.tap()
        sleep(2)
        shot("A_grid")
    }
}

final class SetupMockBUITests: SetupMockTestCase {
    @MainActor func testDirectionB() throws {
        let app = launch("B")
        shot("B_grid_with_card")
        let info = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Full Access'")).firstMatch
        if info.waitForExistence(timeout: 3) {
            info.tap()
            sleep(2)
            shot("B_about_full_access")
            app.buttons["sheetPrimaryButton"].firstMatch.tap()
            sleep(1)
        }
        app.buttons["Open"].firstMatch.tap()
        walkSettings("B")
        app.activate()
        sleep(3)
        shot("B_back_from_settings")
        app.buttons["Try"].firstMatch.tap()
        sleep(2)
        typeStarterCutling(app, "B")
        app.buttons["Done"].firstMatch.tap()
        sleep(2)
        shot("B_grid_done")
    }
}

final class SetupMockCUITests: SetupMockTestCase {
    @MainActor func testDirectionC() throws {
        let app = launch("C")
        shot("C_checklist")
        let info = app.buttons["About Full Access"].firstMatch
        if info.waitForExistence(timeout: 3) {
            info.tap()
            sleep(2)
            shot("C_about_full_access")
            app.buttons["sheetPrimaryButton"].firstMatch.tap()
            sleep(1)
        }
        app.buttons["Open Settings"].firstMatch.tap()
        walkSettings("C")
        app.activate()
        sleep(3)
        shot("C_back_from_settings")
        let field = app.textFields["setupTryField"].firstMatch
        if field.waitForExistence(timeout: 5), !app.keyboards.firstMatch.exists { field.tap() }
        typeStarterCutling(app, "C")
        app.buttons["setupDone"].firstMatch.tap()
        sleep(2)
        shot("C_grid")
    }
}

final class WhatsNewMockUITests: SetupMockTestCase {
    @MainActor func testSheets() throws {
        for (kind, dark) in [("new", false), ("new", true), ("back", false), ("back", true)] {
            let app = XCUIApplication()
            app.launchArguments += ["-WHATSNEW_MOCK", kind, "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES",
                                    "-SNAPSHOT_DARK", dark ? "YES" : "NO"]
            app.launch()
            sleep(4)
            shot("whatsnew_\(kind)_\(dark ? "dark" : "light")")
            app.terminate()
        }
    }
}
