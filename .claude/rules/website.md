---
paths:
  - "web/**"
---

# Website

**The website is `cutling.matsuokengo.com`** (moved off `kengomatsuo.github.io/Cutling` 2026-08-15). Pages serves `gh-pages` at the domain root, so `SITE_BASE` in `web/locale-router.js` + `web/fuzzy-redirect.js` is `''`, and `web/CNAME` must be copied into `dist/` on every build: `deploy_web` rsyncs with `--delete` and would otherwise wipe it and silently unset the domain. Old github.io URLs 301 with the path preserved, which keeps installed Sparkle clients on the old `SUFeedURL` updating. Full account, with the DNS token: [docs/website-domain.md](../../docs/website-domain.md).

**Website copy is composed per locale from a meaning brief, never translated.** `web/_generator/INTENT.md` states what each of the 181 keys must MEAN; each `web/_generator/translations/<locale>.json` is written from it without reading `en-US.json`. Gate every file on `python3 web/_generator/validate_translations.py`.
