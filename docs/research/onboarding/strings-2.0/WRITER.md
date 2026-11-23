# Writer's task: Cutling 2.0's corrected setup, What's New and walkthrough strings

You write one language, named in your prompt with its code and the app's folders for it.

Read `~/Repositories/Cutling/docs/onboarding-strings-brief.md`: its opening paragraphs (the app, the
person, the register) and the section "2.0 corrections (ASG162, ASG195)" to the end of the file.
Your keys are P1, P2, P3, P4, N2b, N4b, N5b, N17, N18 and TU2. No source string exists in any
language: write each from its meaning, in your language's own words, and do not ask for one.

Your language's words for this app are in `~/Repositories/Cutling/Cutling/<folder>.lproj/Localizable.strings`
(cutling, Variables, Ask Each Time, iCloud, keyboard, Next). The strings your language already
shows on the same sheets are in `~/Repositories/Cutling/docs/research/onboarding/strings/<code>.json`;
keep their register, and their words for the same things. Copy rules: the `human-prose` skill and
`~/Repositories/Cutling/.claude/rules/localization.md`.

Write `~/Repositories/Cutling/docs/research/onboarding/strings-2.0/<code>.json`:

```json
{"folders": ["<folder>", "..."], "strings": {"P1": "...", "...": "..."},
 "back": {"P1": "literal English back-translation", "...": "..."}, "notes": "register and grammar choices"}
```

Reply with one line: the file's path, and any key you could not fit in its budget.
