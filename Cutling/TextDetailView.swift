//
//  TextDetailView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import SwiftUI

// MARK: - Icon Picker

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""
    @State private var selectedCategory: SFSymbolCatalog.Category = .objects

    private let columns = [GridItem(.adaptive(minimum: 48), spacing: 8)]

    private var isSearching: Bool { !searchText.isEmpty }

    private var searchResults: [SFSymbolEntry] {
        SFSymbolCatalog.search(searchText)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !isSearching {
                    categoryTabs
                }

                ScrollView {
                    let entries = isSearching ? searchResults : selectedCategory.entries
                    if entries.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(entries) { entry in
                                let isSelected = selectedIcon == entry.name
                                Button {
                                    selectedIcon = entry.name
                                    dismiss()
                                } label: {
                                    Image(systemName: entry.name)
                                        .font(.title3)
                                        .frame(width: 48, height: 48)
                                        .foregroundStyle(isSelected ? .white : .primary)
                                        .background(isSelected ? Color.accentColor : Color.clear)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(entry.name)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Choose Icon")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .searchable(text: $searchText, prompt: "Search icons")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        if #available(iOS 26, macOS 26, *) {
                            Image(systemName: "xmark")
                        } else {
                            Text("Cancel")
                        }
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 360, idealWidth: 420, minHeight: 400, idealHeight: 500)
        #endif
    }

    private var categoryTabs: some View {
        Picker("Category", selection: $selectedCategory) {
            ForEach(SFSymbolCatalog.Category.allCases) { category in
                Image(systemName: category.icon)
                    .accessibilityLabel(category.rawValue)
                    .tag(category)
            }
        }
        .pickerStyle(.palette)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Item Detail

struct TextDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.undoManager) var undoManager
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var store: CutlingStore

    let existingItem: Cutling?
    let autoPasteFromClipboard: Bool
    let presentedAsSheet: Bool

    @State private var name: String
    @State private var value: String
    @State private var icon: String
    @State private var showIconPicker = false
    @State private var showDeleteAlert = false
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""
    @State private var hasClipboardText = false
    @State private var autoDeleteEnabled: Bool
    @State private var deleteAt: Date
    @State private var color: String?
    @State private var inputTypeTriggers: Set<String>
    @State private var autoDetectedCategories: Set<InputTypeCategory> = []
    @State private var userOverriddenCategories: Set<InputTypeCategory> = []
    @State private var showAutoDetectBanner = false
    @State private var detectTask: Task<Void, Never>?
    @State private var isAutoDetecting = false
    @State private var undoHandler = UndoHandler()

    init(item: Cutling?, autoPasteFromClipboard: Bool = false, presentedAsSheet: Bool = true) {
        self.existingItem = item
        self.autoPasteFromClipboard = autoPasteFromClipboard
        self.presentedAsSheet = presentedAsSheet
        _name = State(initialValue: item?.name ?? "")
        _value = State(initialValue: item?.value ?? "")
        _icon = State(initialValue: item?.icon ?? "document")
        _autoDeleteEnabled = State(initialValue: item?.expiresAt != nil)
        _deleteAt = State(initialValue: item?.expiresAt ?? Date().addingTimeInterval(86400))
        _color = State(initialValue: item?.color)
        _inputTypeTriggers = State(initialValue: Set(item?.inputTypeTriggers ?? []))
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
                                saveAndDismiss()
                            } label: {
                                if #available(macOS 26, *) {
                                    Image(systemName: "checkmark")
                                } else {
                                    Text("Save")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(name.isEmpty || value.isEmpty)
                        }
                    }
            }
            .frame(minWidth: 420, idealWidth: 480, minHeight: 400, idealHeight: 500)
        } else {
            formContent
                .toolbar {
                    undoRedoToolbarContent
                }
                .onWillDisappear {
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
                            Button {
                                saveAndDismiss()
                            } label: {
                                if #available(iOS 26, *) {
                                    Image(systemName: "checkmark")
                                } else {
                                    Text("Save")
                                }
                            }
                            .disabled(name.isEmpty || value.isEmpty)
                        }
                    }
            }
        } else {
            formContent
                .toolbar {
                    undoRedoToolbarContent
                }
                .onWillDisappear {
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
                TextField("e.g. Email", text: undoHandler.binding($name, actionName: String(localized: "Change Name")))
            }
            Section("Icon") {
                #if os(macOS)
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(.tint)
                    Spacer()
                    Button("Change Icon") {
                        showIconPicker = true
                    }
                }
                #else
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
                #endif
            }
            Section {
                TextEditor(text: undoHandler.binding($value, actionName: String(localized: "Change Text")))
                    .frame(minHeight: 120, maxHeight: 650)
                    .scrollContentBackground(.hidden)
                    .onChange(of: value) {
                        if value.count > CutlingStore.maxTextLength {
                            value = String(value.prefix(CutlingStore.maxTextLength))
                        }
                        scheduleAutoDetect()
                    }
            } header: {
                Text("Text")
            } footer: {
                Text("\(value.count) / \(CutlingStore.maxTextLength)")
                    .foregroundStyle(value.count > CutlingStore.maxTextLength - 500 ? .orange : .secondary)
                    .font(.caption)
            }
            ColorPaletteSection(selectedColor: undoHandler.binding($color, actionName: String(localized: "Change Color")))
            if showAutoDetectBanner && !autoDetectedCategories.isEmpty {
                Section {
                    HStack {
                        Text("Detected: \(autoDetectedCategories.map(\.displayName).joined(separator: ", "))")
                            .font(.subheadline)
                        Spacer()
                        Button("Undo") {
                            undoAutoDetect()
                        }
                        .font(.subheadline.weight(.medium))
                    }
                }
                .transition(.opacity)
            }
            InputTypePickerSection(selectedTriggers: undoHandler.binding($inputTypeTriggers, actionName: String(localized: "Change Input Types")))
                .onChange(of: inputTypeTriggers) { oldValue, newValue in
                    guard !isAutoDetecting else { return }
                    let oldCategories = Set(InputTypeCategory.matchingCategories(for: oldValue))
                    let newCategories = Set(InputTypeCategory.matchingCategories(for: newValue))
                    let toggled = oldCategories.symmetricDifference(newCategories)
                    userOverriddenCategories.formUnion(toggled)
                    autoDetectedCategories.subtract(toggled)
                    if autoDetectedCategories.isEmpty {
                        withAnimation { showAutoDetectBanner = false }
                    }
                }
            ExpirationPickerSection(autoDeleteEnabled: undoHandler.binding($autoDeleteEnabled, actionName: String(localized: "Change Expiration")), deleteAt: undoHandler.binding($deleteAt, actionName: String(localized: "Change Expiration")))
            if hasClipboardText {
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
                    Text("This will replace the current text with whatever is in your clipboard.")
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
        .scrollDismissesKeyboard(.interactively)
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
        .navigationTitle(isEditing ? "Edit" : "New")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $showIconPicker) {
            IconPickerView(selectedIcon: undoHandler.binding($icon, actionName: String(localized: "Change Icon")))
        }
        .alert("Limit Reached", isPresented: $showLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(limitAlertMessage)
        }
        .onAppear {
            checkClipboard()
            
            if autoPasteFromClipboard {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(500))
                    pasteFromClipboard()
                }
            }
        }
        .onChange(of: undoManager, initial: true) { _, newValue in
            undoHandler.undoManager = newValue
        }

    }

    // MARK: - Save Helpers

    private func saveAndDismiss() {
        if let existing = existingItem {
            var updated = existing
            updated.name = name
            updated.value = value
            updated.icon = icon
            updated.expiresAt = autoDeleteEnabled ? deleteAt : nil
            updated.color = color
            updated.inputTypeTriggers = inputTypeTriggers.isEmpty ? nil : Array(inputTypeTriggers)
            store.update(updated)
            dismiss()
        } else {
            let canAdd = store.canAdd(.text)
            if canAdd.allowed {
                store.add(
                    Cutling(
                        name: name,
                        value: value,
                        icon: icon,
                        expiresAt: autoDeleteEnabled ? deleteAt : nil,
                        color: color,
                        inputTypeTriggers: inputTypeTriggers.isEmpty ? nil : Array(inputTypeTriggers)
                    )
                )
                dismiss()
            } else {
                limitAlertMessage = canAdd.reason ?? String(localized: "Cannot add more text cutlings.")
                showLimitAlert = true
            }
        }
    }

    private func autoSave() {
        if let existing = existingItem {
            var updated = existing
            if !name.isEmpty { updated.name = name }
            if !value.isEmpty { updated.value = value }
            updated.icon = icon
            updated.expiresAt = autoDeleteEnabled ? deleteAt : nil
            updated.color = color
            updated.inputTypeTriggers = inputTypeTriggers.isEmpty ? nil : Array(inputTypeTriggers)
            store.update(updated)
        } else {
            guard !name.isEmpty, !value.isEmpty else { return }
            let canAdd = store.canAdd(.text)
            guard canAdd.allowed else { return }
            store.add(
                Cutling(
                    name: name,
                    value: value,
                    icon: icon,
                    expiresAt: autoDeleteEnabled ? deleteAt : nil,
                    color: color,
                    inputTypeTriggers: inputTypeTriggers.isEmpty ? nil : Array(inputTypeTriggers)
                )
            )
        }
    }
    
    // MARK: - Auto-Detection

    private func scheduleAutoDetect() {
        detectTask?.cancel()
        detectTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(800))
            guard !Task.isCancelled else { return }
            runAutoDetect()
        }
    }

    private func runAutoDetect() {
        let detected = InputTypeCategory.detect(from: value)

        isAutoDetecting = true
        defer { isAutoDetecting = false }

        // Undo previously auto-detected categories that are no longer detected
        // (but only if the user hasn't manually overridden them)
        let staleCategories = autoDetectedCategories.subtracting(detected).subtracting(userOverriddenCategories)
        if !staleCategories.isEmpty {
            for category in staleCategories {
                inputTypeTriggers.subtract(category.triggerKeys)
            }
            autoDetectedCategories.subtract(staleCategories)
        }

        guard !detected.isEmpty else {
            // Nothing detected — hide banner and clear state
            if showAutoDetectBanner {
                withAnimation { showAutoDetectBanner = false }
                autoDetectedCategories = []
            }
            return
        }

        // Only add categories that aren't already set and haven't been manually overridden
        let currentCategories = Set(InputTypeCategory.matchingCategories(for: inputTypeTriggers))
        let newCategories = detected.subtracting(currentCategories).subtracting(userOverriddenCategories)
        guard !newCategories.isEmpty else {
            // Already covered — hide banner if nothing new to show
            if autoDetectedCategories.isEmpty && showAutoDetectBanner {
                withAnimation { showAutoDetectBanner = false }
            }
            return
        }

        // Auto-toggle the new categories on
        for category in newCategories {
            inputTypeTriggers.formUnion(category.triggerKeys)
        }
        autoDetectedCategories.formUnion(newCategories)

        withAnimation(.easeInOut(duration: 0.25)) {
            showAutoDetectBanner = true
        }
    }

    private func undoAutoDetect() {
        isAutoDetecting = true
        defer { isAutoDetecting = false }

        for category in autoDetectedCategories {
            inputTypeTriggers.subtract(category.triggerKeys)
        }
        // Mark undone categories as user-overridden so they don't get re-added
        userOverriddenCategories.formUnion(autoDetectedCategories)
        withAnimation(.easeOut(duration: 0.25)) {
            showAutoDetectBanner = false
        }
        autoDetectedCategories = []
    }

    // MARK: - Actions
    
    private func checkClipboard() {
        #if os(iOS)
        // Only use hasStrings — does NOT trigger the paste-permission prompt.
        // The actual .string access happens in pasteFromClipboard() which is
        // called either by the user tapping "Paste from Clipboard" or after
        // the delayed auto-paste.
        hasClipboardText = UIPasteboard.general.hasStrings
        #else
        if let text = NSPasteboard.general.string(forType: .string) {
            hasClipboardText = !text.isEmpty
        } else {
            hasClipboardText = false
        }
        #endif
    }
    
    private func pasteFromClipboard() {
        var newText: String?
        #if os(iOS)
        if let text = UIPasteboard.general.string, !text.isEmpty {
            newText = text
        }
        #else
        if let text = NSPasteboard.general.string(forType: .string), !text.isEmpty {
            newText = text
        }
        #endif
        if let newText {
            let oldValue = value
            value = newText
            undoHandler.registerUndo(from: oldValue, to: newText, actionName: String(localized: "Paste")) { value = $0 }
        }
    }
}

#Preview {
    TextDetailView(item: Cutling(name: "Hello", value: "Hello", icon: "car.fill"))
    #if os(macOS)
    .frame(width: 400, height: 500)
    #endif
}
