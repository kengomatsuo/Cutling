// Prints "<windowNumber> <width> <height> <name>" for each on-screen normal window of a pid.
import CoreGraphics
import Foundation
let pid = Int32(CommandLine.arguments[1])!
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
for w in list where (w[kCGWindowOwnerPID as String] as? Int32) == pid {
    let b = w[kCGWindowBounds as String] as? [String: Any] ?? [:]
    print(w[kCGWindowNumber as String] ?? 0, b["Width"] ?? 0, b["Height"] ?? 0, w[kCGWindowLayer as String] ?? 0, w[kCGWindowName as String] ?? "-")
}
