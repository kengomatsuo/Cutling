# The Inserted mark on a cutling key

Status: design complete (2026-11-24). Sources, design, SwiftUI, build spec and three plan cards below. Mock: `keyboard-inserted-mark/mock.png`; values: `keyboard-inserted-mark/spec.json`.

## The job

A tap on a cutling key types its text into the host field. The key confirms that this happened, in motion that reads as Apple's. The owner: "I wanted the inserted text thing, i just asked you to make the animation more apple-like because last one's wasn't very apple-like." Earlier he named two directions he would accept: a keyboard-style pop-up showing what is being pasted, or a pasted / applied mark. He has chosen the applied mark ("the inserted text thing"). This document redesigns its look and motion only; the keyboard's cards, colours and layout stay as they are.

## What ships today (KeyboardViewController.swift, read 2026-11-24)

- `CutlingKeyView.overlay`: when `isCopied`, a `RoundedRectangle(cornerRadius: 10, style: .continuous).fill(.ultraThinMaterial)` covers the whole card, and a `Label("Inserted" | "Copied", systemImage: "checkmark")` in `.subheadline.weight(.semibold)` sits centred on it. The label's transition is `.scale(0.85)` plus opacity in, opacity out. The whole key carries `.animation(.spring(duration: 0.35, bounce: 0.2), value: isCopied)`.
- Two timers drive it. Typed text: `markApplied(_:)` sets `keyboardState.applied = id`, sleeps 1.2 s, then clears it with no animation transaction of its own (the view's implicit spring fades it). Image or styled copy: `showCopied(_:)` sets `copiedID` inside `withAnimation(.spring(duration: 0.35, bounce: 0.2))`, sleeps 1.2 s, clears inside `withAnimation(.easeOut(duration: 0.25))`.
- Press: `KeyboardButtonStyle` lays a flat highlight (black 12 % light, white 18 % dark) on touch down with animation disabled, plays a light impact haptic and the keyboard click (ids 1123/1155/1156).
- Card: 64 pt tall on iPhone, 80 pt on iPad, min width 140 / 180 pt, corner radius 10 continuous, fill `UIColor.keyBackground`.
- VoiceOver: nothing is announced when a cutling is typed (no `UIAccessibility.post` in the tap path; the only announcement is the fill-in field's).
- Reduce Motion: not read anywhere in the mark.

Why it reads as not Apple's (to be argued from sources below): the frosted sheet hides the card the person just tapped, so the thing confirmed vanishes; a static checkmark scales up as a block, which is a 2019 web-toast move rather than a symbol animation; two separate timers with different curves give the image and text marks different exits; and a second tap inside 1.2 s restarts nothing (the first task's `if applied == id` check clears the second mark early).

## Sources

Read 2026-11-24. "Apple says" means the quoted page says it; "GUESS" marks what I believe from using iOS but could not source.

### Apple, written

1. **HIG, Feedback** ([page](https://developer.apple.com/design/human-interface-guidelines/feedback), read as [.md](https://developer.apple.com/design/human-interface-guidelines/feedback.md)). "It often works well to display status information in a passive way so that people can view it when they need it." "When it makes sense, confirm that a significant action or task has completed ... reserve this type of confirmation for activities that are sufficiently important — because people typically expect their action or task to succeed." "When you provide feedback using color, text, sound, and haptics, people can receive it whether they silence their device, look away from the screen, or use VoiceOver." Use: the mark is passive and small; it must also be spoken.
2. **HIG, Motion** ([page](https://developer.apple.com/design/human-interface-guidelines/motion)). "Aim for brevity and precision in feedback animations." "In apps, generally avoid adding motion to UI interactions that occur frequently." "Let people cancel motion ... don't make people wait for an animation to complete." "Make motion optional ... avoid using it as the only way to communicate important information." "Consider using animated symbols where it makes sense." Use: one short beat, never blocks the next tap, a word carries the meaning, motion only decorates it.
3. **HIG, SF Symbols, Animations** ([page](https://developer.apple.com/design/human-interface-guidelines/sf-symbols#Animations), change log entry July 28, 2025 adds Draw). Bounce "plays once by default and can help communicate that an action occurred." Draw On "draws the symbol along a path through a set of guide points ... You might use the draw animation ... to reinforce the meaning of a symbol." "Apply symbol animations judiciously." Use: the key's own icon bounces once (an action occurred), and the checkmark draws on (reinforces "done").
4. **WWDC25 337, What's new in SF Symbols 7** ([video](https://developer.apple.com/videos/play/wwdc2025/337/)). Draw On and Draw Off "can be integrated into your experiences to help emphasize relevant moments"; Whole Symbol playback is for "a quicker more immediate effect". Use: `.drawOn.wholeSymbol` on a one-stroke `checkmark`.
5. **Symbols framework, `DrawOnSymbolEffect`** ([doc](https://developer.apple.com/documentation/symbols/drawonsymboleffect)): iOS 26.0+, conforms to `TransitionSymbolEffect`. **SwiftUI `SymbolEffectTransition`** ([doc](https://developer.apple.com/documentation/swiftui/symboleffecttransition)): iOS 17.0+, "applies the Appear, Disappear, DrawOn or DrawOff symbol animation to symbol images within the inserted or removed view hierarchy. Other views are unaffected." Use: the checkmark draws as part of the label's insertion, no timer of its own; iOS 18 to 25 falls back to `.appear`.
6. **SwiftUI `BlurReplaceTransition`** ([doc](https://developer.apple.com/documentation/swiftui/blurreplacetransition)): iOS 17.0+, "animates the insertion or removal of a view by combining blurring and scaling effects." This is the transition Apple built for one label replacing another in place. Use: preview line out, status line in, and back.
7. **WWDC23 10158, Animate with springs** ([video](https://developer.apple.com/videos/play/wwdc2023/10158/)). "When you're not sure, use a spring with bounce 0 ... Bounce can also make sense when you want an animation to feel more physical, like if it's going to be used at the end of a gesture." "Be cautious about using values higher than around 0.4." A retargeted spring "uses the velocity it had when it was retargeted ... this same velocity preservation makes these kind of interruptions feel smooth." Use: every spring in the mark is bounce 0 (`.smooth`); the only bounce is the symbol's own built-in Bounce effect.
8. **WWDC18 803, Designing Fluid Interfaces** ([video](https://developer.apple.com/videos/play/wwdc2018/803/)). "The button should highlight immediately when I touch down on it." "We recommend starting with 100% damping, or no overshoot." Music's Now Playing: a tap "doesn't have any momentum ... we use 100% damping", a swipe gets "80% damping to have a little bit of bounce." "Bounciness needs to be purposeful." Use: a tap has no momentum, so the current mark's `bounce: 0.2` scale-up of a label is exactly what Apple says not to do; that is the main reason it reads as not Apple's.
9. **WWDC23 10258, Animate symbols in your app** ([video](https://developer.apple.com/videos/play/wwdc2023/10258/)): the symbol effects API (`symbolEffect(_:value:)` for discrete effects such as Bounce). Use: replaying the cue on a second tap by bumping a counter.
10. **App Extension Programming Guide, Custom Keyboard** ([archive](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)): "it is not possible to display key artwork above the top edge of a custom keyboard's primary view, as the system keyboard does on iPhone." Use: the owner's first direction (a key pop-up showing what is pasted) cannot rise above the keyboard for the top row of cards, so it would have to sit inside the grid, over other cards. That is a second reason, besides his own choice, to keep the mark on the card.
11. **HIG, Playing haptics** ([page](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)): "Avoid overusing haptics ... become tiresome when it plays frequently." Use: no extra success haptic; the light tick the key already plays on touch-down stays the only one.

### Apple, observed (iOS 26/27, from use; not sourced)

- **AirDrop in the share sheet** (GUESS on exact colours): the person's avatar and name stay put; only the line under the name changes to "Sent". The thing acted on is never covered. This is the model for the design: keep the card, change its second line.
- **Control Center toggles, iOS 18 onward** (GUESS on timing): the module's symbol plays a symbol effect (bounce or replace) on tap, nothing else moves.
- **Settings search result**: the row you land on flashes its highlight and fades it out over about a second (GUESS on timing). Model for the faint tint wash that says which card fired.
- **The system keyboard**: a key highlights on touch-down with no animation, and there is no "typed" mark anywhere; the text appearing in the field is the confirmation. Already matched by `KeyboardButtonStyle` (see `docs/research/fill-ins-press-feedback.md`).

### Outside Apple

- **Mobbin, iOS "copied" confirmations** (searched 2026-11-24): most apps use a toast at the top or bottom ([Chime](https://mobbin.com/screens/0b8c4773-8e29-4267-a500-71252666d3e7), [Brex](https://mobbin.com/screens/c60f6ab7-060f-456b-b9c2-95f1f25d16a4), [Perplexity](https://mobbin.com/screens/c9f01808-09f5-4732-83d8-7b3f5970b246), [X](https://mobbin.com/screens/1d5b30c0-34b3-4846-857d-d07127ecc573)), which a 180 pt keyboard has no room for. [Phantom](https://mobbin.com/screens/4d9778ed-2ba4-48d6-be47-e52696a05d14) also swaps the row's copy icon for a checkmark in place, the stronger of its two signals. [NGL](https://mobbin.com/screens/721bde1a-fe17-44cd-ad18-d7be0ff58ea3) still uses the old iOS square HUD, which is what a full-card frosted sheet with a centred check resembles.
- **Motion's copy button** ([example](https://motion.dev/examples/react-copy-button)) and **Jakub Krehel, Animating icons** ([page](https://jakub.kr/components/animating-icons)): icon swap by opacity, scale and blur together, checkmark drawn by path length. The web's best copy confirmations converge on what Apple ships as `blurReplace` plus Draw On.
- **Emil Kowalski, 7 practical animation tips** ([page](https://emilkowal.ski/ui/7-practical-animation-tips)): add a small blur to a crossfade so the two states blend instead of ghosting. Same idea as `blurReplace`.

### What I drew from

AirDrop's "Sent" (keep the object, change its status line), SF Symbols 7 Draw On (the check writes itself), SF Symbols Bounce on the key's own icon (Apple's stated meaning: an action occurred), `blurReplace` for the line swap, and Fluid Interfaces' 100 % damping for anything a tap starts.

## Design

### The idea in one line

The card stays where it is. Its second line turns into "✓ Inserted" for 1.4 s, the checkmark draws itself in the cutling's colour, the cutling's own icon bounces once, and the card picks up a faint wash of that colour. Then the line turns back. This is AirDrop's "Sent" (the object stays; its status line speaks), not a HUD laid over the object.

Why each part:

| Part | What it says | Apple source |
|---|---|---|
| Card stays visible | "this one" (you can still read which cutling went in) | AirDrop "Sent"; HIG Feedback, passive status |
| Second line becomes "✓ Inserted" | "your text went in" in words, so it works with motion off and the sound off | HIG Motion, "make motion optional"; HIG Feedback, several channels |
| Line swap is `blurReplace` | one label replacing another in place | SwiftUI `BlurReplaceTransition` |
| Checkmark draws on | "done", written rather than stamped | SF Symbols 7 Draw On; HIG SF Symbols, Draw "reinforce the meaning of a symbol" |
| Icon bounces once | "an action occurred" | HIG SF Symbols, Bounce |
| Faint tint wash | which key fired, readable from the corner of the eye while looking at the field | Settings search landing flash (observed) |
| Every spring bounce 0 | a tap has no momentum to reward | WWDC18 803; WWDC23 10158 |
| No added haptic or sound | the touch-down tick already played | HIG Playing haptics, "avoid overusing" |

What leaves: the full-card `.ultraThinMaterial`, the centred label, its 0.85 scale-in with `bounce: 0.2`, the whole-key `.animation(.spring(duration: 0.35, bounce: 0.2), value: isCopied)`, and the two separate timers.

### The drawing

`docs/research/keyboard-inserted-mark/mock.png` (drawn by `mock.mjs` from `spec.json`). Artboards:

- **A1** phone light, text card, eight frames at t = 0, 0.08, 0.15, 0.30, 0.80, 1.50, 1.60, 1.90 s.
- **A2** phone dark, same frames.
- **A3** phone light, image card ("Copied" replaces the name on the thumbnail).
- **A4** phone light, Reduce Motion (opacity only, check already whole, no bounce).
- **B1 / B2** iPad light and dark, text card.
- **Grid** phone at t = 0.8 s: "today" (the frosted sheet hiding Home Address), "new" light, "new" dark. The comparison is the argument: today the tapped card is the one card you cannot read.
- **C1** timeline: each element's progress curve from the spec.

The blur radius, scale and draw progress in the mock stand in for the system's `blurReplace`, Draw On and Bounce; the builder uses the system effects and does not copy those numbers (spec `mock.notes`).

### Where things sit

Text card (phone / iPad, from `KeyStyle`, unchanged): 64 / 80 pt tall, radius 10 continuous, padding 10 / 12. Row 1 is icon (13 / 16 pt, tint) and name (14 / 17 pt semibold), unchanged. The status line takes the preview's place, top-left of the same slot, 4 pt under row 1:

- `checkmark`, `.system(size: bodySize, weight: .semibold)` (12 / 15 pt), `cutling.tintColor`.
- 3 / 4 pt gap.
- "Inserted", `.system(size: bodySize, weight: .semibold)`, `.primary`, one line, `minimumScaleFactor(0.8)`.

The word is `.primary`, not the tint, because a cutling can carry any hex colour; only the symbol takes the tint, exactly as the icon above it already does. Because the card's content is `.topLeading` in a fixed height and the slot is a `ZStack(alignment: .topLeading)`, losing a two-line preview for a one-line status moves nothing: row 1 never shifts and neighbours never resize.

Wash: `cutling.tintColor` at 0.08 opacity in light, 0.12 in dark, a full-card fill above `KeyStyle.keyColor` and below the content, inside the existing clip. Text cards only.

Image card: "✓ Copied" replaces the name in the same place and style as the name (white, `titleSize - 2` semibold, black 0.4 shadow r2 y1, on the existing gradient); the checkmark is white. No wash (it would muddy the photo). A Formatted cutling's long-press Copy uses the text-card layout with "Copied".

### Timing (t = 0 is the Button action, when the text is inserted)

| Element | Start | Duration | Curve / effect |
|---|---|---|---|
| Preview line leaves | 0 | 0.15 | `blurReplace(.upUp)`, `.smooth(duration: 0.15)` |
| Status line arrives | 0.05 | 0.3 | `blurReplace(.upUp)`, `.smooth(duration: 0.3).delay(0.05)` |
| Checkmark draws on | 0.05 | system (about 0.4) | `.symbolEffect(.drawOn.wholeSymbol)` transition, iOS 26+; `.appear` on iOS 18 to 25 |
| Icon bounces | 0 | system (about 0.35) | `.symbolEffect(.bounce, value:)` |
| Wash in | 0 | 0.2 | `.smooth(duration: 0.2)` |
| Hold | | until 1.4 | |
| Status line leaves | 1.4 | 0.15 | `blurReplace(.upUp)`, `.smooth(duration: 0.15)` |
| Preview returns | 1.45 | 0.3 | `blurReplace(.upUp)`, `.smooth(duration: 0.3).delay(0.05)` |
| Wash out | 1.4 | 0.5 | `.smooth(duration: 0.5)` |
| Settled | 1.9 | | |

The 0.05 s stagger is drawn at t = 0.08 and 1.50 s: the outgoing line is nearly gone before the incoming one shows, so a two-line preview never sits under the status (the first draw, with both at 0.3 s together, ghosted badly). `.smooth` is `spring(duration:, bounce: 0)`: nothing in the mark overshoots; the only overshoot is inside Apple's own Bounce effect.

### A second tap while the mark shows

- **Same key, during the hold**: the text is typed again; the status line stays put (no blur out and back), the checkmark and the icon each bounce once, and the hold restarts from this tap. Driven by a serial that rises on every insert.
- **Same key, while the line is leaving (1.4 to 1.55 s)**: a fresh status line enters normally while the old one finishes leaving; the wash turns back up from wherever it was.
- **Another key**: the first key's mark leaves at once with its exit; the new key's mark enters at the same instant. One key carries the mark at a time.
- **Keyboard hidden**: `viewWillDisappear` cancels the hold and clears the mark.

Today's code has a bug here that the serial fixes: `markApplied` sleeps 1.2 s and clears when `applied == id`, so a second tap on the same key at 1.0 s is cleared 0.2 s later by the first tap's timer.

### Reduce Motion

The line swap becomes a plain opacity crossfade (out `.easeInOut(duration: 0.15)`, in `.easeInOut(duration: 0.2).delay(0.05)`), the checkmark arrives whole with the line, the icon does not bounce, and on a repeat the checkmark does not bounce. The wash keeps its opacity fade (not motion). Hold stays 1.4 s. Drawn in A4.

### VoiceOver

Once per insert, after `insertText` returns: an announcement "Inserted Home Address" (or "Copied Boarding pass"), the cutling's **name**, never its text, since a cutling may be a password. Posted as an `NSAttributedString` with `.accessibilitySpeechQueueAnnouncement: true` so it waits behind any echo of the typed text instead of cutting it off. The status line itself is `accessibilityHidden(true)`. New string keys "Inserted %@" and "Copied %@" are composed in each locale (blind-translation), not translated word for word.

### Light and dark

| Token | Light | Dark |
|---|---|---|
| Status word | `.primary` (black) | `.primary` (white) |
| Checkmark | `cutling.tintColor` | `cutling.tintColor` |
| Wash | tint at 0.08 | tint at 0.12 |
| Image status | white on the existing black 0.35 gradient | same |

### The SwiftUI

State, in `KeyboardState` (replaces `applied: UUID?`, `copiedID`, `copiedStyledID`, `showCopied(_:)` and the body of `markApplied(_:)`):

```swift
enum AppliedWord: Equatable { case inserted, copied }

struct AppliedMark: Equatable {
    let id: UUID
    let word: AppliedWord
    let serial: Int
}

// In KeyboardState
@Published private(set) var applied: AppliedMark?
private var serial = 0
private var hold: Task<Void, Never>?
static let markHold: Duration = .seconds(1.4)

/// Marks the key whose text was just typed (or copied) for a moment, and says so to VoiceOver.
@MainActor
func mark(_ id: UUID, _ word: AppliedWord, name: String) {
    serial += 1
    let mine = serial
    applied = AppliedMark(id: id, word: word, serial: mine)
    let format = word == .inserted ? String(localized: "Inserted \(name)") : String(localized: "Copied \(name)")
    UIAccessibility.post(notification: .announcement,
                         argument: NSAttributedString(string: format, attributes: [.accessibilitySpeechQueueAnnouncement: true]))
    hold?.cancel()
    hold = Task { @MainActor [weak self] in
        try? await Task.sleep(for: Self.markHold)
        guard let self, !Task.isCancelled, self.applied?.serial == mine else { return }
        self.applied = nil
    }
}

@MainActor
func clearMark() {
    hold?.cancel()
    applied = nil
}
```

Motion constants, one place:

```swift
enum MarkMotion {
    static let lineIn: Animation = .smooth(duration: 0.3).delay(0.05)
    static let lineOut: Animation = .smooth(duration: 0.15)
    static let fadeIn: Animation = .easeInOut(duration: 0.2).delay(0.05)
    static let fadeOut: Animation = .easeInOut(duration: 0.15)
    static let washIn: Animation = .smooth(duration: 0.2)
    static let washOut: Animation = .smooth(duration: 0.5)
    static let washLight = 0.08
    static let washDark = 0.12

    /// The status line: blurs in while its checkmark draws on; blurs out.
    static func status(reduceMotion: Bool) -> AnyTransition {
        if reduceMotion {
            return .asymmetric(insertion: .opacity.animation(fadeIn), removal: .opacity.animation(fadeOut))
        }
        let draw: AnyTransition
        if #available(iOS 26.0, *) {
            draw = AnyTransition(.symbolEffect(.drawOn.wholeSymbol))
        } else {
            draw = AnyTransition(.symbolEffect(.appear))
        }
        return .asymmetric(insertion: AnyTransition(.blurReplace(.upUp)).combined(with: draw).animation(lineIn),
                           removal: AnyTransition(.blurReplace(.upUp)).animation(lineOut))
    }

    /// The line the status replaces (preview text, or an image card's name): leaves fast, returns softly.
    static func line(reduceMotion: Bool) -> AnyTransition {
        if reduceMotion {
            return .asymmetric(insertion: .opacity.animation(fadeIn), removal: .opacity.animation(fadeOut))
        }
        return .asymmetric(insertion: AnyTransition(.blurReplace(.upUp)).animation(lineIn),
                           removal: AnyTransition(.blurReplace(.upUp)).animation(lineOut))
    }
}
```

The status line:

```swift
struct AppliedLine: View {
    let word: AppliedWord
    let serial: Int
    let symbolColor: Color
    let textColor: Color
    let size: CGFloat
    let spacing: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var repeats = 0

    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: "checkmark")
                .foregroundStyle(symbolColor)
                .symbolEffect(.bounce, options: .nonRepeating, value: repeats)
            Text(word == .inserted ? "Inserted" : "Copied", bundle: snapshotBundle)
                .foregroundStyle(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .font(.system(size: size, weight: .semibold))
        .onChange(of: serial) { if !reduceMotion { repeats += 1 } }
        .accessibilityHidden(true)
    }
}
```

In `CutlingKeyView` (new inputs `mark: AppliedMark?` replacing `isCopied` and `copiedStyled`; the Button-wide `.animation(..., value: isCopied)` and the whole `if isCopied { ... }` overlay are deleted):

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
@Environment(\.colorScheme) private var colorScheme
@State private var bounces = 0

// In body, between the content and the key fill:
.background {
    if cutling.kind == .text {
        Rectangle()
            .fill(cutling.tintColor)
            .opacity(mark == nil ? 0 : (colorScheme == .dark ? MarkMotion.washDark : MarkMotion.washLight))
            .animation(mark == nil ? MarkMotion.washOut : MarkMotion.washIn, value: mark == nil)
    }
}
.background(KeyStyle.keyColor, in: RoundedRectangle(cornerRadius: KeyStyle.cornerRadius, style: .continuous))
// …existing contentShape, clipShape, isExisted overlay…
.onChange(of: mark?.serial) { _, new in
    if new != nil, !reduceMotion { bounces += 1 }
}

private var textContent: some View {
    VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 4) {
            Image(systemName: cutling.icon)
                .font(.system(size: KeyStyle.iconSize(for: horizontalSizeClass)))
                .foregroundStyle(cutling.tintColor)
                .symbolEffect(.bounce, options: .nonRepeating, value: bounces)
            Text(cutling.name)
                .font(.system(size: KeyStyle.titleSize(for: horizontalSizeClass), weight: .semibold))
                .lineLimit(1)
        }
        ZStack(alignment: .topLeading) {
            if let mark {
                AppliedLine(word: mark.word, serial: mark.serial,
                            symbolColor: cutling.tintColor, textColor: .primary,
                            size: KeyStyle.bodySize(for: horizontalSizeClass),
                            spacing: KeyStyle.statusSpacing(for: horizontalSizeClass))
                    .transition(MarkMotion.status(reduceMotion: reduceMotion))
            } else {
                cutling.displayText(pillSize: KeyStyle.bodySize(for: horizontalSizeClass))
                    .font(.system(size: KeyStyle.bodySize(for: horizontalSizeClass)))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .allowsHitTesting(false)
                    .transition(MarkMotion.line(reduceMotion: reduceMotion))
            }
        }
    }
    .padding(KeyStyle.cardPadding(for: horizontalSizeClass))
}

// KeyStyle
static func statusSpacing(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
    sizeClass == .regular ? 4 : 3
}
```

Image card: the same `if let mark { AppliedLine(... symbolColor: .white, textColor: .white, size: KeyStyle.titleSize(for:) - 2 ...) } else { Text(cutling.name) … }` swap inside the existing bottom band, with the band's existing shadow applied to both branches.

Call sites: `markApplied(id)` in the view controller becomes `keyboardState.mark(id, .inserted, name: cutling.name)` (look the name up in `store.cutlings`); the image tap and the Formatted long-press Copy call `state.mark(cutling.id, .copied, name: cutling.name)`; `viewWillDisappear` calls `keyboardState.clearMark()`. The grid passes `mark: state.applied?.id == cutling.id ? state.applied : nil`.

Builder checks I could not settle from documentation (each one is a device measurement, not a design choice): the system duration of `drawOn.wholeSymbol` on `checkmark` and of `.bounce`; that an `AnyTransition` built from `.symbolEffect(.drawOn)` draws the symbol when combined with `blurReplace` (if it does not, the fallback is the same `AppliedLine` with `@State drawn` and `.symbolEffect(.drawOn.wholeSymbol, isActive: !drawn)` set in `onAppear`); and that the attached transition animations run without an enclosing `withAnimation` (the state is set from the view controller, outside any transaction).

## Build spec

Folder `docs/research/keyboard-inserted-mark/`:

- `spec.json`: every value the mark shows. Per breakpoint (phone, iPad): card height, padding, radius, icon, title, body and status sizes, spacings. Per mode (light, dark): colours and wash opacity. The timeline (start, duration and curve of all eight elements, hold 1.4, end 1.9). Repeat rules, Reduce Motion, VoiceOver, copy keys. The values the mock uses only as stand-ins for system effects are kept apart under `mock`.
- `mock.mjs`: draws `mock.html` and `mock.png` from `spec.json` alone (`node mock.mjs`).
- `check.mjs`: prints any number in `mock.mjs` or in this document's Swift blocks that `spec.json` lacks, and exits 1 if there is one (`node check.mjs`). Output of the last run, after the final edit:

```
spec numbers: 86; swift blocks scanned: 4
every number in mock.mjs and the doc's Swift is in spec.json
```

When spec and prose disagree, `spec.json` wins.

## Plan cards

Three cards, in order. Each one changes `CutlingKeyboard/KeyboardViewController.swift` only, and the string catalogue for card 1.

### Card 1: One applied mark, with a serial, a cancellable hold and a spoken announcement

Replace `KeyboardState.applied: UUID?`, `KeyboardView.copiedID`, `copiedStyledID`, `showCopied(_:)` and the body of `markApplied(_:)` with `AppliedMark`, `KeyboardState.mark(_:_:name:)` and `clearMark()` exactly as in "The SwiftUI". The hold's rule (clear only when the serial still matches) lives in one method, `expire(serial:)`, which the hold task calls after `markHold`, so tests drive the rule without sleeping.

Contexts: phone and iPad, portrait and landscape: n/a to the state itself (no layout); the card renders it (card 2). Language: the new "Inserted %@" and "Copied %@" keys exist in every shipped locale, composed per locale. Full Access off: an image tap shows the no-access toast and calls no `mark` (unchanged refusal). An ASCII-only field: a blocked card is disabled and never marks. A cutling with fill-ins marks once, after `finish`, never when the panel opens. VoiceOver on and off. Reduce Motion: n/a here (card 2). Data with no cutlings: no tap, no mark. Old client: n/a: in-memory state, nothing stored.
Neighbours: exits: the hold expiring clears it; a newer mark replaces it; `viewWillDisappear` clears it and cancels the hold. Two keys: the newer key wins, the older clears in the same update. Same key twice: serial rises, the hold restarts, one announcement per insert. Ownership, replay of a stored row, locks, transactions: n/a: no stored write. Time: the clock that ends the mark sets state only; the transition's own end removes the view, so no second clock can drift from it.

Acceptance:
1. After `mark(A, .inserted, name: "Home Address")`, `applied == AppliedMark(id: A, word: .inserted, serial: n)` where n is one more than the previous serial.
2. `expire(serial: n)` clears `applied` when its serial is n and leaves it alone when it is not.
3. `mark(A, …)` then `mark(A, …)`: the serial rises by one each time; the first mark's expiry leaves the second in place.
4. `mark(A, …)` then `mark(B, …)`: `applied.id == B`.
5. `clearMark()` sets `applied` to nil, and a later expiry of the cancelled hold changes nothing.
6. One announcement per `mark`, text "Inserted Home Address" (or "Copied Boarding pass"), an `NSAttributedString` with `.accessibilitySpeechQueueAnnouncement == true`; it never contains the cutling's text (checked with a cutling whose name and text differ).
7. Typing a text cutling calls `mark(_, .inserted, _)`; an image tap and a Formatted long-press Copy call `mark(_, .copied, _)`; a fill-in cutling calls it once, at `finish`.
8. Nothing else reads `copiedID`, `copiedStyledID` or `showCopied` after the change (grep is empty).
9. Unit tests pass with no `Task.sleep` and no waits; one UI test (card 2) measures the real hold.

Mock: none (state only). Proof: the unit tests above, failing first with the old `markApplied`/`showCopied` in place (acceptance 3 fails on today's code).

### Card 2: Text card status line, checkmark, icon bounce and wash

Rebuild `CutlingKeyView` per "The SwiftUI": the `if isCopied` overlay with `.ultraThinMaterial`, its label and the Button-wide `.animation(.spring(duration: 0.35, bounce: 0.2), value: isCopied)` are deleted; the preview slot becomes the `ZStack` swap; the wash background and the icon bounce are added; `MarkMotion`, `AppliedLine` and `KeyStyle.statusSpacing(for:)` are new.

Contexts: phone portrait (card 64 pt) and landscape (64 pt card, 120 pt grid), iPad portrait and landscape (80 pt); light and dark; Reduce Motion on and off; iOS 26 and later (Draw On) and iOS 18 to 25 (Appear; checked on an iOS 18 simulator); a preview of one line and of two; a long name (row 1 unchanged); a user hex tint near white and near black (the word stays `.primary`, readable on both); the longest "Inserted" across shipped locales fits in the narrowest card (140 pt minus 20 pt padding minus the check and gap) at `minimumScaleFactor(0.8)` or above; the "Suggestions" section's copy of a cutling and its copy in the main list both show the mark (both are the same id); a card scrolled off and back during the hold shows the mark without replaying the entry. Text fields: n/a: the mark draws no text field; the host app's field sits above the keyboard on iPhone and iPad and nothing in it moves.
Neighbours: n/a: draws state from card 1, writes nothing. The `isExisted` green glow and `KeyboardButtonStyle`'s touch-down highlight are unchanged and still show (the highlight with no animation).

Acceptance:
1. With a mark on a text card, the card shows its icon, its name, and in the preview's place a `checkmark` and "Inserted"; the preview text is not visible; no material layer exists in the view tree.
2. Without a mark, the card is pixel-identical to today's card (screenshot diff against a baseline taken before the change, same cutling, same mode).
3. Row 1 (icon and name) does not move between any two frames of the mark (measured y of the name's frame is constant across a screen recording).
4. The status line's top equals the preview's top: padding + title row + 4 pt.
5. The word renders in the label colour (black in light, white in dark); the checkmark in the cutling's tint.
6. Wash: the card's fill, sampled in a corner where no text can sit, moves from the key colour towards the tint by 0.08 (light) or 0.12 (dark) of the way, within ±0.01.
7. Timing, from a 60 fps screen recording, t = 0 at the first frame with the text in the field: the preview is gone by 0.2 s, the status line is settled by 0.4 s, the status line starts leaving at 1.4 s (±1 frame), the preview is settled by 1.8 s, the wash is gone by 1.95 s.
8. A second tap on the same key at 1.0 s: the status line does not leave and re-enter; the checkmark and the icon bounce once; the line starts leaving at 2.4 s.
9. A tap on another key during the hold: the first card starts its exit on the same frame the second card starts its entry.
10. Reduce Motion on: no frame shows blur or a scale other than 1 on the line, the checkmark is whole on its first visible frame, the icon does not bounce; the hold is unchanged.
11. VoiceOver on: the status line is not an accessibility element; the key's label while marked is the cutling's name.
12. Nothing in the mark overshoots: the line's opacity and the wash never exceed their resting values in any frame.

Mock: `docs/research/keyboard-inserted-mark/mock.png`, artboards A1, A2, A4, B1, B2 and the two "new" grids. Proof: the builder's phone (iPhone 18 Pro Max simulator, iOS 27.2) and tablet (iPad Air 13-inch M4 simulator, iOS 27.2) screenshots at t = 0.8 s, light and dark, compared side by side with A1, A2, B1, B2 and the grids, plus the frames at 0.08, 0.15, 0.30, 1.50 and 1.60 s pulled from the recording, plus this table filled with measured values:

| Value | Mock (spec.json) phone / iPad | Built, measured |
|---|---|---|
| Card height | 64 / 80 pt | |
| Corner radius | 10 pt continuous | |
| Card padding | 10 / 12 pt | |
| Row 1 to status gap | 4 pt | |
| Checkmark size, weight | 12 / 15 pt, semibold | |
| Check to word gap | 3 / 4 pt | |
| Word size, weight | 12 / 15 pt, semibold | |
| Word colour light / dark | #000000 / #FFFFFF (`.primary`) | |
| Checkmark colour | cutling tint | |
| Wash light / dark | tint at 0.08 / 0.12 | |
| Surface | key fill, no material | |
| Preview out | 0 to 0.15 s | |
| Status in | 0.05 to 0.35 s | |
| Hold ends | 1.4 s | |
| Preview back | 1.45 to 1.75 s | |
| Wash out | 1.4 to 1.9 s | |
| Draw On, Bounce durations | system (mock 0.4, 0.35) | |

### Card 3: Image card and Formatted copy show "Copied" the same way

Image card: the name in the bottom band swaps to "✓ Copied" in white with the same transitions; no wash. Formatted long-press Copy: the text-card layout from card 2 with "Copied".

Contexts: phone and iPad, light and dark (the band is the same in both); Full Access off (no mark, the toast shows); an image with no thumbnail (placeholder fill, the band still reads); Reduce Motion; a long name truncated today stays truncated when it returns. Text fields: n/a: no text field drawn.
Neighbours: n/a: draws state from card 1, writes nothing.

Acceptance:
1. With a `.copied` mark on an image card, the band shows a white `checkmark` and "Copied" at the name's position, size and shadow; the name is not visible; the thumbnail has no wash and no material.
2. Timing as card 2, items 7 to 9; Reduce Motion as card 2, item 10.
3. A Formatted cutling's long-press Copy shows "Copied" in the text-card layout; a plain tap on the same card shows "Inserted".
4. Without a mark, the image card is pixel-identical to today's.

Mock: `mock.png` artboard A3. Proof: phone and tablet screenshots at t = 0.8 s against A3, and the card 2 table rows for size, position and timing filled for the image card.
