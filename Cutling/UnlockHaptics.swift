//
//  UnlockHaptics.swift
//  Cutling
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#if os(iOS)
import CoreHaptics

/// The unlock celebration's haptic pattern (docs/plans/unlock/celebration, card ASG240): one Core Haptics player started
/// at t0, a light tap as the tile lands, taps that speed up with the count, and one strong hit as it lands on 5,000.
/// The copy's system success haptic is not played here. Phones without a haptic engine, and System Haptics off, play
/// nothing: haptics are an extra, so a failure here never reaches the picture.
@MainActor
final class UnlockHaptics {
    static let shared = UnlockHaptics()
    private var engine: CHHapticEngine?
    private var player: CHHapticAdvancedPatternPlayer?

    /// Starts the engine ahead of t0, so the pattern starts at t0 and not an engine start later.
    func prepare() {
        guard engine == nil, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let engine = try? CHHapticEngine()
        engine?.isAutoShutdownEnabled = true
        // A stopped or reset engine is dropped; the next unlock makes a new one.
        engine?.stoppedHandler = { [weak self] _ in Task { @MainActor in self?.engine = nil; self?.player = nil } }
        engine?.resetHandler = { [weak self] in Task { @MainActor in self?.engine = nil; self?.player = nil } }
        try? engine?.start()
        self.engine = engine
    }

    /// Plays the pattern from now: the whole one, or with Reduce Motion the hit and its tail alone (the file waits 125 ms
    /// in itself, for the room to start fading in).
    func play(reduceMotion: Bool) {
        let name = reduceMotion ? "UnlockCelebrationReduceMotion" : "UnlockCelebration"
        guard let engine, let url = Bundle.main.url(forResource: name, withExtension: "ahap"),
              let pattern = try? CHHapticPattern(contentsOf: url) else { return }
        player = try? engine.makeAdvancedPlayer(with: pattern)
        try? player?.start(atTime: CHHapticTimeImmediate)
    }

    /// Stops the pattern. With `hit`, the strong hit the pattern had not reached yet plays now instead.
    func stop(hit: Bool) {
        try? player?.stop(atTime: CHHapticTimeImmediate)
        player = nil
        guard hit, let engine else { return }
        let strike = CHHapticEvent(eventType: .hapticTransient, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1), CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.75)], relativeTime: 0)
        let tail = CHHapticEvent(eventType: .hapticContinuous, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5), CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)],
            relativeTime: 0, duration: 0.4)
        let fade = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [
            .init(relativeTime: 0, value: 1), .init(relativeTime: 0.4, value: 0)], relativeTime: 0)
        if let pattern = try? CHHapticPattern(events: [strike, tail], parameterCurves: [fade]) {
            try? engine.makePlayer(with: pattern).start(atTime: CHHapticTimeImmediate)
        }
    }
}
#endif
