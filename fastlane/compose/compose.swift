// compose.swift — App Store frame: background, two caption lines, device.
//
// Replaces frameit's text step: frameit draws text with ImageMagick, which
// here has no shaping engine, so Arabic, Indic and Thai captions came out
// broken. CoreText shapes every script and lays out right-to-left text.
//
// Usage: compose <jobs.json>
//   [{"input","output","device":"iphone|ipad|mac","title","subtitle","lang","dark"}]

import AppKit
import CoreText
import Foundation

struct Job: Decodable {
    let input: String
    let output: String
    let device: String
    let title: String
    let subtitle: String
    let lang: String
}

let background = CGColor(red: 26 / 255.0, green: 138 / 255.0, blue: 114 / 255.0, alpha: 1)
let iphoneFrame = NSString(string: "~/.fastlane/frameit/latest/Apple iPhone 14 Pro Max Black.png")
    .expandingTildeInPath

func canvasSize(_ device: String) -> CGSize {
    switch device {
    case "iphone": return CGSize(width: 1290, height: 2796)
    case "ipad": return CGSize(width: 2048, height: 2732)
    default: return CGSize(width: 2880, height: 1800)
    }
}

func cgImage(_ path: String) -> CGImage? {
    guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil) else { return nil }
    return CGImageSourceCreateImageAtIndex(src, 0, nil)
}

/// Bold system font; CoreText's cascade supplies each script's own face.
func attributed(_ text: String, size: CGFloat, lang: String, alpha: CGFloat) -> NSAttributedString {
    let para = NSMutableParagraphStyle()
    para.alignment = .center
    para.baseWritingDirection = .natural
    para.lineBreakMode = .byWordWrapping
    para.lineHeightMultiple = 1.05
    var font = NSFont.systemFont(ofSize: size, weight: .bold)
    // Pick the regional CJK face (PingFang TC vs SC, Hiragino for ja)
    let cascade: [String: String] = ["zh-Hant": "PingFangTC-Semibold", "zh-Hans": "PingFangSC-Semibold",
                                     "ja": "HiraginoSans-W7", "ko": "AppleSDGothicNeo-Bold"]
    if let name = cascade[lang], let cjk = NSFont(name: name, size: size) { font = cjk }
    return NSAttributedString(string: text, attributes: [
        .font: font,
        .foregroundColor: NSColor(white: 1, alpha: alpha),
        .paragraphStyle: para,
        NSAttributedString.Key(kCTLanguageAttributeName as String): lang,
    ])
}

/// Lines `text` needs at `size` within `width`.
func lineCount(_ text: String, size: CGFloat, width: CGFloat, lang: String) -> Int {
    let setter = CTFramesetterCreateWithAttributedString(attributed(text, size: size, lang: lang, alpha: 1))
    let path = CGPath(rect: CGRect(x: 0, y: 0, width: width, height: 10_000), transform: nil)
    return (CTFrameGetLines(CTFramesetterCreateFrame(setter, CFRange(), path, nil)) as! [CTLine]).count
}

/// Draws text centred in a box. One line if it fits at 80% size or more
/// (CJK otherwise breaks mid-word), else up to maxLines, shrinking to fit.
@discardableResult
func drawText(_ text: String, in ctx: CGContext, top: CGFloat, width: CGFloat, canvas: CGSize,
              size: CGFloat, maxLines: Int, lang: String, alpha: CGFloat) -> CGFloat {
    guard !text.isEmpty else { return top }
    var fontSize = size
    var maxLines = maxLines
    var probe = size
    while probe >= size * 0.8 {
        if lineCount(text, size: probe, width: width, lang: lang) == 1 { fontSize = probe; maxLines = 1; break }
        probe -= 2
    }
    while true {
        let str = attributed(text, size: fontSize, lang: lang, alpha: alpha)
        let setter = CTFramesetterCreateWithAttributedString(str)
        let fit = CTFramesetterSuggestFrameSizeWithConstraints(
            setter, CFRange(), nil, CGSize(width: width, height: .greatestFiniteMagnitude), nil)
        let path = CGPath(rect: CGRect(x: 0, y: 0, width: width, height: fit.height + 4), transform: nil)
        let frame = CTFramesetterCreateFrame(setter, CFRange(), path, nil)
        let lines = (CTFrameGetLines(frame) as! [CTLine]).count
        if lines <= maxLines || fontSize < size * 0.6 {
            let originX = (canvas.width - width) / 2
            let originY = canvas.height - top - fit.height - 4
            ctx.saveGState()
            ctx.translateBy(x: originX, y: originY)
            CTFrameDraw(frame, ctx)
            ctx.restoreGState()
            return top + fit.height
        }
        fontSize -= 2
    }
}

func render(_ job: Job) throws {
    let size = canvasSize(job.device)
    let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8,
                        bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.setFillColor(background)
    ctx.fill(CGRect(origin: .zero, size: size))

    let scale = size.width / 1290
    let isMac = job.device == "mac"
    let textWidth = size.width - (isMac ? 520 : 150 * scale)
    let titleSize: CGFloat = isMac ? 104 : 92 * scale
    let subSize: CGFloat = isMac ? 60 : 56 * scale
    var y: CGFloat = isMac ? 110 : 150 * scale
    y = drawText(job.title, in: ctx, top: y, width: textWidth, canvas: size,
                 size: titleSize, maxLines: 2, lang: job.lang, alpha: 1)
    y += isMac ? 24 : 26 * scale
    y = drawText(job.subtitle, in: ctx, top: y, width: textWidth, canvas: size,
                 size: subSize, maxLines: 2, lang: job.lang, alpha: 0.88)
    y += isMac ? 80 : 90 * scale

    guard let shot = cgImage(job.input) else { throw NSError(domain: "compose", code: 1) }

    if job.device == "iphone", let frame = cgImage(iphoneFrame) {
        // Real bezel from frameit's cache; screen sits at +67+55
        let deviceWidth = size.width * 0.86
        let k = deviceWidth / CGFloat(frame.width)
        let rect = CGRect(x: (size.width - deviceWidth) / 2,
                          y: size.height - y - CGFloat(frame.height) * k,
                          width: deviceWidth, height: CGFloat(frame.height) * k)
        let screen = CGRect(x: rect.minX + 67 * k, y: rect.maxY - (55 + CGFloat(shot.height)) * k,
                            width: CGFloat(shot.width) * k, height: CGFloat(shot.height) * k)
        ctx.saveGState()
        ctx.addPath(CGPath(roundedRect: screen, cornerWidth: 70 * k, cornerHeight: 70 * k, transform: nil))
        ctx.clip()
        ctx.draw(shot, in: screen)
        ctx.restoreGState()
        ctx.draw(frame, in: rect)
    } else {
        // iPad and Mac: rounded screen with a dark bezel and soft shadow
        let maxW = size.width * (isMac ? 0.80 : 0.86)
        let maxH = isMac ? size.height - y - 60 : CGFloat.greatestFiniteMagnitude
        let k = min(maxW / CGFloat(shot.width), maxH / CGFloat(shot.height))
        let w = CGFloat(shot.width) * k, h = CGFloat(shot.height) * k
        let rect = CGRect(x: (size.width - w) / 2, y: size.height - y - h, width: w, height: h)
        let bezel = isMac ? 0 : 28 * scale
        let radius: CGFloat = isMac ? 22 : 56 * scale
        let outer = rect.insetBy(dx: -bezel, dy: -bezel)
        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: -20), blur: 60,
                      color: CGColor(gray: 0, alpha: 0.35))
        ctx.setFillColor(CGColor(gray: isMac ? 1 : 0.08, alpha: 1))
        ctx.addPath(CGPath(roundedRect: outer, cornerWidth: radius + bezel, cornerHeight: radius + bezel,
                           transform: nil))
        ctx.fillPath()
        ctx.restoreGState()
        ctx.saveGState()
        ctx.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
        ctx.clip()
        ctx.draw(shot, in: rect)
        ctx.restoreGState()
    }

    let out = ctx.makeImage()!
    let url = URL(fileURLWithPath: job.output)
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil)!
    // App Store rejects alpha; the canvas is opaque so drop the channel
    CGImageDestinationAddImage(dest, out, [kCGImagePropertyHasAlpha: false] as CFDictionary)
    CGImageDestinationFinalize(dest)
}

let jobs = try JSONDecoder().decode([Job].self, from: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1])))
var failures = 0
for job in jobs {
    do { try render(job) } catch { failures += 1; FileHandle.standardError.write("FAIL \(job.output)\n".data(using: .utf8)!) }
}
print("rendered \(jobs.count - failures)/\(jobs.count)")
