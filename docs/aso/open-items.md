# Open ASO items

Status on 2026-11-27. The owner asked on 2026-10-01 to hear these in the first reply of
each new session until they close.

1. **Closed 2026-11-23: frame 4 is in all 50 locales.** It now shows the remade setup guide's Try It page in
   dark mode with the Cutling keyboard typing the locale's saved address, on 6.9-inch iPhone and 13-inch iPad
   (`scripts/frame04-store.sh`, card ASG137, commit 358642b1). It goes up with 2.0's screenshots.
2. **Open: the grid captures in nine languages carry the app's older plural (board ASG192).** 2.0's main page is
   Don't type it on iPhone and iPad and direction C on the Mac, in all 50 languages (`fastlane/frames`, ASG252,
   read back 2026-11-27). The grid captures (`02_MainGrid`) in hu, it, hr, no, he, ru, sl-SI, uk and ur-PK still
   show the older plural in their title, on main-page frames 4 and 8, Personal details frames 4 and 6 and Quick
   replies frames 5 and 6. A reshoot of that one capture, then `./deploy.sh frame` and the page builds, fixes it.
3. **Closed 2026-11-27: 2.0.0 has a preview in every slot it uses.** iPhone and iPad in en-US, id and ja show
   2.0 films cut from real recordings (tap to type, a reply that asks for the name, Maps, saving from any app;
   cutling-promo `src/Preview20.tsx`), and the Mac keeps 1.6.2's film, since 2.0's Mac picker looks as it does in that
   film. All nine read back COMPLETE (ASG155, ASG166).
4. **Closed 2026-11-12: live ranks cover all 1,146 queries** (1,110 with results; 36 have
   none in their storefront). Cutling is top ten in 21 of them, top three in 2, and ranks in
   352. On the 566 searches measured since 2026-10-01 it is top ten in 7, against 8 on
   2026-11-07 and 2 on 2026-10-01. The earlier 403 came from parallel runs: about 20 requests
   a second draws an empty 403 from Apple's gateway for about a minute, and one process at
   1.2 s draws none. Data: [data/ranks-2026-11-12.json](data/ranks-2026-11-12.json).
5. **Release state.** iOS and Mac 1.6.2 are live. 2.0.0 is prepared on both and scheduled for 2026-12-01 00:00 UTC,
   with no build attached yet and not submitted (ASG151). `ruby fastlane/submit_release.rb <build>` attaches the
   build and submits both; the iOS submission also carries every custom product page version still being prepared:
   v2 of Personal details and Quick replies (both approved and live as v1) and v1 of Text expander, Clipboard
   history and Notes you paste, all continuous sets (ASG250). Submitting waits for the owner's yes.

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
