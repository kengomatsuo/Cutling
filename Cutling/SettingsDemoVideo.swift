//
//  SettingsDemoVideo.swift
//  Cutling
//
//  The setup guide's looping video of the real Settings steps (Keyboards, the Cutling switch,
//  Allow Full Access, Apple's alert), recorded on the simulator by
//  scripts/record-settings-demo.sh with a touch mark on every tap. The owner asked for the
//  real Settings page, moving, after a drawn picture looked pressable (ASG105).
//
//  The player follows fullmoon's MoonAnimationView (MIT,
//  github.com/mainframecomputer/fullmoon-ios, cbc3c82): an AVPlayerLayer with no controls,
//  an AVQueuePlayer held with its AVPlayerLooper, and an ambient audio session so a silent
//  video never stops the person's music. When Auto-Play Video Previews or Reduce Motion is
//  off it shows a still frame with a play button, as Apple asks of autoplaying video
//  (docs/research/onboarding/swiftui/pages).
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#if os(iOS)
import AVFoundation
import SwiftUI
import UIKit

struct SettingsDemoVideo: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var autoplay = UIAccessibility.isVideoAutoplayEnabled
    @State private var playing = false

    private var name: String { colorScheme == .dark ? "settings-demo-dark" : "settings-demo-light" }

    var body: some View {
        Group {
            if let url = Bundle.main.url(forResource: name, withExtension: "mp4") {
                ZStack {
                    LoopingVideoView(url: url, playing: (autoplay && !reduceMotion) || playing)
                    if !(autoplay && !reduceMotion) && !playing {
                        Button { playing = true } label: {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 54))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .black.opacity(0.55))
                        }
                        .accessibilityLabel("Play the Settings steps")
                    }
                }
                .id(name)
            }
        }
        .aspectRatio(SettingsDemoVideo.aspect, contentMode: .fit)
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Video of the Settings steps: tap Keyboards, turn on Cutling, then turn on Allow Full Access and tap Allow.")
        .onReceive(NotificationCenter.default.publisher(for: UIAccessibility.videoAutoplayStatusDidChangeNotification)) { _ in
            autoplay = UIAccessibility.isVideoAutoplayEnabled
        }
    }

    /// Width over height of the rendered videos (scripts/render-settings-demo.sh crops them).
    static let aspect: CGFloat = 0.74
}

/// A muted, looping, control-free video that plays only while `playing` is true.
private struct LoopingVideoView: UIViewRepresentable {
    let url: URL
    let playing: Bool

    func makeUIView(context: Context) -> LoopingPlayerUIView { LoopingPlayerUIView(url: url) }

    func updateUIView(_ view: LoopingPlayerUIView, context: Context) {
        playing ? view.play() : view.pause()
    }

    static func dismantleUIView(_ view: LoopingPlayerUIView, coordinator: ()) { view.pause() }
}

final class LoopingPlayerUIView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    private let player = AVQueuePlayer()
    private var looper: AVPlayerLooper?

    init(url: URL) {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        player.isMuted = true
        player.preventsDisplaySleepDuringVideoPlayback = false
        looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect
        // The video has no sound; an ambient session keeps the person's music playing.
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func play() { if player.rate == 0 { player.play() } }
    func pause() { player.pause() }
}
#endif
