# Onboarding remake and What's New sheet: plan (ASG103, ASG105)

Research: docs/research/onboarding/README.md (patterns, sources), directions.md (three directions).
Status: mocks for the owner's pick; nothing replaces the shipped guide until he says yes.

```
ASK     ASG105: make first-run setup friendlier and smoother: get the keyboard added and typing in the first
        minute. ASG103: a sheet for people who update or come back after a while.
        changes: KeyboardSetupView's 6 pages (welcome, enable, test, what-you-can-do, iCloud, done) and the
        auto-launched 12-step tutorial; WhatsNewView's stale 1.5 list and its 1.5-only trigger.
        stays: the keyboard (look frozen), the grid, the editor, iCloud and limits in the keyboard manager,
        "How to Use Cutling" replay of the tutorial, TipKit tips.
        goes (in every direction): the scroll-gated What You Can Do page, the iCloud page, the done page,
        Full Access as a gate (App Review 4.4.1), the tutorial's auto-start after setup.
SOURCES docs/research/onboarding/directions.md (every page cites saved files); Apple iOS 27 sheets shot on
        the simulator (apple/shots/sim); Grammarly, Wispr, Gboard frames; Dictus, ClipKeyboard, hex code.
BASE    KeyboardStatus: the one reader of "keyboard added" and "Full Access" (AppleKeyboards, app-group flag);
        used by every direction, the keyboard manager and the Welcome Back check.
        AppleSheet: Apple's welcome / What's New layout (title, subtitle, rows, one Continue); used by
        What's New, Welcome Back and direction A's welcome.
        SettingsPicture: Apple's grouped rows drawn as the buyer will see them in Settings; A and C.
        FullAccessSheet: why Full Access, what it opens, what Cutling never does; A, B, C.
        TryField: real field + Apple's "touch and hold the globe" line; done when a cutling's text lands in it.
BOUNDARY views read KeyboardStatus (an @Observable owned by the flow); CutlingStore for the starter cutling;
        no import cycle; CutlingApp is the composition root that picks the flow.
SCREEN  first launch (fresh install) -> direction's flow; update -> What's New; 30+ days away -> Welcome Back.
PLACE   iPhone and iPad: sheets (A, C, What's New); B lives in the grid's top. Mac unchanged.
WORDS   Apple's: "Touch and hold", "Open Settings", "Continue", "Allow Full Access". No "Whilst".
STATE   keyboardAdded, fullAccess: KeyboardStatus (derived from defaults, refreshed on scene active + 1 s poll
        while a setup screen is up); step: leaf state of the flow; starter cutling: CutlingStore.
ACTION  Open Settings -> UIApplication.openSettingsURLString; return -> status refresh -> A/C advance or tick
        with no animation beyond the system push; Try field text contains a cutling's value -> tick + Done.
TIMING  no spring, scale or fade of our own: system push/sheet transitions only; ticks change at once.
EDGES   keyboard already added (skip to Try); Full Access off (text works, images say why); AppleKeyboards
        missing (unknown, not "no": a manual "I added it" path); dark; large type; VoiceOver labels on
        every row and the picture (one label for the picture, not per fake control).
GUIDE   HIG Onboarding, Privacy (one Continue before a system alert), Virtual keyboards; App Review 4.4.1.
```

Mock switch (DEBUG only): `-ONBOARDING_MOCK A|B|C` runs that direction on launch; `-WHATSNEW_MOCK new|back`
shows the sheet. Shot by `CutlingUITests/OnboardingMockUITests.swift`.
