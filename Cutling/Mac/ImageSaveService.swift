//
//  ImageSaveService.swift
//  Cutling: writes images either via NSSavePanel (ask each time) or
//  silently into a user-chosen folder remembered as a security-scoped
//  bookmark.
//
//  Why a bookmark and not a hardcoded path: the app is sandboxed, so even
//  with `com.apple.security.files.user-selected.read-write` we only have
//  write access to paths the user actually picked through an
//  NSOpenPanel/NSSavePanel during the current launch. Bookmarks let that
//  permission survive relaunches and folder renames.
//

#if os(macOS)
import AppKit
import UniformTypeIdentifiers

@MainActor
final class ImageSaveService {
    static let shared = ImageSaveService()

    enum Behavior: String {
        case ask
        case autoFolder
    }

    private let behaviorKey = "imageSaveBehavior"
    private let bookmarkKey = "imageSaveFolderBookmark"

    private init() {}

    var behavior: Behavior {
        get {
            Behavior(rawValue: UserDefaults.standard.string(forKey: behaviorKey) ?? "")
                ?? .ask
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: behaviorKey)
        }
    }

    /// Resolved current folder URL, refreshing the stored bookmark if the
    /// system reports it as stale (folder renamed or moved). Returns nil
    /// if no bookmark is stored or it can't be resolved at all.
    var savedFolderURL: URL? {
        guard let data = UserDefaults.standard.data(forKey: bookmarkKey) else { return nil }
        var stale = false
        guard let url = try? URL(
            resolvingBookmarkData: data,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &stale
        ) else {
            return nil
        }
        if stale {
            // Re-encode so the next resolve doesn't trip the same flag.
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                if let refreshed = try? url.bookmarkData(
                    options: [.withSecurityScope],
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                ) {
                    UserDefaults.standard.set(refreshed, forKey: bookmarkKey)
                }
            }
        }
        return url
    }

    /// Display path for the configured folder. Falls back to a placeholder
    /// when no folder is set.
    var savedFolderDisplayPath: String {
        savedFolderURL?.path ?? "—"
    }

    /// Present NSOpenPanel for the user to choose (or change) the
    /// auto-save folder. Defaults the panel to ~/Downloads so the most
    /// common pick is one click away. Returns the chosen URL or nil on
    /// cancel.
    @discardableResult
    func chooseFolder() -> URL? {
        // The picker view is hosted inside a MenuBarExtra or floating
        // panel; promote to .regular before showing a modal panel so the
        // sandboxed open dialog actually appears (LSUIElement constraint).
        AppActivationManager.shared.dismissMenuBarPopover()
        AppActivationManager.shared.prepareToShowWindow()
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = String(localized: "Choose")
        panel.title = String(localized: "Choose Image Folder")
        panel.message = String(localized: "Pick a folder where Cutling will save image cutlings.")
        panel.directoryURL = FileManager.default.urls(
            for: .downloadsDirectory, in: .userDomainMask
        ).first
        panel.level = .modalPanel
        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        guard let data = try? url.bookmarkData(
            options: [.withSecurityScope],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        ) else {
            return nil
        }
        UserDefaults.standard.set(data, forKey: bookmarkKey)
        return url
    }

    func clearFolder() {
        UserDefaults.standard.removeObject(forKey: bookmarkKey)
    }

    /// Save the image data using the current behavior. For `ask`, presents
    /// `NSSavePanel`. For `autoFolder`, writes silently into the saved
    /// folder with a collision-safe filename. Returns the destination URL
    /// or nil if the user cancelled or the write failed.
    @discardableResult
    func save(data: Data, suggestedName: String) -> URL? {
        let nameWithExtension = suggestedName.hasSuffix(".png")
            ? suggestedName
            : suggestedName + ".png"
        switch behavior {
        case .ask:
            return runSavePanel(data: data, suggestedName: nameWithExtension)
        case .autoFolder:
            if let folder = savedFolderURL,
               let url = writeToFolder(folder, data: data, filename: nameWithExtension) {
                return url
            }
            // Bookmark missing or write failed: fall back to the panel so
            // the user always has a path to save.
            return runSavePanel(data: data, suggestedName: nameWithExtension)
        }
    }

    private func runSavePanel(data: Data, suggestedName: String) -> URL? {
        AppActivationManager.shared.dismissMenuBarPopover()
        CutlingPickerController.shared.hide()
        AppActivationManager.shared.prepareToShowWindow()
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.nameFieldStringValue = suggestedName
        panel.title = String(localized: "Save Image")
        panel.level = .modalPanel
        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        do {
            try data.write(to: url)
            return url
        } catch {
            NSSound.beep()
            return nil
        }
    }

    private func writeToFolder(_ folder: URL, data: Data, filename: String) -> URL? {
        guard folder.startAccessingSecurityScopedResource() else { return nil }
        defer { folder.stopAccessingSecurityScopedResource() }
        let target = uniqueURL(in: folder, filename: filename)
        do {
            try data.write(to: target)
            return target
        } catch {
            NSSound.beep()
            return nil
        }
    }

    /// Returns a URL inside `folder` that does not collide with an
    /// existing file. Tries the raw filename first, then `Name-2.png`,
    /// `Name-3.png`, … up to a sanity bound.
    private func uniqueURL(in folder: URL, filename: String) -> URL {
        let fm = FileManager.default
        let initial = folder.appendingPathComponent(filename)
        if !fm.fileExists(atPath: initial.path) { return initial }
        let stem = (filename as NSString).deletingPathExtension
        let ext = (filename as NSString).pathExtension
        for i in 2...999 {
            let candidateName = ext.isEmpty ? "\(stem)-\(i)" : "\(stem)-\(i).\(ext)"
            let url = folder.appendingPathComponent(candidateName)
            if !fm.fileExists(atPath: url.path) { return url }
        }
        return initial
    }
}
#endif
