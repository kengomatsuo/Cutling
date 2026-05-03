//
//  AddFromClipboardControl.swift
//  CutlingWidgets
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI
import WidgetKit

struct AddFromClipboardControl: ControlWidget {
    static let kind = "com.matsuokengo.Cutling.addFromClipboard"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: AddFromClipboardIntent()) {
                Label("Add from Clipboard", systemImage: "doc.on.clipboard")
            }
        }
        .displayName("Add from Clipboard")
        .description("Save clipboard contents as a new cutling.")
    }
}
