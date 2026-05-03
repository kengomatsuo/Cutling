//
//  NewImageCutlingControl.swift
//  CutlingWidgets
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI
import WidgetKit

struct NewImageCutlingControl: ControlWidget {
    static let kind = "com.matsuokengo.Cutling.newImageCutling"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: OpenCutlingIntent(target: .newImage)) {
                Label("New Image Cutling", systemImage: "photo.badge.plus")
            }
        }
        .displayName("New Image Cutling")
        .description("Create a new image cutling.")
    }
}
