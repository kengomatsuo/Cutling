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

**CRITICAL: Before running `release_notes`, always generate the English source first.** See `project_release_notes.md` for the full workflow (check version, diff commits, write en-US release_notes.txt, then translate).

iOS deploy subcommands: `release_notes`, `metadata`, `snap`, `snap_all`, `frame`, `screenshots`, `upload`, `build`, `all`.
- `snap` / `snap_all` — capture screenshots (missing only / all from scratch)
- `frame` — add device bezels and marketing text via frameit
- `screenshots` — upload framed screenshots to App Store Connect (replaces raw with framed, then uploads)
- `upload` — upload metadata + framed screenshots together

**Python venv:** `docs/_generator/.venv` — required for `release_notes` step (`deep-translator` package). If missing, create with: `python3 -m venv docs/_generator/.venv && source docs/_generator/.venv/bin/activate && pip install deep-translator`
