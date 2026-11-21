# Fill-ins: dates in the format and on the day a person wants (card ASG109)

Question: how should Cutling let a person put a date into a cutling in the format and on the day they want, including relative and natural days ("tomorrow", "in 3 days", "next Friday", "end of the month", "Monday next week"), the way an Apple app would? Do Apple and mature open-source code already provide the formats and the natural phrases, and can Foundation Models (Apple Intelligence) or App Intents help?

Today (read in the working tree 2026-11-21): the editor's menu and keyboard bar insert only a plain `{date}` ("Today's Date") or `{time}` (`Cutling/TextDetailView.swift` `placeholderChoices`). The engine (`Cutling/Placeholders.swift`) already reads `{date:short|medium|long|full}`, an ICU pattern `{date:yyyy-MM-dd}` (Gregorian, fixed digits), offsets `{date +3d -1w}` in `m h d w M y`, Raycast's `{date format="" offset="" locale=""}`, and formats with `DateFormatter` in the person's locale. It cannot say "the next Friday", "start/end of the month" or "the last weekday".

Every finding carries its source and the date it was read (all 2026-11-21 unless stated). Local runs were done on this Mac (macOS 27 / Darwin 27.0.0) with the installed Xcode SDK; their scripts and output are in `fill-ins-dates/`. Opinions are marked GUESS, anything unconfirmed UNSURE.

## 1. What Apple already provides

### 1a. Formats: Foundation has every format Cutling needs, already localised

Read from the iOS 27.2 SDK's `Foundation.swiftinterface` (Xcode 27.2) and Apple's docs (JSON saved in `fill-ins-dates/pages/apple_foundation_*.json`), then run on this Mac (`runs/formats.swift`, output `runs/formats.out`; fixed moment Sat 2026-11-21 14:05 Asia/Jakarta).

| API | Availability (SDK) | What it gives, measured | Cutling today |
|---|---|---|---|
| `Date.FormatStyle(date:time:)` presets: date `.numeric .abbreviated .long .complete`, time `.shortened .standard .complete` | iOS 15 / macOS 12 | en_US `11/21/2026`, `Nov 21, 2026`, `November 21, 2026`, `Saturday, November 21, 2026`; de_DE `21.11.2026` ... `Samstag, 21. November 2026`; ja_JP `2026/11/21` ... `2026年11月21日 土曜日`. The same four rungs as `DateFormatter.Style` short/medium/long/full. | `{date:short\|medium\|long\|full}` already maps to these |
| `.dateTime` field builder: `.weekday(.wide).day().month(.wide)`, `.month(.wide).year()`, `.weekday(.abbreviated)`, `.week()`, `.quarter()`, `.hour().minute()` | iOS 15 / macOS 12 | Picks the locale's own order and punctuation for any set of fields: en_US `Saturday, November 21`, en_GB `Saturday 21 November`, de_DE `Samstag, 21. November`, fr_FR `samedi 21 novembre`, ja_JP `11月21日 土曜日`. This is a *skeleton* (the same thing `DateFormatter.setLocalizedDateFormatFromTemplate` does): the person picks fields, the locale picks the layout. | Not offered. A written pattern `{date:EEEE d MMMM}` is fixed to one language's order. |
| Calendars | follows `Locale.calendar` | ar_SA formats in the Islamic Umm al-Qura calendar (`١١ جمادى الآخرة، ١٤٤٨ هـ`), th_TH in Buddhist years (`21/11/2569`), fa_IR in Persian (`۳۰ آبان ۱۴۰۵`) with native digits. | The engine already uses `context.locale.calendar` for styles and forces Gregorian only for written patterns (right for ISO-like patterns). |
| `Date.RelativeFormatStyle` (`presentation: .named` or `.numeric`, `unitsStyle`) | iOS 15 / macOS 12 | Words relative to *the clock*: "1 hour ago", "in 2 weeks", "yesterday", "tomorrow". Apple's overview warns: "Use the strings ... as standalone strings. Embedding them in other strings may not be grammatically correct." | Not offered |
| `Date.AnchoredRelativeFormatStyle(anchor:allowedFields:presentation:)` | iOS 18 / macOS 15 | "formats an anchor date relative to the format input" (Apple abstract): the *anchor* is the date described, the argument is "now". Named, en_US: +1d `tomorrow`, +2d `in 2 days`, +7d `next week`, +13d `in 2 weeks`, +30d/+40d `next month`; `allowedFields: [.day]` forces `in 13 days`. Named +2d is `übermorgen` (de), `après-demain` (fr), `明後日` (ja), `lusa` (id), `بعد الغد` (ar). It never names a weekday ("next Friday" is not an output). | Not offered |
| `Date.ISO8601FormatStyle` | iOS 15 / macOS 12 | `2026-11-21T07:05:00Z`; `.year().month().day()` gives `2026-11-21`; week date `2026-W47-06`. | `{date:yyyy-MM-dd}` covers the date form |
| `Date.VerbatimFormatStyle(format: "\(year:)-\(month: .twoDigits)...")` | iOS 15 / macOS 12 | Fixed layout from typed fields, no locale reordering: `2026-11-21`. The Swift-native equivalent of a written ICU pattern. | ICU pattern string does the same |
| `Date.IntervalFormatStyle` | iOS 15 / macOS 12 | A range, merged the locale's way: en_US `Nov 21 – 25, 2026`, de_DE `21.–25. November 2026`. Useful for "valid Nov 21 – 25" snippets. | Not offered |
| `Date.HTTPFormatStyle` | iOS 18-era SDK (UNSURE of exact version; seen in SDK) | `Sat, 21 Nov 2026 07:05:00 GMT` | Not needed |
| Week start | `Calendar.firstWeekday` from the locale | en_US 1 (Sunday), en_GB/de_DE/fr_FR 2 (Monday), fa_IR 7 (Saturday). Matters for "this week" / "Monday next week". | Offsets ignore it (fine for `+1w`) |

Finding: for *format*, nothing needs to be written or bought. A picker that offers the four presets, a few `.dateTime` field sets (weekday + day + month, month + year, weekday only, time), ISO date and "words" (relative) covers what Snippety, Raycast and TextExpander offer (section 4), and every row comes out right in all of Cutling's 60+ localisations and their calendars. The engine's `DateFormatter` path is the same ICU underneath; `Date.FormatStyle` is just the Swift-native door to it.

### 1b. Days: Calendar computes every rule in the brief, but nothing in Foundation *stores* "next Friday" except `RecurrenceRule`

Run in `runs/detector.swift` (Calendar part, output `runs/detector.out`, run Sat 2026-11-21) and `runs/setpos.swift`:

| Rule | Apple call | Result on Sat 2026-11-21 |
|---|---|---|
| next Friday | `nextDate(after: today, matching: DateComponents(weekday: 6), matchingPolicy: .nextTime)` | Fri 2026-11-27 |
| next Saturday, asked on a Saturday | same, weekday 7 | Sat 2026-11-28 (never today) |
| last Friday | same with `direction: .backward` | Fri 2026-11-20. Caution: swift-foundation PR #2321 "Fix Calendar.nextDate backward searches skipping or missing matches" is open (2026-10-13), https://github.com/swiftlang/swift-foundation/pull/2321 |
| start / end of this month | `dateInterval(of: .month, for:)`, end minus one day | Sun 2026-11-01 / Mon 2026-11-30 |
| start of next month | the interval's `end` | Tue 2026-12-01 |
| start of this week | `dateInterval(of: .weekOfYear, for:)` | en_US Sun 2026-11-15, en_GB Mon 2026-11-16 (follows the locale) |
| Monday next week | start of week + 1 week, then the Monday | Mon 2026-11-23 (en_GB) |
| +1 month from Jan 31 | `date(byAdding: .month, value: 1)` | Sun 2027-02-28 (clamps, does not spill into March) |
| 3 working days later | loop with `isDateInWeekend` | Wed 2026-11-25. Foundation knows the weekend per locale but has no holiday calendar. |

`Calendar.RecurrenceRule` (iOS 18 / macOS 15, `Codable`, RFC 5545-shaped: `frequency`, `weekdays: [.every(.friday)] / [.nth(-1, .friday)]`, `daysOfTheMonth: [-1]`, `setPositions`) is the one Apple type that *is* a stored rule. Measured: "last day of month" `daysOfTheMonth: [-1]` gives Nov 30, Dec 31, Jan 31, Feb 28; "last Friday" `.nth(-1, .friday)` gives Nov 27; "first Monday" `.nth(1, .monday)` gives Nov 2, Dec 7. But "last weekday (Mon-Fri) of the month" with `setPositions: [-1]` came back wrong in my run (Fri Nov 6, Mon Dec 7, Thu Jan 7: these are not month ends), and swift-foundation has open bugs on it: #2389 "monthly rule with `.nth(-5, .wednesday)` never returns" (open, 2026-10-30), #1387 "incorrectly calculates ordinal weekdays when firstWeekday != 1" (open, 2025-06-28), #2224 yearly rule outside its months (open, 2026-09-04) (`gh api search/issues`, 2026-11-21). Its JSON is also bulky (the calendar, locale and time zone are encoded into every rule; sample in `runs/detector.out`). And Cutling's macOS floor is 14, below RecurrenceRule's macOS 15.

Finding: the arithmetic is Apple's and is a few lines each; what Cutling must add is a *rule vocabulary* in the token (section 6), evaluated with `nextDate` / `dateInterval` at use time. `RecurrenceRule` is the right mental model (it is iCalendar's RRULE) but not worth storing in a snippet (GUESS: a short token is better than its JSON).

### 1c. Natural phrases: Apple's detectors parse them, but return a fixed date, and their languages depend on the device

Two Apple detectors exist. `NSDataDetector` (`.date`, every OS Cutling supports; Apple: "Don't use NSDataDetector to validate data. NSDataDetector discards potential matches in case of uncertainty", `pages/apple_foundation_nsdatadetector.json`). And the newer **DataDetection** framework (iOS 26 / macOS 26, SDK `DataDetection.swiftinterface`): `string.dataDetectorMatches(.calendarEvent, options:)` with `Options.documentDate` (a reference "now"), `documentTimeZone`, `documentLanguageCode`, `documentRegion`, returning `CalendarEvent(allDay:startDate:endDate:...)`. Neither exposes a rule; both return a `Date`.

Measured on this Mac (`runs/detector.swift` with the run's own clock Sat 2026-11-21; `runs/datadetection.swift` with `documentDate` = Wed 2026-11-25; outputs beside them):

| Phrase (English) | NSDataDetector, Sat 21 | DataDetection, Wed 25 |
|---|---|---|
| tomorrow / the day after tomorrow | Sun 22 / Mon 23 | Thu 26 |
| in 3 days, in two weeks | Tue 24, Sat Dec 5 | Sat 28 |
| **next Friday** | Fri 27 | **Fri Dec 4** (the Friday of *next week*, not the nearest one) |
| this Friday / Friday | Fri 27 | Fri 27 |
| Friday next week / Monday next week | (not run) / Mon 23 | Fri Dec 4 / Mon 30 |
| next Monday | (not run) | Mon 30 |
| tomorrow at 5pm, next Friday at noon | Sun 22 17:00, Fri 27 12:00 | |
| tonight | Sat 21 19:00 | |
| 12/05/2026 | **May 12** (read day-first because this Mac's locale is en_GB) | |
| next week, next month, in 2 months, end of the month, end of month, last day of the month, end of the week, start of next month, this weekend, the 1st, Christmas, "3 days from now" | **not found** | not found |
| first Monday of next month / of December | only "Monday" (Mon 23 / Mon 30): the rest is dropped silently | same |

So Apple's own reading of "next Friday" is "Friday of next week" when said early in a week. Fantastical and people differ on this; a picker must show the resulting date, never guess silently (GUESS).

Languages, measured: with this Mac's languages (en-GB, ja, id, zh-Hans) the detector found Japanese (`明日`, `3日後`, `来週の金曜日`), Chinese (`下周五`), Korean (`다음 주 금요일`), Indonesian (`besok`, `lusa`; "Jumat depan" matched only "Jumat") and French (`demain`, `dans 3 jours`, "vendredi prochain" matched only "vendredi"), but **no German or Spanish at all**, not even `am 5. Dezember`. Re-run as a binary with `-AppleLanguages (de)` (`runs/detector-lang.swift`, `.out`): German and Spanish appear (`nächsten Freitag`, `in 3 Tagen`, `próximo viernes`); with `(ar)` Arabic `الجمعة القادمة` appears; with `(en)` only English and French. DataDetection's `documentLanguageCode = "de"` did **not** turn German on. Neither detector found `غدا`, `en 3 días`, `3 hari lagi`, `fin de mes`, `akhir bulan`, `月末`. UNSURE: Apple does not document which languages the date detector supports or why the preferred-language list gates them; this is what this Mac shows.

Finding: Apple's detectors are good for "the person typed a date-ish phrase, show what day it means now" in the editor, and as one input to a parser. They are not a rule store: "next Friday" parsed on Saturday is a `Date` (Nov 27), and saving it as `+6d` would be wrong next week. Cutling has to map the phrase to a rule itself (weekday = Friday, which week), and use the detector only to cross-check or as the fallback for absolute dates. They cover none of the month-end phrases the owner listed.

### 1d. How Apple's own apps offer format and day choices

| App | What the person picks | Source (read 2026-11-21) |
|---|---|---|
| Shortcuts, **Format Date** | Date Format: None, Short, Medium, Long, Relative, RFC 2822, ISO 8601, Custom; Time Format: None, Short, Medium, Long, Relative; "Relative Alternate Format" Short/Medium/Long; ISO 8601 has an "Include ISO 8601 Time" switch; Custom reveals a Format String field (example `EEE, dd MMM yyyy HH:mm:ss Z`). Apple's own page gives the presets with English examples (Short "6/1/17", Medium "Jun 1, 2017", Long "June 1, 2017"; time Short "2:41 PM", Medium "2:41:36 PM", Long "2:41:36 PM PST") and says "The formats shown above are specific to the English language and may vary by locale." Custom "uses the patterns defined by the Unicode Technical Standard #35". | Option list: https://matthewcassinelli.com/actions/format-date/ (third-party action reference, action added 2014-11-12). Presets: https://support.apple.com/guide/shortcuts/apdfbad418ca/ios (version menu reaches iOS 27). Custom: https://support.apple.com/guide/shortcuts/apd8d9b19184/ios |
| Shortcuts, **Adjust Date** | Operation: Add, Subtract, Get Start of Minute / Hour / Day / Week / Month / Year; Amount (number; decimals only for seconds to days); Unit: seconds ... years. So Apple's model is "offset, or snap to the start of a unit", and "end of month" is done by chaining (start of month, add 1 month, subtract 1 day). There is no "next Friday" choice. | https://matthewcassinelli.com/actions/adjust-date/ (action added 2015-12-02). Apple's guide only shows Adjust Date inside a timestamp example (https://support.apple.com/guide/shortcuts/apdfb33b0e17/ios) |
| Shortcuts, **Current Date** variable | A special variable in the Variables bar; tapping the token offers the same Date Format / Time Format choices inline (UNSURE: seen in earlier Cutling research text, `fill-ins-editor/README.md` row "Apple Shortcuts", not re-checked on a device in this run) | https://support.apple.com/guide/shortcuts/apdd02c2780c/ios |
| Reminders, date control | Presets "Today, Tomorrow, This Weekend, Next Week, or tap Custom to set your own day and time" (Apple, published 2026-10-09). This is Apple's list of the relative days people want most. | https://support.apple.com/102484 |
| Reminders and Calendar, typed phrase (iOS / iPadOS / macOS 27) | **"Smart Event"**: the title field reads "Describe Event"; Apple Intelligence fills Date and Time from the typed words, marking what it understood in bold red and what needs a choice in bold grey; the fields stay editable before saving. Without Apple Intelligence 27 the field reads "Title" with no natural-language support (Six Colors). Older devices (an iPhone 11 is the article's example) keep the date and time suggestions above the keyboard (iDownloadBlog). Reported flaws: "Thursday" read as today; inconsistent with lowercase day names and date-before-time order. | https://sixcolors.com/post/2026/11/describe-an-event-in-calendar-with-apple-intelligence/ (Glenn Fleishman, 2026-11-16); https://idownloadblog.com/2026/10/20/add-reminder-calendar-event-type-natural-language (2026-10-20) |
| Calendar on Mac, Create Quick Event | Type a description, pick the suggestion: "Party Feb 6", "Soccer Game on Saturday from 11am-1pm", "Vacation in Bahamas Mon-Fri"; Spotlight takes "Movie tonight at 7pm". | https://support.apple.com/guide/calendar/icalwr13-events (version menu reaches macOS 27) |

Finding: Apple's pattern is (1) a short menu of named styles with an example of each, plus Custom for a UTS #35 string (Shortcuts); (2) a short list of the days people want most, by name (Reminders: Today, Tomorrow, This Weekend, Next Week, Custom); (3) offsets plus "start of" a unit (Adjust Date); and, new in 27, (4) a typed phrase read by Apple Intelligence, shown back as highlighted words and filled fields the person can correct, with the old rule-based suggestion bar kept for devices without it. That four-part split is the shape a Cutling date pill sheet can copy (section 6).

## 2. Foundation Models (Apple Intelligence) and App Intents

### 2a. What the framework offers, read from the SDK and Apple's docs

- **API shape.** `LanguageModelSession(model: SystemLanguageModel.default, instructions:)`, then `respond(to:generating: SomeType.self)`. `@Generable` structs and enums are filled by constrained decoding: WWDC25 "Meet the Foundation Models framework" says guided generation "fundamentally guarantees structural correctness using a technique called constrained decoding" (https://developer.apple.com/videos/play/wwdc2025/286/, read 2026-11-21). The SDK (`FoundationModels.swiftinterface`, iOS 27.2) makes `Bool, String, Int, Float, Double, Decimal, Array, Optional` and `@Generable` enums Generable; **`Date` is not Generable**, so the model can only return parts of a rule (an enum case, a weekday, a count), and Cutling's own Calendar code must turn that into a day. That is the right split anyway: the stored thing is a rule, not a date.
- **Model.** About 3 billion parameters, 2-bit quantised; "not designed for world knowledge or advanced reasoning" (WWDC25 286). Three model versions so far: OS 26.0-26.3, 26.4, 27.0 (`SystemLanguageModel` doc, `pages/apple_foundationmodels_systemlanguagemodel.json`), so the same prompt can behave differently after an OS update.
- **Availability** (`SystemLanguageModel.Availability`): `.available` or `.unavailable(.deviceNotEligible | .appleIntelligenceNotEnabled | .modelNotReady)` (SDK). Devices (Apple, "How to get Apple Intelligence", published 2026-11-05, https://support.apple.com/en-us/121115): iPhone 15 Pro / Pro Max, iPhone 16 and later, iPhone Air, iPhone Duo; iPad mini (A17 Pro, A20 Pro) and iPads with M1 or later; Macs with M1 or later and MacBook Neo. Not in mainland China. Storage up to 8-14 GB.
- **Languages** (same page): English, Danish, Dutch, French, German, Italian, Norwegian, Portuguese, Spanish, Swedish, Turkish, Vietnamese, Chinese (Simplified, Traditional), Japanese, Korean. On this Mac `supportedLanguages` lists 24 locale variants of those (`runs/fm-avail.swift`). **Not supported: Indonesian, Arabic, Hindi, Thai, Russian, Polish and most of Cutling's 60+ localisations.** Apple's advice for those: check `supportsLocale()`, "Disabling your Foundation Models framework feature" and "Providing an alternative app experience" (https://developer.apple.com/documentation/foundationmodels/supporting-languages-and-locales-with-foundation-models, saved JSON). Apple's measured instruction line for non-US locales, word for word: `The person's locale is \(locale.identifier).`
- **Private Cloud Compute model** (new in the iOS 27 SDK): `PrivateCloudComputeLanguageModel()` swaps in the server model with one line, needs a managed entitlement ("Accessing Private Cloud Compute"), has a `quotaUsage` and network errors, and its availability "depends on whether the device and region supports Apple Intelligence" (doc, saved JSON). So it does **not** help devices without Apple Intelligence.
- **Latency.** Apple's 2024 figure for iPhone 15 Pro: "time-to-first-token latency of about 0.6 millisecond per prompt token" and "a generation rate of 30 tokens per second" (https://machinelearning.apple.com/research/introducing-apple-foundation-models, 2024-06-10). Measured here, see 2c.

### 2b. Can the keyboard extension call it?

- The SDK marks FoundationModels unavailable only on tvOS (and parts on watchOS); there is no `@available(iOSApplicationExtension, unavailable)` (grep of the iOS 27.2 interface, 2026-11-21). So it compiles and runs in an extension.
- It has been shipped in a keyboard: dictus-ios (MIT, 59 stars, pushed 2026-11-21) runs `LanguageModelSession` inside its keyboard extension and measured the cost on an iPhone 15 Pro Max, Release build: peak `phys_footprint` **69 MB with the model in use vs 35 MB without**, "Apple Foundation Models in the extension is ~34 MB of the footprint", and the bigger process is the one iOS reclaims first (issue #555, closed 2026-09-12, https://github.com/getdictus/dictus-ios/issues/555 and its 2026-09-12 comment).
- Apple says the opposite about memory: a Frameworks Engineer's accepted answer (Apple Developer Forums thread 795044, Jul 2025, read in Chrome 2026-11-21, https://developer.apple.com/forums/thread/795044) says the model and inference resources "are managed centrally by the operating system and shared by all Apple Intelligence system features", so "the increase to your app's memory usage will be very minimal"; parallel requests "end up running serially on the Apple Neural Engine". The two do not have to conflict: the weights live outside the process, while dictus measured what *its* extension process grew by (framework code, session and transcript buffers). UNSURE which applies to Cutling's keyboard until measured on a device.
- Cutling's keyboard lives under a **77 MB** hard limit (`docs/research/keyboard-memory-limits.md`, read from Apple's jetsam plists) and already budgets for up to 5,000 cutlings. If dictus's 34 MB holds, that is not affordable at use time; if Apple's "very minimal" holds, memory is fine but the 2 s wait and the wrong answers in 2c still rule it out at use time (GUESS).
- No Apple page found that addresses extensions either way (UNSURE). A Kodeco tutorial builds a share extension on the on-device model (https://www.kodeco.com/49841134-using-apple-foundation-models-to-summarize-text, found by search, not opened).

### 2c. Measured: phrase to rule on this Mac (M3, macOS 27, Apple Intelligence on)

`runs/fm-rules-v2.swift` and `v3` ask the on-device model to fill a `@Generable DateRule { kind, count, weekday? }` (kinds: inDays, inWeeks, inMonths, weekday, startOfMonth, endOfMonth, lastWorkdayOfMonth, firstWeekdayOfMonth, lastWeekdayOfMonth, startOfWeek, endOfWeek), greedy sampling, a fresh session per phrase, with Apple's locale line; Cutling-style Calendar code turns the rule into a day for "today" = Wed 2026-11-25. The vocabulary, instructions and examples are mine (GUESS). 27 phrases in English, German, French, Spanish, Japanese and Indonesian. Outputs: `runs/fm-rules*.out`.

| Run | Correct | Time per phrase |
|---|---|---|
| v1: offsets-then-anchor schema, no examples | 1 of 27 | first 17.8 s, then 1.2-7.7 s |
| v2: phrase-shaped kinds, 7 worked examples | **14 of 27** | first 8.4 s (cold), median 1.9 s, max 4.3 s |
| v3: v2 + 6 more examples covering "this month" | **14 of 27** | first 9.1 s, median 1.9 s, max 4.9 s |

What it got right: tomorrow, the day after tomorrow, in 3 days, in 2 months, this Friday, Monday next week, next week Thursday, `in 3 Tagen`, `vendredi prochain`, `来週の金曜日`; v3 also `nächsten Freitag` and "first Monday of next month". It read "next Friday" as the Friday of next week (as Apple's detector does) in v2 and as "in 1 week" in v3.

What it got wrong, the same way every run: **"end of the month" became the end of *next* month** (count 1) in all six languages (`Ende des Monats`, `fin du mois`, `fin de mes`, `月末`, `akhir bulan`), even with "start of the month -> count 0" in the examples; "last working day of the month" and "last Friday of the month" likewise slid to December; "two weeks from today" became "in 2 days"; "end of the week" became next week's Sunday. Indonesian (unsupported) did **not** throw `unsupportedLanguageOrLocale`; it answered, sometimes right ("Jumat depan" in v3), sometimes wrong.

Finding: on Apple's newest model, with structured output, a phrase-to-rule step is about half right on a small test and takes about 2 s (9 s cold) on an M3. The errors are plausible-looking days, so the result must always be shown back as a date the person confirms, which is what Apple's own Smart Event does (section 1d). It cannot run unattended at use time, and the keyboard cannot afford its memory. A closed list of rules that a person picks (or a small rule-based parser for the same list) gets 100% of the rules it covers.

### 2d. App Intents and Siri

- Shortcuts already has Apple's date tools (Format Date, Adjust Date, section 1d). An App Intent `Date` parameter (`@Parameter(kind: .date | .time | .dateTime)`, SDK `IntentParameter.DateKind`) would let a shortcut pass any date it computed into Cutling. GUESS: an optional "Date" parameter on Copy Cutling / Get Cutling Text that fills `{date}` stamps from that date, instead of now, gives Shortcuts users "next Friday" for free through Adjust Date, with no new Cutling UI.
- Siri resolving spoken dates for a Date parameter is Siri's own work; UNSURE how far it reaches into an app's intents in iOS 27, not tested. Not relevant to typing a cutling from the keyboard.

## 3. Open-source natural-language date parsers

Repo facts from `gh api repos/<name>` on 2026-11-21.

| Project | Licence, stars, last push | What it parses | Fit for Cutling |
|---|---|---|---|
| **chrono** (wanasit/chrono, TypeScript, npm `chrono-node` 2.10.3) | MIT, 5,302, 2026-11-03 | Ships locales ar, de, en, es, fi, fr, id, it, ja, nl, pt, ru, sv, uk, vi, zh (`node_modules/chrono-node/dist/esm/locales/`). Measured (`runs/chrono-node.ts`, `.out`, "now" = Wed 2026-11-25): tomorrow, the day after tomorrow, in 3 days, "3 days from now", **next Friday = Fri Dec 4** (next week's, like Apple), this Friday / Friday = Nov 27, Monday next week, **end of the month = Nov 30**, last day of next month = Dec 31, in 2 months, `übermorgen`, `nächsten Freitag`, `vendredi prochain`, `próximo viernes`, `besok`, `lusa`, `3 hari lagi`, `Jumat depan`, `下周五`. Missed or misread: "next week Thursday" (took "next week" = Wed Dec 2), "the Friday after next" (Nov 27), "first Monday of next month" (just "Monday"), "start of next month" (Dec 25: "next month" keeps today's day number), "last working day of the month", `Ende des Monats`, `fin du mois`, `fin de mes`, `月末`, `akhir bulan`, `3日後`. Each result lists **known** components separately from implied ones (`next Friday` -> known: weekday only), which is exactly the signal for "this is a weekday rule, not a fixed date". | JavaScript: not usable in the app. Its rule files are the best reference for patterns per language. |
| **SwiftyChrono** (quire-io/SwiftyChrono, Swift port of chrono v1) | MIT, 207, last commits 2026-07-27 ("Implement russian language", "Add Chinese Simplified parser from upstream v2") | Parsers per language as Swift files: EN, DE, ES, FR, JP, RU, ZH (Hans, Hant), CA: casual dates, weekday, "deadline" (`in 3 days`), time-ago, relative `next\|last\|past` week/month/year, slash and month-name dates (`Sources/Parsers/*`, tree read via `gh api`). Its relative parser comments: "We don't know the exact day for next/last month", so it implies a day. | Would be a third-party dependency, which Cutling does not take. MIT means its regexes can be read and the idea copied. Returns dates, not rules. |
| **dateparser** (scrapinghub, Python) | BSD-3-Clause, 2,867, 2026-11-18 | "relative dates ("two weeks ago" or "tomorrow")", "more than 200 language locales", language autodetection (README). Mostly for parsing scraped absolute dates. | Python: reference only. Its locale data (month and weekday names, relative words) comes from CLDR, which Foundation already exposes. |
| **Duckling** (meta/duckling, Haskell) | BSD (LICENSE "BSD License ... Copyright (c) 2016-present, Facebook"; GitHub shows NOASSERTION), 4,328, 2026-03-15 (last code fix 2025-11-26) | Composable rules per language, `Time` dimension returns a value with a **grain** ("today at 9am" -> value + `"grain":"hour"`), runs as an HTTP server built with `stack`. | Server-side Haskell: not embeddable. The idea worth copying: a result carries its grain (day, week, month), so "next month" is a month, not a guessed day. |
| **Microsoft Recognizers-Text** (C#, JS, Python, Java) | MIT, 1,799, last code commit 2026-01-23 | Numbers, units, date/time "in multiple languages (ZH, EN, FR, ES, PT, DE, IT, TR, HI, NL. Partial support for JA, KO, AR, SV)" (repo description); resolves to TIMEX values. | Not Swift. TIMEX (`XXXX-WXX-5` style) is the standard way to write an underspecified date as a rule; UNSURE of exact output, not run. |
| **SoulverCore** (soulverteam) | **Closed-source** xcframework, "A license is required for commercial use" (README); 1,069 stars, 2026-08-23. Date parsing write-up: soulverteam/DateParsing (18 stars, 2025-08-12) | `"...".dateValue`, `dateIntervalValue`; "3 weeks from tomorrow", "march 12 + 4 weeks 3 days", "next Monday to Wednesday"; English plus German, Russian, French, Spanish, Italian, Japanese, Korean, Simplified Chinese; says it is "much more versatile than Foundation's DataDetector". iOS 16 / macOS 13.5. | Paid, closed binary, third-party: ruled out by Cutling's no-dependency rule. |
| SwiftDate (malcommac) | MIT, 7,688, last push 2023-09-19 | Date maths and relative formatting in Swift; no natural-language parsing of "next Friday". | Stale, and Foundation now covers it. |
| natty (Java), when (Go, Apache-2.0, 1,466, 2026-11-02), parsedatetime (Python, Apache-2.0, 710, 2026-11-20), go-dateparser (BSD-3, 68, 2026-10-20) | | English-centred rule parsers in other languages. | Reference only. |

Finding: no maintained, Apple-only Swift library parses natural date phrases across Cutling's languages; the good ones are JavaScript, Python or Haskell, and the one Swift port (SwiftyChrono) covers 8 languages and returns dates, not rules. Every parser tested, Apple's included, misses most month-end phrases outside English. And they all return a *date*, so they solve a different problem from Cutling's (store a rule, show it later).

What a rule-based approach in Swift needs, from the above (GUESS on effort): (1) a closed rule list (section 6); (2) per language, the words for each rule: weekday and month names, "today/tomorrow", "next/this/last", already in CLDR through Foundation (`Calendar.weekdaySymbols`, `monthSymbols`, `Date.RelativeFormatStyle` named outputs such as `übermorgen`, `lusa`, `明後日`), so the parser can be *generated* from Foundation's own strings rather than hand-written regexes; (3) the remaining phrases ("end of the month", "first Monday") as a small table per localisation, written with the strings files; (4) Apple's detector as a cross-check for absolute dates ("5 Dec"); (5) the result always shown as a live date before it is accepted. Chrono's per-language files show the work: 7-14 parser files per language.

## 4. How snippet tools let people pick a date's format and day

Read 2026-11-21. Pictures are in `fill-ins-dates/shots/` (vendor images from their help pages and blog, captured in Chrome), plus earlier pictures already in the repo where noted.

| Tool | Format choice | Day choice (offset) | Weekday / month-end rules | Source |
|---|---|---|---|---|
| **TextExpander** (Mac) | The editor's Date button lists date *parts* with a sample each: "Year: 2001 / Year: 01 / Month: January / Month: Jan / Month: 01 / Month: 1 / Day: Monday / Day: Mo / Day: 01 / Day: 1" (`shots/textexpander_mac_date-parts-menu_help-2021.jpg`); the person builds "January 3, 2020" from parts and types the punctuation. "Unicode Date Format" for a pattern (`%date:QQQyyyy%`). Its Date Picker *fill-in* (asked at use time, v8.4+) splits presets into **locale-aware** ("Jan 31, 2025", follows region) and **static** ("2025-01-31", same everywhere). | Math button: Add / Subtract Years, Months, Days, Hours, Minutes, Seconds, Reset Adjustment (`shots/textexpander_mac_date-math-menu_help-2021.jpg`), then a small "Date/Time Math: Add [1] day" dialog (`shots/textexpander_mac_date-math-add-days-dialog_help-2021.jpg`). The math macro must come *before* the date it changes and affects every later date until Reset Adjustment. | None. A blog commenter asked for business days; none found. | https://textexpander.com/learn/using/snippets/advanced-snippet-elements/date-time (updated 2021-12-17); `/advanced-date-time` (updated 2025-07-28); `/snippet-fill-ins/date-picker-fill-in` (updated 2025-12-16) |
| **Raycast** (Mac, Windows, iOS) | `{date}`, `{time}`, `{datetime}`, `{day}`; `format="MM/dd/yyyy"` (case-sensitive ICU); `locale="fr-FR"`; modifiers `uppercase`, `lowercase`, `trim`... | `offset="+2y +5M"`, `{day offset=-3d}`; units `m h d M y` (no weeks), no space after the sign. | None. | https://manual.raycast.com/dynamic-placeholders (the manual's only UI note: a valid placeholder's braces turn blue; no picker described; the Windows manual says typing `{` opens a placeholder menu, https://manual.raycast.com/windows/snippets, not opened) |
| **Snippety** (Mac, iOS) | Calculated Date placeholder, inserted from the Insert Placeholder window (`⌘N`, or type `{{` to search): Date Format field (default `dd.MM.yyyy`) with a help table of patterns and examples (`yyyy-MM-dd` 2020-05-01, `E, d MMM yyyy` Mon, 2 Jun 2020) and a **Language** field (default English) that only changes month and weekday names. Syntax `{@calculated-date\|-1m2d\|dd.MM.yyyy\|English@}`. Selectable Date asks at use time with a calendar. | Date Offset field: `d`, `m` (months), `y`, combinable (`1d-2m1y`), order free. | None. Its own example of "last day of the previous month" (`-1d`) only works when the snippet is used on the 1st. | https://snippety.app/help/macos/placeholders/calculated-date, `/selectable-date`, `/creating-template/adding-placeholders`. Earlier pictures: `docs/research/fill-ins-design/shots/snippety_mac_live-template-form.png` (calendar for a date blank), `fill-ins-editor/images/snippety-mac-editor.png` |
| **Alfred** (Mac) | `{date}` `{time}` `{datetime}` follow the Mac's own formats; `:short` `:medium` `:long` `:full`; ICU patterns `{date:EEEE}`, `{date:MMMM yyyy}`; `isodate` family fixed to en_US_POSIX. The `{ }` button under the snippet box opens a browsable set of example snippets ("Date formats" in a "Dynamic Content" collection), not a picker (`shots/alfred_mac_date-formats-example-snippet_blog-2026-09.jpg`). | `{date +1D}`, `{time -3h -20m}`, `{datetime -2Y +2M:full}`; units Y M D h m s. | None ("next Monday" not covered). | https://www.alfredapp.com/help/workflows/advanced/placeholders/; blog "Dynamic Placeholders: Time and Date" (2026-09-09) |
| **Typinator** (Mac) | Smart Element menu: Day, Month, Year, Week, Time, Date/Time Calculation... (picture already in repo: `fill-ins-editor/images/typinator-mac-smart-element-menu.png`); markers like `{YYYY}-{MM}-{DD}`. | `{{dayDelta=x}}` before the date markers. | "Next Saturday" is a recipe, not a feature: `{{dayDelta={/Choose {DM1}/5/4/3/2/1/7/6/}}}{YYYY}-{MM}-{DD}` (weekday number picks the offset from a list of 7), Typinator 7+. | https://help.typinator.ergonis.com/hc/en-us/articles/22697393296156 (search shows 2025-10-02) |
| **aText** (Mac, Windows) | FAQ: "In snippet editor, double-clicking on a Data/Time variable to access editing data/time format." No other primary page found (UNSURE on its offset UI). | UNSURE | UNSURE | https://www.trankynam.com/atext/doc/index.html |
| **Espanso** (open source, GPL-3.0) | `type: date`, `format: "%x"` (strftime), `locale: "en-US"`, `tz` (v2.3+). | `offset: 86400` in **seconds**. | None. | https://espanso.org/docs/matches/extensions/ |

Finding: every snippet tool stops at "offset by N units" plus a pattern or style; **none offers "next Friday", "end of the month" or "first Monday"** as a choice, and Typinator's documented way to get "next Saturday" is a seven-number lookup table. Only TextExpander shows a sample next to every choice, and only its date-picker presets separate "follows your region" from "same everywhere". Apple (Reminders' Today / Tomorrow / This Weekend / Next Week; Shortcuts' Get Start of Week / Month) goes further than any snippet tool on *which day*. A Cutling picker that offers named days would be ahead of every competitor read (GUESS on how much people want it: the owner's own list is the only demand evidence in this run).

## 5. The owner's questions, answered

**Don't Apple and mature code repos already provide many date formats, dynamic and natural ones?** Yes for *formats*, partly for *days*, no for *storing a natural day as a rule*.
- Formats: Foundation has every format any competitor offers and more (four presets, field sets the locale orders itself, words such as "tomorrow" / `übermorgen` / `lusa`, ISO, date ranges), correct in every Cutling language and in Islamic, Buddhist and Persian calendars (1a). Nothing to write or import.
- Day arithmetic: Foundation's `Calendar` computes "next Friday", "end of the month", "start of next week", "first Monday" in one or two calls each (1b).
- Natural phrases: Apple's `NSDataDetector` and the iOS 26 DataDetection framework read "tomorrow", "in 3 days", "next Friday", "Monday next week" and absolute dates, but only in the device's own language group, never "end of the month" or "next month", and they return one fixed date, not a rule (1c). chrono (MIT, 5.3k stars) reads more English, including "end of the month", but is JavaScript; its Swift port covers 8 languages and is a dependency Cutling does not take (3).

**Can the newest Apple framework (Foundation Models, App Intents) help?** A little, in one place. In the editor, on an Apple Intelligence device in one of its 16 languages, a `@Generable` rule can turn a typed phrase into a rule; measured here it was right 14 times in 27, took about 2 s (9 s cold) on an M3, and its mistakes look plausible, so the person must see the resulting date and confirm (2c), as Apple's own iOS 27 Smart Event does (1d). It is not usable at use time in the keyboard (memory and latency, 2b), not available in Indonesian or most of Cutling's languages, and the Private Cloud Compute model needs the same devices plus a managed entitlement (2a). App Intents only matter for Shortcuts: a `Date` parameter would let a shortcut hand Cutling a day it computed with Adjust Date (2d, GUESS).

## 6. Recommendation for Cutling (all GUESS unless a section is cited)

### 6a. Token: extend the offset list with three kinds of step, applied left to right

The engine already applies `+3d -1w` in order. Keep that and add steps, so every rule in the brief is a short, language-neutral token the pill can label in any language:

| Step | Meaning | Calendar call |
|---|---|---|
| `+3d` `-1w` `+1M` `+2y` `+2h` `+30m` | as today | `date(byAdding:)` |
| `+1fri` `-1fri` `+2fri` (mon tue wed thu fri sat sun) | the 1st / 2nd Friday after (or before) the day so far, never the day itself | `nextDate(after:matching: weekday, .nextTime, direction:)` |
| `+0fri` | the day itself if it is a Friday, else the next Friday | same, from one second before |
| `+3wd` `-1wd`, `-0wd` | working days, skipping the locale's weekend (no holidays) | loop with `isDateInWeekend` |
| `<w` `<M` `<y` | snap to the start of the week (locale's first weekday), month, year | `dateInterval(of:for:).start` |
| `>w` `>M` `>y` | snap to the last day of the week, month, year | `.end` minus one day |

The owner's examples become:

| Phrase | Token |
|---|---|
| tomorrow / in 3 days | `{date +1d}` / `{date +3d}` (exists) |
| next Friday (the coming one) | `{date +1fri}` |
| Friday next week (Apple's and chrono's reading of "next Friday", 1c, 3) | `{date +1w <w +0fri}` |
| Monday next week | `{date +1w <w +0mon}` (not `+1w <w`: en_US weeks start on Sunday, 1a) |
| end of the month | `{date >M}` |
| start of next month | `{date +1M <M}` |
| last working day of the month | `{date >M -0wd}` |
| first Monday of next month | `{date +1M <M +0mon}` |
| last Friday of the month | `{date >M -0fri}` |
| in 3 working days | `{date +3wd}` |

Then `:format` as today. Raycast's `offset="..."` form would take the same steps (they would be Cutling's own; Raycast has no weekday or snap step). Parser change is in `Placeholders.offsets(_:)` (new unit words, the `<`/`>` snap, allowing `0`); `Offset` grows a case or becomes a `Step` enum; `format(_:_:)` applies steps in order. Check: `mon` must not collide with `mo` (month) in `Unit.init` (it does not today: `m`, `min`, `mins`, `M`, `mo` are the only minute and month spellings), and a stored Markdown cutling may escape `<` `>`; `unescapeMarkdown` already strips backslashes.

Not chosen: `Calendar.RecurrenceRule` JSON in the token (bulky, macOS 15+ while Cutling supports 14, open bugs, 1b); a free-text phrase in the token re-parsed at use time (needs a parser or model in the keyboard, and a phrase can change meaning when the language changes).

Format additions, all through Foundation so they follow the person's locale and calendar: `:weekday` (already `{day}`), `:daymonth` (`.dateTime.day().month(.wide)` gives "21 November" / "November 21" / `21. November` / `11月21日`), `:weekdaydaymonth`, `:monthyear`, `:iso` (`yyyy-MM-dd`, same everywhere), and `:words` (`Date.AnchoredRelativeFormatStyle(.named)`: "tomorrow", "in 3 days", "next week"; Apple warns these are meant to stand alone, 1a, so the sheet should say the words are as of the moment of use).

### 6b. Editor: a Date pill sheet

"Today's Date" in the menu and the keyboard bar opens a sheet instead of inserting a bare `{date}`; tapping a date pill reopens it with its rule and format.

1. **A field at the top: "Type a day"** (placeholder text such as "next Friday"). As the person types, the list below filters and the best match is shown as a row with its date today ("Friday next week, Fri 4 Dec"). Parsing order: Cutling's own phrase table for the rule list (built from Foundation's localised weekday and month names and relative words, plus a short per-language table for "end of the month" and friends written with the strings files, section 3); if nothing matches and `SystemLanguageModel.default.availability == .available` and `supportsLocale()`, ask Foundation Models for a `@Generable` rule restricted to the same steps (2c), shown as a suggestion row with its date, never applied silently; `NSDataDetector` only to recognise an absolute date ("5 Dec"), which is offered as plain text, since a fixed day is not a stamp.
2. **Day**, a short list in Apple's style (Reminders' "Today, Tomorrow, This Weekend, Next Week", 1d), each row showing its date today: Today, Tomorrow, In … days / weeks / months (stepper), Next [weekday] (menu of seven), [Weekday] next week, Start / end of this week, Start / end of this month, Start of next month, Last working day of the month, Custom (the step list, as Shortcuts' Adjust Date shows Add / Subtract / Get Start of).
3. **Format**, each row *showing the chosen day in that format* in the person's language: two groups as TextExpander's date-picker presets split them (section 4): "Follows your region" (Short, Medium, Long, Full, Weekday, Day and month, Month and year, Words) and "Same everywhere" (2026-11-27, Custom pattern with a live preview, as Shortcuts' Format Date has Custom, 1d). A Language row ("Automatic", or one language) writes the existing `locale=`.
4. **Preview line**: the finished stamp as it would be typed now, and the same on another day ("Used on Monday 30 Nov: Fri 4 Dec") so a rule is visibly a rule.

The pill label is the rule's name plus the format ("Friday next week · Medium") in the person's language, so the token stays English-neutral (`fill-ins` pills already map `date` to "Today's Date", `Cutling/FillInPills.swift`).

### 6c. What runs where

| Where | Work |
|---|---|
| Editor (app on iPhone, iPad, Mac) | the sheet, the phrase table, optional Foundation Models call (main app process, not the 77 MB keyboard), writing the token |
| Keyboard, Mac picker, Copy, Shortcuts (use time) | only `Placeholders.format`: the steps with `Calendar`, the format with Foundation, from the device's clock and time zone; no model, no network, microseconds, the same Foundation-only file every target already shares |
| Shortcuts (optional) | a `Date` parameter on Copy Cutling / Get Cutling Text so a shortcut's own Adjust Date result fills the stamps (2d) |

### 6d. Without Apple Intelligence

Nothing in the list or the formats depends on it; the typed field falls back to the phrase table, and when that finds nothing the sheet says so and leaves the list in view, so no one hits a dead end. Foundation Models is only ever an extra suggestion row, behind `#if canImport(FoundationModels)`, `#available(iOS 26, macOS 26, *)`, `.available` and `supportsLocale()`. Every other API used exists on Cutling's floor (iOS 18, macOS 14): `nextDate`, `dateInterval`, `isDateInWeekend`, `DateFormatter` templates; `AnchoredRelativeFormatStyle` needs iOS 18 / macOS 15, so `:words` falls back to `RelativeDateTimeFormatter` (iOS 13 / macOS 10.15) on macOS 14 (UNSURE: not run on macOS 14).

## Files in this research

- `fill-ins-dates/runs/`: `formats.swift` (+`.out`), `detector.swift`, `detector-lang.swift`, `datadetection.swift`, `setpos.swift`, `fm-avail.swift`, `fm-rules.swift`, `fm-rules-v2.swift`, `fm-rules-v3.swift`, `chrono-node.ts` (each with `.out`). Run on this Mac on 2026-11-21; chrono-node 2.10.3 was installed in a scratch folder, not in the repo.
- `fill-ins-dates/pages/`: Apple documentation JSON for the Foundation and FoundationModels pages cited.
- `fill-ins-dates/shots/`: `textexpander_mac_date-parts-menu_help-2021.jpg`, `textexpander_mac_date-math-menu_help-2021.jpg`, `textexpander_mac_date-math-add-days-dialog_help-2021.jpg`, `alfred_mac_date-formats-example-snippet_blog-2026-09.jpg`.
