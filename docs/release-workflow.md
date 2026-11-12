# Release workflow

1. `./deploy.sh bump` (patch by default) rewrites MARKETING_VERSION **and CURRENT_PROJECT_VERSION** in every shipping build config and leaves CutlingUITests alone. App Store Connect tracks build numbers **per platform** and rejects any that is not higher than that platform's last upload, so the single shared counter must exceed BOTH (macOS was already at 14 while iOS was at 1, hence the jump to 15 for 1.5.3).
2. Edit the **two** App Store "What's New" sources. iOS and macOS carry **different** copy and live in separate metadata trees:
   - `fastlane/metadata/en-US/release_notes.txt` is the **iOS** App Store. iOS-relevant items only; never list macOS-only features (Mac welcome screen, global hotkey, menu bar picker, auto-update) here.
   - `fastlane/metadata_mac/en-US/release_notes.txt` is the **macOS** App Store (the `Cutling` target's `mas` build). macOS-relevant items only. (The direct-download `dist` + Sparkle build is a separate channel and has no App Store listing.)
   - Scope each to the delta over what is LIVE on that platform (a platform's live version can differ from the other's).
3. `./deploy.sh release_notes` (iOS) and `./deploy.sh release_notes_mac` (macOS) translate each to all locales.
4. `./deploy.sh all` (iOS build + metadata + screenshots) and `./deploy.sh metadata_mac` (macOS notes); macOS binary via `./deploy.sh mas`.

To correct notes on a version already submitted for review, use `./deploy.sh resubmit_notes` (cancels the in-review submission, re-uploads metadata, resubmits; resets the review queue).
