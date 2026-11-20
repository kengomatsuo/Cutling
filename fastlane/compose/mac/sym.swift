import AppKit
let cfg = NSImage.SymbolConfiguration(pointSize: 64, weight: .medium)
let img = NSImage(systemSymbolName: CommandLine.arguments[1], accessibilityDescription: nil)!.withSymbolConfiguration(cfg)!
let size = img.size
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width*2), pixelsHigh: Int(size.height*2), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
rep.size = size
NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let tinted = NSImage(size: size, flipped: false) { r in img.draw(in: r); NSColor.white.set(); r.fill(using: .sourceAtop); return true }
tinted.draw(in: NSRect(origin: .zero, size: size))
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[2]))
