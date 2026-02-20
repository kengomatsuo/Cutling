//
//  ImageDetailView.swift
//  Tine
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
    @EnvironmentObject var store: SnippetStore

    let existingItem: Snippet?

    @State private var name: String
    @State private var imageData: Data?
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showFilePicker = false

    init(item: Snippet?) {
        self.existingItem = item
        _name = State(initialValue: item?.name ?? "")
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
                if isEditing {
                    Section {
                        Button("Delete Snippet", role: .destructive) {
                            if let item = existingItem {
                                store.delete(item)
                            }
                            dismiss()
                        }
                    }
                }
            }
            .formStyle(.grouped)
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
                        #else
                        Image(systemName: "xmark")
                        #endif
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveSnippet()
                    } label: {
                        #if os(macOS)
                        Text("Save")
                        #else
                        Image(systemName: "checkmark")
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
                .fill(.quaternary)
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

    private func saveSnippet() {
        if let existing = existingItem {
            var updated = existing
            updated.name = name

            if let newImageData = imageData {
                if let oldFilename = existing.imageFilename {
                    store.deleteImageFile(named: oldFilename)
                }
                updated.imageFilename = store.saveImageData(newImageData, for: updated.id)
            }

            store.update(updated)
        } else {
            let id = UUID()
            var snippet = Snippet(
                id: id,
                name: name,
                value: "",
                icon: "photo",
                kind: .image,
                imageFilename: nil
            )

            if let imageData {
                snippet.imageFilename = store.saveImageData(imageData, for: id)
            }

            store.add(snippet)
        }
        dismiss()
    }
}
