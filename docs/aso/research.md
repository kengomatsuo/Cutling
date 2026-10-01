# Cutling App Store optimization research, 2026-10-01

Every claim below links the page it came from; all pages were fetched on 2026-10-01. Measurements are in [keywords.md](keywords.md) and [data/](data/), the per-locale proposal in [proposal.json](proposal.json), and the custom product pages in [cpp.json](cpp.json). The full source list is [sources.md](sources.md).

## Top findings

1. **en-GB is the English listing almost everywhere.** Apple's localization table lists English (U.K.) in 172 of 175 storefronts; only the United States, Canada and Japan go without it. The US indexes en-US with nine non-English locales, Japan indexes ja with en-US, and Canada indexes only en-CA and fr-CA ([Apple, App Store localizations](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations)). So en-GB carries the English terms in Germany, Brazil, Korea, India and the rest, and en-AU is the only English variant that shares a storefront with another (Australia: en-AU with en-GB). en-US and en-GB never compete, so they need different emphasis, not different words.
2. **Ten locale folders reach nobody.** bg, bn-IN, en-IN, et, fa, fil, lt, lv, sr and sw appear in no storefront in Apple's table, and App Store Connect rejects them for custom product pages as "not available in your app" (read back 2026-10-01). Their copy was refreshed for consistency, but their keyword fields cannot affect search.
3. **Search inputs are name, subtitle, keywords and primary category, plus downloads and ratings; promotional text is not one** ([Apple, Search](https://developer.apple.com/app-store/search/)). The keyword field limit is "100 characters" on that page and "100 bytes" in App Store Connect's reference ([Platform version information](https://developer.apple.com/help/app-store-connect/reference/platform-version-information)); the live Japanese field held 212 bytes, so the store enforces characters. The proposal keeps every field at 100 bytes or less to satisfy both.
4. **Cutling already ranks where its words are, and nowhere else.** In the live store search (top 250), the best positions are KR 정형문 #6, HR lijepljenje #7, MX "portapapeles teclado" #11, US "clipboard keyboard" #12, CN 剪贴板输入法 #12, and "canned responses" #16 to #25 in nine storefronts ([keywords.md](keywords.md)). 224 of about 270 words in the 1.5.4 keyword fields returned nothing relevant; generic single words (address, quick, template, 保存) were the bulk.
5. **The open terms are local and small.** Textbausteine (DE), frases prontas (BR), respuestas rápidas (ES/MX), risposte rapide (IT), 상용구 and 자주쓰는문구 (KR), 定型文 (JP), 常用语 (CN), hızlı yanıt (TR) and "text expander" in English return results led by apps with under 20 ratings ([competitors.md](#competitors), [keywords.md](keywords.md)). English "copy paste" and "custom keyboard" are closed to a new app (top-10 median ratings 6,333 and 13,486 in the US).
6. **Nobody's listing sells saved personal details.** No competitor in 17 storefronts leads with addresses, IDs or bank numbers; only one (Clipboard - Paste Keyboard, 44,286 ratings in the US) shows them in a preview video. That gap became the "Personal details" custom product page.
7. **Custom product pages can now rank organically.** Each of up to 70 pages can be assigned keywords, taken from the latest approved version's keyword field, with each combination unique to one page ([Apple, Custom product pages](https://developer.apple.com/app-store/custom-product-pages/)). The API exposes this as `searchKeywords` on a page localization; a page needs review and a deep link applies on iOS 18 and later.
8. **Screenshot text as a ranking input is disputed.** Appfigures, SplitMetrics and AppTweak report it; Phiture (March 2026) reports Apple denied it ([practitioner notes](#practitioners)). Caption 1 therefore repeats the name's search words for conversion, and no keyword lives only in a caption.
9. **Change keywords once, then wait.** Practitioners report ranks moving within 12 to 48 hours and settling over 3 to 6 weeks; one Indie Hackers report saw a 66% organic drop after a full rewrite ([practitioner notes](#practitioners)). This release changes most fields at once because 1.5.4's fields ranked for almost nothing; the probes in [data/](data/README.md) re-measure at 48 hours and at 3 to 4 weeks.
10. **The old screenshots were broken in several scripts.** frameit draws captions with ImageMagick, which here has no text shaping: the live Hindi frames had no caption, Arabic letters were unjoined and left to right, Thai showed dotted circles. The new pipeline draws captions with CoreText (`fastlane/compose`).
11. **Cutling already asks for ratings correctly.** `MainContentView.swift` calls SwiftUI `requestReview` after five keyboard pastes, once per version, when the user returns from a sheet or a snippet; never at launch or from a button, as Apple's guidance asks. On Mac the counter never moved, because Mac has no keyboard; copies now count. Verified in a Debug build on the iOS 27 Simulator: [data/review-prompt-simulator.png](data/review-prompt-simulator.png).

## Apple: search inputs, keyword rules, localizations, screenshots, ratings
Every claim below was read from the linked Apple page on 2026-10-01. Quotes are verbatim and short. Where Apple says nothing, the section says so.

### 1. Which fields Apple uses for search

- Ranking inputs: "text relevance (matches for your app's title, subtitle, keywords, and primary category), as well as user behavior (downloads, ratings and reviews, and more)". https://developer.apple.com/app-store/search/
- Categories: "Your primary category and optional secondary category are indexed by our search algorithm." https://developer.apple.com/app-store/search/
- Developer/company name: the keyword field entry in App Store Connect says "Your app is searchable by app name and company name, so you shouldn't duplicate these values in the keyword list." https://developer.apple.com/help/app-store-connect/reference/platform-version-information
- Promotional text is not indexed: "promotional text doesn't affect your app's search ranking so it should not be used to display keywords." https://developer.apple.com/app-store/search/ (same sentence on https://developer.apple.com/app-store/product-page/)
- Description: Apple lists no description indexing for in-store search. The ASC description field says it "will be used for web engine search results once you release your app" (web search engines, not App Store search). https://developer.apple.com/help/app-store-connect/reference/platform-version-information Product-page guidance: "Don't add unnecessary keywords to your description in an attempt to improve search results." https://developer.apple.com/app-store/product-page/
- Ratings: "Ratings and reviews appear on your product page and in search results, and can influence how your app ranks in App Store search." https://developer.apple.com/app-store/search/
- In-app purchase names: Not confirmed as an indexed field. Apple's search page says only "Promoted Apple In-App Purchases appear in App Store search results", and the product page says IAP names are limited to 35 characters and descriptions to 55. Neither page says IAP text feeds ranking for the parent app. Tried: search and product-page pages, platform-version page.
- Custom product pages can be assigned keywords: "Enable your custom product pages to appear in search results for those selected keywords". https://developer.apple.com/app-store/search/
- Per-version vs shared: Keywords, description, promotional text, screenshots and What's New sit on "Platform version information", "the set of properties of an app version specific to each platform". So the macOS version keeps its own keyword string. https://developer.apple.com/help/app-store-connect/reference/platform-version-information

### 2. Keyword field format

- Apple uses two different words. The marketing pages say characters: "Keywords are limited to 100 characters total, with terms separated by commas and no spaces." https://developer.apple.com/app-store/search/ and https://developer.apple.com/app-store/product-page/
- The App Store Connect reference says bytes: "You can provide up to 100 bytes of content." https://developer.apple.com/help/app-store-connect/reference/platform-version-information
- Apple does not reconcile the two. For ASCII text they are equal. For Japanese (3 bytes per character in UTF-8) they are not. The live Japanese string for this app is 212 bytes and 98 characters, which exceeds 100 bytes, so ASC is evidently enforcing the character count there. Record: Apple's text says both; the live field behaviour matches "characters".
- Separators: "terms separated by commas and no spaces. You can use spaces to separate words within keyword phrases. For example: Property,House,Real Estate." https://developer.apple.com/app-store/search/
- Minimum term length: "each greater than two characters". https://developer.apple.com/help/app-store-connect/reference/platform-version-information
- Plurals: avoid "Plurals of words you've already included, such as 'climbs' and 'climb,' as these are considered duplicates." https://developer.apple.com/app-store/search/
- Repeating name, subtitle, category: "Don't repeat any words included in your app name, subtitle, or category." https://developer.apple.com/app-store/search/ (the product-page version says to avoid "Names of categories or the word 'app'").
- Filler and generic words: avoid "Generic terms that are too broad ... such as 'app' or 'game'" and "Filler words like 'the' and 'to'". https://developer.apple.com/app-store/search/
- Special characters: avoid "# or @" "unless they're part of your brand identity". https://developer.apple.com/app-store/search/
- Rejection reasons: "Improper use of keywords is a common reason for App Store rejections." Do not include "Unauthorized use of trademarked terms, celebrity names, or other protected words and phrases", "Terms that are not relevant to the app", "Competing app names". https://developer.apple.com/app-store/search/
- Other apps and companies: "Names of other apps or companies aren't allowed." https://developer.apple.com/help/app-store-connect/reference/platform-version-information
- The app's own name in the keyword list: ASC says not to duplicate the app name and company name there. Same page as above.

### 3. Name, subtitle, promotional text

- Name: "The name must be at least two characters and no more than 30 characters." https://developer.apple.com/help/app-store-connect/reference/app-information
- Subtitle: "This can't be longer than 30 characters." https://developer.apple.com/help/app-store-connect/reference/app-information (product page: "A subtitle can be up to 30 characters long", https://developer.apple.com/app-store/product-page/)
- Where they live: App information is "the properties that are shared across the platforms added to an app", and Name and Subtitle are on that page, so they are shared between iOS and macOS, not per version. They are localized. https://developer.apple.com/help/app-store-connect/reference/app-information
- Name edit rule: "You can edit it until you submit the app to App Review. Later, you can change the name when you create a new version or the status of the app version permits editing this property." https://developer.apple.com/help/app-store-connect/reference/app-information
- Subtitle edit rule: "You can update your subtitle when submitting a new version of your app". https://developer.apple.com/app-store/product-page/ The properties table at https://developer.apple.com/help/app-store-connect/reference/app-information/required-localizable-and-editable-properties marks Name and Subtitle as Required/Localized with an empty Editable cell, whereas the "editable at any time" rows (for example Copyright) carry an Editable mark. So neither is editable without a new version.
- Promotional text: "up to 170 characters long. You can update promotional text at any time without having to submit a new version of your app." https://developer.apple.com/app-store/product-page/ The ASC page agrees: "without requiring an updated submission". https://developer.apple.com/help/app-store-connect/reference/platform-version-information
- Not confirmed: whether keywords and description are editable without a new version. The editable-properties table I could parse had no Keywords or Promotional Text rows. Tried: the HTML table in Chrome and curl text. Product page ties only promotional text to "any time".
- Other limits seen: description 4000 characters; What's New 4000 characters. https://developer.apple.com/help/app-store-connect/reference/platform-version-information

### 4. App Review Guidelines on metadata

All from https://developer.apple.com/app-store/review/guidelines/

- 2.3 intro: metadata including "privacy information, your app description, screenshots, and previews accurately reflect the app's core experience".
- 2.3.7: "Choose a unique app name, assign keywords that accurately describe your app, and don't try to pack any of your metadata with trademarked terms, popular app names, pricing information, or other irrelevant phrases just to game the system. App names must be limited to 30 characters." It continues: names, subtitles, screenshots and previews "should not include prices, terms, or descriptions that are not specific to the metadata type"; subtitles "should not include inappropriate content, reference other apps, or make unverifiable product claims"; "Apple may modify inappropriate keywords at any time".
- 2.3.1(a): no hidden or undocumented features, and "marketing your app in a misleading way, such as by promoting content or services that it does not actually offer" is covered.
- 2.3.3: screenshots "should show the app in use, and not merely the title art, login page, or splash screen. They may also include text and image overlays".
- 2.3.8: metadata must suit a 4+ rating, and "Use of terms like 'For Kids' and 'For Children' in app metadata is reserved in the App Store for the Kids Category."
- 2.3.10: no "names, icons, or imagery of other mobile platforms or alternative app marketplaces" in the app or metadata.
- 5.2.1: "Don't use protected third-party material such as trademarks, copyrighted works, or patented ideas in your app without permission, and don't include misleading, false, or copycat representations, names, or metadata in your app bundle or developer name."
- 5.2.5: keyboards "may not include Apple emoji" (relevant to a keyboard app).

### 5. App Store localizations

Source: https://developer.apple.com/help/app-store-connect/reference/app-store-localizations (175 storefront rows). Locale codes come from https://developer.apple.com/documentation/appstoreconnectapi/managing-metadata-in-your-app-by-using-locale-shortcodes.

Files:
- `docs/aso/data/storefront-locales.json`: `{"<Storefront>": [default, ...additional]}` as ASC codes, default first.
- `docs/aso/data/storefront-locales.raw.json`: the same rows with Apple's original language names, ISO code and default.

The table has columns "Default language" and "Additional supported language(s)". It does not say anywhere which of these Apple indexes for search. Treating "supported" as "metadata in that locale can be shown or searched in that storefront" is an inference. Not confirmed: Apple's wording on indexing per locale. Tried: the localizations page and the locale shortcodes article.

Page naming quirks, mapped: "Bangla" = bn-BD, "Odia" = or-IN, "Slovenia" and "Slovenian" = sl-SI, "English (US)" (no dots, in the US and Japan rows) = en-US, "Simplified Chinese" (China mainland row) = zh-Hans. The shortcode article lists Bengali and Oriya for the same languages.

English counts across the 175 storefronts:

| Locale | Storefronts listing it | As the default |
|---|---|---|
| en-GB (English U.K.) | 172 | 135 |
| en-US (English U.S.) | 2 (United States, Japan) | 1 (United States) |
| en-AU (English Australia) | 2 (Australia, New Zealand) | 1 (Australia) |
| en-CA (English Canada) | 1 (Canada) | 1 (Canada) |

Only Canada, Japan and the United States do not list en-GB. In Japan, English is en-US as an additional language; Japan does not list en-GB.

Extra locales by storefront (default first, then additional):

| Storefront | Default | Additional |
|---|---|---|
| United States | en-US | ar-SA, zh-Hans, zh-Hant, fr-FR, ko, pt-BR, ru, es-MX, vi |
| United Kingdom | en-GB | none |
| Germany | de-DE | en-GB |
| Japan | ja | en-US |
| France | fr-FR | en-GB |
| Brazil | pt-BR | en-GB |
| Republic of Korea | ko | en-GB |
| China mainland | zh-Hans | en-GB |
| Indonesia | en-GB | id |
| India | en-GB | bn-BD, gu-IN, hi, kn-IN, ml-IN, mr-IN, or-IN, pa-IN, ta-IN, te-IN, ur-PK |
| Spain | es-ES | ca, en-GB |
| Italy | it | en-GB |
| Netherlands | nl-NL | en-GB |
| Russia | ru | en-GB, uk |
| Mexico | es-MX | en-GB |
| Canada | en-CA | fr-CA |
| Australia | en-AU | en-GB |

The article above also states "The App Store is available in 175 regions and 50 languages", which matches the 175 rows.

### 6. Screenshots

- Text in screenshots and search: Apple says nothing. Neither https://developer.apple.com/app-store/search/ nor https://developer.apple.com/app-store/product-page/ lists screenshots as an indexed field, and neither mentions reading text from images. The search page names only "title, subtitle, keywords, and primary category" as text relevance inputs. Not confirmed either way; practitioner claims are out of scope here.
- What Apple does say about screenshots in search: "the first one to three images will appear in search results when no app preview is available". https://developer.apple.com/app-store/product-page/ And "up to three screenshots or app previews may display in search results". https://developer.apple.com/app-store/search/
- Count: "You can feature up to 10 screenshots". https://developer.apple.com/app-store/product-page/ ASC: "You can upload one to 10 screenshots in .jpeg, .jpg, and .png formats" and "Images can't include alpha channels or transparencies". https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications
- iPhone sizes: the 6.9" set is the base. 6.9" accepts 1260 x 2736, 1290 x 2796 or 1320 x 2868 (portrait; landscape swaps). The 6.5" set (1284 x 2778 or 1242 x 2688) is "Required if app runs on iPhone and screenshots for 6.9" display aren't provided". Other sizes fall back: "scaled screenshots for 6.9" displays are used" (6.5") and 6.5" for 6.3" and 6.1" onward. https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications
- iPad: "Required if app runs on iPad"; 13" accepts 2064 x 2752 or 2048 x 2732 (portrait). Same page.
- Mac: "Required for Mac apps". Same page.
- Guideline 2.3.3 above allows text overlays.

### 7. Ratings and reviews

- RequestReviewAction: "If the person hasn't rated or reviewed your app on this device, StoreKit displays the ratings and review request a maximum of three times within a 365-day period." https://developer.apple.com/documentation/storekit/requestreviewaction
- If they already reviewed: the request shows "if the app version is new, and if more than 365 days have passed since the person's previous review." Same page.
- "App Store policy governs the actual display"; the call may show nothing, so "don't call it in response to a button tap or other user action." Same page.
- Development builds always show the prompt; "this method has no effect in apps that you distribute for beta testing using TestFlight." Same page.
- SKStoreReviewController is deprecated: "Use RequestReviewAction instead." (iOS 10.3 to 18.0). https://developer.apple.com/documentation/storekit/skstorereviewcontroller
- Manual path: append `action=write-review` to the product page URL. https://developer.apple.com/documentation/storekit/requesting-app-store-reviews
- Sample guidance: avoid asking at launch "even if it isn't the first time it launches", ask after a successful sequence, and people "can disable requests for reviews from ever appearing on their device". https://developer.apple.com/documentation/storekit/requesting-app-store-reviews
- HIG: "Ask for a rating only after people have demonstrated engagement"; "Avoid asking for a rating on first launch or during onboarding"; "Avoid interrupting people while they're performing a task"; "Consider allowing at least a week or two between requests"; the system caps the prompt at "three occurrences per app within a 365-day period". https://developer.apple.com/design/human-interface-guidelines/ratings-and-reviews
- HIG on resetting the summary rating: it "tends to result in having fewer ratings overall". Same page.

### 8. Downloads and ratings as ranking inputs

- Yes, both. Apple: "Search results are based on a number of factors, including text relevance (matches for your app's title, subtitle, keywords, and primary category), as well as user behavior (downloads, ratings and reviews, and more)." https://developer.apple.com/app-store/search/
- Same page: "Ratings and reviews appear on your product page and in search results, and can influence how your app ranks in App Store search." https://developer.apple.com/app-store/search/
- Product page: "Ratings and reviews influence how your app ranks in search". https://developer.apple.com/app-store/product-page/
- Apple gives no weights and no recency rule. Not confirmed: how downloads are counted. Tried: search and product-page pages.

### 9. Category names in the keyword field

- Search page: "Don't repeat any words any words included in your app name, subtitle, or category." (the doubled "any words" is Apple's own typo). https://developer.apple.com/app-store/search/
- Product page, list of things to avoid to fit more words: "Names of categories or the word 'app'". https://developer.apple.com/app-store/product-page/
- Both are framed as wasted space, not as a rejection reason. The rejection list is trademarks, irrelevant terms and competing app names (section 2).

### 10. requestReview in development, TestFlight and Simulator

- Development: "When your app calls this method while it's in development mode, StoreKit always displays the rating and review request view, so you can test the user interface and experience." https://developer.apple.com/documentation/storekit/requestreviewaction
- TestFlight: "this method has no effect in apps that you distribute for beta testing using TestFlight." Same page.
- Production: "App Store policy governs the actual display of a rating and review request view", capped at three times in 365 days. Same page.
- Does the sheet submit anything in development: Not confirmed. Apple's page says only that the view always displays. Tried: RequestReviewAction, SKStoreReviewController (deprecated, no behaviour text), "Requesting App Store reviews".
- Simulator: Not confirmed. No Apple page I read mentions it separately from "development mode".
- Never from a button: "don't call it in response to a button tap or other user action." https://developer.apple.com/documentation/storekit/requestreviewaction For a user-initiated path Apple points to the `action=write-review` link. https://developer.apple.com/documentation/storekit/requesting-app-store-reviews
- Never at launch: "Avoid showing a request for a review immediately when a user launches your app, even if it isn't the first time it launches." https://developer.apple.com/documentation/storekit/requesting-app-store-reviews HIG: "Avoid asking for a rating on first launch or during onboarding". https://developer.apple.com/design/human-interface-guidelines/ratings-and-reviews
- After a moment of value: "Ask for a rating only after people have demonstrated engagement with your app or game. For example, you might prompt people when they complete a game level or a significant task." Same HIG page. The sample says to ask "at the end of a sequence of events that they successfully complete".

### 11. Release notes ("What's New")

- Limit: "Limited to 4000 characters." https://developer.apple.com/help/app-store-connect/reference/platform-version-information
- Availability: "This property isn't available for the first version of the app but required for all subsequent versions. This property can be localized." Same page.
- Edit rule: it is a per-version property. In the required/localizable/editable table its row reads "What's New in this Version | 1 | Localized" with the Editable cell empty and footnote "Required for version updates only". https://developer.apple.com/help/app-store-connect/reference/app-information/required-localizable-and-editable-properties Apple does not state in words that it is editable only with a new version; that is read from the empty Editable cell. Not confirmed in prose.
- Guideline 2.3.12: "Apps must clearly describe new features and product changes in their 'What's New' text." https://developer.apple.com/app-store/review/guidelines/

### 12. App previews

- Count: "You can add up to three app previews for each localization, per device size." https://developer.apple.com/help/app-store-connect/reference/platform-version-information The specs page repeats "You can deliver up to 3 app previews". https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications
- Length: minimum "15 Seconds", maximum "30 Seconds". Same specs page.
- Format: "H.264 and ProRes 422 (HQ only)"; maximum file size 500MB; 10-12 Mbps target bit rate for H.264; max 30 frames per second; stereo audio, 256kbps AAC, 44.1kHz or 48kHz. Orientation portrait or landscape (macOS and tvOS landscape only). Same specs page.
- Poster frame default: "5 Seconds". Same page.
- Resolution for current iPhones (6.9" and the iPhone rows I read): 886 x 1920 (portrait) or 1920 x 886 (landscape). Smaller displays fall back: "scaled app previews for 6.9" displays are used." Not confirmed: the exact accepted resolution on every individual device row; I read the page text and saw this pair repeated for the iPhone rows only. Check the page before producing iPad or Mac video.
- Rules for content: previews "may only use video screen captures of the app itself" (guideline 2.3.4). https://developer.apple.com/app-store/review/guidelines/

## Apple: custom product pages, product page optimization, in-app events
Researched 2026-10-01 from Apple pages fetched in that session. Apple's API reference is JavaScript-rendered, so its fields were read from the page data that developer.apple.com serves to its own documentation viewer (`/tutorials/data/documentation/appstoreconnectapi/<slug>.json`) through Chrome. A claim marked "not stated" means the fetched Apple pages do not say.

Sources used, abbreviated below:
- CPP-MKT: https://developer.apple.com/app-store/custom-product-pages/
- PPO-MKT: https://developer.apple.com/app-store/product-page-optimization/
- IAE-MKT: https://developer.apple.com/app-store/in-app-events/
- ASC-CPP: https://developer.apple.com/help/app-store-connect/create-custom-product-pages/configure-multiple-product-page-versions
- ASC-SUBMIT: https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-a-custom-product-page
- ASC-PPO-OV: https://developer.apple.com/help/app-store-connect/create-product-page-optimization-tests/overview-of-product-page-optimization
- ASC-PPO-CREATE: https://developer.apple.com/help/app-store-connect/create-product-page-optimization-tests/create-a-test
- ASC-IAE-STATUS: https://developer.apple.com/help/app-store-connect/reference/in-app-events/in-app-event-statuses
- API: https://developer.apple.com/documentation/appstoreconnectapi/ plus the slug named in each claim

### 1. How many pages, and what each can vary

Limit: Apple's help page says "Create up to 70 custom product pages per app" (ASC-CPP). The marketing page says "up to 70 additional versions of your product page" for iPhone and iPad (CPP-MKT).

Varied per page: screenshots, app previews and promotional text. Apple writes "Vary the screenshots, promotional text, and/or app previews on each product page" (CPP-MKT). Everything else (name, subtitle, icon, description) stays the default page's. Each page is localizable (ASC-CPP).

Keywords per page: yes. CPP-MKT: "You can also assign keywords to your custom product page... appear in search results for those selected keywords, rather than your default product page." Apple adds that each keyword combination must be unique to a single page.

How keywords are assigned (ASC-CPP, section "Enable keywords for a custom product page"): "You can assign keywords from your latest approved app version to a custom product page." Assignment can happen at any time, but "the custom product page is searchable only after it's approved and set to visible." Keywords are chosen per localization, and individually removable afterward. This means a CPP cannot introduce a keyword the app's metadata does not already carry. A numeric limit on keywords per page is not stated on any fetched Apple page.

API support for keywords: yes.
- `AppCustomProductPageLocalization` has the relationship `searchKeywords`, next to `appScreenshotSets`, `appPreviewSets` and `appCustomProductPageVersion` (API: `appcustomproductpagelocalization/relationships-data.dictionary`). Its abstract reads "The localized promotional text, keywords, and screenshots for a custom App Store product page".
- Endpoints (API: `app-custom-product-page-localizations`, group "Managing search keywords"): `GET /v1/appCustomProductPageLocalizations/{id}/searchKeywords`, `GET|POST|DELETE /v1/appCustomProductPageLocalizations/{id}/relationships/searchKeywords`.
- The POST body is `AppCustomProductPageLocalizationSearchKeywordsLinkagesRequest`: `{"data":[{"type":"appKeywords","id":"..."}]}` with `id` and `type` required. It returns 204.
- The ids come from the app's keyword list: `GET /v1/apps/{id}/searchKeywords` takes `filter[locale]`, `filter[platform]` and `limit` and returns `appKeywords` (API: `get-v1-apps-_id_-searchkeywords`). The `AppKeyword` page documents only `id` and `type`, so what the id encodes is not stated. Read the list first and reuse the returned ids.

For Cutling this means a page can only target words already in the live keyword field, and two pages cannot share the same keyword set.

### 2. Deep links per page

- Mechanics (ASC-CPP): "You can optionally add an app deep link to your custom product page." It works "when users running a minimum of iOS 18 or iPadOS 18 click Open". CPP-MKT repeats "supported in iOS 18 and iPadOS 18, or later."
- Format: "An app deep link can be a universal link or custom URL" and universal links are recommended. Avoid URL shorteners, and test it by pasting the link into Notes (ASC-CPP).
- Review: "Your app deep link must be approved before it'll function for users" (ASC-CPP), and ASC-SUBMIT lists deep links among the metadata that must be reviewed.
- One deep link per page version. Apple documents no count limit beyond that.
- API field: `deepLink` (type `uri`) on `AppCustomProductPageVersion` attributes. It is accepted on create (`appcustomproductpageversioncreaterequest`) and on update (`appcustomproductpageversionupdaterequest`).
- Cutling already registers custom URL and App Intents entry points; a CPP deep link needs a destination the app opens from a URL. Check `Cutling.xcodeproj` URL types or associated domains before choosing the link.

### 3. Review rules, states, and timing

Review: yes. ASC-SUBMIT: "Custom product pages, and their associated metadata like deep links, must be reviewed before they're visible to users on the App Store." CPP-MKT: the metadata "must be submitted for review, which you can do independent of an app update."

Submission rule (ASC-SUBMIT): if the app is not yet approved, include the page in the first iOS version's submission. "If your app is already approved, you can choose to submit a custom product page with or without an iOS app version." Add for Review lets you pick an existing draft submission or a new one, and "Items in the submission will be reviewed together with your latest iOS version." So a CPP can ride in the same submission as a new version, or go alone.

Editing during review: "You can't modify a custom product page's screenshots, previews, promotional text, or keywords, while it's under review." Withdrawing the submission makes it editable (ASC-SUBMIT).

States of `AppCustomProductPageVersion.state` (API: `appcustomproductpageversion/attributes-data.dictionary`): PREPARE_FOR_SUBMISSION, READY_FOR_REVIEW, WAITING_FOR_REVIEW, IN_REVIEW, ACCEPTED, APPROVED, REPLACED_WITH_NEW_VERSION, REJECTED. ASC-SUBMIT's UI wording: Ready for Review after Add for Review, Waiting for Review after Submit, then In Review.

When it can be created (ASC-CPP): "You can create a custom product page if your app has the Ready for Distribution status in at least one country or region." The app version does not need to be the live one, and Apple does not require the version to be live. Starting from an existing page, "you can choose a version that's in the Ready for Distribution state or the Prepare for Submission state and it'll copy the product page for your primary localization." Cutling is live, so a page can be created while 1.5.x is in Prepare for Submission and attached to that same submission.

Editing an approved page (ASC-CPP): Create New Version makes "a new draft... in the Ready to Submit state", the URL stays the same, and the approved edit "will replace the current page". The old version becomes REPLACED_WITH_NEW_VERSION.

Disabling: "If someone selects a URL for a disabled custom product page, they're automatically redirected to your default product page" (ASC-CPP). In the API this is the `visible` boolean on `appCustomProductPages`.

### 4. How a page is reached

- Unique URL: generated on creation and shown in App Store Connect (ASC-CPP). CPP-MKT: "The unique URL adds a new product page ID parameter to the default product page URL." The literal query name `ppid` appears on none of the fetched Apple pages, so treat the parameter name as unconfirmed here; read the real URL from the `url` attribute of the created page.
- Visibility: "only visible to people if they follow a custom product page link, or if you choose to make your custom product page visible in App Store search results by adding keywords. Otherwise, your app's default product page displays" (ASC-CPP).
- Apple Ads: CPP-MKT: "You can also create ad variations for search results based on different custom product pages." Ads on the Today tab, Search tab and in search results can lead to a specific page, and the page's deep link applies.
- Editorial: pages "can appear in editorially curated stories and collections" (CPP-MKT).
- Platforms: CPP-MKT states iPhone and iPad. ASC-CPP: available on iOS 15 and iPadOS 15 or later.
- Analytics: per-page impressions, downloads and conversion appear in App Analytics "after a custom product page receives at least five first-time downloads" (ASC-CPP).

### 5. Product Page Optimization

- Treatments: "up to three treatments" per test, each can alter app icon, screenshots and app previews (PPO-MKT, ASC-PPO-CREATE). Promotional text, description and keywords are not on the list.
- Concurrency: "You can create one test at a time" (PPO-MKT).
- Duration: "A test runs for 90 days or until you manually stop it" (PPO-MKT, ASC-PPO-CREATE). The optional estimate targets at least 90% confidence.
- Traffic: you choose the share shown a treatment; a user sees the same treatment for the whole test. Localizations are selectable (ASC-PPO-CREATE).
- Review: "any new metadata that you'd like to include in your treatments must be approved by App Review." A test with no alternate icon "can be submitted for review independent of a new app version"; alternate icons must ship in the binary (PPO-MKT).
- Requirement: the app must be Ready for Distribution (ASC-PPO-OV).
- CPP interaction: ASC-PPO-OV says "Product page optimization tests aren't available for custom product pages." A test targets the default product page. Apple's fetched pages do not say whether a test and CPPs may be active together, so this is not stated. They are separate features on separate pages.
- API: `appStoreVersionExperiments` and a V2 variant exist, and `reviewSubmissionItems` accept `appStoreVersionExperiment` and `appStoreVersionExperimentV2` (API: `reviewsubmissionitemcreaterequest`). Request bodies were not captured here.

### 6. In-App Events

- Definition: "timely events within apps and games — such as game competitions, movie premieres, livestreamed experiences" (IAE-MKT).
- Not good candidates (IAE-MKT): "Repetitive activities such as daily tasks or rewards", price promotions without new content, and "General promotions that raise awareness about your app". The event "should focus on a related limited-time moment or experience."
- Limits: an event lasts up to 31 days, can be promoted 14 days ahead, 10 published at a time, 15 approved in App Store Connect (IAE-MKT). Drafts: up to 50 (ASC-IAE-STATUS).
- Badges (IAE-MKT): Challenge, Competition, Live Event, Major Update, New Season, Premiere, Special Event. Major Update means significant new features beyond "minor enhancements like UI adjustments or bug fixes."
- Metadata: name up to 30 characters, short description up to 50, long description up to 120, plus card and details media. No prices in metadata (IAE-MKT).
- Deep link: required-style field, universal link or custom URL (IAE-MKT).
- Review: yes, independent of an app version (IAE-MKT). Statuses: Draft, In Review, Rejected, Approved - Set to Publish, Approved - Published, Past (ASC-IAE-STATUS).
- Fit for Cutling: a clipboard utility has no recurring time-bound content, so nothing qualifies as a routine. A real one-off could qualify under Major Update or Special Event, for example a launch of a new keyboard feature with a limited-time moment attached. That is a judgment from the rules above, not an Apple statement. Plain "new version" announcements are excluded by the "minor enhancements" language.
- API: `POST /v1/appEvents`, `GET /v1/apps/{id}/appEvents`, localizations under `/v1/appEvents/{id}/localizations`; submit through a `reviewSubmissionItem` with `appEvent` (API: `app-events`).

### 7. API recipe

Auth: the same App Store Connect API key as the existing lanes (`fastlane/asc_api_key.json`). Base `https://api.appstoreconnect.apple.com`. All bodies are JSON:API. Field names below come from the Apple pages cited in sections 1-6; request attribute lists were read from each `...createrequest` page. Ids in `{braces}` come from earlier responses.

#### Spaceship coverage

Installed fastlane 2.234.0, `/Users/hafang/.rbenv/versions/3.3.6/lib/ruby/gems/3.3.0/gems/fastlane-2.234.0/spaceship/lib/spaceship/connect_api/`.
- No custom product page model, no localization, keyword, experiment or app event model exists (a search for custom_product, app_custom, searchKeyword, appEvent, experiment matched only the file below).
- `models/review_submission_item.rb` maps the `appCustomProductPageVersion`, `appEvent` and experiment relationships for reading only. `tunes/tunes.rb:1162` `post_review_submission_item` can only attach an `appStoreVersion`, so attaching a CPP version needs a raw call.
- Reusable: `models/app_screenshot.rb` `AppScreenshot.create(app_screenshot_set_id:, path:)` runs reserve, upload and commit for any set id, and `models/app_screenshot_set.rb` `upload_screenshot` does the same. `tunes/tunes.rb:1110-1150` covers `get/post/patch_review_submission`.
- Raw calls go through `Spaceship::ConnectAPI.tunes_request_client` with `get`, `post`, `patch` and `delete` (`api_client.rb:105-139`), which the Cutling Fastfile already authenticates.

#### Steps

1. Create the page (API: `post-v1-appcustomproductpages`). Requires `name`, relationship `app`. Optional `appStoreVersionTemplate`, `customProductPageTemplate`, or inline `appCustomProductPageVersions` to copy an earlier page or version.
```
POST /v1/appCustomProductPages
{"data":{"type":"appCustomProductPages","attributes":{"name":"Keyboard setup"},
 "relationships":{"app":{"data":{"type":"apps","id":"6759476314"}}}}}
```
The response carries `attributes.url` (the shareable link), `attributes.visible` and the page id used below. Apple also documents optional `appStoreVersionTemplate`, `customProductPageTemplate` and inline `appCustomProductPageVersions` relationships on this request to copy an existing page; separate calls (steps 2 and 3) are easier to debug.

2. Create a further version of an existing page (API: `post-v1-appcustomproductpageversions`, attributes `deepLink`, relationship `appCustomProductPage*`, optional `appCustomProductPageLocalizations`):
```
POST /v1/appCustomProductPageVersions
{"data":{"type":"appCustomProductPageVersions","attributes":{"deepLink":"cutling://..."},
 "relationships":{"appCustomProductPage":{"data":{"type":"appCustomProductPages","id":"{pageId}"}}}}}
```
Set or change the deep link later with `PATCH /v1/appCustomProductPageVersions/{versionId}` and `{"data":{"type":"appCustomProductPageVersions","id":"{versionId}","attributes":{"deepLink":"..."}}}`.

3. Create a localization (API: `post-v1-appcustomproductpagelocalizations`; `locale` required, `promotionalText` optional, relationship `appCustomProductPageVersion` required):
```
POST /v1/appCustomProductPageLocalizations
{"data":{"type":"appCustomProductPageLocalizations",
 "attributes":{"locale":"en-US","promotionalText":"Paste faster with a keyboard for your snippets."},
 "relationships":{"appCustomProductPageVersion":{"data":{"type":"appCustomProductPageVersions","id":"{versionId}"}}}}}
```
Update text with `PATCH /v1/appCustomProductPageLocalizations/{locId}` (attribute `promotionalText` only; `locale` is fixed).

4. Keywords (sections 1 and 7 sources). List the app's keyword ids, then link them:
```
GET  /v1/apps/6759476314/searchKeywords?filter[locale]=en-US&filter[platform]=IOS&limit=200
POST /v1/appCustomProductPageLocalizations/{locId}/relationships/searchKeywords
{"data":[{"type":"appKeywords","id":"{keywordId}"}]}
```
Remove with DELETE on the same path and the same body shape. The `filter[platform]` value `IOS` is the usual platform enum; it was not re-verified on the filter's page.

5. Screenshot set (API: `appscreenshotsetcreaterequest`; `screenshotDisplayType` required, relationship `appCustomProductPageLocalization`). iPhone values include APP_IPHONE_67, APP_IPHONE_65, APP_IPHONE_61; iPad include APP_IPAD_PRO_3GEN_129:
```
POST /v1/appScreenshotSets
{"data":{"type":"appScreenshotSets","attributes":{"screenshotDisplayType":"APP_IPHONE_67"},
 "relationships":{"appCustomProductPageLocalization":{"data":{"type":"appCustomProductPageLocalizations","id":"{locId}"}}}}}
```
Screenshot create reserves the asset (attributes `fileName`, `fileSize`, relationship `appScreenshotSet`); the response carries `uploadOperations` (each `method`, `url`, `offset`, `length`, `requestHeaders`); send each byte range to its `url` with those headers; commit with an update:
```
POST /v1/appScreenshots
{"data":{"type":"appScreenshots","attributes":{"fileName":"01.png","fileSize":123456},
 "relationships":{"appScreenshotSet":{"data":{"type":"appScreenshotSets","id":"{setId}"}}}}}
PUT {uploadOperations[i].url}   (body = bytes[offset, offset+length), headers from requestHeaders)
PATCH /v1/appScreenshots/{id}
{"data":{"type":"appScreenshots","id":"{id}","attributes":{"uploaded":true,"sourceFileChecksum":"{md5 of file}"}}}
GET  /v1/appScreenshots/{id}     -> check attributes.assetDeliveryState
```
The four steps are Apple's own list: reserve, upload, commit, verify (API: `uploading-assets-to-app-store-connect`). In Ruby, `Spaceship::ConnectAPI::AppScreenshot.create(app_screenshot_set_id:, path:)` does all four.

6. Submit (API: `reviewsubmissioncreaterequest` attribute `platform`; `reviewsubmissionitemcreaterequest` relationships `appCustomProductPageVersion`, `appStoreVersion`, `appEvent`, experiments; `reviewsubmissionupdaterequest` attributes `submitted`, `canceled`). To ride with the next iOS release, add the version item to the same submission as the app version:
```
POST /v1/reviewSubmissions        {"data":{"type":"reviewSubmissions","attributes":{"platform":"IOS"},"relationships":{"app":{"data":{"type":"apps","id":"6759476314"}}}}}
POST /v1/reviewSubmissionItems    {"data":{"type":"reviewSubmissionItems","relationships":{"reviewSubmission":{"data":{"type":"reviewSubmissions","id":"{subId}"}},"appCustomProductPageVersion":{"data":{"type":"appCustomProductPageVersions","id":"{versionId}"}}}}}
PATCH /v1/reviewSubmissions/{subId} {"data":{"type":"reviewSubmissions","id":"{subId}","attributes":{"submitted":true}}}
```
Apple links its own CPP submission help to "app-store-version-submissions" for the API route; the review submission items above are the current documented mechanism for CPP versions. Whether a CPP-only submission is accepted without an app version item follows ASC-SUBMIT ("with or without an iOS app version"); not exercised.

7. Read state back:
```
GET /v1/apps/6759476314/appCustomProductPages
GET /v1/appCustomProductPages/{pageId}/appCustomProductPageVersions     (attributes.state, deepLink, version)
GET /v1/appCustomProductPageVersions/{versionId}/appCustomProductPageLocalizations
GET /v1/appCustomProductPageLocalizations/{locId}/appScreenshotSets
GET /v1/appCustomProductPageLocalizations/{locId}/searchKeywords
GET /v1/reviewSubmissions/{subId}/items
```
Make a page invisible or visible with `PATCH /v1/appCustomProductPages/{pageId}` and attributes `name` and/or `visible`. Delete with `DELETE /v1/appCustomProductPages/{pageId}`.

#### Caveats

- The JSON blocks are assembled from field lists on Apple's pages, not copied example payloads. Run step 1 against one test page first and inspect the responses before scripting all 70.
- Keyword count limits per page, and screenshot counts per CPP set are not stated on the fetched pages.

## Practitioners
Every claim below comes from a page fetched in this session. Dates are the date shown on the page; "no date shown" means the page displays none. Most vendor pages state conclusions without publishing their test data, and each section says so where it applies. Pages that returned an empty shell to WebFetch (Appfigures, HTTP 403) were read in Chrome.

Sources read, by site:

- AppTweak: keyword field guide, localization guide, ranking factors, keyword research guide, iOS checklist, screenshot A/B guide.
- Appfigures: June 2025 algorithm post, secondary-localization guide, app-name guide, keyword teardown livestream.
- MobileAction: cross-localization post, keyword-field post, ranking-factors post.
- Sensor Tower: two blog posts, both undated.
- SplitMetrics: ranking-factors post, mistakes post, OLBG case study.
- Phiture: ASO Stack post (2017) and ASO Trends 2026 post.
- Indie and developer write-ups: MartianCraft (AJ Picard, 2024), John MacAdam (Medium, 2018), Terry Xu (Indie Hackers, 2020), ConsultMyApp screenshot test (agency).

Gaps up front: no fetched source gives guidance specific to keyboard apps, none addresses numbers in the keyword field, and real before/after figures from indie developers are scarce (section 10).

### 1. Weight of name vs subtitle vs keyword field

- Name has the most weight; subtitle gets less. AppTweak says the title is "the text field with the most weight" and the subtitle is "given less weight" ([AppTweak iOS checklist](https://www.apptweak.com/en/aso-blog/app-store-optimization-aso-checklist-for-ios), 10 Apr 2024). AppTweak's ranking-factors page calls title and subtitle "the most heavily weighted text fields" ([AppTweak ranking factors](https://www.apptweak.com/en/aso-blog/app-store-ranking-factors), updated 28 Jan 2026).
- Appfigures gives an explicit order: name, then subtitle, then keyword list. In the keyword livestream the presenter calls the keyword list "the second-and-a-half most important" field ([Appfigures keyword teardown](https://appfigures.com/resources/videos/live-keyword-list-teardown-aso), 26 Feb 2025). The name guide says Apple "combines keywords from the name and subtitle together but gives more weight to ones in the name" ([Appfigures app-name guide](https://appfigures.com/resources/guides/app-name-optimization), "Jun. 29", year not shown).
- Position inside the field also counts. Appfigures: keywords earlier in the name rank better, and in English keywords on the left of the keyword list get more weight (same two pages). Appfigures also says that since a few years ago the algorithm "put more weight on focus": a name and subtitle that mix many keyword themes rank worse than a focused pair. The Expedia rewrite is the only evidence given, and it is an opinion with no test attached.
- Other vendors agree on the order without numbers. Sensor Tower: "Titles (your app's name) and subtitles hold the most weight" ([Sensor Tower, 3 ASO strategies](https://sensortower.com/blog/app-store-optimization-visibility-conversions), no date shown). SplitMetrics: title and subtitle "carry the highest ranking weight" ([SplitMetrics ranking factors](https://splitmetrics.com/blog/apple-app-store-ranking-factors/), 1 Sep 2025). MartianCraft: the keyword field "has less impact than the name and subtitle" ([MartianCraft](https://martiancraft.com/blog/2024/07/the-art-of-app-store-optimization/), 18 Jul 2024). Phiture: the title has the biggest impact and the hidden keyword field "also impacts search rankings a lot" ([Phiture ASO Stack](https://phiture.com/asostack/the-app-store-optimization-stack-7443936050c5/), 4 May 2017).
- Evidence quality: none of these pages publishes a controlled test of field weights. The ranking is consistent across all of them, the ratios are not given anywhere.
- Disagreement on the description. SplitMetrics (Sep 2025) lists "keyword-rich app descriptions" as a ranking activity. Phiture says the App Store description "doesn't affect ranking" ([Phiture ASO Trends 2026](https://phiture.com/blog/aso-trends-in-2026/), 19 Mar 2026), AppTweak (Jan 2026) says the same, and Appfigures found "no indication" of description indexing ([Appfigures algorithm post](https://appfigures.com/resources/guides/app-store-algorithm-update-2025), 17 Jun 2025).

### 2. Combining words across fields

- Within one locale, Apple combines words from name, subtitle and keyword list into phrases. Appfigures: "Within the same localization, keywords from the name, subtitle, and keyword list get combined so you don't have to repeat them" ([Appfigures secondary localizations](https://appfigures.com/resources/guides/extend-keyword-list), "Jun. 29", year not shown; its country table is dated 25 Apr 2023). AppTweak: "The Apple algorithm will automatically make combinations with the different keywords in your keyword field" ([AppTweak keyword field](https://www.apptweak.com/en/aso-blog/how-to-optimize-your-ios-keyword-field), updated 29 Aug 2024). MobileAction (15 Apr 2026) repeats the rule.
- Across localizations, no combining. Appfigures: "Apple doesn't combine those across localizations." AppTweak gives a worked example: if "bus" is only in en-US and "metro" only in es-MX, the app ranks for each word alone and "will most likely not be indexed for 'metro bus'"; its conclusion says "Repetition may be required in some cases to target specific combinations" ([AppTweak localization guide](https://www.apptweak.com/en/aso-blog/how-to-benefit-from-cross-localization-on-the-app-store), updated 21 Nov 2025). MobileAction: "Phrase combinations only form within a single locale, not across them" ([MobileAction cross-localization](https://www.mobileaction.co/blog/app-store-cross-localization/), 15 Apr 2026).
- Practical reading: a phrase you want must have all its words inside one locale's name, subtitle and keyword list. AppTweak's guide says the same-locale rule means a deliberately repeated word in a second locale buys the extra phrase.
- No source in this set publishes the underlying test for the no-combine rule. AppTweak and Phiture did run a fake-keyword test (a made-up token in en-UK metadata, tracked across storefronts), but that test established which locales are indexed, not how phrases combine.

### 3. Cross-localization (secondary locale keyword fields)

- Each storefront indexes its primary locale plus one or more secondary locales. For the US, AppTweak lists: Spanish (Mexico), Russian, Chinese (Simplified), Arabic, French, Portuguese (Brazil), Chinese (Traditional), Vietnamese, Korean. Appfigures's table lists the same nine for the US (Arabic, Chinese Simplified and Traditional, French, Korean, Portuguese Brazil, Russian, Spanish Mexico, Vietnamese). MobileAction (Apr 2026) gives the same nine. English (UK) is not in the US list in any of the three tables. For most other territories English (UK) is a secondary locale (AppTweak, Appfigures, MobileAction tables).
- Method behind AppTweak's table: "AppTweak and Phiture ran a few tests using fake keywords, such as 'enuk1201,' for an English (UK) localization and tracked these keywords across the different App Store territories." This is the only published test in this set for any section, and it dates from writing the 2022 Advanced ASO book.
- Size of the gain, per MobileAction: a US app using all nine secondary locales has up to 1,440 characters of keyword-bearing metadata versus 160 for en-US alone (30 name + 30 subtitle + 100 keywords per locale).
- Appfigures: filling a secondary locale adds 100 characters of English keywords "for every additional localization", and the language of the added text is irrelevant. SplitMetrics (16 Mar 2023) says the other locales expand a US "semantic core" almost nine times ([SplitMetrics mistakes post](https://splitmetrics.com/blog/aso-mistakes-affecting-app-visibility-and-conversion-rate/)).
- Rules from the sources: avoid duplicating keywords across locales in one storefront, except to build a phrase (AppTweak, MobileAction); localize the visible title and subtitle for local users and mix languages only in the keyword field (AppTweak, MobileAction).
- AppTweak adds a side effect in the other direction: an app localized for Spain is also indexed on English keywords from the default English keyword field, so adding English words to a Spanish keyword field is wasted space ([AppTweak keyword field](https://www.apptweak.com/en/aso-blog/how-to-optimize-your-ios-keyword-field)).
- Developer report: John MacAdam ([Medium, 31 Oct 2018](https://appsbyjohn.medium.com/how-i-doubled-app-store-impressions-be04d9f8c001)) states that "All metadata is indexed twice" (US English plus Mexico Spanish) and used the es-MX slot for extra keywords. Dated, no per-change numbers.
- Point for Cutling: the user's example of en-GB in the US does not match the tables above. For the US storefront the listed secondary slots are es-MX, ru, zh-Hans, ar, fr, pt-BR, zh-Hant, vi and ko. Cutling already ships many locales, so check what the keyword fields of those nine currently hold before adding anything.

### 4. Screenshot text and search (reports since June 2025)

Sources disagree. Confidence that captions help ranking at all: low to medium. Confidence that they work alone without matching metadata: low.

- Appfigures, 17 Jun 2025: states "Apple is now extracting text from your app's screenshot captions and treating that text as part of your keyword metadata." Evidence given: the author analyzed "thousands of keywords" with Appfigures tools and a custom AI; apps whose captions matched their other metadata rose, apps without them fell. Captions strengthen existing keywords and can introduce new ones (apps ranking for words found only in screenshots), though "it doesn't seem to be as strong a signal alone." Caption position at top is flagged as speculation. No data table is published. Description indexing: none found. App Preview video: "I don't think that's happening right now." ([Appfigures algorithm post](https://appfigures.com/resources/guides/app-store-algorithm-update-2025)).
- SplitMetrics, 1 Sep 2025, states as fact that "Apple now indexes this content" and recommends caption keywords ([SplitMetrics ranking factors](https://splitmetrics.com/blog/apple-app-store-ranking-factors/)). No evidence given on that page.
- AppTweak, 28 Jan 2026: "Some screenshot captions are now factored for the App Store rankings"; it advises action-driven caption text with keywords ([AppTweak ranking factors](https://www.apptweak.com/en/aso-blog/app-store-ranking-factors)).
- Phiture, 19 Mar 2026, contradicts the confident framing: the June 2025 shift "led some to speculate that Apple had begun indexing screenshot text using OCR technology. This has since been denied by Apple, and Apptweak echoed that position in a recent seminar session." Phiture's advice stays the same: treat captions as keyword-aware content, and note that keyword-stuffed screenshots "look desperate and convert poorly" ([Phiture ASO Trends 2026](https://phiture.com/blog/aso-trends-in-2026/)). So AppTweak's own page (Jan 2026) and its reported seminar position (per Phiture, Mar 2026) do not line up.
- ConsultMyApp test (agency; page shows the 6 June 2025 update date but no publication date): 64 phrases taken from screenshots of 8 category-leading US apps; 36 ranked in no way, 27 of the rankings were explained by metadata, 1 was unexplained (an Audible phrase). Its verdict: "no strong evidence Apple is broadly indexing screenshot titles" ([ConsultMyApp](https://www.consultmyapp.com/blog/-is-apple-now-indexing-screenshot-titles-on-the-app-store)). Small sample and the author's own methodology, so treat as one data point.
- Where they agree: captions that repeat words already in name/subtitle are harmless and may help; writing captions as real search phrases serves conversion anyway ("Track Sleep Patterns" over "Wake Up Refreshed", Appfigures; "Track Your Run" over "All-in-One Solution", Phiture).
- Legibility advice if machines do read it (Appfigures only, no test): high contrast, plain legible fonts, large size, no glow or heavy shadow, one keyword theme per screenshot, captions at top, no repeated captions.

### 5. Keyword field best practice

- Singular vs plural: use the singular in English; Apple's guidance is quoted by AppTweak and the app "will typically rank for the plural version automatically" ([AppTweak keyword field](https://www.apptweak.com/en/aso-blog/how-to-optimize-your-ios-keyword-field)). Appfigures agrees ("Don't Pluralize Words (Usually)", 26 Feb 2025). Exception, from AppTweak: this does not always hold in other languages (it shows Farmville ranking for French "animal" but not "animaux"), so check competitors per language.
- Commas and spaces: single words separated by commas, no space after a comma (AppTweak; Appfigures: "Spaces don't help the algorithm"; MobileAction, which also warns against multi-word phrases in the field, [MobileAction keyword field](https://www.mobileaction.co/blog/ios-app-store-optimization-keywords-field/), page shows 20 Sep 2021 and a 2026 title). Appfigures adds that its free list tool shows the combinations the list produces and that cleanup can save up to 20% of the characters.
- Special characters such as "-", "@", "*" are replaced by a blank, so they waste space (AppTweak). Appfigures: a stray "+" is generally dropped.
- Numbers: none of the fetched pages addresses them. No claim made.
- Category name: AppTweak calls it a "free keyword" not to be targeted. Appfigures says to leave out app name, company name and category, since they are already indexed. MobileAction relays Apple's instruction not to repeat words from the name, subtitle or category.
- Stop words and "app": Appfigures says "on", "the" and "app" are ignored by Apple and should be removed (also warns "free" often draws a metadata rejection). AppTweak lists "app", "free", "iPhone", "iPad", "new", "best" as free keywords. MobileAction's weak example lists "app" as a problem. All three agree.
- Repeating words: do not repeat a word across fields or inside the field; Apple does not weight repetition (AppTweak; Appfigures calls it the most important takeaway, repeated in its teardown; Phiture's 2017 post and the SplitMetrics/MobileAction pages say the same). Section 4 notes Appfigures's view that caption words are an exception.
- Fill all 100 characters? Appfigures changed its advice in Feb 2025: "I used to recommend filling all 100 characters, but now I advise only doing so if your keywords are tightly focused" and said more keywords means less weight each. AppTweak and MobileAction still describe the 100 characters as space to use. This is a disagreement, and Appfigures cites no test.
- Competitor and trademarked names: AppTweak says Apple "does not approve" and can block ranking on the term or remove the app; its workaround is single generic words from a competitor's name (e.g. "guitar,tuner"). Appfigures's livestream says not to spend characters on competitor names because "you won't win those downloads", though it says to avoid them "unless you have evidence it works for your category". Risk is stated by AppTweak, a payoff test is stated by none.
- Order: Appfigures says left-most keywords get more weight in English; no other fetched source says this.

### 6. Ratings, reviews, and review-prompt timing

- Ranking: AppTweak (28 Jan 2026): apps under 3.5 stars "have significantly reduced visibility", apps above 4.0 "correlate" with higher keyword rankings. This is correlation as presented, with no data shown. Sensor Tower (no date): aim for four stars or higher. SplitMetrics (1 Sep 2025): 4+ stars and review prompts. Phiture (4 May 2017): "The number of reviews, the review velocity, and the star rating all have a big impact on visibility." MartianCraft (18 Jul 2024): reviews are "the highest form of currency", and negative reviews have the biggest negative effect.
- Conversion: AppTweak says a "vast majority" of store visitors check reviews and ratings before installing, and suggests replying to reviews (negative first) because it can change the viewer's mind ([AppTweak checklist](https://www.apptweak.com/en/aso-blog/app-store-optimization-aso-checklist-for-ios), 10 Apr 2024). No conversion figure is given.
- Timing of the prompt, with a disagreement:
  - AppTweak: after the user completes a challenging task and is not busy; its example is after a tough level in a game.
  - Sensor Tower: after a positive interaction such as completing a task; avoid after frustrating moments such as a crash ([Sensor Tower](https://sensortower.com/blog/app-store-optimization-visibility-conversions)).
  - MartianCraft: first prompt right after onboarding ("you'll be surprised at how many reviews you'll get"), then again after every seventh open for users who have not reviewed. It states the system alert can only be shown three times, a custom alert can be shown unlimited times but sends the user to the App Store, "which users often dislike".
  - The first two give a success-moment rule and the third a fixed schedule; none publishes a test comparing them.

### 7. Conversion: first screenshots, captions, showing the product work

- First three screenshots: Phiture (19 Mar 2026): they "appear directly in search results" and for many users are the only visuals seen before the tap decision; the first frame "needs to communicate your core value proposition instantly." SplitMetrics OLBG case (no date shown): the winning changes gave a 61% conversion increase overall, one test +45%, and "people don't often scroll past the 3rd screen to make their decision" ([SplitMetrics OLBG](https://splitmetrics.com/cases/olbg-ios-screenshots-optimization/)). The biggest single gain came from putting the two newest and most popular features in the first three screenshots. Vendor case study for a betting app, one test series.
- What the OLBG tests found: a plain single-colour background performed 10 to 13% worse than a coloured one (against what many competitors recommended), and removing the headline text from the first screenshot and adding feature bubbles gave the +45%. Result is category-specific by the case study's own note ("storytelling videos don't work in the betting vertical").
- Caption size and clarity: SplitMetrics (16 Mar 2023): "almost 50% of users leave the app product page after 3 seconds", yet 40% of analyzed apps had hard-to-read captions; advice is high contrast, legible font, text large enough for a small device, short length. AppTweak (10 Apr 2024): short captions in a large font. Appfigures (Jun 2025): if you cannot read it on a phone, reduce words. These advice items agree; the 3-second and 40% figures come from SplitMetrics's own analysis, unpublished.
- Phiture's caption advice: concrete task phrases beat vague ones ("Track Your Run", "Edit 4K Video").
- One feature per screenshot: Appfigures (one keyword theme each); SplitMetrics's search-result summary says the same, but I did not read that specific page in full.
- Showing the product working: Sensor Tower (no date shown) says video previews should display core functionality in the first five seconds, with text callouts; the same page says top apps test layouts, colours and CTA placement. AppTweak describes screenshots as "banner ads" that are also "self-explanatory" ([AppTweak screenshot A/B guide](https://www.apptweak.com/en/aso-blog/ultimate-guide-to-screenshots-a-slash-b-testing), 13 Feb 2024). The ZiMAD case in that guide (+32%) used real screenshots layered with gameplay and a caption highlighting features.
- Phiture's benchmark: most App Store categories averaged under four screenshot updates a year, which it calls an opening for teams that test more.

### 8. Picking targets: popularity, difficulty, small apps

- Popularity vs difficulty: AppTweak (updated 10 Feb 2026): aim for keywords you can realistically rank for, "better to be #1 for a lower-volume keyword than buried in the results for a competitive one"; its Difficulty score uses the top 10 apps and their "App Power" ([AppTweak keyword research](https://www.apptweak.com/en/aso-blog/app-store-keyword-research-aso)). Popularity comes from Apple's Search Popularity score. Phiture (2017): research keywords with high volume, relevance and low competition; target ranks of 10 or better.
- Competitors' ratings and downloads matter. Appfigures name guide: look at the top 5 apps for each keyword, check "their monthly downloads, how high they rank in their category, and how many ratings they have. Your app needs to have similar performance to be able to break into that list." It also describes "keyword opportunities": keywords where the top results lack the term in their name; these are easier to win with less performance. Sensor Tower's Predictive Rank takes the strength of your app and your competitors into account to estimate top-10 likelihood ([Sensor Tower Predictive Rank](https://sensortower.com/blog/how-to-predict-a-top-10-app-store-keyword-ranking), no date shown, Enterprise feature).
- Long-tail for new apps: AppTweak keyword field page: new apps should target long-tail keywords, e.g. "meet new people" instead of "dating" for a new dating app; enter them as single words so Apple builds the combinations. Phiture (19 Mar 2026): long-tail "deserve renewed attention" because head-term competition is rising, with "remove background from photo" as an example; it says those users "convert better" (no figure given). MartianCraft uses the keyword field for less popular, lower-competition words when an app is new.
- Metric caution: popularity scores are Apple's index from 5 to 100 (Phiture 2017) and Appfigures says to pick the highest relevant score rather than a fixed number.
- Change management: MartianCraft says to expect 1 to 2 weeks before downloads move, 3 to 4 weeks for real results, and to wait 6 weeks before more changes; once keywords drive consistent downloads, change only a few at a time. Appfigures says to expect a sharp rank change in 12 to 48 hours then small movements for weeks. See section 10 for the Indie Hackers report of a drop after a full keyword rewrite.

### 9. Keyboard apps and utility apps

- No fetched practitioner or vendor page gives ASO guidance specific to keyboard extensions or utilities. This is a gap, not a finding.
- Closest case: MartianCraft's OneTap, an app built around keyboard shortcuts and clipboard pasting. Name before: OneTap. Name after: "Keyboard Shortcuts - OneTap". Subtitle: "Paste clipboard & AI assistant". The author says the two highest-priority keywords were put in front of the brand name because many other apps already use "OneTap" and have more reviews. Reported result: "almost triple the amount of users in 7 months compared to the previous 14 months" (Nov 2023 to May 2024 vs Sep 2022 to Oct 2023, shown as charts I could not extract; the author also warns that removing a subtitle in a later update "drastically" hurts ASO, which is hearsay, in the author's words "word on the street") ([MartianCraft](https://martiancraft.com/blog/2024/07/the-art-of-app-store-optimization/), 18 Jul 2024). Weak as proof (single app, before/after period lengths differ, ASO was not isolated from other work), strong as a close category analog.

### 10. Indie developer write-ups with numbers

Real before/after numbers are rare. These are the usable ones.

- AJ Picard, MartianCraft, 18 Jul 2024 (OneTap): see section 9. Almost triple the users over 7 months compared with the prior 14 months. Exact counts not extractable.
- John MacAdam, Medium, 31 Oct 2018: after an ASO update on a personal app, "App store impressions doubled immediately. Profits for the app almost doubled as well." He changed one factor at a time and waited at least two weeks between changes ([Medium](https://appsbyjohn.medium.com/how-i-doubled-app-store-impressions-be04d9f8c001)). Dated and the numbers are in a chart image.
- Terry Xu, Indie Hackers, 1 Mar 2020 (a cautionary case): after rewriting title, subtitle and keywords to push tool scores from under 60 to over 90, "3 days after I changed my keywords, the organic viewers of my app dropped by 66%". He reverted and concluded that tool scores are "only guessing" ([Indie Hackers](https://www.indiehackers.com/post/a-hard-lesson-learned-about-app-store-optimization-7d55646fc4)). A commenter notes the drop may have coincided with Apple-side changes, so cause is not proven.
- Indie Hackers, "How I grow my App's monthly revenue from $200 to $3K": the author credits ASO and Apple Search Ads for traffic but gives no ASO figures (no date shown), so it adds no usable number ([Indie Hackers](https://www.indiehackers.com/post/how-i-grow-my-apps-monthly-revenue-from-200-to-3k-4bfc271ab3)).
- Several other "ASO for indie developers" pages (Applyra, cos-go, a dev.to roundup) quote percentages such as "40% more downloads after localizing" with no named app, dates or screenshots. I excluded them as unverifiable.

### Actionable reading for Cutling, strongest support first

1. Put the two highest-value keywords in the name and extend them in the subtitle without repeating words; keep both focused on one theme (every vendor agrees on name over subtitle over keyword field; focus claim is Appfigures only).
2. Fill the keyword field with single words, singular, no spaces, no "app", no category word, no words already in name or subtitle (AppTweak, Appfigures, MobileAction agree).
3. Use the nine US secondary locales (not en-GB) for extra keyword fields, and keep every phrase's words inside one locale (AppTweak, Appfigures, MobileAction agree; AppTweak's fake-keyword test is the only published test).
4. Make the first three screenshots carry the strongest feature with large, high-contrast, short captions (SplitMetrics case with numbers, Phiture, AppTweak; vendor case studies).
5. Write captions as real search phrases that echo name and subtitle words; treat any ranking gain as unproven (Appfigures and SplitMetrics say yes, Phiture reports an Apple denial, ConsultMyApp's test found little).
6. Change a few keywords at a time and wait 3 to 6 weeks; the Indie Hackers 66% drop and MartianCraft's advice both point this way (single anecdotes).

## Competitors
Source: iTunes Search/Lookup API (search ranking, trackName, seller, userRatingCount, price) and each app's own apps.apple.com page (subtitle), all fetched 2026-10-01. Top 8 relevant results per storefront by combined rank over the queries below, plus anchor apps (Paste, Paste Keyboard, TextExpander, WordBoard) marked † when they did not rank. Where the page showed only the category in the subtitle slot, the app has no subtitle. Ratings are per storefront. Machine-readable copy: [competitors.json](data/competitors.json).

Queries: English (clipboard manager, clipboard keyboard, text snippets keyboard, text expander, clipboard, canned replies) plus the local terms for each store: クリップボード, 定型文, コピペ; 클립보드, 상용구; Zwischenablage, Textbausteine; presse-papiers; área de transferência, frases prontas; portapapeles, respuestas rápidas; appunti; klembord; буфер обмена; 剪贴板, 常用语; 剪貼簿; papan klip, template chat; pano, hazır metin.

### Cross-market notes

- Clipy is not on the iOS or Mac App Store (store search for "Clipy" returns only unrelated apps: Cliply, ClipyPro, ClipyBoard). It is a GitHub/direct Mac app, so it is not a listing competitor, but its name is still a trademark to avoid.
- TextExpander's new iOS app (id 6805960547, subtitle "Your snippets in every app.") has 0 to 5 ratings everywhere; the brand is strong, the listing is not.
- Words competitors put in names across stores: Clipboard, Paste, Keyboard, Manager, Auto, Copy, Text Expander, Snippet. Subtitle verbs: Copy, Paste, Organize, Save, Search, Sync, Shortcuts, Replies.
- Terms nobody owns with real ratings: personal-data phrases (address, ID, bank account, e-mail), "canned replies" in a keyboard sense outside Taiwan and Japan, and the local snippet words in DE, FR, BR, ID, TR, IT, ES, MX.
- Trademarks Cutling must not put in keywords, name or subtitle: Paste (Paste Team, plus "Paste Keyboard"), TextExpander (TextExpander, Inc.), Clipy, WordBoard, Copied, Phraser, PastePal, OneTap, Clipboard++, CannedText, EasyPaste, Maccy, Yoink, Rocket Typist, Snippety, PhraseExpress, TypeIt4Me. The generic words clipboard, snippet, keyboard are fine.

### US

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [WordBoard: Text Expander](https://apps.apple.com/us/app/id960167417) | Snippets, Shortcuts & AI Keys | 5580 | Free |
| [Paste Keyboard](https://apps.apple.com/us/app/id1066723174) | Super Easy Copy&Paste Keyboard | 44286 | Free |
| [Copied: Workspace Keyboard](https://apps.apple.com/us/app/id1517022963) | Text Shortcuts & Clipboard | 495 | Free |
| [Clipboard : Keyboard Manager](https://apps.apple.com/us/app/id1633027266) | Copy, Paste & Organize Data | 466 | Free |
| [Clipboard - Paste Keyboard](https://apps.apple.com/us/app/id1514741180) | Auto Copy and Paste Keyboard | 1847 | Free |
| [Paste – Limitless Clipboard](https://apps.apple.com/us/app/id967805235) | Copy, Search, Manage, Share | 1323 | Free |
| [Rocket Keyboard: Text Expander](https://apps.apple.com/us/app/id947029839) | Quick Replies & Paste Keyboard | 7 | Free |
| [LazyBoard: Keyboard](https://apps.apple.com/us/app/id1459047306) | Clipboard & Shortcuts | 588 | Free |
| [TextExpander](https://apps.apple.com/us/app/id6805960547) † | Your snippets in every app. | 5 | Free |

**Patterns.** Names use clipboard, paste, keyboard, text expander. Subtitles use copy, paste, snippets, shortcuts, replies. Leaders: Paste Keyboard 44,286 ratings, WordBoard 5,580; the rest are under 2,000, so the head terms are hard and the long tail is open. Nobody mentions addresses, IDs, bank numbers or autofill of personal details; "canned replies" appears only in small apps (Canned Replies Keyboard 111 ratings). Taken names: Paste, TextExpander, WordBoard.

### GB

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [Paste Keyboard](https://apps.apple.com/gb/app/id1066723174) | Super Easy Copy&Paste Keyboard | 4178 | Free |
| [Clipboard : Keyboard Manager](https://apps.apple.com/gb/app/id1633027266) | Copy, Paste & Organize Data | 30 | Free |
| [WordBoard: Text Expander](https://apps.apple.com/gb/app/id960167417) | Snippets, Clipboard & Kaomoji | 249 | Free |
| [Clipboard - Paste Keyboard](https://apps.apple.com/gb/app/id1514741180) | Auto Copy and Paste Keyboard | 276 | Free |
| [Copied: Workspace Keyboard](https://apps.apple.com/gb/app/id1517022963) | Text Shortcuts & Clipboard | 51 | Free |
| [Paste – Limitless Clipboard](https://apps.apple.com/gb/app/id967805235) | Copy, Search, Manage, Share | 160 | Free |
| [Clipboard++](https://apps.apple.com/gb/app/id854707788) | (none; page shows the category) | 34 | Free |
| [TextExpander](https://apps.apple.com/gb/app/id6805960547) | Your snippets in every app. | 0 | Free |

**Patterns.** Same set as the US with smaller counts: Paste Keyboard 4,178, others under 300. "Snippets" and "Kaomoji" appear in WordBoard's subtitle. Nobody uses British phrasing such as "saved replies" for personal details.

### IN

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [Clipboard : Keyboard Manager](https://apps.apple.com/in/app/id1633027266) | Copy, Paste & Organize Data | 60 | Free |
| [Clipboard - Paste Keyboard](https://apps.apple.com/in/app/id1514741180) | Auto Copy and Paste Keyboard | 538 | Free |
| [Paste – Limitless Clipboard](https://apps.apple.com/in/app/id967805235) | Copy, Search, Manage, Share | 97 | Free |
| [Clipboard Manager - PastePal](https://apps.apple.com/in/app/id1503446680) | Copy Paste Keyboard History | 18 | Free |
| [WordBoard: Text Expander](https://apps.apple.com/in/app/id960167417) | Snippets, Clipboard & Kaomoji | 11 | Free |
| [Clipboard++](https://apps.apple.com/in/app/id854707788) | (none; page shows the category) | 67 | Free |
| [Copied: Workspace Keyboard](https://apps.apple.com/in/app/id1517022963) | Text Shortcuts & Clipboard | 10 | Free |
| [Clipboard Manager - Pastely](https://apps.apple.com/in/app/id6752802696) | Universal clipboard sync | 0 | Free |
| [Paste Keyboard](https://apps.apple.com/in/app/id1066723174) † | Super Easy Copy&Paste Keyboard | 90 | Free |
| [TextExpander](https://apps.apple.com/in/app/id6805960547) † | Your snippets in every app. | 0 | Free |

**Patterns.** Top rating count is 538 (Clipboard - Paste Keyboard); most are under 100. Cheapest storefront to rank in. English only; no Hindi names in the results.

### DE

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [Clipboard++](https://apps.apple.com/de/app/id854707788) | Dienst­programme | 22 | Gratis |
| [Paste – Zwischenablage-Manager](https://apps.apple.com/de/app/id967805235) | Kopiertes speichern & finden | 171 | Gratis |
| [Zwischenablage - EasyPaste](https://apps.apple.com/de/app/id6743236947) | Kopieren - Einfügen Tastatur | 1 | Gratis |
| [iCliper - Clipboard Keyboard](https://apps.apple.com/de/app/id6473295955) | Tastatur Text Fortgeschritten | 13 | Gratis |
| [+Zwischenablage - Text, Bild](https://apps.apple.com/de/app/id524303305) | Notizen kopieren und einfügen | 14 | Gratis |
| [Zwischenablage+](https://apps.apple.com/de/app/id6748193583) | Auto-Kopier-Einfüge-Tastatur | 0 | Gratis |
| [Auto Paste Keyboard](https://apps.apple.com/de/app/id1570011952) | AutoPaste & Auto Clicker | 2568 | Gratis |
| [Tastatur Kopieren und Einfügen](https://apps.apple.com/de/app/id1571451125) | Einfache Zwischenablage-App | 11 | Gratis |
| [Paste Keyboard](https://apps.apple.com/de/app/id1066723174) † | Dienst­programme | 836 | Gratis |
| [TextExpander](https://apps.apple.com/de/app/id6805960547) † | Produktivität | 0 | Gratis |
| [WordBoard: Text Expander](https://apps.apple.com/de/app/id960167417) † | Dienst­programme | 20 | Gratis |

**Patterns.** German names use the loanword Zwischenablage; subtitles use kopieren, einfügen, Tastatur, Textbausteine only in small apps (SnipIt, Snippet Kit, 0 ratings). Leaders: Auto Paste Keyboard 2,568 (an auto-clicker, not a snippet app), Paste Keyboard 836, Paste 171. Nobody owns Textbausteine plus Tastatur with real ratings.

### JP

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [コピペ帳〜 素早くコピー＆ペースト](https://apps.apple.com/jp/app/id1448631013) | 仕事効率化 | 3124 | 無料 |
| [定型文 & コピペ履歴キーボード CannedText](https://apps.apple.com/jp/app/id919137334) | コピーしたテキスト、テンプレ爆速入力。クリップボード自動記録 | 293 | 無料 |
| [コピペキーボード - 定型文をキーボードから一瞬で入力](https://apps.apple.com/jp/app/id6756287687) | 定型文もクリップボードもこれ一つでキーボードから使える | 25 | 無料 |
| [コピペ＋ - ウィジェットで簡単コピー＆ペースト -](https://apps.apple.com/jp/app/id953228437) | シンプルで簡単操作の人気クリップボード管理アプリ | 3471 | 無料 |
| [クリップボード 文字 - ペースト コピーアプリ](https://apps.apple.com/jp/app/id1514741180) | ウィジェットで簡単コピペショートカット | 322 | 無料 |
| [WordBoard - 自動コピーペーストキーボード](https://apps.apple.com/jp/app/id960167417) | ショートカット。入力。フォーム。絵文字。テキスト。 | 898 | 無料 |
| [CopyCenter 2](https://apps.apple.com/jp/app/id919379392) | コピペするならコピーセンター！ | 441 | 無料 |
| [BetterClip](https://apps.apple.com/jp/app/id1485555078) | あなたの時間を節約する、より良いコピペ管理アプリ | 171 | 無料 |
| [Paste – クリップボード管理](https://apps.apple.com/jp/app/id967805235) † | コピーしたものを保存・検索・同期 | 285 | 無料 |
| [コピペキーボード](https://apps.apple.com/jp/app/id1066723174) † | Easy Copy & Paste Keyboard | 148 | 無料 |
| [TextExpander](https://apps.apple.com/jp/app/id6805960547) † | 仕事効率化 | 1 | 無料 |

**Patterns.** The most mature market: コピペ, 定型文, クリップボード and キーボード in names; the leaders are コピペ帳 (3,124) and コピペ＋ (3,471), both widget-led. Subtitles are full sentences (爆速入力, 一瞬で入力). 定型文 is held by CannedText (293) and コピペキーボード (25). Nobody ties 定型文 to addresses or bank details (住所, 口座).

### FR

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [OneTap: Gestion Presse-papiers](https://apps.apple.com/fr/app/id1639795583) | Copier-Coller & Raccourcis | 37 | Gratuit |
| [Paste – Gestion presse-papiers](https://apps.apple.com/fr/app/id967805235) | Copier, chercher, synchroniser | 96 | Gratuit |
| [ClipBox: Presse-papiers](https://apps.apple.com/fr/app/id1036140929) | Historique, Copier et Coller | 0 | Gratuit |
| [Clipboard Presse Papier](https://apps.apple.com/fr/app/id6503147033) | Clavier Copier Coller Vite | 9 | Gratuit |
| [Presse papiers : raccourcis](https://apps.apple.com/fr/app/id6741728223) | Copier, coller, partager gérer | 1 | Gratuit |
| [Clippo - Presse-papiers](https://apps.apple.com/fr/app/id1092865336) | Couteau suisse presse-papiers | 2 | Gratuit |
| [SingleTap – Presse-papiers](https://apps.apple.com/fr/app/id6755674254) | Copier-coller rapide | 0 | Gratuit |
| [Presse-papiers: Copier Coller](https://apps.apple.com/fr/app/id6759264853) | Textes favoris copiés en 1 tap | 0 | Gratuit |
| [Paste Keyboard](https://apps.apple.com/fr/app/id1066723174) † | Utilitaires | 994 | Gratuit |
| [TextExpander](https://apps.apple.com/fr/app/id6805960547) † | Productivité | 1 | Gratuit |
| [WordBoard: Text Expander](https://apps.apple.com/fr/app/id960167417) † | Utilitaires | 27 | Gratuit |

**Patterns.** Names are almost all presse-papiers. Largest result is Paste Keyboard at 994; every ranked app is under 100. Subtitles use copier, coller, raccourcis, historique. Nobody uses texte rapide, réponses, or coordonnées.

### BR

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [+Clipboard copiar,cortar,colar](https://apps.apple.com/br/app/id524303305) | Salvar textos, imagens, dados | 18 | Grátis |
| [iCliper: Área de transferência](https://apps.apple.com/br/app/id6473295955) | Copiar e colar rapidamente | 3 | Grátis |
| [OneTap: Área de Transferência](https://apps.apple.com/br/app/id1639795583) | Histórico e Atalhos de Colar | 13 | Grátis |
| [Paste – Área de Transferência](https://apps.apple.com/br/app/id967805235) | Salve e busque tudo que copia | 54 | Grátis |
| [Clipboard : Keyboard Manager](https://apps.apple.com/br/app/id1633027266) | Utilidades | 31 | Grátis |
| [ClipBox: Área de Transferência](https://apps.apple.com/br/app/id1036140929) | Histórico, Copiar e Colar | 2 | Grátis |
| [Clipboard++](https://apps.apple.com/br/app/id854707788) | Utilidades | 1 | Grátis |
| [Área de transferência: Atalhos](https://apps.apple.com/br/app/id6741728223) | Copiar, colar, compartilhar | 20 | Grátis |
| [Paste Keyboard](https://apps.apple.com/br/app/id1066723174) † | Utilidades | 79 | Grátis |
| [TextExpander](https://apps.apple.com/br/app/id6805960547) † | Produtividade | 0 | Grátis |
| [Auto Paste Keyboard Ad-Free](https://apps.apple.com/br/app/id960167417) † | Text Snippet Expand & Autofill | 43 | Grátis |

**Patterns.** Names use Área de transferência; subtitles use copiar, colar, histórico, atalhos. All under 100 ratings. frases prontas / mensagens prontas results are WhatsApp greeting apps, not keyboards, so the snippet-keyboard meaning is unowned.

### KR

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [Copied: 텍스트대치, 영업 및 붙여넣기 키보드](https://apps.apple.com/kr/app/id1517022963) | 클립보드 기록, 상용구, 자동완성 및 메모장 | 18 | 무료 |
| [문자복사 관리자 - 간단 복사, 정리 툴](https://apps.apple.com/kr/app/id1514741180) | 복사, 쉬운 해시태그 작성 클립 | 404 | 무료 |
| [클립보드 - EasyPaste 복사 붙여넣기 키보드](https://apps.apple.com/kr/app/id6743236947) | 복사 붙여넣기 키보드, , 키보드 계산기 | 1 | 무료 |
| [복붙키보드](https://apps.apple.com/kr/app/id1066723174) | 빠르고 가벼운 복사 붙여넣기 전세계 1위 키보드 | 484 | 무료 |
| [Clipboard : Keyboard Manager](https://apps.apple.com/kr/app/id1633027266) | 유틸리티 | 47 | 무료 |
| [클립키보드](https://apps.apple.com/kr/app/id1543660502) | 상용구·자주 쓰는 문구 빠른 입력 | 16 | 무료 |
| [복사 붙여넣기 키보드 - TapPaste](https://apps.apple.com/kr/app/id6756998433) | 답장·링크·상용구 바로 저장 | 4 | 무료 |
| [나만의 문구 키보드 상용구 스니펫 템플릿 붙여넣기](https://apps.apple.com/kr/app/id6774947061) | 어떤 앱에서나 빠르게 입력하기 | 0 | 무료 |
| [Paste – Limitless Clipboard](https://apps.apple.com/kr/app/id967805235) † | 생산성 | 28 | 무료 |
| [TextExpander](https://apps.apple.com/kr/app/id6805960547) † | 생산성 | 0 | 무료 |
| [Copy and Paste Keyboard](https://apps.apple.com/kr/app/id960167417) † | Auto Reply Text Workflow App | 18 | 무료 |

**Patterns.** Names use 클립보드, 복붙, 복사 붙여넣기 키보드; 상용구 appears in subtitles (Copied, 클립키보드, TapPaste). Leaders 복붙키보드 484 and 문자복사 관리자 404. 상용구 and 키보드 together are used by apps with fewer than 20 ratings.

### CN

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [QuickPaste：剪贴板粘贴板键盘高效黏贴剪切快捷计算](https://apps.apple.com/cn/app/id6755954671) | 便捷键盘&支持分词&多内容复制粘贴&常用语神器&剪贴板助手 | 49 | 免费 |
| [EasyPaste - 高效剪贴板键盘 连续复制粘贴 快易贴](https://apps.apple.com/cn/app/id6743236947) | 文本分类管理，支持分词，多内容复制，键盘计算器，复制粘贴键盘 | 560 | 免费 |
| [Clipster - 便捷纯粹 注重隐私的剪贴板键盘工具](https://apps.apple.com/cn/app/id6759727436) | 剪贴板键盘：内容归类、前句匹配、持续监控、分词大爆炸、计算器 | 14 | 免费 |
| [懒懒键盘: Typeless AI输入法, 常用语剪切板工具](https://apps.apple.com/cn/app/id6756532440) | 常用回复·话术库·Prompt角色 | 14 | 免费 |
| [FastCopy-快速复制常用语](https://apps.apple.com/cn/app/id1019457990) | 节省你的打字时间 | 336 | 免费 |
| [复制和粘贴键盘](https://apps.apple.com/cn/app/id1571451125) | 适用于 iPhone 的简易剪贴板应用程序 | 414 | 免费 |
| [剪贴板键盘 - TapPaste](https://apps.apple.com/cn/app/id6756998433) | 保存常用语，键盘直接粘贴 | 0 | 免费 |
| [剪贴板](https://apps.apple.com/cn/app/id6751185139) | 小巧本地存储无广告 | 16 | 免费 |
| [Paste – 剪贴板管理工具](https://apps.apple.com/cn/app/id967805235) † | 保存、搜索、同步复制的一切 | 160 | 免费 |
| [Paste Keyboard](https://apps.apple.com/cn/app/id1066723174) † | 工具 | 26 | 免费 |
| [TextExpander](https://apps.apple.com/cn/app/id6805960547) † | 效率 | 0 | 免费 |
| [WordBoard - 短语键盘](https://apps.apple.com/cn/app/id960167417) † | 一键式输入短语 | 55 | 免费 |

**Patterns.** Names stack 剪贴板, 键盘, 粘贴; subtitles are long comma lists (分词, 常用语, 计算器). Leader in this set EasyPaste 560 (复制清单 has 1,550 but ranks lower). 常用语 is used by several small apps. Keyword stuffing is the norm, so a short clean name stands out.

### ID

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [Clipboard - Paste Keyboard](https://apps.apple.com/id/app/id1514741180) | Auto Copy and Paste Keyboard | 704 | Free |
| [Clipboard : Keyboard Manager](https://apps.apple.com/id/app/id1633027266) | Copy, Paste & Organize Data | 57 | Free |
| [Clipboard++](https://apps.apple.com/id/app/id854707788) | (none; page shows the category) | 21 | Free |
| [iCliper - Clipboard Manager](https://apps.apple.com/id/app/id6473295955) | Auto Copy and Paste Keyboard | 1 | Free |
| [Clipboard: Copy Paste Keyboard](https://apps.apple.com/id/app/id6804240016) | Auto save your clipboard | 2 | Free |
| [+Clipboard - copy, cut & paste](https://apps.apple.com/id/app/id524303305) | Texts, links, snippets manager | 3 | Free |
| [Clipboard Manager - OneTap](https://apps.apple.com/id/app/id1639795583) | Copy Paste History & Shortcuts | 10 | Free |
| [Paste Keyboard](https://apps.apple.com/id/app/id1066723174) | Super Easy Copy&Paste Keyboard | 83 | Free |
| [Paste – Limitless Clipboard](https://apps.apple.com/id/app/id967805235) † | Copy, Search, Manage, Share | 10 | Free |
| [TextExpander](https://apps.apple.com/id/app/id6805960547) † | Your snippets in every app. | 0 | Free |
| [WordBoard: Text Expander](https://apps.apple.com/id/app/id960167417) † | Snippets, Clipboard & Kaomoji | 16 | Free |

**Patterns.** Almost all English names (Clipboard, Paste Keyboard). No Indonesian-language app ranks for papan klip or template chat; the leader is Clipboard - Paste Keyboard (704). Indonesian terms are effectively unowned.

### ES

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [Copy And Paste Keyboard +](https://apps.apple.com/es/app/id1633027266) | Auto Paste Keyboard Note App | 9 | Gratis |
| [Teclado de Pegar](https://apps.apple.com/es/app/id1066723174) | Super fácil for copiar y pegar | 97 | Gratis |
| [+Portapapeles - copiar y pegar](https://apps.apple.com/es/app/id524303305) | Organizador de textos,imágenes | 20 | Gratis |
| [SingleTap – Portapapeles](https://apps.apple.com/es/app/id6755674254) | Copia y pega rápido | 1 | Gratis |
| [Paste – Gestor de Portapapeles](https://apps.apple.com/es/app/id967805235) | Guarda, busca y sincroniza | 57 | Gratis |
| [ClipBox: Portapapeles](https://apps.apple.com/es/app/id1036140929) | Historial de Copiar y Pegar | 0 | Gratis |
| [Portapapeles Teclado Pegar](https://apps.apple.com/es/app/id6760254931) | Pegar texto rápido y plantilla | 0 | Gratis |
| [Clipboard Manager - OneTap](https://apps.apple.com/es/app/id1639795583) | Copy Paste History & Shortcuts | 9 | Gratis |
| [TextExpander](https://apps.apple.com/es/app/id6805960547) † | Productividad | 0 | Gratis |
| [WordBoard - Teclado de frases](https://apps.apple.com/es/app/id960167417) † | Escriba frases con un toque | 185 | Gratis |

**Patterns.** Names use Portapapeles and Teclado; subtitles copiar, pegar, rápido. Highest is Teclado de Pegar (97), WordBoard (185) as a lookup. Respuestas rápidas appears only in ReplyKit/QuickReply (under 3 ratings). Low difficulty.

### IT

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [Appunti+](https://apps.apple.com/it/app/id1609361989) | Quaderno & Notes & Note | 8086 | Gratis |
| [Clipboard Manager - OneTap](https://apps.apple.com/it/app/id1639795583) | Copy Paste History & Shortcuts | 6 | Gratis |
| [TextDeck: Comandi rapidi testo](https://apps.apple.com/it/app/id6761092608) | Appunti, macro, offline | 0 | Gratis |
| [Clipboard Manager - PastePal](https://apps.apple.com/it/app/id1503446680) | Utility | 12 | Gratis |
| [Tastiera di frasi: TypeShelf](https://apps.apple.com/it/app/id6743344539) | Risposte rapide e modelli | 0 | Gratis |
| [Clipboard : Keyboard Manager](https://apps.apple.com/it/app/id1633027266) | Utility | 11 | Gratis |
| [ReplyKit - Risposte rapide](https://apps.apple.com/it/app/id6761647620) | Modelli di testo e appunti | 2 | Gratis |
| [Clipbud - Clipboard Manager](https://apps.apple.com/it/app/id6468892359) | Produttività | 10 | Gratis |
| [Paste – Gestore Appunti](https://apps.apple.com/it/app/id967805235) † | Salva, cerca e sincronizza | 56 | Gratis |
| [Paste Keyboard](https://apps.apple.com/it/app/id1066723174) † | Utility | 176 | Gratis |
| [TextExpander](https://apps.apple.com/it/app/id6805960547) † | Produttività | 0 | Gratis |
| [WordBoard: Text Expander](https://apps.apple.com/it/app/id960167417) † | Utility | 116 | Gratis |

**Patterns.** Appunti is ambiguous (it also means notes): Appunti+ (8,086) is a notes app. Real clipboard apps are under 200 ratings (Paste Keyboard 176). Cutling already shows up here for "appunti". Risposte rapide and modelli are used only by 0 to 2 rating apps.

### NL

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [iCliper Klembord Manager Kopie](https://apps.apple.com/nl/app/id6473295955) | Toetsenbord, Clipboard Manager | 1 | Gratis |
| [ClipBox: Klembord Manager](https://apps.apple.com/nl/app/id1036140929) | Geschiedenis & Toetsenbord | 0 | Gratis |
| [Auto Paste Keyboard](https://apps.apple.com/nl/app/id1570011952) | AutoPaste & Auto Clicker | 2595 | Gratis |
| [Kopieer En Plak Toetsenbord](https://apps.apple.com/nl/app/id1571451125) | Eenvoudige klembord-app | 16 | Gratis |
| [Clipboard Manager - PastePal](https://apps.apple.com/nl/app/id1503446680) | Diensten | 10 | Gratis |
| [+Klembord - kopiëren & plakken](https://apps.apple.com/nl/app/id524303305) | Tekst, afbeelding organiseren | 4 | Gratis |
| [Clipboard : Keyboard Manager](https://apps.apple.com/nl/app/id1633027266) | Diensten | 7 | Gratis |
| [Fingertips: fragmenten](https://apps.apple.com/nl/app/id6798439217) | Je fragmenten, één toets | 0 | Gratis |
| [Paste – Limitless Clipboard](https://apps.apple.com/nl/app/id967805235) † | Productiviteit | 38 | Gratis |
| [Paste Keyboard](https://apps.apple.com/nl/app/id1066723174) † | Diensten | 681 | Gratis |
| [TextExpander](https://apps.apple.com/nl/app/id6805960547) † | Productiviteit | 0 | Gratis |
| [WordBoard: Text Expander](https://apps.apple.com/nl/app/id960167417) † | Diensten | 18 | Gratis |

**Patterns.** Names use Klembord; Auto Paste Keyboard (2,595) is an auto-clicker app. Paste Keyboard 681; the rest under 20. Many apps keep the English name "Clipboard Manager". Cutling already appears for klembord.

### RU

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [ClipBox: Буфер обмена](https://apps.apple.com/ru/app/id1036140929) | История и Клавиатура | 0 | Бесплатно |
| [Phraser - Paste Keyboard](https://apps.apple.com/ru/app/id1106396024) | Шаблоны текста под рукой | 7105 | Бесплатно |
| [Clipboard - Paste Keyboard](https://apps.apple.com/ru/app/id1514741180) | Auto Copy and Paste Keyboard | 267 | Бесплатно |
| [SingleTap – Буфер обмена](https://apps.apple.com/ru/app/id6755674254) | Быстрое копирование и вставка | 3 | Бесплатно |
| [Буфер обмена: клавиатура](https://apps.apple.com/ru/app/id6804240016) | Автосохранение скопированного | 0 | Бесплатно |
| [Буфер обмена Клавиатура](https://apps.apple.com/ru/app/id6503147033) | Повторить текст Вставить | 5 | Бесплатно |
| [LazyBoard: Клавиатура](https://apps.apple.com/ru/app/id1459047306) | Буфер обмена и ярлыки | 17 | Бесплатно |
| [Диспетчер Буфера - OneTap](https://apps.apple.com/ru/app/id1639795583) | История копирования и ярлыки | 11 | Бесплатно |
| [Paste – Limitless Clipboard](https://apps.apple.com/ru/app/id967805235) † | Производительность | 73 | Бесплатно |
| [Paste Keyboard](https://apps.apple.com/ru/app/id1066723174) † | Утилиты | 649 | Бесплатно |
| [TextExpander](https://apps.apple.com/ru/app/id6805960547) † | Производительность | 0 | Бесплатно |
| [Shortcuts Clipboard Keyboard](https://apps.apple.com/ru/app/id960167417) † | Autopaste. Snippet. Boards | 7 | Бесплатно |

**Patterns.** Names use Буфер обмена; Phraser - Paste Keyboard leads with 7,105 ratings and the subtitle Шаблоны текста под рукой. Everyone else is under 700. Шаблоны and фразы are owned by Phraser; Автосохранение, История are common in subtitles.

### MX

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [Copy And Paste Keyboard +](https://apps.apple.com/mx/app/id1633027266) | Auto Paste Keyboard Note App | 48 | Gratis |
| [Clipboard - Paste Keyboard](https://apps.apple.com/mx/app/id1514741180) | Auto Copy and Paste Keyboard | 120 | Gratis |
| [Paste – Gestor de Portapapeles](https://apps.apple.com/mx/app/id967805235) | Guarda, busca y sincroniza | 52 | Gratis |
| [ClipBox: Portapapeles](https://apps.apple.com/mx/app/id1036140929) | Historial de Copiar y Pegar | 0 | Gratis |
| [Teclado de Pegar](https://apps.apple.com/mx/app/id1066723174) | Super fácil for copiar y pegar | 430 | Gratis |
| [ReplyKit - Respuestas rápidas](https://apps.apple.com/mx/app/id6761647620) | Plantillas y atajos de texto | 2 | Gratis |
| [OneTap: Quản lý Clipboard](https://apps.apple.com/mx/app/id1639795583) | Historial y atajos | 32 | Gratis |
| [CopyNote: Atajos de teclado](https://apps.apple.com/mx/app/id1519660591) | Frases, plantillas, teclado | 0 | Gratis |
| [TextExpander](https://apps.apple.com/mx/app/id6805960547) † | Productividad | 0 | Gratis |
| [Copy Paste Keyboard: WordBoard](https://apps.apple.com/mx/app/id960167417) † | Autopaste, Shortcut & Kaomoji | 37 | Gratis |

**Patterns.** Same set as ES: Portapapeles, Teclado de Pegar, Respuestas rápidas. Leader Teclado de Pegar 430, the rest under 130. Frases / plantillas used only by 0 to 2 rating apps.

### TW

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [CannedText 複製貼上・常用句・剪貼簿鍵盤](https://apps.apple.com/tw/app/id919137334) | 客服回覆、常用語快捷輸入，罐頭訊息一鍵貼上 | 40 | 免費 |
| [FastBoard 飛速鍵盤 - 常用詞彙快速回覆](https://apps.apple.com/tw/app/id1462074199) | 儲存常用文字・一鍵貼上・剪貼簿複製・自動帶入・罐頭訊息 | 423 | 免費 |
| [EasyPaste - 高效剪貼簿鍵盤 連續復製粘貼 剪貼板](https://apps.apple.com/tw/app/id6743236947) | 文本分類管理，支持分詞，多內容復製，鍵盤計算器，復製粘貼鍵盤 | 37 | 免費 |
| [剪貼簿：鍵盤快速鍵](https://apps.apple.com/tw/app/id6741728223) | 複製、貼上、分享和管理 | 7 | 免費 |
| [複製清單 - 快速復制粘貼的文本工具](https://apps.apple.com/tw/app/id1514741180) | 一款支持連續複製粘貼的剪切板鍵盤 | 2063 | 免費 |
| [CopyNow - 自訂鍵盤與一鍵剪貼](https://apps.apple.com/tw/app/id6760156586) | 自訂鍵盤與快速複製貼上 | 52 | 免費 |
| [ClipBox: 剪貼簿管理工具](https://apps.apple.com/tw/app/id1036140929) | 複製貼上歷史與快捷鍵盤 | 4 | 免費 |
| [Kopycat 常用文字的鍵盤快捷鍵](https://apps.apple.com/tw/app/id6795369381) | 地址電話常用語，鍵盤一點就貼 | 4 | 免費 |
| [Paste – 剪貼簿管理工具](https://apps.apple.com/tw/app/id967805235) † | 儲存、搜尋、同步複製的一切 | 54 | 免費 |
| [Paste Keyboard](https://apps.apple.com/tw/app/id1066723174) † | 工具程式 | 75 | 免費 |
| [TextExpander](https://apps.apple.com/tw/app/id6805960547) † | 生產力工具 | 0 | 免費 |
| [WordBoard: Text Expander](https://apps.apple.com/tw/app/id960167417) † | 工具程式 | 35 | 免費 |

**Patterns.** Traditional characters: 剪貼簿 and 常用語 in names, 罐頭訊息 (canned messages) in subtitles. Leader 複製清單 (2,063), FastBoard 423. Several apps carry Simplified text in a Taiwan listing (復製, 剪貼板), which leaves 剪貼簿 plus 地址/銀行 specifics open.

### TR

| App | Subtitle | Ratings | Price |
|---|---|---|---|
| [+Clipboard - copy, cut & paste](https://apps.apple.com/tr/app/id524303305) | Texts, links, snippets manager | 8 | Free |
| [AutoPaste & Clipboard Manager](https://apps.apple.com/tr/app/id1659871053) | Auto Paste Keyboard,Copy, Spam | 7 | Free |
| [Clipboard Manager - OneTap](https://apps.apple.com/tr/app/id1639795583) | Copy Paste History & Shortcuts | 12 | Free |
| [ReplyKit - Quick Reply](https://apps.apple.com/tr/app/id6761647620) | Saved replies & Text Shortcuts | 0 | Free |
| [Clipboard : Keyboard Manager](https://apps.apple.com/tr/app/id1633027266) | Copy, Paste & Organize Data | 5 | Free |
| [Snippad: Smart AI Keyboard](https://apps.apple.com/tr/app/id6787169119) | Templates, translate, snippets | 6 | Free |
| [Clipboard++](https://apps.apple.com/tr/app/id854707788) | (none; page shows the category) | 8 | Free |
| [Auto Paste Keyboard: Auto Send](https://apps.apple.com/tr/app/id1570011952) | AutoPaste & Auto Clicker | 188 | Free |
| [Paste – Limitless Clipboard](https://apps.apple.com/tr/app/id967805235) † | Copy, Search, Manage, Share | 32 | Free |
| [Paste Keyboard](https://apps.apple.com/tr/app/id1066723174) † | Super Easy Copy&Paste Keyboard | 155 | Free |
| [TextExpander](https://apps.apple.com/tr/app/id6805960547) † | Your snippets in every app. | 0 | Free |
| [WordBoard: Text Expander](https://apps.apple.com/tr/app/id960167417) † | Snippets, Clipboard & Kaomoji | 3 | Free |

**Patterns.** Only 188 ratings at the top (Auto Paste Keyboard). Names and subtitles are English; no Turkish app ranks for pano or hazır metin. Turkish copy is a clear gap.

### Screenshots and previews

Fetched 2026-10-01. Screenshot URLs from the iTunes Lookup API (counts are per storefront); the first 3 iPhone screenshots are saved in `docs/aso/data/competitor-screens/<cc>/<appid>-<n>.jpg` and were read by eye. App Preview videos were detected from the app pages' own data (`videoUrl` entries in the page JSON, which fully render without JavaScript, so Chrome was not needed); the preview's opening seconds were decoded with ffmpeg. Covers the top 6 per storefront plus the anchors (Paste, Paste Keyboard, TextExpander, WordBoard) in US, GB, JP, DE, KR, BR. GB uses the same screenshot sets as the US for every app found there.

#### US

| App | Frames (iPhone/iPad) | Caption 1 | Caption 2 | Caption 3 | Frame 1 shows | Preview |
|---|---|---|---|---|---|---|
| [WordBoard: Text Expander](https://apps.apple.com/us/app/id960167417) | 6/7 | TYPE 10X FASTER | (frame 2) TAP KEYS / SEND MESSAGES | CREATE KEYBOARD SHORTCUTS | Hand holding a tilted iPhone with Messages and the snippet keyboard; Apple Featured / Great Apps for iOS 26 badge, 5 stars. Product working, device frame, blue light theme. | no |
| [Paste Keyboard](https://apps.apple.com/us/app/id1066723174) | 5/3 | Easy Copy Paste (New Update) | Simple, Quickly: use your messages | Easy Save: Add sample your messages | Tilted black iPhone showing the app's snippet list (Paste Keyboard, 'My instagram ID is @testuser', email, 'Love you'); teal background. Product UI in device frame, light mode. | no |
| [Copied: Workspace Keyboard](https://apps.apple.com/us/app/id1517022963) | 6/4 | Your Keyboard Your Rules | Respond Faster with Pre-Saved Texts | Easy paste clipboard | Two chat bubbles over a My Keys / Clipboard tab bar with keys (Support reply, Office address); no device frame, blue gradient. Product working, light-on-blue. | no |
| [Clipboard : Keyboard Manager](https://apps.apple.com/us/app/id1633027266) | 5/3 | The Best Clipboard Manager App | Save & Organize in Folders | Paste Directly From Clipboard Keyboard | Dark-mode iPhone frame with the 'Paste Manager' card grid; 'Best Utility App' laurel in frame 2. Product UI, dark mode, device frame. | no |
| [Clipboard - Paste Keyboard](https://apps.apple.com/us/app/id1514741180) | 4/4 | (no caption text) | (no caption text) | (no caption text) | Raw screenshot, no marketing text: colored tile grid of Address, Postage Code, SSN, John's email, Credit Card, Password, Account. Product UI, no device frame, light mode. Closest match to Cutling's use case. | yes (2) |
| [Paste – Limitless Clipboard](https://apps.apple.com/us/app/id967805235) | 9/9 | A Better Way to Copy and Paste | The limitless clipboard for your essentials (KEEP) | Find what you copied just now or long ago (SEARCH) | Headline over an iPhone, MacBook and iPad composite with cross-device clips; '10 Years on AppStore' laurels. Product UI, device frames, light mode. | no |
| [TextExpander](https://apps.apple.com/us/app/id6805960547) † | 7/1 | Every snippet, now on your phone | Auto-fill forms within any app | Suggested snippets as you type | TextExpander logo, headline, iPhone with keyboard showing ';email' snippet and a hand cursor; 'Trusted by over 100k users' laurel. Product working, device frame, orange gradient. | no |

#### GB

| App | Frames (iPhone/iPad) | Caption 1 | Caption 2 | Caption 3 | Frame 1 shows | Preview |
|---|---|---|---|---|---|---|
| [Paste Keyboard](https://apps.apple.com/gb/app/id1066723174) | 5/3 | Easy Copy Paste (New Update) | Simple, Quickly: use your messages | Easy Save: Add sample your messages | Tilted black iPhone showing the app's snippet list (Paste Keyboard, 'My instagram ID is @testuser', email, 'Love you'); teal background. Product UI in device frame, light mode. | no |
| [Clipboard : Keyboard Manager](https://apps.apple.com/gb/app/id1633027266) | 5/3 | The Best Clipboard Manager App | Save & Organize in Folders | Paste Directly From Clipboard Keyboard | Dark-mode iPhone frame with the 'Paste Manager' card grid; 'Best Utility App' laurel in frame 2. Product UI, dark mode, device frame. | no |
| [WordBoard: Text Expander](https://apps.apple.com/gb/app/id960167417) | 6/7 | TYPE 10X FASTER | (frame 2) TAP KEYS / SEND MESSAGES | CREATE KEYBOARD SHORTCUTS | Hand holding a tilted iPhone with Messages and the snippet keyboard; Apple Featured / Great Apps for iOS 26 badge, 5 stars. Product working, device frame, blue light theme. | no |
| [Clipboard - Paste Keyboard](https://apps.apple.com/gb/app/id1514741180) | 4/4 | (no caption text) | (no caption text) | (no caption text) | Raw screenshot, no marketing text: colored tile grid of Address, Postage Code, SSN, John's email, Credit Card, Password, Account. Product UI, no device frame, light mode. Closest match to Cutling's use case. | yes (2) |
| [Copied: Workspace Keyboard](https://apps.apple.com/gb/app/id1517022963) | 6/4 | Your Keyboard Your Rules | Respond Faster with Pre-Saved Texts | Easy paste clipboard | Two chat bubbles over a My Keys / Clipboard tab bar with keys (Support reply, Office address); no device frame, blue gradient. Product working, light-on-blue. | no |
| [Paste – Limitless Clipboard](https://apps.apple.com/gb/app/id967805235) | 9/9 | A Better Way to Copy and Paste | The limitless clipboard for your essentials (KEEP) | Find what you copied just now or long ago (SEARCH) | Headline over an iPhone, MacBook and iPad composite with cross-device clips; '10 Years on AppStore' laurels. Product UI, device frames, light mode. | no |
| [TextExpander](https://apps.apple.com/gb/app/id6805960547) † | 7/1 | Every snippet, now on your phone | Auto-fill forms within any app | Suggested snippets as you type | TextExpander logo, headline, iPhone with keyboard showing ';email' snippet and a hand cursor; 'Trusted by over 100k users' laurel. Product working, device frame, orange gradient. | no |

#### JP

| App | Frames (iPhone/iPad) | Caption 1 | Caption 2 | Caption 3 | Frame 1 shows | Preview |
|---|---|---|---|---|---|---|
| [コピペ帳〜 素早くコピー＆ペースト](https://apps.apple.com/jp/app/id1448631013) | 5/5 | コピペが簡単 (ワンタップでメモを素早くコピー) | 拡張キーボード | フォルダで楽々管理 | iPhone 8-era frame showing a memo list 'フリマアプリ用' (canned seller replies); blue background. Product UI, device frame, light mode. | no |
| [定型文 & コピペ履歴キーボード CannedText](https://apps.apple.com/jp/app/id919137334) | 5/5 | 定型文・コピペ 爆速入力 | 面倒な定型文入力 1回登録するだけ | コピー履歴 自動保存 | Messages thread with the snippet keyboard (カテゴリ: ビジネス, 住所, 電話番号). Product working, device frame, light mode. 定型文 is in caption 1. | no |
| [コピペキーボード - 定型文をキーボードから一瞬で入力](https://apps.apple.com/jp/app/id6756287687) | 6/3 | 使いやすさへのこだわり / 定型文もクリップボードも | (frame 2) 共有からワンタップで保存 flow with red arrows | カスタムキーボードで爆速コピペ | Large '定型文もクリップボードも' headline over a share-sheet and keyboard crop with red arrows. Product shown partly, no full device frame. | no |
| [コピペ＋ - ウィジェットで簡単コピー＆ペースト -](https://apps.apple.com/jp/app/id953228437) | 2/0 | コピペ＋ 超！作業効率UP！ | コピペが捗る！最強ウィジェット |  | List screen with a 'コピーしました' toast; only 2 iPhone screenshots. Widget on home screen in frame 2. Device frame, light mode. | no |
| [クリップボード 文字 - ペースト コピーアプリ](https://apps.apple.com/jp/app/id1514741180) | 4/4 | (no caption text) | (no caption text) | (no caption text) | Raw screenshot, no marketing text: colored tile grid of Address, Postage Code, SSN, John's email, Credit Card, Password, Account. Product UI, no device frame, light mode. Closest match to Cutling's use case. | yes (2) |
| [WordBoard - 自動コピーペーストキーボード](https://apps.apple.com/jp/app/id960167417) | 10/5 | メッセージをまとめて入力 1キーで送信 / 10倍速く返信 | すべてのアプリで使える LINE・メール・SNS・チャット | メッセージに絵文字・顔文字・GIFをすぐ追加 | Localised WordBoard set: '10倍速く返信' over an iPhone chat. Product working, device frame, blue. | no |
| [Paste – クリップボード管理](https://apps.apple.com/jp/app/id967805235) † | 9/9 | A Better Way to Copy and Paste | The limitless clipboard for your essentials (KEEP) | Find what you copied just now or long ago (SEARCH) | Headline over an iPhone, MacBook and iPad composite with cross-device clips; '10 Years on AppStore' laurels. Product UI, device frames, light mode. | no |
| [コピペキーボード](https://apps.apple.com/jp/app/id1066723174) † | 5/3 | 簡単で早いです。(New Update) | シンプル、迅速 あなたのメッセージを使う | 簡単な保存 メッセージを追加 | Same layout as the US Paste Keyboard set with Japanese captions and アプリ title コピペ・キーボード. | no |
| [TextExpander](https://apps.apple.com/jp/app/id6805960547) † | 7/1 | Every snippet, now on your phone | Auto-fill forms within any app | Suggested snippets as you type | TextExpander logo, headline, iPhone with keyboard showing ';email' snippet and a hand cursor; 'Trusted by over 100k users' laurel. Product working, device frame, orange gradient. | no |

#### DE

| App | Frames (iPhone/iPad) | Caption 1 | Caption 2 | Caption 3 | Frame 1 shows | Preview |
|---|---|---|---|---|---|---|
| [Clipboard++](https://apps.apple.com/de/app/id854707788) | 3/0 | clean & simple interface | hold tap to open item menu | open app to save copied text | English captions in a German listing; plain iPhone with a list, no keyboard shown. Product UI, device frame, light mode. | no |
| [Paste – Zwischenablage-Manager](https://apps.apple.com/de/app/id967805235) | 9/9 | A Better Way to Copy and Paste | The limitless clipboard for your essentials (KEEP) | Find what you copied just now or long ago (SEARCH) | Headline over an iPhone, MacBook and iPad composite with cross-device clips; '10 Years on AppStore' laurels. Product UI, device frames, light mode. | no |
| [Zwischenablage - EasyPaste](https://apps.apple.com/de/app/id6743236947) | 5/5 | Schnelltastatur: Antworten Sie bequemer. Einheitlicher Apple-Designstil. | Segmentierung / Berechnung: Sätze umstellen, schnell rechnen. | Inhaltsverwaltung: Listen ordnen, doppelte Effizienz. | Perspective iPhones with the keyboard in a Messages thread; calculator keyboard in frame 2. Product working, device frames, light blue. | no |
| [iCliper - Clipboard Keyboard](https://apps.apple.com/de/app/id6473295955) | 5/5 | Quickly Access Your Clipboard History | Keep Your Clipboard Organized | Never Lose Your Copied Text Again | English captions in a German listing: iPhone with a Reminders sheet and the clipboard keyboard strip. Product working, device frame, blue background. | no |
| [+Zwischenablage - Text, Bild](https://apps.apple.com/de/app/id524303305) | 4/4 | Synchronisation: Automatisches Speichern des Inhalts der System-Zwischenablage | Einfaches Abrufen: Antippen, um den Clip in die Systemablage zu kopieren | Spezialtastatur: Abrufen von Clips überall und zu jeder Zeit | iPhone 8 frame with a clip grid (Heute / Gestern), mostly CJK dictionary images. Product UI, device frame, light blue. | no |
| [Zwischenablage+](https://apps.apple.com/de/app/id6748193583) | 6/0 | Lange Texte? Keywords sofort teilen | Nahtlos auf iPhone und iPad | Kopieren & Einfügen stärker denn je | Before/after keyboard crops with sample sentences and a 'Teste deinen smarten Clipboard-Assistenten!' banner; text-heavy. Product working, light blue. | no |
| [Paste Keyboard](https://apps.apple.com/de/app/id1066723174) † | 5/3 | Easy Copy Paste (New Update) | Simple, Quickly: use your messages | Easy Save: Add sample your messages | Tilted black iPhone showing the app's snippet list (Paste Keyboard, 'My instagram ID is @testuser', email, 'Love you'); teal background. Product UI in device frame, light mode. | no |
| [TextExpander](https://apps.apple.com/de/app/id6805960547) † | 7/1 | Every snippet, now on your phone | Auto-fill forms within any app | Suggested snippets as you type | TextExpander logo, headline, iPhone with keyboard showing ';email' snippet and a hand cursor; 'Trusted by over 100k users' laurel. Product working, device frame, orange gradient. | no |
| [WordBoard: Text Expander](https://apps.apple.com/de/app/id960167417) † | 6/7 | TYPE 10X FASTER | (frame 2) TAP KEYS / SEND MESSAGES | CREATE KEYBOARD SHORTCUTS | Hand holding a tilted iPhone with Messages and the snippet keyboard; Apple Featured / Great Apps for iOS 26 badge, 5 stars. Product working, device frame, blue light theme. | no |

#### KR

| App | Frames (iPhone/iPad) | Caption 1 | Caption 2 | Caption 3 | Frame 1 shows | Preview |
|---|---|---|---|---|---|---|
| [Copied: 텍스트대치, 영업 및 붙여넣기 키보드](https://apps.apple.com/kr/app/id1517022963) | 8/4 | 같은 내용을 반복해서 입력하지 마세요 | 클립보드 / 키보드 내 히스토리 | 탭 한 번으로 어디서나 붙여넣기 | Blue slide with a ghost keyboard and a 'My Key' button, 4.6/5 rating laurel and a user quote. Product shown as a keyboard mock, no device frame. | no |
| [문자복사 관리자 - 간단 복사, 정리 툴](https://apps.apple.com/kr/app/id1514741180) | 4/4 | (no caption text) | (no caption text) | (no caption text) | Raw screenshot, no marketing text: colored tile grid of Address, Postage Code, SSN, John's email, Credit Card, Password, Account. Product UI, no device frame, light mode. Closest match to Cutling's use case. | yes (2) |
| [클립보드 - EasyPaste 복사 붙여넣기 키보드](https://apps.apple.com/kr/app/id6743236947) | 5/5 | 빠른 키보드: 응답이 더욱 간편해집니다. 통일된 Apple 디자인 스타일. | 분할/계산 | 콘텐츠 관리 | Same EasyPaste layout as the DE set, translated. | no |
| [복붙키보드](https://apps.apple.com/kr/app/id1066723174) | 5/3 | 더욱 새로워졌습니다 (New Update) | 자주 쓰는 메모들을 빠르게 사용할 수 있어요 | 자주 쓰는 메모들을 저장해보세요 | Same Paste Keyboard layout as US with Korean captions. | no |
| [Clipboard : Keyboard Manager](https://apps.apple.com/kr/app/id1633027266) | 5/3 | The Best Clipboard Manager App | Save & Organize in Folders | Paste Directly From Clipboard Keyboard | Dark-mode iPhone frame with the 'Paste Manager' card grid; 'Best Utility App' laurel in frame 2. Product UI, dark mode, device frame. | no |
| [클립키보드](https://apps.apple.com/kr/app/id1543660502) | 3/2 | 클립 키보드 / 빠른 문구작성 | 한 번의 탭, 적은 터치 | 더 이상 기억하지 마세요 | Dark slide: tilted iPhone with a chat asking for an address and the keyboard with Combo/saved items (address 'Sunset Boulevard'); this is address-style content. Product working, device frame. | no |
| [Paste – Limitless Clipboard](https://apps.apple.com/kr/app/id967805235) † | 9/9 | A Better Way to Copy and Paste | The limitless clipboard for your essentials (KEEP) | Find what you copied just now or long ago (SEARCH) | Headline over an iPhone, MacBook and iPad composite with cross-device clips; '10 Years on AppStore' laurels. Product UI, device frames, light mode. | no |
| [TextExpander](https://apps.apple.com/kr/app/id6805960547) † | 7/1 | Every snippet, now on your phone | Auto-fill forms within any app | Suggested snippets as you type | TextExpander logo, headline, iPhone with keyboard showing ';email' snippet and a hand cursor; 'Trusted by over 100k users' laurel. Product working, device frame, orange gradient. | no |
| [Copy and Paste Keyboard](https://apps.apple.com/kr/app/id960167417) † | 6/7 | TYPE 10X FASTER | (frame 2) TAP KEYS / SEND MESSAGES | CREATE KEYBOARD SHORTCUTS | Hand holding a tilted iPhone with Messages and the snippet keyboard; Apple Featured / Great Apps for iOS 26 badge, 5 stars. Product working, device frame, blue light theme. | no |

#### BR

| App | Frames (iPhone/iPad) | Caption 1 | Caption 2 | Caption 3 | Frame 1 shows | Preview |
|---|---|---|---|---|---|---|
| [+Clipboard copiar,cortar,colar](https://apps.apple.com/br/app/id524303305) | 4/4 | Sincronização: Auto-salvamento do conteúdo da área de transferência | Fácil recuperação: Tocar para copiar para a área de transferência | Teclado especializado: Recuperar clipes em qualquer lugar e a qualquer momento | Portuguese version of the +Clipboard set: iPhone 8 frame with Hoje / Ontem clip grid. | no |
| [iCliper: Área de transferência](https://apps.apple.com/br/app/id6473295955) | 5/5 | Acesse rapidamente o histórico da sua área de transferência | Mantenha sua área de transferência organizada | Nunca mais perca seu texto copiado | Portuguese version of the iCliper set: iPhone with Reminders sheet and clipboard strip. Product working, device frame, blue. | no |
| [OneTap: Área de Transferência](https://apps.apple.com/br/app/id1639795583) | 9/9 | Share anything from your keyboard... | With OneTap Keyboard Shortcuts. | Organize your shortcuts in Folders. | English captions in a Brazilian listing; floating link chips (TikTok Profile, Portfolio Link) around a dark-mode keyboard. Dark mode, device frame in frames 2-3. | no |
| [Paste – Área de Transferência](https://apps.apple.com/br/app/id967805235) | 9/9 | A Better Way to Copy and Paste | The limitless clipboard for your essentials (KEEP) | Find what you copied just now or long ago (SEARCH) | Headline over an iPhone, MacBook and iPad composite with cross-device clips; '10 Years on AppStore' laurels. Product UI, device frames, light mode. | no |
| [Clipboard : Keyboard Manager](https://apps.apple.com/br/app/id1633027266) | 5/3 | The Best Clipboard Manager App | Save & Organize in Folders | Paste Directly From Clipboard Keyboard | Dark-mode iPhone frame with the 'Paste Manager' card grid; 'Best Utility App' laurel in frame 2. Product UI, dark mode, device frame. | no |
| [ClipBox: Área de Transferência](https://apps.apple.com/br/app/id1036140929) | 6/6 | Nunca perca o que copiou. (HISTÓRICO DA ÁREA DE TRANSFERÊNCIA · COPIAR · COLAR) | Seus clips em todos os dispositivos. (ICLOUD · MAC · IPHONE · IPAD) | Continue de onde parou. (ICLOUD · SINCRONIZADO EM TODO LUGAR) | Light iPhone showing the ClipBox card grid with Office / Home / Family chips; Mac and iPad composites in frame 2. | no |
| [Paste Keyboard](https://apps.apple.com/br/app/id1066723174) † | 5/3 | Easy Copy Paste (New Update) | Simple, Quickly: use your messages | Easy Save: Add sample your messages | Tilted black iPhone showing the app's snippet list (Paste Keyboard, 'My instagram ID is @testuser', email, 'Love you'); teal background. Product UI in device frame, light mode. | no |
| [TextExpander](https://apps.apple.com/br/app/id6805960547) † | 7/1 | Every snippet, now on your phone | Auto-fill forms within any app | Suggested snippets as you type | TextExpander logo, headline, iPhone with keyboard showing ';email' snippet and a hand cursor; 'Trusted by over 100k users' laurel. Product working, device frame, orange gradient. | no |
| [Auto Paste Keyboard Ad-Free](https://apps.apple.com/br/app/id960167417) † | 6/7 | TYPE 10X FASTER | (frame 2) TAP KEYS / SEND MESSAGES | CREATE KEYBOARD SHORTCUTS | Hand holding a tilted iPhone with Messages and the snippet keyboard; Apple Featured / Great Apps for iOS 26 badge, 5 stars. Product working, device frame, blue light theme. | no |

#### Patterns

- **Search words in caption 1.** Only two of the English sets repeat a search word: "Clipboard" (The Best Clipboard Manager App; Quickly Access Your Clipboard History; the Zwischenablage / área de transferência translations) and "Copy Paste" (Easy Copy Paste). The others lead with a benefit (Type 10x Faster, Every snippet now on your phone, Your Keyboard Your Rules). In Japan caption 1 carries the market's own terms: 定型文・コピペ 爆速入力, コピペが簡単, 定型文もクリップボードも, メッセージをまとめて入力. In Korea caption 1 is a pain statement (같은 내용을 반복해서 입력하지 마세요) or 클립 키보드. Several DE and BR listings reuse English captions untranslated (clean & simple interface; Share anything from your keyboard), so a native-language caption 1 is uncommon there.
- **Caption size.** Large, 2 to 4 lines, bold, filling the top third in every marketing-style set (WordBoard, Copied, TextExpander, CannedText, コピペ帳). Paste's headline is smaller but still the top left. The exceptions are raw screenshots with no caption at all (Clipboard - Paste Keyboard).
- **What frame 1 shows.** Most of the 26 distinct sets show the product working inside a device frame, usually a Messages thread with the keyboard open. Dark-mode frames: Clipboard Manager Keyboard (all three), OneTap, the Clipboard - Paste Keyboard preview. Nobody in the sample shows a widget except コピペ＋ (frame 2) and Paste (iPad/Mac composite).
- **Personal-data examples.** Only a few sets show addresses or IDs as saved content: Clipboard - Paste Keyboard (Address Delivery, SSN, Credit Card, Password; also in its video), 클립키보드 (address, passport number), CannedText (会社住所, 電話番号), Paste Keyboard (instagram ID, email). The address/ID/bank-number story is told in screenshots by two or three small apps and in no caption headline.
- **Preview videos.** Only 1 of the 26 distinct screenshot sets checked has App Preview videos: Clipboard - Paste Keyboard (2 previews). Paste, Paste Keyboard, WordBoard, TextExpander, Copied, CannedText, コピペ帳 and every other one in the sample have none, so a short preview is a cheap differentiator.
- **Screenshot counts.** Most use 4 to 6 iPhone frames (Paste 9, WordBoard 6 to 10, OneTap 9); コピペ＋ uses 2 and Clipboard++ 3. Cutling can fill up to 10.
