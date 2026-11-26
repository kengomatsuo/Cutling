//
//  UnlockCelebrationMotion.swift
//  Cutling
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI

/// The unlock celebration as pure functions of the milliseconds since t0, ported from
/// docs/plans/unlock/celebration/src/motion.js (card ASG240). `scripts/check-celebration.sh` compares this file with the
/// reference's fixtures.json; every number here is a value of that design's spec.json.
/// Nothing in this file knows a view, the store or the clock: `UnlockRoom` lays the room out once, `frame(at:)` answers
/// for one instant.
enum UnlockMotion {
    // MARK: Spec

    static let heroTile = 48.0
    static let heroGap = 10.0
    static let tileRatioEnd = 0.72
    static let dotFrom = 30.0
    static let dotTo = 12.0
    static let revealStartMs = 60.0
    static let tailStartMs = 1100.0
    static let landMs = 1650.0
    static let zoomStartMs = 300.0
    static let zoomMs = 900.0
    static let endMs = 2200.0
    static let tapThroughMs = 150.0
    static let beatMs = 250.0
    static let wordsStartMs = 1420.0
    static let wordsStaggerMs = 60.0
    static let wordsFadeMs = 300.0
    static let wordsRise = 10.0
    static let cellFadeInMs = 90.0
    static let cellTintHoldMs = 40.0
    static let cellTintMs = 300.0
    static let cellScaleFrom = 0.25
    /// A slot is at rest this long after it appears: its scale spring (0.38 s) has decayed under 0.0001 and its tint is done.
    static let cellSettledMs = 700.0
    /// Slots that appeared within the same few milliseconds are drawn with one look: a frame is 8 to 17 ms.
    static let cellBucketMs = 4.0
    static let roomFadeMs = 200.0
    static let exitStaggerMs = 30.0
    static let exitMs = 160.0
    static let extrasMs = 200.0
    static let buttonMs = 200.0
    static let settleDashMs = 150.0
    static let settleFillMs = 200.0
    static let reduceOutMs = 125.0
    static let reduceInMs = 125.0
    static let minRoomHeight = 120.0

    private static let easeOut = UnitCurve.bezier(startControlPoint: UnitPoint(x: 0, y: 0), endControlPoint: UnitPoint(x: 0.58, y: 1))
    private static let easeIn = UnitCurve.bezier(startControlPoint: UnitPoint(x: 0.42, y: 0), endControlPoint: UnitPoint(x: 1, y: 1))
    private static let fillCurve = UnitCurve.bezier(startControlPoint: UnitPoint(x: 0.25, y: 0), endControlPoint: UnitPoint(x: 0.4, y: 1))
    private static let settleTilt = Spring(duration: 0.45, bounce: 0.15)
    private static let settleBump = Spring(duration: 0.4, bounce: 0.4)
    private static let cellSpring = Spring(duration: 0.38, bounce: 0.3)
    private static let wordSpring = Spring(duration: 0.5, bounce: 0)

    // MARK: Curves

    static func clamp01(_ x: Double) -> Double { min(1, max(0, x)) }
    static func lerp(_ a: Double, _ b: Double, _ m: Double) -> Double { a + (b - a) * m }
    static func smootherstep(_ x: Double) -> Double { x * x * x * (x * (6 * x - 15) + 10) }
    static func fade(_ curve: UnitCurve, _ ms: Double, over duration: Double) -> Double { curve.value(at: clamp01(ms / duration)) }

    /// SwiftUI `Spring` moved from `a` to `b` from rest, `ms` after it started.
    private static func spring(_ s: Spring, _ ms: Double, _ a: Double, _ b: Double) -> Double {
        ms <= 0 ? a : a + s.value(target: b - a, time: ms / 1000)
    }

    /// Up to `peak` on smootherstep over `riseMs`, then a spring back to 0 from rest: no kick in the speed.
    private static func bump(_ ms: Double, riseMs: Double, peak: Double) -> Double {
        if ms <= 0 { return 0 }
        if ms < riseMs { return peak * smootherstep(ms / riseMs) }
        return spring(settleBump, ms - riseMs, peak, 0)
    }

    // MARK: Frame

    /// Everything that moves, at one instant. Lengths are points, angles degrees, the rest 0 to 1.
    struct Frame {
        /// Distance between slots, the tile's share of it, and 0 to 1 along the zoom.
        var pitch = 0.0, tileRatio = 0.0, zoom = 0.0
        /// 0 as a tile, 1 as a dot of its colour; the icon's opacity is 1 - dot.
        var dot = 0.0
        var sixthRotation = 0.0, sixthScale = 1.0, sixthDash = 0.0, sixthLift = 0.0, sixthWash = 0.0
        /// The bracket, "5 free" and the two spare slots.
        var extras = 0.0
        var buttonFill = 0.0, buttonBuyLabel = 0.0, buttonDoneLabel = 0.0
        /// Opacity of the ask's title, subtitle, three rows and Restore Purchases, in that order.
        var exit = [Double](repeating: 0, count: 6)
        var roomOpacity = 0.0
        var titleOpacity = 0.0, titleDY = 0.0, subtitleOpacity = 0.0, subtitleDY = 0.0

        var tileSize: Double { pitch * tileRatio }

        /// The ask before t0: tiles in a row at the hero's size, the sixth tilted and lifted, every word showing.
        static let ask = Frame(
            pitch: heroTile + heroGap, tileRatio: heroTile / (heroTile + heroGap), zoom: 0, dot: 0,
            sixthRotation: 5, sixthScale: 1, sixthDash: 1, sixthLift: 1, sixthWash: 0, extras: 1,
            buttonFill: 0, buttonBuyLabel: 1, buttonDoneLabel: 0, exit: [Double](repeating: 1, count: 6),
            roomOpacity: 0, titleOpacity: 0, titleDY: wordsRise, subtitleOpacity: 0, subtitleDY: wordsRise)

        /// This frame moving to `end` by `m` (0 to 1): a tap on the sheet takes every element to its end value.
        func blended(to end: Frame, _ m: Double) -> Frame {
            func l(_ a: Double, _ b: Double) -> Double { UnlockMotion.lerp(a, b, m) }
            return Frame(
                pitch: l(pitch, end.pitch), tileRatio: l(tileRatio, end.tileRatio), zoom: l(zoom, end.zoom), dot: l(dot, end.dot),
                sixthRotation: l(sixthRotation, end.sixthRotation), sixthScale: l(sixthScale, end.sixthScale),
                sixthDash: l(sixthDash, end.sixthDash), sixthLift: l(sixthLift, end.sixthLift), sixthWash: l(sixthWash, end.sixthWash),
                extras: l(extras, end.extras),
                buttonFill: l(buttonFill, end.buttonFill), buttonBuyLabel: l(buttonBuyLabel, end.buttonBuyLabel), buttonDoneLabel: l(buttonDoneLabel, end.buttonDoneLabel),
                exit: zip(exit, end.exit).map { l($0, $1) },
                roomOpacity: l(roomOpacity, end.roomOpacity),
                titleOpacity: l(titleOpacity, end.titleOpacity), titleDY: l(titleDY, end.titleDY),
                subtitleOpacity: l(subtitleOpacity, end.subtitleOpacity), subtitleDY: l(subtitleDY, end.subtitleDY))
        }
    }

    /// One slot of the room `age` ms after it appeared: scale about its centre, opacity, and how far its colour has gone
    /// from brand to rest.
    struct Slot {
        var scale: Double, opacity: Double, tint: Double
        static let hidden = Slot(scale: cellScaleFrom, opacity: 0, tint: 0)
        static let resting = Slot(scale: 1, opacity: 1, tint: 1)

        init(scale: Double, opacity: Double, tint: Double) { self.scale = scale; self.opacity = opacity; self.tint = tint }

        init(age: Double) {
            scale = lerp(cellScaleFrom, 1, spring(cellSpring, age, 0, 1))
            opacity = clamp01(age / cellFadeInMs)
            tint = easeOut.value(at: clamp01((age - cellTintHoldMs) / cellTintMs))
        }

        func blended(to end: Slot, _ m: Double) -> Slot {
            Slot(scale: lerp(scale, end.scale, m), opacity: lerp(opacity, end.opacity, m), tint: lerp(tint, end.tint, m))
        }
    }

    /// Where the room's slots are and when each appears, laid out once for the room's frame (`width` x `height` pt).
    struct Room {
        let cols: Int, rows: Int, lastRow: Int
        /// Rows drawn: the grid's last row only when it is full, so the room never ends on a short row (owner, 2026-11-26:
        /// it shows that there is plenty of room, not an exact count). The layout and timing still use every row.
        let drawnRows: Int
        let p0: Double, p1: Double, k0: Double
        let heroCells: Int
        /// Milliseconds after t0 at which slot `j * cols + i` appears; -1 for the hero's own cells.
        let revealMs: [Float]
        /// Slot indexes in order of appearance, and their times.
        let order: [Int32]
        let orderMs: [Float]
        let capacity: Int
        private let rFill: Double, rTail: Double

        init(capacity: Int, limit: Int, sixth: Bool, width: Double, height: Double, heroTile: Double = UnlockMotion.heroTile, heroGap: Double = UnlockMotion.heroGap) {
            self.capacity = capacity
            cols = Int((Double(capacity) * width / height).squareRoot().rounded())
            rows = Int((Double(capacity) / Double(cols)).rounded(.up))
            lastRow = capacity - (rows - 1) * cols
            drawnRows = lastRow < cols ? rows - 1 : rows
            p0 = heroTile + heroGap
            k0 = heroTile / p0
            p1 = min(width / (Double(cols - 1) + tileRatioEnd), height / (Double(rows - 1) + tileRatioEnd))
            heroCells = limit + (sixth ? 1 : 0)
            let oi = Double(heroCells - 1)
            var dmax = 0.0
            for j in 0..<rows {
                for i in 0..<(j == rows - 1 ? lastRow : cols) where !(j == 0 && i < heroCells) {
                    dmax = max(dmax, hypot(Double(i) - oi, Double(j)))
                }
            }
            let rEnd = dmax * p1
            rFill = min(height - p1, rEnd)
            rTail = max(0, rEnd - rFill)
            // The ring's reach, in slots, at every millisecond: it only grows, so each slot's time is found by search.
            let steps = Int(landMs)
            let p0 = self.p0, p1 = self.p1, rFill = self.rFill, rTail = self.rTail
            let reach = (0...steps).map { ms -> Double in
                let t = Double(ms)
                let zoomEnd = zoomStartMs + zoomMs
                let front = rFill * fillCurve.value(at: clamp01((t - revealStartMs) / (zoomEnd - revealStartMs)))
                    + rTail * smootherstep(clamp01((t - tailStartMs) / (landMs - tailStartMs)))
                return front / (p0 * pow(p1 / p0, smootherstep(clamp01((t - zoomStartMs) / zoomMs))))
            }
            var reveal = [Float](repeating: -1, count: capacity)
            var list: [(Float, Int32)] = []
            list.reserveCapacity(capacity)
            for j in 0..<drawnRows {
                for i in 0..<cols where !(j == 0 && i < heroCells) {
                    let d = hypot(Double(i) - oi, Double(j))
                    var lo = 0, hi = steps
                    while lo < hi { let mid = (lo + hi) / 2; if reach[mid] >= d { hi = mid } else { lo = mid + 1 } }
                    var t = Double(hi)
                    if hi > 0 { let a = reach[hi - 1], b = reach[hi]; if b > a { t = Double(hi - 1) + (d - a) / (b - a) } }
                    let index = j * cols + i
                    reveal[index] = Float(t)
                    list.append((Float(t), Int32(index)))
                }
            }
            list.sort { $0.0 < $1.0 }
            revealMs = reveal
            order = list.map { $0.1 }
            orderMs = list.map { $0.0 }
        }

        /// The ring's radius in points at `t`.
        func ring(at t: Double) -> Double {
            let zoomEnd = zoomStartMs + zoomMs
            return rFill * fillCurve.value(at: clamp01((t - revealStartMs) / (zoomEnd - revealStartMs)))
                + rTail * smootherstep(clamp01((t - tailStartMs) / (landMs - tailStartMs)))
        }

        /// Slots on screen at `t`, the hero's own cells included.
        func count(at t: Double) -> Int {
            var lo = 0, hi = orderMs.count
            while lo < hi { let mid = (lo + hi) / 2; if Double(orderMs[mid]) <= t { lo = mid + 1 } else { hi = mid } }
            return heroCells + lo
        }

        /// The frame at `t` ms after t0. Before t0 (t < 0) it is the ask.
        func frame(at t: Double) -> Frame {
            let tc = max(t, 0)
            var f = Frame()
            f.zoom = smootherstep(clamp01((t - zoomStartMs) / zoomMs))
            f.pitch = p0 * pow(p1 / p0, f.zoom)
            f.tileRatio = lerp(k0, UnlockMotion.tileRatioEnd, f.zoom)
            f.dot = clamp01((dotFrom - f.tileSize) / (dotFrom - dotTo))
            let settled = t > 0 ? spring(settleTilt, t, 1, 0) : 1
            f.sixthRotation = 5 * settled
            f.sixthLift = settled
            f.sixthDash = t > 0 ? 1 - fade(easeOut, t, over: settleDashMs) : 1
            f.sixthWash = t > 0 ? clamp01(t / settleFillMs) : 0
            f.sixthScale = 1 + bump(t, riseMs: 100, peak: 0.1)
            for index in 0..<6 {
                f.exit[index] = 1 - fade(easeIn, tc - Double(index) * exitStaggerMs, over: exitMs)
            }
            f.extras = 1 - fade(easeOut, tc, over: extrasMs)
            f.buttonFill = fade(easeOut, tc, over: buttonMs)
            f.buttonBuyLabel = 1 - fade(easeOut, tc, over: buttonMs / 2)
            f.buttonDoneLabel = fade(easeOut, tc - buttonMs / 2, over: buttonMs / 2)
            f.roomOpacity = fade(easeOut, t - Double(orderMs.first ?? 0), over: roomFadeMs)
            let rise = [wordsStartMs, wordsStartMs + wordsStaggerMs].map { start in
                (opacity: fade(easeOut, t - start, over: wordsFadeMs), dy: t < start ? wordsRise : spring(wordSpring, t - start, wordsRise, 0))
            }
            f.titleOpacity = rise[0].opacity; f.titleDY = rise[0].dy
            f.subtitleOpacity = rise[1].opacity; f.subtitleDY = rise[1].dy
            return f
        }
    }

    /// Reduce Motion: the ask fades out, then the finished room fades in. Returns both opacities.
    static func reduceMix(at t: Double) -> (out: Double, in: Double) {
        (easeIn.value(at: clamp01(t / reduceOutMs)), easeOut.value(at: clamp01((t - reduceOutMs) / reduceInMs)))
    }
}

/// One celebration: when t0 was, whether it moves, and when a tap jumped it to its end. The iPhone sheet and the Mac
/// window each hold one and draw `UnlockShown.at` from it, so both play the same moment.
struct UnlockMoment {
    let start: Date
    /// Reduce Motion or Prefer Cross-Fade Transitions: the ask fades out and the finished room fades in.
    let reduced: Bool
    var tapMs: Double?
    /// Nothing moves any more, so the clock can stop drawing.
    var settled = false

    func ms(at date: Date) -> Double { date.timeIntervalSince(start) * 1000 }

    func isOver(at date: Date) -> Bool {
        let t = ms(at: date)
        if reduced { return t >= UnlockMotion.reduceOutMs + UnlockMotion.reduceInMs }
        return t >= (tapMs.map { $0 + UnlockMotion.tapThroughMs } ?? UnlockMotion.endMs)
    }

    /// A tap on the sheet takes every element to its end in 150 ms. Returns the instant it jumped from, or nil when the
    /// moment is reduced, already jumped or already over.
    mutating func jumpToEnd(at date: Date) -> Double? {
        guard !reduced, tapMs == nil else { return nil }
        let t = ms(at: date)
        guard t < UnlockMotion.endMs else { return nil }
        tapMs = t
        return t
    }
}

/// What is drawn at one instant: the frame of everything that moves, and how the room's slots are drawn.
struct UnlockShown {
    var frame: UnlockMotion.Frame
    /// Reduce Motion: the finished room, fading in over the ask.
    var end: UnlockMotion.Frame?
    var slotsAt: Double?
    var settle = 0.0

    /// `ask` is the platform's ask (its tile size, the sixth upright under Reduce Motion); `t` is ms after t0.
    static func at(_ t: Double, ask: UnlockMotion.Frame, moment: UnlockMoment?, room: UnlockMotion.Room?) -> UnlockShown {
        // The room's view is made during the beat before t0, drawing no slot yet, so its first frame is not t0's.
        guard let moment, let room else { return UnlockShown(frame: ask, slotsAt: room == nil ? nil : -1) }
        if moment.reduced {
            let mix = UnlockMotion.reduceMix(at: t)
            var end = room.frame(at: UnlockMotion.endMs)
            end.roomOpacity = mix.in; end.titleOpacity = mix.in; end.subtitleOpacity = mix.in
            end.titleDY = 0; end.subtitleDY = 0; end.buttonBuyLabel = 0; end.buttonDoneLabel = mix.in
            var frame = ask
            frame.exit = [Double](repeating: 1 - mix.out, count: 6)
            frame.extras = 1 - mix.out
            frame.buttonBuyLabel = 1 - mix.out
            frame.buttonDoneLabel = mix.in
            return UnlockShown(frame: frame, end: end)
        }
        if let tap = moment.tapMs {
            let m = UnlockMotion.clamp01((t - tap) / UnlockMotion.tapThroughMs)
            return UnlockShown(frame: room.frame(at: tap).blended(to: room.frame(at: UnlockMotion.endMs), m), slotsAt: tap, settle: m)
        }
        let now = min(t, UnlockMotion.endMs)
        return UnlockShown(frame: room.frame(at: now), slotsAt: now)
    }
}
