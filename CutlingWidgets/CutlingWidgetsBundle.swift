//
//  CutlingWidgetsBundle.swift
//  CutlingWidgets
//
//  Created by Kenneth Johannes Fang on 04/05/26.
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct CutlingWidgetsBundle: WidgetBundle {
    /// Control Center controls arrived in iOS 18; on iOS 17 the extension offers none.
    var body: some Widget {
        if #available(iOS 18.0, *) {
            AddFromClipboardControl()
            NewTextCutlingControl()
            NewImageCutlingControl()
        }
    }
}
