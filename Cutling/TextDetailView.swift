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
#if os(iOS)
import TipKit
#endif

// MARK: - Item Detail

struct TextDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.undoManager) var undoManager
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var store: CutlingStore

    let existingItem: Cutling?
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
    @State private var pickedColor: Color
    @State private var inputTypeTriggers: Set<String>
    @State private var detectTask: Task<Void, Never>?
    @State private var titleFetchTask: Task<Void, Never>?
    @State private var isFetchingTitle = false
    @State private var isAutoDetecting = false
    /// The exact name auto-detect last wrote. Auto-detect only manages the name
    /// while it's empty or still equals this value; once the user types anything
    /// (even a reserved word like "Email"), it diverges and is left alone.
    @State private var lastAutoName: String = ""
    @State private var userSetInputType: Bool
    @State private var userDidPickIcon = false
    @State private var sensitiveContentTypes: Set<SensitiveContentType> = []
    @State private var wasTruncated: Bool
    @AppStorage("autoDetectInputTypes") private var autoDetectInputTypes = true
    @State private var undoHandler = UndoHandler()

    /// Lets the Name field's Return key move focus to the Text field.
    private enum Field: Hashable { case name, value }
    @FocusState private var focusedField: Field?

    #if os(iOS)
    private let editorNameTip = EditorNameTip()
    private let editorTextTip = EditorTextTip()
    private let editorSaveTip = EditorSaveTip()
    private let editorBackTip = EditorBackTip()
    private let editorDeleteTip = EditorDeleteTip()
    #endif

    init(
        item: Cutling?,
        initialName: String = "",
        initialValue: String = "",
        initialIcon: String? = nil,
        initialColor: String? = nil,
        initialTriggers: [String] = [],
        initialExpiresAt: Date? = nil,
        initialWasTruncated: Bool = false,
        presentedAsSheet: Bool = true
    ) {
        self.existingItem = item
        self.presentedAsSheet = presentedAsSheet
        _name = State(initialValue: item?.name ?? initialName)
        _value = State(initialValue: item?.value ?? initialValue)
        _icon = State(initialValue: item?.icon ?? initialIcon ?? "document")
        let resolvedExpiresAt = item?.expiresAt ?? initialExpiresAt
        _autoDeleteEnabled = State(initialValue: resolvedExpiresAt != nil)
        _deleteAt = State(initialValue: resolvedExpiresAt ?? Date().addingTimeInterval(86400))
        let resolvedColor: Color = {
            if let item { return item.tintColor }
            if let initialColor, let parsed = Cutling.color(fromHex: initialColor) { return parsed }
            if let initialColor, let palette = Cutling.palette[initialColor] { return palette }
            return Cutling.defaultTint
        }()
        _pickedColor = State(initialValue: resolvedColor)
        _inputTypeTriggers = State(initialValue: Set(item?.inputTypeTriggers ?? initialTriggers))
        _userSetInputType = State(initialValue: item?.userSetInputType ?? false)
        // When editing an existing cutling, treat the saved icon as user-chosen.
        // Also treat as user-chosen if an explicit initial icon was supplied
        // (e.g. dropped from another cutling) so auto-detect doesn't override it.
        _userDidPickIcon = State(initialValue: item != nil || initialIcon != nil)
        _wasTruncated = State(initialValue: initialWasTruncated)
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
        #endif
        #if os(iOS)
        if presentedAsSheet {
            NavigationStack {
                formContent
                    .interactiveDismissDisabled(tutorialLocksCancel)
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
                            .disabled(tutorialLocksCancel)
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
                                .popoverTip(editorSaveTip, arrowEdge: .top)
                            } else {
                                Button("Done") {
                                    saveAndDismiss()
                                }
                                .disabled(name.isEmpty || value.isEmpty)
                                .popoverTip(editorSaveTip, arrowEdge: .top)
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
        #endif
        #if os(macOS)
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
        ScrollViewReader { proxy in
        Form {
            #if os(iOS)
            // Edit step: the back tip is shown inline at the top (anchoring a
            // popover to the system Back button isn't reliable).
            if isEditing {
                TipView(editorBackTip)
                    .listRowBackground(Color.clear)
            }
            #endif
            Section {
                TextField("e.g. Email", text: undoHandler.binding($name, actionName: String(localized: "Change Name")))
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { handleNameSubmit() }
                    #if os(iOS)
                    .popoverTip(editorNameTip, arrowEdge: .top)
                    #endif
            } header: {
                HStack(spacing: 6) {
                    Text("Name")
                    if isFetchingTitle {
                        ProgressView()
                            .controlSize(.mini)
                    }
                }
            }
            Section("Icon") {
                #if os(macOS)
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(pickedColor)
                    Spacer()
                    Button("Change Icon") {
                        showIconPicker = true
                    }
                }
                #endif
                #if os(iOS)
                Button {
                    showIconPicker = true
                } label: {
                    HStack {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundStyle(pickedColor)
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
                // ColorPicker's built-in label is hidden so we can place the reset
                // button between the label and the color well. If layout breaks
                // here in the future, revert to a normal ColorPicker("Color", ...)
                // and move the reset button after it.
                HStack {
                    Text("Color")
                    Spacer()
                    if pickedColor != Cutling.defaultTint {
                        Button {
                            withAccessibleAnimation(.easeInOut(duration: 0.2)) {
                                pickedColor = Cutling.defaultTint
                            }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.subheadline)
                        }
                        .buttonStyle(.borderless)
                    }
                    ColorPicker("", selection: undoHandler.binding($pickedColor, actionName: String(localized: "Change Color")), supportsOpacity: false)
                        .labelsHidden()
                }
            }
            SensitiveContentWarning(types: sensitiveContentTypes)
            Section {
                TextEditor(text: undoHandler.binding($value, actionName: String(localized: "Change Text")))
                    .focused($focusedField, equals: .value)
                    .frame(minHeight: 120, maxHeight: 450)
                    .scrollContentBackground(.hidden)
                    #if os(iOS)
                    .id("tutorialTextSection")
                    .popoverTip(editorTextTip, arrowEdge: .top)
                    #endif
                    .onChange(of: value) { oldValue, newValue in
                        if newValue.count > CutlingStore.maxTextLength {
                            value = String(newValue.prefix(CutlingStore.maxTextLength))
                        }
                        if wasTruncated && newValue != oldValue {
                            wasTruncated = false
                        }
                        let isLargeChange = abs(newValue.count - oldValue.count) > 1
                        if isPasting || isLargeChange {
                            runAutoDetectNow()
                        } else {
                            scheduleAutoDetect()
                        }
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
                VStack(alignment: .leading, spacing: 4) {
                    if wasTruncated {
                        HStack(spacing: 4) {
                            Image(systemName: "scissors")
                            Text("Trimmed to fit \(CutlingStore.maxTextLength) characters")
                        }
                        .foregroundStyle(.orange)
                    }
                    Text("\(value.count) / \(CutlingStore.maxTextLength)")
                        .foregroundStyle(value.count > CutlingStore.maxTextLength - 500 ? .orange : .secondary)
                }
                .font(.caption)
            }
            InputTypePickerSection(selectedTriggers: undoHandler.binding($inputTypeTriggers, actionName: String(localized: "Change Input Types")), userSetInputType: $userSetInputType)
            ExpirationPickerSection(autoDeleteEnabled: undoHandler.binding($autoDeleteEnabled, actionName: String(localized: "Change Expiration")), deleteAt: undoHandler.binding($deleteAt, actionName: String(localized: "Change Expiration")))

            if isEditing {
                Section {
                    Button("Delete Cutling", role: .destructive) {
                        if let item = existingItem {
                            store.delete(item)
                        }
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .id("tutorialDeleteButton")
                    #if os(iOS)
                    .popoverTip(editorDeleteTip, arrowEdge: .bottom)
                    #endif
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .formStyle(.grouped)
        .navigationTitle(isEditing ? "Edit" : "New")
        .accessibilityIdentifier("detailView")
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
            if !value.isEmpty && !isEditing {
                scheduleAutoDetect()
            }
            if !value.isEmpty {
                sensitiveContentTypes = SensitiveContentType.detect(in: value)
            }
        }
        .onChange(of: undoManager, initial: true) { _, newValue in
            undoHandler.undoManager = newValue
        }
        .onDisappear {
            undoHandler.closeAllGroups()
            undoManager?.removeAllActions()
        }
        #if os(iOS)
        // Only reveal the tip once the zoom transition (and any scroll) settles.
        .onAppear { revealEditorTip(proxy) }
        .onChange(of: TutorialCoordinator.shared.step) { _, newStep in
            focusForTutorialStep()
            // Same-sheet create transition (name → value) has no new appearance,
            // so show the text tip right away.
            if newStep == .createSave, !isEditing {
                TutorialCoordinator.shared.showEditorTipForCurrentStep()
            }
        }
        // Advance the name step however the user leaves the field (Return, tap
        // elsewhere, keyboard dismiss), not only on Return.
        .onChange(of: focusedField) { oldValue, newValue in
            let t = TutorialCoordinator.shared
            if oldValue == .name, newValue != .name, !name.isEmpty,
               t.isActive, t.step == .createName {
                t.advance(from: .createName)
            }
            // The name step is done past createName. A tip popover presenting /
            // dismissing can restore first-responder to the Name field; since
            // the name is complete, send focus back to the Value field.
            if newValue == .name, t.isActive, !isEditing,
               t.step == .createSave {
                focusedField = .value
            }
        }
        // Typing dismisses the current field's tip; it (or the next one) shows
        // again after a 2s pause.
        .onChange(of: name) { _, _ in
            let t = TutorialCoordinator.shared
            // Only go back to the name step if the user actually cleared the
            // Name field while editing it. If they're in the Value field (or a
            // stray auto-detect blanked the name), never reset/refocus — that's
            // what was yanking the cursor back to Name mid-typing.
            if t.isActive, t.step == .createSave, !isEditing,
               name.isEmpty, focusedField == .name {
                t.reset(to: .createName)
                return
            }
            t.editorTypingChanged(valueEmpty: value.isEmpty)
        }
        .onChange(of: value) { _, _ in
            TutorialCoordinator.shared.editorTypingChanged(valueEmpty: value.isEmpty)
        }
        #endif
        }
    }

    #if os(iOS)
    /// Focuses only the Name field at the start of create (so Return flows to
    /// the text field). The value/edit steps just show the tip — no auto-focus.
    private func focusForTutorialStep() {
        guard TutorialCoordinator.shared.isActive else { return }
        // Never yank focus away from the Value field.
        if TutorialCoordinator.shared.step == .createName, !isEditing, focusedField != .value {
            focusedField = .name
        }
    }

    /// While the walkthrough is creating a cutling, the only way out of the
    /// sheet is Save — Cancel is locked so the user completes the step.
    private var tutorialLocksCancel: Bool {
        !isEditing && TutorialCoordinator.shared.isActive
    }

    /// Reveal the editor tip only after the zoom transition (and, for the
    /// delete step, the scroll to the button) has fully finished.
    private func revealEditorTip(_ proxy: ScrollViewProxy) {
        guard TutorialCoordinator.shared.isActive else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.5))      // zoom / sheet transition
            guard TutorialCoordinator.shared.isActive else { return }
            focusForTutorialStep()
            if TutorialCoordinator.shared.step == .deleteConfirm {
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo("tutorialDeleteButton", anchor: .center)
                }
                try? await Task.sleep(for: .seconds(0.45)) // wait for the scroll
                guard TutorialCoordinator.shared.step == .deleteConfirm else { return }
            }
            TutorialCoordinator.shared.showEditorTipForCurrentStep()
        }
    }
    #endif

    /// Return on the Name field jumps to the Text field (rather than just
    /// dismissing the keyboard), and advances the walkthrough's name step.
    private func handleNameSubmit() {
        focusedField = .value
        #if os(iOS)
        if !isEditing, !name.isEmpty {
            TutorialCoordinator.shared.advance(from: .createName)
        }
        #endif
    }

    // MARK: - Save Helpers

    private func saveAndDismiss() {
        if let existing = existingItem {
            var updated = existing
            updated.name = name
            updated.value = value
            updated.icon = icon
            updated.expiresAt = autoDeleteEnabled ? deleteAt : nil
            updated.color = Cutling.hexString(from: pickedColor)
            updated.inputTypeTriggers = inputTypeTriggers.isEmpty ? nil : Array(inputTypeTriggers)
            updated.userSetInputType = userSetInputType
            store.update(updated)
            postMacSaveNotification()
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
                        color: Cutling.hexString(from: pickedColor),
                        inputTypeTriggers: inputTypeTriggers.isEmpty ? nil : Array(inputTypeTriggers),
                        userSetInputType: userSetInputType
                    )
                )
                postMacSaveNotification()
                dismiss()
            } else {
                limitAlertMessage = canAdd.reason ?? String(localized: "Cannot add more text cutlings.")
                showLimitAlert = true
            }
        }
    }

    private func postMacSaveNotification() {
        #if os(macOS)
        NotificationCenter.default.post(name: .cutlingDidSaveFromMacWindow, object: nil)
        #endif
    }

    private func autoSave() {
        if let existing = existingItem {
            var updated = existing
            if !name.isEmpty { updated.name = name }
            if !value.isEmpty { updated.value = value }
            updated.icon = icon
            updated.expiresAt = autoDeleteEnabled ? deleteAt : nil
            updated.color = Cutling.hexString(from: pickedColor)
            updated.inputTypeTriggers = inputTypeTriggers.isEmpty ? nil : Array(inputTypeTriggers)
            updated.userSetInputType = userSetInputType
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
                    color: Cutling.hexString(from: pickedColor),
                    inputTypeTriggers: inputTypeTriggers.isEmpty ? nil : Array(inputTypeTriggers),
                    userSetInputType: userSetInputType
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
            if autoDetectInputTypes || !isEditing {
                runAutoDetect()
            }
            sensitiveContentTypes = SensitiveContentType.detect(in: value)
        }
    }

    private func runAutoDetectNow() {
        detectTask?.cancel()
        if autoDetectInputTypes || !isEditing {
            runAutoDetect()
        }
        sensitiveContentTypes = SensitiveContentType.detect(in: value)
    }

    private func runAutoDetect() {
        let suggestion = InputTypeCategory.suggest(from: value)

        isAutoDetecting = true
        defer { isAutoDetecting = false }

        // Once the user has pinned an assignment, the in-page detector stops
        // touching `inputTypeTriggers`. Icon and name suggestions below still
        // apply because those are independent signals.
        if !userSetInputType {
            inputTypeTriggers = Set(suggestion.categories.flatMap { $0.triggerKeys })
        }

        // Auto-suggest icon as long as the user hasn't manually picked one.
        if !userDidPickIcon {
            let currentIconMatchesDetected = suggestion.categories.contains { $0.icon == icon }
            if !currentIconMatchesDetected {
                icon = suggestion.icon
            }
        }

        // Auto-suggest name when empty or when it matches a previous auto-suggestion
        // (including numbered variants like "Email 2").
        // Only manage the name while the user hasn't typed their own (it's empty
        // or still exactly what we last auto-set).
        if name.isEmpty || name == lastAutoName {
            if !suggestion.categories.isEmpty {
                name = deduplicatedName(for: suggestion.name)
            } else {
                name = ""
            }
            lastAutoName = name
        }

        titleFetchTask?.cancel()
        if suggestion.categories.contains(.url) {
            isFetchingTitle = true
            titleFetchTask = Task { @MainActor in
                defer { isFetchingTitle = false }
                guard let title = await InputTypeCategory.fetchURLTitle(from: value),
                      !Task.isCancelled else { return }
                if name.isEmpty || name == lastAutoName {
                    name = deduplicatedName(for: title)
                    lastAutoName = name
                }
            }
        } else {
            isFetchingTitle = false
        }
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
        // the delayed direct-paste.
        hasClipboardText = UIPasteboard.general.hasStrings
        #endif
        #if os(macOS)
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
        #endif
        #if os(macOS)
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
