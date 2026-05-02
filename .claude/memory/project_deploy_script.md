---
name: deploy.sh — project deploy script
description: deploy.sh is the single entry point for all deploy operations (iOS App Store + website). Key subcommands to remember.
type: project
originSessionId: ebe753d6-b48d-4160-952d-6a3d002d01fd
---
`deploy.sh` lives at the repo root and handles both iOS and website deployments.

**Website deploy (gh-pages):** `./deploy.sh web`
- Runs `web/_generator/generate.py --output-dir dist/` to generate locale HTML into `dist/`
- Copies static assets (`style.css`, `locale-router.js`, `icon.png`, `img/`, `locales.json`) into `dist/`
- Uses `git worktree` to push `dist/` contents to the `gh-pages` branch

**Why:** User edits website source on `main` branch (in `web/`) and deploys without ever switching branches.

**How to apply:** Edit templates/translations/CSS under `web/` on `main`, then run `./deploy.sh web`. The `dist/` output dir is gitignored — never commit it.

iOS deploy subcommands: `release_notes`, `metadata`, `screenshots`, `frame`, `upload_screenshots`, `build`, `all`.
