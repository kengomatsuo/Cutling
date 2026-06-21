//
//  AddFromClipboardIntent.swift
//  Cutling
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents
#if os(iOS)
import UIKit
#endif

struct AddFromClipboardIntent: AppIntent {
    static var title: LocalizedStringResource = "Add from Clipboard"
    static var description = IntentDescription("Save clipboard contents as a new cutling.")

    // UIPasteboard.general.string returns nil when the intent runs in the
    // lightweight extension environment (Siri / Shortcuts with no UI). Forcing
    // the app foreground is the only reliable way to read the system clipboard.
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        #if os(iOS)
        let store = await CutlingStore.shared

        if let string = UIPasteboard.general.string, !string.isEmpty {
            if await store.findDuplicateText(value: string) != nil {
                return .result(dialog: IntentDialog(stringLiteral: String(localized: "Already saved.")))
            }
            let check = await store.canAdd(.text)
            guard check.allowed else {
                return .result(dialog: IntentDialog(stringLiteral: check.reason ?? String(localized: "Cannot add more text cutlings.")))
            }

            let cutling = Cutling(
                name: String(string.prefix(50)),
                value: String(string.prefix(CutlingStore.maxTextLength)),
                icon: "doc.on.clipboard",
                kind: .text
            )
            await store.add(cutling)
            return .result(dialog: IntentDialog(stringLiteral: String(localized: "Saved!")))
        } else if let image = UIPasteboard.general.image,
                  let data = image.pngData() {
            if await store.findDuplicateImage(data: data) != nil {
                return .result(dialog: IntentDialog(stringLiteral: String(localized: "Already saved.")))
            }
            let check = await store.canAdd(.image)
            guard check.allowed else {
                return .result(dialog: IntentDialog(stringLiteral: check.reason ?? String(localized: "Cannot add more image cutlings.")))
            }

            let id = UUID()
            let cutling = Cutling(
                id: id,
                name: String(localized: "Shared Image"),
                value: "",
                icon: "photo",
                kind: .image
            )

            if let filename = await store.saveImageData(data, for: id) {
                var c = cutling
                c.imageFilename = filename
                await store.add(c)
                return .result(dialog: IntentDialog(stringLiteral: String(localized: "Saved!")))
            }
        }
        #endif

        return .result(dialog: IntentDialog(stringLiteral: String(localized: "Clipboard is empty.")))
    }
}
