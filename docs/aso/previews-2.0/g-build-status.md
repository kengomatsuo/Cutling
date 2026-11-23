# Every app previews: where the build stands (2026-11-23 12:35 WIB)

Read with `g-build-brief.md` (the brief). A first builder ran from about 07:00 to 12:30 and was stopped with no film
made. What it left:

## Built and committed

- Cutling 91933e22: seed `seedForEveryApp` (`-SNAPSHOT_MODE -PROMO_EVERY`, en/id/ja keys from `g-words.json`, the
  drawn size-chart image, the Name blank's recent values; the ja order reply ends with a line break because the
  keyboard's `spaced` would put a space after 「。」), the hook in `CutlingApp.swift` and `Mac/MacApp.swift`,
  `CutlingUITests/PromoEveryAppUITests.swift` (a warm pass, then a filmed pass, with a press log),
  `scripts/every-app-takes.sh` (device-queue job: per-language keyboards, contacts, system language with a SpringBoard
  restart restored on exit, light mode, serves the refund page, runs the camera).
- cutling-promo 99cbb04: `src/every/EveryApp.tsx` (iPhone and iPad), `src/every/EveryMac.tsx`, `src/every/words.ts`
  (from g-words.json), compositions `EveryApp-<device>-<lang>` in `src/Root.tsx` (one per key of
  `src/every/takes.json`), `tools/every-plan.ts` (cuts each take and the simulator's lag between a press and its
  result), `takes-app/mac-every.swift` (compile with `swiftc -parse-as-library -O`; the binary is gitignored),
  `takes-web/refund.html`, `public/music/mixkit-complicated-281.mp3`. Lines over 760 px shrink to fit, keeping
  g-words.json's breaks; that change was never re-rendered.
- Build for testing (iOS sim and Mac Debug): `$(./build-dir.sh)/every` (src = git archive of HEAD plus the files above;
  `DerivedData`, `DerivedDataMac`).

## Takes so far

- iPhone en: `cutling-promo/public/every/iphone-en.mp4` is from a bad take (globe hold missed under load, Calendar's
  Location row is a button in iOS 27, a 24-hour region left by another job). `src/every/takes.json` was planned from it.
  Later runs fixed the Calendar title and Location; still open: typing "Maya" into To: brings no contact suggestion
  (contacts are imported, but sms: links read "No Name, Searching"), and the globe hold misses when the simulator lags.
- iPad id and ja (tickets t1795407891611-70d2, t1795407903111-b68d): `testEveryApp` fails at
  `PromoEveryAppUITests.swift:261` "Failed to get matching snapshot"; earlier the iPad's main thread stayed busy over
  30 s under load. The globe hold's row offset on iPad is a guess.
- Mac en: `public/every/mac-en-textedit.mp4`, `mac-en-safari.mp4` (1232x770 window, ~11 s each), recorded 12:29 while
  the owner was away. Mac id (12:31): both `.mov` files exist but the picker row was never found ("no row No.
  rekening", press log `mac-id.presses.json`), so the takes show the picker with no pick. Mac ja: not recorded (the
  owner came back). The Mac picker copies by default (pasteDirectly off), so a pick is followed by ⌘V.
- Mac takes bring TextEdit (an untitled, never-saved document) and a private Safari window to the front and press the
  real ⌘⇧V, so they run only while the owner is away from the keyboard (HID idle time). He gave 12:15-12:35 today;
  after that, run them whenever his Mac has been idle for 5 minutes or more.

## Machine and queue

- 08:00-11:05 load was 60-300 on 8 cores and swap 85-91 % from other sessions; at 12:30 load was 14.
- The device-queue pool is still the store sizes (iPhone 18 Pro Max, iPad Air 13-inch M4). When the takes are done,
  hand it back the way `scripts/frame04-store.sh` ends (a no-op ticket naming the usual pool).
- Contacts added to the store simulators by the takes stay there (Maya Brooks, Lea Hart, the en contacts of
  g-words.json).

## On the owner's Mac during the first run

An AppleScript prompt ("Terminal wants access to control TextEdit") came up at 07:14; held-⌘ typing opened Safari
Start Page windows (six closed afterwards); the first run replaced his clipboard and was killed before restoring it.
The tool now uses no Apple Events and restores the clipboard.
