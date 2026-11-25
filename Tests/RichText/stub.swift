// Stands in for the app model so RichText.swift compiles alone.
import Foundation
enum CutlingKind { case text, image }
struct Cutling { var value: String; var format: TextFormat?; var kind: CutlingKind = .text }
import SwiftUI
/// The fill-in pills' stand-in: no tokens, so previews are plain styled text.
enum FillInPills {
    enum Piece { case text(String), token(String) }
    static func split(_ value: String) -> [Piece] { [.text(value)] }
    static func inline(_ token: String, size: CGFloat, dark: Bool? = nil) -> Text { Text(token) }
}
