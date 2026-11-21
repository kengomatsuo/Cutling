# Sources for ../fill-ins-apple-apis.md (fetched or read 2026-11-21)

| # | URL or SDK path | saved file | what to take |
|---|---|---|---|
| 1 | iPhoneOS27.2.sdk UIKit UIDevice.h, Foundation NSProcessInfo.h | `headers_uikit_processinfo_iOS27.2.txt` | UIDevice.name is a synonym for model; battery is -1 unless monitoring is on; ProcessInfo thermal, low power, userName macOS-only |
| 2 | iPhoneOS27.2.sdk Foundation NSCalendar.h, NSLocale.h, NSPersonNameComponents.h | `headers_foundation_iOS27.2.txt` | Calendar identifiers incl. iOS 26 regional ones, quarter "not recommended", no holiday API, locale properties |
| 3 | iPhoneOS27.2.sdk CoreLocation CLGeocoder.h, CLPlacemark.h, MapKit MKReverseGeocodingRequest.h, MKAddressRepresentations.h | `headers_corelocation_mapkit_iOS27.2.txt` | CLGeocoder deprecated in 26, MKReverseGeocodingRequest iOS 26, placemark fields and timeZone |
| 4 | iPhoneOS27.2.sdk Contacts, ContactsUI headers | `headers_contacts_iOS27.2.txt` | unifiedMeContact is NA on iOS (macOS only), limited access iOS 18, picker predicates, contact keys |
| 5 | iPhoneOS27.2.sdk MediaPlayer, NowPlaying swiftinterface | `headers_media_iOS27.2.txt` | MPMusicPlayerController macOS-unavailable; NowPlaying framework is publish-only and extension-unavailable |
| 6 | iPhoneOS27.2 and MacOSX27.2 MusicKit swiftinterface | `headers_musickit_iOS27.2.txt` | SystemMusicPlayer macOS-unavailable, MusicRecentlyPlayedRequest iOS 16 |
| 7 | iPhoneOS27.2.sdk WeatherKit, Intents INFocusStatus*, NetworkExtension NEHotspotNetwork.h, Network, CoreTelephony | `headers_weather_focus_network_iOS27.2.txt` | WeatherKit types, isFocused only, Wi-Fi SSID four conditions, CTCarrier deprecated |
| 8 | iPhoneOS27.2.sdk Translation, NaturalLanguage, Vision, FoundationModels | `headers_translation_nl_vision_fm_iOS27.2.txt` | TranslationSession iOS 18 and installedSource init iOS 26, RecognizeDocumentsRequest iOS 26, FoundationModels iOS 26 |
| 9 | iPhoneOS27.2.sdk HealthKit, CoreMotion, Photos, UIPasteboard | `headers_health_motion_photos_pasteboard_iOS27.2.txt` | handleAuthorizationForExtension, pedometer, photo access levels, pasteboard detection patterns |
| 10 | iPhoneOS27.2.sdk DataDetection swiftinterface | `datadetection_swiftinterface_outline_iOS27.2.txt` | DataDetector match types and fields, iOS 26 |
| 11 | iPhoneOS27.2.sdk JournalingSuggestions swiftinterface | `journalingsuggestions_outline_iOS27.2.txt` | item types, macOS unavailable, iOS 17.2 |
| 12 | MacOSX27.2.sdk AppKit NSWorkspace, NSRunningApplication, HIServices AX, CoreWLAN, IOKit, NSHost, CGWindow | `headers_macos_appkit_ax_MacOSX27.2.txt` | frontmost app, AX attribute constants, CoreWLAN needs location |
| 13 | MacOSX27.2.sdk NSPasteboard.h, NSPathUtilities.h | `headers_macos_ax_pasteboard_MacOSX27.2.txt` | accessBehavior ask/alwaysAllow/alwaysDeny, NSFullUserName |
| 14 | MacOSX27.2.sdk NSHost.h, CGWindow.h, IOPowerSources.h | `headers_macos_host_cgwindow_iops_MacOSX27.2.txt` | NSHost deprecated and iOS-unavailable, IOPS call |
| 15 | iPhoneOS27.2.sdk UIInputViewController.h, UITextInputTraits.h | `headers_uikit_textdocumentproxy_contenttypes_iOS27.2.txt` | proxy properties and the list of text content types |
| 16 | iPhoneOS27.2.sdk extension-unavailable marker scan | `headers_extension_unavailable_iOS27.2.txt` | only EventKitUI, HealthKit auth helper, INUserContext carry markers; the stores do not |
| 17 | iPhoneOS27.2.sdk grep for new iOS 27 API in 25 frameworks | `sdk_new_in_27_scan_iOS27.2.txt` | iOS 27 adds nothing relevant to fill-ins |
| 18 | https://developer.apple.com/weatherkit/ (Claude in Chrome) | `docs/weatherkit_page_chrome_2026-11-21.md` | 500,000 calls per month included, tiers, attribution |
| 19 | https://developer.apple.com/app-store/review/guidelines/ | `docs/developer_apple_com_app-store_review_guidelines_.txt` | 4.4.1 keyboard rules, 5.1.1(iii), 5.1.2, 5.1.3 |
| 20 | https://support.apple.com/guide/shortcuts/run-a-shortcut-from-a-url-apd624386f42/ios and the x-callback page | `docs/support_apple_com_guide_shortcuts_use-x-callback-url-apdcd7f20a6f_ios.txt` | run-shortcut URL, x-success appends result |
| 21 | https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/ExtensionOverview.html | `docs/extensibilitypg_apis_unavailable.txt` | 2014 text: HealthKit and EventKit UI unavailable to extensions |
| 22 | https://support.apple.com/guide/security/secabd3504cd/web | `docs/security_guide_extensions.txt` | keyboard sandbox blocks network and exfiltration APIs |
| 23 | Apple doc JSON: UIDevice.name, device-name entitlement, Wi-Fi entitlement, WeatherKit entitlement, contacts notes entitlement, journal entitlement | `docs/bundleresources_entitlements_com.apple.developer.device-information.user-assigned-device-name.json` | entitlement criteria (others sit beside it in docs/) |
| 24 | Apple doc JSON: CNContactPickerViewController, ContactAccessButton | `docs/contactsui_cncontactpickerviewcontroller.json` | picker needs no authorization; access button iOS 18 |
| 25 | Apple doc JSON: UIPasteboard, UIPasteControl | `docs/uikit_uipasteboard.json` | pattern detection without notifying the user; iOS 14 notification, iOS 16 prompt |
| 26 | Apple doc JSON: DataDetector, Translation, HKHealthStore, CMPedometer, JournalingSuggestions, INFocusStatus | `docs/datadetection_datadetector.json` | availability and one-line purpose of each |
| 27 | Apple doc JSON: Safari web extension messaging, NSAppleEventsUsageDescription | `docs/safariservices_messaging-between-the-app-and-javascript-in-a-safari-web-extension.json` | nativeMessaging route for a browser URL on Mac |
| 28 | https://developer.apple.com/wwdc26/guides/highlights/ | `docs/wwdc26_highlights.txt` | WWDC26 session list: Foundation Models, App Intents, Core AI; no session on contacts, location or keyboards |
| 29 | https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api | `docs/required_reason_api.json` | page loaded but its category text is in sub-pages; UNSURE of the list |
| 30 | https://developer.apple.com/forums (search for keyboard + location prompt) | gated: WebSearch returned no Apple thread that states whether a keyboard can show the location prompt |
