fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Clear all screenshots and recapture from scratch

### ios framed_screenshots

```sh
[bundle exec] fastlane ios framed_screenshots
```

Clear all screenshots, recapture, and add device frames with marketing text

### ios new_screenshots

```sh
[bundle exec] fastlane ios new_screenshots
```

Take screenshots for new ASC languages only (keeps existing screenshots)

### ios frame

```sh
[bundle exec] fastlane ios frame
```

Frame screenshots with device bezels and marketing text

### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

Upload metadata only (no screenshots)

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload framed screenshots only to App Store Connect

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Upload metadata and framed screenshots to App Store Connect

### ios add_new_locales

```sh
[bundle exec] fastlane ios add_new_locales
```

Create/update ASC localizations for new languages via Spaceship API

### ios build

```sh
[bundle exec] fastlane ios build
```

Build IPA for App Store submission

### ios upload_binary

```sh
[bundle exec] fastlane ios upload_binary
```

Upload the already-built IPA to App Store Connect (binary only, no metadata/screenshots). Run `build` first. Does NOT submit for review.

### ios deploy

```sh
[bundle exec] fastlane ios deploy
```

Full deploy: metadata → missing screenshots → frame → upload all → build & submit

### ios asc_status

```sh
[bundle exec] fastlane ios asc_status
```

Print current iOS App Store version + review-submission states (read-only)

### ios resubmit_notes

```sh
[bundle exec] fastlane ios resubmit_notes
```

Cancel the in-review submission, push corrected metadata, and resubmit for review

----


## Mac

### mac upload_mas

```sh
[bundle exec] fastlane mac upload_mas
```

Build the clean Cutling macOS App Store target (no Sparkle) and upload the .pkg to App Store Connect

### mac upload_metadata_mac

```sh
[bundle exec] fastlane mac upload_metadata_mac
```

Upload macOS App Store metadata (release notes only) from fastlane/metadata_mac

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
