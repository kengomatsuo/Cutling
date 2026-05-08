//
//  MainContentView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import SwiftUI
import StoreKit

#if os(iOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif
import UniformTypeIdentifiers

// MARK: - Menu Commands (macOS)

#if os(macOS)
@Observable
final class MainContentCommands {
    var enterSelectMode: (() -> Void)?
    var enterReorderMode: (() -> Void)?
    var deleteSelected: (() -> Void)?
    var selectedCount: Int = 0
    var cutlingsCount: Int = 0
}
#endif

// MARK: - Mode Enum

enum MainContentMode: Equatable {
    case browsing
    case selecting
    case ordering
}

// MARK: - Main Content

struct MainContentView: View {
    // MARK: Environment
    @EnvironmentObject var store: CutlingStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    #if os(macOS)
    @Environment(\.openWindow) private var openWindow
    #endif

    // MARK: Parent Bindings
    @Binding var activeSheet: ActiveSheet?
    @Binding var newCutlingDraft: NewCutlingDraft?

    // MARK: Navigation
    @State private var selectedItem: Cutling? = nil
    @State private var showRecentlyDeleted = false
    @State private var limitAlertMessage: String?

    // MARK: Search
    @State private var searchText = ""
    @State private var searchIsPresented = false

    // MARK: Mode & Selection
    @State private var mode: MainContentMode = .browsing
    @State private var showDeleteConfirmation = false
    #if os(iOS)
    @State private var panGesture: UIPanGestureRecognizer?
    @State private var selectionProperties: SelectionProperties = .init()
    @State private var scrollProperties: ScrollProperties = .init()
    #endif
    #if os(macOS)
    @State private var selectedCutlingIDs: Set<UUID> = []
    @State private var menuCommands = MainContentCommands()
    #endif

    // MARK: Grid Tracking
    @State private var cutlingLocations: [UUID: CGRect] = [:]
    @State private var hasScrolledToNew = false

    // MARK: Transitions (iOS)
    #if os(iOS)
    @Namespace private var zoomNamespace
    private let addButtonZoomID = "addButton"
    private let keyboardButtonZoomID = "keyboardButton"
    #endif

    init(activeSheet: Binding<ActiveSheet?> = .constant(nil), newCutlingDraft: Binding<NewCutlingDraft?> = .constant(nil)) {
        _activeSheet = activeSheet
        _newCutlingDraft = newCutlingDraft
    }
    
    // MARK: - Keyboard Status

    #if os(iOS)
    private var isKeyboardAdded: Bool {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let keyboards = UserDefaults.standard.stringArray(forKey: "AppleKeyboards") ?? []
        return keyboards.contains(where: { $0.hasPrefix(bundleID) })
    }

    private var hasFullAccess: Bool {
        UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.bool(forKey: "hasFullAccess") ?? false
    }

    private var keyboardNeedsAttention: Bool {
        !isKeyboardAdded || !hasFullAccess
    }
    #endif

    #if os(iOS)
    let columns = [GridItem(.adaptive(minimum: 160, maximum: 240), spacing: 12)]
    private let cardHeight: CGFloat = 140
    #endif
    #if os(macOS)
    let columns = [GridItem(.adaptive(minimum: 180, maximum: 280), spacing: 14)]
    private let cardHeight: CGFloat = 160
    #endif

    var filtered: [Cutling] {
        let live = store.cutlings.filter { !$0.isExpired }
        if searchText.isEmpty { return live }
        return live.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.value.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Selection & Scroll Types

    #if os(iOS)
    /// Mirrors SelectionProperties from the reference.
    private struct SelectionProperties {
        var start: Int?
        var end: Int?
        /// The live selected IDs (shown in the UI during and after a drag).
        var selectedIDs: Set<UUID> = []
        /// The committed selected IDs from before the current drag began.
        var previousIDs: Set<UUID> = []
        /// IDs that will be removed from selection when the drag ends (deselect-drag).
        var toBeDeletedIDs: Set<UUID> = []
        /// Whether the current drag is a deselect-drag.
        var isDeleteDrag: Bool = false
    }

    /// Mirrors ScrollProperties from the reference.
    private struct ScrollProperties {
        var position: ScrollPosition = .init()
        var currentScrollOffset: CGFloat = 0
        var manualScrollOffset: CGFloat = 0
        var timer: Timer?
        var direction: ScrollDirection = .none
        /// Pixels per tick — updated continuously as finger moves within edge zone.
        var speed: CGFloat = 0
    }

    nonisolated private enum ScrollDirection {
        case up
        case down
        case none
    }
    #endif

    /// Cross-platform accessor for the current selected IDs.
    private var selectedIDs: Set<UUID> {
        #if os(iOS)
        selectionProperties.selectedIDs
        #endif
        #if os(macOS)
        selectedCutlingIDs
        #endif
    }

    #if os(macOS)
    private func openAddWindow(for kind: CutlingKind) {
        switch kind {
        case .text: openWindow(id: "addText")
        case .image: openWindow(id: "addImage")
        }
    }
    #endif

    // MARK: - Body

    var body: some View {
        NavigationStack {
            mainContent
                .modifier(SheetsModifier(
                    selectedItem: $selectedItem
                ))
                .modifier(AlertsModifier(
                    limitAlertMessage: $limitAlertMessage
                ))
                .modifier(ChangeHandlersModifier(
                    mode: mode,
                    lastAddedCutlingID: store.lastAddedCutlingID,
                    selectedItem: $selectedItem,
                    activeSheet: $activeSheet,
                    hasScrolledToNew: $hasScrolledToNew,
                    onModeChange: handleModeChange,
                    onScrollToNew: scrollToBottom
                ))
                #if os(iOS)
                .modifier(PanGestureModifier(
                    isSelecting: mode == .selecting,
                    panGesture: $panGesture,
                    onPanChange: onGestureChange,
                    onPanEnd: onGestureEnded
                ))
                #endif
                #if os(macOS)
                .focusedSceneValue(\.mainContentMode, mode)
                .focusedSceneValue(\.mainContentCommands, menuCommands)
                .onAppear { updateMenuCommands() }
                .onChange(of: mode) { _, _ in updateMenuCommands() }
                .onChange(of: selectedCutlingIDs) { _, _ in updateMenuCommands() }
                #endif
                .navigationDestination(isPresented: $showRecentlyDeleted) {
                    RecentlyDeletedView()
                }
                #if os(iOS)
                .navigationDestination(item: $selectedItem) { item in
                    Group {
                        switch item.kind {
                        case .text:
                            TextDetailView(item: item, presentedAsSheet: false)
                        case .image:
                            ImageDetailView(item: item, presentedAsSheet: false)
                        }
                    }
                    .navigationTransition(.zoom(sourceID: item.id, in: zoomNamespace))
                }
                .sheet(item: $activeSheet) { sheet in
                    switch sheet {
                    case .newCutling:
                        if let draft = newCutlingDraft {
                            Group {
                                switch draft.kind {
                                case .text:
                                    TextDetailView(item: nil, initialName: draft.name, initialValue: draft.text, presentedAsSheet: true)
                                case .image:
                                    ImageDetailView(item: nil, initialName: draft.name, initialImageData: draft.imageData, presentedAsSheet: true)
                                }
                            }
                            .navigationTransition(.zoom(sourceID: addButtonZoomID, in: zoomNamespace))
                        }
                    case .keyboardManager:
                        KeyboardView()
                            .navigationTransition(.zoom(sourceID: keyboardButtonZoomID, in: zoomNamespace))
                    case .keyboardSetup:
                        KeyboardSetupView()
                    }
                }
                #endif
                #if os(macOS)
                .sheet(item: $activeSheet) { sheet in
                    switch sheet {
                    case .keyboardManager:
                        KeyboardView()
                            .environmentObject(store)
                    case .keyboardSetup:
                        KeyboardSetupView()
                            .environmentObject(store)
                    case .newCutling:
                        EmptyView()
                    }
                }
                #endif
                #if os(macOS)
                .onChange(of: activeSheet) { _, sheet in
                    guard sheet == .newCutling, let draft = newCutlingDraft else { return }
                    activeSheet = nil
                    newCutlingDraft = nil
                    openAddWindow(for: draft.kind)
                }
                #endif
                #if os(iOS)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    let groupDefaults = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")
                    guard groupDefaults?.string(forKey: "pendingControlAction") == "addFromClipboard" else { return }
                    groupDefaults?.removeObject(forKey: "pendingControlAction")
                    if let string = UIPasteboard.general.string, !string.isEmpty {
                        newCutlingDraft = NewCutlingDraft(kind: .text, text: string)
                        activeSheet = .newCutling
                    } else if let image = UIPasteboard.general.image,
                              let data = image.pngData() {
                        newCutlingDraft = NewCutlingDraft(kind: .image, name: String(localized: "Shared Image"), imageData: data)
                        activeSheet = .newCutling
                    }
                }
                #endif
        }
    }
    
    // MARK: - Main Content View
    
    private var mainContent: some View {
        Group {
            if mode == .ordering {
                orderingListView
            } else {
                gridScrollView
            }
        }
        #if os(iOS)
        .background {
            Color(uiColor: .systemGroupedBackground)
                .padding(-50)
                .ignoresSafeArea()
        }
        #endif
        #if os(macOS)
        .background(.background)
        #endif
        .navigationTitle("Cutlings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .modifier(SubtitleModifier(count: store.cutlings.count))
        .searchable(text: $searchText, isPresented: $searchIsPresented, prompt: "Search cutlings")
        #if os(iOS)
        .toolbar(mode != .browsing ? .visible : .hidden, for: .bottomBar)
        #endif
        .toolbar {
            #if os(iOS)
            if mode == .browsing {
                if #available(iOS 26, *) {
                    ToolbarItem(placement: .primaryAction) {
                        addMenu
                    }
                    .matchedTransitionSource(id: addButtonZoomID, in: zoomNamespace)
                } else {
                    ToolbarItem(placement: .primaryAction) {
                        addMenu
                    }
                }
            }
            #endif
            if mode == .browsing {
                #if os(iOS)
                if #available(iOS 26, *) {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            activeSheet = .keyboardManager
                        } label: {
                            Image(systemName: "keyboard")
                        }
                        .accessibilityIdentifier("keyboardToolbarButton")
                    }
                    .matchedTransitionSource(id: keyboardButtonZoomID, in: zoomNamespace)
                } else {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            activeSheet = .keyboardManager
                        } label: {
                            Image(systemName: "keyboard")
                        }
                        .accessibilityIdentifier("keyboardToolbarButton")
                    }
                }
                #endif
                #if os(macOS)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        activeSheet = .keyboardManager
                    } label: {
                        Image(systemName: "keyboard")
                    }
                    .accessibilityIdentifier("keyboardToolbarButton")
                }
                #endif
            }
            ToolbarItemGroup(placement: .primaryAction) {
                primaryToolbarContent
            }
            
            #if os(iOS)
            ToolbarItemGroup(placement: .bottomBar) {
                bottomToolbarContent
            }
            #endif
            #if os(macOS)
            ToolbarItemGroup(placement: .automatic) {
                macOSToolbarContent
            }
            #endif
        }
    }
    
    // MARK: - Toolbar Content Views
    
    @ViewBuilder
    private var primaryToolbarContent: some View {
        switch mode {
        case .browsing:
            browsingToolbarItems
        case .selecting:
            selectingPrimaryToolbarItems
        case .ordering:
            orderingPrimaryToolbarItems
        }
    }
    
    @ViewBuilder
    private var bottomToolbarContent: some View {
        switch mode {
        case .selecting:
            selectingBottomToolbarItems
        case .ordering:
            orderingBottomToolbarItems
        case .browsing:
            EmptyView()
        }
    }
    
    #if os(macOS)
    @ViewBuilder
    private var macOSToolbarContent: some View {
        switch mode {
        case .selecting:
            Button {
                shareSelectedCutlings()
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .disabled(selectedIDs.isEmpty)
            Button(role: .destructive) {
                if !selectedIDs.isEmpty {
                    showDeleteConfirmation = true
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .keyboardShortcut(.delete, modifiers: [])
            .disabled(selectedIDs.isEmpty)
            .confirmationDialog(
                "Delete \(selectedIDs.count) item\(selectedIDs.count == 1 ? "" : "s")?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteSelectedCutlings()
                }
                Button("Cancel", role: .cancel) {}
            }
        case .ordering:
            Menu {
                Button { sortCutlings(by: .nameAscending) } label: { Label("Name (A → Z)", systemImage: "textformat.abc") }
                Button { sortCutlings(by: .nameDescending) } label: { Label("Name (Z → A)", systemImage: "textformat.abc") }
                Divider()
                Button { sortCutlings(by: .textFirst) } label: { Label("Text First", systemImage: "doc.text") }
                Button { sortCutlings(by: .imageFirst) } label: { Label("Images First", systemImage: "photo") }
                Divider()
                Button { sortCutlings(by: .shortestFirst) } label: { Label("Shortest First", systemImage: "text.line.first.and.arrowtriangle.forward") }
                Button { sortCutlings(by: .longestFirst) } label: { Label("Longest First", systemImage: "text.line.last.and.arrowtriangle.forward") }
                Divider()
                Button { sortCutlings(by: .reverse) } label: { Label("Reverse Order", systemImage: "arrow.up.arrow.down") }
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down.circle")
            }
            .menuIndicator(.hidden)
        case .browsing:
            EmptyView()
        }
    }
    #endif
    
    // MARK: - Mode Change Handler
    
    private func handleModeChange(_ newValue: MainContentMode) {
        #if os(iOS)
        panGesture?.isEnabled = newValue == .selecting
        if newValue != .selecting {
            selectionProperties = .init()
        }
        #endif
        #if os(macOS)
        if newValue != .selecting {
            selectedCutlingIDs.removeAll()
        }
        #endif

        withAccessibleAnimation {
            if newValue != .browsing {
                searchText = ""
                searchIsPresented = false
            }
        }
    }

    // MARK: - Navigation Title

    // MARK: - Ordering List View

    private var orderingListView: some View {
        List {
            ForEach(store.cutlings) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.icon)
                        .font(.title3)
                        .foregroundStyle(item.tintColor)
                        .frame(width: 28)

                    if item.kind == .image,
                       let filename = item.imageFilename,
                       let thumbnail = store.loadThumbnail(named: filename) {
                        Image(platformImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.body.weight(.medium))
                            .lineLimit(1)
                        if item.kind == .text {
                            Text(item.value)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .onMove(perform: moveCutlings)
        }
        #if os(iOS)
        .environment(\.editMode, .constant(.active))
        .listStyle(.insetGrouped)
        #endif
        #if os(macOS)
        .listStyle(.inset)
        #endif
    }

    // MARK: - Grid Scroll View

    private var gridScrollView: some View {
        ScrollView {
            if filtered.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: searchText.isEmpty ? "tray" : "magnifyingglass")
                        .font(.system(size: 48, weight: .thin))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                    Text(searchText.isEmpty ? "No Cutlings Yet" : "No Results")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(searchText.isEmpty ? "Tap + to add your first cutling." : "Try a different search term.")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                .accessibilityElement(children: .combine)
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filtered) { item in
                        let isSelected = selectedIDs.contains(item.id)
                        let isMarkedForDeletion: Bool = {
                            #if os(iOS)
                            selectionProperties.toBeDeletedIDs.contains(item.id)
                            #endif
                            #if os(macOS)
                            false
                            #endif
                        }()

                        CardView(
                            item: item,
                            isSelecting: mode == .selecting,
                            isSelected: isSelected && !isMarkedForDeletion,
                            onEdit: {
                                selectedItem = item
                            },
                            onToggleSelection: {
                                toggleSelection(for: item)
                            },
                            onDelete: {
                                withAccessibleAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                                    store.delete(item)
                                }
                            }
                        )
                        .frame(height: cardHeight)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.85).combined(with: .opacity),
                            removal: .scale(scale: 0.85).combined(with: .opacity)
                        ))
                        .id(item.id)
                        #if os(iOS)
                        .matchedTransitionSource(id: item.id, in: zoomNamespace)
                        #endif
                        .onGeometryChange(for: CGRect.self) {
                            $0.frame(in: .global)
                        } action: { newValue in
                            cutlingLocations[item.id] = newValue
                        }
                    }
                }
                .padding()
//                #if os(iOS)
//                .padding(.bottom, searchIsPresented ? 0 : 160)
//                #else
//                .padding(.bottom, 40)
//                #endif
                .animation(reduceMotion ? .easeOut(duration: 0.15) : .spring(duration: 0.35, bounce: 0.2), value: filtered.map(\.id))
            }
        }
        #if os(iOS)
        .scrollPosition($scrollProperties.position)
        .onScrollGeometryChange(for: CGFloat.self, of: {
            $0.contentOffset.y + $0.contentInsets.top
        }, action: { _, newValue in
            scrollProperties.currentScrollOffset = newValue
        })
        .onChange(of: scrollProperties.direction) { _, newValue in
            if newValue != .none {
                guard scrollProperties.timer == nil else { return }
                scrollProperties.manualScrollOffset = scrollProperties.currentScrollOffset

                scrollProperties.timer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { _ in
                    let speed = scrollProperties.speed
                    if case .up = scrollProperties.direction {
                        scrollProperties.manualScrollOffset -= speed
                    }
                    if case .down = scrollProperties.direction {
                        scrollProperties.manualScrollOffset += speed
                    }
                    scrollProperties.position.scrollTo(y: scrollProperties.manualScrollOffset)
                }
                scrollProperties.timer?.fire()
            } else {
                resetScrollTimer()
            }
        }
        #endif
    }

    // MARK: - Toolbar Content

    #if os(iOS)
    private func presentNewCutlingSheet(_ draft: NewCutlingDraft) {
        newCutlingDraft = draft
        // Delay presentation one run loop so Menu dismissal/toolbar transition source
        // are resolved before opening the detail sheet.
        DispatchQueue.main.async {
            guard newCutlingDraft?.id == draft.id else { return }
            activeSheet = .newCutling
        }
    }

    @ViewBuilder
    private var addMenu: some View {
        Menu {
            Button {
                let canAddText = store.canAdd(.text)
                if canAddText.allowed {
                    presentNewCutlingSheet(NewCutlingDraft(kind: .text))
                } else {
                    limitAlertMessage = canAddText.reason ?? String(localized: "Cannot add text cutling")
                }
            } label: {
                Label("Text Cutling", systemImage: "doc.text")
            }
            Button {
                let canAddImage = store.canAdd(.image)
                if canAddImage.allowed {
                    presentNewCutlingSheet(NewCutlingDraft(kind: .image))
                } else {
                    limitAlertMessage = canAddImage.reason ?? String(localized: "Cannot add image cutling")
                }
            } label: {
                Label("Image Cutling", systemImage: "photo")
            }
        } label: {
            Image(systemName: "plus")
        }
        .menuIndicator(.hidden)
        .accessibilityLabel(String(localized: "Add cutling"))
    }
    #endif

    @ViewBuilder
    private var browsingToolbarItems: some View {
        #if os(macOS)
        Menu {
            Button {
                let canAddText = store.canAdd(.text)
                if canAddText.allowed {
                    openAddWindow(for: .text)
                } else {
                    limitAlertMessage = canAddText.reason ?? String(localized: "Cannot add text cutling")

                }
            } label: {
                Label("Text Cutling", systemImage: "doc.text")
            }
            Button {
                let canAddImage = store.canAdd(.image)
                if canAddImage.allowed {
                    openAddWindow(for: .image)
                } else {
                    limitAlertMessage = canAddImage.reason ?? String(localized: "Cannot add image cutling")

                }
            } label: {
                Label("Image Cutling", systemImage: "photo")
            }
        } label: {
            Image(systemName: "plus")
        }
        .menuIndicator(.hidden)
        #endif
        
        Menu {
            Button {
                mode = .selecting
            } label: {
                Label("Select Cutlings", systemImage: "checkmark.circle")
            }

            Button {
                mode = .ordering
            } label: {
                Label("Reorder Cutlings", systemImage: "arrow.up.arrow.down")
            }
            .disabled(store.cutlings.count < 2)

            #if os(iOS)
            #if DEBUG
            Button {
                activeSheet = .keyboardSetup
            } label: {
                Label("Keyboard Setup", systemImage: keyboardNeedsAttention ? "exclamationmark.triangle" : "keyboard.badge.ellipsis")
            }
            #else
            if keyboardNeedsAttention {
                Button {
                    activeSheet = .keyboardSetup
                } label: {
                    Label("Keyboard Setup", systemImage: "exclamationmark.triangle")
                }
            }
            #endif
            #endif

            Divider()

            Button {
                showRecentlyDeleted = true
            } label: {
                Label("Recently Deleted", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
        }
        .menuIndicator(.hidden)
        .accessibilityLabel(String(localized: "More options"))
    }

    @ViewBuilder
    private var selectingPrimaryToolbarItems: some View {
        Button {
            mode = .browsing
        } label: {
            if #available(iOS 26, macOS 26, *) {
                Image(systemName: "xmark")
            } else {
                Text("Cancel")
            }
        }
    }

    @ViewBuilder
    private var orderingPrimaryToolbarItems: some View {
        Button {
            mode = .browsing
        } label: {
            if #available(iOS 26, macOS 26, *) {
                Image(systemName: "checkmark")
            } else {
                Text("Done")
            }
        }
    }

    @ViewBuilder
    private var selectingBottomToolbarItems: some View {
        Button {
            shareSelectedCutlings()
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .disabled(selectedIDs.isEmpty)
        Spacer()
        Button(role: .destructive) {
            if !selectedIDs.isEmpty {
                showDeleteConfirmation = true
            }
        } label: {
            Image(systemName: "trash")
                .foregroundStyle(selectedIDs.isEmpty ? Color.secondary : Color.red)
        }
        .disabled(selectedIDs.isEmpty)
        .confirmationDialog(
            "Delete \(selectedIDs.count) item\(selectedIDs.count == 1 ? "" : "s")?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteSelectedCutlings()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var orderingBottomToolbarItems: some View {
        Menu {
            Button {
                sortCutlings(by: .nameAscending)
            } label: {
                Label("Name (A → Z)", systemImage: "textformat.abc")
            }
            Button {
                sortCutlings(by: .nameDescending)
            } label: {
                Label("Name (Z → A)", systemImage: "textformat.abc")
            }
            Divider()
            Button {
                sortCutlings(by: .textFirst)
            } label: {
                Label("Text First", systemImage: "doc.text")
            }
            Button {
                sortCutlings(by: .imageFirst)
            } label: {
                Label("Images First", systemImage: "photo")
            }
            Divider()
            Button {
                sortCutlings(by: .shortestFirst)
            } label: {
                Label("Shortest First", systemImage: "text.line.first.and.arrowtriangle.forward")
            }
            Button {
                sortCutlings(by: .longestFirst)
            } label: {
                Label("Longest First", systemImage: "text.line.last.and.arrowtriangle.forward")
            }
            Divider()
            Button {
                sortCutlings(by: .reverse)
            } label: {
                Label("Reverse Order", systemImage: "arrow.up.arrow.down")
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down.circle")
        }
        Spacer()
    }

    // MARK: - Sorting

    private enum SortOrder {
        case nameAscending, nameDescending
        case textFirst, imageFirst
        case shortestFirst, longestFirst
        case reverse
    }

    private func sortCutlings(by order: SortOrder) {
        withAccessibleAnimation(.spring(duration: 0.35, bounce: 0.2)) {
            switch order {
            case .nameAscending:
                store.sortCutlings { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            case .nameDescending:
                store.sortCutlings { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
            case .textFirst:
                store.sortCutlings { lhs, rhs in
                    if lhs.kind == rhs.kind { return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending }
                    return lhs.kind == .text
                }
            case .imageFirst:
                store.sortCutlings { lhs, rhs in
                    if lhs.kind == rhs.kind { return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending }
                    return lhs.kind == .image
                }
            case .shortestFirst:
                store.sortCutlings { $0.value.count < $1.value.count }
            case .longestFirst:
                store.sortCutlings { $0.value.count > $1.value.count }
            case .reverse:
                store.reverseCutlings()
            }
        }
    }

    // MARK: - Move / Reorder

    private func moveCutlings(from source: IndexSet, to destination: Int) {
        store.moveCutlings(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Gesture Handling (mirrors reference exactly)

    #if os(iOS)
    private func onGestureChange(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let position = gesture.location(in: view)
        let edgeThreshold: CGFloat = 320

        if let fallingIndex = filtered.indices.first(where: {
            cutlingLocations[filtered[$0].id]?.contains(position) == true
        }) {
            if selectionProperties.start == nil {
                selectionProperties.start = fallingIndex
                selectionProperties.isDeleteDrag = selectionProperties.previousIDs.contains(filtered[fallingIndex].id)
            }

            selectionProperties.end = fallingIndex

            if let start = selectionProperties.start, let end = selectionProperties.end {
                let range = (start > end ? end...start : start...end)
                let rangeIDs = Set(range.map { filtered[$0].id })

                if selectionProperties.isDeleteDrag {
                    selectionProperties.toBeDeletedIDs = selectionProperties.previousIDs.intersection(rangeIDs)
                } else {
                    selectionProperties.selectedIDs = selectionProperties.previousIDs.union(rangeIDs)
                }
            }
        }

        // Check scroll direction and calculate speed based on how deep into the edge zone
        if position.y < edgeThreshold {
            let depth = (edgeThreshold - position.y) / edgeThreshold // 0…1
            scrollProperties.speed = 3 + depth * 12 // 3…15
            scrollProperties.direction = .up
        } else if position.y > view.bounds.height - edgeThreshold {
            let depth = (position.y - (view.bounds.height - edgeThreshold)) / edgeThreshold // 0…1
            scrollProperties.speed = 3 + depth * 12 // 3…15
            scrollProperties.direction = .down
        } else {
            scrollProperties.speed = 0
            scrollProperties.direction = .none
        }
    }

    private func onGestureEnded() {
        // Remove IDs that were marked for deletion during a deselect-drag
        selectionProperties.selectedIDs.subtract(selectionProperties.toBeDeletedIDs)
        selectionProperties.toBeDeletedIDs = []

        // Commit the current selection as the new baseline
        selectionProperties.previousIDs = selectionProperties.selectedIDs
        selectionProperties.start = nil
        selectionProperties.end = nil
        selectionProperties.isDeleteDrag = false

        resetScrollTimer()
    }

    private func resetScrollTimer() {
        scrollProperties.manualScrollOffset = 0
        scrollProperties.timer?.invalidate()
        scrollProperties.timer = nil
        scrollProperties.direction = .none
        scrollProperties.speed = 0
    }
    #endif

    // MARK: - Tap Selection

    private func toggleSelection(for cutling: Cutling) {
        #if os(iOS)
        if selectionProperties.selectedIDs.contains(cutling.id) {
            selectionProperties.selectedIDs.remove(cutling.id)
        } else {
            selectionProperties.selectedIDs.insert(cutling.id)
        }
        // Commit after tap, just like the reference
        selectionProperties.previousIDs = selectionProperties.selectedIDs
        #endif
        #if os(macOS)
        if selectedCutlingIDs.contains(cutling.id) {
            selectedCutlingIDs.remove(cutling.id)
        } else {
            selectedCutlingIDs.insert(cutling.id)
        }
        #endif
    }

    // MARK: - Delete

    private func deleteSelectedCutlings() {
        let idsToDelete = selectedIDs
        let cutlingsToDelete = store.cutlings.filter { idsToDelete.contains($0.id) }
        showDeleteConfirmation = false
        withAccessibleAnimation(.spring(duration: 0.35, bounce: 0.2)) {
            for cutling in cutlingsToDelete {
                store.delete(cutling)
            }
        }
        Task { @MainActor in
            #if os(iOS)
            selectionProperties = .init()
            #endif
            #if os(macOS)
            selectedCutlingIDs.removeAll()
            #endif
            mode = .browsing
        }
    }
    
    // MARK: - Share

    private func shareSelectedCutlings() {
        let selected = store.cutlings.filter { selectedIDs.contains($0.id) }
        guard !selected.isEmpty else { return }

        var items: [NSItemProvider] = []
        for cutling in selected {
            switch cutling.kind {
            case .text:
                let provider = NSItemProvider(item: cutling.value as NSString, typeIdentifier: UTType.plainText.identifier)
                provider.suggestedName = cutling.name
                if let url = URL(string: cutling.value.trimmingCharacters(in: .whitespacesAndNewlines)),
                   let scheme = url.scheme, ["http", "https", "ftp"].contains(scheme.lowercased()) {
                    provider.registerDataRepresentation(for: .url, visibility: .all) { handler in
                        handler(url.absoluteString.data(using: .utf8), nil)
                        return nil
                    }
                } else if cutling.value.trimmingCharacters(in: .whitespacesAndNewlines).contains("@"),
                          let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue),
                          let match = detector.firstMatch(in: cutling.value, range: NSRange(cutling.value.startIndex..., in: cutling.value)),
                          let matchURL = match.url, matchURL.scheme == "mailto" {
                    provider.registerDataRepresentation(for: .url, visibility: .all) { handler in
                        handler(matchURL.absoluteString.data(using: .utf8), nil)
                        return nil
                    }
                }
                items.append(provider)
            case .image:
                if let filename = cutling.imageFilename,
                   let data = store.loadImageData(named: filename) {
                    let provider = NSItemProvider(item: data as NSData, typeIdentifier: UTType.image.identifier)
                    provider.suggestedName = cutling.name
                    let previewData = data
                    provider.previewImageHandler = { completionHandler, _, _ in
                        completionHandler?(previewData as NSData, nil)
                    }
                    items.append(provider)
                }
            }
        }
        guard !items.isEmpty else { return }

        #if os(iOS)
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              var topController = window.rootViewController else { return }
        while let presented = topController.presentedViewController {
            topController = presented
        }
        activityVC.popoverPresentationController?.sourceView = topController.view
        activityVC.popoverPresentationController?.sourceRect = CGRect(
            x: topController.view.bounds.midX,
            y: topController.view.bounds.midY,
            width: 0, height: 0
        )
        topController.present(activityVC, animated: true)
        #endif
        #if os(macOS)
        let picker = NSSharingServicePicker(items: items)
        guard let window = NSApp.keyWindow,
              let contentView = window.contentView else { return }
        picker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
        #endif
    }

    // MARK: - Scroll to New Item
    
    private func scrollToBottom() {
        #if os(iOS)
        withAccessibleAnimation(.spring(duration: 0.5, bounce: 0.3)) {
            scrollProperties.position.scrollTo(edge: .bottom)
        }
        #endif
        #if os(macOS)
        // On macOS, we can use the same approach if needed
        // For now, the list is typically smaller and visible
        #endif
    }

    // MARK: - Menu Commands (macOS)

    #if os(macOS)
    private func updateMenuCommands() {
        menuCommands.enterSelectMode = { mode = .selecting }
        menuCommands.enterReorderMode = { mode = .ordering }
        menuCommands.deleteSelected = {
            if !selectedIDs.isEmpty {
                showDeleteConfirmation = true
            }
        }
        menuCommands.selectedCount = selectedIDs.count
        menuCommands.cutlingsCount = store.cutlings.count
    }
    #endif
}

// MARK: - Pan Gesture Recognizer

#if os(iOS)
@available(iOS 18.0, *)
struct PanGestureRecognizer: UIGestureRecognizerRepresentable {
    var handle: (UIPanGestureRecognizer) -> ()
    
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        return UIPanGestureRecognizer()
    }
    
    func updateUIGestureRecognizer(_ recognizer: UIPanGestureRecognizer, context: Context) {}
    
    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        handle(recognizer)
    }
}
#endif

// MARK: - Pan Gesture Modifier

#if os(iOS)
struct PanGestureModifier: ViewModifier {
    let isSelecting: Bool
    @Binding var panGesture: UIPanGestureRecognizer?
    let onPanChange: (UIPanGestureRecognizer) -> Void
    let onPanEnd: () -> Void

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .gesture(
                    PanGestureRecognizer { gesture in
                        if panGesture == nil {
                            panGesture = gesture
                            gesture.isEnabled = isSelecting
                        }
                        switch gesture.state {
                        case .began, .changed:
                            onPanChange(gesture)
                        case .ended, .cancelled, .failed:
                            onPanEnd()
                        default:
                            break
                        }
                    }
                )
        } else {
            content
        }
    }
}
#endif

// MARK: - Helper View Modifiers

private struct SubtitleModifier: ViewModifier {
    let count: Int

    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .navigationSubtitle("\(count) Cutlings")
        #endif
        #if os(iOS)
        if #available(iOS 26, *) {
            content
                .navigationSubtitle("\(count) Cutlings")
        } else {
            content
        }
        #endif
    }
}

struct SheetsModifier: ViewModifier {
    @EnvironmentObject var store: CutlingStore
    @Binding var selectedItem: Cutling?

    #if os(macOS)
    @Environment(\.openWindow) private var openWindow
    #endif

    func body(content: Content) -> some View {
        content
            #if os(macOS)
            .onChange(of: selectedItem) { _, newItem in
                if let item = newItem {
                    openWindow(id: "editCutling", value: item.id)
                    selectedItem = nil
                }
            }
            #endif
    }
}

struct AlertsModifier: ViewModifier {
    @Binding var limitAlertMessage: String?

    func body(content: Content) -> some View {
        content
            .alert(
                "Limit Reached",
                isPresented: Binding(
                    get: { limitAlertMessage != nil },
                    set: { if !$0 { limitAlertMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(limitAlertMessage ?? "")
            }
    }
}

struct ChangeHandlersModifier: ViewModifier {
    let mode: MainContentMode
    let lastAddedCutlingID: UUID?
    @Binding var selectedItem: Cutling?
    @Binding var activeSheet: ActiveSheet?
    @Binding var hasScrolledToNew: Bool
    let onModeChange: (MainContentMode) -> Void
    let onScrollToNew: () -> Void

    @Environment(\.requestReview) private var requestReview
    @AppStorage("lastVersionPromptedForReview") private var lastVersionPromptedForReview = ""

    private var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: mode) { _, newValue in
                onModeChange(newValue)
            }
            .onChange(of: lastAddedCutlingID) { _, newID in
                guard newID != nil, !hasScrolledToNew else { return }
                hasScrolledToNew = true

                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(100))
                    onScrollToNew()

                    try? await Task.sleep(for: .seconds(1))
                    hasScrolledToNew = false
                }

                requestReviewIfAppropriate()
            }
            .onChange(of: selectedItem) { old, new in
                if old != nil, new == nil {
                    requestReviewIfAppropriate()
                }
            }
            #if os(iOS)
            .onChange(of: activeSheet) { old, new in
                if old != nil, new == nil {
                    requestReviewIfAppropriate()
                }
            }
            #endif
    }

    private func requestReviewIfAppropriate() {
        let pasteCount = UserDefaults(suiteName: appGroupID)?.integer(forKey: "keyboardPasteCount") ?? 0

        guard pasteCount >= 5,
              currentAppVersion != lastVersionPromptedForReview else {
            return
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            requestReview()
            lastVersionPromptedForReview = currentAppVersion
        }
    }
}

// MARK: - Preview

#Preview {
    MainContentView()
        .environmentObject(CutlingStore.shared)
    #if os(macOS)
        .frame(width: 400, height: 500)
    #endif
}
