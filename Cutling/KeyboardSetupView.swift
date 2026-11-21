//
//  KeyboardSetupView.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//
//  The setup guide, opened on first launch, from the keyboard manager and by the App Store
//  screenshot run. Since 2026-11-21 it is the remade guide in SetupFlows.swift (SetupGuide):
//  Welcome, Add the Keyboard with the real Settings video, Try It, then What You Can Do,
//  Sync Across Devices and You're All Set, all on one page layout (ASG105). The name stays so
//  every caller opens the same guide.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI

#if !os(macOS)
struct KeyboardSetupView: View {
    var body: some View { SetupGuide() }
}

#Preview {
    KeyboardSetupView()
        .environmentObject(CutlingStore.shared)
}
#endif
