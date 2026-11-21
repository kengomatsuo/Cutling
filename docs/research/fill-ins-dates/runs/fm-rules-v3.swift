// Third try: v2's vocabulary, with examples that also show count 0 for this month/week and the month-end kinds (none of them is a test phrase).
// Vocabulary, instructions and examples are this research's GUESS. M3 Mac, macOS 27, 2026-11-21. Today fixed to Wed 2026-11-25.
import Foundation
import FoundationModels

@Generable enum Kind {
    case inDays            // "tomorrow" (1), "in 3 days" (3), "yesterday" (-1)
    case inWeeks           // "in two weeks" (2)
    case inMonths          // "in 2 months" (2)
    case weekday           // a named day of the week; count 0 = the coming one, 1 = the one in next week
    case startOfMonth      // count = months ahead: 0 this month, 1 next month
    case endOfMonth
    case lastWorkdayOfMonth
    case firstWeekdayOfMonth  // "first Monday of next month": weekday + count months ahead
    case lastWeekdayOfMonth   // "last Friday of the month"
    case startOfWeek          // count = weeks ahead
    case endOfWeek
}
@Generable enum Weekday { case monday, tuesday, wednesday, thursday, friday, saturday, sunday }

@Generable(description: "A day described relative to today, as a rule that can be recomputed later")
struct DateRule {
    var kind: Kind
    @Guide(description: "The number in the phrase; for weekday, 0 means the coming one (this week) and 1 means the one in next week; for month and week kinds, how many months or weeks ahead")
    var count: Int
    @Guide(description: "The named day of the week, only for weekday kinds")
    var weekday: Weekday?
}

let tz = TimeZone(identifier: "Asia/Jakarta")!
var cal = Calendar(identifier: .gregorian); cal.timeZone = tz; cal.firstWeekday = 2; cal.minimumDaysInFirstWeek = 4
let today = cal.date(from: DateComponents(year: 2026, month: 11, day: 25))!   // Wednesday
let df = DateFormatter(); df.locale = Locale(identifier: "en_US_POSIX"); df.timeZone = tz; df.dateFormat = "EEE yyyy-MM-dd"
func wd(_ w: Weekday) -> Int { [.sunday: 1, .monday: 2, .tuesday: 3, .wednesday: 4, .thursday: 5, .friday: 6, .saturday: 7][w]! }

func evaluate(_ r: DateRule) -> Date? {
    let monthOf = { (n: Int) in cal.dateInterval(of: .month, for: cal.date(byAdding: .month, value: n, to: today)!)! }
    let weekOf = { (n: Int) in cal.dateInterval(of: .weekOfYear, for: cal.date(byAdding: .weekOfYear, value: n, to: today)!)! }
    switch r.kind {
    case .inDays: return cal.date(byAdding: .day, value: r.count, to: today)
    case .inWeeks: return cal.date(byAdding: .weekOfYear, value: r.count, to: today)
    case .inMonths: return cal.date(byAdding: .month, value: r.count, to: today)
    case .weekday:
        guard let w = r.weekday else { return nil }
        if r.count == 0 { return cal.nextDate(after: today, matching: DateComponents(weekday: wd(w)), matchingPolicy: .nextTime) }
        return cal.nextDate(after: weekOf(r.count).start.addingTimeInterval(-1), matching: DateComponents(weekday: wd(w)), matchingPolicy: .nextTime)
    case .startOfMonth: return monthOf(r.count).start
    case .endOfMonth: return cal.date(byAdding: .day, value: -1, to: monthOf(r.count).end)
    case .lastWorkdayOfMonth:
        var x = cal.date(byAdding: .day, value: -1, to: monthOf(r.count).end)!
        while cal.isDateInWeekend(x) { x = cal.date(byAdding: .day, value: -1, to: x)! }
        return x
    case .firstWeekdayOfMonth:
        guard let w = r.weekday else { return nil }
        return cal.nextDate(after: monthOf(r.count).start.addingTimeInterval(-1), matching: DateComponents(weekday: wd(w)), matchingPolicy: .nextTime)
    case .lastWeekdayOfMonth:
        guard let w = r.weekday else { return nil }
        return cal.nextDate(after: monthOf(r.count).end, matching: DateComponents(weekday: wd(w)), matchingPolicy: .nextTime, direction: .backward)
    case .startOfWeek: return weekOf(r.count).start
    case .endOfWeek: return cal.date(byAdding: .day, value: -1, to: weekOf(r.count).end)
    }
}

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

func instructions(_ localeID: String) -> String {
    let locale = Locale(identifier: localeID)
    var lines: [String] = []
    if !Locale.Language(identifier: "en_US").isEquivalent(to: locale.language) {
        lines.append("The person's locale is \(locale.identifier).")   // Apple's exact phrase
    }
    lines.append("""
    Describe the day the person names as a DateRule. Never compute a calendar date.
    Examples:
    tomorrow -> kind inDays, count 1
    in 10 days -> kind inDays, count 10
    in 3 weeks -> kind inWeeks, count 3
    Friday, this Friday -> kind weekday, count 0, weekday friday
    Tuesday next week, next week's Tuesday -> kind weekday, count 1, weekday tuesday
    start of the month -> kind startOfMonth, count 0
    end of next month -> kind endOfMonth, count 1
    first Wednesday of the month -> kind firstWeekdayOfMonth, count 0, weekday wednesday
    second-to-last... is not supported; pick the closest kind
    last Tuesday of next month -> kind lastWeekdayOfMonth, count 1, weekday tuesday
    last business day of next month -> kind lastWorkdayOfMonth, count 1
    start of this week -> kind startOfWeek, count 0
    Leave weekday empty unless the kind is weekday, firstWeekdayOfMonth or lastWeekdayOfMonth. Use count 0 unless the phrase says next, a number, or after.
    """)
    return lines.joined(separator: "\n")
}

let model = SystemLanguageModel.default
var correct = 0
var times: [Double] = []
for (i, c) in cases.enumerated() {
    let session = LanguageModelSession(model: model, instructions: instructions(c.1))
    let start = Date()
    do {
        let r = try await session.respond(to: c.0, generating: DateRule.self, options: GenerationOptions(sampling: .greedy)).content
        let secs = Date().timeIntervalSince(start); times.append(secs)
        let got = evaluate(r).map { df.string(from: $0) } ?? "nil"
        let ok = c.2.contains(got); if ok { correct += 1 }
        print(String(format: "%2d %@ %@ [%@] -> %@  (%@ %d %@)  %.2f s", i + 1, ok ? "OK  " : "MISS", c.0, c.1, got, "\(r.kind)", r.count, r.weekday.map { "\($0)" } ?? "-", secs))
    } catch {
        print(String(format: "%2d ERR  %@ [%@] -> %@  %.2f s", i + 1, c.0, c.1, "\(error)", Date().timeIntervalSince(start)))
    }
}
let sorted = times.sorted()
print(String(format: "correct %d of %d; time per phrase: first %.2f s, median %.2f s, max %.2f s", correct, cases.count, times.first ?? 0, sorted[sorted.count / 2], sorted.last ?? 0))
