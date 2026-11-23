---
paths:
  - "docs/aso/**"
  - "fastlane/**"
  - "CutlingUITests/**"
---

# Store screenshots and ASO

- **Time one locale before a screenshot run and state the total; capture only the frames that changed and reuse committed raws (a `snap --all` run takes about 14 minutes per locale, 14 hours in all).** Full account: [docs/aso/open-items.md](../../docs/aso/open-items.md).
- **The store frames are direction C, "The blank", built by `./deploy.sh frame` into `fastlane/frames/<locale>/{iphone,ipad,mac}-NN.png`, the only folder the upload lanes and `fastlane/readback.rb` read.** Its source is `fastlane/compose/creative/v2` (words per language in `words/<locale>.json`, written blind from `docs/aso/screens-2.0/C-words-brief.md`; app strings, dates and numbers in `docs/aso/screens-2.0/locale-facts.json`). New captures go into that build. The plain green frames from `fastlane/compose` are the old style and now feed only custom product pages and the site's link preview (`./deploy.sh frame_cpp`); directions A and B in `v2` and Keys, Poster and Night flight in `creative/sets` wait for the product page test (board ASG149).

- **After every screenshot upload, read back with `fastlane/readback.rb` before calling it done: deliver can upload a frame twice when it retries an upload that had already landed.** A set holding more than its files on disk has a duplicate; fetch the set again and delete the extra screenshot by its id, never by file name, since both copies share one.
