# Research brief: Cutling onboarding and What's New (ASG103, ASG105)

Read whole first: ~/.claude/session-states/cutling-onboarding-brief.md (the owner's words and the session's limits).

## Goal and why
Cutling is a paid-once iPhone/iPad snippet keyboard (custom keyboard extension, needs "Allow Full Access" for images and the clipboard) plus a Mac menu-bar picker. A buyer who does not get the keyboard added and working in the first minute asks for a refund or leaves one star. The owner wants the onboarding remade to be friendlier and smoother, and a What's New sheet for people who update or come back after a while. He shaped Cutling's keyboard to look exactly like Apple's own, so every screen should feel like something Apple would ship. This research decides the shape before any mock is drawn.

## Facts read from disk (2026-11-21)
- Current screens and their IDs: `docs/research/onboarding/screens.md`. Code: `Cutling/KeyboardSetupView.swift` (6 pages), `Cutling/TutorialOverlay.swift` (12 coach-mark steps, account in `docs/tutorial.md`), `Cutling/WhatsNewView.swift`.
- Buyer evidence (`~/Repositories/undirect/docs/research/cutling-voice-of-customer.md`): fear that a Full Access keyboard logs what you type is the 4th pain (11 mentions: A3 A14 M17 R13 R14 R33 R35 O2 C5 C6 C7); "setup feels complicated and people quit before the habit sticks" (R15 R18 R19).
- The owner's sibling app Undirect (`~/Repositories/undirect/App/WelcomeView.swift`, `SetupView.swift`, commit 2e788b4d) dropped a three-step tutorial for one sentence and one button, modelled on Apple's own extensions pane.
- The owner rejected, on the fill-in redesign today: designs drawn from memory, new-looking controls, spring/scale/fade animations. He wants what Apple ships.

## Limits
- Read-only in the owner's Chrome (Claude in Chrome): navigate, scroll, read, screenshot only. Open your own tab, never close one you did not open. Never sign in, buy, download an app, follow, post or accept anything. A page behind a login is written down as gated.
- Never fabricate a URL or an image. A source counts only when its bytes are saved in your folder. "GUESS" marks anything inferred, not seen.
- No simulator or Xcode runs (the device queue is shared); no edits outside your folder.

## Output
Write into your folder as each finding lands (a stopped agent leaves only what it wrote):
- `shots/NN-<product>-<what>.png` (open each with Read to confirm it shows the thing; delete junk), `pages/` for saved page text or JSON with URL and date on line 1, `code/` for source with a permalink header.
- `notes.md` with this exact table header and one row per saved reference:
  `| # | URL | file | screen | what it does | how Cutling's screen differs and what to take |`
  `screen` holds the IDs from screens.md (S01...W02). `file` names a file in your folder (relative path) or says `gated: <reason>`.
- `bun ~/.claude/skills/design-research/check-notes.ts <your folder>` must exit 0 before you report.
- Report in under 300 words: what you saved per screen ID, the 3-5 strongest patterns with their files, and what you could not get.
