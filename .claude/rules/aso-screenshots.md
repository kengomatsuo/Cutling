---
paths:
  - "docs/aso/**"
  - "fastlane/**"
  - "CutlingUITests/**"
---

# Store screenshots and ASO

- **Time one locale before a screenshot run and state the total; capture only the frames that changed and reuse committed raws (a `snap --all` run takes about 14 minutes per locale, 14 hours in all).** Full account: [docs/aso/open-items.md](../../docs/aso/open-items.md).
- **The plain green frames from `./deploy.sh frame` are the old style, not the design the owner wants.** His redesign lives in `fastlane/compose/creative/` (board ASG148/149: Keys, Poster, Night flight); before shooting or framing any store screenshot, read those cards and put new captures into the current design through that session, never into the green template.
