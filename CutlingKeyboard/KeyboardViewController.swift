//
//  KeyboardViewController.swift
//  CutlingKeyboard
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import UIKit
import SwiftUI
import Combine

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
            ? Color.white.opacity(0.18)
            : Color.black.opacity(0.12)
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
                }
            }
    }
}

// MARK: - Keyboard View Controller

class KeyboardViewController: UIInputViewController {

    private var hostingController: UIHostingController<KeyboardView>?
    private let keyboardState = KeyboardState()
    
    // CRITICAL: Reuse the shared store instance to avoid duplicate loading
    private let store = CutlingStore.shared

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Sync full-access state to shared UserDefaults AND observable state
        let fullAccess = hasFullAccess
        print(fullAccess)
        UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.set(fullAccess, forKey: "hasFullAccess")
        keyboardState.hasFullAccess = fullAccess
        keyboardState.returnKeyType = textDocumentProxy.returnKeyType ?? .default

        // Only create the hosting controller once
        if hostingController == nil {
            let inputVC = self

            // Type-safe hosting controller — no AnyView overhead
            let keyboardView = KeyboardView(
                store: store,
                state: keyboardState,
                onInsertText: { inputVC.textDocumentProxy.insertText($0) },
                onCopyImage: { if let image = UIImage(data: $0) { UIPasteboard.general.image = image } },
                onBackspace: { inputVC.textDocumentProxy.deleteBackward() }
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
        let newType = textDocumentProxy.returnKeyType ?? .default
        if keyboardState.returnKeyType != newType {
            keyboardState.returnKeyType = newType
        }
    }
}

// MARK: - Key Styling

enum KeyStyle {
    static let cornerRadius: CGFloat = 12
    static let keyHeight: CGFloat = 44
    static let horizontalPadding: CGFloat = 6
    static let keyColor = Color(UIColor.keyBackground)
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

// MARK: - Keyboard Root View

struct KeyboardView: View {
    let store: CutlingStore
    @ObservedObject var state: KeyboardState
    let onInsertText: (String) -> Void
    let onCopyImage: (Data) -> Void
    let onBackspace: () -> Void

    @State private var copiedID: UUID? = nil
    @State private var existedID: UUID? = nil
    @State private var showAddedToast = false
    @State private var showNoAccessToast = false

    var body: some View {
        VStack(spacing: 6) {
            suggestionBar
                .padding(.horizontal, KeyStyle.horizontalPadding)
                .frame(height: KeyStyle.keyHeight + 6)
                .padding(.top, 6)

            cutlingGrid
                .frame(height: 240)

            bottomRow
                .padding(.horizontal, KeyStyle.horizontalPadding)
                .frame(height: KeyStyle.keyHeight)
        }
        .padding(.bottom, 2)
        .tint(Color(hex: 0x22a98d))
        .background(Color.clear)
    }

    // MARK: - Suggestion Bar

    private var suggestionBar: some View {
        HStack(spacing: 6) {
            Group {
                if state.hasFullAccess {
                    // Normal clipboard button
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: 15, weight: .medium))
                        Text("Add from Clipboard")
                            .font(.system(size: 16))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: KeyStyle.keyHeight)
                    .instantPress(cornerRadius: 99) {
                        addFromClipboard()
                    }
                } else {
                    // No full access — show disabled state that opens settings
                    Link(destination: URL(string: "cutling://settings")!) {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                            Text("Enable Full Access for Clipboard")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: KeyStyle.keyHeight)
                    }
                    .buttonStyle(.plain)
                }
            }
            .overlay {
                if showAddedToast {
                    toastOverlay(icon: "checkmark", text: "Added!")
                }
                if showNoAccessToast {
                    toastOverlay(icon: "lock.fill", text: "Full Access Required")
                }
            }
            .animation(.spring(duration: 0.35, bounce: 0.2), value: showAddedToast)
            .animation(.spring(duration: 0.35, bounce: 0.2), value: showNoAccessToast)

            Link(destination: URL(string: "cutling://open")!) {
                Image(systemName: "arrow.up.forward.square")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: KeyStyle.keyHeight, height: KeyStyle.keyHeight)
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
        .frame(height: KeyStyle.keyHeight)
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

    // MARK: - Cutling Grid

    private var cutlingGrid: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                if store.cutlings.isEmpty {
                    // ... (your empty state view)
                } else {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 140), spacing: 6)],
                        spacing: 6
                    ) {
                        ForEach(store.cutlings) { cutling in
                            CutlingKeyView(
                                cutling: cutling,
                                store: store,
                                isCopied: copiedID == cutling.id,
                                isExisted: existedID == cutling.id,
                                onTap: { handleTap(cutling) }
                            )
                            .id(cutling.id)
                        }
                    }
                    .padding(.horizontal, KeyStyle.horizontalPadding)
                    .padding(.vertical, 6)
                }
            }
            .onChange(of: existedID) { oldValue, newValue in
                if let id = newValue {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        }
        .background(Color.white.opacity(0.001))
    }

    // MARK: - Bottom Row

    private var bottomRow: some View {
        let info = ReturnKeyInfo.from(state.returnKeyType)

        return HStack(spacing: 5) {
            // Backspace
            Image(systemName: "delete.left")
                .font(.system(size: 20, weight: .light))
                .frame(width: 52, height: KeyStyle.keyHeight)
                .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
                .instantPress { onBackspace() }

            // Space
            Text("")
                .font(.system(size: 17))
                .frame(maxWidth: .infinity, minHeight: KeyStyle.keyHeight)
                .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
                .instantPress { onInsertText(" ") }

            // Return — icon + action tint
            Image(systemName: info.icon)
                .font(.system(size: 18, weight: info.isAction ? .semibold : .light))
                .foregroundStyle(info.isAction ? .white : .primary)
                .frame(width: 92, height: KeyStyle.keyHeight)
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
        case .image:
            if !state.hasFullAccess {
                flashNoAccess()
                return
            }
            if let filename = cutling.imageFilename,
               let data = store.loadImageData(named: filename) {
                onCopyImage(data)
                showCopied(cutling.id)
            }
        }
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
        
        // Check for image first
        if let image = UIPasteboard.general.image,
           let imageData = image.pngData() {
            
            let id = UUID()
            var cutling = Cutling(
                id: id,
                name: "Image: \(timestamp)",
                value: "",
                icon: "photo",
                kind: .image,
                imageFilename: nil
            )
            
            cutling.imageFilename = store.saveImageData(imageData, for: id)
            store.add(cutling)
            
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
        guard let text = UIPasteboard.general.string, !text.isEmpty else { return }

        if let existing = store.cutlings.first(where: { $0.value == text }) {
            showExisted(existing.id)
            return
        }

        let cutling = Cutling(
            name: "Clip: \(timestamp)",
            value: text,
            icon: "doc.on.clipboard"
        )

        store.add(cutling)

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

    var body: some View {
        Button(action: onTap) {
            Group {
                switch cutling.kind {
                case .text:  textContent
                case .image: imageContent
                }
            }
            .frame(maxWidth: .infinity, minHeight: 64, maxHeight: 64, alignment: .topLeading)
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
                    .font(.system(size: 13))
                    .foregroundStyle(.tint)
                Text(cutling.name)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
            }
            Text(cutling.value)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(10)
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
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
                    .padding(8)
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
