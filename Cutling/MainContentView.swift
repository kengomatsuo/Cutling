//
//  MainContentView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import SwiftUI

#if os(iOS)
import UIKit
#else
import AppKit
#endif

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

// MARK: - Cross-Platform Image Helpers

#if os(iOS)
func loadPlatformImage(from data: Data) -> UIImage? {
    UIImage(data: data)
}

extension Image {
    init(platformImage: UIImage) {
        self.init(uiImage: platformImage)
    }
}
#else
func loadPlatformImage(from data: Data) -> NSImage? {
    NSImage(data: data)
}

extension Image {
    init(platformImage: NSImage) {
        self.init(nsImage: platformImage)
    }
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
    @EnvironmentObject var store: CutlingStore

    @State private var searchText = ""
    @State private var searchIsPresented = false
    @State private var selectedItem: Cutling? = nil
    @State private var showAddText = false
    @State private var showAddImage = false
    @State private var newCutlingKind: CutlingKind? = nil
    @Binding var showKeyboard: Bool
    
    @State private var showKeyboardSetup = false
    @State private var showRecentlyDeleted = false
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""

    @State private var mode: MainContentMode = .browsing
    @State private var showBottomBar = false
    @State private var showDeleteConfirmation = false

    #if os(iOS)
    @State private var panGesture: UIPanGestureRecognizer?
    @State private var selectionProperties: SelectionProperties = .init()
    @State private var scrollProperties: ScrollProperties = .init()
    #else
    // macOS doesn't use pan gesture selection, so just keep a simple set
    @State private var selectedCutlingIDs: Set<UUID> = []
    @State private var menuCommands = MainContentCommands()
    #endif

    @State private var cutlingLocations: [UUID: CGRect] = [:]
    @State private var hasScrolledToNew = false

    #if os(iOS)
    @Namespace private var zoomNamespace
    private let addButtonZoomID = "addButton"
    private let keyboardButtonZoomID = "keyboardButton"
    #endif

    init(showKeyboard: Binding<Bool> = .constant(false)) {
        _showKeyboard = showKeyboard
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
    #else
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
        #else
        selectedCutlingIDs
        #endif
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            mainContent
                .modifier(SheetsModifier(
                    selectedItem: $selectedItem,
                    showAddText: $showAddText,
                    showAddImage: $showAddImage,
                    showKeyboardSetup: $showKeyboardSetup
                ))
                .modifier(AlertsModifier(
                    showLimitAlert: $showLimitAlert,
                    limitAlertMessage: limitAlertMessage
                ))
                .modifier(ChangeHandlersModifier(
                    mode: mode,
                    lastAddedCutlingID: store.lastAddedCutlingID,
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
                .sheet(item: $newCutlingKind) { kind in
                    Group {
                        switch kind {
                        case .text:
                            TextDetailView(item: nil, presentedAsSheet: true)
                        case .image:
                            ImageDetailView(item: nil, presentedAsSheet: true)
                        }
                    }
                    .navigationTransition(.zoom(sourceID: addButtonZoomID, in: zoomNamespace))
                }
                .sheet(isPresented: $showKeyboard) {
                    KeyboardView()
                        .navigationTransition(.zoom(sourceID: keyboardButtonZoomID, in: zoomNamespace))
                }
                #endif
                #if os(macOS)
                .sheet(isPresented: $showKeyboard) {
                    KeyboardView()
                        .environmentObject(store)
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
        .background(Color(uiColor: .systemGroupedBackground))
        #else
        .background(.background)
        #endif
        .navigationTitle("Cutlings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .modifier(SubtitleModifier(count: store.cutlings.count))
        .searchable(text: $searchText, isPresented: $searchIsPresented, prompt: "Search cutlings")
        #if os(iOS)
        .toolbar(showBottomBar ? .visible : .hidden, for: .bottomBar)
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
                            showKeyboard = true
                        } label: {
                            Image(systemName: "keyboard")
                        }
                        .accessibilityIdentifier("keyboardToolbarButton")
                    }
                    .matchedTransitionSource(id: keyboardButtonZoomID, in: zoomNamespace)
                } else {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showKeyboard = true
                        } label: {
                            Image(systemName: "keyboard")
                        }
                        .accessibilityIdentifier("keyboardToolbarButton")
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showKeyboard = true
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
            #else
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
        #else
        if newValue != .selecting {
            selectedCutlingIDs.removeAll()
        }
        #endif

        withAnimation {
            showBottomBar = newValue != .browsing
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
        #else
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
                    Text(searchText.isEmpty ? "No Cutlings Yet" : "No Results")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(searchText.isEmpty ? "Tap + to add your first cutling." : "Try a different search term.")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filtered) { item in
                        let isSelected = selectedIDs.contains(item.id)
                        let isMarkedForDeletion: Bool = {
                            #if os(iOS)
                            selectionProperties.toBeDeletedIDs.contains(item.id)
                            #else
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
                                withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
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
                .animation(.spring(duration: 0.35, bounce: 0.2), value: filtered.map(\.id))
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
    @ViewBuilder
    private var addMenu: some View {
        Menu {
            Button {
                let canAddText = store.canAdd(.text)
                if canAddText.allowed {
                    newCutlingKind = .text
                } else {
                    limitAlertMessage = canAddText.reason ?? String(localized: "Cannot add text cutling")
                    showLimitAlert = true
                }
            } label: {
                Label("Text Cutling", systemImage: "doc.text")
            }
            Button {
                let canAddImage = store.canAdd(.image)
                if canAddImage.allowed {
                    newCutlingKind = .image
                } else {
                    limitAlertMessage = canAddImage.reason ?? String(localized: "Cannot add image cutling")
                    showLimitAlert = true
                }
            } label: {
                Label("Image Cutling", systemImage: "photo")
            }
        } label: {
            Image(systemName: "plus")
        }
        .menuIndicator(.hidden)
    }
    #endif

    @ViewBuilder
    private var browsingToolbarItems: some View {
        #if os(macOS)
        Menu {
            Button {
                let canAddText = store.canAdd(.text)
                if canAddText.allowed {
                    showAddText = true
                } else {
                    limitAlertMessage = canAddText.reason ?? String(localized: "Cannot add text cutling")
                    showLimitAlert = true
                }
            } label: {
                Label("Text Cutling", systemImage: "doc.text")
            }
            Button {
                let canAddImage = store.canAdd(.image)
                if canAddImage.allowed {
                    showAddImage = true
                } else {
                    limitAlertMessage = canAddImage.reason ?? String(localized: "Cannot add image cutling")
                    showLimitAlert = true
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
            if keyboardNeedsAttention {
                Button {
                    showKeyboardSetup = true
                } label: {
                    Label("Keyboard Setup", systemImage: "exclamationmark.triangle")
                }
            }
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
        withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
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
        #else
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
        withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
            for cutling in cutlingsToDelete {
                store.delete(cutling)
            }
        }
        Task { @MainActor in
            #if os(iOS)
            selectionProperties = .init()
            #else
            selectedCutlingIDs.removeAll()
            #endif
            mode = .browsing
        }
    }
    
    // MARK: - Scroll to New Item
    
    private func scrollToBottom() {
        #if os(iOS)
        withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
            scrollProperties.position.scrollTo(edge: .bottom)
        }
        #else
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

// MARK: - Card Shape

private let cardShape = RoundedRectangle(
    cornerRadius: .init(24),
    style: .continuous
)

// MARK: - Card View

struct CardView: View {
    @EnvironmentObject var store: CutlingStore

    let item: Cutling
    let isSelecting: Bool
    let isSelected: Bool
    let onEdit: () -> Void
    let onToggleSelection: () -> Void
    let onDelete: () -> Void

    @State private var copied = false
    @State private var showInfo = false
    
    #if os(iOS)
    // Reusable haptic generator for better performance
    private static let haptic = UIImpactFeedbackGenerator(style: .light)
    #endif

    var body: some View {
        cardContent
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            #if os(iOS)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            #else
            .background(.background.secondary)
            #endif
            .contentShape(cardShape)
            .clipShape(cardShape)
            #if os(iOS)
            .contentShape(.contextMenuPreview, cardShape)
            #endif
            .overlay(alignment: .center) {
                copiedOverlay
            }
            .animation(.spring(), value: copied)
            #if os(iOS)
            .contextMenu {
                cardContextMenu
            } preview: {
                previewContent
            }
            #else
            .contextMenu {
                cardContextMenu
            }
            #endif
            .accessibilityIdentifier("cutlingCard")
            .onTapGesture {
                handleTap()
            }
            .sheet(isPresented: $showInfo) {
                CutlingInfoView(item: item)
                    .environmentObject(store)
            }
    }
    
    // MARK: - Card Content
    
    @ViewBuilder
    private var cardContent: some View {
        switch item.kind {
        case .text:
            textCard
        case .image:
            imageCard
        }
    }
    
    @ViewBuilder
    private var copiedOverlay: some View {
        if copied {
            Label("Copied", systemImage: "checkmark")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.thinMaterial)
                .clipShape(Capsule())
                .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
    }
    
    @ViewBuilder
    private var cardContextMenu: some View {
        if !isSelecting {
            ControlGroup {
                Button {
                    copyToClipboard()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }

                Button {
                    shareItem()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }

            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .accessibilityIdentifier("editButton")

            Button {
                store.duplicate(item)
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }

            Button {
                showInfo = true
            } label: {
                Label("Get Info", systemImage: "info.circle")
            }

            Divider()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func handleTap() {
        #if os(iOS)
        if !isSelecting {
            Self.haptic.impactOccurred()
        }
        #endif
        if isSelecting {
            onToggleSelection()
        } else {
            copyToClipboard()
        }
    }

    // MARK: - Text Card

    private var textCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Image(systemName: item.icon)
                    .font(.title2)
                    .foregroundStyle(item.tintColor)
                Spacer()
                topRightButton
            }
            Text(item.name)
                .font(.headline)
                .lineLimit(1)
            Text(item.value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .truncationMode(.tail)
            if let expiresAt = item.expiresAt, expiresAt > Date() {
                Spacer(minLength: 0)
                Label {
                    Text(expiresAt, style: .timer)
                } icon: {
                    Image(systemName: "clock")
                }
                .font(.caption2)
                .foregroundStyle(.orange)
            }
        }
        .padding()
    }

    // MARK: - Image Card

    private var imageCard: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                if let filename = item.imageFilename,
                   let thumbnail = store.loadThumbnail(named: filename) {
                    Image(platformImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    Color.secondary.opacity(0.15)
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        .frame(width: geo.size.width, height: geo.size.height)
                }

                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        topRightButton
                            .shadow(radius: 2)
                    }
                    Spacer()
                    HStack {
                        Text(item.name)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                            .lineLimit(1)
                        if let expiresAt = item.expiresAt, expiresAt > Date() {
                            Spacer()
                            Label {
                                Text(expiresAt, style: .timer)
                            } icon: {
                                Image(systemName: "clock")
                            }
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.85))
                            .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                        }
                    }
                }
                .padding()
                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                .background(
                    LinearGradient(
                        colors: [.clear, .clear, .black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }

    // MARK: - Preview Content

    #if os(iOS)
    @ViewBuilder
    private var previewContent: some View {
        switch item.kind {
        case .text:
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: item.icon)
                        .font(.title2)
                        .foregroundStyle(item.tintColor)
                    Text(item.name)
                        .font(.headline)
                    Spacer()
                }

                Text(item.value)
                    .font(.body)
                    .lineLimit(18)
            }
            .padding()
            .frame(
                width: min(UIScreen.main.bounds.width - 40, 350),
                alignment: .leading
            )
            .fixedSize(horizontal: false, vertical: true)
            .background(.background)
            
        case .image:
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: item.icon)
                        .foregroundStyle(item.tintColor)
                    Text(item.name)
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(.background)
                
                if let filename = item.imageFilename,
                   let data = store.loadImageData(named: filename),
                   let img = loadPlatformImage(from: data) {
                    Image(platformImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(minHeight: 100, maxHeight: 500)
                }
            }
            .frame(width: min(UIScreen.main.bounds.width - 40, 350))
            .background(.background)
        }
    }
    #endif

    // MARK: - Shared

    private var topRightButton: some View {
        Button {
            if isSelecting {
                onToggleSelection()
            } else {
                onEdit()
            }
        } label: {
            ZStack {
                if !isSelecting {
                    Circle()
                        .fill(item.kind == .image ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(.quinary))
                }
                
                if isSelecting {
                    // Selection mode: animate between circle and checkmark
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(
                            isSelected ? Color.white : (item.kind == .image ? Color.white : Color.primary),
                            isSelected ? Color.accentColor : (item.kind == .image ? Color.white : Color.primary)
                        )
                        .scaleEffect(isSelected ? 1.3 : 1.2)
                        .rotationEffect(.degrees(isSelected ? 0 : -15))
                        .animation(.spring(duration: 0.15), value: isSelected)
                } else {
                    // Browse mode: no animation
                    Image(systemName: "ellipsis")
                        .font(.subheadline)
                        .foregroundStyle(Color.primary)
                        .scaleEffect(1.3)
                }
            }
            .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
    }

    private func copyToClipboard() {
        switch item.kind {
        case .text:
            #if os(iOS)
            UIPasteboard.general.string = item.value
            #else
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(item.value, forType: .string)
            #endif

        case .image:
            if let filename = item.imageFilename,
               let data = store.loadImageData(named: filename) {
                #if os(iOS)
                if let uiImage = UIImage(data: data) {
                    UIPasteboard.general.image = uiImage
                }
                #else
                if let nsImage = NSImage(data: data) {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.writeObjects([nsImage])
                }
                #endif
            }
        }

        copied = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            copied = false
        }
    }

    private func shareItem() {
        switch item.kind {
        case .text:
            presentShareSheet(items: [item.value])
        case .image:
            guard let filename = item.imageFilename,
                  let data = store.loadImageData(named: filename) else { return }
            #if os(iOS)
            guard let image = UIImage(data: data) else { return }
            presentShareSheet(items: [image])
            #else
            guard let image = NSImage(data: data) else { return }
            presentShareSheet(items: [image])
            #endif
        }
    }

    private func presentShareSheet(items: [Any]) {
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
        #else
        let picker = NSSharingServicePicker(items: items)
        guard let window = NSApp.keyWindow,
              let contentView = window.contentView else { return }
        picker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
        #endif
    }
}

// MARK: - Get Info View

struct CutlingInfoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: CutlingStore

    let item: Cutling

    private var imageFileSize: Int? {
        guard let filename = item.imageFilename,
              let data = store.loadImageData(named: filename) else { return nil }
        return data.count
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    LabeledContent("Name", value: item.name)
                    LabeledContent("Kind", value: item.kind == .text ? String(localized: "Text") : String(localized: "Image"))
                    if let colorName = item.color {
                        LabeledContent("Color") {
                            HStack {
                                Text(colorName.capitalized)
                                Circle()
                                    .fill(item.tintColor)
                                    .frame(width: 14, height: 14)
                            }
                        }
                    }
                }

                Section("Size") {
                    if item.kind == .text {
                        LabeledContent("Characters", value: "\(item.value.count)")
                        LabeledContent("Words", value: "\(wordCount)")
                        LabeledContent("Lines", value: "\(lineCount)")
                    } else if let size = imageFileSize {
                        LabeledContent("File Size", value: ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))
                    }
                }

                Section("Dates") {
                    LabeledContent("Created", value: item.createdDate.formatted(date: .abbreviated, time: .shortened))
                    LabeledContent("Modified", value: item.lastModifiedDate.formatted(date: .abbreviated, time: .shortened))
                    if let expiresAt = item.expiresAt {
                        LabeledContent("Expires", value: expiresAt.formatted(date: .abbreviated, time: .shortened))
                    }
                }

                if !item.assignedCategories.isEmpty {
                    Section("Input Types") {
                        ForEach(Array(item.assignedCategories).sorted(by: { $0.displayName < $1.displayName })) { category in
                            Label(category.displayName, systemImage: category.icon)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Info")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        #if os(iOS)
                        if #available(iOS 26, *) {
                            Image(systemName: "xmark")
                        } else {
                            Text("Done")
                        }
                        #else
                        Text("Done")
                        #endif
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 360, idealWidth: 400, minHeight: 300, idealHeight: 400)
        #endif
    }

    private var wordCount: Int {
        var count = 0
        item.value.enumerateSubstrings(in: item.value.startIndex..., options: [.byWords, .substringNotRequired]) { _, _, _, _ in
            count += 1
        }
        return count
    }

    private var lineCount: Int {
        item.value.isEmpty ? 0 : item.value.components(separatedBy: .newlines).count
    }
}

// MARK: - Helper View Modifiers

private struct SubtitleModifier: ViewModifier {
    let count: Int

    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .navigationSubtitle("\(count) Cutlings")
        #else
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
    @Binding var showAddText: Bool
    @Binding var showAddImage: Bool
    @Binding var showKeyboardSetup: Bool

    #if os(macOS)
    @Environment(\.openWindow) private var openWindow
    #endif

    func body(content: Content) -> some View {
        content
            #if os(iOS)
            .sheet(isPresented: $showKeyboardSetup) {
                KeyboardSetupView(isOnboarding: false)
            }
            #endif
            #if os(macOS)
            .onChange(of: selectedItem) { _, newItem in
                if let item = newItem {
                    openWindow(id: "editCutling", value: item.id)
                    selectedItem = nil
                }
            }
            .onChange(of: showAddText) { _, show in
                if show {
                    openWindow(id: "addText")
                    showAddText = false
                }
            }
            .onChange(of: showAddImage) { _, show in
                if show {
                    openWindow(id: "addImage")
                    showAddImage = false
                }
            }
            #endif
    }
}

struct AlertsModifier: ViewModifier {
    @Binding var showLimitAlert: Bool
    let limitAlertMessage: String
    
    func body(content: Content) -> some View {
        content
            .alert("Limit Reached", isPresented: $showLimitAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(limitAlertMessage)
            }
    }
}

struct ChangeHandlersModifier: ViewModifier {
    let mode: MainContentMode
    let lastAddedCutlingID: UUID?
    @Binding var hasScrolledToNew: Bool
    let onModeChange: (MainContentMode) -> Void
    let onScrollToNew: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onChange(of: mode) { _, newValue in
                onModeChange(newValue)
            }
            .onChange(of: lastAddedCutlingID) { _, newID in
                guard newID != nil, !hasScrolledToNew else { return }
                hasScrolledToNew = true
                
                // Wait a moment for the view to appear in the list
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(100))
                    onScrollToNew()
                    
                    // Reset the flag after a delay
                    try? await Task.sleep(for: .seconds(1))
                    hasScrolledToNew = false
                }
            }
            #if os(iOS)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // App became active
            }
            #else
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                // App became active
            }
            #endif
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
