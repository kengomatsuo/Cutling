# Memory Index

- [Project architecture & targets](project_architecture.md) — 6 targets, shared code, compilation flags, bundle IDs, entitlements, app group
- [Data model & CutlingStore](project_data_model.md) — Cutling struct, limits (100 text / 25 image), persistence, Darwin notifications, image handling
- [Extensions (keyboard, share, action, widgets)](project_extensions.md) — All 4 extension architectures, keyboard features, ShareView, ControlWidgets
- [UI views & app lifecycle](project_ui_and_app.md) — All views, deep links (cutling://), quick actions, iCloud sync, background tasks, localization
- [Use existing translations](feedback_localization.md) — Always reference existing Localizable.strings before writing new translations
- [Cutling name translations](reference_cutling_translations.md) — How "Cutling" is localized per-language (transliterated, translated, or kept Latin)
- [deploy.sh — project deploy script](project_deploy_script.md) — `./deploy.sh web` deploys website from main→gh-pages; iOS subcommands also live here
- [Website source structure on main branch](project_website_structure.md) — source in `web/`, output to gitignored `dist/`, gh-pages is write-only
- [Release notes workflow](project_release_notes.md) — edit `fastlane/metadata/en-US/release_notes.txt`, then `./deploy.sh release_notes` to translate all locales
