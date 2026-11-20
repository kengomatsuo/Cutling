# Keyboard extension memory limit: what is sourced

Read 2026-11-20. Apple publishes no number for a custom keyboard's memory limit.

| Fact | Source |
|---|---|
| A keyboard extension is killed when its `phys_footprint` crosses a hard limit: kernel log `memorystatus: keyboard [pid] exceeded mem limit: ActiveHard 77 MB (fatal)` | fcitx-contrib/fcitx5-ios, README.md (GitHub code search for "ActiveHard 77 MB") |
| 77 MB on recent iOS (iOS 18-era kernel logs and a JetsamEvent report on an iPhone 14 Pro running iOS 27), 66 MB on iOS 12-14, 48 MB on iOS 8, with no sign of scaling with device RAM | GDemay/Lokey, docs/BENCHMARK.md, "Keyboard memory: limit, stages and the q8_0 KV cache" |
| The Simulator enforces no limit; on a device, `footprint + os_proc_available_memory()` is the limit | GDemay/Lokey, docs/BENCHMARK.md |
| Instruments lifts the jetsam limit while attached, so its readings run high | a keyboard project's memory-profiling research notes (dictus, Phase 21), citing developer.apple.com/documentation/xcode/gathering-information-about-memory-use |
| Developers report roughly 48-77 MB by device and iOS version; KeyboardKit's docs say about 60-70 MB | KeyboardKit documentation, Memory Management (docs.keyboardkit.com); cl445/wurstfinger commit 5cd78f43 (48-66 MB) |
| `UserDefaults.sizeLimitExceededNotification` ("Posted when the amount of data in the defaults database exceeds the allowed maximum") exists on iOS 9.3+; the page states no size for iOS | developer.apple.com/documentation/foundation/userdefaults/sizelimitexceedednotification |

## Apple's own limits, read from the firmware

`com.apple.jetsamproperties.<board>.plist` in the restore image's filesystem sets each extension type's hard limit (`Version4 > Extension > Override`), read with `ipsw extract --remote --ranged --files --pattern 'jetsamproperties.*\.plist$' <ipsw URL>` (about 400-565 MB of ranged reads, no full download):

| Device, iOS | Keyboard (`com.apple.keyboard-service`) | Share (`com.apple.share-services`) | Widget (`com.apple.widgetkit-extension`) |
|---|---|---|---|
| iPhone XR (iPhone11,8, N841), iOS 18.0 (22A3354) | 77 MB active and inactive, jetsam priority 80 | 120 MB | 30 MB |
| iPhone SE 2nd generation (iPhone12,8, D79), iOS 27.2.1 (24B156) | 77 MB active and inactive, jetsam priority 80 | 120 MB | 30 MB |

Both are the smallest-memory iPhones (3 GB) that run Cutling's minimum and the current iOS, so the limit Cutling's keyboard lives under is 77 MB of `phys_footprint` on every supported iPhone.

## UserDefaults size

Apple documents `UserDefaults.sizeLimitExceededNotification` on iOS 9.3 and later but gives no size.

Apple's DTS engineers on the forums tie the log line "Attempting to store >= 4194304 bytes of data in CFPreferences/NSUserDefaults on this platform is invalid" to about 4 MB stored in one defaults domain, and advise keeping large data in a file (developer.apple.com/forums/thread/734927, thread/722096). A macOS user reports the write still succeeds there (thread/121527); iOS users report it does not.

For Cutling (iOS 18 and later): keep the keyboard's measured peak well under 77 MB, and keep the app-group defaults domain (`savedCutlings` + `recentlyDeletedCutlings`) under 4 MB.
