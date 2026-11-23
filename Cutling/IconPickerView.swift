//
//  IconPickerView.swift
//  Cutling
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import SwiftUI

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
