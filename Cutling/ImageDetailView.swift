//
//  ImageDetailView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

#if os(iOS)
import UIKit
#else
import AppKit
#endif

// MARK: - Transferable wrapper for PhotosPicker

struct PickedImage: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            PickedImage(data: data)
        }
    }
}

// MARK: - Undo Handler

/// A class-based undo handler that intercepts bindings to register undo/redo.
/// Only user-driven changes (through the intercepted binding setter) register undos.
/// Undo/redo-driven changes go through the `apply` closure directly, bypassing the
/// intercepted binding, so they don't re-register and clobber the redo stack.
/// See: https://nilcoalescing.com/blog/HandlingUndoAndRedoInSwiftUI/
class UndoHandler: NSObject {
    weak var undoManager: UndoManager?

    /// Tracks open undo groups per action name so rapid changes coalesce into one undo.
    private var openGroups: Set<String> = []
    private var groupTimers: [String: Timer] = [:]
    private static let coalesceInterval: TimeInterval = 0.5

    /// Returns an intercepted binding that registers undo on every set.
    func binding<T: Equatable>(
        _ source: Binding<T>,
        actionName: String
    ) -> Binding<T> {
        Binding {
            source.wrappedValue
        } set: { [weak self] newValue in
            let oldValue = source.wrappedValue
            source.wrappedValue = newValue
            self?.registerUndo(from: oldValue, to: newValue, actionName: actionName) {
                source.wrappedValue = $0
            }
        }
    }

    func registerUndo<T: Equatable>(
        from oldValue: T,
        to newValue: T,
        actionName: String,
        apply: @escaping (T) -> Void
    ) {
        guard oldValue != newValue, let undoManager else { return }

        let isUndoingOrRedoing = undoManager.isUndoing || undoManager.isRedoing

        // Only open coalescing groups for user-driven changes, not undo/redo.
        if !isUndoingOrRedoing, !openGroups.contains(actionName) {
            undoManager.beginUndoGrouping()
            openGroups.insert(actionName)
        }

        undoManager.registerUndo(withTarget: self) { handler in
            apply(oldValue)
            handler.registerUndo(from: newValue, to: oldValue, actionName: actionName, apply: apply)
        }
        undoManager.setActionName(actionName)

        // Only manage the debounce timer for user-driven changes.
        if !isUndoingOrRedoing {
            groupTimers[actionName]?.invalidate()
            groupTimers[actionName] = Timer.scheduledTimer(withTimeInterval: Self.coalesceInterval, repeats: false) { [weak self] _ in
                self?.closeGroup(actionName: actionName)
            }
        }
    }

    private func closeGroup(actionName: String) {
        guard openGroups.contains(actionName), let undoManager else { return }
        undoManager.endUndoGrouping()
        openGroups.remove(actionName)
        groupTimers.removeValue(forKey: actionName)
    }

    /// Close all open groups immediately (e.g. when the view disappears).
    func closeAllGroups() {
        for actionName in openGroups {
            groupTimers[actionName]?.invalidate()
            undoManager?.endUndoGrouping()
        }
        openGroups.removeAll()
        groupTimers.removeAll()
    }
}

// MARK: - Image Detail View

struct ImageDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.undoManager) var undoManager
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var store: CutlingStore

    let existingItem: Cutling?
    let autoPasteFromClipboard: Bool
    let presentedAsSheet: Bool

    @State private var name: String
    @State private var imageData: Data?
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showFilePicker = false
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""
    @State private var hasClipboardImage = false
    @State private var canPaste = false
    @State private var isPasting = false
    @State private var autoDeleteEnabled: Bool
    @State private var deleteAt: Date
    @State private var undoHandler = UndoHandler()
    
    init(item: Cutling?, autoPasteFromClipboard: Bool = false, presentedAsSheet: Bool = true) {
        self.existingItem = item
        self.autoPasteFromClipboard = autoPasteFromClipboard
        self.presentedAsSheet = presentedAsSheet
        _name = State(initialValue: item?.name ?? "")
        _autoDeleteEnabled = State(initialValue: item?.expiresAt != nil)
        _deleteAt = State(initialValue: item?.expiresAt ?? Date().addingTimeInterval(86400))
    }

    var isEditing: Bool { existingItem != nil }

    var body: some View {
        #if os(macOS)
        if presentedAsSheet {
            NavigationStack {
                formContent
                    .toolbar {
                        compactUndoToolbarContent
                        ToolbarItem(placement: .confirmationAction) {
                            Button {
                                saveCutling()
                            } label: {
                                if #available(macOS 26, *) {
                                    Image(systemName: "checkmark")
                                } else {
                                    Text("Save")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(name.isEmpty || (imageData == nil && existingItem?.imageFilename == nil))
                        }
                    }
            }
            .frame(minWidth: 420, idealWidth: 480, minHeight: 400, idealHeight: 500)
        } else {
            formContent
                .toolbar {
                    undoRedoToolbarContent
                }
                .onDisappear {
                    undoHandler.closeAllGroups()
                    autoSave()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase != .active {
                        autoSave()
                    }
                }
        }
        #else
        if presentedAsSheet {
            NavigationStack {
                formContent
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                dismiss()
                            } label: {
                                if #available(iOS 26, *) {
                                    Image(systemName: "xmark")
                                } else {
                                    Text("Cancel")
                                }
                            }
                        }
                        compactUndoToolbarContent
                        ToolbarItem(placement: .confirmationAction) {
                            if #available(iOS 26, *) {
                                Button {
                                    saveCutling()
                                } label: {
                                    Image(systemName: "checkmark")
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(name.isEmpty || (imageData == nil && existingItem?.imageFilename == nil))
                            } else {
                                Button("Done") {
                                    saveCutling()
                                }
                                .disabled(name.isEmpty || (imageData == nil && existingItem?.imageFilename == nil))
                            }
                        }
                    }
            }
        } else {
            formContent
                .toolbar {
                    undoRedoToolbarContent
                }
                .onWillDisappear {
                    undoHandler.closeAllGroups()
                    autoSave()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase != .active {
                        autoSave()
                    }
                }
        }
        #endif
    }

    // MARK: - Undo/Redo Toolbar

    @ToolbarContentBuilder
    private var compactUndoToolbarContent: some ToolbarContent {
        #if os(iOS)
        ToolbarItem {
            if undoManager?.canRedo == true {
                Menu {
                    Button {
                        undoManager?.undo()
                    } label: {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                    }
                    .disabled(undoManager?.canUndo != true)

                    Button {
                        undoManager?.redo()
                    } label: {
                        Label("Redo", systemImage: "arrow.uturn.forward")
                    }
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                }
            } else {
                Button {
                    undoManager?.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                }
                .disabled(undoManager?.canUndo != true)
            }
        }
        #else
        undoRedoToolbarContent
        #endif
    }

    @ToolbarContentBuilder
    private var undoRedoToolbarContent: some ToolbarContent {
        ToolbarItemGroup {
            Button {
                undoManager?.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            .disabled(undoManager?.canUndo != true)

            Button {
                undoManager?.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward")
            }
            .disabled(undoManager?.canRedo != true)
        }
    }

    // MARK: - Form Content

    private var formContent: some View {
        Form {
            Section("Name") {
                TextField("e.g. Signature, QR Code", text: undoHandler.binding($name, actionName: String(localized: "Change Name")))
            }
            Section("Image") {
                imagePreview
                pickerButtons
                Button {
                    pasteFromClipboard()
                } label: {
                    Label("Paste from Clipboard", systemImage: "doc.on.clipboard")
                }
                .foregroundStyle(.primary)
                .disabled(!canPaste)
            }
            ExpirationPickerSection(autoDeleteEnabled: undoHandler.binding($autoDeleteEnabled, actionName: String(localized: "Change Expiration")), deleteAt: undoHandler.binding($deleteAt, actionName: String(localized: "Change Expiration")))
            if isEditing {
                Section {
                    Button("Delete Cutling", role: .destructive) {
                        if let item = existingItem {
                            store.delete(item)
                        }
                        dismiss()
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .formStyle(.grouped)
        .navigationTitle(isEditing ? "Edit" : "New")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onChange(of: selectedPhoto) {
            Task {
                if let picked = try? await selectedPhoto?.loadTransferable(type: PickedImage.self) {
                    let oldData = imageData
                    imageData = picked.data
                    undoHandler.registerUndo(from: oldData, to: imageData, actionName: String(localized: "Change Image")) { imageData = $0 }
                }
            }
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    let oldData = imageData
                    if let newData = try? Data(contentsOf: url) {
                        imageData = newData
                        undoHandler.registerUndo(from: oldData, to: newData, actionName: String(localized: "Change Image")) { imageData = $0 }
                    }
                }
            }
        }
        .onChange(of: imageData) {
            if isPasting {
                isPasting = false
            } else if hasClipboardImage {
                canPaste = true
            }
        }
        .onAppear {
            if let filename = existingItem?.imageFilename {
                imageData = store.loadImageData(named: filename)
            }
            checkClipboard()
            canPaste = hasClipboardImage

            if autoPasteFromClipboard {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(500))
                    pasteFromClipboard()
                }
            }
        }
        .alert("Limit Reached", isPresented: $showLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(limitAlertMessage)
        }
        .onChange(of: undoManager, initial: true) { _, newValue in
            undoHandler.undoManager = newValue
        }
        .onDisappear {
            undoHandler.closeAllGroups()
            undoManager?.removeAllActions()
        }

    }

    // MARK: - Auto-Save

    private func autoSave() {
        if let existing = existingItem {
            var updated = existing
            if !name.isEmpty { updated.name = name }
            updated.expiresAt = autoDeleteEnabled ? deleteAt : nil

            if let newImageData = imageData,
               newImageData != store.loadImageData(named: existing.imageFilename ?? "") {
                if let oldFilename = existing.imageFilename {
                    store.deleteImageFile(named: oldFilename)
                }
                updated.imageFilename = store.saveImageData(newImageData, for: updated.id)
            }

            store.update(updated)
        } else {
            guard !name.isEmpty, imageData != nil else { return }
            let canAdd = store.canAdd(.image)
            guard canAdd.allowed else { return }

            let id = UUID()
            var cutling = Cutling(
                id: id,
                name: name,
                value: "",
                icon: "photo",
                kind: .image,
                imageFilename: nil,
                expiresAt: autoDeleteEnabled ? deleteAt : nil
            )

            if let imageData {
                cutling.imageFilename = store.saveImageData(imageData, for: id)
            }

            store.add(cutling)
        }
    }

    // MARK: - Image Preview

    @ViewBuilder
    private var imagePreview: some View {
        if let imageData, let img = loadPlatformImage(from: imageData) {
            Image(platformImage: img)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 500)
                .accessibilityLabel(name.isEmpty ? String(localized: "Image preview") : String(localized: "Image preview for \(name)"))
        } else {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.quinary)
                .frame(height: 120)
                .overlay {
                    VStack(spacing: 6) {
                        Image(systemName: "photo.badge.plus")
                            .font(.title2)
                        Text("No image selected")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
                .accessibilityLabel(String(localized: "No image selected"))
        }
    }

    // MARK: - Picker Buttons

    @ViewBuilder
    private var pickerButtons: some View {
        #if os(macOS)
        HStack {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Label("Photos Library", systemImage: "photo.on.rectangle")
            }
            Spacer()
            Button {
                showFilePicker = true
            } label: {
                Label("Choose File", systemImage: "folder")
            }
        }
        #else
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            Label("Choose from Photos", systemImage: "photo.on.rectangle")
        }
        .foregroundStyle(.primary)

        Button {
            showFilePicker = true
        } label: {
            Label("Choose from Files", systemImage: "folder")
        }
        .foregroundStyle(.primary)
        #endif
    }

    // MARK: - Save

    private func saveCutling() {
        if let existing = existingItem {
            var updated = existing
            updated.name = name
            updated.expiresAt = autoDeleteEnabled ? deleteAt : nil

            if let newImageData = imageData {
                if let oldFilename = existing.imageFilename {
                    store.deleteImageFile(named: oldFilename)
                }
                updated.imageFilename = store.saveImageData(newImageData, for: updated.id)
            }

            store.update(updated)
            dismiss()
        } else {
            // Check limit for new cutlings
            let canAdd = store.canAdd(.image)
            if !canAdd.allowed {
                limitAlertMessage = canAdd.reason ?? String(localized: "Cannot add more image cutlings.")
                showLimitAlert = true
                return
            }
            
            let id = UUID()
            var cutling = Cutling(
                id: id,
                name: name,
                value: "",
                icon: "photo",
                kind: .image,
                imageFilename: nil,
                expiresAt: autoDeleteEnabled ? deleteAt : nil
            )

            if let imageData {
                cutling.imageFilename = store.saveImageData(imageData, for: id)
            }

            store.add(cutling)
            dismiss()
        }
    }
    
    // MARK: - Actions
    
    private func checkClipboard() {
        #if os(iOS)
        hasClipboardImage = UIPasteboard.general.hasImages
        #else
        hasClipboardImage = NSPasteboard.general.canReadObject(forClasses: [NSImage.self], options: nil)
        #endif
    }
    
    private func pasteFromClipboard() {
        let oldData = imageData
        var newData: Data?
        #if os(iOS)
        // First try to get raw image data (preserves GIFs, etc.)
        if let data = UIPasteboard.general.data(forPasteboardType: UTType.gif.identifier) {
            newData = data
        } else if let data = UIPasteboard.general.data(forPasteboardType: UTType.png.identifier) {
            newData = data
        } else if let data = UIPasteboard.general.data(forPasteboardType: UTType.jpeg.identifier) {
            newData = data
        } else if let image = UIPasteboard.general.image {
            // Fallback: convert UIImage to PNG or JPEG
            newData = image.pngData() ?? image.jpegData(compressionQuality: 1.0)
        }
        #else
        // macOS: try to get raw data first
        if let data = NSPasteboard.general.data(forType: NSPasteboard.PasteboardType(UTType.gif.identifier)) {
            newData = data
        } else if let data = NSPasteboard.general.data(forType: .png) {
            newData = data
        } else if let data = NSPasteboard.general.data(forType: NSPasteboard.PasteboardType(UTType.jpeg.identifier)) {
            newData = data
        } else if let image = NSPasteboard.general.readObjects(forClasses: [NSImage.self])?.first as? NSImage,
           let tiffData = image.tiffRepresentation,
           let bitmapImage = NSBitmapImageRep(data: tiffData),
           let data = bitmapImage.representation(using: .png, properties: [:]) {
            newData = data
        }
        #endif
        if let newData {
            isPasting = true
            canPaste = false
            imageData = newData
            undoHandler.registerUndo(from: oldData, to: newData, actionName: String(localized: "Change Image")) { imageData = $0 }
        }
    }
}
