import Foundation
var cal = Calendar(identifier: .gregorian); cal.timeZone = TimeZone(identifier: "Asia/Jakarta")!
let start = cal.date(from: DateComponents(year: 2026, month: 11, day: 1))!
let f = DateFormatter(); f.dateFormat = "EEE yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX"); f.timeZone = cal.timeZone
let workdays: [Calendar.RecurrenceRule.Weekday] = [.every(.monday), .every(.tuesday), .every(.wednesday), .every(.thursday), .every(.friday)]
let rule = Calendar.RecurrenceRule.monthly(calendar: cal, weekdays: workdays, setPositions: [-1])
print("last weekday of month, from Nov 1:", rule.recurrences(of: start).prefix(4).map { f.string(from: $0) })
let rule2 = Calendar.RecurrenceRule.monthly(calendar: cal, daysOfTheMonth: [-1])
print("last day of month, from Nov 1:", rule2.recurrences(of: start).prefix(4).map { f.string(from: $0) })
let rule3 = Calendar.RecurrenceRule.monthly(calendar: cal, weekdays: [.nth(1, .monday)])
print("first Monday, from Nov 1:", rule3.recurrences(of: start).prefix(3).map { f.string(from: $0) })
