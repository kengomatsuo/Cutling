//
//  StableDismiss.swift
//  Cutling
//
//  A dismiss action that a view can hold without its body depending on it. On iOS 17 the environment's dismiss
//  action changes each time a page the view pushed updates; a view that reads it re-runs its body, hands the page new
//  bindings, the page updates, and dismiss changes again, without end. Opening a cutling's Text page froze the app
//  that way on iOS 17.0 (TextDetailView's `_dismiss` and TextPageView's `_text` changed in turn, tens of thousands of
//  times, until memory passed 4 GB). Every view that pushes pages holds its dismiss here: a hidden reader keeps the
//  action current, and only the reader re-runs when it changes.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI

@MainActor
final class StableDismiss {
    fileprivate var action: DismissAction?

    func callAsFunction() { action?() }
}

private struct StableDismissReader: View {
    @Environment(\.dismiss) private var dismiss
    let box: StableDismiss

    var body: some View {
        box.action = dismiss
        return Color.clear.frame(width: 0, height: 0).accessibilityHidden(true)
    }
}

extension View {
    /// Keeps `box` holding the dismiss action of the place this view sits, for a view that pushes pages.
    func readsDismiss(into box: StableDismiss) -> some View {
        background(StableDismissReader(box: box))
    }
}
