// Can the on-device Foundation Model turn a typed phrase into a date RULE (not a date)?
// The rule vocabulary and the instructions below are this research's GUESS, not Apple's.
// Run on an M3 Mac, macOS 27, Apple Intelligence on, 2026-11-21. "Today" is fixed to Wed 2026-11-25 in the prompt.
import Foundation
import FoundationModels

@Generable enum Anchor {
    case today            // the day itself after the shifts
    case upcomingWeekday  // the first `weekday` strictly after the shifted day
    case weekdayOfWeek    // `weekday` inside the (shifted) Monday-first week
    case firstWeekdayOfMonth
    case lastWeekdayOfMonth
    case startOfWeek, endOfWeek, startOfMonth, endOfMonth, lastWorkdayOfMonth
}
@Generable enum Weekday { case monday, tuesday, wednesday, thursday, friday, saturday, sunday }

@Generable(description: "A date written as a rule relative to today, so it can be recomputed on any later day")
struct DateRule {
    @Guide(description: "Whole months to move from today before applying the anchor. 0 = this month, 1 = next month, -1 = last month")
    var months: Int
    @Guide(description: "Whole weeks to move before applying the anchor. 0 = this week, 1 = next week")
    var weeks: Int
    @Guide(description: "Days to move before applying the anchor, e.g. 3 for 'in 3 days', 1 for 'tomorrow'")
    var days: Int
    var anchor: Anchor
    @Guide(description: "Only for weekday anchors; otherwise nil")
    var weekday: Weekday?
}

let tz = TimeZone(identifier: "Asia/Jakarta")!
var cal = Calendar(identifier: .gregorian); cal.timeZone = tz; cal.firstWeekday = 2; cal.minimumDaysInFirstWeek = 4
let today = cal.date(from: DateComponents(year: 2026, month: 11, day: 25))!   // Wednesday
let df = DateFormatter(); df.locale = Locale(identifier: "en_US_POSIX"); df.timeZone = tz; df.dateFormat = "EEE yyyy-MM-dd"

func weekdayNumber(_ w: Weekday) -> Int { [.sunday: 1, .monday: 2, .tuesday: 3, .wednesday: 4, .thursday: 5, .friday: 6, .saturday: 7][w]! }
func evaluate(_ r: DateRule) -> Date? {
    var d = today
    d = cal.date(byAdding: .month, value: r.months, to: d)!
    d = cal.date(byAdding: .weekOfYear, value: r.weeks, to: d)!
    d = cal.date(byAdding: .day, value: r.days, to: d)!
    let week = cal.dateInterval(of: .weekOfYear, for: d)!
    let month = cal.dateInterval(of: .month, for: d)!
    switch r.anchor {
    case .today: return d
    case .upcomingWeekday:
        guard let w = r.weekday else { return nil }
        return cal.nextDate(after: d, matching: DateComponents(weekday: weekdayNumber(w)), matchingPolicy: .nextTime)
    case .weekdayOfWeek:
        guard let w = r.weekday else { return nil }
        return cal.nextDate(after: week.start.addingTimeInterval(-1), matching: DateComponents(weekday: weekdayNumber(w)), matchingPolicy: .nextTime)
    case .firstWeekdayOfMonth:
        guard let w = r.weekday else { return nil }
        return cal.nextDate(after: month.start.addingTimeInterval(-1), matching: DateComponents(weekday: weekdayNumber(w)), matchingPolicy: .nextTime)
    case .lastWeekdayOfMonth:
        guard let w = r.weekday else { return nil }
        return cal.nextDate(after: month.end, matching: DateComponents(weekday: weekdayNumber(w)), matchingPolicy: .nextTime, direction: .backward)
    case .startOfWeek: return week.start
    case .endOfWeek: return cal.date(byAdding: .day, value: -1, to: week.end)
    case .startOfMonth: return month.start
    case .endOfMonth: return cal.date(byAdding: .day, value: -1, to: month.end)
    case .lastWorkdayOfMonth:
        var x = cal.date(byAdding: .day, value: -1, to: month.end)!
        while cal.isDateInWeekend(x) { x = cal.date(byAdding: .day, value: -1, to: x)! }
        return x
    }
}

// (phrase, locale, acceptable answers)
let cases: [(String, String, [String])] = [
    ("tomorrow", "en_GB", ["Thu 2026-11-26"]),
    ("the day after tomorrow", "en_GB", ["Fri 2026-11-27"]),
    ("in 3 days", "en_GB", ["Sat 2026-11-28"]),
    ("two weeks from today", "en_GB", ["Wed 2026-12-09"]),
    ("this Friday", "en_GB", ["Fri 2026-11-27"]),
    ("next Friday", "en_GB", ["Fri 2026-11-27", "Fri 2026-12-04"]),
    ("Monday next week", "en_GB", ["Mon 2026-11-30"]),
    ("next week Thursday", "en_GB", ["Thu 2026-12-03"]),
    ("the Friday after next", "en_GB", ["Fri 2026-12-04", "Fri 2026-12-11"]),
    ("end of the month", "en_GB", ["Mon 2026-11-30"]),
    ("start of next month", "en_GB", ["Tue 2026-12-01"]),
    ("last day of next month", "en_GB", ["Thu 2026-12-31"]),
    ("first Monday of next month", "en_GB", ["Mon 2026-12-07"]),
    ("last Friday of the month", "en_GB", ["Fri 2026-11-27"]),
    ("last working day of the month", "en_GB", ["Mon 2026-11-30"]),
    ("in 2 months", "en_GB", ["Mon 2027-01-25"]),
    ("end of the week", "en_GB", ["Sun 2026-11-29", "Fri 2026-11-27"]),
    ("nächsten Freitag", "de_DE", ["Fri 2026-11-27", "Fri 2026-12-04"]),
    ("Ende des Monats", "de_DE", ["Mon 2026-11-30"]),
    ("in 3 Tagen", "de_DE", ["Sat 2026-11-28"]),
    ("vendredi prochain", "fr_FR", ["Fri 2026-11-27", "Fri 2026-12-04"]),
    ("fin du mois", "fr_FR", ["Mon 2026-11-30"]),
    ("fin de mes", "es_ES", ["Mon 2026-11-30"]),
    ("来週の金曜日", "ja_JP", ["Fri 2026-12-04"]),
    ("月末", "ja_JP", ["Mon 2026-11-30"]),
    ("akhir bulan", "id_ID", ["Mon 2026-11-30"]),
    ("Jumat depan", "id_ID", ["Fri 2026-11-27", "Fri 2026-12-04"]),
]

let model = SystemLanguageModel.default
print("availability:", model.availability)
func instructions(_ localeID: String) -> String {
    let locale = Locale(identifier: localeID)
    var lines: [String] = []
    if !Locale.Language(identifier: "en_US").isEquivalent(to: locale.language) {
        lines.append("The person's locale is \(locale.identifier).")   // Apple's exact phrase, see "Supporting languages and locales"
    }
    lines.append("Turn the person's description of a day into a DateRule relative to today. Weeks start on Monday. Do not compute a calendar date; describe the rule.")
    return lines.joined(separator: "\n")
}

let clock = ContinuousClock()
var correct = 0, answered = 0
let warm = LanguageModelSession(model: model, instructions: instructions("en_GB"))
let prewarmStart = clock.now
warm.prewarm()
print("prewarm() returned in", clock.now - prewarmStart)
for (i, c) in cases.enumerated() {
    let session = LanguageModelSession(model: model, instructions: instructions(c.1))
    let start = clock.now
    do {
        let response = try await session.respond(to: "Today is Wednesday. The day: \(c.0)", generating: DateRule.self, options: GenerationOptions(sampling: .greedy))
        let elapsed = clock.now - start
        let r = response.content
        let got = evaluate(r).map { df.string(from: $0) } ?? "nil"
        let ok = c.2.contains(got); answered += 1; if ok { correct += 1 }
        print(String(format: "%2d", i + 1), ok ? "OK  " : "MISS", "\(c.0) [\(c.1)] -> \(got)  (rule: months \(r.months) weeks \(r.weeks) days \(r.days) \(r.anchor) \(r.weekday.map { "\($0)" } ?? "-"))  \(elapsed.formatted(.units(allowed: [.milliseconds])))")
    } catch {
        print(String(format: "%2d", i + 1), "ERR ", "\(c.0) [\(c.1)] -> \(error)  \((clock.now - start).formatted(.units(allowed: [.milliseconds])))")
    }
}
print("correct \(correct) of \(answered) answered, \(cases.count) asked")
