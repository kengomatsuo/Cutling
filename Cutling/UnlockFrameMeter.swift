//
//  UnlockFrameMeter.swift
//  Cutling
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#if DEBUG && os(iOS)
import QuartzCore

/// `-UnlockFrameMeter`: measures the unlock celebration's 2.2 seconds with the display's own clock and writes the result
/// to /tmp/unlock-frames.json (a simulator shares the Mac's /tmp): the gaps between frames the display link delivered,
/// and what the room's drawing closure cost on the main thread. Debug builds only; nothing ships.
@MainActor
final class UnlockFrameMeter: NSObject {
    static let shared = UnlockFrameMeter()
    private let isOn = ProcessInfo.processInfo.arguments.contains("-UnlockFrameMeter")
    private var link: CADisplayLink?
    private var last: CFTimeInterval = 0
    private var gaps: [Double] = []
    private var draws: [Double] = []

    func begin() {
        guard isOn else { return }
        gaps = []; draws = []; last = 0
        link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        link?.add(to: .main, forMode: .common)
    }

    /// The room as laid out for this sheet, for comparing with the design's table (debug builds, every run).
    func noted(_ room: UnlockMotion.Room, size: CGSize) {
        let text = "{\"width\": \(size.width), \"height\": \(size.height), \"cols\": \(room.cols), \"rows\": \(room.rows), \"lastRow\": \(room.lastRow), \"p0\": \(room.p0), \"p1\": \(room.p1), \"firstSlotMs\": \(room.orderMs.first ?? 0), \"lastSlotMs\": \(room.orderMs.last ?? 0)}"
        try? text.write(toFile: "/tmp/unlock-room.json", atomically: true, encoding: .utf8)
    }

    /// Called from the room's Canvas closure with how long it ran.
    nonisolated func drew(_ duration: Duration) {
        let ms = Double(duration.components.attoseconds) / 1e15 + Double(duration.components.seconds) * 1000
        Task { @MainActor in if isOn { draws.append(ms) } }
    }

    @objc private func tick(_ link: CADisplayLink) {
        if last > 0 { gaps.append((link.timestamp - last) * 1000) }
        last = link.timestamp
    }

    func end() {
        guard isOn, let link else { return }
        link.invalidate(); self.link = nil
        func stat(_ v: [Double]) -> [String: Double] {
            let s = v.sorted()
            guard !s.isEmpty else { return [:] }
            return ["n": Double(s.count), "mean": s.reduce(0, +) / Double(s.count), "p50": s[s.count / 2], "p95": s[Int(Double(s.count) * 0.95)], "p99": s[Int(Double(s.count) * 0.99)], "max": s.last!]
        }
        let nominal = gaps.sorted()[gaps.count / 2]
        let late = gaps.filter { $0 > nominal * 1.5 }.count
        let result: [String: Any] = ["gaps": gaps.map { ($0 * 10).rounded() / 10 }, "canvasSeries": draws.map { ($0 * 100).rounded() / 100 }, "frameGapMs": stat(gaps), "framesLate": late, "nominalMs": nominal, "canvasMs": stat(draws)]
        if let data = try? JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys]) {
            try? data.write(to: URL(fileURLWithPath: "/tmp/unlock-frames.json"))
        }
    }
}
#endif
