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
    var body: some Widget {
        AddFromClipboardControl()
        NewTextCutlingControl()
        NewImageCutlingControl()
    }
}
