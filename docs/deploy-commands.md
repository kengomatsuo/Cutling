# deploy.sh commands

```bash
./deploy.sh bump [patch|minor|major]  # Bump MARKETING_VERSION across every shipping build config
./deploy.sh build          # Build IPA for App Store (output: ./build/Cutling.ipa)
./deploy.sh binary         # Upload the already-built IPA to App Store Connect (binary only, no submit; run build first)
./deploy.sh snap           # Capture missing locale screenshots
./deploy.sh snap --all     # Recapture all screenshots
./deploy.sh frame          # Caption iPhone/iPad/Mac/product-page screenshots (fastlane/compose, CoreText; frameit cannot shape Arabic/Indic/Thai)
./deploy.sh screenshots    # Upload framed screenshots to App Store Connect
./deploy.sh metadata       # Upload iOS metadata/release notes to App Store Connect
./deploy.sh metadata_mac   # Upload macOS metadata (fastlane/metadata_mac: release notes, promo text, description, keywords, support URL) to App Store Connect (platform osx)
./deploy.sh upload         # Upload metadata + framed screenshots together
./deploy.sh all            # Full pipeline: metadata → screenshots → build → upload
./deploy.sh release_notes  # Translate iOS release_notes.txt to all locales (fastlane/metadata)
./deploy.sh release_notes_mac # Translate macOS release notes to all locales (fastlane/metadata_mac)
./deploy.sh web            # Deploy website to gh-pages (serves cutling.matsuokengo.com)
./deploy.sh dist           # Build/notarize/publish the macOS Developer ID app (direct download) + Sparkle appcast
./deploy.sh mas            # Build the clean "Cutling" target for the Mac App Store (no Sparkle) and upload the .pkg via fastlane (build_mac_app + deliver, platform osx)
./deploy.sh resubmit_notes # Correct notes on a version already in review (see release-workflow.md)
```
