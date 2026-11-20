---
paths:
  - "web/**"
---

# Website

**The website is `cutling.matsuokengo.com`** (moved off `kengomatsuo.github.io/Cutling` 2026-08-15). Pages serves `gh-pages` at the domain root, so `SITE_BASE` in `web/locale-router.js` + `web/fuzzy-redirect.js` is `''`, and `web/CNAME` must be copied into the built site (`$(./build-dir.sh)/site`) on every build: `deploy_web` rsyncs with `--delete` and would otherwise wipe it and silently unset the domain. Old github.io URLs 301 with the path preserved, which keeps installed Sparkle clients on the old `SUFeedURL` updating. Full account, with the DNS token: [docs/website-domain.md](../../docs/website-domain.md).

**Website copy is composed per locale from a meaning brief, never translated.** `web/_generator/INTENT.md` states what each of the 181 keys must MEAN; each `web/_generator/translations/<locale>.json` is written from it without reading `en-US.json`. Gate every file on `python3 web/_generator/validate_translations.py`.

**`web/_generator/ai_files.py` is one file kept identical in undirect and Cutling (2026-11-20); each site says what it is in its own `ai_facts.py`.** A change to one copy is made to the other in the same turn, so both sites keep serving the same llms.txt, robots.txt and `.well-known` shapes.

**`web/_generator/store-source.js` is one file kept identical in undirect and Cutling.** It gives every App Store button the visit's source as its campaign token (`?ref=`, `?utm_source=`, `?ct=` or the referring site), so App Store Connect > Campaigns names a source the same way for both apps; a change to one copy is made to the other in the same turn. A new App Store link anywhere else is a campaign link with `pt` and its own `ct`, listed in `docs/plans/app-store-growth/campaigns.md` in the undirect repo.
