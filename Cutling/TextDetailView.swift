//
//  TextDetailView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
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
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""
    @State private var hasClipboardText = false
    @State private var canPaste = false
    @State private var isPasting = false
    @State private var autoDeleteEnabled: Bool
    @State private var deleteAt: Date
    @State private var color: String?
    @State private var inputTypeTriggers: Set<String>
    @State private var detectTask: Task<Void, Never>?
    @State private var isAutoDetecting = false
    @State private var autoDetectedCategories: Set<InputTypeCategory> = []
    @State private var userDidPickIcon = false
    @AppStorage("autoDetectInputTypes") private var autoDetectInputTypes = true
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
        // When editing an existing cutling, treat the saved icon as user-chosen.
        _userDidPickIcon = State(initialValue: item != nil)
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
                                    saveAndDismiss()
                                } label: {
                                    Image(systemName: "checkmark")
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(name.isEmpty || value.isEmpty)
                            } else {
                                Button("Done") {
                                    saveAndDismiss()
                                }
                                .disabled(name.isEmpty || value.isEmpty)
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
                        if isPasting {
                            isPasting = false
                        } else if hasClipboardText {
                            canPaste = true
                        }
                    }

                Button {
                    pasteFromClipboard()
                } label: {
                    Label("Paste from Clipboard", systemImage: "doc.on.clipboard")
                }
                .foregroundStyle(.primary)
                .disabled(!canPaste)
            } header: {
                Text("Text")
            } footer: {
                Text("\(value.count) / \(CutlingStore.maxTextLength)")
                    .foregroundStyle(value.count > CutlingStore.maxTextLength - 500 ? .orange : .secondary)
                    .font(.caption)
            }
            ColorPaletteSection(selectedColor: undoHandler.binding($color, actionName: String(localized: "Change Color")))
            InputTypePickerSection(selectedTriggers: undoHandler.binding($inputTypeTriggers, actionName: String(localized: "Change Input Types")), autoDetectedCategories: $autoDetectedCategories)
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
        .sheet(isPresented: $showIconPicker, onDismiss: { userDidPickIcon = true }) {
            IconPickerView(selectedIcon: undoHandler.binding($icon, actionName: String(localized: "Change Icon")))
        }
        .alert("Limit Reached", isPresented: $showLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(limitAlertMessage)
        }
        .onAppear {
            checkClipboard()
            canPaste = hasClipboardText

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
        .onDisappear {
            undoHandler.closeAllGroups()
            undoManager?.removeAllActions()
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
        guard autoDetectInputTypes else { return }
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

        // Remove categories that were auto-detected before but are no longer detected.
        // Categories the user toggled manually are not in autoDetectedCategories, so
        // they stay untouched.
        let stale = autoDetectedCategories.subtracting(detected)
        for category in stale {
            inputTypeTriggers.subtract(category.triggerKeys)
        }
        autoDetectedCategories.subtract(stale)

        // Add newly detected categories that aren't already set
        let currentCategories = Set(InputTypeCategory.matchingCategories(for: inputTypeTriggers))
        let newCategories = detected.subtracting(currentCategories)
        for category in newCategories {
            inputTypeTriggers.formUnion(category.triggerKeys)
            autoDetectedCategories.insert(category)
        }

        // Auto-suggest icon as long as the user hasn't manually picked one.
        // If the current icon already matches one of the detected categories, keep it.
        if !userDidPickIcon {
            let currentIconMatchesDetected = detected.contains { $0.icon == icon }
            if !currentIconMatchesDetected, let first = detected.first {
                icon = first.icon
            }
            // If nothing is detected at all, revert to default
            if detected.isEmpty {
                icon = "document"
            }
        }

        // Auto-suggest name when empty or when it matches a previous auto-suggestion
        // (including numbered variants like "Email 2").
        if name.isEmpty || isAutoSuggestedName(name) {
            if let first = detected.first {
                name = deduplicatedName(for: first.displayName)
            } else {
                name = ""
            }
        }
    }

    /// Returns true if the given name is an auto-suggested category name or a numbered variant (e.g. "Email 2").
    private func isAutoSuggestedName(_ name: String) -> Bool {
        let baseNames = Set(InputTypeCategory.allCases.map(\.displayName))
        if baseNames.contains(name) { return true }
        // Check for numbered variants like "Email 2"
        for base in baseNames {
            if name.hasPrefix(base + " "),
               let suffix = Int(name.dropFirst(base.count + 1)),
               suffix >= 2 {
                return true
            }
        }
        return false
    }

    /// Returns a unique name based on the category display name, appending a number if needed.
    private func deduplicatedName(for baseName: String) -> String {
        let existingNames = store.cutlings
            .filter { $0.id != existingItem?.id }
            .map(\.name)
        let nameSet = Set(existingNames)

        if !nameSet.contains(baseName) { return baseName }

        var counter = 2
        while nameSet.contains("\(baseName) \(counter)") {
            counter += 1
        }
        return "\(baseName) \(counter)"
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
            isPasting = true
            canPaste = false
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
