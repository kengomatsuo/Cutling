# Memory Index

- [deploy.sh — project deploy script](project_deploy_script.md) — `./deploy.sh web` deploys website from main→gh-pages; iOS subcommands also live here
- [Website source structure on main branch](project_website_structure.md) — source in `web/`, output to gitignored `dist/`, gh-pages is write-only
- [Release notes workflow](project_release_notes.md) — edit `fastlane/metadata/en-US/release_notes.txt`, then `./deploy.sh release_notes` to translate all locales
- [Cutling name translations](reference_cutling_translations.md) — How "Cutling" is localized per-language (transliterated, translated, or kept Latin)