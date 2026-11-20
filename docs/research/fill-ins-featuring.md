# Fill-ins: nominating Cutling for App Store featuring

Card ASG89. All Apple pages were fetched with curl on 2026-11-21 and saved in `fill-ins-featuring-src/` (rows in `fill-ins-featuring-src/notes.md`). Chrome was not needed: every page came back whole, no JavaScript shell. Anything not read from a source is marked GUESS; anything unconfirmed is UNSURE. Nothing was submitted or signed into.

## Blocker to know first

`docs/fill-ins.md` says fill-ins are off in every build (`FillIns.isOn` false) until the owner approves the redesigned screens (cards ASG84 to ASG91). Apple's editors play the build they feature (Meet with Apple, below), so a nomination needs a TestFlight build with fill-ins on, or a later build where they are on for everyone. Owner decision: which build the TestFlight link points to.

## 1. The form: fields, limits, types, lead time

Source: App Store Connect Help, "Nominate your app for featuring" https://developer.apple.com/help/app-store-connect/manage-featuring-nominations/nominate-your-app-for-featuring/ (no page date shown; copyright 2026; saved `help_nominate-your-app-for-featuring.html`), and the CSV reference https://developer.apple.com/help/app-store-connect/reference/nominations/nominations-template (saved `help_nominations-template.html`).

Required role: Account Holder, Admin, App Manager or Marketing.

| Field | Limit or rule | Source |
|---|---|---|
| Nomination name | 60 characters max | template page |
| Nomination type | exactly one of New Content, App Enhancements, App Launch | both pages |
| Nomination description | 1,000 characters max; "purpose and priority level", specific details, objectives | template page; help page |
| Publish date (start) and (end) | a day, or a custom range; YYYY-MM-DD in the CSV; local timezone in the UI | both |
| Related apps | the app plus up to 9 more (10 total, same account) | both |
| Platforms | iOS (iPhone), iOS (iPad), macOS, tvOS, watchOS, visionOS; "In-App Events are only available on iPhone and iPad apps" | both |
| Relevant countries or regions | defaults to where the app is available; editable; 3-letter ISO codes in CSV | both |
| Launch in certain markets first? | Yes or No | template |
| New In-App Event for this nomination? | Yes or No | template |
| Related In-App Events | attach existing; up to 25 IDs; "attaching as early as possible" recommended | both |
| Localizations | pre-filled from the app; editable | both |
| Supplemental materials | up to 5 URLs; may include TestFlight public links, documents, art | both |
| Pre-order? | Yes or No | template |
| Helpful details | 500 characters max (CSV); accessibility, inclusivity, priority, anything unique about app or team | template; help page |

- Draft, edit and archive: UI nominations save as drafts; CSV imports submit at once and cannot be drafts. After submitting, the type and related apps cannot be changed; other fields can. Archived ones cannot be restored. Duplicate does not copy publish date, platforms, market-first plans or supplemental materials.
- UNSURE: the help page gives no character limits for the UI fields; the 60, 1,000 and 500 limits are the CSV template's. GUESS: the UI uses the same limits. Only a signed-in look at the real form settles it, and that was not done.
- Lead time, three Apple statements that differ: "give our team a minimum of two weeks notice... up to three months in advance" (https://developer.apple.com/app-store/getting-featured/, saved `developer_apple_com_app-store_getting-featured_.html`); "minimum lead time of 3 weeks" (help page); "at least three weeks in advance" and, for a story, "about eight weeks" (Meet with Apple, below). Plan on 8 weeks before the release date, which satisfies all three.
- Not-yet-released update: yes. The help page says to "submit your plans" and describe "what changes are coming", with a future publish date, and WWDC24 describes it as "upcoming content and enhancements" (https://developer.apple.com/videos/play/wwdc2024/10063/, published 2024-06-13, saved `wwdc24-10063.html`). Editors can be given a TestFlight link.
- Separate nominations per dated update: "submit those as individual nominations"; dates can be changed later (Meet with Apple 249, https://developer.apple.com/videos/play/meet-with-apple/249, published 2025-12-17, speaker is the games editorial team, saved `mwa249.html`). They "check these nominations every week" there.
- Which type fits fill-ins: App Enhancements ("new features, functionality, or other significant updates"). Not New Content (content, offers, events), not App Launch (launch or pre-order of a new app).

## 2. What editors say they look for

Source: https://developer.apple.com/app-store/getting-featured/ (read 2026-11-21, no page date). "no checklist of requirements for getting featured". The factors it lists: user experience ("Cohesive, efficient, and valuable functionality"), UI design, Innovation ("New technologies that solve a unique problem"), Uniqueness ("A fresh approach to a familiar category"), Accessibility ("A great experience for a broad range of users"), Localization ("High-quality support for multiple languages"), and App Store product page (screenshots, previews, descriptions, ratings). It also says Apple is "always looking to highlight... significant updates".

- Games talk, but the same team and tool: Meet with Apple 249 says editors weigh UI and flow, "OS and device specific features", and that "localization and accessibility are also important". It also says there is "no featuring checklist". Games-only, so use as context, not as a rule for utilities.
- WWDC26 App Store Connect Group Lab, https://developer.apple.com/videos/play/wwdc2026/8010/ (published 2026-06-11, saved `wwdc26-8010.html`), answer to "Any tips for creating a successful featuring nomination": crowded categories are harder; art matters ("great art"); "you can try a couple times"; nominations also cover updates, roadmap, and "the story behind your app". Paraphrase of a transcript, speakers not named.
- WWDC24 10063: the Helpful Details box is for "values you live by" and "the story of how you create your app", such as inclusivity or accessibility.
- Apple technologies (App Intents, Liquid Glass, Apple Intelligence): no Apple page read says adopting any of them raises featuring odds. Only "Innovation. New technologies" is Apple's wording. Anything beyond that is third-party SEO opinion (AppTweak, ASOMobile, Launchbuddy surfaced in search; not fetched, not relied on). GUESS: mentioning real adoption is harmless. Facts from this repo, not Apple: Cutling has App Intents (`Cutling/OpenCutlingAppIntent.swift`, `ViewCutlingIntent.swift`, `CutlingAppEntity.swift`) and uses `glassEffect` (`CardView.swift`, `MainContentView.swift`). The fill-ins feature itself does not need them; UNSURE whether to mention them.
- Accessibility and localization for Cutling: the listing has 60 fastlane locale folders. UNSURE: fill-ins strings in all 60 and a VoiceOver pass on the fill-in panel were not checked here. Do not claim either in the form until checked.
- Promotional artwork: if considered, Apple emails Admin, App Manager and Marketing roles for assets (getting-featured page). Creative Assets and a new Asset Library were announced 2026-06 (MacRumors, https://macrumors.com/2026/06/15/app-store-gains-personalized-recommendations/, saved `macrumors-2026-06.html`; second-hand).

## 3. In-app events and promotional text

- Promotional text: up to 170 characters, shown above the description, "update promotional text at any time without having to submit a new version" (https://developer.apple.com/app-store/product-page/, saved; and App Store Connect Help, platform version information https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information, saved `platform-version-information.html`, line "can't be longer than 170 characters"). It does not affect search ranking. The current en-US text is 148 characters. Fits: yes, and it can go live the day 1.6.2 releases or the day the feature is on, with no review round (GUESS on timing of review: Apple says no new version needed).
- In-app events: https://developer.apple.com/app-store/in-app-events/ (saved `in-app-events-marketing.html`) and https://developer.apple.com/help/app-store-connect/offer-in-app-events/offer-in-app-events (saved `iae-offer.html`). Limits: reference name 64, event name 30, short description 50, long description 120 characters; publish up to 14 days before start; runs up to 31 days; up to 10 published at once; iPhone and iPad only; must be approved by App Review first. A "Major Update" badge exists: "significant new features, content, or experiences... beyond minor enhancements". But events are "timely", and the event "should focus on a related limited-time moment", not general awareness or permanent features.
- Fit for Cutling: GUESS that a Major Update event for fill-ins is a borderline fit (permanent feature, not time-limited; the Mac picker is excluded because events are iPhone and iPad only). Recommend: nominate without an event; if the owner wants one, a 31-day "Major Update" event with the first line below. Event name (30): "Fill-ins and date stamps" (24 characters), short (50): "Blanks and dates filled as you insert" (37), long (120): "Write a blank once in a cutling and fill it when you insert it. Date stamps write today's date or a day ahead." (110 characters).

## 4. Developer experience reports

- No first-hand report of a nomination was found with a date. Searched: web search (standard and extended), Hacker News API (`fill-ins-featuring-src/hn-stories.json`, one unrelated hit), Apple developer forums via search. Reddit is not reachable: blocked in Claude in Chrome ("not allowed due to safety restrictions") and 403 to curl. UNSURE: whether Reddit holds reports.
- Closest: an Apple Developer Forums post from April 2026 asked when applicants hear back; the search result showed no answer (title only seen in search results; not fetched).
- Second-hand: Gummicube, 2024-11-15 (https://www.gummicube.com/blog/featuring-nominations-live-in-app-store-connect, saved `gummicube.html`): says there is no guarantee and recommends clear, timely nominations. TechCrunch 2024-11-13 and a Medium Game-of-the-Day story were 403 to curl (gated). Treat as marketing blogs.
- What Apple says about the answer: if selected, you get a notification from App Store Connect (getting-featured page, App of the Day) and "we'll reach out to the email address you provide" (template page).

## 5. Draft nomination for Cutling fill-ins

Plain English, buyers' words from `~/Repositories/undirect/docs/research/cutling-voice-of-customer.md`: "type out the same info over and over and over" (row A1, WordBoard review, 2019-12-26) and "ability to add custom variables" (row A7, WordBoard review, 2021-08-06). Row R21, "variables in the snippets", is from 2026-05-24 on Reddit. No place names are used. The feature takes no payments, so no payment-method question arises.

| Field | Value |
|---|---|
| Nomination name (60) | Cutling fill-ins: blanks and date stamps (40) |
| Nomination type | App Enhancements |
| Nomination description (1,000) | see below (912 characters) |
| Publish date (start) | the 1.6.2 or later release date, to be set |
| Publish date (end) | blank (a single day; or a range if the owner prefers) |
| Related apps | Cutling only (Mac picker is the same purchase and listing; UNSURE whether Mac is a separate app record; check) |
| Platforms | iOS (iPhone), iOS (iPad), macOS |
| Relevant countries or regions | leave the default: where the app is available |
| Launch in certain markets first? | No |
| New In-App Event? | No (see section 3) |
| Related In-App Events | none |
| Localizations | leave the default (pre-filled from the app); UNSURE fill-ins strings exist in all |
| Supplemental materials (5 URLs) | 1. TestFlight public link to a build with fill-ins on (owner to create); 2. the Cutling site page for fill-ins (URL to be set when the site page exists); 3. a screen recording of the keyboard panel and the Mac picker (owner to host); the rest empty |
| Pre-order? | No |
| Helpful details (500) | see below (199 characters) |

Nomination description:

> Cutling keeps the text people send again and again, such as addresses, bank details and replies, one tap away in an iPhone and iPad keyboard and in a Mac picker. Buyers of other snippet keyboards say they "type out the same info over and over and over" and ask for "custom variables". Fill-ins answer that. Write a blank such as {Name} once in a cutling, and Cutling asks for it when you insert it, in the keyboard on iPhone and iPad and in the Mac picker, then types the finished text. A blank used twice is filled once, a blank can offer a short list of choices, and the keyboard offers recent values as one-tap chips. Date stamps such as {date} and {date +3d} write today's date, or one a few days ahead, in the reader's own language and format. The syntax matches Raycast and Alfred, so snippets move over unchanged. The keyboard does not use the internet. Release 1.6.2 or later; paid once, no subscription.

Helpful details:

> One purchase covers iPhone, iPad and Mac. No account, no ads, no tracking. The App Store listing is localized into 60 languages and regions. Dates follow each reader's own system language and format.

Companion promotional text (170, en-US; goes live without a new version):

> New: fill in names and blanks as you insert a cutling, and stamp today's date or one a few days ahead. Cutling keeps your replies ready on iPhone, iPad and Mac. (160)

## Open questions for the owner

1. Fill-ins are off in all builds until you approve the screens (ASG84 to ASG91). Nominate only after a build with them on exists.
2. A TestFlight public link: create one, or nominate without a build (Apple's editors say they play what they feature).
3. Is Mac a separate app record in App Store Connect, or one record with a Mac platform?
4. Do you want to mention App Intents and Liquid Glass in Helpful Details? No Apple page says it helps.
5. Is a VoiceOver pass on the fill-in panel done? If yes, one sentence about it belongs in Helpful Details.
6. Release date of 1.6.2 or later: set it, then submit at least 3 weeks before, ideally 8.
