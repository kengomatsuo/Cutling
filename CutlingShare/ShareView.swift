import SwiftUI
import UniformTypeIdentifiers
import UIKit

enum SharedContentType {
    case text(String)
    case url(URL)
    case image(Data)
}

struct SharedItem: Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var color: Color = Cutling.defaultTint
    var content: SharedContentType
    var inputTypeTriggers: Set<String> = []
    var autoDetectedCategories: Set<InputTypeCategory> = []
    var autoDeleteEnabled = false
    var deleteAt = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    var needsTitleFetch = false
}

struct ShareView: View {
    let extensionContext: NSExtensionContext
    let dismiss: () -> Void

    @State private var items: [SharedItem] = []
    @State private var showIconPicker = false

    @State private var isLoading = true
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""

    private let store = CutlingStore.shared

    private var saveDisabled: Bool {
        if items.isEmpty || isSaving { return true }
        if items.count == 1 {
            let item = items[0]
            switch item.content {
            case .text(let text):
                return item.name.isEmpty || text.isEmpty
            case .url:
                return item.name.isEmpty
            case .image(let data):
                return item.name.isEmpty || data.isEmpty
            }
        }
        return items.contains { $0.name.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    Form {}
                        .formStyle(.grouped)
                        .overlay { ProgressView().tint(.secondary) }
                } else if let errorMessage {
                    Form {}
                        .formStyle(.grouped)
                        .overlay {
                            ContentUnavailableView(
                                errorMessage,
                                systemImage: "exclamationmark.triangle"
                            )
                        }
                } else if items.count == 1 {
                    singleItemFormContent
                } else {
                    multiItemFormContent
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

    // MARK: - Single Item Form

    @ViewBuilder
    private var singleItemFormContent: some View {
        let item = items[0]
        Form {
            Section("Name") {
                switch item.content {
                case .text, .url:
                    TextField(String(localized: "e.g. Email"), text: $items[0].name)
                case .image:
                    TextField(String(localized: "e.g. Signature, QR Code"), text: $items[0].name)
                }
            }

            switch item.content {
            case .text, .url:
                iconAndColorSection(for: 0)
            case .image:
                EmptyView()
            }

            switch item.content {
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
            }

            switch item.content {
            case .text, .url:
                InputTypePickerSection(selectedTriggers: $items[0].inputTypeTriggers, autoDetectedCategories: $items[0].autoDetectedCategories)
            default:
                EmptyView()
            }

            ExpirationPickerSection(autoDeleteEnabled: $items[0].autoDeleteEnabled, deleteAt: $items[0].deleteAt)
        }
        .scrollDismissesKeyboard(.interactively)
        .formStyle(.grouped)
        .sheet(isPresented: $showIconPicker) {
            IconPickerView(selectedIcon: $items[0].icon)
        }
    }

    private func iconAndColorSection(for index: Int) -> some View {
        Section("Icon") {
            Button {
                showIconPicker = true
            } label: {
                HStack {
                    Image(systemName: items[index].icon)
                        .font(.title2)
                        .foregroundStyle(items[index].color)
                        .frame(width: 36, height: 36)
                    Text("Change Icon")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .foregroundStyle(.primary)

            HStack {
                Text("Color")
                Spacer()
                if items[index].color != Cutling.defaultTint {
                    Button {
                        withAccessibleAnimation(.easeInOut(duration: 0.2)) {
                            items[index].color = Cutling.defaultTint
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.subheadline)
                    }
                    .buttonStyle(.borderless)
                }
                ColorPicker("", selection: $items[index].color, supportsOpacity: false)
                    .labelsHidden()
            }
        }
    }

    // MARK: - Multi Item Form

    @ViewBuilder
    private var multiItemFormContent: some View {
        Form {
            Section {
                ForEach($items) { $item in
                    NavigationLink {
                        SharedItemDetailView(item: $item)
                    } label: {
                        SharedItemRow(item: item)
                    }
                }
                .onDelete { indexSet in
                    guard items.count > 1 else { return }
                    items.remove(atOffsets: indexSet)
                }
            } header: {
                Text("\(items.count) items")
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .formStyle(.grouped)
    }

    // MARK: - Content Extraction

    private func extractSharedContent() async {
        guard let extensionItems = extensionContext.inputItems as? [NSExtensionItem] else {
            errorMessage = String(localized: "No content to save.")
            isLoading = false
            return
        }

        var extracted: [SharedItem] = []

        for item in extensionItems {
            guard let attachments = item.attachments else { continue }
            // Only use the parent item's title when there's a single attachment.
            // Share extensions bundle multiple attachments under one NSExtensionItem,
            // so using the shared title would give every item the same name.
            let itemTitle = attachments.count == 1
                ? (item.attributedTitle?.string ?? item.attributedContentText?.string)
                : nil

            for provider in attachments {
                let providerName = provider.suggestedName
                let title = providerName ?? itemTitle

                if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    if let result = try? await provider.loadItem(forTypeIdentifier: UTType.image.identifier),
                       let data = imageData(from: result) {
                        extracted.append(SharedItem(
                            name: title ?? String(localized: "Shared Image"),
                            icon: "photo",
                            content: .image(data)
                        ))
                        continue
                    }
                }

                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    if let result = try? await provider.loadItem(forTypeIdentifier: UTType.url.identifier),
                       let url = result as? URL, !url.isFileURL {
                        let suggestion = InputTypeCategory.suggest(from: url.absoluteString, defaultIcon: "link", defaultName: String(localized: "Shared URL"))
                        extracted.append(SharedItem(
                            name: title ?? suggestion.name,
                            icon: suggestion.icon,
                            content: .url(url),
                            inputTypeTriggers: suggestion.triggers,
                            autoDetectedCategories: suggestion.categories,
                            needsTitleFetch: title == nil
                        ))
                        continue
                    }
                }

                if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    if let result = try? await provider.loadItem(forTypeIdentifier: UTType.plainText.identifier),
                       let text = result as? String {
                        let contentFallback = String(text.prefix(40)).components(separatedBy: .newlines).first ?? String(localized: "Shared Text")
                        let suggestion = InputTypeCategory.suggest(from: text, defaultIcon: "document", defaultName: contentFallback)
                        extracted.append(SharedItem(
                            name: title ?? suggestion.name,
                            icon: suggestion.icon,
                            content: .text(text),
                            inputTypeTriggers: suggestion.triggers,
                            autoDetectedCategories: suggestion.categories
                        ))
                        continue
                    }
                }
            }
        }

        let nameGroups = Dictionary(grouping: extracted.indices, by: { extracted[$0].name })
        for (_, indices) in nameGroups where indices.count > 1 {
            for (offset, index) in indices.enumerated() {
                extracted[index].name = "\(extracted[index].name) \(offset + 1)"
            }
        }

        if extracted.isEmpty {
            errorMessage = String(localized: "No content to save.")
        } else {
            items = extracted
        }
        isLoading = false

        for i in items.indices {
            if items[i].needsTitleFetch, case .url(let url) = items[i].content {
                let itemID = items[i].id
                Task {
                    await fetchURLTitle(for: itemID, url: url)
                }
            }
        }
    }

    private func fetchURLTitle(for itemID: UUID, url: URL) async {
        guard let title = await InputTypeCategory.fetchURLTitle(from: url.absoluteString) else { return }
        guard let index = items.firstIndex(where: { $0.id == itemID }),
              items[index].needsTitleFetch else { return }
        items[index].name = title
        items[index].needsTitleFetch = false
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
        guard !items.isEmpty else { return }
        isSaving = true

        let textItemCount = items.filter {
            if case .text = $0.content { return true }
            if case .url = $0.content { return true }
            return false
        }.count
        let imageItemCount = items.filter {
            if case .image = $0.content { return true }
            return false
        }.count

        let currentTextCount = store.cutlings.filter { $0.kind == .text }.count
        let currentImageCount = store.cutlings.filter { $0.kind == .image }.count
        let currentTotal = store.cutlings.count

        if currentTotal + items.count > CutlingStore.maxTotalCutlings {
            limitAlertMessage = String(localized: "Adding \(items.count) items would exceed the maximum of \(CutlingStore.maxTotalCutlings) total cutlings.")
            showLimitAlert = true
            isSaving = false
            return
        }

        if textItemCount > 0 && currentTextCount + textItemCount > CutlingStore.maxTextCutlings {
            limitAlertMessage = String(localized: "Adding \(textItemCount) text items would exceed the maximum of \(CutlingStore.maxTextCutlings) text cutlings.")
            showLimitAlert = true
            isSaving = false
            return
        }

        if imageItemCount > 0 && currentImageCount + imageItemCount > CutlingStore.maxImageCutlings {
            limitAlertMessage = String(localized: "Adding \(imageItemCount) images would exceed the maximum of \(CutlingStore.maxImageCutlings) image cutlings.")
            showLimitAlert = true
            isSaving = false
            return
        }

        for item in items {
            let expiresAt = item.autoDeleteEnabled ? item.deleteAt : nil

            switch item.content {
            case .text(let text):
                if store.isTextTooLong(text) { continue }
                store.add(Cutling(
                    name: item.name,
                    value: text,
                    icon: item.icon,
                    kind: .text,
                    expiresAt: expiresAt,
                    color: Cutling.hexString(from: item.color),
                    inputTypeTriggers: item.inputTypeTriggers.isEmpty ? nil : Array(item.inputTypeTriggers)
                ))

            case .url(let url):
                store.add(Cutling(
                    name: item.name,
                    value: url.absoluteString,
                    icon: item.icon,
                    kind: .text,
                    expiresAt: expiresAt,
                    color: Cutling.hexString(from: item.color)
                ))

            case .image(let data):
                if store.findDuplicateImage(data: data) != nil { continue }
                let id = UUID()
                guard let filename = store.saveImageData(data, for: id) else { continue }
                store.add(Cutling(
                    id: id,
                    name: item.name,
                    value: "",
                    icon: "photo",
                    kind: .image,
                    imageFilename: filename,
                    expiresAt: expiresAt
                ))
            }
        }

        dismiss()
    }
}

// MARK: - SharedItemDetailView

private struct SharedItemDetailView: View {
    @Binding var item: SharedItem
    @State private var showIconPicker = false

    var body: some View {
        Form {
            Section("Name") {
                switch item.content {
                case .text, .url:
                    TextField(String(localized: "e.g. Email"), text: $item.name)
                case .image:
                    TextField(String(localized: "e.g. Signature, QR Code"), text: $item.name)
                }
            }

            switch item.content {
            case .text, .url:
                Section("Icon") {
                    Button {
                        showIconPicker = true
                    } label: {
                        HStack {
                            Image(systemName: item.icon)
                                .font(.title2)
                                .foregroundStyle(item.color)
                                .frame(width: 36, height: 36)
                            Text("Change Icon")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)

                    HStack {
                        Text("Color")
                        Spacer()
                        if item.color != Cutling.defaultTint {
                            Button {
                                withAccessibleAnimation(.easeInOut(duration: 0.2)) {
                                    item.color = Cutling.defaultTint
                                }
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.borderless)
                        }
                        ColorPicker("", selection: $item.color, supportsOpacity: false)
                            .labelsHidden()
                    }
                }
            case .image:
                EmptyView()
            }

            switch item.content {
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
            }

            switch item.content {
            case .text, .url:
                InputTypePickerSection(selectedTriggers: $item.inputTypeTriggers, autoDetectedCategories: $item.autoDetectedCategories)
            default:
                EmptyView()
            }

            ExpirationPickerSection(autoDeleteEnabled: $item.autoDeleteEnabled, deleteAt: $item.deleteAt)
        }
        .scrollDismissesKeyboard(.interactively)
        .formStyle(.grouped)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showIconPicker) {
            IconPickerView(selectedIcon: $item.icon)
        }
    }
}

// MARK: - SharedItemRow

private struct SharedItemRow: View {
    let item: SharedItem

    var body: some View {
        HStack(spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name.isEmpty ? String(localized: "Untitled") : item.name)
                    .foregroundStyle(item.name.isEmpty ? .secondary : .primary)

                switch item.content {
                case .text(let text):
                    Text(text.prefix(60))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                case .url(let url):
                    Text(url.host ?? url.absoluteString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                case .image:
                    EmptyView()
                }
            }
        }
    }

    @ViewBuilder
    private var thumbnail: some View {
        switch item.content {
        case .image(let data):
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                iconPlaceholder(systemName: "photo", color: .secondary)
            }
        case .text:
            iconPlaceholder(systemName: item.icon, color: item.color)
        case .url:
            iconPlaceholder(systemName: "link", color: item.color)
        }
    }

    private func iconPlaceholder(systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.title2)
            .foregroundStyle(color)
            .frame(width: 44, height: 44)
    }
}
