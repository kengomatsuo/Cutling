---
name: Release notes workflow
description: How to write and translate App Store release notes for Cutling — Claude does this autonomously
type: project
---

English release notes source: `fastlane/metadata/en-US/release_notes.txt`

## Claude's responsibility

When asked to write or update release notes, Claude should:

1. **Determine the current version** from the Xcode project:
   ```
   grep MARKETING_VERSION Cutling.xcodeproj/project.pbxproj | head -1
   ```

2. **Find the relevant commits** — look for the previous "New version release notes X.Y.Z" or "Bump version" commit, then list all commits since then:
   ```
   git log --oneline <prev-bump-hash>..HEAD
   ```

3. **Inspect each commit** for user-facing changes (skip pure metadata, localization-only, or internal tooling commits). Check diffs with `git show <hash> -- "*.swift"`.

   **iOS-ONLY — critical:** `release_notes.txt` is the **iOS** App Store "What's New" (deploy is `platform :ios`, bundle `com.matsuokengo.Cutling`). The macOS app ships separately via direct download (`./deploy.sh dist` + Sparkle) and has no App Store listing here. The commit diffs mix iOS + macOS + web changes, so filter every bullet: does this feature exist in the iOS app? NEVER list macOS-only features (Mac welcome screen, global hotkey, menu bar picker, Sparkle auto-update) or web-only changes. (A stray "On Mac, turn on iCloud from the welcome screen" line once shipped into an iOS submission — do not repeat.)

4. **Write the release notes** to `fastlane/metadata/en-US/release_notes.txt` — bullet points, plain language, user-facing framing.

5. **Run translations** immediately after writing:
   ```
   ./deploy.sh release_notes
   ```
   This requires the venv at `docs/_generator/.venv`. If it's missing, recreate it:
   ```
   python3 -m venv docs/_generator/.venv && docs/_generator/.venv/bin/pip install deep-translator tqdm -q
   ```

**How to apply:** Do all of the above autonomously when asked to write release notes — don't stop to ask the user to run the translation step.
