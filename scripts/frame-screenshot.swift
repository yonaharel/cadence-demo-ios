// Frames a raw simulator screenshot for the App Store: a gradient background, a headline and the screen in a device outline.
// Usage: swift scripts/frame-screenshot.swift <raw.png> <out.jpg> <headline> <subtitle>
// The output is the same pixel size as the input, so it matches the device's required App Store size.
import AppKit
import CoreText

let args = CommandLine.arguments
guard args.count == 5,
    let source = NSImage(contentsOfFile: args[1])?.cgImage(forProposedRect: nil, context: nil, hints: nil)
else {
    FileHandle.standardError.write("usage: frame-screenshot.swift <raw.png> <out.jpg> <headline> <subtitle>\n".data(using: .utf8)!)
    exit(1)
}
let (headline, subtitle) = (args[3], args[4])
let width = CGFloat(source.width), height = CGFloat(source.height)
let unit = width / 1320  // everything is laid out for 6.9" and scaled for other sizes

let space = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(
    data: nil, width: source.width, height: source.height, bitsPerComponent: 8, bytesPerRow: 0, space: space,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(
        srgbRed: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255,
        alpha: alpha)
}

// Background: deep blue to the app's accent blue, with a soft green glow (the in-tune colour) behind the device.
let background = CGGradient(colorsSpace: space, colors: [color(0x0B1A3A), color(0x0A4FD6)] as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(background, start: CGPoint(x: 0, y: height), end: CGPoint(x: width, y: 0), options: [])
let glow = CGGradient(colorsSpace: space, colors: [color(0x34C759, 0.35), color(0x34C759, 0)] as CFArray, locations: [0, 1])!
ctx.drawRadialGradient(
    glow, startCenter: CGPoint(x: width / 2, y: height * 0.42), startRadius: 0,
    endCenter: CGPoint(x: width / 2, y: height * 0.42), endRadius: width * 0.75, options: [])

// Text, centred, top-down (CoreGraphics' origin is bottom-left).
func drawText(_ text: String, size: CGFloat, weight: NSFont.Weight, color textColor: CGColor, top: CGFloat) -> CGFloat {
    let font = NSFont.systemFont(ofSize: size * unit, weight: weight)
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    paragraph.lineHeightMultiple = 0.95
    let string = NSAttributedString(
        string: text,
        attributes: [.font: font, .foregroundColor: NSColor(cgColor: textColor)!, .paragraphStyle: paragraph])
    let framesetter = CTFramesetterCreateWithAttributedString(string)
    let box = CGSize(width: width - 160 * unit, height: .greatestFiniteMagnitude)
    let fit = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(), nil, box, nil)
    let rect = CGRect(x: 80 * unit, y: height - top - fit.height, width: box.width, height: ceil(fit.height))
    CTFrameDraw(CTFramesetterCreateFrame(framesetter, CFRange(), CGPath(rect: rect, transform: nil), nil), ctx)
    return top + fit.height
}
let headlineBottom = drawText(headline, size: 112, weight: .bold, color: color(0xFFFFFF), top: 190 * unit)
_ = drawText(subtitle, size: 50, weight: .medium, color: color(0xFFFFFF, 0.75), top: headlineBottom + 28 * unit)

// The device: the screen scaled down inside a dark bezel, with a drop shadow.
let scale: CGFloat = 0.8
let bezel = 22 * unit
let screen = CGSize(width: width * scale, height: height * scale)
let screenRect = CGRect(x: (width - screen.width) / 2, y: 0, width: screen.width, height: screen.height)
    .offsetBy(dx: 0, dy: -screen.height * 0.1)  // bleed off the bottom a little
let bodyRect = screenRect.insetBy(dx: -bezel, dy: -bezel)
let screenRadius = 190 * unit * scale
let bodyPath = CGPath(
    roundedRect: bodyRect, cornerWidth: screenRadius + bezel, cornerHeight: screenRadius + bezel, transform: nil)

ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -30 * unit), blur: 90 * unit, color: color(0x000000, 0.5))
ctx.addPath(bodyPath)
ctx.setFillColor(color(0x1C1C1E))
ctx.fillPath()
ctx.restoreGState()
// A thin metallic edge.
ctx.addPath(bodyPath)
ctx.setStrokeColor(color(0x8E8E93, 0.8))
ctx.setLineWidth(4 * unit)
ctx.strokePath()

ctx.saveGState()
ctx.addPath(CGPath(roundedRect: screenRect, cornerWidth: screenRadius, cornerHeight: screenRadius, transform: nil))
ctx.clip()
ctx.interpolationQuality = .high
ctx.draw(source, in: screenRect)
ctx.restoreGState()

let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
guard let jpeg = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.92]) else { exit(1) }
try jpeg.write(to: URL(fileURLWithPath: args[2]))
