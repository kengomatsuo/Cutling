# The interactive tutorial (iOS)

`Cutling/TutorialOverlay.swift` drives a 12-step, learn-by-doing walkthrough of
the four core flows — create, edit, delete, recover — across three screens. The
user performs the real actions; each step advances only when the app observes
the action happen.

Per Apple's HIG (*Onboarding*): "Teach through interactivity" and "If it makes
sense to offer a separate tutorial, consider making it optional." Per NN/g's
*Instructional Overlays and Coach Marks*: keep tips short and focused, one
interaction at a time.

## Three pieces, deliberately separate

| Piece | Where | Carries |
|---|---|---|
| `TutorialHUD` | bottom of **every** participating screen, via `.tutorialHUD(_:)` | progress (`n / 12`), **Skip Tutorial**, Next/Done |
| `TutorialCoachmark` | grid + Recently Deleted, via `.tutorialOverlay(_:)` | dim, spotlight ring, one-line instruction |
| TipKit popovers | the editor (`IOSTips.swift`) | the instruction, anchored to the field/button |

The HUD depends on nothing but the current step. That is the whole point: it
is reachable when a spotlight target can't be located, when a TipKit popover
was closed, and on the editor steps that host no coach-mark at all. It is the
walkthrough's guaranteed escape hatch.

Apply `.tutorialHUD(_:)` **after** `.tutorialOverlay(_:)` so the bar draws above
the dim.

## Steps

`createIntro → createAdd → createName → createSave → createdCelebrate →
editOpen → editSave → deleteOpen → deleteConfirm → recoverIntro → recoverTap →
recoveredCelebrate`

`TutorialStep.screen` decides which host renders. The four editor steps
(`createName`, `createSave`, `editSave`, `deleteConfirm`) get the HUD plus a
TipKit popover, no coach-mark.

## Rules that exist because breaking them caused bugs

- **Never move a TipKit anchor while a field is focused.** Presenting a popover
  resigns first responder. The old build moved the anchor on a 2s idle timer,
  so a user pausing mid-word had the rest of their typing swallowed and got
  bumped to the next step. Anchors now move only on step transitions and on
  focus loss (`editorFocusChanged`); typing only updates `nameFieldFilled`.
- **The coach-mark must always render its caption.** When a spotlight target's
  frame can't be resolved — card not yet laid out, or scrolled out of the lazy
  grid — the overlay falls back to a centred caption. Rendering nothing left a
  fully dimmed screen with every control disabled and no way out.
- **`hasSeenInteractiveTutorial` is set when the walkthrough STARTS**, not when
  it ends, so a force-quit part-way through doesn't replay it (and create
  another cutling) on every launch. The contextual TipKit hints gated on that
  flag also test `!TutorialCoordinator.shared.isActive`, so they stay quiet
  until it's genuinely over — see `syncTipSetupParameters` in `CutlingApp.swift`.
- **Search stays shut for the duration** (`allowsSearch`). Filtering the grid
  can hide the very card the spotlight is pointing at. `.searchable` has no
  `disabled`, so `MainContentView` force-closes it.
- **`Tip.resetEligibility()` is iOS 26+.** Below that, a tip the user closes
  stays closed for good — which is exactly why the HUD, not the tip, carries
  the controls.

## Locking

A scrim can't cover the navigation bar and can't reliably swallow long-presses,
so the walkthrough logically disables every control except the current step's
target (`allowsAddButton`, `allowsMoreButton`, `allowsUnrelatedControls`,
`cardMode(isTarget:)`, `recoverRowEnabled(isFirst:)`). Newly deleted items are
inserted at index 0, so the spotlighted first row in Recently Deleted is always
the one just deleted.

## Backing out

- Create sheet: Cancel routes through a "Leave Tutorial?" alert
  (`tutorialGuardsDismiss`); swipe-dismiss stays off so Cancel is the single
  deliberate exit.
- Pushed editor on `deleteConfirm`: a custom Back (`tutorialInterceptsBack`)
  resets the flow to `deleteOpen` rather than stranding it.
- Recently Deleted: a custom Back routes through the same alert.
- Everywhere: **Skip Tutorial** in the HUD.

## Replay

Auto-launches once for anyone who hasn't seen it, and is replayable from "How
to Use Cutling" in the keyboard manager's About section. Auto-start is skipped
when the store is already at the text-cutling limit, since the first step could
never complete.
