# Keyboard extension with unbounded items: research

Question: how do iOS keyboard extensions show thousands of items (text and images) while staying under the keyboard extension memory limit, so Cutling's keyboard can hold any number of cutlings.

Every claim cites a URL or a file path in a cloned repo. Anything inferred without a source is marked GUESS.

## 1. How open-source keyboards lay out, load and store many items

Repos were shallow-cloned on 2026-11-20; paths are inside each repo at the commit shown. Found with GitHub code search for `UIInputViewController UICollectionView language:swift` and repo searches.

### Gladys keyboard (ptsochantaris/Gladys @ 6556469, 2026-09-27): the closest match to Cutling

Gladys is a drag-and-drop shelf app (text, images, files) with a keyboard extension, "GladysKeys" (product `Keyhive.appex`), that shows the whole collection as a grid. https://github.com/ptsochantaris/Gladys

- **Grid: UIKit `UICollectionView` with cell reuse.** `GladysKeys/KeyboardViewController.swift:111-162`: the controller is a `UICollectionViewDataSource`; `cellForItemAt` calls `dequeueReusableCell(withReuseIdentifier: "CommonItemCell")` and sets `cell.archivedDropItem = filteredDrops[indexPath.item]`. Square cells, 3 columns on a phone (`itemsPerRow`, lines 130-150).
- **SwiftUI inside reused cells.** `GladysUIKit/Sources/GladysUIKit/CommonItemCell.swift:67-101`: each `UICollectionViewCell` owns one `UIHostingController(rootView: ItemView(...))`, created lazily once per cell and re-pointed at a new item on reuse (`myWrapper.configure(with:size:style:)`). So the number of SwiftUI item views equals the number of live cells (about a screen and a bit), not the number of items.
- **Thumbnails: pre-generated on disk, loaded small.** Each component stores a `thumbnail.png` next to its data (`GladysCommon/Sources/GladysCommon/Component.swift:258-260`, `imagePath`). The keyboard uses `style = .widget` (KeyboardViewController.swift:158), and for that style `ArchivedItem+Presentation.swift:44,146-149` (GladysUI) loads `thumbnail`, which `Component.getThumbnail()` (Component.swift:724-733) reads from `thumbnail.png` and limits to 128 x 128 single scale. The original bytes are never decoded for the grid.
- **Data: one file per item, metadata only.** `GladysCommon/Sources/GladysCommon/LiteModel.swift:70-120` ("Only to be used in extensions!"): reads a packed `uuids` index file, then decodes each item's small metadata file inside an `autoreleasepool`. Item bytes are not loaded: `Component.bytes` is `Data.forceMemoryMapped(contentsOf: bytesPath)` (Component.swift:324-326), an `mmap(PROT_READ, MAP_PRIVATE)` wrapped in `Data(bytesNoCopy:deallocator: .unmap)` (`GladysCommon/Sources/GladysCommon/Data+Extensions.swift:17-48`).
- **State dropped on hide.** `viewWillDisappear` saves the scroll offset and calls `DropStore.reset()` (KeyboardViewController.swift:323-329); `viewWillAppear` reloads (268-284).
- **Copy: lazy item provider, not bytes.** The keyboard's context menu "Copy" calls `item.copyToPasteboard()` (KeyboardViewController.swift:414-416), which is `UIPasteboard.general.setItemProviders([itemProvider], localOnly: false, expirationDate: nil)` (`Gladys/Logic/ArchivedItem+Copy.swift:20-38`). Each component registers `registerDataRepresentation(forTypeIdentifier:visibility:)` whose loader hands back the memory-mapped `bytes` only when a reader asks (`Gladys/Logic/Component+Copy.swift:7-20`). Both files are in the GladysKeys target's Sources build phase (`Gladys.xcodeproj/project.pbxproj`, phase `16B2AA3424DF42B5004F3FC2`), so this runs inside the keyboard process. A tap inserts text with `textDocumentProxy.insertText` (168-174).

### Hamster, a Rime Chinese keyboard (imfuxiao/Hamster @ 6569370, 2025-05-13)

https://github.com/imfuxiao/Hamster. Candidate lists can be thousands of entries.

- **Rewrote KeyboardKit's SwiftUI views in UIKit.** `Packages/HamsterKeyboardKit/README.md:7` and `Packages/HamsterKeyboardKit/Sources/KeyboardKit/README.md:5` say the KeyboardKit SwiftUI view layer was replaced with UIKit. (The README gives no reason; GUESS: performance and memory in the extension.)
- **Grid: `UICollectionView` + `UICollectionViewDiffableDataSource`, cell registration and reuse.** `Packages/HamsterKeyboardKit/Sources/View/Compoents/CandidateWords/CandidatesPagingView.swift:36,89-107` (`dequeueConfiguredReusableCell`), symbol grid in `.../StandarKeyboard/ClassifySymbolic/SymbolsView.swift:18,78-98`. Cells clear content in `prepareForReuse` (`CandidateWordCell.swift:86-91`).
- **Data: paged in as you scroll.** `CandidateWordsCollectionView.swift:186-190` and `CandidatesPagingView.swift:164-169`: in `willDisplay`, when the last item is about to show, call `rimeContext.nextPage()`, which appends the next page of candidates from the engine (`Sources/RimeContext/RimeContext.swift:691-703`). The full list is never materialised.

### PrivateGifKeyboard (Xatter/PrivateGifKeyboard @ 56efd3e, 2026-03-29)

https://github.com/Xatter/PrivateGifKeyboard. GIF keyboard reading a folder of GIFs.

- **Grid: `UICollectionView`, reused `GifCell`.** `GifKeyboardExtension/KeyboardViewController.swift:70-74,275-300,318-354`; animation starts in `willDisplay` and stops in `didEndDisplaying`, and `prepareForReuse` resets the image view.
- **Thumbnails generated by the main app**, not the keyboard: "The companion app syncs GIFs to a local cache with thumbnails / The keyboard extension reads from the cache" (README.md "How It Works"); generator `Shared/Services/ThumbnailGenerator.swift:15-27` (ImageIO `CGImageSourceCreateThumbnailAtIndex`, `kCGImageSourceThumbnailMaxPixelSize`, `ShouldCacheImmediately`).
- **Data:** an `index.json` loaded whole on open (`docs/plans/2026-02-20-gif-keyboard-design.md:85-87`, which also assumes a "~30MB memory limit" with no source).
- **Copy:** reads the whole GIF into `Data` and `setData(_:forPasteboardType: UTType.gif)` (`Shared/Services/GifPasteboardService.swift:11-21`), i.e. the same cost Cutling pays today.

### xSticker (W-Mai/xSticker @ e5806a3, 2025-07-26)

https://github.com/W-Mai/xSticker. Sticker keyboard.

- Main keyboard grid is a `UICollectionView` with a flow layout (`xStickerBoard/CustomKeyboardView.swift:92-93`); a sticker-manager sheet uses SwiftUI `ScrollView > LazyVGrid` (`xStickerBoard/KeyboardStickerManagerView.swift:44-55`).
- **Data: Core Data** `NSFetchRequest`/SwiftUI `FetchRequest` per collection (`CustomKeyboardView.swift:30,156`; `KeyboardStickerManagerView.swift:35-42`), so only one collection's managed objects are fetched.
- **Images:** the WWDC 2018 ImageIO downsample, `kCGImageSourceShouldCache: false` on the source and `CreateThumbnailFromImageAlways` + `ShouldCacheImmediately` + `ThumbnailMaxPixelSize` on the thumbnail (`Shared/StickerManager.swift:182-197`).

### Keyboards that avoid the problem by capping or by tiny items

- **azooKey** (azooKey/azooKey @ 0b19111): its clipboard history tab is text-only (`AzooKeyCore/Sources/KeyboardViews/ClipboardHistoryManager.swift:31-33`, `enum Content { case text(String) }`), one JSON file in the App Group (130-147), trimmed to `maxCount` (line 124) which is `50` (`AzooKeyCore/Sources/AzooKeyUtils/AzooKeyKeyboardViewExtension.swift:142-144`). Shown in SwiftUI `ScrollView > LazyHStack` (`View/SpecialTabs/ClipboardHistoryTab.swift:333-335`). The emoji tab is `ScrollView(.horizontal) > LazyHGrid` (`View/SpecialTabs/EmojiTab.swift:311-318`).
- **KeyboardKit 6.9.6** (last tag with the open-source emoji keyboard): `Sources/KeyboardKit/Emojis/EmojiKeyboard.swift:60-77`, a SwiftUI `LazyHGrid` of all emojis in one category inside a horizontal `ScrollView` (`EmojiCategoryKeyboard.swift:147-148`). Emoji are glyphs, not bitmaps. In KeyboardKit 7+ the emoji keyboard moved to the closed Pro binary.
- **ISEmojiView** (isaced/ISEmojiView): UIKit `UICollectionView` emoji grid (`Sources/ISEmojiView/Classes/Views/EmojiCollectionView/EmojiCollectionView.swift`).

### What the examples agree on

1. Every keyboard here that shows images uses `UICollectionView` with reused cells (Gladys, PrivateGifKeyboard, xSticker); Hamster moved from SwiftUI to UIKit for its lists. The SwiftUI lazy stacks appear where items are text or glyphs (azooKey, KeyboardKit emoji) or in a secondary sheet (xSticker).
2. The keyboard never decodes the original image for the grid: it reads a small thumbnail the main app wrote to disk (Gladys `thumbnail.png`, PrivateGifKeyboard thumbnail cache) or downsamples with ImageIO (xSticker).
3. Item bodies stay on disk: Gladys decodes metadata only and memory-maps bytes; Hamster pages candidates in on `willDisplay`; xSticker fetches one collection from Core Data.
4. Copy: Gladys hands the pasteboard a lazy `NSItemProvider`; the GIF keyboard reads the whole file (Cutling's current cost).

## 2. SwiftUI lazy stacks vs cell reuse: memory evidence

### What Apple says

- Apple's article on lazy stacks says only that they "load and render their subviews on-demand", and that the system calculates geometry "only ... for subviews as they become visible". It says nothing about releasing or reusing subviews after they scroll away. https://developer.apple.com/documentation/swiftui/creating-performant-scrollable-stacks (read from the page's JSON, `developer.apple.com/tutorials/data/documentation/swiftui/creating-performant-scrollable-stacks.json`).
- `UICollectionView` reuse is documented behaviour: "When it is scrolled off screen, didEndDisplaying is called for the cell, and it ends up right back in the reuse pool. From the reuse pool, a cell can be dequeued again", and "UICollectionView maintains a reuse queue for each instance of a registration". WWDC21 "Make blazing fast lists and collection views", https://developer.apple.com/videos/play/wwdc2021/10252/ (transcript).
- Same session: iOS 15's `prepareThumbnail(of:)` / `byPreparingThumbnail(ofSize:)` "ensures that the image is read and processed with its destination size in mind, saving a lot of CPU time and memory"; prepared full images "take up a lot of memory, and they should be cached sparingly". Prefetching (`UICollectionViewDataSourcePrefetching`, `cancelPrefetchingForItemsAt`) gives time to prepare images before cells show.
- WWDC18 "iOS Memory Deep Dive", https://developer.apple.com/videos/play/wwdc2018/416/ (transcript): an image costs width x height x 4 bytes when decoded (2048 x 1536 JPEG of 590 KB uses about 10 MB); ImageIO `CGImageSourceCreateThumbnailAtIndex` downsamples with "a streaming API such that you only pay the dirty memory cost of the resulting image"; "Extensions have a much lower footprint" limit; "we recommend unloading large resources you cannot see"; caches should not be emptied wholesale on memory warnings because compressed pages grow back when touched.
  - Applied to Cutling: one 12 MP photo decoded at full size is about 4000 x 3000 x 4 = 48 MB, two thirds of the 77 MB limit. A 200 px thumbnail at 3x is 600 x 600 x 4 = 1.4 MB, or 0.16 MB at 200 x 200. (Arithmetic from the formula above.)

### Measurements and reports from developers

| Source | Setup | Finding |
|---|---|---|
| STRV, "SwiftUI: List vs LazyVStack", 2025-12-10, https://strvcom.substack.com/p/swiftui-list-vs-lazyvstack | iPhone 15 Pro, iOS 17.5.1, 1,001 rows each with 400 small image views; scroll to bottom then back to top | List 114.4 MB launch, 128.9 MB at bottom, 118.2 MB back at top. LazyVStack 90.2, 149.0, 151.8 MB. Author: "LazyVStack loads views lazily but struggles to free them, whereas List appears to reuse or release views that are no longer visible." |
| Jacob's Tech Tavern, "SwiftUI Scroll Performance: The 120FPS Challenge", 2025-05-05, https://blog.jacobstechtavern.com/p/swiftui-scroll-performance-the-120fps | iPhone 15 Pro, iOS 18.3.2 | On iOS 18 LazyVStack memory was "pretty consistent", views evicted after scrolling past; built against the iOS 16 SDK, memory grew the further he scrolled. Figures only in chart images. |
| Apple Developer Forums 703499 (2022-04), https://developer.apple.com/forums/thread/703499 | infinite list, device | Memory grows until crash with both `List` and `ScrollView/LazyVStack`; "remains pretty much constant" with a wrapped `UITableView`. No Apple reply. |
| Forums 776325 (2025-03), https://developer.apple.com/forums/thread/776325 | iOS 16 and 18, 10,000-row LazyVStack | Memory Graph showed row views not released; wrapping the row in a `VStack` changed it. Apple DTS asked for a bug report with a SwiftUI Instruments trace; no answer since. |
| Forums 771059 (2024-12), https://developer.apple.com/forums/thread/771059 | LazyVStack of row view models | Removed rows' view models never `deinit`; Memory Graph shows them owned by SwiftUI internals. No reply. |
| Forums 773238 (2025-01), https://developer.apple.com/forums/thread/773238 | LazyVStack of `UIImage(data:)` from SwiftData blobs | Memory not released for images off screen, crash past about 100 images. Apple DTS: "This isn't a SwiftUI problem but an implementation detail": store images as files and load by URL, and use thumbnails. |
| Forums 811432 (2025-12), https://developer.apple.com/forums/thread/811432 | SwiftUI `List` of 60 cards | Rows "destroyed and recreated", which does not match UIKit cell reuse. No reply. |
| Fatbobman, "Tips and Considerations for Using Lazy Containers in SwiftUI", 2024-03-14, https://fatbobman.com/en/posts/tips-and-considerations-for-using-lazy-containers-in-swiftui/ | lazy containers with image state | Lazy containers keep the state of top-level rows after they leave the screen; an `Image`/`UIImage` held in state is not released promptly even when set to `nil`. |
| Fatbobman, "List or LazyVStack", 2024-07-10, https://fatbobman.com/en/posts/list-or-lazyvstack/ | analysis, no memory numbers | `List` is backed by `UICollectionView` from iOS 16; `LazyVStack` is pure SwiftUI and keeps a full content height, instantiating every row above a far jump target. |

### Cutling's own measurement (from the brief, iOS 27.2 simulator, `scripts/keyboard-memory.sh`)

Keyboard up 44.7 MB; scrolling 1,000 full-length text snippets alone 53 MB; 1,000 text + 50 photos 68.4 MB; 1,000 text + 100 12 MP photos peaks at 95.5 MB; memory rises with each key scrolled past and does not fall back. That is the LazyVStack/LazyVGrid retention the STRV numbers and forums describe, now in Cutling's grid.

### What the evidence supports

- A SwiftUI lazy stack creates rows lazily but has no documented upper bound on rows it keeps after they leave the screen; measured on iOS 17 and in Cutling on iOS 27.2, memory climbs with scroll distance and does not return. (Jacob's iOS 18.3 test saw eviction, so behaviour varies by version and row shape; nothing Apple documents guarantees it.)
- `UICollectionView` documents a reuse pool: live cells are about one screen plus prefetch margin, independent of item count. That is the only design here whose memory ceiling does not depend on how far the user scrolls.
- Whatever the container, image memory comes from what is decoded: decoding originals costs width x height x 4; ImageIO thumbnails or `byPreparingThumbnail(ofSize:)` cost only the target size.

## 3. Apple guidance on extension memory, and how GIF keyboards keep it down

### Apple

- App Extension Programming Guide, "App Extension Creation": "Memory limits for running app extensions are significantly lower than the memory limits imposed on a foreground app ... the system may aggressively terminate extensions"; "Functionality that makes heavy use of system resources is appropriate for an app, not an app extension"; watch the debug gauges and profile with Instruments. https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/ExtensionCreation.html
- Same guide, "Custom Keyboard": `UIPasteboard` access is one of the things `RequestsOpenAccess` (Full Access) grants, so any copy path needs Full Access, and without it a keyboard "cannot share a container with its containing app". https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html
- WWDC18 "iOS Memory Deep Dive" (section 2 above): extensions have a much lower footprint limit; downsample with ImageIO; unload what is not on screen; on memory warnings change policy (stop caching) rather than purge and rebuild.
- The 77 MB keyboard limit itself is sourced in `docs/research/keyboard-memory-limits.md` (firmware `jetsamproperties` plists). Apple publishes no number.
- Forums, keyboard images: a keyboard showing images converted to HEIC rendered blank without Full Access and fine with it (https://developer.apple.com/forums/thread/114965, 2019, no reply). GUESS: write keyboard thumbnails as PNG or JPEG, not HEIC, until tested without Full Access.

### GIF and sticker keyboards

- GIPHY's rendition guide, for "a scrolling selection above the keyboard", recommends `fixed_width_small` or `fixed_height_small` for the preview (100 px wide per the glossary, https://developers.giphy.com/docs/optional-settings/renditions-glossary/), and "When the user selects a gif object, developers should call a higher quality rendition to send" (`downsized_large`). https://developers.giphy.com/docs/optional-settings/rendition-guide/
- GIPHY's iOS SDK grid (`GiphyGridController`) is a `UICollectionViewCell`-based waterfall grid; it caches media `Data` in `URLCache` (300 MB disk + memory by default, adjustable via `GPHCache.shared.cache.memoryCapacity`). https://github.com/Giphy/giphy-ios-sdk-ui-example/blob/master/Docs.md
- PrivateGifKeyboard (section 1): the main app writes thumbnails; the keyboard shows them in reused cells and animates only between `willDisplay` and `didEndDisplaying`.
- Gboard's and GIPHY Keys' keyboard code is closed; no source found for how they budget memory. GUESS: the same pattern (small preview renditions in a reused grid, full asset fetched only on send), since that is what GIPHY's own docs prescribe.

So the pattern is one rule, applied to every image: the grid shows a small, pre-sized rendition, and the full-size asset is touched only when the user picks it.

## 4. Putting a large image on the pasteboard without loading it whole

### Documented

- `UIPasteboard` takes data three ways: `setItemProviders(_:localOnly:expirationDate:)` for `NSItemProviderWriting` objects, `setValue(_:forPasteboardType:)` for common objects, and `setData(_:forPasteboardType:)` for binary data. https://developer.apple.com/documentation/uikit/uipasteboard (from its JSON). Apple's page for `setItemProviders` says nothing about when the providers' loaders run or what happens once the writing process ends (https://developer.apple.com/documentation/uikit/uipasteboard/setitemproviders(_:localonly:expirationdate:)), and the iOS SDK header (`UIKit.framework/Headers/UIPasteboard.h:65-73`, Xcode on this Mac) has no comment on it.
- `NSItemProvider.registerFileRepresentation(forTypeIdentifier:fileOptions:visibility:loadHandler:)` registers "a file-backed representation"; the handler returns a file URL (plus a `coordinated` flag). https://developer.apple.com/documentation/foundation/nsitemprovider/registerfilerepresentation(fortypeidentifier:fileoptions:visibility:loadhandler:)
- Keyboards need Full Access (`RequestsOpenAccess`) to use `UIPasteboard` at all (Custom Keyboard guide, section 3).
- Gladys's keyboard ships exactly this lazy path: `setItemProviders` with `registerDataRepresentation` loaders that return memory-mapped bytes (section 1, `Gladys/Logic/ArchivedItem+Copy.swift:20-38`, `Component+Copy.swift:7-20`).
- No Apple page, forum answer or blog found says whether a lazy provider is still served after its process is suspended or killed (searched 2026-11-20). For named non-persistent pasteboards Apple's older guide says they "only last until the owning (creating) app quits" (https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/UsingCopy,Cut,andPasteOperations/UsingCopy,Cut,andPasteOperations.html); the general pasteboard is persistent. That is the risk for a keyboard: its process can be torn down any time after the user switches keyboards.

### Measured: what each copy path costs the writer, and whether it survives the writer dying

No source answered this, so it was measured on 2026-11-20 with a throwaway probe app (not in the repo; source was in this session's scratchpad), on the iPad Pro 11-inch (M5) simulator, iOS 27.2, through the device queue (ticket t1795192672335-094e). The probe puts a 4032 x 3024 PNG (31.8 MB file, 12 MP) on `UIPasteboard.general`, logs its own `phys_footprint` (`task_info(TASK_VM_INFO)`), is terminated, and a new process of the same app then reads the pasteboard (same bundle, so no paste prompt).

| Write path | Footprint before -> after write -> 3 s later | Loader ran | New process after writer killed reads |
|---|---|---|---|
| `Data(contentsOf:)` + `setData(_:forPasteboardType: "public.png")` | 20.3 -> 51.2 -> 53.9 MB (+31 MB, the whole file) | n/a | 31,768,118 bytes |
| `Data(contentsOf:, options: .alwaysMapped)` + `setData` | 22.4 -> 22.5 -> 23.8 MB | n/a | 31,768,118 bytes |
| `NSItemProvider.registerDataRepresentation` (loader returns `.alwaysMapped` data) + `setItemProviders` | 22.1 -> 22.8 -> 22.7 MB | at once, 16 ms after `setItemProviders` | 31,768,118 bytes |
| `NSItemProvider.registerFileRepresentation` (loader returns the file URL) + `setItemProviders` | 21.6 -> 21.8 -> 23.8 MB | at once, 13 ms after `setItemProviders` | 31,768,118 bytes, and `loadFileRepresentation` gives a 31.8 MB file |
| `setObjects([fileURL as NSURL])` | 21.3 -> 21.3 MB | n/a | only `public.file-url`/`public.url`; no image (`Cannot load representation of type public.png`) |

What this shows (simulator, an app not a keyboard, one run each):

1. Reading the file whole costs its full size; this is the +20 MB Cutling measured. A memory-mapped `Data` handed to `setData` costs about 0.1 MB at the write and up to 1.4 MB a few seconds later: the pasteboard reads the mapped pages without making them dirty memory in the writer.
2. On iOS 27.2 the "lazy" item providers are not lazy: the system calls the loader as soon as `setItemProviders` runs and takes the bytes then, so the paste still works after the writer is gone. That removes the keyboard-death risk in section 4, and also means providers buy nothing over mapped `setData` for a single type.
3. A file-URL object does not put an image on the pasteboard.
4. Not tested: the same inside a keyboard process with Full Access, on a device, and pasting into another app. GUESS: the same, because `UIPasteboard` behaves the same in every process; check on device with `scripts/keyboard-memory.sh`.
5. `.mappedIfSafe`, Cutling's current option, is documented only as "a hint indicating the file should be mapped into virtual memory, if possible and safe" (https://developer.apple.com/documentation/foundation/nsdata/readingoptions/mappedifsafe); `.alwaysMapped` "takes precedence" (https://developer.apple.com/documentation/foundation/nsdata/readingoptions/alwaysmapped). Only `.alwaysMapped` was measured here. Gladys skips the hint and calls `mmap` itself (`Data+Extensions.swift:17-48`).

## 5. Recommendation for Cutling's keyboard

The aim is a keyboard whose memory depends on what is on screen, not on how many cutlings exist or how far the user scrolls. Four parts, each resting on the findings above.

### 5.1 Grid: `UICollectionView` with reused cells hosting the existing SwiftUI key

- Replace `cutlingGrid`'s `ScrollView > LazyVStack > LazyVGrid` (`CutlingKeyboard/KeyboardViewController.swift:1008-1090`) with a `UICollectionView`: compositional layout with an adaptive column count from `KeyStyle.cardMinWidth`, two sections (Suggestions, All), a `UICollectionViewDiffableDataSource<Section, Cutling.ID>`, and one `UICollectionView.CellRegistration` per key kind, created once (WWDC21 10252; Apple: "Don't create your cell registration inside a CellProvider closure; doing so prevents cell reuse", https://developer.apple.com/documentation/uikit/uicollectionview/cellregistration).
- Keep `CutlingKeyView` as the cell content through `cell.contentConfiguration = UIHostingConfiguration { CutlingKeyView(...) }` (iOS 16+, "to host a hierarchy of SwiftUI views in a collection or table view", https://developer.apple.com/documentation/swiftui/uihostingconfiguration; WWDC22 "Use SwiftUI with UIKit", https://developer.apple.com/videos/play/wwdc2022/10072/). Gladys does the same thing with one `UIHostingController` per reused cell (`CommonItemCell.swift:67-101`). The key's look, copied/blocked states and styled-copy button stay in SwiftUI; only the container changes.
- Copied/existed flashes become `snapshot.reconfigureItems([id])` on that one item, not a whole-grid rebuild.
- Rests on: the documented reuse pool (WWDC21), every image keyboard in section 1 using `UICollectionView`, Hamster's move from SwiftUI to UIKit, and the lazy-stack retention measured by STRV and by Cutling itself (section 2).
- Expected: live cells are about one screen plus the prefetch margin, so the views cost the same at 100 or 100,000 cutlings. GUESS for size: with about 20-40 live cells at a few hundred KB each, roughly 5-10 MB. Measure with `scripts/keyboard-memory.sh` before and after.

### 5.2 Thumbnails: written once by whoever saves the image, read small by the keyboard

- When the app, share or action extension saves an image cutling, also write `Images/thumbs/<filename>.jpg`: square-cropped, at the largest key size in pixels (GUESS: about 300 x 300 covers a 3x phone key; check against `KeyStyle`), drawn into a new bitmap. Not HEIC until tested without Full Access (forum 114965). The app makes thumbnails for existing images on its next launch; until one exists, the keyboard uses the current ImageIO downsample of the original.
- The keyboard loads the thumbnail off the main thread in the cell configuration (or `prefetchItemsAt`), cancels on reuse or `cancelPrefetchingForItemsAt`, and decodes with ImageIO `kCGImageSourceShouldCacheImmediately` at that size (WWDC18 416; `UIImage.preparingThumbnail(of:)` docs).
- Cache decoded thumbnails in an `NSCache` whose cost is bytes, `cgImage.bytesPerRow * cgImage.height` (as Gladys's `Caches.swift:25-30` does), with a cap such as 8 MB. Two defects in today's cache (`Cutling/CutlingStore.swift:189-190, 721-726`): the cost is the pixel count, so the "10 MB" limit allows about 40 MB of bitmaps; and `cgImage.cropping(to:)` "retains a reference to the original image" (https://developer.apple.com/documentation/coregraphics/cgimage/cropping(to:)), so each cached square keeps the whole 267 x 200 downsample alive. `NSCache` limits are also "not a strict limit" (https://developer.apple.com/documentation/foundation/nscache/totalcostlimit); with reused cells the real bound is the cells, and the cache is only a speed-up.
- Expected: a 300 x 300 thumbnail decodes to 0.36 MB (300 x 300 x 4), with no full-size decode or 12 MP read per key. Rests on: WWDC18 416 (memory = pixels x 4; ImageIO streams), Gladys `thumbnail.png`, PrivateGifKeyboard's app-made thumbnails, GIPHY's small preview renditions.

### 5.3 Data: the keyboard loads an index, and bodies on demand

- Today `CutlingStore` decodes every cutling whole (`Cutling/CutlingStore.swift:86, 297-299`). Cutling's measurement puts 1,000 full-length texts at about +8 MB (53 MB vs 44.7 MB), part of which is retained views; that grows with count, so at 10,000 it would not fit (GUESS by linear extrapolation).
- Give the keyboard a small per-cutling index: id, kind, a preview prefix long enough for the key (GUESS: about 300 characters), sort and suggestion fields, image filename, expiry and flags. Load the full body only when a key is tapped. Two ways, both Apple-only:
  1. Keep `Lists/*.json` as the source of truth and have writers also write a compact index file plus one body file per cutling, like Gladys's `uuids` file plus per-item files (`LiteModel.swift:70-120`).
  2. Move the store to SQLite (`libsqlite3`, ships with iOS) or Core Data in the App Group, query only the visible range, and fetch bodies by id. Core Data's `fetchBatchSize` returns "a proxy object that transparently fetches subsequent batches on demand ... an in-memory cursor" (https://developer.apple.com/documentation/coredata/nsfetchrequest/fetchbatchsize); xSticker uses Core Data from its keyboard; Hamster pages its data in from `willDisplay`.
  Option 1 keeps the current cross-process contract (Darwin notification, JSON lists in `CLAUDE.md`) and is the smaller change; option 2 is the one that scales without limit and makes search cheap. That choice of store is a design decision.
- Search and word-match suggestions then run on the index (preview plus title), and a full-text search, if wanted, runs as a query (option 2) or a streaming scan of body files off the main thread (option 1).
- Drop the decoded index, caches and cells in `viewWillDisappear` and reload in `viewWillAppear`, as Gladys does (`KeyboardViewController.swift:268-329`) and WWDC18 416 advises ("unloading large resources you cannot see"); the keyboard process can stay alive after it is hidden.

### 5.4 Copy: memory-mapped bytes straight to the pasteboard

- Keep `setData(_:forPasteboardType:)`, but read with `Data(contentsOf: url, options: .alwaysMapped)` (or `mmap` as Gladys does) instead of `.mappedIfSafe`. Measured: +0.1 MB at the write and +1.4 MB a few seconds later for a 31.8 MB 12 MP PNG, against +31 MB for a whole read, and the paste still works after the writing process is killed (section 4).
- Find the type with `CGImageSourceCreateWithURL` on the file URL instead of `CGImageSourceCreateWithData` on the bytes (`KeyboardViewController.swift:285-291`), or store the UTType with the cutling, so nothing touches the pages before the pasteboard does. (GUESS: reading the header through the mapped `Data` touches only the first pages, so this is tidiness, not a large saving.)
- An `NSItemProvider` with `registerFileRepresentation` measured the same and is the path to take if Cutling later offers several types per copy (for example PNG and JPEG), as Gladys does. A file URL object alone does not paste an image.
- Rests on: the probe in section 4 (simulator, app process). Still to check: inside the keyboard with Full Access on a device.

### Expected memory once all four land (GUESS until measured)

Keyboard base 44.7 MB (measured) + live cells (about 5-10 MB) + thumbnail cache (cap 8 MB) + index (well under 1 MB per 1,000 cutlings at about 300 characters each) + copy (about 1-2 MB, measured) gives roughly 60-65 MB at any number of cutlings, flat with scroll distance, under the 77 MB limit with headroom. The checks that prove it: run `scripts/keyboard-memory.sh` at 1,000x100 and 10,000x1,000 and confirm the scrolled and peak numbers match the 0x0 run within the cell and cache budget, then repeat once on a device.

### Order of work, by memory saved per change (GUESS from the measurements)

1. Copy with `.alwaysMapped` (one line; about 30 MB off the copy spike for a 12 MP PNG).
2. Collection view with `UIHostingConfiguration` cells (removes the growth with scrolling, about 40 MB of the 95.5 MB peak).
3. App-written thumbnails and a byte-cost cache (removes full-size decoding per key).
4. Index plus bodies on demand (what makes 10,000+ fit).

