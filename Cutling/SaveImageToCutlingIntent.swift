//
//  SaveImageToCutlingIntent.swift
//  Cutling
//
//  Save a file (image) parameter as a new image cutling. Lets users
//  chain "Take Screenshot → Save to Cutling" or "Latest Photo → Save
//  to Cutling" entirely from Shortcuts.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import AppIntents
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

struct SaveImageToCutlingIntent: AppIntent {
    static var title: LocalizedStringResource = "Save Image"
    static var description = IntentDescription("Save an image as a new cutling.")

    @Parameter(title: "Image", supportedContentTypes: [.image])
    var image: IntentFile

    init() {}

    init(image: IntentFile) {
        self.image = image
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let store = CutlingStore.shared
        let data = image.data

        guard CGImageSourceCreateWithData(data as CFData, nil) != nil else {
            return .result(dialog: IntentDialog(stringLiteral: String(localized: "That doesn't look like an image.")))
        }

        if store.findDuplicateImage(data: data) != nil {
            return .result(dialog: IntentDialog(stringLiteral: String(localized: "Already saved.")))
        }

        let check = store.canAdd(.image)
        guard check.allowed else {
            return .result(dialog: IntentDialog(stringLiteral: check.reason ?? String(localized: "Cannot add more image cutlings.")))
        }

        let id = UUID()
        let trimmedName = (image.filename as NSString).deletingPathExtension
        let name = trimmedName.isEmpty ? String(localized: "Shared Image") : trimmedName

        var cutling = Cutling(
            id: id,
            name: name,
            value: "",
            icon: "photo",
            kind: .image
        )

        guard let filename = store.saveImageData(data, for: id) else {
            return .result(dialog: IntentDialog(stringLiteral: String(localized: "Failed to save image.")))
        }
        cutling.imageFilename = filename
        store.add(cutling)

        return .result(dialog: IntentDialog(stringLiteral: String(localized: "Saved!")))
    }
}
