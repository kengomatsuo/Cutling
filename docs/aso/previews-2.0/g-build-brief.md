# Brief: build Cutling 2.0's "Every app" App Store previews (direction G)

card: ASG166 (parent ASG155), board ~/Repositories/undirect/docs/plans/app-store-growth/BOARD.md. The session
cutling-2-previews owns the cards, commits, sends the clips to the owner and uploads to App Store Connect.

## The owner's request and picks

His ask (2026-11-22), word for word: "Where's the new previews and screenshots?" He expects Cutling 2.0's App Store
listing to carry new preview videos. The full request: `~/.claude/session-states/cutling-2-previews-brief.md`.

From the directions drawn for him (`docs/aso/previews-2.0/directions.md`), he picked **G, "Every app"** as the one
preview per device (iPhone, iPad, Mac), no second or third preview, and **"Complicated" (Mixkit 281)** as the music.
1.6.x carried previews in en-US, id and ja; 2.0's go up in the same three languages.

## Why

2.0 releases December 1 (both 2.0.0 versions are scheduled for 2026-12-01 00:00 UTC) and its previews have to be on
the 2.0.0 versions before 2.0 is sent to Apple. Previews autoplay muted on the product page and in search.

## Done

A person can watch, for each of iPhone (886x1920), iPad (1200x1600) and Mac (1920x1080), in en-US, id and ja, a 15-30 s
film at 30 fps cut from real recordings of Cutling 2.0 that tells G as `directions.md` section "G. Every app" draws it,
passing the product-video skill's check loops, saved as
`~/Repositories/cutling-promo/out/previews-2.0/cutling-preview-<iphone|ipad|mac>-<en|id|ja>.mp4` (the names
`fastlane/replace_previews.rb` uploads).

## Facts read from disk

- The design: `docs/aso/previews-2.0/directions.md`, sections "What binds round two", "G. Every app", "Recording notes
  for round two", "Seed for round two (English)", "Round two in Indonesian and Japanese", and round one's "What binds
  every direction" and "Recording (every take)". The drawn film: `docs/aso/previews-2.0/directions/round-2/src/`
  (`g-every-app.js`, `kit2.js`, `film.html`, `build.sh`), its animatic
  `docs/aso/previews-2.0/directions/round-2/g-every-app/animatic-iphone.mp4` and stills beside it. The screens there are
  drawn stand-ins; the film replaces them with recordings.
- Apple's rules, quoted with sources: `docs/aso/previews-2.0/apple-rules.md`. Apple rejected iOS 1.6.1 because its
  previews drew a device bezel around the recording.
- Indonesian and Japanese words and seed: `docs/aso/previews-2.0/g-words.json` (being written blind now by another
  agent from the meanings in directions.md; read it when it lands).
- Music: `~/Repositories/undirect-promo/monholt-samples/public/music-full/complicated.mp3` (Mixkit 281, Arulo);
  directions.md's music table gives where G starts the track.
- Simulators: shared through the device queue (`~/claude-house-rules/docs/device-queue.md`). Store sizes are iPhone
  18 Pro Max (626CECA3-66AF-4284-921F-C7A8FD05FA08) and iPad Air 13-inch M4 (178ED08A-840F-43D6-8261-D3C4D641E295);
  `scripts/frame04-store.sh` shows how the pool is switched to them and handed back, and `scripts/frame04.sh` how the
  Cutling keyboard is added the buyer's way and the keyboard list kept to one system keyboard plus Cutling.
  `scripts/ui-test.sh` runs UI tests in the queue and records the screen. On 2026-11-22 the pool was the store sizes
  (another session's frame-04 run).
- A build-for-testing of HEAD 1fc0d326 (iOS simulator) sits in `$(./build-dir.sh)/previews2/DerivedData`, built from
  `git archive HEAD` into `previews2/src`, because the main tree can be mid-edit by other sessions.
- Existing promo UI tests: `CutlingUITests/PromoTakesUITests.swift`, `PromoFilmUITests.swift`, `FillInUITests.swift`;
  seeding launch arguments such as `-SNAPSHOT_MODE`, `-PROMO_MODE`, `-FILLIN_TEST` are read in `Cutling/`.
- The Remotion project for Cutling films is `~/Repositories/cutling-promo` (product-video skill); its earlier store
  preview compositions are `src/explainer/Preview.tsx` and `MacPreview.tsx`.
- The Mac: no Cutling app is installed on this Mac. `~/Library/Group Containers/group.com.matsuokengo.Cutling` holds
  test data from earlier Debug runs. Screen Recording works for this session. Other sessions drive Chrome on this Mac.
  The product-video skill's `scripts/capture-mac-clean.swift` records one window without the cursor.

## Not to do

- Never create, edit or delete anything in the owner's own Calendar, Notes, Contacts, Mail or Messages on this Mac:
  they sync through his iCloud to his phone, so a test event or note lands on his devices and cannot be quietly taken
  back. A Mac take uses a place that writes nothing to his accounts.
- Nothing goes to App Store Connect, YouTube or any other outside service; this session uploads after the owner's yes.
