//
//  BrandGreen.swift
//  Cutling
//
//  Cutling's two greens. Green text (links, toolbar and text buttons, `.tint` labels) is the accent colour, which is a
//  deeper green in light mode so it reads at 4.5:1 or more on white; filled shapes (prominent buttons, chips, selection
//  dots, highlights) keep the bright brand green, set here.
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

import SwiftUI

extension Color {
    /// The bright brand green for fills; text uses the accent colour.
    static let brandGreen = Color("BrandGreen")
}

extension ShapeStyle where Self == Color {
    static var brandGreen: Color { Color.brandGreen }
}
