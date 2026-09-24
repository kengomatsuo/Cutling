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
//  interactivity" / "If it makes sense to offer a separate tutorial, consider
//  making it optional").
//
//  Two pieces, deliberately separated:
//
//  * `TutorialHUD` — a persistent bar pinned to the bottom of EVERY
//    participating screen (grid, editor, Recently Deleted) carrying progress,
//    Skip and Next. It depends on nothing but `step`, so it is reachable even
//    when a spotlight target can't be located or a TipKit popover was closed.
//    This is the walkthrough's guaranteed escape hatch.
//  * `TutorialCoachmark` — the dim + spotlight + one-line instruction that
//    points at a control. Only the grid and Recently Deleted host it; the
//    editor steps use native TipKit popovers instead so the system handles
//    anchoring, scrolling and keyboard avoidance.
//
//  Controls publish their live global frame via `.tutorialFrame(_:)`; each
//  participating screen hosts the overlay via `.tutorialOverlay(_:)` and the
//  bar via `.tutorialHUD(_:)`.
//

#if os(iOS)
import SwiftUI
import TipKit
import UIKit

// MARK: - Screens, Targets, Steps

enum TutorialScreen {
    case grid
    case editor
    case recentlyDeleted
}

/// The on-screen control a step points at. Only controls that actually publish
/// a frame live here — the editor's fields are pointed at by TipKit popovers,
/// not by the spotlight, so they need no target.
enum TutorialTarget: Hashable {
    case addButton          // toolbar +
    case editEllipsis       // the ⋯ button on a card (opens the editor directly)
    case card               // the whole new card (celebration)
    case recoverCard        // a card in Recently Deleted
    case moreButton         // toolbar ellipsis (post-walkthrough RecoverWhereTip)
}

enum TutorialStep: Int, CaseIterable {
    case createIntro
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
        case .createIntro, .createAdd, .createdCelebrate, .editOpen, .deleteOpen, .recoveredCelebrate: return .grid
        case .createName, .createSave, .editSave, .deleteConfirm: return .editor
        case .recoverIntro, .recoverTap: return .recentlyDeleted
        }
    }

    /// A page-intro step (centred caption, no spotlight, tap Next to continue).
    var isIntro: Bool { self == .createIntro || self == .recoverIntro }

    /// The spotlight target, or nil for steps with no control to point at
    /// (page intros, and the editor steps that TipKit handles).
    var target: TutorialTarget? {
        switch self {
        case .createAdd: return .addButton
        case .editOpen, .deleteOpen: return .editEllipsis
        case .createdCelebrate, .recoveredCelebrate: return .card
        case .recoverTap: return .recoverCard
        case .createIntro, .recoverIntro, .createName, .createSave, .editSave, .deleteConfirm: return nil
        }
    }

    /// The single instruction for this step. `LocalizedStringResource` (rather
    /// than `LocalizedStringKey`) so the same string can be both rendered and
    /// read out to VoiceOver without duplicating the literal.
    var message: LocalizedStringResource {
        switch self {
        case .createIntro: return "Welcome to Cutling! Let's create your first cutling together."
        case .createAdd: return "Tap + to start a new text cutling."
        case .createName: return "Give your cutling a name."
        case .createSave: return "Now type the text you want to save."
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

    /// Steps advanced by the HUD's Next button rather than by a real action.
    var showsNext: Bool { self == .createIntro || self == .createName || self == .createdCelebrate || self == .recoverIntro }
    /// The name step's Next is gated until the name has content.
    var nextRequiresValidName: Bool { self == .createName }

    var isLast: Bool { self == .recoveredCelebrate }

    /// 1-based position, for the HUD's "n / total" counter.
    var number: Int { rawValue + 1 }
}

// MARK: - Coordinator

/// Shared driver so the grid, the editor sheet/push, and the Recently Deleted
/// screen all observe and report into one walkthrough. The "seen" flag is
/// persisted by `MainContentView` as soon as the walkthrough starts.
@MainActor
@Observable
final class TutorialCoordinator {
    static let shared = TutorialCoordinator()
    private init() {}

    var isActive = false
    var step: TutorialStep = .createAdd
    /// Live global frames of registered controls, keyed by target.
    var frames: [TutorialTarget: CGRect] = [:]
    /// Whether the Name field has content (gates the name step's Next button).
    var nameFieldFilled = false
    /// Whether a text field in the editor currently holds focus. While true no
    /// popover anchor may move — see `editorTypingChanged`.
    var editorFieldFocused = false
    /// After the walkthrough finishes via recover, the More button shows the
    /// "where Recently Deleted lives" popover instead of the usual More tip.
    var recoverWhereActive = false

    func showRecoverWhereTip() {
        recoverWhereActive = true
        RecoverWhereTip.active = true
    }

    /// Debounce task for editor-tip transitions.
    @ObservationIgnored private var editorTipTask: Task<Void, Never>?
    /// Debounce task for the VoiceOver step announcement.
    @ObservationIgnored private var announceTask: Task<Void, Never>?

    func start() {
        frames = [:]
        nameFieldFilled = false
        editorFieldFocused = false
        recoverWhereActive = false
        RecoverWhereTip.active = false
        step = .createIntro
        isActive = true
        // Replay: make the in-sheet tips eligible again if previously closed.
        // `resetEligibility()` is iOS 26+, so on earlier releases a tip the user
        // closed stays closed — which is exactly why the HUD, not the tip,
        // carries the walkthrough's controls.
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
        announce(step)
    }

    /// Advance only if we're on `expected`, so unrelated state changes can't
    /// skip ahead or fire twice.
    func advance(from expected: TutorialStep) {
        guard isActive, step == expected else { return }
        editorTipTask?.cancel()
        setEditorAnchor(.none)   // clear the previous tip during the transition
        if let next = TutorialStep(rawValue: step.rawValue + 1) {
            step = next
            announce(next)
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
        editorTipTask?.cancel()
        setEditorAnchor(.none)
        step = target
        announce(target)
    }

    func skip() { finish() }

    func finish() {
        isActive = false
        editorTipTask?.cancel()
        announceTask?.cancel()
        setEditorAnchor(.none)
    }

    /// Read the new step's instruction out to VoiceOver. Without this the
    /// walkthrough is invisible to VoiceOver users: the caption is a plain
    /// overlay and focus never moves to it on its own.
    private func announce(_ target: TutorialStep) {
        announceTask?.cancel()
        guard unsafe UIAccessibility.isVoiceOverRunning else { return }
        let text = String(localized: target.message)
        announceTask = Task { @MainActor in
            // Let the screen transition settle so the announcement isn't
            // interrupted by VoiceOver's own "screen changed" chatter.
            try? await Task.sleep(for: .seconds(0.8))
            guard !Task.isCancelled, isActive, step == target else { return }
            unsafe UIAccessibility.post(notification: .announcement, argument: text)
        }
    }

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

    /// Re-present the current editor tip after the user cancels the "Leave
    /// Tutorial?" alert. The alert dismisses (and invalidates) the popover, so we
    /// reset its eligibility and re-anchor once the alert has gone.
    func resumeEditorTips() {
        guard isActive else { return }
        editorTipTask?.cancel()
        Task { @MainActor in
            if #available(iOS 26, *) {
                await EditorNameTip().resetEligibility()
                await EditorTextTip().resetEligibility()
                await EditorSaveTip().resetEligibility()
                await EditorBackTip().resetEligibility()
                await EditorDeleteTip().resetEligibility()
            }
            setEditorAnchor(.none)
            try? await Task.sleep(for: .seconds(0.35))
            if isActive { showEditorTipForCurrentStep() }
        }
    }

    /// Reacts to typing.
    ///
    /// Nothing here may move a popover while a field is focused. Presenting a
    /// TipKit popover resigns first responder, so an anchor change mid-typing
    /// dismisses the keyboard and silently swallows the rest of what the user
    /// was writing. The old build ran this on a 2s idle timer, which any
    /// first-time user trips just by pausing to think — they'd type "My
    /// Address", get "My", and be bumped to the next step mid-word.
    func editorTypingChanged(nameEmpty: Bool, valueEmpty: Bool) {
        guard isActive else { return }
        // Gates the name step's Next button in the HUD. Typing does nothing
        // else — the pointer is moved by step transitions and by focus loss,
        // never by a keystroke timer.
        nameFieldFilled = !nameEmpty
    }

    /// Called by the editor whenever a text field gains or loses focus. The
    /// pointer only moves once the keyboard is down, so it can never interrupt.
    func editorFocusChanged(focused: Bool, nameEmpty: Bool, valueEmpty: Bool) {
        guard isActive else { return }
        editorFieldFocused = focused
        editorTipTask?.cancel()
        // Gaining focus leaves the current step's tip exactly where it is: it
        // sits above the field, and re-presenting it is what breaks typing.
        if focused { return }
        // Let the keyboard finish dismissing before anchoring, otherwise the
        // popover is positioned against a layout that's still moving.
        editorTipTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.4))
            guard !Task.isCancelled, isActive, !editorFieldFocused else { return }
            refreshEditorAnchor(nameEmpty: nameEmpty, valueEmpty: valueEmpty)
        }
    }

    /// Point at whatever the current step still needs, given what's filled in.
    private func refreshEditorAnchor(nameEmpty: Bool, valueEmpty: Bool) {
        switch step {
        case .createName:
            setEditorAnchor(nameEmpty ? .name : .none)
        case .createSave:
            // Guide toward whatever's still missing: title first, then text,
            // then the Save button once both are filled.
            if nameEmpty {
                setEditorAnchor(.name)
            } else if valueEmpty {
                setEditorAnchor(.text)
            } else {
                setEditorAnchor(.save)
            }
        case .editSave:
            break   // the inline Back tip stays put; no churn
        default:
            break
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
    /// sort, select/reorder) stay disabled for its whole duration.
    var allowsUnrelatedControls: Bool { !isActive }

    /// Search must stay closed: filtering the grid can hide the very card the
    /// walkthrough is pointing at, leaving the spotlight with nothing to
    /// resolve. `.searchable` can't be `.disabled()`, so the grid force-closes
    /// it instead.
    var allowsSearch: Bool { !isActive }

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
    /// row during the recover step). Newly deleted items are inserted at index
    /// 0, so the first row is always the one the walkthrough just deleted.
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

    /// Hosts the walkthrough's spotlight for `screen`. Renders only while the
    /// active step belongs to that screen.
    func tutorialOverlay(_ screen: TutorialScreen) -> some View {
        modifier(TutorialOverlayModifier(screen: screen))
    }

    /// Hosts the always-present progress / Skip / Next bar for `screen`. Apply
    /// AFTER `.tutorialOverlay(_:)` so the bar draws above the dim.
    func tutorialHUD(_ screen: TutorialScreen) -> some View {
        modifier(TutorialHUDModifier(screen: screen))
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

// MARK: - HUD

struct TutorialHUDModifier: ViewModifier {
    let screen: TutorialScreen
    private var tutorial: TutorialCoordinator { .shared }

    func body(content: Content) -> some View {
        content.safeAreaInset(edge: .bottom) {
            if tutorial.isActive && tutorial.step.screen == screen {
                TutorialHUD()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

/// The walkthrough's permanent chrome: where am I, how do I move on, how do I
/// get out. Deliberately independent of spotlight frames and TipKit popovers so
/// no missing frame or closed tip can ever strand the user.
struct TutorialHUD: View {
    private var tutorial: TutorialCoordinator { .shared }

    var body: some View {
        let step = tutorial.step
        let total = TutorialStep.allCases.count

        VStack(spacing: 10) {
            HStack(spacing: 10) {
                ProgressView(value: Double(step.number), total: Double(total))
                    .tint(.accentColor)
                    .accessibilityHidden(true)
                // Digits only — localised by the number formatter, so this
                // needs no entry in Localizable.strings.
                HStack(spacing: 2) {
                    Text(step.number, format: .number)
                    Text(verbatim: "/")
                    Text(total, format: .number)
                }
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            }

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
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 3)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
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

/// The dimming + spotlight + instruction for the current step, resolved into
/// the hosting screen's local coordinate space. Progress and the Skip / Next
/// buttons live in `TutorialHUD`, not here.
struct TutorialCoachmark: View {
    private var tutorial: TutorialCoordinator { .shared }
    @State private var captionHeight: CGFloat = 140

    var body: some View {
        let step = tutorial.step

        // The GeometryReader must ignore the safe area so that `proxy` spans the
        // full screen: target frames are reported in global (window) coordinates,
        // and `proxy.frame(in: .global).origin` then matches the same space the
        // holes and caption are positioned in. (If only the inner ZStack ignores
        // the safe area, the position space and the local-rect space diverge by
        // the top inset and every box ends up misplaced.)
        GeometryReader { proxy in
            let origin = proxy.frame(in: .global).origin
            let size = proxy.size
            let local = step.target.flatMap { resolvedRect(for: $0, origin: origin, size: size) }

            // The dim never intercepts touches (a tap-blocking scrim breaks text
            // field focus). The UI is locked instead by logically disabling every
            // non-target control.
            ZStack(alignment: .topLeading) {
                if step.isIntro {
                    // Page intro: a blocking dim + centred caption (no spotlight).
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture { }   // block interaction until Next
                    centredCaption(step: step, size: size)
                } else if let hole = local, let target = step.target {
                    let radius = cornerRadius(for: target, rect: hole)
                    dimWithCutout(hole, radius: radius)
                    spotlightRing(hole, radius: radius)
                    captionCard(message: step.message)
                        .frame(maxWidth: 360)
                        .padding(.horizontal, 20)
                        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { captionHeight = $0 }
                        .position(captionPosition(hole: hole, size: size, target: target))
                } else {
                    // The target's frame is unknown — it hasn't been laid out
                    // yet, or the user scrolled it out of the lazy grid. Never
                    // render nothing: without a caption the screen would be
                    // fully dimmed, fully disabled, and completely silent about
                    // what to do. Show the instruction centred and leave the
                    // dim non-blocking so the user can scroll the target back.
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                    centredCaption(step: step, size: size)
                }
            }
        }
        .ignoresSafeArea()
    }

    private func centredCaption(step: TutorialStep, size: CGSize) -> some View {
        captionCard(message: step.message)
            .frame(maxWidth: 360)
            .padding(.horizontal, 20)
            .position(x: size.width / 2, y: size.height * 0.4)
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
                case .editEllipsis, .addButton, .moreButton:
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
        case .moreButton:
            return CGRect(x: size.width - 54, y: 52, width: 40, height: 40)
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
        case .editEllipsis, .addButton, .moreButton:
            return rect.height / 2          // circular icon / capsule button
        case .recoverCard, .card:
            return 24                        // card
        }
    }

    /// Place the caption just outside the highlight (small gap), preferring the
    /// side with room. Cards get the caption above; nav-bar targets get it below.
    private func captionPosition(hole: CGRect, size: CGSize, target: TutorialTarget) -> CGPoint {
        let gap: CGFloat = 8
        let half = captionHeight / 2          // measured, so the gap is exact
        // Fixed side per target so the bubble never flips while frames jitter.
        let above: Bool
        switch target {
        case .editEllipsis, .card:
            above = true
        case .addButton, .moreButton, .recoverCard:
            above = false   // deleted card sits near the top; caption goes below
        }
        let y = above ? hole.minY - gap - half : hole.maxY + gap + half
        // Keep the whole bubble below the nav/stack toolbar, and clear of the
        // HUD pinned to the bottom.
        let topLimit: CGFloat = 104
        let bottomLimit: CGFloat = 132
        let clamped = min(max(y, topLimit + half), size.height - bottomLimit - half)
        return CGPoint(x: size.width / 2, y: max(clamped, topLimit + half))
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

    /// One short instruction, nothing else — NN/g's "short, focused tips": the
    /// controls live in the HUD so the bubble stays scannable.
    private func captionCard(message: LocalizedStringResource) -> some View {
        Text(message)
            .font(.subheadline)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
            .accessibilityElement(children: .combine)
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
