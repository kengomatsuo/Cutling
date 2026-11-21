# Cutling onboarding and What's New: what the research found (ASG103, ASG105)

Collected 2026-11-21 into four folders, each with a `notes.md` whose rows name a saved file:
`competitors/` (rival keyboard apps: code, help pages, frames from setup recordings),
`apple/` (Apple's rules, strings, docs, and Apple's own iOS 27 sheets shot on the simulator in `apple/shots/sim/`),
`whats-new/` (welcome and What's New sheets), and `cutling-today/` (Cutling's own first run, shot from a fresh
install by `CutlingUITests/OnboardingCaptureUITests.swift`). Screen IDs are in `screens.md`. GUESS marks inference.

## Cutling today, measured

From `cutling-today/01..15`: welcome, enable (three numbered lines and Open Cutling Settings), Settings,
back, test page (field and two status rows), What You Can Do (Continue stays off until scrolled to the
bottom), iCloud toggle page, You're All Set, then a 12-step coach-mark tutorial. About 18 taps from first
launch to the grid, before the tutorial. Defects seen in the shots:

- Continue on the test and done pages waits for Full Access (`KeyboardSetupView.lastAllowedPage`). App Review
  4.4.1 says a keyboard must work without requiring Full Access (`apple/pages/app-review-guidelines-4.4.txt`),
  and Apple's own docs say a keyboard without it can still read the app's shared container
  (`apple/pages/dev-configuring-open-access-for-a-custom-keyboard.txt`), so text cutlings work with it off.
  Only images, Add from Clipboard and formatted copy need it.
- A fresh install has no cutlings, so the test page's Cutling keyboard shows "No Cutlings Yet"
  (`cutling-today/15_tutorial_step_3.png` shows the same empty keyboard inside the editor).
- The What's New sheet still lists the 1.5 features and its last row runs under the Continue button
  (`cutling-today/01_whatsnew_light.png`); it shows only to people crossing 1.5, so nobody sees it now.
- US English strings say "Whilst" (`cutling-today/09_setup_what_you_can_do_top.png`).

## Rivals, from recordings (`competitors/notes.md`, "Setup flows from recordings")

| Product | Taps to a working keyboard | Move worth copying | File |
|---|---|---|---|
| Gboard | about 13 | the Full Access reason on the first screen; the keyboard strip asks for Full Access when a feature needs it | `competitors/shots/v-gboard-welcome-step1of2-0030.png`, `v-gboard-keyboard-needs-fullaccess-0114.png` |
| Grammarly | about 16 (7 before the keyboard) | "Step 2 of 3": a picture of Apple's own Settings row, one deep-link button, a "What's Full Access?" link; step 3 is an instruction above the real keyboard and a field | `v-grammarly-setup-step2of3-add-keyboard-0056.png`, `v-grammarly-step3of3-switch-test-0120.png` |
| Wispr Flow | 16 or more | "Set up your Flow Keyboard in Settings" draws the Settings rows it wants touched; a checklist follows the buyer into Settings | `v-wispr-setup-in-settings-go-to-settings-0031.png`, `v-wispr-settings-fullaccess-alert-checklist-overlay-0037.png` |
| SwiftKey | about 12 | nothing: the app teaches no setup, Apple's screens do it all | `v-swiftkey-add-new-keyboard-0101.png` |
| TypeWhisper | about 8 | setup is a row in the app's own settings ("Keyboard not enabled"), with a "Not showing up?" page | `v-typewhisper-app-settings-keyboard-not-enabled-0016.png` |
| Dictus (code) | n/a | a Settings checklist in a Picture in Picture window over Settings; Full Access explained in an optional sheet after testers refused at Apple's alert | `apple/code/dictus-SettingsChecklistPictureCard.swift`, `apple/pages/gh-dictus-issue704.txt` |
| ClipKeyboard (code) | n/a | notices the keyboard on return from Settings and moves on; sample cutlings the tutorial points at and keeps | `competitors/code/clipkeyboard-KeyboardSetupOnboardingView.swift`, `clipkeyboard-TutorialFlow.swift` |
| hex (code) | n/a | the test step completes itself when the keyboard types into the field; "Finish setup, N steps" stays on Home | `competitors/code/hex-ios-Onboarding.swift` |

## Apple's own sheets on iOS 27 (`apple/shots/sim/`)

- What's New in Calendar (`apple_calendar.png`): large bold title left-aligned, a grey one-line subtitle,
  one row (app-coloured symbol, bold title, grey line), one full-width capsule Continue in the app's tint.
  Apple ships a What's New sheet with a single row when that is all that changed.
- Welcome to Reminders (`apple_reminders.png`): the same layout with four rows and multicolour symbols.
- Passwords (`apple_passwords_2.png`): a one-screen explanation before a system ask, one Continue.
- Reminders' own route to Settings (`apple_reminders_2.png`): an alert "Enable iCloud Syncing?" with Not Now and Go to Settings.
- Journal's welcome from Apple's guide (`whats-new/shots/02-apple-journal-welcome.png`): app icon above,
  "Welcome to" tinted over "Journal", three one-sentence rows, one capsule Continue.
- Games shows its welcome as a card on Home with one View button, not a sheet (`whats-new/shots/v-apple-games-welcome-card-0038.png`).
- No recording or guide shows any app's What's New sheet after an update beyond Calendar's; Duolingo
  counts someone as returning after 30 days away (`whats-new/pages/duolingo-back-from-the-brink.txt`);
  Discourse greets a long-absent user once with "Welcome back!" and stores the time so it never repeats
  (`whats-new/pages/discourse-welcome-back-inactive.txt`).

## Apple's rules (quoted in `apple/notes.md`)

- Onboarding is fast, fun and optional; teach by doing; postpone setup that is not essential; a skipped
  tutorial never returns and stays findable (`apple/pages/hig-onboarding.json`).
- A screen before a system alert has one button, Continue or Next, never Allow (`apple/pages/hig-privacy.json`).
- Apple asks keyboard apps to teach choosing, activating, using and switching back, outside the keyboard
  (`apple/pages/hig-virtual-keyboards.json`). Apple's guide says "touch and hold" the globe key (`apple/pages/support-add-keyboards.txt`).
- The Full Access alert is Apple's, shown for every keyboard: "Allow Full Access for “Cutling” Keyboards?",
  saying the developer could send anything you type (`apple/pages/ios-strings-KeyboardSettings.framework.md`).
  This is the fear buyers name (11 mentions in `undirect/docs/research/cutling-voice-of-customer.md`).
- NN/g: tutorials and What's New lists at launch are push revelations people forget; keep them short and
  dismissable (`apple/pages/nng-onboarding-tutorials.txt`).

## Patterns taken

1. Full Access becomes optional in setup: add the keyboard, try it, done; Full Access is offered with its
   reason (images, Add from Clipboard) and a "Why Full Access?" sheet, never a gate. (4.4.1; Dictus #704; Gboard.)
2. Show the exact Settings rows to touch, drawn with iOS's own grouped-list parts, and one button that
   opens Cutling's page in Settings; on return, detect the keyboard and move on by itself. (Grammarly,
   Wispr, ClipKeyboard.)
3. The try step is a real field with the keyboard up and Apple's words: touch and hold the globe, choose
   Cutling. It completes when a cutling is typed into the field. (Grammarly step 3, hex.)
4. A first cutling exists before the try step, so the keyboard is never empty on first open. (ClipKeyboard
   sample cutlings; Cutling's own empty keyboard in `cutling-today/15`.)
5. Drop the scroll-gated "What You Can Do" page, the iCloud page and the done page from setup; iCloud stays
   in Settings and the keyboard manager. (HIG: postpone nonessential setup; NN/g.)
6. What's New is Apple's iOS 27 sheet: left-aligned title, short subtitle, one row per real change, one
   Continue; shown once per version that declares rows, never on first install. (Calendar, Reminders, WhatsNewKit's per-version store.)
7. Someone back after 30 days or more sees "Welcome Back" with the three things that make Cutling work
   (switch with the globe, tap to type, save from anywhere) plus any new rows; if the keyboard was removed
   meanwhile, the sheet's button goes to setup. (Duolingo 30 days, Discourse.)

## Rejected

- Sign-in, surveys, carousels and paywalls before the keyboard (Grammarly, Wispr, SwiftKey): Cutling has no
  account and is paid up front.
- A Picture in Picture checklist over Settings (Dictus, Raycast's video): heavy to build, and Cutling's
  path in Settings is three taps on one page. GUESS: revisit if the try step shows people getting lost.
- Coach marks over the grid for twelve steps: NN/g and the HIG both argue against them; the editor's
  TipKit tips stay for later moments.
