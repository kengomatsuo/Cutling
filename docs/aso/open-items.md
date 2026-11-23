# Open ASO items

Status on 2026-10-09. The owner asked on 2026-10-01 to hear these in the first reply of
each new session until they close.

1. **Closed 2026-11-23: frame 4 is in all 50 locales.** It now shows the remade setup guide's Try It page in
   dark mode with the Cutling keyboard typing the locale's saved address, on 6.9-inch iPhone and 13-inch iPad
   (`scripts/frame04-store.sh`, card ASG137, commit 358642b1). It goes up with 2.0's screenshots.
2. **Closed 2026-11-23: the store frames no longer use the Messages capture.** 2.0's frames (direction C, in all
   50 languages, iPhone, iPad and Mac; `fastlane/frames`, card ASG167) show each language's Try It, grid and Mac
   captures. The Messages captures (`01_KeyboardInMessages`) are English in most languages and are left only in the
   custom product pages. The grid captures (`02_MainGrid`) in some languages still carry an older plural in their
   title (hu, it, hr, no, he, ru, sl-SI, uk, ur-PK); a reshoot of that one frame fixes it.
3. **Previews.** The iPhone 6.9" preview for 1.6.0 went up on 2026-10-09 (feature film
   first, older save film second). As of 1.6.1, en-US, id and ja have iPhone, iPad and
   Mac previews; the iPhone and iPad ones are being re-cut without the device frame.
4. **Closed 2026-11-12: live ranks cover all 1,146 queries** (1,110 with results; 36 have
   none in their storefront). Cutling is top ten in 21 of them, top three in 2, and ranks in
   352. On the 566 searches measured since 2026-10-01 it is top ten in 7, against 8 on
   2026-11-07 and 2 on 2026-10-01. The earlier 403 came from parallel runs: about 20 requests
   a second draws an empty 403 from Apple's gateway for about a minute, and one process at
   1.2 s draws none. Data: [data/ranks-2026-11-12.json](data/ranks-2026-11-12.json).
5. **Release state.** iOS 1.6.1 (19) was rejected on 2026-11-11 under guideline 2.3.4:
   its iPhone and iPad previews draw a phone bezel around the screen recording. Re-cut
   previews in the style of Undirect's accepted ones (bare rounded screen, no hardware)
   replace them on 1.6.1. Resubmitted 2026-11-12 with `ruby fastlane/resubmit_rejected.rb IOS`;
   iOS 1.6.1 is WAITING_FOR_REVIEW and Mac 1.6.1 is in review.

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
