# Open ASO items

Status on 2026-10-09. The owner asked on 2026-10-01 to hear these in the first reply of
each new session until they close.

1. **Dark frame 4 is missing in 39 of 50 locales.** Only ar-SA, bn-BD, ca, cs, da, de-DE,
   el, en-AU, en-CA, en-GB and en-US have it. Fix: `fastlane snapshot --only_testing
   CutlingUITests/CutlingUITests/testDarkFrame --languages <the 39>`, then
   `./deploy.sh frame`, `./deploy.sh screenshots`, and re-run
   `ruby fastlane/custom_product_pages.rb docs/aso/cpp.json` with `CPP_LOCALES` split
   across about 12 parallel workers. About 1-2 hours. Lands in the next version.
2. **Frame 1 shows the Cutling keyboard with no pasted text.** The iOS 27 simulator UI
   test cannot switch to the Cutling keyboard, so frame 1 reuses iOS 26 captures (es-ES
   uses es-MX's).
3. **Previews.** The iPhone 6.9" preview for 1.6.0 went up on 2026-10-09 (feature film
   first, older save film second). No iPad or Mac preview exists yet.
4. **Live ranks cover 565 of 1,109 queries**, because Apple's search endpoint returned 403.
   Rerun per [data/README.md](data/README.md), and take the 48-hour and 3-4-week
   re-measures after 1.5.5 ships.
5. **Release state.** 1.6.0 (18) went to review on iOS and Mac on 2026-10-09; Mac 1.5.5
   released the same day.

## What a screenshot run costs

On 2026-10-01 a full `./deploy.sh snap --all` (60 locales, iPhone and iPad) ran about 14
minutes per locale on the iOS 27 simulator, about 14 hours in all, and the owner was angry
that the ASO job "took 6 hours" when the text work had been done long before. Every
locale repeats the Settings keyboard setup and the app launches, and the machine is shared
with other sessions' simulators.

Time one locale first and state the total before starting. Capture only the frames that
change (`testDarkFrame` in CutlingUITests for frame 4, through `--only_testing`), reuse the
committed raws for the rest, and skip the 10 locale folders App Store Connect does not have
(bg, bn-IN, en-IN, et, fa, fil, lt, lv, sr, sw). Report the text work as done when it is
done.
