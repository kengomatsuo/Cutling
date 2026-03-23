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
    @EnvironmentObject var store: CutlingStore

    let existingItem: Cutling?
    let autoPasteFromClipboard: Bool

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

    init(item: Cutling?, autoPasteFromClipboard: Bool = false) {
        self.existingItem = item
        self.autoPasteFromClipboard = autoPasteFromClipboard
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
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Email", text: $name)
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
                    TextEditor(text: $value)
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
                ColorPaletteSection(selectedColor: $color)
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
                InputTypePickerSection(selectedTriggers: $inputTypeTriggers)
                    .onChange(of: inputTypeTriggers) { oldValue, newValue in
                        guard !isAutoDetecting else { return }
                        // User manually toggled — figure out which categories changed
                        let oldCategories = Set(InputTypeCategory.matchingCategories(for: oldValue))
                        let newCategories = Set(InputTypeCategory.matchingCategories(for: newValue))
                        let toggled = oldCategories.symmetricDifference(newCategories)
                        userOverriddenCategories.formUnion(toggled)
                        // If user manually removed an auto-detected category, stop claiming we detected it
                        autoDetectedCategories.subtract(toggled)
                        if autoDetectedCategories.isEmpty {
                            withAnimation { showAutoDetectBanner = false }
                        }
                    }
                ExpirationPickerSection(autoDeleteEnabled: $autoDeleteEnabled, deleteAt: $deleteAt)
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
            .navigationTitle(isEditing ? "Edit Cutling" : "New Cutling")
            .toolbar {
                #if os(iOS)
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
                #endif
                ToolbarItem(placement: .confirmationAction) {
                    Button {
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
                            // Check limit for new cutlings
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
                    } label: {
                        if #available(iOS 26, macOS 26, *) {
                            Image(systemName: "checkmark")
                        } else {
                            Text("Save")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty || value.isEmpty)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selectedIcon: $icon)
            }
            .alert("Limit Reached", isPresented: $showLimitAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(limitAlertMessage)
            }
            .onAppear {
                checkClipboard()
                
                if autoPasteFromClipboard {
                    // Delay paste so the sheet is fully presented before iOS
                    // shows the paste-permission prompt. Without this delay the
                    // prompt is suppressed during the sheet transition animation
                    // and the paste silently fails on the first attempt.
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(500))
                        pasteFromClipboard()
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 420, idealWidth: 480, minHeight: 400, idealHeight: 500)
        #endif
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
        #if os(iOS)
        if let text = UIPasteboard.general.string, !text.isEmpty {
            value = text
        }
        #else
        if let text = NSPasteboard.general.string(forType: .string), !text.isEmpty {
            value = text
        }
        #endif
    }
}

#Preview {
    TextDetailView(item: Cutling(name: "Hello", value: "Hello", icon: "car.fill"))
    #if os(macOS)
    .frame(width: 400, height: 500)
    #endif
}
