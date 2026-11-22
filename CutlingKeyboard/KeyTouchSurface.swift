//
//  KeyTouchSurface.swift
//  CutlingKeyboard
//
//  A key's touch read straight from UIKit, for the keys drawn in SwiftUI (space, delete, return, the clipboard bar).
//  On iOS 27 a SwiftUI DragGesture(minimumDistance: 0) holds its first update while the system might still claim
//  the touch: filmed on the iOS 27.2 simulator, the bottom row lit 130 to 580 ms after touch-down, delete's first
//  character went before its key lit, and a quick tap never lit a key at all, where Apple's keys light on the frame
//  the finger lands (ASG159). azooKey met the same and moved its keys to a UIKit recognizer on a plain UIView
//  (MIT; github.com/azooKey/azooKey, AzooKeyCore/Sources/KeyboardViews/View/UnifiedKey/KeyPressGesture.swift at
//  f81200605139, pull requests 765 and 766, measured 754 ms before and 4 to 9 ms after).
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI
import UIKit

/// A transparent view over a key that reports its touch as it happens: down, each move (the offset from where the
/// finger landed, in points) and up, or cancelled when the system or a scroll view takes the touch.
struct KeyTouchSurface: UIViewRepresentable {
    var onDown: () -> Void
    var onMove: (CGSize) -> Void
    var onUp: (CGSize) -> Void
    var onCancel: () -> Void

    func makeUIView(context: Context) -> Surface {
        let view = Surface()
        updateUIView(view, context: context)
        return view
    }

    func updateUIView(_ view: Surface, context: Context) {
        view.recognizer.onDown = onDown
        view.recognizer.onMove = onMove
        view.recognizer.onUp = onUp
        view.recognizer.onCancel = onCancel
    }

    static func dismantleUIView(_ view: Surface, coordinator: ()) {
        view.recognizer.cancelTracking()
        view.recognizer.isEnabled = false
    }

    final class Surface: UIView {
        let recognizer = Recognizer()

        init() {
            super.init(frame: .zero)
            backgroundColor = .clear
            isOpaque = false
            // Watches the touch without holding it back or taking it from anything else.
            recognizer.cancelsTouchesInView = false
            recognizer.delaysTouchesBegan = false
            recognizer.delaysTouchesEnded = false
            addGestureRecognizer(recognizer)
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }

    /// Follows the first finger on the key; later fingers on the same key are left alone, as on Apple's keys.
    final class Recognizer: UIGestureRecognizer {
        var onDown: (() -> Void)?
        var onMove: ((CGSize) -> Void)?
        var onUp: ((CGSize) -> Void)?
        var onCancel: (() -> Void)?
        private var tracked: UITouch?
        private var start: CGPoint = .zero

        override func canPrevent(_ other: UIGestureRecognizer) -> Bool { false }
        override func canBePrevented(by other: UIGestureRecognizer) -> Bool { false }

        private func offset(of touch: UITouch) -> CGSize {
            let point = touch.location(in: view)
            return CGSize(width: point.x - start.x, height: point.y - start.y)
        }

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
            guard tracked == nil, let touch = touches.first else { return }
            tracked = touch
            start = touch.location(in: view)
            onDown?()
            state = .began
        }

        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
            guard let touch = tracked, touches.contains(touch) else { return }
            onMove?(offset(of: touch))
            state = .changed
        }

        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
            guard let touch = tracked, touches.contains(touch) else { return }
            tracked = nil
            onUp?(offset(of: touch))
            state = .ended
        }

        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
            guard let touch = tracked, touches.contains(touch) else { return }
            cancelTracking()
            state = .cancelled
        }

        override func reset() {
            cancelTracking()
            super.reset()
        }

        /// Ends a touch that will not finish as a press.
        func cancelTracking() {
            guard tracked != nil else { return }
            tracked = nil
            onCancel?()
        }
    }
}
