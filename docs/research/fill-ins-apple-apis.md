# Fill-ins: every value Apple's public APIs let Cutling read (card ASG124)

Read 2026-11-21. Question: which values can an iOS/iPadOS 27 or macOS 27 app, or Cutling's keyboard extension, read with public Apple APIs, so a Cutling 2.0 fill-in can insert them when a cutling is used? Competitors' variable kinds and inserter screens are the other agent's job (`fill-ins-kinds/`); this file is only about what Apple permits. Dates, formats and the memory limit are already settled in `fill-ins-dates.md`, `keyboard-memory-limits.md`, `fill-ins-keyboard-apis.md` and `smarter-typing.md`; they are linked, not redone.

How to read it. "SDK" means I read the header or swiftinterface in the iPhoneOS 27.2 or MacOSX 27.2 SDK of the Xcode on this Mac; each is saved under `fill-ins-apple-apis-sources/` (names in the table at the end). "Doc" means an Apple page fetched today, saved in `fill-ins-apple-apis-sources/docs/`. Nothing here was run on a phone or in a simulator, so every statement about what works inside the keyboard process is read, not observed. **UNSURE** = not confirmed by a source. **GUESS** = my opinion. Cutling's minimum is iOS 18 (`keyboard-memory-limits.md`), so "min OS" above 18 needs an availability check.

## 1. The short answer

The owner's belief is half right. Apple offers many values, but three rules cut the list hard:

1. **A keyboard is a small, sandboxed process.** Apple's own words: without Full Access it has no network, no write to the shared container, and "the keyboard can access Location Services and Contacts, with user permission" only with it (`apple_configuring-open-access...md` in `fill-ins-keyboard-apis-sources/`). App Review 4.4.1 says a keyboard must "remain functional without full network access and without requiring full access" and must not "launch other apps besides Settings" (guideline text saved in `docs/developer_apple_com_app-store_review_guidelines_.txt`). So every kind that needs Full Access, a permission prompt, or another app must degrade to "ask the person to type it", which is what Cutling does now. Memory is 77 MB of `phys_footprint` on every supported iPhone (`keyboard-memory-limits.md`).
2. **Most "personal" values have no public API at all** (section 8): the person's own phone number, Apple Account name or email, the Me card on iOS, the owner name of the device on iOS (`UIDevice.name` is generic since iOS 16), carrier, Focus name, passwords, Messages and Mail content.
3. **Where an API exists, the main app can usually read it and the keyboard cannot**, so there are four delivery routes, used below as the "Where" column:
   - **K** computed in the keyboard from the clock, locale and field, no permission, works without Full Access (all of section 2 and 3).
   - **S** snapshot: the main app (or Mac app) reads it, writes the result to the App Group, the keyboard reads the file. Works without Full Access (reading the group is allowed, writing needs Full Access only from the keyboard, Apple page above). Stale until the app next runs.
   - **P** pick once: an out-of-process Apple picker the person uses in the main app (no permission prompt), the result is saved as a "saved value".
   - **M** Mac live: the Mac app reads it at use time (Accessibility, NSWorkspace, AppleScript).

New iOS 27 SDK surface relevant here is thin. I grepped the 27.2 SDK for `ios(27` in Contacts, ContactsUI, EventKit, Intents, Translation, NaturalLanguage, MediaPlayer, WeatherKit, CoreLocation (only a maritime configuration and a body-heading property) and found nothing useful for fill-ins (`sdk_new_in_27_scan_iOS27.2.txt`). Everything below that is "new" is iOS 26: `DataDetector` (Swift), `MKReverseGeocodingRequest`, `RecognizeDocumentsRequest`, `TranslationSession(installedSource:target:)`, FoundationModels, Bangla, Gujarati, Kannada, Malayalam, Marathi, Odia, Tamil, Telugu, Vikram, Dangi and Vietnamese calendars.

## 2. Inventory A: time, calendar and language (Foundation; no permission; keyboard yes, no Full Access; route K)

Baseline already shipped: `{date}`, `{time}`, `{day}`, formats and date math (`fill-ins-dates.md`). These are the additions.

| # | Value | API (SDK/doc) | Min OS | Permission | Review/privacy | Example inserted |
|---|---|---|---|---|---|---|
| A1 | Time zone name, abbreviation, UTC offset | `TimeZone.current` (`NSTimeZone.h`) | iOS 2 | none | none | `Jakarta (WIB, UTC+7)` |
| A2 | Time in another place | `TimeZone(identifier:)` plus a date style; person picks the zone once | iOS 2 | none | none | `3 pm WIB / 9 am CET` |
| A3 | Relative phrase | `Date.RelativeFormatStyle`, `NSRelativeDateTimeFormatter.h` | iOS 13 / 15 | none | none | `in 3 days`, `yesterday` |
| A4 | Week number, ISO week, day of year | `NSCalendarUnitDayOfYear` is iOS 18 (SDK `NSCalendar.h`); `weekOfYear`, `yearForWeekOfYear` | iOS 18 for day of year | none | none | `Week 47, day 325` |
| A5 | Quarter | `NSCalendarUnitQuarter`; the header itself says it "is largely unimplemented, and is not recommended for use" (SDK) | n/a | none | none | compute it from the month instead (GUESS) |
| A6 | Weekend-aware days ("next business day") | `isDateInWeekend` "as defined by the calendar and calendar's locale" (SDK) | iOS 8 | none | none | `Monday 24 Nov` when sent on Friday evening |
| A7 | The same day in another calendar | Gregorian, Buddhist, Chinese, Hebrew, Indian, Islamic (civil, tabular, Umm al-Qura), Japanese, Persian, ROC, ISO 8601 and, since iOS 26, Bangla, Gujarati, Kannada, Malayalam, Marathi, Odia, Tamil, Telugu, Vikram, Dangi, Vietnamese (SDK `NSCalendar.h` lines 27-72) | iOS 4 (new ones 26) | none | none | `2 Jumadil Akhir 1448`, `令和8年11月21日` |
| A8 | Locale facts: language name, country name, currency code, symbol and name, decimal and grouping separators, metric or not, quotation marks, preferred languages | `NSLocale.h` properties `languageCode`, `regionCode` (iOS 17), `currencyCode`, `currencySymbol`, `usesMetricSystem`, `quotationBeginDelimiter`, `preferredLanguages` | iOS 10 | none | none | `IDR`, `Rp`, `Indonesia` |
| A9 | Number as words, currency in the person's format | `NumberFormatter` (spell-out, currency) | iOS 2 | none | none | `Rp1.500.000` and `one million five hundred thousand` |
| A10 | Unit conversion | `Measurement<UnitLength>.converted(to:)`, `MeasurementFormatter` (`NSMeasurementFormatter.h`) | iOS 10 | none | none | `5 km = 3.1 mi` |
| A11 | A name in a style | `PersonNameComponents` and its formatter: prefix, given, middle, family, suffix, nickname, phonetic (`NSPersonNameComponents.h`) | iOS 9 | none | none | `K. Fang`, `Mr. Fang` |
| A12 | A list with the language's "and" | `ListFormatStyle`, `NSListFormatter.h` | iOS 13 / 15 | none | none | `A, B, and C` for a multi-choice blank |
| A13 | Random value, UUID, counter | `UUID()`, `Int.random`; a counter kept in the App Group | iOS 2 | none | none | `INV-2026-0042`, `a3f1...` |
| A14 | Greeting by hour, age, "days until" | computed from `Calendar` and `DateComponentsFormatter` | iOS 8 | none | none | `Good afternoon`, `34 years`, `12 days left` |
| A15 | Public holidays | **No Foundation API**: `NSCalendar.h` has no holiday member (grep, SDK). Only via the Holidays calendar if the person subscribed to it (EventKit, E5), or a table Cutling ships (GUESS: Indonesia's list changes by decree each year) | n/a | EventKit full access | none | `Today is a public holiday` |

## 3. Inventory B: device, system and the text field (no permission unless noted)

| # | Value | API | Min OS | Permission | Keyboard? | Review/privacy | Example |
|---|---|---|---|---|---|---|---|
| B1 | Selected text, word before the cursor, text after the cursor | `UITextDocumentProxy.selectedText` (iOS 11), `documentContextBeforeInput`, `documentContextAfterInput` (SDK `UIInputViewController.h`) | iOS 11 | none | Yes; this is the keyboard's native input | Shown to the person; fine | wrap the selection: `"Selected words"` |
| B2 | Kind of field | `UITextInputTraits.keyboardType`, `returnKeyType`, `textContentType` with email, URL, phone, name, address, birthdate, date-time, flight number, tracking number, one-time code etc. (SDK `UITextInputTraits.h`) | iOS 10 | none | Yes | none | in an email field, rank the email cutlings first (GUESS) |
| B3 | Language of the document, keyboard language | `documentInputMode`, `UIInputViewController.primaryLanguage` | iOS 10 | none | Yes | none | pick the Indonesian variant |
| B4 | Device kind | `UIDevice.model`, `localizedModel`: "iPhone" (SDK `UIDevice.h`) | iOS 2 | none | Yes | none | `iPhone` |
| B5 | Device name | `UIDevice.name` is a "Synonym for model" since iOS 16; the real name needs `com.apple.developer.device-information.user-assigned-device-name`, granted only for a multi-device feature shown in the UI (doc `bundleresources_entitlements_com.apple.developer.device-information.user-assigned-device-name.json`) | iOS 16 | entitlement, Apple approval | no snippet use qualifies | fingerprinting rule | **not available** |
| B6 | OS version | `UIDevice.systemVersion`, `ProcessInfo.operatingSystemVersionString` | iOS 8 | none | Yes | none | `iOS 27.2` |
| B7 | Marketing model ("iPhone 17 Pro") | no API; `sysctl hw.machine` gives `iPhone18,1`-style ids and a table must map them (UNSURE the sysctl works in the extension sandbox; GUESS table upkeep is the cost) | n/a | none | UNSURE | none | `iPhone 17 Pro` |
| B8 | Battery level and state, Low Power Mode | `UIDevice.batteryLevel` is -1 unless `isBatteryMonitoringEnabled` (SDK, doc `uikit_uidevice_batterylevel.json`); `ProcessInfo.isLowPowerModeEnabled` | iOS 3 / 9 | none | Yes (UNSURE only for the extension process) | none | `Battery 23%, can't call` |
| B9 | Connection type, metered or not | `NWPathMonitor` path: wifi, cellular, wiredEthernet; `isExpensive`, `isConstrained` (SDK `Network.swiftinterface`) | iOS 12 | none (UNSURE) | Yes | none | `on mobile data` |
| B10 | Wi-Fi network name | `NEHotspotNetwork.fetchCurrent` returns SSID only with the `com.apple.developer.networking.wifi-info` entitlement **and** one of: precise-location authorization, a Wi-Fi configured by NEHotspotConfiguration, an active VPN, or an active DNS-settings config (SDK `NEHotspotNetwork.h` lines 66-80). macOS unavailable (CoreWLAN `ssid` needs location, SDK `CWInterface.h`) | iOS 14 | entitlement + location | UNSURE | review justification needed (GUESS) | `Office-5G` |
| B11 | Carrier, SIM country, own phone number | `CTCarrier` is "Deprecated with no replacement" and will return `--` (SDK `CTCarrier.h`); `CTTelephonyNetworkInfo` has radio technology only; no phone-number property in the 13 CoreTelephony headers | n/a | none | n/a | **not available** | |
| B12 | Vendor id | `identifierForVendor` | iOS 6 | none | Yes | fingerprinting; not for text | **do not use** |
| B13 | Thermal state, uptime, memory, core count | `ProcessInfo` | iOS 8-11 | none | Yes | `systemUptime` is on Apple's required-reason list (UNSURE; category text not loaded in `docs/required_reason_api.json`) | useless in a snippet |
| B14 | Mac: account full name and short name | `NSFullUserName()`, `NSUserName()` (SDK `NSPathUtilities.h`); `ProcessInfo.fullUserName` is `API_UNAVAILABLE(ios)` | macOS 10.12 | none | route M | none | `Kenneth Fang` |
| B15 | Mac: computer name | `NSHost` is deprecated and `API_UNAVAILABLE(ios)` (SDK `NSHost.h`); `SCDynamicStoreCopyComputerName` (SystemConfiguration, UNSURE in sandbox) | macOS | none | route M | none | `Kenneth's MacBook Pro` |
| B16 | Mac: battery | `IOPSCopyPowerSourcesInfo` (SDK `IOPowerSources.h`) | macOS | none (UNSURE in sandbox) | route M | none | `Battery 80%, charging` |

## 4. Inventory C: place and weather

| # | Value | API | Min OS | Permission / entitlement | Keyboard? | Main app + snapshot? | Review/privacy | Example |
|---|---|---|---|---|---|---|---|---|
| C1 | Coordinates | `CLLocationManager.requestLocation`, `requestWhenInUseAuthorization` (SDK; macOS 10.15 too); `accuracyAuthorization` gives the reduced-accuracy case | iOS 2 | `NSLocationWhenInUseUsageDescription`; Apple: keyboard may use Location Services only with Full Access and permission (Open Access page) | UNSURE: whether the system prompt can appear from inside a keyboard is not stated by Apple (a Kodeco tutorial says it does, iOS 8 era; not trusted) | Yes, stale | Apple tells keyboards not to use location "in the background" or send it to servers for non-obvious purposes (archive guide `ExtensibilityPG_CustomKeyboard.html` line 713-719) | `-6.2088, 106.8456` |
| C2 | City, neighbourhood, state, postal code, country, street | `MKReverseGeocodingRequest` (iOS 26; `MKAddress.fullAddress`, `shortAddress`; `MKAddressRepresentations.cityName`, `cityWithContext`, `regionName`, `regionCode`); `CLGeocoder` still works but is `API_DEPRECATED("Use MapKit", ios(5.0, 26.0))`; `CLPlacemark` has `locality`, `subLocality`, `administrativeArea`, `postalCode`, `country`, `areasOfInterest` (SDK) | iOS 5 (26) | location + network | needs Full Access for the network call (Apple security guide: keyboard sandbox blocks "services that perform network operations on behalf of a process", saved `docs/security_guide_extensions.txt`) | Yes | App Store privacy label: location | `Senayan, Jakarta` |
| C3 | Time zone of a place | `CLPlacemark.timeZone` (SDK, iOS 9) | iOS 9 | as C2 | as C2 | Yes | none | `Asia/Jayapura` |
| C4 | Link to where I am | compose an Apple Maps URL from C1 (UNSURE of exact URL syntax; not fetched) | n/a | as C1 | as C1 | Yes | outgoing text contains location: the person sees it before sending | `maps.apple.com/?ll=...` |
| C5 | A place I recently visited, a song, a workout, a contact | `JournalingSuggestionsPicker` (SDK outline `journalingsuggestions_outline_iOS27.2.txt`): `Location` (`place`, `city`, `location`, `date`), `Song`, `Podcast`, `Workout`, `Contact`, `Photo`, `MotionActivity` (`steps`), `StateOfMind`, `Reflection`; iPhone only, `macOS` unavailable | iOS 17.2 | entitlement `com.apple.developer.journal.allow` (Journaling Suggestions capability); "You don't need to ask for additional authorization" (doc) | No (a SwiftUI sheet, route P) | Pick once in the app, save the value | the person chooses each item | `Kopi Kenangan, Senayan` |
| C6 | Current weather: temperature, feels-like, condition, UV, humidity, rain chance, wind | `WeatherService.weather(for:including:)` (SDK `WeatherKit.swiftinterface`: `CurrentWeather`, `HourWeather`, `DayWeather` with `precipitationChance`, `uvIndex`, `wind`) | iOS 16, macOS 13 | WeatherKit entitlement `com.apple.developer.weatherkit` on the App ID; Apple Developer Program; 500,000 calls per month included, then US$49.99 for 1 million (Chrome read of `developer.apple.com/weatherkit`, saved `docs/weatherkit_page_chrome_2026-11-21.md`); attribution of the Apple Weather mark and legal link required | Needs location, network (Full Access) and the entitlement on the extension's own App ID (UNSURE) | Yes, with a 30 minute stale cache | attribution is an App Review item (GUESS) | `31 C, light rain` |
| C7 | Sunrise, sunset, moon phase | `SunEvents.sunrise`, `.sunset`, `MoonEvents` (SDK) | iOS 16 | as C6 | as C6 | Yes | as C6 | `Sunset 17:52` |
| C8 | Nearby named place | `MKLocalSearch`, `MKLocalPointsOfInterestRequest` (SDK) | iOS 6 | location + network | as C2 | Yes | none | `Plaza Indonesia` |

## 5. Inventory D: people and contacts

| # | Value | API | Min OS | Permission / entitlement | Keyboard? | Main app + snapshot? | Review/privacy | Example |
|---|---|---|---|---|---|---|---|---|
| D1 | **My own details** (name, nickname, organization, job title, phones, emails, postal addresses, birthday, URLs, social profiles, relations) | iOS: **no Me-card API**: `unifiedMeContactWithKeysToFetch:` is `NS_AVAILABLE(10_11, NA)` in the iOS header (SDK `CNContactStore.h` line 126). macOS: that call, with Contacts permission. iOS route: `CNContactPickerViewController`, where "the user will not be prompted for 'grant permission'" and the app gets "only the user's final selection" (doc `contactsui_cncontactpickerviewcontroller.json`) | iOS 9 / macOS 10.11 | picker: none; macOS store: Contacts permission, sandbox entitlement (UNSURE name) | picker: no (route P); stored result: yes | Yes: the person picks their own card once, Cutling saves "My details" to the App Group | stored in the App Group on the device (no sync, as `FillInMemory`) | `Jl. Sudirman 1, Jakarta`, `+62 812...` |
| D2 | Any contact's fields at use time (name, email, phone, address, birthday, company) | iOS 18+: `CNContactStore` with `CNAuthorizationStatusLimited` (SDK: `NS_ENUM_AVAILABLE_IOS(18_0)`) plus `ContactAccessButton` to add more contacts (doc: "grant ... additional contacts"); or the picker (`predicateForSelectionOfProperty`, `displayedPropertyKeys`, SDK `CNContactPickerViewController.h`) | iOS 9 / 18 | `NSContactsUsageDescription`; Apple says a keyboard with Full Access "can access Location Services and Contacts, with user permission" | UNSURE: how the permission prompt is shown from an extension; GUESS it must first be granted in the main app | Yes: copy only the few chosen contacts ("Saved people") to the App Group | Guideline 5.1.1(iii) says prefer "the out-of-process picker"; 5.1.2 forbids building a contact database or "Select All" | `Sari`, `sari@example.com` |
| D3 | Contact's birthday | `CNContact.birthday`, `nonGregorianBirthday`; or events in the Birthdays calendar (`EKCalendarTypeBirthday`, SDK) | iOS 9 / EventKit 17 | as D2 or EventKit | as D2 | Yes | none beyond D2 | `Happy birthday, Budi (turns 40 today)` |
| D4 | Notes field of a contact | `CNContactNoteKey` needs entitlement `com.apple.developer.contacts.notes` and Apple permission (doc) | iOS 13 | entitlement by request | no | no | avoid | not recommended |
| D5 | The To: field of a message | none; the keyboard proxy does not expose other fields | n/a | n/a | n/a | n/a | n/a | **not available** |

## 6. Inventory E: calendar and reminders (EventKit)

All need `NSCalendarsFullAccessUsageDescription` (iOS 17) and `requestFullAccessToEvents`; "write-only" access cannot read (SDK `EKEventStore.h` lines 84-90, doc `bundleresources_information-property-list_nscalendarsfullaccessusagedescription.json`). Apple's 2014 guide says some frameworks are unavailable to extensions, naming "HealthKit framework and EventKit UI framework" for iOS 8 (`docs/extensibilitypg_apis_unavailable.txt`); in the 27.2 SDK `EKEventEditViewController` and `EKEventViewController` carry `NS_EXTENSION_UNAVAILABLE_IOS` but `EKEventStore` does not (`headers_extension_unavailable_iOS27.2.txt`), so a store read in a keyboard is **UNSURE**, not forbidden. Route S is the safe plan.

| # | Value | API | Example |
|---|---|---|---|
| E1 | Next event: title, start, end, location, organizer, attendees, URL, all-day | `predicateForEvents(withStart:end:calendars:)`; `EKEvent` has `title`, `startDate`, `endDate`, `location`, `organizer`, `attendees`, `URL`, `availability` (SDK) | `Standup at 09:30` |
| E2 | Today's or tomorrow's agenda as a list | same, formatted with `ListFormatStyle` | `09:30 Standup, 13:00 Lunch with Sari` |
| E3 | Free time between events ("I am free Tue 10:00-11:00") | computed from E1, respecting `availability` | `Free Tue 10:00-11:00 or Wed 14:00` |
| E4 | Reminders due today, open count | `predicateForIncompleteReminders(withDueDateStarting:ending:calendars:)`, `EKReminder` (SDK) | `3 reminders due today` |
| E5 | Holidays and birthdays | calendars of type `EKCalendarTypeSubscription` and `EKCalendarTypeBirthday` (SDK `EKTypes.h`); exists only if the person subscribed (UNSURE how Apple's holiday calendar appears per country) | `Tomorrow is Independence Day` |
| E6 | A date written in the message | `DataDetector.calendarEvent` (F3), not EventKit | `Friday 3 Dec, 15:00` |

Privacy: event titles can be sensitive; insert only on use, never save to disk beyond the day's snapshot (GUESS). Where: S on iPhone (snapshot refreshed when the app opens, so "next event" goes stale in hours) and M on Mac (live read in the Mac app, no extension).

## 7. Inventory F: clipboard and input data (parsing, no new permission beyond the paste prompt)

The clipboard rule first. Since iOS 14 "the system notifies the user when an app gets general pasteboard content that originates in a different app without user intent"; the pattern API reads "without notifying the user" (doc `uikit_uipasteboard.json`); iOS 16+ asks before programmatic paste, `UIPasteControl` pastes without a prompt (doc `uikit_uipastecontrol.json`). On macOS 15.4+ `NSPasteboard.accessBehavior` is `default`, `ask`, `alwaysAllow` or `alwaysDeny` and the user sets it per app in System Settings (SDK `NSPasteboard.h` lines 52-70). `cutling-pains.md` row 216 already notes the keyboard side.

| # | Value | API | Min OS | Permission | Keyboard? | Example |
|---|---|---|---|---|---|---|
| F1 | What kind of thing is on the clipboard, without reading it | `UIPasteboard.detectPatterns(for:)` with `probableWebURL`, `probableWebSearch`, `number`, `link`, `phoneNumber`, `emailAddress`, `postalAddress`, `calendarEvent`, `shipmentTrackingNumber`, `flightNumber`, `moneyAmount` (SDK `UIPasteboard.h` lines 19-45) | iOS 14 / 15 | none, no alert | Yes with Full Access (UNSURE whether the keyboard can read the pasteboard at all without it; `cutling-pains.md` says reading needs Full Access) | enables a `Paste email` chip only when an email is there |
| F2 | Just the email, phone, link or number from the clipboard | `detectValues(for:)`, "reading the contents if it finds a match" (SDK/doc); UNSURE whether a match raises the paste alert | iOS 14 | maybe the paste prompt | as F1 | `sari@example.com` out of a pasted signature |
| F3 | Structured parts of any text: link, email, phone, postal address (street, city, state, postal code, region code), calendar event (start, end, time zones, all-day), money amount (currency, `Decimal`), measurement with possible units, flight (airline, number), shipment (carrier, number, tracking URL), payment id (UPI) | `DataDetector` and `String.dataDetectorMatches(_:options:)`; options carry document date, time zone, language and region (SDK `DataDetection.swiftinterface`, `datadetection_swiftinterface_outline_iOS27.2.txt`); older `NSDataDetector` since iOS 4, with `NSTextCheckingTypeDate`, `Address`, `Link`, `PhoneNumber`, `TransitInformation` (SDK) | iOS 26 (NSDataDetector 4) | none; on-device; 3.7 ms for a 120-character message on a Mac (`smarter-typing.md`) | Yes (no model memory) | `{clipboard:amount}` becomes `Rp 1.500.000` |
| F4 | Language of a text | `NLLanguageRecognizer.dominantLanguage` (SDK `NLLanguageRecognizer.h`, iOS 12) | iOS 12 | none | Yes (memory UNSURE; `smarter-typing.md` measured NaturalLanguage costs) | `id` |
| F5 | Words typed in another language | `TranslationSession.translate(_:)` (iOS 18); non-UI use via `init(installedSource:target:)` (iOS 26); `LanguageAvailability`; all on device (SDK `Translation.swiftinterface`; doc `docs/translation_translationsession.json`, which says translation runs on the device per the WWDC24 session 10117 text: UNSURE, that session page was not fetched) | iOS 18 / 26 | none, but the language pack is downloaded by a system sheet shown from a SwiftUI view | UNSURE from a keyboard | route S/M: translate a blank into Spanish | `Terima kasih` into `Thank you` |
| F6 | Text on an image on the clipboard | `VNRecognizeTextRequest` (iOS 13), `RecognizeTextRequest` (iOS 18), `RecognizeDocumentsRequest` (iOS 26), `DetectBarcodesRequest` for QR payloads (SDK) | iOS 13 / 18 / 26 | none | UNSURE: model memory under 77 MB; GUESS use `.fast` level or skip | main app and Mac: `INV/2026/118` out of a screenshot |
| F7 | A language-model answer (rewrite, summarize the clipboard) | FoundationModels `SystemLanguageModel` (iOS 26), PrivateCloudCompute model with quota in the 27.2 SDK; not marked extension-unavailable (SDK) | iOS 26 | Apple Intelligence on | UNSURE, 2 s warm and 16 s cold on a Mac in `smarter-typing.md`; not loaded into the caller's memory per Apple DTS | one-tap, main app and Mac first |
| F8 | Latest photo or screenshot as an image cutling | `PHAsset.fetchAssets` with `fetchLimit` (SDK `PHFetchOptions.h`) after `requestAuthorization(for: .readWrite)`; limited access exists (`PHAuthorizationStatusLimited`, iOS 14); `PHPickerViewController` needs no library access and works for single picks (doc) | iOS 14 | Photos read access | UNSURE; images cost memory (`keyboard-memory-limits.md`) | route P in the main app |
| F9 | Title of a copied link | `LPMetadataProvider` (LinkPresentation, iOS 13) | iOS 13 | network | needs Full Access | `Cutling on the App Store` (UNSURE not read in SDK) |

## 8. Inventory G to K: media, health, state, other apps, Mac-only

| # | Value | API | Min OS | Permission | Where it runs | Review/privacy | Example |
|---|---|---|---|---|---|---|---|
| G1 | Now playing in the Music app: title, artist, album, duration, last played date | `MPMusicPlayerController.systemMusicPlayer.nowPlayingItem`, `MPMediaItemPropertyTitle`, `...Artist`, `...AlbumTitle`, `...LastPlayedDate` (SDK); `MPMediaLibrary.requestAuthorization`; `NSAppleMusicUsageDescription`. `MPMusicPlayerController` is `API_UNAVAILABLE(watchos, macos)` | iOS 9.3 | Media & Apple Music permission | iPhone: S or K (UNSURE keyboard); not Mac | Reads only Apple's Music app, not Spotify or YouTube (GUESS from API shape) | `Now playing: Song - Artist` |
| G2 | Same via MusicKit; recently played | `SystemMusicPlayer` queue's `currentEntry` (iOS 15, **macOS unavailable**, SDK); `MusicRecentlyPlayedRequest` (iOS 16, macOS 13) | iOS 15 | `MusicAuthorization`; catalog items need an Apple Music subscription (UNSURE) | iPhone S | none | `Recently played: Album` |
| G3 | Now playing from any app (Spotify, podcasts) | `MPNowPlayingInfoCenter.nowPlayingInfo` publishes **your own** info; the new `NowPlaying` framework (iOS 27) is also for publishing and is `iOSApplicationExtension, unavailable` (SDK) | n/a | n/a | **not available** | the private MediaRemote route is not for the store (GUESS) | |
| G4 | Mac: what Music or Spotify is playing | AppleScript or ScriptingBridge with Automation permission, `NSAppleEventsUsageDescription` (doc); sandbox entitlement for the target app UNSURE (doc page for `com.apple.security.scripting-targets` did not load) | macOS | Automation prompt per app | M | direct-download build likely fine; Mac App Store UNSURE | `Now playing: ...` |
| H1 | Steps today | `CMPedometer.queryPedometerData(from:to:)` (SDK; iOS 8; macOS 10.15 class available), `NSMotionUsageDescription` (doc); or `HKStatisticsQuery` on step count with `requestAuthorization` | iOS 8 | Motion or Health permission | iPhone S (Health UNSURE from an extension: the header has `handleAuthorizationForExtension` "When an app extension calls requestAuthorization... the parent application" prompts, so extensions can ask, SDK line 117-128; the 2014 guide says unavailable) | Guideline 5.1.3 limits health data to health use, not marketing (guidelines text) | `8,420 steps today` |
| H2 | Activity: walking, running, driving, cycling | `CMMotionActivityManager` (SDK; `authorizationStatus` iOS 11, macOS unavailable) | iOS 7 | Motion | iPhone S | none | auto "I'm driving, I'll reply later" (GUESS) |
| H3 | Sleep, heart rate, mood | HealthKit | iOS 8 | per-type; the person may grant "limited access restricted to a recent window of data" (doc `healthkit_hkhealthstore.json`) | S | sensitive in outgoing text: GUESS do not build | |
| I1 | Focus on or off | `INFocusStatusCenter.default.focusStatus.isFocused`, `NSNumber?`, `requestAuthorization`, `NSFocusStatusUsageDescription` (SDK `INFocusStatus.h`; doc) | iOS 15, macOS 12 | prompt in the main app | K only if the extension can read it (UNSURE); the answer changes by the minute so a snapshot is useless | the page says it is meant for "other people in your communication service" | `Focus: on`; **the name of the Focus is not exposed** (header has only `isFocused`) |
| J1 | Result of any Shortcut | `shortcuts://x-callback-url/run-shortcut?name=...&input=text&text=...&x-success=...` appends "a parameter named result ... the textual output of the shortcut" (Apple Support pages saved in `docs/`); no `runShortcut` symbol anywhere in the iOS 27.2 SDK headers (grep) | UNSURE (page undated) | none | P in the app (switches apps; the keyboard may not launch apps, 4.4.1); Mac UNSURE | none | whatever the shortcut returns: a weather line, a Focus name, a HomeKit reading |
| J2 | Let Shortcuts push values in | Cutling already has Get Cutling Text, which leaves blanks as written; a `values` parameter would let any shortcut fill them (GUESS; design, no API risk) | iOS 16 | none | S/K | none | a shortcut sends `{Weather}` |
| J3 | Other apps' data via Spotlight, Wallet, StoreKit, Screen Time, SensorKit | CoreSpotlight indexes **your** items only; PassKit lists only passes your team issued (UNSURE); FinanceKit is entitlement-restricted (UNSURE); SensorKit and Screen Time are research or opaque-token APIs (UNSURE; I did not open them) | n/a | n/a | **not recommended** | | |
| K1 | Mac: frontmost app name and bundle id | `NSWorkspace.frontmostApplication`, `NSRunningApplication.localizedName`, `bundleIdentifier` (SDK); Cutling already stores it (`Cutling/Mac/PickerPanel.swift:148`) | macOS 10.7 | none | M | none | `Slack` |
| K2 | Mac: selected text in that app | Accessibility `kAXSelectedTextAttribute` (SDK `AXAttributeConstants.h` line 80); Cutling already holds the Accessibility permission for direct paste (`Cutling/Mac/PasteService.swift:28`) | macOS | Accessibility (already asked) | M | apps that do not expose AX text (some Electron, terminals) return nothing: UNSURE | `{selection}` |
| K3 | Mac: window title, document path | `kAXTitleAttribute`, `kAXDocumentAttribute` (header line 168); `kCGWindowName` in `CGWindow.h` may need Screen Recording for other apps' windows (UNSURE; header does not say) | macOS | Accessibility | M | none | `Invoice 118.pdf` |
| K4 | Mac: browser URL and tab title | three routes: AX `kAXURLAttribute` (header line 173; which browsers fill it is UNSURE); AppleScript to Safari or Chrome with Automation; or a Safari web extension whose background script sends `browser.runtime.sendNativeMessage` to the app extension (needs `nativeMessaging` in the manifest, doc `safariservices_messaging-between-the-app-and-javascript-in-a-safari-web-extension.json`; the user must enable the extension) | macOS | Accessibility, Automation or the extension's site permission | M | Safari extensions "should not claim access to more websites than strictly necessary" (guidelines) | `https://example.com/pricing` |
| K5 | Mac: Wi-Fi name, location, weather, contacts, calendar, Me card, clipboard | same APIs as above; on Mac `CLLocationManager.requestWhenInUseAuthorization` is macOS 10.15, `unifiedMeContact` exists, EventKit and WeatherKit are macOS 13 and 14 | macOS 10.15+ | as iPhone | M (live, no snapshot needed) | pasteboard prompt on 15.4+ | |

## 9. What does not exist or is not allowed (so nobody plans it)

- The person's own phone number: no property in the 13 CoreTelephony headers (SDK).
- Me card on iOS: not available (D1). Use the picker once.
- Owner name of the device on iOS: `UIDevice.name` is generic (B5).
- Name of the active Focus: only a yes/no (I1).
- Carrier name: deprecated, returns `--` (B11).
- Wi-Fi name without the entitlement and one of four conditions (B10).
- Now playing from Spotify or podcasts (G3).
- Calling a Shortcut from the keyboard, or opening any app from it (4.4.1, J1).
- Microphone input or dictation of a blank: Apple's Open Access page lists "No access to microphone and speaker" without Full Access, and the 2014 guide says keyboards cannot record (`fill-ins-keyboard-apis.md` row 1).
- Reading another field of the host app, the host app's name or URL from the keyboard: the proxy has only the properties in B1 to B3 (SDK).
- Password-field text: the system does not use a custom keyboard for secure fields (Apple security guide, saved).
- Public holidays: no Foundation API (A15).

## 10. The 25 most useful new kinds, ranked

Ranking is GUESS: how often a person writing snippets (replies, signatures, invoices, customer messages) would use it, divided by the cost and risk of building it. "Where" uses the routes from section 1.

**Group 1. Free, instant, no permission (build first)**

| Rank | Kind | Where it runs |
|---|---|---|
| 1 | Time-zone name and offset, and a second zone chosen once (A1, A2) | iPhone keyboard, iPad, Mac (K) |
| 2 | Relative dates and phrases: "in 3 days", next business day, week number (A3, A4, A6) | K, Mac |
| 3 | Selected text and word before the cursor as a value, `{selection}` (B1) | iPhone keyboard (K); Mac via Accessibility (K2) |
| 4 | Greeting by hour, "days until", age (A14) | K |
| 5 | Locale facts: currency code and symbol, country name, language name (A8) | K |
| 6 | Number as words and amounts in the person's format (A9) | K |
| 7 | Counter and random or ID values, `INV-0042` (A13) | K (counter stored in the App Group; writing from the keyboard needs Full Access, so GUESS count in the app or via the shared file only when Full Access is on) |
| 8 | Other calendars: Hijri, Buddhist, Japanese era and the iOS 26 regional ones (A7) | K, Mac |

**Group 2. Parse what is already on the clipboard (no new permission beyond the paste prompt)**

| Rank | Kind | Where it runs |
|---|---|---|
| 9 | Typed clipboard parts: email, phone, link, amount, address, tracking number, date (F1 to F3) | iPhone keyboard with Full Access (UNSURE), Mac, app |
| 10 | Language of the clipboard or the typed text (F4), to choose a variant | K |
| 11 | Text from an image on the clipboard (F6) | Mac and iPhone main app; keyboard UNSURE on memory |

**Group 3. About me, picked once (route P/S, no store-wide permission)**

| Rank | Kind | Where it runs |
|---|---|---|
| 12 | My details: name, email, phone, address, company, job title from my own contact card (D1) | iPhone: pick once in the app, saved to the App Group; Mac: live Me card |
| 13 | Saved people: a few chosen contacts' name, email, phone, birthday (D2, D3) | S from the app, keyboard reads the list |
| 14 | A place or song or workout I chose from Journaling Suggestions (C5) | iPhone main app only; saved value |

**Group 4. Calendar and reminders (permission, snapshot on iPhone)**

| Rank | Kind | Where it runs |
|---|---|---|
| 15 | Next event: title, time, link, attendees (E1) | Mac live; iPhone snapshot (stale) |
| 16 | Free time slots for a meeting reply (E3) | Mac live; iPhone snapshot |
| 17 | Today's agenda list (E2) and reminders due (E4) | as above |
| 18 | Holiday or birthday today (E5) | as above |

**Group 5. Place and weather (permission, network; keep optional)**

| Rank | Kind | Where it runs |
|---|---|---|
| 19 | City or neighbourhood now, time zone of the place (C2, C3) | Mac live; iPhone main app snapshot, keyboard only with Full Access (UNSURE) |
| 20 | Weather now, sunrise and sunset (C6, C7), with the required Apple Weather attribution | Mac live; iPhone snapshot |

**Group 6. Mac-only context (live)**

| Rank | Kind | Where it runs |
|---|---|---|
| 21 | Frontmost app name (K1) and window title (K3) | Mac |
| 22 | Browser URL and tab title (K4) | Mac (Safari extension or AX or AppleScript) |
| 23 | Now playing in Music or Spotify (G4) | Mac, AppleScript with Automation (UNSURE for the Mac App Store build) |

**Group 7. Escape hatches and AI (one design each)**

| Rank | Kind | Where it runs |
|---|---|---|
| 24 | Value from a Shortcut: Cutling's intent accepts values from any shortcut, or the app opens a shortcut and takes its `result` (J1, J2) | iPhone and Mac main app; never the keyboard |
| 25 | On-device translate or rewrite of a blank (F5, F7) | Mac and main app first; keyboard only after a device memory test |

Not ranked because they cost more than they give: steps and activity (H1, H2: 5.1.3 limits, Motion or Health prompt, stale), Wi-Fi name (B10), Focus state (I1), battery (B8), network type (B9), photos (F8), now playing on iPhone (G1: Music app only).

## 11. What must be tested on a device before anything is promised

1. Whether a keyboard with Full Access can show the Location, Contacts, Calendar, Motion, Health or Photos permission prompt, or only read a grant made in the main app (Apple does not say; C1, D2, E, H1).
2. Whether `UIPasteboard.detectValues` raises the paste alert (F2) and whether the keyboard can read the pasteboard without Full Access.
3. Memory of `NLLanguageRecognizer`, `DataDetector`, `TranslationSession(installedSource:)` and Vision text recognition inside the keyboard against the 77 MB ceiling.
4. Whether `INFocusStatusCenter` and `UIDevice.batteryLevel` return real values in the extension process.
5. Which Mac apps return text for `kAXSelectedTextAttribute` and a URL for `kAXURLAttribute` (K2, K4), and whether the Mac App Store build may use Apple Events to Music or Safari.
6. `CNContactPickerViewController` presented from the keyboard (P in the keyboard) versus only from the app.

## 12. Sources

All saved in `fill-ins-apple-apis-sources/`; the table is `fill-ins-apple-apis-sources/notes.md`. SDK means read in the Xcode 27.2 SDKs on this Mac. Apple's current page for `Foundation`, `CoreLocation`, `EventKit` and others was not fetched beyond the pages named in the notes: header text was the primary source there. Domain guides (offline ledger sync, ERP, Indonesia business, integrity) do not cover this subject; no guide rows to report.
