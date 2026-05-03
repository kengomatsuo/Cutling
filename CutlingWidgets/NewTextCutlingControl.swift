//
//  NewTextCutlingControl.swift
//  CutlingWidgets
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI
import WidgetKit

struct NewTextCutlingControl: ControlWidget {
    static let kind = "com.matsuokengo.Cutling.newTextCutling"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: OpenCutlingIntent(target: .newText)) {
                Label("New Text Cutling", systemImage: "text.badge.plus")
            }
        }
        .displayName("New Text Cutling")
        .description("Create a new text cutling.")
    }
}
