// Same detector, run as a binary with -AppleLanguages to see whether the preferred language changes what is found.
import Foundation
let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
let out = DateFormatter(); out.locale = Locale(identifier: "en_US_POSIX"); out.dateFormat = "EEE yyyy-MM-dd HH:mm"
print("preferred:", Locale.preferredLanguages.prefix(2))
for s in ["morgen", "in 3 Tagen", "nächsten Freitag", "am 5. Dezember", "mañana", "el próximo viernes", "en 3 días", "غدا", "الجمعة القادمة", "next Friday", "demain"] {
    let ms = detector.matches(in: s, range: NSRange(s.startIndex..., in: s))
    print("  \(s) ->", ms.map { m in "\"\((s as NSString).substring(with: m.range))\" = \(m.date.map { out.string(from: $0) } ?? "nil")" }.joined(separator: "; ").ifEmpty("(no date found)"))
}
extension String { func ifEmpty(_ s: String) -> String { isEmpty ? s : self } }
