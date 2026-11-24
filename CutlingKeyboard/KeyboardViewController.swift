//
//  KeyboardViewController.swift
//  CutlingKeyboard
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


import UIKit
import SwiftUI
import Combine
import ImageIO
import UniformTypeIdentifiers
import AudioToolbox
import os

#if DEBUG
@MainActor private var snapshotBundle: Bundle?
#else
@MainActor private let snapshotBundle: Bundle? = nil
#endif

// MARK: - Hex Color Extension

extension Color {
    init(hex: Int) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    /// Near-invisible fill used to guarantee hit-testing on otherwise transparent views.
    /// `.contentShape` alone is unreliable with `DragGesture` in some SwiftUI versions.
    static let keyHitTest = Color.white.opacity(0.001)
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
    /// Letters/digits typed right before the cursor.
    @Published var wordBeforeCursor: String = ""
    /// A cutling with fill-ins waiting at a blank.
    @Published var fill: FillSession?
}

// MARK: - Keyboard Sound

/// Plays the iPhone keyboard's own click for each key type: key_press_click, _delete and _modifier, the three
/// files UIKitCore.framework carries for its keyboard (the same bytes sit in /System/Library/Audio/UISounds as
/// system sounds 1123, 1155 and 1156). Not the keyboard_press_normal, _delete and _clear files beside them in
/// UISounds, which UIKit's keyboard does not carry: they are 140 to 314 ms long against Apple's 4 to 19 ms, about
/// a fifth as loud, and _clear only sounds 131 ms after the press, so space and return clicked late (ASG159).
enum KeyboardSound {
    case standard   // character and cutling keys: key_press_click (1123)
    case delete     // backspace: key_press_delete (1155)
    case modifier   // space, return, globe: key_press_modifier (1156)

    var soundID: SystemSoundID {
        switch self {
        case .standard: 1123
        case .delete:   1155
        case .modifier: 1156
        }
    }

    func play() {
        AudioServicesPlaySystemSound(soundID)
    }
}

// MARK: - Instant Press Modifier

/// Lights on touch-down, as Apple's keys do, and fires on lift; read from UIKit (KeyTouchSurface.swift), since a
/// SwiftUI DragGesture lights late on iOS 27. Cancels when the finger drags more than a threshold, when vertical
/// scrolling is detected, or when the system takes the touch.
struct InstantPress: ViewModifier {
    let cornerRadius: CGFloat
    let fill: Color?
    let sound: KeyboardSound
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

    private func shouldCancelForScroll(_ offset: CGSize) -> Bool {
        // Cancel if vertical movement exceeds threshold (user is trying to scroll)
        abs(offset.height) > Self.scrollDetectionThreshold &&
        abs(offset.height) > abs(offset.width)
    }

    private func isInsideBounds(_ offset: CGSize) -> Bool {
        max(abs(offset.width), abs(offset.height)) < Self.cancelThreshold
    }

    private func track(_ offset: CGSize) {
        // Cancel immediately if user is trying to scroll
        if shouldCancelForScroll(offset) {
            isPressed = false
            return
        }
        let inside = isInsideBounds(offset)
        if inside && !isPressed {
            Self.haptic.impactOccurred()
            sound.play()
        }
        isPressed = inside
    }

    func body(content: Content) -> some View {
        content
            .background(Color.keyHitTest)
            .overlay(
                isPressed
                    ? RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(highlightColor)
                    : nil
            )
            .overlay(
                KeyTouchSurface(
                    onDown: { track(.zero) },
                    onMove: { track($0) },
                    onUp: { offset in
                        let shouldFire = isPressed && isInsideBounds(offset) && !shouldCancelForScroll(offset)
                        isPressed = false
                        if shouldFire { onPress() }
                    },
                    onCancel: { isPressed = false }
                )
            )
    }
}

extension View {
    func instantPress(
        cornerRadius: CGFloat = KeyStyle.cornerRadius,
        fill: Color? = nil,
        sound: KeyboardSound = .standard,
        action: @escaping () -> Void
    ) -> some View {
        modifier(InstantPress(cornerRadius: cornerRadius, fill: fill, sound: sound, onPress: action))
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
                // On and off at once, as Apple's keys: the tap's own spring (showCopied) must not fade it out.
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(highlightColor)
                    .opacity(configuration.isPressed ? 1 : 0)
                    .transaction { $0.animation = nil }
            )
            .onChange(of: configuration.isPressed) {
                if configuration.isPressed {
                    haptic.impactOccurred()
                    KeyboardSound.standard.play()
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

/// Milliseconds since this process started, for the launch-timing log (subsystem com.matsuokengo.Cutling, category launch).
private func msSinceProcessStart() -> Int {
    var info = kinfo_proc()
    var size = MemoryLayout<kinfo_proc>.stride
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    guard sysctl(&mib, 4, &info, &size, nil, 0) == 0 else { return -1 }
    let start = info.kp_proc.p_starttime
    var now = timeval()
    gettimeofday(&now, nil)
    return Int((now.tv_sec - start.tv_sec) * 1000 + Int(now.tv_usec - start.tv_usec) / 1000)
}
private let launchLog = Logger(subsystem: "com.matsuokengo.Cutling", category: "launch")

/// Logs each step of the keyboard's start once, so a cold switch can be timed step by step from the launch log.
@MainActor
private enum LaunchMarks {
    private static var seen = Set<String>()
    static func once(_ step: String) {
        guard seen.insert(step).inserted else { return }
        launchLog.log("\(step, privacy: .public) at \(msSinceProcessStart()) ms")
    }
}

class KeyboardViewController: UIInputViewController {

    private var hostingController: UIHostingController<KeyboardView>?
    private let keyboardState = KeyboardState()
    
    // CRITICAL: Reuse the shared store instance to avoid duplicate loading
    private let store: CutlingStore = {
        launchLog.log("store load starts at \(msSinceProcessStart()) ms")
        let store = CutlingStore.shared
        launchLog.log("store loaded at \(msSinceProcessStart()) ms")
        return store
    }()

    override func loadView() {
        launchLog.log("loadView at \(msSinceProcessStart()) ms")
        #if DEBUG
        if let snapshotLang = UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.string(forKey: "snapshotLanguage") {
            let langCode = snapshotLang.components(separatedBy: "-").first ?? snapshotLang
            if let path = Bundle.main.path(forResource: snapshotLang, ofType: "lproj")
                        ?? Bundle.main.path(forResource: langCode, ofType: "lproj") {
                snapshotBundle = Bundle(path: path)
            }
        }
        #endif

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
        LaunchMarks.once("viewWillAppear")
        defer { LaunchMarks.once("viewWillAppear done") }

        // Sync full-access state to shared UserDefaults AND observable state
        let fullAccess = hasFullAccess
        UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.set(fullAccess, forKey: "hasFullAccess")
        keyboardState.hasFullAccess = fullAccess
        keyboardState.returnKeyType = textDocumentProxy.returnKeyType ?? .default
        keyboardState.needsInputModeSwitchKey = needsInputModeSwitchKey
        keyboardState.keyboardType = textDocumentProxy.keyboardType ?? .default
        let contentType: UITextContentType? = textDocumentProxy.textContentType
        keyboardState.textContentType = contentType
        refreshWordBeforeCursor()
        cacheTextReplacements()
        // Back from typing a blank on the person's own keyboard: pick up the value and carry on.
        if keyboardState.fill == nil, let session = FillSession.load() {
            keyboardState.fill = session
        }
        pickUpTypedValue()
        installKeyboardView()
        updateHeight()
    }

    // The keyboard is built and sized as the controller loads, not when it is about to appear: a cold
    // launch then shows it at full height from its first frame instead of at height 0 snapping up.
    override func viewDidLoad() {
        super.viewDidLoad()
        launchLog.log("viewDidLoad at \(msSinceProcessStart()) ms")
        installKeyboardView()
        heightConstraint = view.heightAnchor.constraint(equalToConstant: currentHeight)
        // Below required, so the system's own height constraint wins for a moment when it must.
        heightConstraint?.priority = UILayoutPriority(999)
        heightConstraint?.isActive = true
        frameLink = CADisplayLink(target: self, selector: #selector(frameTick))
        frameLink?.add(to: .main, forMode: .common)
        launchLog.log("viewDidLoad done at \(msSinceProcessStart()) ms")
    }

    /// Times the keyboard's first frames on screen for the launch log, then stops.
    private var frameLink: CADisplayLink?
    private var framesInWindow = 0
    @objc private func frameTick() {
        guard view.window != nil else { return }
        framesInWindow += 1
        LaunchMarks.once("frame \(framesInWindow) in a window")
        if framesInWindow >= 3 {
            frameLink?.invalidate()
            frameLink = nil
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        launchLog.log("viewDidAppear at \(msSinceProcessStart()) ms, height \(self.view.bounds.height)")
        deliverTouchesAtOnce()
    }

    /// The keyboard window's system gesture gates (_UISystemGestureGate, _UIHomeAffordanceGate) hold a touch's start
    /// and end until they rule out a system swipe: filmed on the iOS 27.2 simulator (ASG159), a cutling key at the
    /// screen's edge lit about 120 ms after touch-down and delete once stayed lit and repeating 0.5 s after the finger
    /// left. Apple's keys answer at once; letting the gates watch without holding the touch does the same (touches
    /// then reach the keys within 20 ms), as azooKey's keyboard does for the start (MIT, github.com/azooKey/azooKey,
    /// Keyboard/Display/KeyboardViewController.swift, viewDidAppear). A touch a gate then claims arrives cancelled,
    /// which InstantPress and BackspaceRepeat clear (KeyTouchSurface.swift).
    private func deliverTouchesAtOnce() {
        view.window?.gestureRecognizers?.forEach {
            $0.delaysTouchesBegan = false
            $0.delaysTouchesEnded = false
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        LaunchMarks.once("first layout")
        updateHeight()
    }

    private var heightConstraint: NSLayoutConstraint?

    /// The height for the current size class and orientation; before the host's traits arrive,
    /// read from the device and the screen.
    private var currentHeight: CGFloat {
        let traits = view.traitCollection
        let regular: Bool = traits.horizontalSizeClass == .unspecified
            ? UIDevice.current.userInterfaceIdiom == .pad
            : traits.horizontalSizeClass == .regular
        let landscape: Bool = traits.verticalSizeClass == .unspecified
            ? UIScreen.main.bounds.width > UIScreen.main.bounds.height
            : traits.verticalSizeClass == .compact
        return KeyStyle.keyboardHeight(for: regular ? .regular : .compact, isLandscape: landscape)
    }

    private func updateHeight() {
        let height = currentHeight
        if let constraint = heightConstraint, constraint.constant != height { constraint.constant = height }
    }

    private func installKeyboardView() {
        // Only create the hosting controller once
        if hostingController == nil {
            let inputVC = self

            // Type-safe hosting controller — no AnyView overhead
            let keyboardView = KeyboardView(
                store: store,
                state: keyboardState,
                onInsertText: { inputVC.textDocumentProxy.insertText($0); inputVC.refreshWordBeforeCursor() },
                onUseCutling: { inputVC.use($0, replacingCount: $1, smartSpacing: $2) },
                onFillPick: { inputVC.fillPick($0) },
                onFillPaste: { inputVC.fillPaste() },
                onFillNext: { inputVC.fillNext() },
                onFillTypeOnOwnKeyboard: { inputVC.fillTypeOnOwnKeyboard() },
                onFillCancel: { inputVC.fillCancel() },
                onCopyImage: { data in
                    // Set the raw image bytes directly without decoding to UIImage.
                    // UIImage(data:) decompresses to a bitmap that can be 10-30x the
                    // file size, OOM-ing the keyboard extension on large images.
                    let uti: String
                    if let source = CGImageSourceCreateWithData(data as CFData, nil),
                       let type = CGImageSourceGetType(source) {
                        uti = type as String
                    } else {
                        uti = UTType.png.identifier
                    }
                    UIPasteboard.general.setData(data, forPasteboardType: uti)
                },
                onBackspace: {
                    let proxy = inputVC.textDocumentProxy
                    guard proxy.hasText else { return false }
                    proxy.deleteBackward()
                    inputVC.refreshWordBeforeCursor()
                    return true
                },
                onDeleteWord: { wordCount in
                    let proxy = inputVC.textDocumentProxy
                    guard proxy.hasText else { return false }

                    func isWordChar(_ ch: Character) -> Bool {
                        ch.isLetter || ch.isNumber || ch == "_"
                    }

                    var didDelete = false
                    for _ in 0..<wordCount {
                        guard let before = proxy.documentContextBeforeInput, !before.isEmpty else { break }

                        var count = 0
                        let chars = Array(before)
                        var i = chars.count - 1

                        while i >= 0 && !isWordChar(chars[i]) {
                            count += 1
                            i -= 1
                        }

                        while i >= 0 && isWordChar(chars[i]) {
                            count += 1
                            i -= 1
                        }

                        if count == 0 { count = 1 }
                        for _ in 0..<count {
                            proxy.deleteBackward()
                        }
                        didDelete = true
                    }
                    inputVC.refreshWordBeforeCursor()
                    return didDelete
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
                Task { @MainActor in
                    self?.store.clearThumbnailCache()
                }
            }
        }
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
        refreshWordBeforeCursor()
    }

    // MARK: - Completion

    fileprivate func refreshWordBeforeCursor() {
        let word = Self.trailingWord(in: textDocumentProxy.documentContextBeforeInput ?? "")
        if keyboardState.wordBeforeCursor != word {
            keyboardState.wordBeforeCursor = word
        }
    }

    static func trailingWord(in context: String) -> String {
        String(context.reversed().prefix { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "-" }.reversed())
    }

    /// Types a cutling, optionally replacing the typed word and spacing it from the text before.
    /// Stamps and the clipboard are filled in; a cutling with blanks asks for them first (FillInPanel.swift).
    fileprivate func use(_ cutling: Cutling, replacingCount: Int, smartSpacing: Bool) {
        let proxy = textDocumentProxy
        for _ in 0..<replacingCount { proxy.deleteBackward() }
        guard let template = cutling.placeholders else {
            // filled(_:) types the text as written, less Cutling's invisible fill-in markers when fill-ins are off.
            insert(cutling.filled(.now()).cutling.plainValue, smartSpacing: smartSpacing, charactersAfterCursor: nil)
            return
        }
        fillCancel()
        let clipboard = template.usesClipboard && hasFullAccess ? UIPasteboard.general.string : nil
        let chunks = template.chunks(.now(clipboard: clipboard ?? ""))
        guard !template.fields.isEmpty else {
            let rendered = Self.render(chunks, values: [:])
            insert(rendered.text, smartSpacing: smartSpacing, charactersAfterCursor: rendered.afterCursor)
            FillInCounters.advance(after: cutling)
            return
        }
        var session = FillSession(cutlingID: cutling.id, chunks: chunks, fields: template.fields, smartSpacing: smartSpacing)
        // A word typed just before the cutling fills its first blank (a choice only takes one of its options).
        if replacingCount == 0, let first = template.fields.first,
           let typed = FillSession.wordTypedFirst(in: proxy.documentContextBeforeInput ?? "") {
            let option = first.options.count > 1 ? first.options.first { $0.localizedCaseInsensitiveCompare(typed.word) == .orderedSame } : typed.word
            if let option {
                session.values[first.key] = option
                session.typed = String((proxy.documentContextBeforeInput ?? "").suffix(typed.length))
            }
        }
        show(session)
    }

    /// The cutling's text with these values, and how many characters follow `{cursor}`.
    static func render(_ chunks: [Placeholders.Chunk], values: [String: String]) -> (text: String, afterCursor: Int?) {
        var text = ""
        var afterCursor: Int?
        for chunk in chunks {
            let piece: String
            switch chunk {
            case .text(let t): piece = t
            case .field(let field): piece = values[field.key] ?? field.options.first ?? ""
            case .cursor:
                if afterCursor == nil { afterCursor = 0 }
                continue
            }
            text += piece
            if let after = afterCursor { afterCursor = after + cursorLength(piece) }
        }
        return (text, afterCursor)
    }

    /// Types finished text, spaced from the text before, and puts the cursor where `{cursor}` was.
    private func insert(_ text: String, smartSpacing: Bool, charactersAfterCursor: Int?) {
        let proxy = textDocumentProxy
        let before = proxy.documentContextBeforeInput ?? ""
        let spaced = smartSpacing ? Self.spaced(text, after: before, keyboardType: proxy.keyboardType ?? .default, contentType: proxy.textContentType) : text
        proxy.insertText(spaced)
        if let after = charactersAfterCursor, after > 0 {
            proxy.adjustTextPosition(byCharacterOffset: -after)
        }
        refreshWordBeforeCursor()
    }

    private func show(_ session: FillSession?) {
        keyboardState.fill = session
        FillSession.save(session)
        refreshWordBeforeCursor()
        if let field = session?.field, let session {
            UIAccessibility.post(notification: .announcement, argument: String(localized: "\(field.label), \(session.index + 1) of \(session.fields.count)", bundle: snapshotBundle ?? .main))
        }
    }

    /// The `adjustTextPosition(byCharacterOffset:)` offset that steps back over `text`.
    static func cursorLength(_ text: String) -> Int { text.utf16.count }

    /// A choice, a value used before or the clipboard fills the waiting blank, and the next one comes up.
    fileprivate func fillPick(_ value: String) {
        guard var session = keyboardState.fill, let field = session.field else { return }
        session.values[field.key] = value
        advance(session)
    }

    fileprivate func fillPaste() {
        guard let text = UIPasteboard.general.string, !text.isEmpty else { return }
        fillPick(String(text.prefix(FillInMemory.maxValueLength)))
    }

    /// The return key: the next blank, or on the last one the finished text.
    fileprivate func fillNext() {
        guard let session = keyboardState.fill, session.field != nil else { return }
        advance(session)
    }

    private func advance(_ start: FillSession) {
        var session = start
        if session.isLast {
            finish(session)
        } else {
            session.index += 1
            show(session)
        }
    }

    /// Takes out what the person typed for the blanks, then types the finished text.
    private func finish(_ session: FillSession) {
        let proxy = textDocumentProxy
        if !session.typed.isEmpty, (proxy.documentContextBeforeInput ?? "").hasSuffix(session.typed) {
            for _ in session.typed { proxy.deleteBackward() }
        }
        var values = session.values
        for field in session.fields where values[field.key] == nil { values[field.key] = field.options.first ?? "" }
        FillInMemory.remember(values.filter { !$0.value.isEmpty })
        let rendered = Self.render(session.chunks, values: values)
        show(nil)
        insert(rendered.text, smartSpacing: session.smartSpacing, charactersAfterCursor: rendered.afterCursor)
        if let cutling = store.cutlings.first(where: { $0.id == session.cutlingID }) { FillInCounters.advance(after: cutling) }
    }

    /// Type with Your Keyboard: remembers where the cursor was, then goes to the person's keyboard.
    fileprivate func fillTypeOnOwnKeyboard() {
        guard var session = keyboardState.fill else { return }
        session.anchor = String((textDocumentProxy.documentContextBeforeInput ?? "").suffix(40))
        FillSession.save(session)
        keyboardState.fill = session
        advanceToNextInputMode()
    }

    /// Back from the person's keyboard: what they typed since leaving fills the waiting blank.
    private func pickUpTypedValue() {
        guard var session = keyboardState.fill, let anchor = session.anchor, let field = session.field else { return }
        session.anchor = nil
        let context = textDocumentProxy.documentContextBeforeInput ?? ""
        if let typed = FillSession.typed(after: anchor, in: context), !typed.isEmpty {
            let value = typed.trimmingCharacters(in: .whitespacesAndNewlines)
            if !value.isEmpty {
                session.values[field.key] = String(value.prefix(FillInMemory.maxValueLength))
                session.typed += typed
            }
        }
        show(session)
    }

    /// Leaves what the person typed and forgets the cutling.
    fileprivate func fillCancel() {
        show(nil)
    }

    /// Adds a space after a word, and drops a doubled one.
    static func spaced(_ value: String, after before: String, keyboardType: UIKeyboardType, contentType: UITextContentType?) -> String {
        // Spaces would break URLs, emails, usernames and codes.
        let spacelessTypes: [UIKeyboardType] = [.URL, .emailAddress, .webSearch, .numberPad, .decimalPad, .numbersAndPunctuation, .asciiCapableNumberPad]
        let spacelessContent: [UITextContentType] = [.URL, .emailAddress, .username, .oneTimeCode]
        if spacelessTypes.contains(keyboardType) { return value }
        if let contentType, spacelessContent.contains(contentType) { return value }
        guard let last = before.last, let first = value.first else { return value }
        if last == " " && first == " " { return String(value.dropFirst()) }
        let opensSpan = "([{\"'“‘/@#$-\n\t".contains(last)
        let closesSpan = first.isWhitespace || ".,;:!?)]}…".contains(first)
        if !last.isWhitespace && !opensSpan && !closesSpan { return " " + value }
        return value
    }

    /// Caches the user's system text replacements for the app to import.
    private func cacheTextReplacements() {
        // UIKit calls this on a background XPC queue, not the main actor.
        requestSupplementaryLexicon { @Sendable lexicon in
            let pairs = lexicon.entries
                .filter { $0.userInput.caseInsensitiveCompare($0.documentText) != .orderedSame }
                .map { ["shortcut": $0.userInput, "phrase": $0.documentText] }
            UserDefaults(suiteName: "group.com.matsuokengo.Cutling")?.set(pairs, forKey: TextReplacementImport.defaultsKey)
        }
    }
}

// MARK: - Key Styling

enum KeyStyle {
    static let cornerRadius: CGFloat = 10
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
    
    /// The whole keyboard's height, as KeyboardView stacks it: top pad, suggestion bar, grid, bottom row,
    /// the spacing between them and 2 pt under the bottom row. Known before SwiftUI lays anything out,
    /// so the input view has its height from its first frame on a cold launch.
    static func keyboardHeight(for sizeClass: UserInterfaceSizeClass?, isLandscape: Bool) -> CGFloat {
        let key = keyHeight(for: sizeClass, isLandscape: isLandscape)
        let spacing = keySpacing(for: sizeClass)
        return spacing + (key + spacing) + spacing + gridHeight(for: sizeClass, isLandscape: isLandscape) + spacing + key + 2
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
/// 3. After 2 s of repeating, delete two words at a time
struct BackspaceRepeat: ViewModifier {
    let cornerRadius: CGFloat
    let onDelete: () -> Bool
    let onDeleteWord: (Int) -> Bool

    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    @State private var isHighlighted = false
    @State private var repeatTask: Task<Void, Never>?

    private static let haptic = UIImpactFeedbackGenerator(style: .light)

    // Apple's keyboard, filmed holding delete over 96 characters (iOS 27.2 simulator, ASG159): one character on
    // touch-down, the repeat 0.5 s later, a character every 100 ms for 2 s, then two words every 350 ms.
    private static let initialDelay: Duration = .milliseconds(500)
    private static let charRepeatInterval: Duration = .milliseconds(100)
    private static let wordPhaseThreshold: Duration = .milliseconds(2000)
    private static let wordRepeatInterval: Duration = .milliseconds(350)

    private static let cancelThreshold: CGFloat = 40
    private static let scrollDetectionThreshold: CGFloat = 8

    private var highlightColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.3)
            : Color.black.opacity(0.25)
    }

    private func track(_ offset: CGSize) {
        let shouldCancel =
            abs(offset.height) > Self.scrollDetectionThreshold &&
            abs(offset.height) > abs(offset.width)
        let inside = max(abs(offset.width), abs(offset.height)) < Self.cancelThreshold

        if shouldCancel || !inside {
            releaseBackspace()
            return
        }

        if !isPressed {
            isPressed = true
            isHighlighted = true
            Self.haptic.impactOccurred()
            KeyboardSound.delete.play()
            if onDelete() {
                startRepeat()
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .background(Color.keyHitTest)
            .overlay(
                isHighlighted
                    ? RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(highlightColor)
                    : nil
            )
            // Read from UIKit, as InstantPress; a cancelled touch stops the repeat too.
            .overlay(
                KeyTouchSurface(
                    onDown: { track(.zero) },
                    onMove: { track($0) },
                    onUp: { _ in releaseBackspace() },
                    onCancel: { releaseBackspace() }
                )
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
                let deleted: Bool
                if elapsed >= Self.wordPhaseThreshold {
                    deleted = onDeleteWord(2)
                    if deleted {
                        Self.haptic.impactOccurred(intensity: 0.75)
                        KeyboardSound.delete.play()
                    }
                    try? await Task.sleep(for: Self.wordRepeatInterval)
                } else {
                    deleted = onDelete()
                    if deleted {
                        Self.haptic.impactOccurred(intensity: 0.75)
                        KeyboardSound.delete.play()
                    }
                    try? await Task.sleep(for: Self.charRepeatInterval)
                }
                if !deleted {
                    isHighlighted = false
                    break
                }
            }
        }
    }

    private func releaseBackspace() {
        repeatTask?.cancel()
        repeatTask = nil
        isPressed = false
        isHighlighted = false
    }
}

extension View {
    func backspaceRepeat(
        cornerRadius: CGFloat = KeyStyle.cornerRadius,
        onDelete: @escaping () -> Bool,
        onDeleteWord: @escaping (Int) -> Bool
    ) -> some View {
        modifier(BackspaceRepeat(cornerRadius: cornerRadius, onDelete: onDelete, onDeleteWord: onDeleteWord))
    }
}

// MARK: - Keyboard Root View

struct KeyboardView: View {
    @ObservedObject var store: CutlingStore
    @ObservedObject var state: KeyboardState
    let onInsertText: (String) -> Void
    let onUseCutling: (Cutling, Int, Bool) -> Void
    let onFillPick: (String) -> Void
    let onFillPaste: () -> Void
    let onFillNext: () -> Void
    let onFillTypeOnOwnKeyboard: () -> Void
    let onFillCancel: () -> Void
    let onCopyImage: (Data) -> Void
    let onBackspace: () -> Bool
    let onDeleteWord: (Int) -> Bool
    let onSwitchKeyboard: () -> Void

    @State private var copiedID: UUID? = nil
    @State private var existedID: UUID? = nil
    @State private var newlyAddedID: UUID? = nil
    @State private var showAddedToast = false
    @State private var copiedStyledID: UUID? = nil
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
        let _ = LaunchMarks.once("first keyboard body")
        VStack(spacing: keySpacing) {
            Group {
                if let session = state.fill, session.field != nil {
                    FillInBar(session: session, keyHeight: keyHeight, bundle: snapshotBundle, onCancel: onFillCancel)
                } else {
                    suggestionBar
                }
            }
                .padding(.horizontal, KeyStyle.horizontalPadding)
                .frame(height: keyHeight + keySpacing)
                .padding(.top, keySpacing)

            Group {
                // The fill-in screen replaces the grid at once, as Apple's keyboard swaps layouts.
                if let session = state.fill, session.field != nil {
                    FillInKeys(session: session, canPaste: state.hasFullAccess, bundle: snapshotBundle, keyHeight: keyHeight, keySpacing: keySpacing,
                               onYourKeyboard: onFillTypeOnOwnKeyboard, onPick: onFillPick, onPaste: onFillPaste)
                } else {
                    cutlingGrid
                }
            }
            .frame(height: gridHeight)

            bottomRow
                .padding(.horizontal, KeyStyle.horizontalPadding)
                .frame(height: keyHeight)
        }
        .accessibilityIdentifier("CutlingKeyboardView")
        .padding(.bottom, 2)
        .tint(Color(hex: 0x00be86))
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
                        Text("Add from Clipboard", bundle: snapshotBundle)
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
                            Text("Enable Full Access for Clipboard", bundle: snapshotBundle)
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
                    toastOverlay(icon: "checkmark", text: String(localized: "Added!", bundle: snapshotBundle))
                }
                if showNoAccessToast {
                    toastOverlay(icon: "lock.fill", text: String(localized: "Full Access Required", bundle: snapshotBundle))
                }
                if showEmptyClipboardToast {
                    toastOverlay(icon: "doc.on.clipboard", text: String(localized: "Clipboard Empty", bundle: snapshotBundle))
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
                    .background(Color.keyHitTest)
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
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 99, style: .continuous)
        )
        .transition(AsymmetricTransition(
            insertion: .scale(0.85).combined(with: .opacity),
            removal: .opacity
        ))
        .allowsHitTesting(false)
    }

    // MARK: - Input Type Suggestion

    /// Text cutlings whose name starts with the word before the cursor.
    private func wordMatches(from liveCutlings: [Cutling]) -> [Cutling] {
        let word = state.wordBeforeCursor
        guard word.count >= 2 else { return [] }
        return liveCutlings.filter { cutling in
            cutling.kind == .text
                && cutling.name.range(of: word, options: [.anchored, .caseInsensitive, .diacriticInsensitive]) != nil
                && cutling.plainValue.caseInsensitiveCompare(word) != .orderedSame
        }
        .prefix(6)
        .map { $0 }
    }

    /// Cutlings whose inputTypeTriggers match the current text field context.
    private func suggestedCutlings(from liveCutlings: [Cutling]) -> [Cutling] {
        let activeKeys = InputTypeCategory.activeTriggerKeys(
            keyboardType: state.keyboardType,
            textContentType: state.textContentType
        )
        guard !activeKeys.isEmpty else { return [] }

        return liveCutlings.filter { cutling in
            guard let triggers = cutling.inputTypeTriggers, !triggers.isEmpty else { return false }
            return !Set(triggers).isDisjoint(with: activeKeys)
        }
    }

    // MARK: - Cutling Grid

    private var cutlingGrid: some View {
        let liveCutlings = store.cutlings.filter { !$0.isExpired }
        let matches = wordMatches(from: liveCutlings)
        let matchIDs = Set(matches.map(\.id))
        let suggested = matches + suggestedCutlings(from: liveCutlings).filter { !matchIDs.contains($0.id) }
        let suggestedIDs = Set(suggested.map(\.id))
        let remaining = liveCutlings.filter { !suggestedIDs.contains($0.id) }

        // Reused cells, not a lazy stack: a lazy stack keeps every key it has built, and the keyboard has 77 MB.
        return Group {
            if liveCutlings.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "rectangle.on.rectangle.slash")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                    Text("No Cutlings Yet", bundle: snapshotBundle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text("Open Cutling to add snippets", bundle: snapshotBundle)
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 16)
            } else {
                CutlingKeyGrid(
                    sections: [
                        CutlingKeySection(title: Text("Suggestions", bundle: snapshotBundle), cutlings: suggested, dividerAfter: true),
                        CutlingKeySection(cutlings: remaining)
                    ],
                    cardHeight: KeyStyle.cardHeight(for: horizontalSizeClass),
                    cardMinWidth: KeyStyle.cardMinWidth(for: horizontalSizeClass),
                    spacing: keySpacing,
                    horizontalPadding: KeyStyle.horizontalPadding,
                    scrollTarget: existedID ?? newlyAddedID
                ) { cutling in
                    CutlingKeyView(
                        cutling: cutling,
                        store: store,
                        isCopied: copiedID == cutling.id,
                        isExisted: existedID == cutling.id,
                        isBlocked: isBlockedByASCIIField(cutling),
                        copiedStyled: copiedStyledID == cutling.id,
                        onCopyStyled: copyStyledAction(for: cutling),
                        onTap: { handleTap(cutling, replacesWord: matchIDs.contains(cutling.id)) }
                    )
                }
            }
        }
        .onChange(of: newlyAddedID) { _, newValue in
            // The grid scrolls to it on its next update; then it is spent.
            guard newValue != nil else { return }
            Task {
                try? await Task.sleep(for: .seconds(0.6))
                newlyAddedID = nil
            }
        }
        .background(Color.keyHitTest)
    }

    // MARK: - Bottom Row

    private var bottomRow: some View {
        // During a fill-in the return key moves to the next blank (arrow), then inserts (checkmark).
        let info = state.fill.flatMap { $0.field == nil ? nil : ReturnKeyInfo(icon: $0.isLast ? "checkmark" : "arrow.right", isAction: true) }
            ?? ReturnKeyInfo.from(state.returnKeyType)

        return HStack(spacing: keySpacing) {
            // Next Keyboard (Globe) - only shown when needed
            if state.needsInputModeSwitchKey {
                Image(systemName: "globe")
                    .font(.system(size: 20, weight: .light))
                    .frame(width: smallKeyWidth, height: keyHeight)
                    .background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
                    .accessibilityLabel("Next keyboard")
                    .accessibilityAddTraits(.isButton)
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
                .instantPress(sound: .modifier) { onInsertText(" ") }

            // Return — icon + action tint
            Image(systemName: info.icon)
                .font(.system(size: 18, weight: info.isAction ? .semibold : .light))
                .foregroundStyle(info.isAction ? .white : .primary)
                .frame(width: 92, height: keyHeight)
                .background(
                    info.isAction
                        ? AnyShapeStyle(Color(hex: 0x01be86))
                        : AnyShapeStyle(KeyStyle.keyColor),
                    in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous)
                )
                // VoiceOver reads the return key as a button, and during a fill-in as Next or Insert.
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel(ifPresent: state.fill.flatMap { $0.field == nil ? nil : Text($0.isLast ? "Insert" : "Next", bundle: snapshotBundle) })
                .instantPress(sound: .modifier) {
                    if state.fill?.field != nil { onFillNext() } else { onInsertText("\n") }
                }
                .animation(.easeInOut(duration: 0.15), value: state.returnKeyType)
        }
    }

    // MARK: - Actions

    /// ASCII-only fields can't take non-ASCII text.
    private func isBlockedByASCIIField(_ cutling: Cutling) -> Bool {
        guard cutling.kind == .text,
              state.keyboardType == .asciiCapable || state.keyboardType == .asciiCapableNumberPad
        else { return false }
        return !cutling.plainValue.allSatisfy(\.isASCII)
    }

    /// Keyboards can only type plain text, so a tap types every key's text and a Formatted
    /// key's long press copies the styled version for the user to paste.
    private func copyStyledAction(for cutling: Cutling) -> (() -> Void)? {
        guard cutling.kind == .text, cutling.textFormat == .rich,
              state.hasFullAccess, !CutlingPasteboard.alwaysPastesPlain
        else { return nil }
        return {
            CutlingPasteboard.copy(cutling.filled(.now(values: nil)).cutling)
            FillInCounters.advance(after: cutling)
            copiedStyledID = cutling.id
            showCopied(cutling.id)
            incrementPasteCount()
        }
    }

    private func handleTap(_ cutling: Cutling, replacesWord: Bool = false) {
        guard !isBlockedByASCIIField(cutling) else { return }
        switch cutling.kind {
        case .text:
            onUseCutling(cutling, replacesWord ? state.wordBeforeCursor.count : 0, cutling.textFormat != .code)
            copiedStyledID = nil
            showCopied(cutling.id)
            incrementPasteCount()
        case .image:
            if !state.hasFullAccess {
                flashToast($showNoAccessToast, warning: true)
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
        // Check for image first - try to get raw data to preserve format (GIF, etc.)
        if let imageData = clipboardImageData() {
            addImageFromClipboard(imageData)
            return
        }

        // Otherwise check for text
        guard let rawText = UIPasteboard.general.string, !rawText.isEmpty else {
            flashToast($showEmptyClipboardToast, warning: true)
            return
        }

        addTextFromClipboard(rawText)
    }

    private func clipboardImageData() -> Data? {
        if let data = UIPasteboard.general.data(forPasteboardType: UTType.gif.identifier) {
            return data
        }
        if let data = UIPasteboard.general.data(forPasteboardType: UTType.png.identifier) {
            return data
        }
        if let data = UIPasteboard.general.data(forPasteboardType: UTType.jpeg.identifier) {
            return data
        }
        // Fallback: convert UIImage to PNG or JPEG
        if let image = UIPasteboard.general.image {
            return image.pngData() ?? image.jpegData(compressionQuality: 1.0)
        }
        return nil
    }

    private func addImageFromClipboard(_ imageData: Data) {
        // Check for duplicate image first
        if let existing = store.findDuplicateImage(data: imageData) {
            showExisted(existing.id)
            return
        }

        // Check image limit
        guard store.canAdd(.image).allowed else {
            showLimitReached(for: .image)
            return
        }

        let id = UUID()
        let imageName = String(localized: "Image: \(timestampString())", bundle: snapshotBundle)
        var cutling = Cutling(
            id: id,
            name: imageName,
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

        flashToast($showAddedToast)
    }

    private func addTextFromClipboard(_ rawText: String) {
        // Truncate to character limit
        let text = rawText.count > store.textLimit(excluding: nil)
            ? String(rawText.prefix(store.textLimit(excluding: nil)))
            : rawText

        if let existing = store.findDuplicateText(value: text) {
            showExisted(existing.id)
            return
        }

        // Check text limit
        guard store.canAdd(.text).allowed else {
            showLimitReached(for: .text)
            return
        }

        // Formatting comes from RTF only; HTML import needs WebKit.
        var value = text
        var format = TextFormat.suggested(for: text)
        if let markdown = CutlingPasteboard.formattedMarkdown(allowHTML: false),
           RichText.plainText(markdown).count <= store.textLimit(excluding: nil),
           markdown.count <= RichText.maxStoredLength {
            value = markdown
            format = .rich
        }

        let clipName = String(localized: "Clip: \(timestampString())", bundle: snapshotBundle)
        let cutling = Cutling(
            name: clipName,
            value: value,
            icon: "doc.on.clipboard",
            format: format == .plain ? nil : format
        )

        store.add(cutling)
        if let added = store.cutlings.first(where: { $0.id == cutling.id }) {
            KeyboardSyncHelper.upload(added, imagesDirectory: store.imagesDirectory)
        }
        newlyAddedID = cutling.id

        flashToast($showAddedToast)
    }

    private func timestampString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }

    /// Show a transient toast: animate in, hold, animate out.
    private func flashToast(_ binding: Binding<Bool>, hold: Duration = .seconds(1.5), warning: Bool = false) {
        if warning {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
        withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
            binding.wrappedValue = true
        }
        Task {
            try? await Task.sleep(for: hold)
            withAnimation(.easeOut(duration: 0.25)) {
                binding.wrappedValue = false
            }
        }
    }

    private func showLimitReached(for kind: CutlingKind) {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        switch kind {
        case .image:
            limitToastMessage = String(localized: "Image Limit: \(CutlingStore.maxImageCutlings)", bundle: snapshotBundle)
        case .text:
            limitToastMessage = String(localized: "Text Limit: \(CutlingStore.maxTextCutlings)", bundle: snapshotBundle)
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
    var isBlocked: Bool = false
    var copiedStyled = false
    /// A Formatted key's long-press Copy; nil for every other key.
    var onCopyStyled: (() -> Void)? = nil
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
                        .stroke(Color(hex: 0x01be86), lineWidth: 2)
                        .shadow(color: Color(hex: 0x01be86).opacity(0.6), radius: 2)
                        // The "Shine/Pulse" effect
                        .overlay(
                            RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous)
                                .fill(Color(hex: 0x01be86).opacity(0.15))
                        )
                }
                // Typed text needs no confirmation, as on Apple's keyboards; only a copied image says so (ASG101).
                if isCopied && (cutling.kind == .image || copiedStyled) {
                    RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    Label {
                        Text(cutling.kind == .text && !copiedStyled ? "Inserted" : "Copied", bundle: snapshotBundle)
                    } icon: {
                        Image(systemName: "checkmark")
                    }
                    .font(.subheadline.weight(.semibold))
                    .transition(AsymmetricTransition(
                        insertion: .scale(0.85).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
            .scaleEffect(isExisted ? 1.025 : 1.0)
            .animation(.spring(duration: 0.4, bounce: 0.5), value: isExisted)
        }
        .buttonStyle(KeyboardButtonStyle())
        .contextMenu {
            if let onCopyStyled {
                Button("Copy", systemImage: "doc.on.doc", action: onCopyStyled)
            }
        }
        .disabled(isBlocked)
        .opacity(isBlocked ? 0.4 : 1)
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
            cutling.displayText(pillSize: KeyStyle.bodySize(for: horizontalSizeClass))
                .font(.system(size: KeyStyle.bodySize(for: horizontalSizeClass)))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                // A Formatted cutling's link is drawn, not followed: a tap anywhere on the key types it.
                .allowsHitTesting(false)
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

extension View {
    /// An accessibility label only when there is one; otherwise the view keeps the label it derives.
    @ViewBuilder
    func accessibilityLabel(ifPresent label: Text?) -> some View {
        if let label { accessibilityLabel(label) } else { self }
    }
}
