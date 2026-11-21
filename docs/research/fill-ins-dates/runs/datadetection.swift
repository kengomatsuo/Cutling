// DataDetection (iOS 26 / macOS 26): the newer detector, which takes a reference date and a language.
// Run: swift datadetection.swift  (macOS 27 SDK, 2026-11-21). Reference date: Wednesday 2026-11-25 09:00 Asia/Jakarta.
import Foundation
import DataDetection

let tz = TimeZone(identifier: "Asia/Jakarta")!
var gc = Calendar(identifier: .gregorian); gc.timeZone = tz
let wed = gc.date(from: DateComponents(year: 2026, month: 11, day: 25, hour: 9))!
let out = DateFormatter(); out.locale = Locale(identifier: "en_US_POSIX"); out.dateFormat = "EEE yyyy-MM-dd HH:mm"; out.timeZone = tz

func run(_ lang: String, _ phrases: [String]) async {
    var options = DataDetector.Options()
    options.documentDate = wed
    options.documentTimeZone = tz
    options.documentLanguageCode = Locale.LanguageCode(lang)
    print("== \(lang) (reference Wed 2026-11-25)")
    for s in phrases {
        var found: [String] = []
        for await m in s.dataDetectorMatches(.calendarEvent, options: options) {
            if case .calendarEvent(let e) = m.details {
                let r = m.range.map { String(s[$0]) } ?? "?"
                found.append("\"\(r)\" = \(e.startDate.map { out.string(from: $0) } ?? "nil")\(e.allDay ? " all-day" : "")\(e.endDate.map { " to " + out.string(from: $0) } ?? "")")
            }
        }
        print("  \(s.padding(toLength: 30, withPad: " ", startingAt: 0)) -> \(found.isEmpty ? "(none)" : found.joined(separator: "; "))")
    }
}
await run("en", ["tomorrow", "in 3 days", "next Friday", "this Friday", "Friday", "Friday next week", "Monday next week", "next Monday", "next week", "end of the month", "end of month", "last day of the month", "in 2 months", "first Monday of December", "December 5", "the 1st"])
await run("de", ["morgen", "in 3 Tagen", "nächsten Freitag", "Freitag", "Ende des Monats", "am 5. Dezember"])
await run("es", ["mañana", "en 3 días", "el próximo viernes", "fin de mes", "5 de diciembre"])
await run("ar", ["غدا", "الجمعة القادمة", "بعد 3 أيام"])
await run("id", ["besok", "Jumat depan", "3 hari lagi", "akhir bulan"])
