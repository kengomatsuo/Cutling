//
//  CopyCutlingIntent.swift
//  Cutling
//
//  Silent copy: just writes the cutling's contents to the system pasteboard
//  and returns. Unlike OpenCutlingByIDIntent (which is an OpenIntent and
//  foregrounds the app), this one is used by interactive snippet view
//  buttons where we don't want the jarring app launch on every tap.
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

struct CopyCutlingIntent: AppIntent {
    static var title: LocalizedStringResource = "Copy Cutling"
    static var description = IntentDescription("Copy a cutling's contents to the clipboard.")

    @Parameter(title: "Cutling")
    var target: CutlingAppEntity

    init() {}

    init(target: CutlingAppEntity) {
        self.target = target
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = CutlingStore.shared
        guard let cutling = store.cutlings.first(where: { $0.id == target.id }),
              !cutling.isExpired else {
            return .result(dialog: IntentDialog(stringLiteral: String(localized: "No Cutlings Yet")))
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

        return .result(dialog: IntentDialog(stringLiteral: String(localized: "Copied")))
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
