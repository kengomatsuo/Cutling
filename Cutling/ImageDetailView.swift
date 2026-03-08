//
//  ImageDetailView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
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

// MARK: - Image Detail View

struct ImageDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: CutlingStore

    let existingItem: Cutling?
    let autoPasteFromClipboard: Bool

    @State private var name: String
    @State private var imageData: Data?
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showFilePicker = false
    @State private var showDeleteAlert = false
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""
    @State private var hasClipboardImage = false
    @State private var autoDeleteEnabled: Bool
    @State private var deleteAt: Date
    
    init(item: Cutling?, autoPasteFromClipboard: Bool = false) {
        self.existingItem = item
        self.autoPasteFromClipboard = autoPasteFromClipboard
        _name = State(initialValue: item?.name ?? "")
        _autoDeleteEnabled = State(initialValue: item?.expiresAt != nil)
        _deleteAt = State(initialValue: item?.expiresAt ?? Date().addingTimeInterval(86400))
    }

    var isEditing: Bool { existingItem != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Signature, QR Code", text: $name)
                }
                Section("Image") {
                    imagePreview
                    pickerButtons
                }
                ExpirationPickerSection(autoDeleteEnabled: $autoDeleteEnabled, deleteAt: $deleteAt)
                if hasClipboardImage {
                    Section {
                        Button {
                            pasteFromClipboard()
                        } label: {
                            Label("Paste from Clipboard", systemImage: "doc.on.clipboard")
                        }
                        .foregroundStyle(.primary)
                    } header: {
                        Text("Quick Actions")
                    } footer: {
                        Text("This will replace the current image with whatever is in your clipboard.")
                    }
                }
                if isEditing {
                    Section {
                        Button("Delete Cutling", role: .destructive) {
                            showDeleteAlert = true
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .alert("Delete Cutling?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let item = existingItem {
                        store.delete(item)
                    }
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
            .navigationTitle(isEditing ? "Edit Image" : "New Image")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        #if os(macOS)
                        Text("Cancel")
                        #elseif os(iOS)
                        if #available(iOS 26, *) {
                            Image(systemName: "xmark")
                        } else {
                            Text("Cancel")
                        }
                        #endif
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveCutling()
                    } label: {
                        #if os(macOS)
                        Text("Save")
                        #elseif os(iOS)
                        if #available(iOS 26, *) {
                            Image(systemName: "checkmark")
                        } else {
                            Text("Save")
                        }
                        #endif
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty || (imageData == nil && existingItem?.imageFilename == nil))
                }
            }
            .onChange(of: selectedPhoto) {
                Task {
                    if let picked = try? await selectedPhoto?.loadTransferable(type: PickedImage.self) {
                        imageData = picked.data
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
                        imageData = try? Data(contentsOf: url)
                    }
                }
            }
            .onAppear {
                if let filename = existingItem?.imageFilename {
                    imageData = store.loadImageData(named: filename)
                }
                checkClipboard()
                
                if autoPasteFromClipboard {
                    // Delay paste so the sheet is fully presented before iOS
                    // shows the paste-permission prompt. Without this delay the
                    // prompt is suppressed during the sheet transition animation
                    // and the paste silently fails on the first attempt.
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(500))
                        print("Auto Paste Called!")
                        pasteFromClipboard()
                    }
                }
            }
            .alert("Limit Reached", isPresented: $showLimitAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(limitAlertMessage)
            }
        }
        #if os(macOS)
        .frame(minWidth: 420, idealWidth: 480, minHeight: 400, idealHeight: 500)
        #endif
    }

    // MARK: - Image Preview

    @ViewBuilder
    private var imagePreview: some View {
        if let imageData, let img = loadPlatformImage(from: imageData) {
            Image(platformImage: img)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .frame(maxWidth: .infinity)
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
                limitAlertMessage = canAdd.reason ?? "Cannot add more image cutlings."
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
        #if os(iOS)
        // First try to get raw image data (preserves GIFs, etc.)
        if let data = UIPasteboard.general.data(forPasteboardType: UTType.gif.identifier) {
            imageData = data
        } else if let data = UIPasteboard.general.data(forPasteboardType: UTType.png.identifier) {
            imageData = data
        } else if let data = UIPasteboard.general.data(forPasteboardType: UTType.jpeg.identifier) {
            imageData = data
        } else if let image = UIPasteboard.general.image {
            // Fallback: convert UIImage to PNG or JPEG
            if let data = image.pngData() {
                imageData = data
            } else if let data = image.jpegData(compressionQuality: 1.0) {
                imageData = data
            }
        }
        #else
        // macOS: try to get raw data first
        if let data = NSPasteboard.general.data(forType: NSPasteboard.PasteboardType(UTType.gif.identifier)) {
            imageData = data
        } else if let data = NSPasteboard.general.data(forType: .png) {
            imageData = data
        } else if let data = NSPasteboard.general.data(forType: NSPasteboard.PasteboardType(UTType.jpeg.identifier)) {
            imageData = data
        } else if let image = NSPasteboard.general.readObjects(forClasses: [NSImage.self])?.first as? NSImage,
           let tiffData = image.tiffRepresentation,
           let bitmapImage = NSBitmapImageRep(data: tiffData),
           let data = bitmapImage.representation(using: .png, properties: [:]) {
            imageData = data
        }
        #endif
    }
}
