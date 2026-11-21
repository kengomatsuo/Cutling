//
//  SetupChecksUITests.swift
//  CutlingUITests
//
//  The setup guide's and What's New sheet's checks beyond the light and dark walk
//  (SetupMockUITests): long and right-to-left languages for clipping, landscape with the
//  keyboard up, and what VoiceOver reads on each page (the accessibility tree is written to
//  $FORMAT_TEST_SHOTS/a11y-<page>.txt).
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import XCTest

final class SetupChecksUITests: SetupMockTestCase {

    @MainActor private func dumpAccessibility(_ app: XCUIApplication, _ name: String) {
        if let dir = ProcessInfo.processInfo.environment["FORMAT_TEST_SHOTS"] {
            try? app.debugDescription.write(to: URL(fileURLWithPath: dir).appendingPathComponent("a11y-\(name).txt"),
                                            atomically: true, encoding: .utf8)
        }
    }

    @MainActor private func freshGuide(_ extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-hasCompletedSetup", "NO", "-setupWelcomeSeen", "NO", "-hasSeenInteractiveTutorial", "YES"] + extra
        app.launch()
        sleep(3)
        return app
    }

    /// Welcome, Add the Keyboard, About Full Access and What's New in a long Latin, a CJK and
    /// a right-to-left language, for clipping.
    @MainActor func testLanguages() throws {
        for lang in ["de", "ja", "ar", "ta"] {
            let langArgs = ["-AppleLanguages", "(\(lang))", "-AppleLocale", lang]
            let app = freshGuide(langArgs)
            shot("\(lang)_welcome")
            app.buttons["continueButton"].firstMatch.tap()
            sleep(2)
            shot("\(lang)_next_page")
            let about = app.buttons["aboutFullAccess"].firstMatch
            if about.waitForExistence(timeout: 3) {
                about.tap()
                sleep(2)
                shot("\(lang)_about_full_access")
            }
            app.terminate()
            let news = XCUIApplication()
            news.launchArguments += ["-WHATSNEW_MOCK", "new", "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES"] + langArgs
            news.launch()
            sleep(4)
            shot("\(lang)_whats_new")
            news.terminate()
        }
    }

    /// Landscape on the pages that matter most: the field with the keyboard up must stay clear
    /// of the button.
    @MainActor func testLandscape() throws {
        XCUIDevice.shared.orientation = .landscapeLeft
        defer { XCUIDevice.shared.orientation = .portrait }
        let app = freshGuide()
        sleep(1)
        shot("landscape_welcome")
        app.buttons["continueButton"].firstMatch.tap()
        sleep(3)
        shot("landscape_second_page")
    }

    /// What VoiceOver reads, page by page, in English.
    @MainActor func testAccessibility() throws {
        let app = freshGuide()
        dumpAccessibility(app, "welcome")
        app.buttons["continueButton"].firstMatch.tap()
        sleep(2)
        dumpAccessibility(app, "second_page")
        app.terminate()
        let news = XCUIApplication()
        news.launchArguments += ["-WHATSNEW_MOCK", "back", "-hasCompletedSetup", "YES", "-hasSeenInteractiveTutorial", "YES"]
        news.launch()
        sleep(4)
        dumpAccessibility(news, "welcome_back")
    }
}
