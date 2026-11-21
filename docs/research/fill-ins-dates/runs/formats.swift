// Prints what Foundation's date styles give for one fixed moment in several locales.
// Run: swift formats.swift  (macOS 27 SDK, 2026-11-21)
import Foundation

let tz = TimeZone(identifier: "Asia/Jakarta")!
var gc = Calendar(identifier: .gregorian); gc.timeZone = tz
let now = gc.date(from: DateComponents(year: 2026, month: 11, day: 21, hour: 14, minute: 5))!   // a Saturday
let locales = ["en_US", "en_GB", "de_DE", "fr_FR", "ja_JP", "id_ID", "ar_SA", "th_TH", "fa_IR"]

for id in locales {
    let loc = Locale(identifier: id)
    var cal = loc.calendar; cal.timeZone = tz
    func fs(_ d: Date.FormatStyle.DateStyle, _ t: Date.FormatStyle.TimeStyle) -> String {
        return now.formatted(Date.FormatStyle(date: d, time: t, locale: loc, calendar: cal, timeZone: tz))
    }
    print("== \(id)  calendar=\(cal.identifier) firstWeekday=\(cal.firstWeekday)")
    print("  date .numeric    :", fs(.numeric, .omitted))
    print("  date .abbreviated:", fs(.abbreviated, .omitted))
    print("  date .long       :", fs(.long, .omitted))
    print("  date .complete   :", fs(.complete, .omitted))
    print("  time .shortened  :", fs(.omitted, .shortened))
    print("  time .standard   :", fs(.omitted, .standard))
    let base = Date.FormatStyle(locale: loc, calendar: cal, timeZone: tz)
    print("  weekday+day+month:", now.formatted(base.weekday(.wide).day().month(.wide)))
    print("  month+year       :", now.formatted(base.month(.wide).year()))
    print("  weekday short    :", now.formatted(base.weekday(.abbreviated)))
    print("  week of year     :", now.formatted(base.week(.defaultDigits)))
    print("  quarter          :", now.formatted(base.quarter(.abbreviated)))
    // Relative, as Foundation says it
    for days in [-1, 1, 2, 3, 7, 30] {
        let target = cal.date(byAdding: .day, value: days, to: now)!
        let named = Date.AnchoredRelativeFormatStyle(anchor: target, presentation: .named, unitsStyle: .wide, locale: loc, calendar: cal, capitalizationContext: .middleOfSentence).format(now)
        let numeric = Date.AnchoredRelativeFormatStyle(anchor: target, presentation: .numeric, unitsStyle: .wide, locale: loc, calendar: cal).format(now)
        print("  relative \(days > 0 ? "+" : "")\(days)d named/numeric: \(named) | \(numeric)")
    }
}

print("\n== fixed-format styles (en_US)")
print("ISO8601 default   :", now.formatted(.iso8601))
print("ISO8601 date only :", now.formatted(Date.ISO8601FormatStyle(timeZone: tz).year().month().day()))
print("ISO8601 week date :", now.formatted(Date.ISO8601FormatStyle(timeZone: tz).year().weekOfYear().day()))
let verb = Date.VerbatimFormatStyle(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)", timeZone: tz, calendar: gc)
print("Verbatim y-MM-dd  :", now.formatted(verb))
let later = gc.date(byAdding: .day, value: 4, to: now)!
print("Interval          :", (now..<later).formatted(Date.IntervalFormatStyle(date: .abbreviated, time: .omitted, locale: Locale(identifier: "en_US"), calendar: gc, timeZone: tz)))
print("Interval de_DE    :", (now..<later).formatted(Date.IntervalFormatStyle(date: .long, time: .omitted, locale: Locale(identifier: "de_DE"), calendar: gc, timeZone: tz)))
print("HTTP              :", now.formatted(.http))
// AnchoredRelativeFormatStyle describes its ANCHOR as seen from the date passed to format(_:).
for d in [1, 2, 6, 7, 13, 40] {
    let t = gc.date(byAdding: .day, value: d, to: now)!
    print("Anchored named +\(d)d:", Date.AnchoredRelativeFormatStyle(anchor: t, presentation: .named, unitsStyle: .wide, locale: Locale(identifier: "en_US"), calendar: gc).format(now),
          "| days only:", Date.AnchoredRelativeFormatStyle(anchor: t, allowedFields: [.day], presentation: .numeric, unitsStyle: .wide, locale: Locale(identifier: "en_US"), calendar: gc).format(now))
}
print("Template j:mm via DateFormatter de_DE:", DateFormatter.dateFormat(fromTemplate: "jmm", options: 0, locale: Locale(identifier: "de_DE"))!)
print("Template yMMMd ja_JP:", DateFormatter.dateFormat(fromTemplate: "yMMMd", options: 0, locale: Locale(identifier: "ja_JP"))!)
