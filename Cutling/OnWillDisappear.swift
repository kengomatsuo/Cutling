//
//  OnWillDisappear.swift
//  Cutling
//
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//


#if os(iOS)
import SwiftUI
import UIKit

/// A SwiftUI modifier that fires a callback when the hosting view controller's
/// `viewWillDisappear` is called — i.e. at the *start* of a navigation transition,
/// not after the animation completes (which is when SwiftUI's `.onDisappear` fires).
private struct WillDisappearViewController: UIViewControllerRepresentable {
    let onWillDisappear: () -> Void

    func makeUIViewController(context: Context) -> WillDisappearUIViewController {
        WillDisappearUIViewController(onWillDisappear: onWillDisappear)
    }

    func updateUIViewController(_ uiViewController: WillDisappearUIViewController, context: Context) {
        uiViewController.onWillDisappear = onWillDisappear
    }

    class WillDisappearUIViewController: UIViewController {
        var onWillDisappear: () -> Void

        init(onWillDisappear: @escaping () -> Void) {
            self.onWillDisappear = onWillDisappear
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError() }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onWillDisappear()
        }
    }
}

extension View {
    /// Calls the given closure when the view's hosting view controller is about to disappear
    /// (at the start of the transition, not after the animation).
    func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
        background(WillDisappearViewController(onWillDisappear: perform))
    }
}
#endif
