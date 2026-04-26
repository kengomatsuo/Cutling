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

Take localized screenshots

### ios framed_screenshots

```sh
[bundle exec] fastlane ios framed_screenshots
```

Take screenshots and add device frames with marketing text

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

Upload screenshots only to App Store Connect

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Upload metadata and screenshots to App Store Connect

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

### ios deploy

```sh
[bundle exec] fastlane ios deploy
```

Full deploy: metadata → missing screenshots → frame → upload all → build & submit

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
