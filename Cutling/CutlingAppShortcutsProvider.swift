//
//  CutlingAppShortcutsProvider.swift
//  Cutling
//
//  Registers Cutling's App Shortcuts. These appear in the Shortcuts
//  app gallery under "Cutling", in Spotlight as suggested actions,
//  and as recognised Siri phrases — all without user setup.
//
//  Constraints baked into the implementation:
//  - Hard cap of 10 shortcuts per app.
//  - Every phrase must contain `\(.applicationName)`.
//  - One @Parameter placeholder per phrase (Xcode 16.3+ limit).
//  - systemImageName must be an SF Symbol.
//
//  Order matters — this is the order they show in the Shortcuts gallery.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents

struct CutlingAppShortcutsProvider: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        // 1. Save Clipboard — the core action: capture whatever's on the pasteboard
        AppShortcut(
            intent: AddFromClipboardIntent(),
            phrases: [
                "Save clipboard to \(.applicationName)",
                "Save to \(.applicationName)",
                "Add clipboard to \(.applicationName)",
                "Clip with \(.applicationName)",
            ],
            shortTitle: "Add from Clipboard",
            systemImageName: "doc.on.clipboard"
        )

        // 2. Copy Cutling — pick a saved cutling, copies it to the pasteboard
        AppShortcut(
            intent: OpenCutlingByIDIntent(),
            phrases: [
                "Copy \(\.$target) from \(.applicationName)",
                "Paste \(\.$target) with \(.applicationName)",
                "Get \(\.$target) from \(.applicationName)",
            ],
            shortTitle: "Copy Cutling",
            systemImageName: "doc.on.doc"
        )

        // 3. Save Text — composable: accepts text from any prior Shortcut action.
        // Note: String parameters can't be inlined into phrases (AppEntity/AppEnum only),
        // so Siri will prompt for the text after matching one of these triggers.
        AppShortcut(
            intent: SaveTextToCutlingIntent(),
            phrases: [
                "Save text to \(.applicationName)",
                "Save text with \(.applicationName)",
                "Add text to \(.applicationName)",
            ],
            shortTitle: "Save Text",
            systemImageName: "square.and.arrow.down"
        )

        // 4. Get Cutling Text — returns a string for downstream actions
        AppShortcut(
            intent: GetCutlingTextIntent(),
            phrases: [
                "Get text of \(\.$target) from \(.applicationName)",
                "Read \(\.$target) from \(.applicationName)",
            ],
            shortTitle: "Get Cutling Text",
            systemImageName: "text.quote"
        )

        // 5. Latest Cutling — quick "what did I just save?" lookup
        AppShortcut(
            intent: GetLatestCutlingTextIntent(),
            phrases: [
                "Get latest from \(.applicationName)",
                "Latest \(.applicationName)",
                "Most recent \(.applicationName)",
            ],
            shortTitle: "Latest Cutling",
            systemImageName: "clock.arrow.circlepath"
        )

        // 6. New Text Cutling — opens app at the text-entry screen
        AppShortcut(
            intent: OpenNewTextCutlingIntent(),
            phrases: [
                "New text in \(.applicationName)",
                "Create text in \(.applicationName)",
                "New text cutling with \(.applicationName)",
            ],
            shortTitle: "New Text Cutling",
            systemImageName: "square.and.pencil"
        )

        // 7. New Image Cutling — opens app at the image-entry screen
        AppShortcut(
            intent: OpenNewImageCutlingIntent(),
            phrases: [
                "New image in \(.applicationName)",
                "Create image in \(.applicationName)",
                "New image cutling with \(.applicationName)",
            ],
            shortTitle: "New Image Cutling",
            systemImageName: "photo.badge.plus"
        )

        // 8. Save Image — accepts an image file from prior Shortcut action.
        // IntentFile params can't be inlined into phrases; Siri will prompt for the image.
        AppShortcut(
            intent: SaveImageToCutlingIntent(),
            phrases: [
                "Save image to \(.applicationName)",
                "Save image with \(.applicationName)",
                "Add image to \(.applicationName)",
            ],
            shortTitle: "Save Image",
            systemImageName: "photo.on.rectangle.angled"
        )

        // 9. Search Cutlings — returns an array for chaining.
        // String params can't be inlined into phrases; Siri will prompt for the query.
        AppShortcut(
            intent: SearchCutlingsIntent(),
            phrases: [
                "Search \(.applicationName)",
                "Find in \(.applicationName)",
                "Search in \(.applicationName)",
            ],
            shortTitle: "Search Cutlings",
            systemImageName: "magnifyingglass"
        )

        // 10. Open Cutling — just open the app, last-resort default match
        AppShortcut(
            intent: OpenCutlingAppIntent(),
            phrases: [
                "Open \(.applicationName)",
                "Launch \(.applicationName)",
            ],
            shortTitle: "Open Cutling",
            systemImageName: "scissors"
        )
    }
}
