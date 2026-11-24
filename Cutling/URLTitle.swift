//
//  URLTitle.swift
//  Cutling
//
//  A web link's page title, fetched to name a cutling saved from a link. Kept out of the files the keyboard compiles:
//  importing LinkPresentation links it into a target, and a linked LinkPresentation loads WebKit, MapKit, AVKit,
//  QuickLook, Contacts and Photos into the process at start, which held the keyboard's cold launch while the person
//  waited on the globe menu. The app and the share and action extensions, which name cutlings from links, compile it.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import Foundation
import LinkPresentation

extension InputTypeCategory {
    static func fetchURLTitle(from text: String) async -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return nil }
        let range = NSRange(trimmed.startIndex..., in: trimmed)
        guard let match = detector.firstMatch(in: trimmed, range: range),
              let url = match.url,
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme) else { return nil }
        let provider = LPMetadataProvider()
        provider.shouldFetchSubresources = false
        provider.timeout = 5
        guard let metadata = try? await provider.startFetchingMetadata(for: url),
              let title = metadata.title, !title.isEmpty else { return nil }
        return title
    }
}
