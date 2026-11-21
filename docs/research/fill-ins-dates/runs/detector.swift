// What NSDataDetector (.date) returns for natural phrases, and what Calendar computes for the same days.
// Run: swift detector.swift  (macOS 27 SDK, run on 2026-11-21, a Saturday, Asia/Jakarta)
import Foundation

let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
let out = DateFormatter(); out.locale = Locale(identifier: "en_US_POSIX"); out.dateFormat = "EEE yyyy-MM-dd HH:mm"
func detect(_ s: String) {
    let ms = detector.matches(in: s, range: NSRange(s.startIndex..., in: s))
    if ms.isEmpty { print("  \(s.padding(toLength: 34, withPad: " ", startingAt: 0)) -> (no date found)"); return }
    let parts = ms.map { m -> String in
        let r = Range(m.range, in: s).map { String(s[$0]) } ?? "?"
        let d = m.date.map { out.string(from: $0) } ?? "nil"
        let dur = m.duration > 0 ? " dur=\(Int(m.duration))s" : ""
        let tz = m.timeZone.map { " tz=\($0.identifier)" } ?? ""
        return "\"\(r)\" = \(d)\(dur)\(tz)"
    }
    print("  \(s.padding(toLength: 34, withPad: " ", startingAt: 0)) -> \(parts.joined(separator: "; "))")
}
print("now:", out.string(from: Date()), TimeZone.current.identifier, Locale.current.identifier)
print("== English")
["today", "tomorrow", "the day after tomorrow", "yesterday", "in 3 days", "3 days from now", "in two weeks", "next week",
 "next Friday", "Friday", "this Friday", "on Friday", "Monday next week", "next month", "end of the month", "end of month",
 "the last day of the month", "end of the week", "start of next month", "first Monday of next month", "in 2 months",
 "tomorrow at 5pm", "next Friday at noon", "December 5", "5 Dec", "12/05/2026", "2026-12-05", "Christmas", "New Year's Day", "tonight", "this weekend"
].forEach(detect)
print("== German");   ["morgen", "übermorgen", "in 3 Tagen", "nächsten Freitag", "Freitag", "nächste Woche", "Ende des Monats", "am 5. Dezember"].forEach(detect)
print("== French");   ["demain", "après-demain", "dans 3 jours", "vendredi prochain", "vendredi", "la semaine prochaine", "fin du mois", "le 5 décembre"].forEach(detect)
print("== Spanish");  ["mañana", "pasado mañana", "en 3 días", "el próximo viernes", "viernes", "la próxima semana", "fin de mes", "5 de diciembre"].forEach(detect)
print("== Japanese"); ["明日", "明後日", "3日後", "来週の金曜日", "金曜日", "来週", "月末", "12月5日"].forEach(detect)
print("== Indonesian"); ["besok", "lusa", "3 hari lagi", "Jumat depan", "Jumat", "minggu depan", "akhir bulan", "5 Desember"].forEach(detect)
print("== Chinese");  ["明天", "后天", "3天后", "下周五", "下个月", "月底", "12月5日"].forEach(detect)
print("== Korean");   ["내일", "모레", "3일 후", "다음 주 금요일", "12월 5일"].forEach(detect)
print("== Arabic");   ["غدا", "الجمعة القادمة", "بعد 3 أيام"].forEach(detect)

print("\n== Calendar (en_US calendar, from the run time)")
var cal = Calendar(identifier: .gregorian); cal.locale = Locale(identifier: "en_US"); cal.timeZone = .current
let now = Date()
let today = cal.startOfDay(for: now)
func show(_ label: String, _ d: Date?) { print("  \(label.padding(toLength: 46, withPad: " ", startingAt: 0)) \(d.map { out.string(from: $0) } ?? "nil")") }
show("next Friday (nextDate weekday=6 .nextTime)", cal.nextDate(after: today, matching: DateComponents(weekday: 6), matchingPolicy: .nextTime))
show("next Saturday from a Saturday", cal.nextDate(after: today, matching: DateComponents(weekday: 7), matchingPolicy: .nextTime))
show("previous Friday (direction .backward)", cal.nextDate(after: today, matching: DateComponents(weekday: 6), matchingPolicy: .nextTime, direction: .backward))
let month = cal.dateInterval(of: .month, for: now)!
show("start of this month", month.start)
show("end of this month (interval.end - 1 day)", cal.date(byAdding: .day, value: -1, to: month.end))
show("start of next month", month.end)
let week = cal.dateInterval(of: .weekOfYear, for: now)!
show("start of this week (en_US: Sunday)", week.start)
var gb = cal; gb.locale = Locale(identifier: "en_GB")
show("start of this week (en_GB: Monday)", gb.dateInterval(of: .weekOfYear, for: now)!.start)
let nextWeekStart = gb.date(byAdding: .weekOfYear, value: 1, to: gb.dateInterval(of: .weekOfYear, for: now)!.start)!
show("Monday next week (en_GB)", gb.nextDate(after: nextWeekStart.addingTimeInterval(-1), matching: DateComponents(weekday: 2), matchingPolicy: .nextTime))
show("+1 month from Jan 31 (clamps)", cal.date(byAdding: .month, value: 1, to: cal.date(from: DateComponents(year: 2027, month: 1, day: 31))!))
var weekdaysOnly = 0; var d = today
while weekdaysOnly < 3 { d = cal.date(byAdding: .day, value: 1, to: d)!; if !cal.isDateInWeekend(d) { weekdaysOnly += 1 } }
show("3 working days later (isDateInWeekend)", d)
if #available(macOS 15, *) {
    let firstMonday = Calendar.RecurrenceRule.monthly(calendar: cal, weekdays: [.nth(1, .monday)])
    show("RecurrenceRule first Monday of a month", firstMonday.recurrences(of: today).first { $0 > now })
    let lastDay = Calendar.RecurrenceRule.monthly(calendar: cal, daysOfTheMonth: [-1])
    show("RecurrenceRule last day of month", lastDay.recurrences(of: today).first { $0 >= today })
    let lastFriday = Calendar.RecurrenceRule.monthly(calendar: cal, weekdays: [.nth(-1, .friday)])
    show("RecurrenceRule last Friday of month", lastFriday.recurrences(of: today).first { $0 >= today })
    let lastWorkday = Calendar.RecurrenceRule.monthly(calendar: cal, weekdays: [.every(.monday), .every(.tuesday), .every(.wednesday), .every(.thursday), .every(.friday)], setPositions: [-1])
    show("RecurrenceRule last weekday of month (BYSETPOS=-1)", lastWorkday.recurrences(of: today).first { $0 >= today })
    let data = try! JSONEncoder().encode(lastFriday)
    print("  RecurrenceRule Codable JSON:", String(data: data, encoding: .utf8)!)
}
