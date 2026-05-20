//
//  OpenCutlingByIDIntent.swift
//  Cutling
//
//  Primary action when the user taps a Cutling result in Spotlight
//  (or via the entity in Shortcuts). Copies the cutling's contents
//  to the system pasteboard so the user can paste immediately into
//  whichever app they're heading to next. The app still foregrounds
//  (OpenIntent semantics force that), and surfaces a brief "Copied"
//  banner via the shared app group flag.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers
#if os(iOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif

struct OpenCutlingByIDIntent: OpenIntent {
    static var title: LocalizedStringResource = "Copy Cutling"
    static var description = IntentDescription("Copy a cutling's contents to the clipboard.")

    @Parameter(title: "Cutling")
    var target: CutlingAppEntity

    init() {}

    init(target: CutlingAppEntity) {
        self.target = target
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let store = CutlingStore.shared
        guard let cutling = store.cutlings.first(where: { $0.id == target.id }),
              !cutling.isExpired else {
            return .result()
        }

        switch cutling.kind {
        case .text:
            copyText(cutling.value)
        case .image:
            if let filename = cutling.imageFilename,
               let data = store.loadImageData(named: filename) {
                copyImage(data)
            }
        }

        // Flag for the main app to render a "Copied" banner on scene-active.
        UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?
            .set(target.id.uuidString, forKey: "pendingCopiedCutlingID")

        return .result()
    }

    // MARK: - Pasteboard helpers

    private func copyText(_ value: String) {
        #if os(iOS)
        UIPasteboard.general.string = value
        #endif
        #if os(macOS)
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(value, forType: .string)
        #endif
    }

    private func copyImage(_ data: Data) {
        // Detect UTI from the file header without decoding the bitmap —
        // avoids the same memory blowup that bit the keyboard extension.
        let uti: String
        if let source = CGImageSourceCreateWithData(data as CFData, nil),
           let type = CGImageSourceGetType(source) {
            uti = type as String
        } else {
            uti = UTType.png.identifier
        }

        #if os(iOS)
        UIPasteboard.general.setData(data, forPasteboardType: uti)
        #endif
        #if os(macOS)
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setData(data, forType: NSPasteboard.PasteboardType(uti))
        #endif
    }
}
