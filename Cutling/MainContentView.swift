//
//  MainContentView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import SwiftUI

#if os(iOS)
import UIKit
private let platformGroupedBackground = UIColor.systemGroupedBackground
private let platformSecondaryGroupedBackground = UIColor.secondarySystemGroupedBackground
#else
import AppKit
private let platformGroupedBackground = NSColor(white: 0.93, alpha: 1.0)
private let platformSecondaryGroupedBackground = NSColor.white
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

// MARK: - Main Content

struct MainContentView: View {
    @EnvironmentObject var store: CutlingStore

    @State private var searchText = ""
    @State private var selectedItem: Cutling? = nil
    @State private var showAddText = false
    @State private var showAddImage = false
    @Binding var showSettings: Bool
    
    @State private var showKeyboardSetup = false
    @State private var showLimitAlert = false
    @State private var limitAlertMessage = ""

    @State private var isSelecting = false
    @State private var showDeleteConfirmation = false
    @State private var cutlingToDelete: Cutling?

    #if os(iOS)
    @State private var panGesture: UIPanGestureRecognizer?
    @State private var selectionProperties: SelectionProperties = .init()
    @State private var scrollProperties: ScrollProperties = .init()
    #else
    // macOS doesn't use pan gesture selection, so just keep a simple set
    @State private var selectedCutlingIDs: Set<UUID> = []
    #endif

    @State private var cutlingLocations: [UUID: CGRect] = [:]
    @State private var hasScrolledToNew = false

    init(showSettings: Binding<Bool> = .constant(false)) {
        _showSettings = showSettings
    }

    // MARK: - Keyboard Status

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

    let columns = [GridItem(.adaptive(minimum: 160, maximum: 240), spacing: 12)]

    var filtered: [Cutling] {
        if searchText.isEmpty { return store.cutlings }
        return store.cutlings.filter {
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
            ScrollView {
                // Storage usage indicator
                VStack(spacing: 6) {
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(store.textCutlingsCount)/\(CutlingStore.maxTextCutlings)")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "photo")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(store.imageCutlingsCount)/\(CutlingStore.maxImageCutlings)")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    if !filtered.isEmpty {
                        Divider()
                            .padding(.horizontal)
                    }
                }
                
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
                                isSelecting: isSelecting,
                                isSelected: isSelected && !isMarkedForDeletion,
                                onEdit: {
                                    selectedItem = item
                                },
                                onToggleSelection: {
                                    toggleSelection(for: item)
                                },
                                onDelete: {
                                    cutlingToDelete = item
                                    showDeleteConfirmation = true
                                }
                            )
                            .frame(height: 140)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.85).combined(with: .opacity),
                                removal: .scale(scale: 0.85).combined(with: .opacity)
                            ))
                            .id(item.id)
                            .onGeometryChange(for: CGRect.self) {
                                $0.frame(in: .global)
                            } action: { newValue in
                                cutlingLocations[item.id] = newValue
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 160)
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
            .background(Color(platformGroupedBackground))
            .navigationTitle("My Cutlings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(isSelecting ? .inline : .large)
            #endif
            .searchable(text: $searchText, prompt: "Search cutlings")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    if isSelecting {
                        Button {
                            isSelecting = false
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
                    } else {
                        Menu {
                            Button {
                                let canAddText = store.canAdd(.text)
                                if canAddText.allowed {
                                    showAddText = true
                                } else {
                                    limitAlertMessage = canAddText.reason ?? "Cannot add text cutling"
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
                                    limitAlertMessage = canAddImage.reason ?? "Cannot add image cutling"
                                    showLimitAlert = true
                                }
                            } label: {
                                Label("Image Cutling", systemImage: "photo")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                        
                        Menu {
                            Button {
                                isSelecting = true
                            } label: {
                                Label("Select Cutlings", systemImage: "checkmark.circle")
                            }

                            if keyboardNeedsAttention {
                                Button {
                                    showKeyboardSetup = true
                                } label: {
                                    Label("Keyboard Setup", systemImage: "exclamationmark.triangle")
                                }
                            }

                            Button {
                                showSettings = true
                            } label: {
                                Label("Settings", systemImage: "gearshape")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    if isSelecting {
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
                            isPresented: Binding(
                                get: { showDeleteConfirmation && cutlingToDelete == nil },
                                set: { if !$0 { showDeleteConfirmation = false } }
                            ),
                            titleVisibility: .visible
                        ) {
                            Button("Delete", role: .destructive) {
                                deleteSelectedCutlings()
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                switch item.kind {
                case .text:
                    TextDetailView(item: item)
                case .image:
                    ImageDetailView(item: item)
                }
            }
            .sheet(isPresented: $showAddText) {
                TextDetailView(item: nil)
            }
            .sheet(isPresented: $showAddImage) {
                ImageDetailView(item: nil)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showKeyboardSetup) {
                KeyboardSetupView(isOnboarding: false)
            }
            .alert("Limit Reached", isPresented: $showLimitAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(limitAlertMessage)
            }
            .alert(
                "Delete \"\(cutlingToDelete?.name ?? "")\"?",
                isPresented: Binding(
                    get: { showDeleteConfirmation && cutlingToDelete != nil },
                    set: { if !$0 { showDeleteConfirmation = false; cutlingToDelete = nil } }
                ),
                presenting: cutlingToDelete
            ) { cutling in
                Button("Delete", role: .destructive) {
                    withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                        store.delete(cutling)
                    }
                    cutlingToDelete = nil
                    showDeleteConfirmation = false
                }
                Button("Cancel", role: .cancel) {
                    cutlingToDelete = nil
                    showDeleteConfirmation = false
                }
            }
            .onChange(of: isSelecting) { _, newValue in
                #if os(iOS)
                panGesture?.isEnabled = newValue
                if !newValue {
                    selectionProperties = .init()
                }
                #else
                if !newValue {
                    selectedCutlingIDs.removeAll()
                }
                #endif
            }
            .onChange(of: store.lastAddedCutlingID) { _, newID in
                guard newID != nil, !hasScrolledToNew else { return }
                hasScrolledToNew = true
                
                // Wait a moment for the view to appear in the list
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(100))
                    scrollToBottom()
                    
                    // Reset the flag after a delay
                    try? await Task.sleep(for: .seconds(1))
                    hasScrolledToNew = false
                }
            }
            #if os(iOS)
            .modifier(PanGestureModifier(
                isSelecting: isSelecting,
                panGesture: $panGesture,
                onPanChange: onGestureChange,
                onPanEnd: onGestureEnded
            ))
            #endif
        }
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
            isSelecting = false
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
    
    #if os(iOS)
    // Reusable haptic generator for better performance
    private static let haptic = UIImpactFeedbackGenerator(style: .light)
    #endif

    var body: some View {
        Group {
            switch item.kind {
            case .text:
                textCard
            case .image:
                imageCard
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(platformSecondaryGroupedBackground))
        .contentShape(cardShape)
        .clipShape(cardShape)
        #if os(iOS)
        .contentShape(.contextMenuPreview, cardShape)
        #endif
        .overlay(alignment: .center) {
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
        .animation(.spring(), value: copied)
        .contextMenu {
            if !isSelecting {
                Button {
                    copyToClipboard()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }

                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Divider()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        } preview: {
            previewContent
        }
        .onTapGesture {
            #if os(iOS)
            Self.haptic.impactOccurred()
            #endif
            if isSelecting {
                onToggleSelection()
            } else {
                copyToClipboard()
            }
        }
    }

    // MARK: - Text Card

    private var textCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Image(systemName: item.icon)
                    .font(.title2)
                    .foregroundStyle(.tint)
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
                    Text(item.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                        .lineLimit(1)
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
    
    @ViewBuilder
    private var previewContent: some View {
        switch item.kind {
        case .text:
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: item.icon)
                        .font(.title2)
                        .foregroundStyle(.tint)
                    Text(item.name)
                        .font(.headline)
                    Spacer()
                }
                
                Text(item.value)
                    .font(.body)
                    .lineLimit(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(width: 300)
            .background(Color(platformSecondaryGroupedBackground))
            
        case .image:
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: item.icon)
                        .foregroundStyle(.tint)
                    Text(item.name)
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(Color(platformSecondaryGroupedBackground))
                
                if let filename = item.imageFilename,
                   let data = store.loadImageData(named: filename),
                   let img = loadPlatformImage(from: data) {
                    Image(platformImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 500)
                }
            }
            .frame(width: 300)
        }
    }

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
                
                Image(systemName: isSelecting ? (isSelected ? "checkmark.circle.fill" : "circle") : "ellipsis")
                    .font(isSelecting ? .title2 : .subheadline)
                    .foregroundStyle(
                        isSelecting && isSelected ? Color.white : Color.primary,
                        isSelecting && isSelected ? Color.accentColor : Color.primary
                    )
                    .scaleEffect(!isSelecting || isSelected ? 1.0 : 0.85)
                    .rotationEffect(.degrees(!isSelecting || isSelected ? 0 : -15))
                    .animation(.spring(duration: 0.15), value: isSelected)
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
}

// MARK: - Preview

#Preview {
    MainContentView()
        .environmentObject(CutlingStore.shared)
    #if os(macOS)
        .frame(width: 400, height: 500)
    #endif
}
