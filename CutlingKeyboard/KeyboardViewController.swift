//
//  KeyboardViewController.swift
//  CutlingKeyboard
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import UIKit
import SwiftUI
import Combine
import UniformTypeIdentifiers

// MARK: - Hex Color Extension

extension Color {
    init(hex: Int) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

// MARK: - Adaptive Key Color

extension UIColor {
    /// Light: rgb(254,254,254)  Dark: rgb(59,59,59)
    static let keyBackground = UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(white: 145/255, alpha: 0.30)
        : UIColor(white: 1.05, alpha: 0.75)
    }
}

// MARK: - Reactive Keyboard State

/// Shared between UIKit (KeyboardViewController) and SwiftUI (KeyboardView).
/// The VC writes; the SwiftUI view observes.
final class KeyboardState: ObservableObject {
    @Published var returnKeyType: UIReturnKeyType = .default
    @Published var hasFullAccess: Bool = false
    @Published var needsInputModeSwitchKey: Bool = false
    @Published var keyboardType: UIKeyboardType = .default
    @Published var textContentType: UITextContentType?
}

// MARK: - Instant Press Modifier

/// Zero-latency touch via DragGesture(minimumDistance: 0).
/// Cancels when finger drags more than a threshold, or when vertical scrolling is detected.
struct InstantPress: ViewModifier {
    let cornerRadius: CGFloat
    let fill: Color?
    let onPress: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false

    private static let cancelThreshold: CGFloat = 40
    private static let scrollDetectionThreshold: CGFloat = 8
    private static let haptic = UIImpactFeedbackGenerator(style: .light)

    private var highlightColor: Color {
        if let fill { return fill }
        return colorScheme == .dark
            ? Color.white.opacity(0.3)
            : Color.black.opacity(0.25)
    }

    private func shouldCancelForScroll(_ value: DragGesture.Value) -> Bool {
        // Cancel if vertical movement exceeds threshold (user is trying to scroll)
        abs(value.translation.height) > Self.scrollDetectionThreshold &&
        abs(value.translation.height) > abs(value.translation.width)
    }

    private func isInsideBounds(_ value: DragGesture.Value) -> Bool {
        max(abs(value.translation.width), abs(value.translation.height)) < Self.cancelThreshold
    }

    func body(content: Content) -> some View {
        content
            // Near-invisible background guarantees hit-testing on
            // transparent views — .contentShape alone is unreliable
            // with DragGesture in some SwiftUI versions.
            .background(Color.white.opacity(0.001))
            .overlay(
                isPressed
                    ? RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(highlightColor)
                    : nil
            )
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        // Cancel immediately if user is trying to scroll
                        if shouldCancelForScroll(value) {
                            isPressed = false
                            return
                        }
                        
                        let inside = isInsideBounds(value)
                        if inside && !isPressed {
                            Self.haptic.impactOccurred()
                            UIDevice.current.playInputClick()
                        }
                        isPressed = inside
                    }
                    .onEnded { value in
                        let shouldFire = isPressed &&
                                       isInsideBounds(value) &&
                                       !shouldCancelForScroll(value)
                        isPressed = false
                        if shouldFire {
                            onPress()
                        }
                    }
            )
    }
}

extension View {
    func instantPress(
        cornerRadius: CGFloat = KeyStyle.cornerRadius,
        fill: Color? = nil,
        action: @escaping () -> Void
    ) -> some View {
        modifier(InstantPress(cornerRadius: cornerRadius, fill: fill, onPress: action))
    }
}

// MARK: - Keyboard Button Style

/// Shared button style for keyboard elements - matches InstantPress visual feedback
struct KeyboardButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    
    @Environment(\.colorScheme) private var colorScheme
    private let haptic = UIImpactFeedbackGenerator(style: .light)
    
    private var highlightColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.18)
            : Color.black.opacity(0.12)
    }
    
    init(cornerRadius: CGFloat = KeyStyle.cornerRadius) {
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                configuration.isPressed
                    ? RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(highlightColor)
                    : nil
            )
            .onChange(of: configuration.isPressed) {
                if configuration.isPressed {
                    haptic.impactOccurred()
                    UIDevice.current.playInputClick()
                }
            }
    }
}

// MARK: - Audio-Feedback-Enabled Input View

/// A UIInputView subclass that adopts UIInputViewAudioFeedback
/// so `UIDevice.current.playInputClick()` produces the standard
/// keyboard click sound (when the user has enabled it in Settings).
final class AudioFeedbackInputView: UIInputView, UIInputViewAudioFeedback {
    var enableInputClicksWhenVisible: Bool { true }
}

// MARK: - Keyboard View Controller

class KeyboardViewController: UIInputViewController {

    private var hostingController: UIHostingController<KeyboardView>?
    private let keyboardState = KeyboardState()
    
    // CRITICAL: Reuse the shared store instance to avoid duplicate loading
    private let store = CutlingStore.shared

    override func loadView() {
        // Replace the default inputView with our audio-feedback-enabled subclass
        let audioView = AudioFeedbackInputView(
            frame: .zero,
            inputViewStyle: .keyboard
        )
        audioView.allowsSelfSizing = true
        inputView = audioView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Sync full-access state to shared UserDefaults AND observable state
        let fullAccess = hasFullAccess
        print(fullAccess)
        UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.set(fullAccess, forKey: "hasFullAccess")
        keyboardState.hasFullAccess = fullAccess
        keyboardState.returnKeyType = textDocumentProxy.returnKeyType ?? .default
        keyboardState.needsInputModeSwitchKey = needsInputModeSwitchKey
        keyboardState.keyboardType = textDocumentProxy.keyboardType ?? .default
        let contentType: UITextContentType? = textDocumentProxy.textContentType
        keyboardState.textContentType = contentType
        
        // Fetch remote changes from CloudKit (in case main app hasn't been opened)
        KeyboardSyncHelper.fetchFromCloudKit(store: store)
        
        // Only create the hosting controller once
        if hostingController == nil {
            let inputVC = self

            // Type-safe hosting controller — no AnyView overhead
            let keyboardView = KeyboardView(
                store: store,
                state: keyboardState,
                onInsertText: { inputVC.textDocumentProxy.insertText($0) },
                onCopyImage: { if let image = UIImage(data: $0) { UIPasteboard.general.image = image } },
                onBackspace: { inputVC.textDocumentProxy.deleteBackward() },
                onDeleteWord: {
                    // Delete backward until the start of the current word
                    // (matches native keyboard word-deletion behavior)
                    let proxy = inputVC.textDocumentProxy
                    guard let before = proxy.documentContextBeforeInput, !before.isEmpty else { return }
                    
                    // Find trailing whitespace, then the word before it
                    var count = 0
                    let reversed = before.reversed()
                    var iter = reversed.makeIterator()
                    
                    // Skip trailing whitespace
                    var hitNonSpace = false
                    while let ch = iter.next() {
                        if ch.isWhitespace && !hitNonSpace {
                            count += 1
                        } else {
                            hitNonSpace = true
                            if ch.isWhitespace {
                                break
                            }
                            count += 1
                        }
                    }
                    
                    if count == 0 { count = 1 }
                    for _ in 0..<count {
                        proxy.deleteBackward()
                    }
                },
                onSwitchKeyboard: { inputVC.advanceToNextInputMode() }
            )

            let hc = UIHostingController(rootView: keyboardView)
            hc.view.translatesAutoresizingMaskIntoConstraints = false
            hc.view.backgroundColor = .clear
            hc.safeAreaRegions = []

            addChild(hc)
            view.addSubview(hc.view)
            hc.didMove(toParent: self)

            NSLayoutConstraint.activate([
                hc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                hc.view.topAnchor.constraint(equalTo: view.topAnchor),
                hc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

            hostingController = hc
            
            // Listen for memory warnings and clear image cache
            NotificationCenter.default.addObserver(
                forName: UIApplication.didReceiveMemoryWarningNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                print("⚠️ Memory warning received - clearing thumbnail cache")
                self?.store.clearThumbnailCache()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

    // Called every time the text input context changes — new text field,
    // keyboard type change, return key type change, etc.
    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        let newReturnType = textDocumentProxy.returnKeyType ?? .default
        if keyboardState.returnKeyType != newReturnType {
            keyboardState.returnKeyType = newReturnType
        }
        let newKeyboardType = textDocumentProxy.keyboardType ?? .default
        if keyboardState.keyboardType != newKeyboardType {
            keyboardState.keyboardType = newKeyboardType
        }
        let newContentType: UITextContentType? = textDocumentProxy.textContentType
        if keyboardState.textContentType != newContentType {
            keyboardState.textContentType = newContentType
        }
    }
}

// MARK: - Key Styling

enum KeyStyle {
    static let cornerRadius: CGFloat = 12
    static let horizontalPadding: CGFloat = 6
    static let keyColor = Color(UIColor.keyBackground)
    
    static func keyHeight(for sizeClass: UserInterfaceSizeClass?, isLandscape: Bool) -> CGFloat {
        // iPad uses regular size class in both orientations
        if sizeClass == .regular {
            return 64
        }
        // iPhone in landscape
        if isLandscape {
            return 32
        }
        // iPhone in portrait (default)
        return 44
    }
    
    static func gridHeight(for sizeClass: UserInterfaceSizeClass?, isLandscape: Bool) -> CGFloat {
        // iPad uses regular size class in both orientations
        if sizeClass == .regular {
            return 240
        }
        // iPhone in landscape
        if isLandscape {
            return 120
        }
        // iPhone in portrait (default)
        return 180
    }
    
    static func smallKeyWidth(for sizeClass: UserInterfaceSizeClass?, isLandscape: Bool) -> CGFloat {
        // iPad uses regular size class in both orientations
        if sizeClass == .regular {
            return 72
        }
        // iPhone in landscape
        if isLandscape {
            return 64
        }
        // iPhone in portrait (default)
        return 52
    }
    
    static func keySpacing(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        // iPad uses larger spacing for better touch targets
        if sizeClass == .regular {
            return 8
        }
        // iPhone uses tighter spacing
        return 6
    }
    
    // MARK: - Card Sizing
    
    static func cardHeight(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        if sizeClass == .regular {
            return 80  // Larger cards for iPad
        }
        return 64  // iPhone
    }
    
    static func cardMinWidth(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        if sizeClass == .regular {
            return 180  // Wider cards for iPad
        }
        return 140  // iPhone
    }
    
    // MARK: - Icon Sizing
    
    static func iconSize(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        if sizeClass == .regular {
            return 16  // Larger icons for iPad
        }
        return 13  // iPhone
    }
    
    static func buttonIconSize(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        if sizeClass == .regular {
            return 22  // Larger button icons for iPad
        }
        return 18  // iPhone
    }
    
    // MARK: - Text Sizing
    
    static func titleSize(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        if sizeClass == .regular {
            return 17  // Larger titles for iPad
        }
        return 14  // iPhone
    }
    
    static func bodySize(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        if sizeClass == .regular {
            return 15  // Larger body text for iPad
        }
        return 12  // iPhone
    }
    
    static func buttonTextSize(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        if sizeClass == .regular {
            return 18  // Larger button text for iPad
        }
        return 16  // iPhone
    }
    
    static func cardPadding(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        if sizeClass == .regular {
            return 12  // More padding for iPad
        }
        return 10  // iPhone
    }
}

// MARK: - Return Key Descriptor

/// Maps UIReturnKeyType → SF Symbol + whether it's an "action" key
/// that should be visually emphasized (tinted background).
struct ReturnKeyInfo {
    let icon: String
    let isAction: Bool

    static func from(_ type: UIReturnKeyType) -> ReturnKeyInfo {
        switch type {
        case .search:       return .init(icon: "magnifyingglass",   isAction: true)
        case .send:         return .init(icon: "arrow.up",          isAction: true)
        case .go:           return .init(icon: "arrow.right",       isAction: true)
        case .done:         return .init(icon: "checkmark",         isAction: true)
        case .next:         return .init(icon: "arrow.right",       isAction: true)
        case .join:         return .init(icon: "arrow.right",       isAction: true)
        case .route:        return .init(icon: "location",          isAction: true)
        case .continue:     return .init(icon: "arrow.right",       isAction: true)
        case .emergencyCall:return .init(icon: "phone",             isAction: true)
        default:            return .init(icon: "return.left",       isAction: false)
        }
    }
}

// MARK: - Backspace Repeat Modifier

/// Replicates native iOS keyboard backspace behavior:
/// 1. Delete one character immediately on press
/// 2. After initial delay (~0.5s), delete character-by-character
/// 3. After acceleration threshold (~1.8s of holding), delete word-by-word
struct BackspaceRepeat: ViewModifier {
    let cornerRadius: CGFloat
    let onDelete: () -> Void
    let onDeleteWord: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    @State private var repeatTask: Task<Void, Never>?

    private static let haptic = UIImpactFeedbackGenerator(style: .light)

    // Timing constants matching native keyboard feel
    private static let initialDelay: Duration = .milliseconds(500)
    private static let charRepeatInterval: Duration = .milliseconds(130)
    private static let wordPhaseThreshold: Duration = .milliseconds(1800)
    private static let wordRepeatInterval: Duration = .milliseconds(300)

    private static let cancelThreshold: CGFloat = 40
    private static let scrollDetectionThreshold: CGFloat = 8

    private var highlightColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.3)
            : Color.black.opacity(0.25)
    }

    func body(content: Content) -> some View {
        content
            .background(Color.white.opacity(0.001))
            .overlay(
                isPressed
                    ? RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(highlightColor)
                    : nil
            )
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        let shouldCancel =
                            abs(value.translation.height) > Self.scrollDetectionThreshold &&
                            abs(value.translation.height) > abs(value.translation.width)
                        let inside = max(abs(value.translation.width), abs(value.translation.height)) < Self.cancelThreshold

                        if shouldCancel || !inside {
                            cancelRepeat()
                            return
                        }

                        if !isPressed {
                            isPressed = true
                            Self.haptic.impactOccurred()
                            UIDevice.current.playInputClick()
                            onDelete()
                            startRepeat()
                        }
                    }
                    .onEnded { _ in
                        cancelRepeat()
                    }
            )
    }

    private func startRepeat() {
        repeatTask?.cancel()
        repeatTask = Task { @MainActor in
            // Phase 1: initial delay before repeating
            try? await Task.sleep(for: Self.initialDelay)
            guard !Task.isCancelled else { return }

            let startTime = ContinuousClock.now

            // Phase 2+3: character-by-character, then word-by-word
            while !Task.isCancelled {
                let elapsed = ContinuousClock.now - startTime
                if elapsed >= Self.wordPhaseThreshold {
                    // Word-by-word deletion
                    onDeleteWord()
                    try? await Task.sleep(for: Self.wordRepeatInterval)
                } else {
                    // Character-by-character deletion
                    onDelete()
                    try? await Task.sleep(for: Self.charRepeatInterval)
                }
            }
        }
    }

    private func cancelRepeat() {
        repeatTask?.cancel()
        repeatTask = nil
        isPressed = false
    }
}

extension View {
    func backspaceRepeat(
        cornerRadius: CGFloat = KeyStyle.cornerRadius,
        onDelete: @escaping () -> Void,
        onDeleteWord: @escaping () -> Void
    ) -> some View {
        modifier(BackspaceRepeat(cornerRadius: cornerRadius, onDelete: onDelete, onDeleteWord: onDeleteWord))
    }
}

// MARK: - Keyboard Root View

struct KeyboardView: View {
    @ObservedObject var store: CutlingStore
    @ObservedObject var state: KeyboardState
    let onInsertText: (String) -> Void
    let onCopyImage: (Data) -> Void
    let onBackspace: () -> Void
    let onDeleteWord: () -> Void
    let onSwitchKeyboard: () -> Void

    @State private var copiedID: UUID? = nil
    @State private var existedID: UUID? = nil
    @State private var newlyAddedID: UUID? = nil
    @State private var showAddedToast = false
    @State private var showNoAccessToast = false
    @State private var showEmptyClipboardToast = false
    @State private var showLimitToast = false
    @State private var limitToastMessage = ""
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private var keyHeight: CGFloat {
        KeyStyle.keyHeight(for: horizontalSizeClass, isLandscape: isLandscape)
    }
    
    private var gridHeight: CGFloat {
        KeyStyle.gridHeight(for: horizontalSizeClass, isLandscape: isLandscape)
    }
    
    private var smallKeyWidth: CGFloat {
        KeyStyle.smallKeyWidth(for: horizontalSizeClass, isLandscape: isLandscape)
    }
    
    private var keySpacing: CGFloat {
        KeyStyle.keySpacing(for: horizontalSizeClass)
    }

    var body: some View {
        VStack(spacing: keySpacing) {
            suggestionBar
                .padding(.horizontal, KeyStyle.horizontalPadding)
                .frame(height: keyHeight + keySpacing)
                .padding(.top, keySpacing)

            cutlingGrid
                .frame(height: gridHeight)

            bottomRow
                .padding(.horizontal, KeyStyle.horizontalPadding)
                .frame(height: keyHeight)
        }
        .padding(.bottom, 2)
        .tint(Color(hex: 0x22a98d))
        .background(Color.clear)
    }

    // MARK: - Suggestion Bar

    private var suggestionBar: some View {
        HStack(spacing: keySpacing) {
            Group {
                if state.hasFullAccess {
                    // Always-active clipboard button — checks clipboard at tap time
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: KeyStyle.iconSize(for: horizontalSizeClass) + 2, weight: .medium))
                        Text("Add from Clipboard")
                            .font(.system(size: KeyStyle.buttonTextSize(for: horizontalSizeClass)))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: keyHeight)
                    .instantPress(cornerRadius: 99) {
                        addFromClipboard()
                    }
                } else {
                    // No full access — show disabled state that opens settings
                    Link(destination: URL(string: "cutling://settings")!) {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: KeyStyle.iconSize(for: horizontalSizeClass), weight: .medium))
                                .foregroundStyle(.secondary)
                            Text("Enable Full Access for Clipboard")
                                .font(.system(size: KeyStyle.buttonTextSize(for: horizontalSizeClass) - 2))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: keyHeight)
                    }
                    .buttonStyle(.plain)
                }
            }
            .overlay {
                if showAddedToast {
                    toastOverlay(icon: "checkmark", text: String(localized: "Added!"))
                }
                if showNoAccessToast {
                    toastOverlay(icon: "lock.fill", text: String(localized: "Full Access Required"))
                }
                if showEmptyClipboardToast {
                    toastOverlay(icon: "doc.on.clipboard", text: String(localized: "Clipboard Empty"))
                }
                if showLimitToast {
                    toastOverlay(icon: "exclamationmark.triangle", text: limitToastMessage)
                }
            }
            .animation(.spring(duration: 0.35, bounce: 0.2), value: showAddedToast)
            .animation(.spring(duration: 0.35, bounce: 0.2), value: showNoAccessToast)
            .animation(.spring(duration: 0.35, bounce: 0.2), value: showEmptyClipboardToast)
            .animation(.spring(duration: 0.35, bounce: 0.2), value: showLimitToast)

            Link(destination: URL(string: "cutling://open")!) {
                Image(systemName: "arrow.up.forward.square")
                    .font(.system(size: KeyStyle.buttonIconSize(for: horizontalSizeClass), weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: keyHeight, height: keyHeight)
                    .background(Color.white.opacity(0.001))
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private func toastOverlay(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
            Text(text)
                .font(.system(size: 15, weight: .semibold))
        }
        .foregroundStyle(.primary)
        .frame(maxWidth: .infinity)
        .frame(height: keyHeight)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 99, style: .continuous)
        )
        .transition(.asymmetric(
            insertion: .scale(scale: 0.85).combined(with: .opacity),
            removal: .opacity
        ))
        .allowsHitTesting(false)
    }

    // MARK: - Input Type Suggestion

    /// Cutlings whose inputTypeTriggers match the current text field context.
    private var suggestedCutlings: [Cutling] {
        let activeKeys = InputTypeCategory.activeTriggerKeys(
            keyboardType: state.keyboardType,
            textContentType: state.textContentType
        )
        guard !activeKeys.isEmpty else { return [] }

        let liveCutlings = store.cutlings.filter { !$0.isExpired }
        return liveCutlings.filter { cutling in
            guard let triggers = cutling.inputTypeTriggers, !triggers.isEmpty else { return false }
            return !Set(triggers).isDisjoint(with: activeKeys)
        }
    }

    // MARK: - Cutling Grid

    private var cutlingGrid: some View {
        let liveCutlings = store.cutlings.filter { !$0.isExpired }
        let suggested = suggestedCutlings
        let suggestedIDs = Set(suggested.map(\.id))
        let remaining = liveCutlings.filter { !suggestedIDs.contains($0.id) }
        let gridColumns = [GridItem(.adaptive(minimum: KeyStyle.cardMinWidth(for: horizontalSizeClass)), spacing: keySpacing)]

        return ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                if liveCutlings.isEmpty {
                    // ... (your empty state view)
                } else {
                    LazyVStack(spacing: 0) {
                        if !suggested.isEmpty {
                            // Suggestions section header
                            HStack(spacing: 4) {
                                Image(systemName: "sparkle")
                                    .font(.system(size: 10, weight: .semibold))
                                Text("Suggestions")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, KeyStyle.horizontalPadding + 4)
                            .padding(.top, keySpacing)
                            .padding(.bottom, 4)

                            LazyVGrid(columns: gridColumns, spacing: keySpacing) {
                                ForEach(suggested) { cutling in
                                    CutlingKeyView(
                                        cutling: cutling,
                                        store: store,
                                        isCopied: copiedID == cutling.id,
                                        isExisted: existedID == cutling.id,
                                        onTap: { handleTap(cutling) }
                                    )
                                    .id(cutling.id)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                                        removal: .scale(scale: 0.8).combined(with: .opacity)
                                    ))
                                }
                            }
                            .padding(.horizontal, KeyStyle.horizontalPadding)

                            // Divider between sections
                            Rectangle()
                                .fill(.secondary.opacity(0.2))
                                .frame(height: 0.5)
                                .padding(.horizontal, KeyStyle.horizontalPadding + 8)
                                .padding(.vertical, keySpacing)
                        }

                        LazyVGrid(columns: gridColumns, spacing: keySpacing) {
                            ForEach(remaining) { cutling in
                                CutlingKeyView(
                                    cutling: cutling,
                                    store: store,
                                    isCopied: copiedID == cutling.id,
                                    isExisted: existedID == cutling.id,
                                    onTap: { handleTap(cutling) }
                                )
                                .id(cutling.id)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                                    removal: .scale(scale: 0.8).combined(with: .opacity)
                                ))
                            }
                        }
                        .padding(.horizontal, KeyStyle.horizontalPadding)
                        .padding(.top, suggested.isEmpty ? keySpacing : 0)
                        .padding(.bottom, keySpacing)
                    }
                }
            }
            .animation(.spring(duration: 0.4, bounce: 0.2), value: liveCutlings.map(\.id))
            .animation(.spring(duration: 0.4, bounce: 0.2), value: suggested.map(\.id))
            .onChange(of: existedID) { oldValue, newValue in
                if let id = newValue {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
            .onChange(of: newlyAddedID) { oldValue, newValue in
                if let id = newValue {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                    newlyAddedID = nil
                }
            }
        }
        .background(Color.white.opacity(0.001))
    }

    // MARK: - Bottom Row

    private var bottomRow: some View {
        let info = ReturnKeyInfo.from(state.returnKeyType)

        return HStack(spacing: keySpacing) {
            // Next Keyboard (Globe) - only shown when needed
            if state.needsInputModeSwitchKey {
                Image(systemName: "globe")
                    .font(.system(size: 20, weight: .light))
                    .frame(width: smallKeyWidth, height: keyHeight)
                    .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
                    .onTapGesture {
                        // Tap: switch to next keyboard
                        onSwitchKeyboard()
                    }
            }
            
            // Backspace
            Image(systemName: "delete.left")
                .font(.system(size: 20, weight: .light))
                .frame(width: smallKeyWidth, height: keyHeight)
                .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
                .backspaceRepeat(onDelete: onBackspace, onDeleteWord: onDeleteWord)

            // Space
            Text("")
                .font(.system(size: 17))
                .frame(maxWidth: .infinity, minHeight: keyHeight)
                .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
                .instantPress { onInsertText(" ") }

            // Return — icon + action tint
            Image(systemName: info.icon)
                .font(.system(size: 18, weight: info.isAction ? .semibold : .light))
                .foregroundStyle(info.isAction ? .white : .primary)
                .frame(width: 92, height: keyHeight)
                .background(
                    info.isAction
                        ? AnyShapeStyle(Color(hex: 0x22a98d))
                        : AnyShapeStyle(KeyStyle.keyColor),
                    in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous)
                )
                .instantPress { onInsertText("\n") }
                .animation(.easeInOut(duration: 0.15), value: state.returnKeyType)
        }
    }

    // MARK: - Actions

    private func handleTap(_ cutling: Cutling) {
        switch cutling.kind {
        case .text:
            onInsertText(cutling.value)
            showCopied(cutling.id)
            incrementPasteCount()
        case .image:
            if !state.hasFullAccess {
                flashNoAccess()
                return
            }
            if let filename = cutling.imageFilename,
               let data = store.loadImageData(named: filename) {
                onCopyImage(data)
                showCopied(cutling.id)
                incrementPasteCount()
            }
        }
    }

    /// Tracks how many times the user has pasted from the keyboard, stored in the shared app group.
    private func incrementPasteCount() {
        let defaults = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")
        let current = defaults?.integer(forKey: "keyboardPasteCount") ?? 0
        defaults?.set(current + 1, forKey: "keyboardPasteCount")
    }

    private func showCopied(_ id: UUID) {
        withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
            copiedID = id
        }
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            if copiedID == id {
                withAnimation(.easeOut(duration: 0.25)) {
                    copiedID = nil
                }
            }
        }
    }

    private func addFromClipboard() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let timestamp = formatter.string(from: Date())
        
        // Check for image first - try to get raw data to preserve format (GIF, etc.)
        var imageData: Data?
        
        if let data = UIPasteboard.general.data(forPasteboardType: UTType.gif.identifier) {
            imageData = data
        } else if let data = UIPasteboard.general.data(forPasteboardType: UTType.png.identifier) {
            imageData = data
        } else if let data = UIPasteboard.general.data(forPasteboardType: UTType.jpeg.identifier) {
            imageData = data
        } else if let image = UIPasteboard.general.image {
            // Fallback: convert UIImage to PNG or JPEG
            if let data = image.pngData() {
                imageData = data
            } else if let data = image.jpegData(compressionQuality: 1.0) {
                imageData = data
            }
        }
        
        if let imageData {
            // Check for duplicate image first
            if let existing = store.findDuplicateImage(data: imageData) {
                showExisted(existing.id)
                return
            }
            
            // Check image limit
            let canAdd = store.canAdd(.image)
            if !canAdd.allowed {
                showLimitReached(canAdd.reason ?? "Limit reached")
                return
            }
            
            let id = UUID()
            var cutling = Cutling(
                id: id,
                name: String(localized: "Image: \(timestamp)"),
                value: "",
                icon: "photo",
                kind: .image,
                imageFilename: nil
            )
            
            cutling.imageFilename = store.saveImageData(imageData, for: id)
            store.add(cutling)
            if let added = store.cutlings.first(where: { $0.id == id }) {
                KeyboardSyncHelper.upload(added, imagesDirectory: store.imagesDirectory)
            }
            newlyAddedID = id
            
            withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                showAddedToast = true
            }
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                withAnimation(.easeOut(duration: 0.25)) {
                    showAddedToast = false
                }
            }
            return
        }
        
        // Otherwise check for text
        guard let rawText = UIPasteboard.general.string, !rawText.isEmpty else {
            flashEmptyClipboard()
            return
        }
        
        // Truncate to character limit
        let text = rawText.count > CutlingStore.maxTextLength
            ? String(rawText.prefix(CutlingStore.maxTextLength))
            : rawText

        if let existing = store.cutlings.first(where: { $0.value == text }) {
            showExisted(existing.id)
            return
        }
        
        // Check text limit
        let canAdd = store.canAdd(.text)
        if !canAdd.allowed {
            showLimitReached(canAdd.reason ?? "Limit reached")
            return
        }

        let cutling = Cutling(
            name: String(localized: "Clip: \(timestamp)"),
            value: text,
            icon: "doc.on.clipboard"
        )

        store.add(cutling)
        if let added = store.cutlings.first(where: { $0.id == cutling.id }) {
            KeyboardSyncHelper.upload(added, imagesDirectory: store.imagesDirectory)
        }
        newlyAddedID = cutling.id

        withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
            showAddedToast = true
        }
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(.easeOut(duration: 0.25)) {
                showAddedToast = false
            }
        }
    }

    private func flashNoAccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
            showNoAccessToast = true
        }
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(.easeOut(duration: 0.25)) {
                showNoAccessToast = false
            }
        }
    }

    private func flashEmptyClipboard() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
            showEmptyClipboardToast = true
        }
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(.easeOut(duration: 0.25)) {
                showEmptyClipboardToast = false
            }
        }
    }
    
    private func showLimitReached(_ message: String) {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        // Shorten the message for keyboard display
        if message.contains("image") {
            limitToastMessage = String(localized: "Image Limit: \(CutlingStore.maxImageCutlings)")
        } else if message.contains("text") {
            limitToastMessage = String(localized: "Text Limit: \(CutlingStore.maxTextCutlings)")
        } else {
            limitToastMessage = String(localized: "Limit Reached")
        }
        
        withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
            showLimitToast = true
        }
        Task {
            try? await Task.sleep(for: .seconds(2.0))
            withAnimation(.easeOut(duration: 0.25)) {
                showLimitToast = false
            }
        }
    }

    private func showExisted(_ id: UUID) {
        withAnimation(.spring(duration: 0.4, bounce: 0.3)) {
            existedID = id
        }
        
        // Auto-reset the highlight after a delay
        Task {
            try? await Task.sleep(for: .seconds(1.0))
            if existedID == id {
                withAnimation(.easeOut(duration: 0.5)) {
                    existedID = nil
                }
            }
        }
    }
}


// MARK: - Cutling Key

struct CutlingKeyView: View {
    let cutling: Cutling
    let store: CutlingStore
    let isCopied: Bool
    let isExisted: Bool
    let onTap: () -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var cardHeight: CGFloat {
        KeyStyle.cardHeight(for: horizontalSizeClass)
    }

    var body: some View {
        Button(action: onTap) {
            Group {
                switch cutling.kind {
                case .text:  textContent
                case .image: imageContent
                }
            }
            .frame(maxWidth: .infinity, minHeight: cardHeight, maxHeight: cardHeight, alignment: .topLeading)
            .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
            .overlay {
                if isExisted {
                    RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous)
                        .stroke(Color(hex: 0x22a98d), lineWidth: 2)
                        .shadow(color: Color(hex: 0x22a98d).opacity(0.6), radius: 2)
                        // The "Shine/Pulse" effect
                        .overlay(
                            RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous)
                                .fill(Color(hex: 0x22a98d).opacity(0.15))
                        )
                }
                if isCopied {
                    RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    Label(
                        cutling.kind == .text ? "Inserted" : "Copied",
                        systemImage: "checkmark"
                    )
                    .font(.subheadline.weight(.semibold))
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.85).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
            .scaleEffect(isExisted ? 1.025 : 1.0)
            .animation(.spring(duration: 0.4, bounce: 0.5), value: isExisted)
        }
        .buttonStyle(KeyboardButtonStyle())
        .animation(.spring(duration: 0.35, bounce: 0.2), value: isCopied)
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: cutling.icon)
                    .font(.system(size: KeyStyle.iconSize(for: horizontalSizeClass)))
                    .foregroundStyle(cutling.tintColor)
                Text(cutling.name)
                    .font(.system(size: KeyStyle.titleSize(for: horizontalSizeClass), weight: .semibold))
                    .lineLimit(1)
            }
            Text(cutling.value)
                .font(.system(size: KeyStyle.bodySize(for: horizontalSizeClass)))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(KeyStyle.cardPadding(for: horizontalSizeClass))
    }

    private var imageContent: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                if let filename = cutling.imageFilename,
                   let thumbnail = store.loadThumbnail(named: filename) {
                    // Use thumbnail instead of full-size image
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    Color.secondary.opacity(0.1)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                }

                Text(cutling.name)
                    .font(.system(size: KeyStyle.titleSize(for: horizontalSizeClass) - 2, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
                    .padding(KeyStyle.cardPadding(for: horizontalSizeClass) - 2)
                    .frame(width: geo.size.width, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.35)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
