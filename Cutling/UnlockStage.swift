//
//  UnlockStage.swift
//  Cutling
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI

/// The unlock sheet's hero tiles and the room's slots at one instant (docs/plans/unlock/celebration, card ASG240).
/// Origin is the hero's top leading corner; the first tile and the camera stay pinned there while the pitch shrinks.
/// It draws what `UnlockMotion.Frame` says and holds no time of its own.
struct UnlockStage: View {
    /// The person's own cutlings in the hero, at most the free limit.
    let cutlings: [Cutling]
    /// A sixth tile (the waiting + here) stands after the five.
    let hasSixth: Bool
    /// The sixth has nothing to land (a restore): it leaves with the ask's bracket instead.
    var sixthLeaves = false
    let frame: UnlockMotion.Frame
    let room: UnlockMotion.Room?
    /// Milliseconds after t0 the slots are drawn at; nil draws none. `settle` takes every slot on to its resting look.
    var slotsAt: Double?
    var settle = 0.0
    /// The room's frame (width and height in points) and the sheet's padding past it.
    let roomSize: CGSize
    let trailingPadding: CGFloat

    @Environment(\.layoutDirection) private var direction
    @Environment(\.colorScheme) private var scheme

    private var side: CGFloat { frame.tileSize }
    private var cells: Int { Unlock.freeLimit + (hasSixth ? 1 : 0) }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let room, let slotsAt {
                UnlockSlots(room: room, frame: frame, at: slotsAt, settle: settle, direction: direction)
                    .frame(width: roomSize.width + trailingPadding, height: roomSize.height)
            }
            ForEach(0..<cells, id: \.self) { index in
                tile(index)
                    .frame(width: side, height: side)
                    // offset follows the layout direction on its own: positive is toward the trailing edge
                    .offset(x: CGFloat(index) * frame.pitch)
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder private func tile(_ index: Int) -> some View {
        let radius = side * UnlockSlots.radiusRatio
        let icon = 20 * side / UnlockMotion.heroTile
        if index == Unlock.freeLimit {
            ZStack {
                RoundedRectangle(cornerRadius: radius).fill(Color.brandGreen.opacity(0.12 + 0.88 * frame.dot))
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(Color.brandGreen, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                    .opacity(frame.sixthDash)
                Image(systemName: "plus")
                    .font(.system(size: icon, weight: .semibold))
                    .foregroundStyle(Color.brandGreen)
                    .opacity(1 - frame.dot)
            }
            .rotationEffect(.degrees(-frame.sixthRotation))
            .scaleEffect(frame.sixthScale)
            .shadow(color: .black.opacity((scheme == .dark ? 0.5 : 0.14) * frame.sixthLift), radius: 6, y: 4 * frame.sixthLift)
            .opacity(sixthLeaves ? frame.extras : 1)
        } else if index < cutlings.count {
            let item = cutlings[index]
            ZStack {
                RoundedRectangle(cornerRadius: radius).fill(item.tintColor.opacity(0.12 + 0.88 * frame.dot))
                Image(systemName: item.icon)
                    .font(.system(size: icon, weight: .medium))
                    .foregroundStyle(item.tintColor)
                    .opacity(1 - frame.dot)
            }
        } else {
            // A spare slot of the free five: dashed in the ask, one more slot of the room once it opens.
            ZStack {
                RoundedRectangle(cornerRadius: radius).fill(UnlockSlots.rest).opacity(1 - frame.extras)
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(.quaternary, style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    .opacity(frame.extras)
            }
        }
    }
}

/// The room: one rounded square for each cutling the unlock makes room for, in a grid that fills the room's frame.
/// Slots that have rested are one path and one fill; only the ones still appearing are drawn one by one.
struct UnlockSlots: View {
    let room: UnlockMotion.Room
    let frame: UnlockMotion.Frame
    let at: Double
    let settle: Double
    let direction: LayoutDirection

    /// A slot's corner radius is a quarter of its side at every zoom level.
    static let radiusRatio = 0.25
    /// The slot's colour at rest: the system fill, which is the design's rgba(120,120,128,0.2) light and 0.36 dark.
    static var rest: Color {
        #if os(iOS)
        Color(uiColor: .systemFill)
        #else
        Color(nsColor: .quaternaryLabelColor)
        #endif
    }

    var body: some View {
        #if os(iOS)
        if let metal = UnlockMetal.shared {
            UnlockMetalSlots(metal: metal, room: room, frame: frame, at: at, settle: settle, mirrored: direction == .rightToLeft)
        } else {
            canvas
        }
        #else
        canvas
        #endif
    }

    /// The same room drawn on the main thread, for a device without Metal and for the Mac.
    private var canvas: some View {
        Canvas { context, size in
            #if DEBUG && os(iOS)
            let started = ContinuousClock.now
            defer { UnlockFrameMeter.shared.drew(ContinuousClock.now - started) }
            #endif
            if direction == .rightToLeft {
                context.translateBy(x: size.width, y: 0)
                context.scaleBy(x: -1, y: 1)
            }
            let cols = room.cols
            let pitch = frame.pitch, side = frame.tileSize
            let reveal = max(0, room.count(at: at) - room.heroCells)
            let rested = max(0, room.count(at: at - UnlockMotion.cellSettledMs) - room.heroCells)
            func rect(_ index: Int32, _ scale: Double) -> CGRect? {
                let x = Double(Int(index) % cols) * pitch, y = Double(Int(index) / cols) * pitch
                guard x <= size.width, y <= size.height else { return nil }
                let inset = side * (1 - scale) / 2
                return CGRect(x: x + inset, y: y + inset, width: side * scale, height: side * scale)
            }
            let corner = side * Self.radiusRatio
            // Slots that have rested are one path and one fill.
            var resting = Path()
            for k in 0..<rested { if let r = rect(room.order[k], 1) { resting.addRoundedRect(in: r, cornerSize: CGSize(width: corner, height: corner)) } }
            context.fill(resting, with: .color(Self.rest))
            // The others share a look by the millisecond they appeared in (every 4 ms), so each look is one path and at
            // most two fills, not two fills per slot.
            func fill(_ slot: UnlockMotion.Slot, _ cells: Range<Int>) {
                guard slot.opacity > 0 else { return }
                var path = Path()
                let r = corner * slot.scale
                for k in cells { if let box = rect(room.order[k], slot.scale) { path.addRoundedRect(in: box, cornerSize: CGSize(width: r, height: r)) } }
                if slot.tint < 1 { context.fill(path, with: .color(Color.brandGreen.opacity(slot.opacity * (1 - slot.tint)))) }
                if slot.tint > 0 { context.fill(path, with: .color(Self.rest.opacity(slot.opacity * slot.tint))) }
            }
            func bucket(_ k: Int) -> Int { Int((at - Double(room.orderMs[k])) / UnlockMotion.cellBucketMs) }
            var k = rested
            while k < reveal {
                let b = bucket(k)
                var e = k + 1
                while e < reveal && bucket(e) == b { e += 1 }
                var slot = UnlockMotion.Slot(age: (Double(b) + 0.5) * UnlockMotion.cellBucketMs)
                if settle > 0 { slot = slot.blended(to: .resting, settle) }
                fill(slot, k..<e)
                k = e
            }
            if settle > 0 && reveal < room.order.count { fill(UnlockMotion.Slot.hidden.blended(to: .resting, settle), reveal..<room.order.count) }
        }
        .accessibilityHidden(true)
    }
}
