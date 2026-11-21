# Onboarding directions (ASG105) and the What's New sheet (ASG103)

Each direction rebuilds one source's structure in Cutling's own parts (accent green, `GlassProminentButtonModifier`, grouped `Form` rows, SF Symbols); none is a restyle of another.

- **A. Three short pages** (Grammarly's steps and Wispr's Settings picture, in Apple's welcome-sheet look): Welcome, Add the Keyboard, Try It, each one screen with one button.
- **B. Setup on the grid** (Apple Games' welcome card on Home, TypeWhisper's setup row, hex's "Finish setup"): no wizard. The app opens on the grid with a first cutling; a Finish Setting Up card carries the steps until done.
- **C. One live checklist** (Dictus' checklist, Wispr's checklist in Settings, TypeWhisper's status row): one sheet, three numbered rows that tick themselves as the buyer comes back, with the try field inside it.

| Page | A. Three short pages | B. Setup on the grid | C. One live checklist |
|---|---|---|---|
| P1 first screen | `apple/shots/sim/apple_reminders.png` `whats-new/shots/02-apple-journal-welcome.png` | `whats-new/shots/v-apple-games-welcome-card-0038.png` `whats-new/shots/04-apple-sports-get-started.png` | `apple/code/dictus-KeyboardSetupChecklistScript.swift` `competitors/shots/v-wispr-lets-set-up-flow-0026.png` |
| P2 add the keyboard | `competitors/shots/v-wispr-setup-in-settings-go-to-settings-0031.png` `competitors/shots/v-grammarly-setup-step2of3-add-keyboard-0056.png` | `competitors/shots/v-typewhisper-app-settings-keyboard-not-enabled-0016.png` `competitors/code/hex-ios-Onboarding.swift` | `apple/code/dictus-SettingsChecklistPictureCard.swift` `competitors/shots/v-wispr-settings-fullaccess-alert-checklist-overlay-0037.png` |
| P3 Full Access | `apple/code/dictus-FullAccessExplainerPage.swift` `apple/pages/gh-dictus-issue704.txt` | `competitors/shots/v-gboard-keyboard-needs-fullaccess-0114.png` `competitors/code/clipkeyboard-FullAccessGuideView.swift` | `whats-new/shots/v-sundrop-connect-photos-fullaccess-0134.png` `apple/shots/sim/apple_passwords_2.png` |
| P4 try it | `competitors/shots/v-grammarly-step3of3-switch-test-0120.png` `competitors/shots/v-wispr-globe-switch-step-0049.png` | `competitors/code/clipkeyboard-TutorialFlow.swift` `competitors/shots/12-clipkeyboard-appstore-keyboard-preview-field.jpg` | `competitors/code/type4me-ios-OnboardingView.swift` `competitors/code/hex-ios-KeyboardSetup.swift` |
| P5 after setup | `competitors/shots/v-grammarly-keyboard-installed-0129.png` | `competitors/shots/10-textexpander-appstore-home-setup-banner.jpg` `competitors/code/clipkeyboard-KeyboardSetupBannerGate.swift` | `competitors/shots/v-typewhisper-not-showing-up-fallback-0224.png` |

## What's New and Welcome Back (one design, not per direction)

- W1 What's New after an update copies Apple's iOS 27 What's New in Calendar (`apple/shots/sim/apple_calendar.png`): left-aligned title, grey subtitle, one row per real change, one Continue in the app's tint. Trigger: once per version that declares rows, never on first install (`whats-new/code/whatsnewkit-Sources_Store_UserDefaultsWhatsNewVersionStore.swift.txt`).
- W2 Welcome Back copies Welcome to Reminders (`apple/shots/sim/apple_reminders.png`) for its rows, shown once to someone away 30 days or more (`whats-new/pages/duolingo-back-from-the-brink.txt`, `whats-new/pages/discourse-welcome-back-inactive.txt`).
