// Stands in for the app model so RichText.swift compiles alone.
import Foundation
enum CutlingKind { case text, image }
struct Cutling { var value: String; var format: TextFormat?; var kind: CutlingKind = .text }
