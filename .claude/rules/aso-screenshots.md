---
paths:
  - "docs/aso/**"
  - "fastlane/**"
  - "CutlingUITests/**"
---

# Store screenshots and ASO

- **Time one locale before a screenshot run and state the total; capture only the frames that changed and reuse committed raws (a `snap --all` run takes about 14 minutes per locale, 14 hours in all).** Full account: [docs/aso/open-items.md](../../docs/aso/open-items.md).
- **`./deploy.sh frame` builds the store frames into `fastlane/frames/<locale>/<device>-NN.png`, the only folder the upload lanes and `fastlane/readback.rb` read: iPhone and iPad show Don't type it, one picture across eight frames (`fastlane/compose/creative/cpp`, page `main`); Mac and iPhone Duo show direction C (`fastlane/compose/creative/v2`).** Each build publishes only its own devices, so neither overwrites the other. Words: `cpp/words/` for the cpp pages, `v2/words/<locale>.json` for C; app strings, dates and numbers in `docs/aso/screens-2.0/locale-facts.json`. New captures go into both builds.
- **Every custom product page is a continuous set from `fastlane/compose/creative/cpp` (`python3 build.py <page> --all`, frames in `cpp/out/<page>/<locale>/`), uploaded with `fastlane/custom_product_pages.rb docs/aso/cpp-2.0/cpp-<page>.json` and checked with `--readback` plus the same spec files, which compares every image with disk.** Personal details and Notes you paste are Keys, Quick replies and Clipboard history are Night flight, Text expander is Don't type it. The plain green frames from `fastlane/compose` (`./deploy.sh frame_cpp`) now feed only the site's link preview.

- **After every screenshot upload, read back with `fastlane/readback.rb` before calling it done: deliver can upload a frame twice when it retries an upload that had already landed.** A set holding more than its files on disk has a duplicate; fetch the set again and delete the extra screenshot by its id, never by file name, since both copies share one.

- **The header and search banners (5244x2950, one per page and language) come from `fastlane/compose/creative/cpp/banners.py <page> --all`, each page in its own set's look, and go up with `undirect/Support/AppStore/banner.py upload` and `place` under a new prefix per render, since a rerun keeps an image already uploaded under its name; `banner.py show` is the readback.** Look at `out/banners/<page>/sheet.png` before uploading: every language's text has to sit whole inside the frame. Last readback: [docs/aso/readback-2026-11-27-banners.md](../../docs/aso/readback-2026-11-27-banners.md).
