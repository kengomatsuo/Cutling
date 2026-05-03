import SwiftUI
import UniformTypeIdentifiers
import UIKit

enum SharedContentType {
    case text(String)
    case url(URL)
    case image(Data)
}

struct ShareView: View {
    let extensionContext: NSExtensionContext
    let dismiss: () -> Void

    @State private var name = ""
    @State private var icon = "document"
    @State private var color: String?
    @State private var autoDeleteEnabled = false
    @State private var deleteAt = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var inputTypeTriggers: Set<String> = []
    @State private var autoDetectedCategories: Set<InputTypeCategory> = []
    @State private var showIconPicker = false

    @State private var content: SharedContentType?
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""

    private let store = CutlingStore.shared

    private var saveDisabled: Bool {
        switch content {
        case .text(let text):
            return name.isEmpty || text.isEmpty || isSaving
        case .url:
            return name.isEmpty || isSaving
        case .image(let data):
            return name.isEmpty || data.isEmpty || isSaving
        case .none:
            return true
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    Form {}
                        .formStyle(.grouped)
                        .overlay { ProgressView() }
                } else if let errorMessage {
                    Form {}
                        .formStyle(.grouped)
                        .overlay {
                            ContentUnavailableView(
                                errorMessage,
                                systemImage: "exclamationmark.triangle"
                            )
                        }
                } else {
                    formContent
                }
            }
            .tint(Cutling.defaultTint)
            .navigationTitle(String(localized: "Cutling"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        extensionContext.cancelRequest(withError: NSError(
                            domain: NSCocoaErrorDomain,
                            code: NSUserCancelledError
                        ))
                    } label: {
                        if #available(iOS 26, *) {
                            Image(systemName: "xmark")
                        } else {
                            Text("Cancel")
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26, *) {
                        Button {
                            save()
                        } label: {
                            Image(systemName: "checkmark")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Cutling.defaultTint)
                        .disabled(saveDisabled)
                    } else {
                        Button("Done") {
                            save()
                        }
                        .disabled(saveDisabled)
                    }
                }
            }
        }
        .task {
            await extractSharedContent()
        }
        .alert("Limit Reached", isPresented: $showLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(limitAlertMessage)
        }
    }

    // MARK: - Form Content

    @ViewBuilder
    private var formContent: some View {
        Form {
            Section("Name") {
                switch content {
                case .text, .url, .none:
                    TextField(String(localized: "e.g. Email"), text: $name)
                case .image:
                    TextField(String(localized: "e.g. Signature, QR Code"), text: $name)
                }
            }

            if case .text = content {
                Section("Icon") {
                    Button {
                        showIconPicker = true
                    } label: {
                        HStack {
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundStyle(.tint)
                                .frame(width: 36, height: 36)
                            Text("Change Icon")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }

            switch content {
            case .text(let text):
                Section {
                    Text(text)
                        .frame(minHeight: 120, maxHeight: 650, alignment: .topLeading)
                } header: {
                    Text("Text")
                } footer: {
                    Text("\(text.count) / \(CutlingStore.maxTextLength)")
                        .foregroundStyle(text.count > CutlingStore.maxTextLength - 500 ? .orange : .secondary)
                        .font(.caption)
                }

            case .url(let url):
                Section("Text") {
                    Text(url.absoluteString)
                        .frame(minHeight: 60, alignment: .topLeading)
                }

            case .image(let data):
                Section("Image") {
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 500)
                    }
                }

            case .none:
                EmptyView()
            }

            if case .text = content {
                ColorPaletteSection(selectedColor: $color)
                InputTypePickerSection(selectedTriggers: $inputTypeTriggers, autoDetectedCategories: $autoDetectedCategories)
            }

            ExpirationPickerSection(autoDeleteEnabled: $autoDeleteEnabled, deleteAt: $deleteAt)
        }
        .scrollDismissesKeyboard(.interactively)
        .formStyle(.grouped)
        .sheet(isPresented: $showIconPicker) {
            IconPickerView(selectedIcon: $icon)
        }
    }

    // MARK: - Content Extraction

    private func extractSharedContent() async {
        guard let items = extensionContext.inputItems as? [NSExtensionItem] else {
            errorMessage = String(localized: "No content to save.")
            isLoading = false
            return
        }

        for item in items {
            guard let attachments = item.attachments else { continue }

            for provider in attachments {
                if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    if let result = try? await provider.loadItem(forTypeIdentifier: UTType.image.identifier),
                       let imageData = imageData(from: result) {
                        content = .image(imageData)
                        icon = "photo"
                        if name.isEmpty { name = String(localized: "Shared Image") }
                        isLoading = false
                        return
                    }
                }

                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    if let result = try? await provider.loadItem(forTypeIdentifier: UTType.url.identifier),
                       let url = result as? URL, !url.isFileURL {
                        content = .url(url)
                        icon = "link"
                        if name.isEmpty { name = String(localized: "Shared URL") }
                        isLoading = false
                        return
                    }
                }

                if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    if let result = try? await provider.loadItem(forTypeIdentifier: UTType.plainText.identifier),
                       let text = result as? String {
                        content = .text(text)
                        if name.isEmpty {
                            name = String(text.prefix(40)).components(separatedBy: .newlines).first ?? String(localized: "Shared Text")
                        }
                        let detected = InputTypeCategory.detect(from: text)
                        if !detected.isEmpty {
                            inputTypeTriggers = Set(detected.flatMap { $0.triggerKeys })
                            autoDetectedCategories = detected
                        }
                        isLoading = false
                        return
                    }
                }
            }
        }

        errorMessage = String(localized: "No content to save.")
        isLoading = false
    }

    private func imageData(from item: NSSecureCoding) -> Data? {
        if let url = item as? URL {
            return try? Data(contentsOf: url)
        }
        if let image = item as? UIImage {
            return image.pngData()
        }
        if let data = item as? Data {
            return data
        }
        return nil
    }

    // MARK: - Save

    private func save() {
        guard let content else { return }
        isSaving = true

        switch content {
        case .text(let text):
            let canAdd = store.canAdd(.text)
            guard canAdd.allowed else {
                limitAlertMessage = canAdd.reason ?? String(localized: "Cannot add more text cutlings.")
                showLimitAlert = true
                isSaving = false
                return
            }
            if store.isTextTooLong(text) {
                limitAlertMessage = String(localized: "Text exceeds the maximum length of \(CutlingStore.maxTextLength) characters.")
                showLimitAlert = true
                isSaving = false
                return
            }
            store.add(Cutling(
                name: name,
                value: text,
                icon: icon,
                kind: .text,
                expiresAt: autoDeleteEnabled ? deleteAt : nil,
                color: color,
                inputTypeTriggers: inputTypeTriggers.isEmpty ? nil : Array(inputTypeTriggers)
            ))

        case .url(let url):
            let canAdd = store.canAdd(.text)
            guard canAdd.allowed else {
                limitAlertMessage = canAdd.reason ?? String(localized: "Cannot add more text cutlings.")
                showLimitAlert = true
                isSaving = false
                return
            }
            store.add(Cutling(
                name: name,
                value: url.absoluteString,
                icon: icon,
                kind: .text,
                expiresAt: autoDeleteEnabled ? deleteAt : nil,
                color: color
            ))

        case .image(let data):
            let canAdd = store.canAdd(.image)
            guard canAdd.allowed else {
                limitAlertMessage = canAdd.reason ?? String(localized: "Cannot add more image cutlings.")
                showLimitAlert = true
                isSaving = false
                return
            }
            if let existing = store.findDuplicateImage(data: data) {
                limitAlertMessage = String(localized: "This image already exists as \"\(existing.name)\".")
                showLimitAlert = true
                isSaving = false
                return
            }
            let id = UUID()
            guard let filename = store.saveImageData(data, for: id) else {
                limitAlertMessage = String(localized: "Failed to save image.")
                showLimitAlert = true
                isSaving = false
                return
            }
            store.add(Cutling(
                id: id,
                name: name,
                value: "",
                icon: "photo",
                kind: .image,
                imageFilename: filename,
                expiresAt: autoDeleteEnabled ? deleteAt : nil
            ))
        }

        dismiss()
    }
}
