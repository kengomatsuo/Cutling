//
//  TutorialOverlay.swift
//  Cutling: interactive, forced, skippable coach-mark walkthrough for iOS.
//
//  A "learn by doing" walkthrough that drives the user through the four core
//  flows — create, edit, delete, recover — one concrete action at a time. The
//  user actually taps the real +, names and types a cutling, saves it, edits
//  it, deletes it, then recovers it. Each step blocks on the real action (the
//  walkthrough advances only when the app observes it happen) yet stays
//  skippable at every point, per Apple's HIG (Onboarding: "Teach through
//  interactivity" / "consider making it optional").
//
//  Controls publish their live global frame via `.tutorialFrame(_:)`; each
//  participating screen hosts its own overlay via `.tutorialOverlay(_:)` so
//  coach-marks can render above presented sheets and pushed destinations.
//

#if os(iOS)
import SwiftUI
import TipKit

// MARK: - Screens, Targets, Steps

enum TutorialScreen {
    case grid
    case editor
    case recentlyDeleted
}

/// The on-screen control a step points at.
enum TutorialTarget: Hashable {
    case addButton          // toolbar +
    case editorName         // Name field (unioned with its header)
    case editorNameHeader   // "Name" section header
    case editorText         // Text editor (unioned with its header + footer)
    case editorTextHeader   // "Text" section header
    case editorTextFooter   // "Text" section footer (char count)
    case editorSave         // confirm/save toolbar button
    case editorDelete       // "Delete Cutling" button at the bottom of the editor
    case editEllipsis       // the ⋯ button on a card (opens the editor directly)
    case card               // the whole new card (celebration)
    case backButton         // the editor's navigation Back button
    case recoverCard        // a card in Recently Deleted
    case moreButton         // toolbar ellipsis
}

enum TutorialStep: Int, CaseIterable {
    case createAdd
    case createName
    case createSave
    case createdCelebrate
    case editOpen
    case editSave
    case deleteOpen
    case deleteConfirm
    case recoverIntro
    case recoverTap
    case recoveredCelebrate

    var screen: TutorialScreen {
        switch self {
        case .createAdd, .createdCelebrate, .editOpen, .deleteOpen, .recoveredCelebrate: return .grid
        case .createName, .createSave, .editSave, .deleteConfirm: return .editor
        case .recoverIntro, .recoverTap: return .recentlyDeleted
        }
    }

    /// A page-intro step (centred caption, no spotlight, tap Next to continue).
    var isIntro: Bool { self == .recoverIntro }

    /// The spotlight target for custom-overlay (grid) steps. Editor and recover
    /// steps use native TipKit popovers instead.
    func target(hintShown: Bool) -> TutorialTarget {
        switch self {
        case .createAdd: return .addButton
        case .createName: return .editorName
        case .createSave: return hintShown ? .editorSave : .editorText
        case .createdCelebrate: return .card
        case .editSave: return .backButton
        case .editOpen, .deleteOpen: return .editEllipsis
        case .deleteConfirm: return .editorDelete
        case .recoverIntro, .recoverTap: return .recoverCard
        case .recoveredCelebrate: return .card
        }
    }

    func message(hintShown: Bool) -> LocalizedStringKey {
        switch self {
        case .createAdd: return "Tap + to start a new text cutling."
        case .createName: return "Give your cutling a name."
        case .createSave:
            return hintShown
                ? "Tap here to save your cutling."
                : "Now type the text you want to save."
        case .createdCelebrate: return "Nice! Your cutling is saved."
        case .editOpen: return "Tap the ⋯ button on a card to open and edit it."
        case .editSave: return "Edit the text, then tap Back. Your changes save automatically."
        case .deleteOpen: return "To delete, open a cutling with the ⋯ button."
        case .deleteConfirm: return "Scroll down and tap Delete Cutling to remove it."
        case .recoverIntro: return "Deleted cutlings will appear here for 30 days."
        case .recoverTap: return "Touch and hold a deleted cutling, then tap Recover."
        case .recoveredCelebrate: return "Recovered! Your cutling is back."
        }
    }

    /// The editor steps don't darken the sheet; only the grid dims.
    var dimsBackground: Bool { screen != .editor }

    /// Steps advanced by a button in the coach-mark.
    var showsNext: Bool { self == .createName || self == .createdCelebrate || self == .recoverIntro }
    /// The name step's Next is gated until the name has content.
    var nextRequiresValidName: Bool { self == .createName }

    var isLast: Bool { self == .recoveredCelebrate }
}

// MARK: - Coordinator

/// Shared driver so the grid, the editor sheet/push, and the Recently Deleted
/// screen all observe and report into one walkthrough. The "seen" flag is
/// persisted by `MainContentView` when `isActive` flips to false.
@MainActor
@Observable
final class TutorialCoordinator {
    static let shared = TutorialCoordinator()
    private init() {}

    var isActive = false
    var step: TutorialStep = .createAdd
    /// Live global frames of registered controls, keyed by target.
    var frames: [TutorialTarget: CGRect] = [:]
    /// On the editor save/edit steps, flips true ~2.5s after the user pauses so
    /// the spotlight moves from "type the text" to the save hint.
    var editorHintShown = false
    /// Whether Save is currently valid (name + text filled). The save hint only
    /// appears when true; clearing a field reverts the spotlight to typing.
    var editorCanSave = false
    /// Whether the Name field has content (gates the name step's Next button).
    var nameFieldFilled = false
    /// Set by the editor's OK button to hide the caption so it stops covering
    /// the controls the user is editing (the spotlight ring stays).
    var captionHidden = false
    /// True while a deleted card's context menu is (likely) open, so the recover
    /// overlay hides and doesn't clash with the menu.
    /// After the walkthrough finishes via recover, the More button shows the
    /// "where Recently Deleted lives" popover instead of the usual More tip.
    var recoverWhereActive = false

    func showRecoverWhereTip() {
        recoverWhereActive = true
        RecoverWhereTip.active = true
    }

    /// (Re)start the pause countdown. After 2.5s with no further edits, if Save
    /// is valid, nudge toward the Save button.
    func startEditorHintTimer() {
        editorHintShown = false
        let target = step
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.5))
            if isActive, step == target, editorCanSave {
                editorHintShown = true
            }
        }
    }

    /// Debounce task for editor-tip transitions.
    @ObservationIgnored private var editorTipTask: Task<Void, Never>?

    func start() {
        frames = [:]
        editorHintShown = false
        editorCanSave = false
        nameFieldFilled = false
        captionHidden = false
        recoverWhereActive = false
        RecoverWhereTip.active = false
        step = .createAdd
        isActive = true
        // Replay: make the in-sheet tips eligible again if previously closed.
        if #available(iOS 26, *) {
            Task { @MainActor in
                await EditorNameTip().resetEligibility()
                await EditorTextTip().resetEligibility()
                await EditorSaveTip().resetEligibility()
                await EditorBackTip().resetEligibility()
                await EditorDeleteTip().resetEligibility()
                await RecoverWhereTip().resetEligibility()
            }
        }
        setEditorAnchor(.none)
    }

    /// Advance only if we're on `expected`, so unrelated state changes can't
    /// skip ahead or fire twice.
    func advance(from expected: TutorialStep) {
        guard isActive, step == expected else { return }
        captionHidden = false
        editorTipTask?.cancel()
        setEditorAnchor(.none)   // clear the previous tip during the transition
        if let next = TutorialStep(rawValue: step.rawValue + 1) {
            step = next
        } else {
            finish()
            // After the whole walkthrough finishes, teach where Recently
            // Deleted lives via the More-button popover.
            showRecoverWhereTip()
        }
    }

    /// Recover from a dead-end (e.g. the user cancels the create editor).
    func reset(to target: TutorialStep) {
        guard isActive, step != target else { return }
        captionHidden = false
        editorTipTask?.cancel()
        setEditorAnchor(.none)
        step = target
    }

    func skip() { finish() }
    func finish() { isActive = false; editorTipTask?.cancel(); setEditorAnchor(.none) }

    // MARK: In-sheet tip anchoring

    /// Show the tip for the current editor step. Called by the editor view only
    /// AFTER its zoom transition (and any scroll) has settled.
    func showEditorTipForCurrentStep() {
        editorTipTask?.cancel()
        guard isActive else { return setEditorAnchor(.none) }
        switch step {
        case .createName:    setEditorAnchor(.name)
        case .createSave:    setEditorAnchor(.text)
        case .editSave:      setEditorAnchor(.back)
        case .deleteConfirm: setEditorAnchor(.delete)
        default:             setEditorAnchor(.none)
        }
    }

    /// Reacts to typing. Editor tips are inline now, so we don't hide/re-present
    /// popovers on every keystroke (that churn resigned/restored first-responder
    /// and bounced the cursor). We just advance after a pause.
    func editorTypingChanged(valueEmpty: Bool) {
        guard isActive else { return }
        switch step {
        case .createName:
            // Finished naming → move on to the value step after a pause.
            editorTipTask?.cancel()
            setEditorAnchor(.none)   // dismiss the Name popover (restores to Name)
            editorTipTask = Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                if !Task.isCancelled, isActive, step == .createName {
                    advance(from: .createName)
                }
            }
        case .createSave:
            // Keep the inline text tip visible while typing; once there's text
            // and the user pauses, move the spotlight to the Save button.
            editorTipTask?.cancel()
            if valueEmpty {
                setEditorAnchor(.text)
            } else {
                editorTipTask = Task { @MainActor in
                    try? await Task.sleep(for: .seconds(2))
                    if !Task.isCancelled, isActive, step == .createSave {
                        setEditorAnchor(.save)
                    }
                }
            }
        case .editSave:
            break   // the inline Back tip stays put; no churn
        default:
            break
        }
    }

    private func scheduleEditorAnchor(_ anchor: EditorTipAnchor, after: Double) {
        editorTipTask?.cancel()
        editorTipTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(after))
            if !Task.isCancelled, isActive { setEditorAnchor(anchor) }
        }
    }

    private func setEditorAnchor(_ anchor: EditorTipAnchor) {
        let v = anchor.rawValue
        EditorNameTip.anchor = v
        EditorTextTip.anchor = v
        EditorSaveTip.anchor = v
        EditorBackTip.anchor = v
        EditorDeleteTip.anchor = v
    }

    // MARK: - UI locking
    //
    // A visual scrim can't cover the navigation bar (UIKit draws it above the
    // SwiftUI overlay) and can't reliably swallow long-press/buttons, so the
    // walkthrough hard-disables every control except the current step's target.

    /// The toolbar + is only live during the create step (where it opens a text
    /// cutling directly).
    var allowsAddButton: Bool { !isActive || step == .createAdd }

    /// The toolbar ellipsis stays locked during the walkthrough; afterwards the
    /// existing More-menu TipKit hint teaches where Recently Deleted lives.
    var allowsMoreButton: Bool { !isActive }

    /// Controls that never participate in the walkthrough (keyboard button,
    /// search, sort, select/reorder) stay disabled for its whole duration.
    var allowsUnrelatedControls: Bool { !isActive }

    /// How a grid card should behave for the current step. `isTarget` is the
    /// freshly created cutling the walkthrough wants the user to act on.
    func cardMode(isTarget: Bool) -> CardTutorialMode {
        guard isActive else { return .normal }
        switch step {
        case .editOpen, .deleteOpen:
            return isTarget ? .ellipsisOnly : .disabled
        default:
            return .disabled
        }
    }

    /// Whether a Recently Deleted row may be tapped (only the spotlighted first
    /// row during the recover step).
    func recoverRowEnabled(isFirst: Bool) -> Bool {
        guard isActive else { return true }
        return step != .recoverTap || isFirst
    }
}

// MARK: - Frame Reporting

extension View {
    /// Publishes this view's live global frame as the spotlight target.
    func tutorialFrame(_ target: TutorialTarget) -> some View {
        modifier(TutorialFrameReporter(target: target))
    }

    /// Reports the `.recoverCard` frame only for the first deleted card.
    func tutorialFirstRecoverCard(_ isFirst: Bool) -> some View {
        modifier(ConditionalFrameReporter(target: .recoverCard, active: isFirst))
    }

    /// Hosts the walkthrough overlay for `screen`. Renders only while the
    /// active step belongs to that screen.
    func tutorialOverlay(_ screen: TutorialScreen) -> some View {
        modifier(TutorialOverlayModifier(screen: screen))
    }
}

struct TutorialFrameReporter: ViewModifier {
    let target: TutorialTarget
    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self) {
            $0.frame(in: .global)
        } action: { rect in
            TutorialCoordinator.shared.frames[target] = rect
        }
    }
}

struct ConditionalFrameReporter: ViewModifier {
    let target: TutorialTarget
    let active: Bool
    func body(content: Content) -> some View {
        if active {
            content.tutorialFrame(target)
        } else {
            content
        }
    }
}

// MARK: - Overlay

struct TutorialOverlayModifier: ViewModifier {
    let screen: TutorialScreen
    private var tutorial: TutorialCoordinator { .shared }

    func body(content: Content) -> some View {
        content.overlay {
            if tutorial.isActive && tutorial.step.screen == screen {
                TutorialCoachmark()
                    .transition(.opacity)
            }
        }
    }
}

/// The dimming + spotlight + caption for the current step, resolved into the
/// hosting screen's local coordinate space.
struct TutorialCoachmark: View {
    private var tutorial: TutorialCoordinator { .shared }
    @State private var captionHeight: CGFloat = 140

    var body: some View {
        let step = tutorial.step
        let hint = tutorial.editorHintShown
        let target = step.target(hintShown: hint)

        // The GeometryReader must ignore the safe area so that `proxy` spans the
        // full screen: target frames are reported in global (window) coordinates,
        // and `proxy.frame(in: .global).origin` then matches the same space the
        // holes and caption are positioned in. (If only the inner ZStack ignores
        // the safe area, the position space and the local-rect space diverge by
        // the top inset and every box ends up misplaced.)
        GeometryReader { proxy in
            let origin = proxy.frame(in: .global).origin
            let size = proxy.size
            let local = resolvedRect(for: target, origin: origin, size: size)
            let radius = cornerRadius(for: target, rect: local ?? .zero)

            // The dim never intercepts touches (a tap-blocking scrim breaks text
            // field focus). The UI is locked instead by logically disabling every
            // non-target control. The editor steps don't dim at all, leaving the
            // sheet fully editable; only the grid / Recently Deleted darken.
            // Everything renders only when the element's frame is known, so the
            // bubble is always locked to the element (never floating at center).
            ZStack(alignment: .topLeading) {
                if step.isIntro {
                    // Page intro: a blocking dim + centred caption (no spotlight).
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture { }   // block interaction until Next
                    captionCard(message: step.message(hintShown: hint))
                        .frame(maxWidth: 360)
                        .padding(.horizontal, 20)
                        .position(x: size.width / 2, y: size.height * 0.4)
                } else if let hole = local {
                    if step.dimsBackground { dimWithCutout(hole, radius: radius) }
                    spotlightRing(hole, radius: radius)

                    if !tutorial.captionHidden {
                        captionCard(message: step.message(hintShown: hint))
                            .frame(maxWidth: 360)
                            .padding(.horizontal, 20)
                            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { captionHeight = $0 }
                            .position(captionPosition(hole: hole, size: size, target: target))
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: Geometry

    /// Target frame in the overlay's local space, with a sensible fallback for
    /// nav-bar controls whose frame may not be reported.
    private func resolvedRect(for target: TutorialTarget, origin: CGPoint, size: CGSize) -> CGRect? {
        if let g = tutorial.frames[target] {
            let f = g.offsetBy(dx: -origin.x, dy: -origin.y)
            // Guard against absurd/offscreen values.
            if f.width > 0, f.height > 0, f.minY > -200, f.minY < size.height + 200 {
                switch target {
                case .editorName, .editorText:
                    // Union every element of the section (header + field +
                    // footer) into one rect, with generous padding.
                    let keys: [TutorialTarget] = target == .editorName
                        ? [.editorName, .editorNameHeader]
                        : [.editorText, .editorTextHeader, .editorTextFooter]
                    var union: CGRect?
                    for key in keys {
                        guard let g = tutorial.frames[key] else { continue }
                        let r = g.offsetBy(dx: -origin.x, dy: -origin.y)
                        guard r.width > 0, r.height > 0 else { continue }
                        union = union.map { $0.union(r) } ?? r
                    }
                    guard let u = union else { return f.insetBy(dx: -10, dy: -10) }
                    let padX: CGFloat = 22
                    let padY: CGFloat = 9
                    let x = max(u.minX - padX, 4)
                    let maxX = min(u.maxX + padX, size.width - 4)
                    return CGRect(x: x, y: u.minY - padY, width: maxX - x, height: (u.maxY + padY) - (u.minY - padY))
                case .editEllipsis, .addButton, .moreButton, .editorSave:
                    // Icon / capsule buttons: a square (1:1) box so the circular
                    // ring has equal padding on every side.
                    return squared(f).insetBy(dx: -7, dy: -7)
                default:
                    return f.insetBy(dx: -7, dy: -7)
                }
            }
        }
        switch target {
        case .addButton:
            return CGRect(x: size.width - 90, y: 52, width: 40, height: 40)
        case .moreButton, .editorSave:
            return CGRect(x: size.width - 54, y: 52, width: 40, height: 40)
        case .backButton:
            return CGRect(x: 8, y: 52, width: 40, height: 40)
        default:
            return nil
        }
    }

    /// Expands a rect to a centred square using its larger dimension.
    private func squared(_ r: CGRect) -> CGRect {
        let side = max(r.width, r.height)
        return CGRect(x: r.midX - side / 2, y: r.midY - side / 2, width: side, height: side)
    }

    /// Match the spotlight's corner radius to the highlighted element's shape.
    private func cornerRadius(for target: TutorialTarget, rect: CGRect) -> CGFloat {
        switch target {
        case .editEllipsis, .addButton, .moreButton, .editorSave, .backButton:
            return rect.height / 2          // circular icon / capsule button
        case .recoverCard, .card:
            return 24                        // card
        case .editorName, .editorNameHeader, .editorText, .editorTextHeader,
             .editorTextFooter, .editorDelete:
            return 12                        // grouped form section
        }
    }

    /// Place the caption just outside the highlight (small gap), preferring the
    /// side with room. Form fields and cards get the caption above; nav-bar
    /// targets get it below.
    private func captionPosition(hole: CGRect, size: CGSize, target: TutorialTarget) -> CGPoint {
        let gap: CGFloat = 8
        let half = captionHeight / 2          // measured, so the gap is exact
        // Fixed side per target so the bubble never flips while frames jitter.
        let above: Bool
        switch target {
        case .editorText, .editorTextHeader, .editorTextFooter,
             .editorDelete, .editEllipsis, .card:
            above = true
        case .editorName, .editorNameHeader, .editorSave, .addButton,
             .moreButton, .backButton, .recoverCard:
            above = false   // deleted card sits near the top; caption goes below
        }
        let y = above ? hole.minY - gap - half : hole.maxY + gap + half
        // Keep the whole bubble below the nav/stack toolbar and on screen.
        let topLimit: CGFloat = 104
        let clamped = min(max(y, topLimit + half), size.height - half - 12)
        return CGPoint(x: size.width / 2, y: clamped)
    }

    // MARK: Pieces

    private func spotlightRing(_ rect: CGRect, radius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .stroke(Color.accentColor, lineWidth: 3)
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
            // A soft dark halo keeps the ring visible on white controls and
            // light backgrounds in Light Mode.
            .shadow(color: .black.opacity(0.35), radius: 3)
            .allowsHitTesting(false)
    }

    /// Non-blocking dim (taps pass through everywhere) with a cutout.
    private func dimWithCutout(_ hole: CGRect, radius: CGFloat) -> some View {
        Rectangle()
            .fill(Color.black.opacity(0.5))
            .mask {
                Rectangle()
                    .overlay {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .frame(width: hole.width, height: hole.height)
                            .position(x: hole.midX, y: hole.midY)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
            }
            .allowsHitTesting(false)
    }

    private func captionCard(message: LocalizedStringKey) -> some View {
        let step = tutorial.step
        return VStack(alignment: .leading, spacing: 10) {
            Text(message)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)

            ProgressView(
                value: Double(step.rawValue + 1),
                total: Double(TutorialStep.allCases.count)
            )
            .tint(.accentColor)

            HStack {
                Button { tutorial.skip() } label: {
                    Text("Skip Tutorial").font(.subheadline)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Spacer()

                if step.isLast {
                    Button { tutorial.advance(from: step) } label: {
                        Text("Done").font(.subheadline.weight(.semibold))
                    }
                    .modifier(GlassProminentButtonModifier())
                    .buttonBorderShape(.capsule)
                    .controlSize(.small)
                } else if step.showsNext {
                    // Always present (no layout shift); the name step's Next
                    // fades in only once the name is valid.
                    let enabled = !step.nextRequiresValidName || tutorial.nameFieldFilled
                    Button { tutorial.advance(from: step) } label: {
                        Text("Next").font(.subheadline.weight(.semibold))
                    }
                    .modifier(GlassProminentButtonModifier())
                    .buttonBorderShape(.capsule)
                    .controlSize(.small)
                    .opacity(enabled ? 1 : 0)
                    .disabled(!enabled)
                    .allowsHitTesting(enabled)
                    .animation(.easeInOut(duration: 0.2), value: enabled)
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
    }
}

/// Liquid Glass prominent button on iOS 26+ (no drop shadow), bordered
/// prominent on earlier versions.
private struct GlassProminentButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.buttonStyle(.glassProminent)
        } else {
            content.buttonStyle(.borderedProminent)
        }
    }
}
#endif
