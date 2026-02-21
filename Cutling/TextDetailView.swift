//
//  ItemDetailView.swift
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

    private let columns = [GridItem(.adaptive(minimum: 48), spacing: 8)]

    private var results: [SFSymbolEntry] {
        SFSymbolCatalog.search(searchText)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(results) { entry in
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
            }
        }
        #if os(macOS)
        .frame(minWidth: 360, idealWidth: 420, minHeight: 400, idealHeight: 500)
        #endif
    }
}

// MARK: - Item Detail

struct TextDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: CutlingStore

    let existingItem: Cutling?

    @State private var name: String
    @State private var value: String
    @State private var icon: String
    @State private var showIconPicker = false
    @State private var showDeleteAlert = false
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""

    init(item: Cutling?) {
        self.existingItem = item
        _name = State(initialValue: item?.name ?? "")
        _value = State(initialValue: item?.value ?? "")
        _icon = State(initialValue: item?.icon ?? "document")
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
                Section("Text") {
                    TextEditor(text: $value)
                        .frame(minHeight: 120, maxHeight: 650)
                        .scrollContentBackground(.hidden)
                }
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
            .navigationTitle(isEditing ? "Edit Cutling" : "New Cutling")
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
                        if let existing = existingItem {
                            var updated = existing
                            updated.name = name
                            updated.value = value
                            updated.icon = icon
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
                                        icon: icon
                                    )
                                )
                                dismiss()
                            } else {
                                limitAlertMessage = canAdd.reason ?? "Cannot add more text cutlings."
                                showLimitAlert = true
                            }
                        }
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
        }
        #if os(macOS)
        .frame(minWidth: 420, idealWidth: 480, minHeight: 400, idealHeight: 500)
        #endif
    }
    
    // MARK: - Actions
    
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
