//
//  UnlockMetalSlots.swift
//  Cutling
//
//  Copyright (c) 2026 Kenneth Johannes Fang. All rights reserved.
//

#if os(iOS)
import Metal
import MetalKit
import SwiftUI

/// The unlock celebration's room drawn by the GPU: one instanced quad per slot, its rounded corners and edges worked out
/// per pixel, its scale, opacity and colour read from a table of the slot's look by age (docs/plans/unlock/celebration,
/// card ASG240, C3). A SwiftUI `Canvas` fills 5,000 shapes on the main thread, which at the end of the zoom takes longer
/// than a frame; this takes the main thread a few uniforms.
/// The shader is compiled from source when first needed, so no Metal toolchain is needed to build. If the device or the
/// compile is not there, `shared` is nil and `UnlockSlots` draws with a Canvas instead.
final class UnlockMetal {
    static let shared: UnlockMetal? = UnlockMetal()
    /// Ages in whole milliseconds the look table covers; a slot older than this is at rest.
    static let lutLast = Int(UnlockMotion.cellSettledMs)

    let device: MTLDevice
    let queue: MTLCommandQueue
    let pipeline: MTLRenderPipelineState
    let lut: MTLBuffer

    struct Uniforms {
        var view = SIMD2<Float>(0, 0)
        var pitch: Float = 0, side: Float = 0
        var radiusRatio: Float = 0, cols: Float = 0, mirror: Float = 0, t: Float = 0
        var settle: Float = 0, lutLast: Float = 0, pxPoints: Float = 1, pad: Float = 0
        var brand = SIMD4<Float>(0, 0, 0, 1)
        var rest = SIMD4<Float>(0, 0, 0, 1)
    }

    private init?() {
        guard let device = MTLCreateSystemDefaultDevice(), let queue = device.makeCommandQueue(),
              let library = try? device.makeLibrary(source: Self.source, options: nil) else { return nil }
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "slotVertex")
        descriptor.fragmentFunction = library.makeFunction(name: "slotFragment")
        let color = descriptor.colorAttachments[0]!
        color.pixelFormat = .bgra8Unorm
        color.isBlendingEnabled = true
        color.rgbBlendOperation = .add
        color.alphaBlendOperation = .add
        color.sourceRGBBlendFactor = .one
        color.sourceAlphaBlendFactor = .one
        color.destinationRGBBlendFactor = .oneMinusSourceAlpha
        color.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        guard let pipeline = try? device.makeRenderPipelineState(descriptor: descriptor) else { return nil }
        var table: [SIMD4<Float>] = []
        for ms in 0...Self.lutLast {
            let slot = UnlockMotion.Slot(age: Double(ms))
            table.append(SIMD4(Float(slot.scale), Float(slot.opacity), Float(slot.tint), 0))
        }
        guard let lut = device.makeBuffer(bytes: table, length: table.count * MemoryLayout<SIMD4<Float>>.stride, options: .storageModeShared) else { return nil }
        self.device = device; self.queue = queue; self.pipeline = pipeline; self.lut = lut
    }

    private static let source = """
    #include <metal_stdlib>
    using namespace metal;
    struct Uniforms {
        float2 view; float pitch; float side;
        float radiusRatio; float cols; float mirror; float t;
        float settle; float lutLast; float pxPoints; float pad;
        float4 brand; float4 rest;
    };
    struct Out { float4 position [[position]]; float2 local; float halfSize; float radius; float3 look; };
    vertex Out slotVertex(uint vid [[vertex_id]], uint iid [[instance_id]], constant Uniforms& u [[buffer(0)]],
                          constant float4* inst [[buffer(1)]], constant float4* lut [[buffer(2)]]) {
        float2 corner = float2((vid == 1 || vid == 4 || vid == 5) ? 1.0 : 0.0, (vid == 2 || vid == 3 || vid == 5) ? 1.0 : 0.0);
        float4 c = inst[iid];
        float age = u.t - c.z;
        float3 look;
        if (age < 0.0) { look = float3(0.25, 0.0, 0.0); }
        else if (age >= u.lutLast) { look = float3(1.0); }
        else { uint k = uint(age); look = mix(lut[k].xyz, lut[k + 1].xyz, age - float(k)); }
        look = mix(look, float3(1.0), u.settle);
        float halfSize = u.side * look.x * 0.5;
        float2 local = (corner * 2.0 - 1.0) * (halfSize + u.pxPoints);
        float2 p = float2(c.x * u.pitch, c.y * u.pitch) + u.side * 0.5 + local;
        if (u.mirror > 0.5) { p.x = u.view.x - p.x; }
        Out o;
        o.position = look.y <= 0.0 ? float4(2.0, 2.0, 0.0, 1.0) : float4(p.x / u.view.x * 2.0 - 1.0, 1.0 - p.y / u.view.y * 2.0, 0.0, 1.0);
        o.local = local; o.halfSize = halfSize; o.radius = u.side * u.radiusRatio * look.x; o.look = look;
        return o;
    }
    fragment float4 slotFragment(Out in [[stage_in]], constant Uniforms& u [[buffer(0)]]) {
        float2 q = abs(in.local) - (in.halfSize - in.radius);
        float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - in.radius;
        float coverage = clamp(0.5 - d / u.pxPoints, 0.0, 1.0);
        float a1 = in.look.y * (1.0 - in.look.z);
        float a2 = in.look.y * in.look.z * u.rest.a;
        float3 rgb = u.rest.rgb * a2 + u.brand.rgb * a1 * (1.0 - a2);
        return float4(rgb, a2 + a1 * (1.0 - a2)) * coverage;
    }
    """
}

/// Draws again after every layout, since the first update arrives before the view has a size.
private final class RoomMetalView: MTKView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
}

/// The room as a transparent Metal view the size of the room and the sheet's padding past it.
struct UnlockMetalSlots: UIViewRepresentable {
    let metal: UnlockMetal
    let room: UnlockMotion.Room
    let frame: UnlockMotion.Frame
    let at: Double
    let settle: Double
    let mirrored: Bool

    func makeCoordinator() -> Renderer { Renderer(metal: metal, room: room) }

    func makeUIView(context: Context) -> MTKView {
        let view = RoomMetalView(frame: .zero, device: metal.device)
        view.delegate = context.coordinator
        view.isPaused = true
        view.enableSetNeedsDisplay = true
        view.framebufferOnly = true
        view.colorPixelFormat = .bgra8Unorm
        view.isOpaque = false
        view.backgroundColor = .clear
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.isUserInteractionEnabled = false
        // The slots and the SwiftUI tiles beside them change in the same frame: the picture waits for the transaction.
        (view.layer as? CAMetalLayer)?.presentsWithTransaction = true
        return view
    }

    func updateUIView(_ view: MTKView, context: Context) {
        let renderer = context.coordinator
        #if DEBUG && os(iOS)
        let started = ContinuousClock.now
        defer { UnlockFrameMeter.shared.drew(ContinuousClock.now - started) }
        #endif
        var u = UnlockMetal.Uniforms()
        u.pitch = Float(frame.pitch); u.side = Float(frame.tileSize)
        u.radiusRatio = Float(UnlockSlots.radiusRatio); u.cols = Float(room.cols)
        u.mirror = mirrored ? 1 : 0; u.t = Float(at); u.settle = Float(settle)
        u.lutLast = Float(UnlockMetal.lutLast)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        UIColor(Color.brandGreen).resolvedColor(with: view.traitCollection).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        u.brand = SIMD4(Float(max(red, 0)), Float(green), Float(blue), 1)
        UIColor.systemFill.resolvedColor(with: view.traitCollection).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        u.rest = SIMD4(Float(red), Float(green), Float(blue), Float(alpha))
        renderer.uniforms = u
        renderer.instanceCount = settle > 0 ? room.order.count : max(0, room.count(at: at) - room.heroCells)
        view.setNeedsDisplay()
    }

    /// Draws the room each time SwiftUI says the instant changed.
    final class Renderer: NSObject, MTKViewDelegate {
        let metal: UnlockMetal
        let instances: MTLBuffer?
        var uniforms = UnlockMetal.Uniforms()
        var instanceCount = 0

        init(metal: UnlockMetal, room: UnlockMotion.Room) {
            self.metal = metal
            // One entry per slot in the order they appear: its column, its row and the millisecond it appears.
            let table = room.order.enumerated().map { k, index in
                SIMD4<Float>(Float(Int(index) % room.cols), Float(Int(index) / room.cols), room.orderMs[k], 0)
            }
            instances = metal.device.makeBuffer(bytes: table, length: max(table.count, 1) * MemoryLayout<SIMD4<Float>>.stride, options: .storageModeShared)
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { view.setNeedsDisplay() }

        func draw(in view: MTKView) {
            // The view's size is known once it has been laid out, which is after the first update.
            uniforms.view = SIMD2(Float(view.bounds.width), Float(view.bounds.height))
            uniforms.pxPoints = 1 / Float(max(view.contentScaleFactor, 1))
            guard uniforms.view.x > 0, let drawable = view.currentDrawable, let pass = view.currentRenderPassDescriptor,
                  let buffer = metal.queue.makeCommandBuffer(), let encoder = buffer.makeRenderCommandEncoder(descriptor: pass) else { return }
            encoder.setRenderPipelineState(metal.pipeline)
            encoder.setVertexBytes(&uniforms, length: MemoryLayout<UnlockMetal.Uniforms>.stride, index: 0)
            encoder.setVertexBuffer(instances, offset: 0, index: 1)
            encoder.setVertexBuffer(metal.lut, offset: 0, index: 2)
            encoder.setFragmentBytes(&uniforms, length: MemoryLayout<UnlockMetal.Uniforms>.stride, index: 0)
            // At least one instance, which the shader collapses until its time: the first frame, made during the beat before
            // t0, then prepares the GPU for the pipeline instead of the first slot's frame doing it.
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: max(instanceCount, 1))
            encoder.endEncoding()
            buffer.commit()
            buffer.waitUntilScheduled()
            drawable.present()
        }
    }
}
#endif
