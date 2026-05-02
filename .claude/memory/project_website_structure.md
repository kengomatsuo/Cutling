---
name: Website source structure on main branch
description: Where the Cutling GitHub Pages website source lives and how the build works
type: project
originSessionId: ebe753d6-b48d-4160-952d-6a3d002d01fd
---
Website source lives in `web/` on the `main` branch (tracked):
- `web/_generator/generate.py` — static site generator (outputs localized HTML)
- `web/_generator/templates/` — HTML templates (index, faq, support, privacy)
- `web/_generator/translations/` — per-locale JSON translation files
- `web/style.css`, `web/locale-router.js`, `web/icon.png`, `web/img/` — static assets
- `locales.json` at repo root — shared source of truth for locale list (used by both iOS and the generator)

Generated output goes to `dist/` (gitignored). `gh-pages` branch is write-only output — never edit it directly.

**Why:** Moved source from `gh-pages` branch to `main` so the user never needs to switch branches to edit the website. The generated locale HTML dirs were polluting code analysis tools.
