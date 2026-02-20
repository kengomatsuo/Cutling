//
//  KeyboardViewController.swift
//  TineKeyboard
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
        : UIColor(white: 1, alpha: 0.60)
    }
}

// MARK: - Reactive Keyboard State

/// Shared between UIKit (KeyboardViewController) and SwiftUI (KeyboardView).
/// The VC writes; the SwiftUI view observes.
final class KeyboardState: ObservableObject {
    @Published var returnKeyType: UIReturnKeyType = .default
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
    }
}

// MARK: - Keyboard View Controller

class KeyboardViewController: UIInputViewController {

    private var hostingController: UIHostingController<AnyView>?
    private let keyboardState = KeyboardState()

    override func viewDidLoad() {
        super.viewDidLoad()

        let store = SnippetStore()
        store.load()
        let inputVC = self

        // Seed initial return key type
        keyboardState.returnKeyType = textDocumentProxy.returnKeyType ?? .default

        let keyboardView = KeyboardView(
            store: store,
            state: keyboardState,
            onInsertText: { text in
                inputVC.textDocumentProxy.insertText(text)
            },
            onCopyImage: { data in
                if let image = UIImage(data: data) {
                    UIPasteboard.general.image = image
                }
            },
            onBackspace: {
                inputVC.textDocumentProxy.deleteBackward()
            }
        )

        let hc = UIHostingController(rootView: AnyView(keyboardView))
        hc.view.translatesAutoresizingMaskIntoConstraints = false
        hc.view.backgroundColor = .clear

        addChild(hc)
        view.addSubview(hc.view)
        hc.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hc.view.topAnchor.constraint(equalTo: view.topAnchor),
            hc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let heightConstraint = view.heightAnchor.constraint(equalToConstant: 320)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true

        hostingController = hc
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
    let store: SnippetStore
    @ObservedObject var state: KeyboardState
    let onInsertText: (String) -> Void
    let onCopyImage: (Data) -> Void
    let onBackspace: () -> Void

    @State private var copiedID: UUID? = nil
    @State private var showAddedToast = false

    var body: some View {
        VStack(spacing: 6) {
            suggestionBar
                .padding(.horizontal, KeyStyle.horizontalPadding)

            snippetGrid

            bottomRow
                .padding(.horizontal, KeyStyle.horizontalPadding)
        }
        .padding(.bottom, 2)
        .tint(Color(hex: 0x22a98d))
    }

    // MARK: - Suggestion Bar

    private var suggestionBar: some View {
        HStack(spacing: 6) {
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
            .overlay {
                if showAddedToast {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Added!")
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
            }
            .animation(.spring(duration: 0.35, bounce: 0.2), value: showAddedToast)

            Link(destination: URL(string: "tine://open")!) {
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

    // MARK: - Snippet Grid

    private var snippetGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if store.snippets.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                    Text("No snippets yet")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                    Text("Add snippets in the Tine app")
                        .font(.caption)
                        .foregroundStyle(.quaternary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 140), spacing: 6)],
                    spacing: 6
                ) {
                    ForEach(store.snippets) { snippet in
                        SnippetKeyView(
                            snippet: snippet,
                            store: store,
                            isCopied: copiedID == snippet.id,
                            onTap: { handleTap(snippet) }
                        )
                    }
                }
                .padding(.horizontal, KeyStyle.horizontalPadding)
                .padding(.bottom, 6)
            }
        }
        .frame(maxHeight: .infinity)
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

    private func handleTap(_ snippet: Snippet) {
        switch snippet.kind {
        case .text:
            onInsertText(snippet.value)
            showCopied(snippet.id)
        case .image:
            if let filename = snippet.imageFilename,
               let data = store.loadImageData(named: filename) {
                onCopyImage(data)
                showCopied(snippet.id)
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
        guard let text = UIPasteboard.general.string, !text.isEmpty else { return }
        let name = String(text.prefix(30)).trimmingCharacters(in: .whitespacesAndNewlines)
        let snippet = Snippet(
            name: name.isEmpty ? "Clipboard" : name,
            value: text,
            icon: "doc.on.clipboard"
        )
        store.add(snippet)

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
}

// MARK: - Snippet Key

struct SnippetKeyView: View {
    let snippet: Snippet
    let store: SnippetStore
    let isCopied: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Group {
                switch snippet.kind {
                case .text:  textContent
                case .image: imageContent
                }
            }
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .topLeading)
            .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
            .overlay {
                if isCopied {
                    RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    Label(
                        snippet.kind == .text ? "Inserted" : "Copied",
                        systemImage: "checkmark"
                    )
                    .font(.subheadline.weight(.semibold))
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.85).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
        }
        .buttonStyle(KeyboardButtonStyle())
        .animation(.spring(duration: 0.35, bounce: 0.2), value: isCopied)
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: snippet.icon)
                    .font(.system(size: 13))
                    .foregroundStyle(.tint)
                Text(snippet.name)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
            }
            Text(snippet.value)
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
                if let filename = snippet.imageFilename,
                   let data = store.loadImageData(named: filename),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
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

                Text(snippet.name)
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
