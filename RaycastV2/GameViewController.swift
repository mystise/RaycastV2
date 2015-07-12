//
//  GameViewController.swift
//  RaycastV2
//
//  Created by Adalynn Dudney on 7/10/15.
//  Copyright © 2015 Adalynn Dudney. All rights reserved.
//

import UIKit
import Metal
import MetalKit

let ConstantBufferSize = 128

let vertexData:[Float] =
[
    -1.0, -1.0, 0.0, 1.0,
    -1.0,  1.0, 0.0, 1.0,
    1.0, -1.0, 0.0, 1.0,
    
    -1.0,  1.0, 0.0, 1.0,
    1.0,  1.0, 0.0, 1.0,
    1.0, -1.0, 0.0, 1.0,
]

class GameViewController:UIViewController, MTKViewDelegate {
    let device: MTLDevice = MTLCreateSystemDefaultDevice()!
    
    var size: CGSize = CGSizeZero
    var renderPassDescriptor: MTLRenderPassDescriptor! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    var bgPipelineState: MTLRenderPipelineState! = nil
    var fgPipelineState: MTLRenderPipelineState! = nil
    var rayPipelineState: MTLComputePipelineState! = nil
    var vertexBuffer: MTLBuffer! = nil
    
    var computeTexOut: MTLTexture! = nil
    var computeSize: MTLSize = MTLSizeMake(64, 1, 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view as! MTKView
        view.delegate = self
        
        loadAssets()
    }
    
    func loadAssets() {
        //Initialize players
        //Initialize level (Rasterize to image)
        
        let view = self.view as! MTKView
        
        view.sampleCount = 1
        let metalLayer = view.layer as! CAMetalLayer
        metalLayer.framebufferOnly = false
        
        self.commandQueue = device.newCommandQueue()
        self.commandQueue.label = "main command queue"
        
        let defaultLibrary = self.device.newDefaultLibrary()!
        let bgFragmentProgram = defaultLibrary.newFunctionWithName("bgFragment")!
        let fgFragmentProgram = defaultLibrary.newFunctionWithName("fgFragment")!
        let vertexProgram = defaultLibrary.newFunctionWithName("vertexTransform")!
        
        let bgPipelineStateDescriptor = MTLRenderPipelineDescriptor()
        bgPipelineStateDescriptor.vertexFunction = vertexProgram
        bgPipelineStateDescriptor.fragmentFunction = bgFragmentProgram
        bgPipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        bgPipelineStateDescriptor.sampleCount = view.sampleCount
        
        do {
            try self.bgPipelineState = self.device.newRenderPipelineStateWithDescriptor(bgPipelineStateDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error \(error)")
        }
        
        let fgPipelineStateDescriptor = MTLRenderPipelineDescriptor()
        fgPipelineStateDescriptor.vertexFunction = vertexProgram
        fgPipelineStateDescriptor.fragmentFunction = fgFragmentProgram
        fgPipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        fgPipelineStateDescriptor.sampleCount = view.sampleCount
        
        do {
            try self.bgPipelineState = self.device.newRenderPipelineStateWithDescriptor(fgPipelineStateDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error \(error)")
        }
        
        do {
            try self.rayPipelineState = self.device.newComputePipelineStateWithFunction(defaultLibrary.newFunctionWithName("raycast")!)
        } catch let error {
            print("Failed to create ray pipeline state, error \(error)")
        }
        
        self.vertexBuffer = self.device.newBufferWithLength(ConstantBufferSize, options: [])
        self.vertexBuffer.label = "vertices"
        
        self.renderPassDescriptor = MTLRenderPassDescriptor()
        let bgAttach = self.renderPassDescriptor.colorAttachments[0] as MTLRenderPassColorAttachmentDescriptor
        bgAttach.loadAction = .DontCare
        
        let pData = vertexBuffer.contents()
        let vData = UnsafeMutablePointer<Float>(pData)
        
        vData.initializeFrom(vertexData)
    }
    
    func update() {
        //Move player, move enemies, do collision detection
        
        //Create list of all enemies and place in billboard buffer, also place all other billboards
    }
    
    func drawInView(view: MTKView) {
        self.update()
        
        let commandBuffer = commandQueue.commandBuffer()
        commandBuffer.label = "Frame command buffer"
        
        let drawable = view.currentDrawable!
        let bgAttach = self.renderPassDescriptor.colorAttachments[0] as MTLRenderPassColorAttachmentDescriptor
        bgAttach.texture = drawable.texture
        
        let bgRenderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(self.renderPassDescriptor)
        bgRenderEncoder.label = "Screen clear"
        
        bgRenderEncoder.setRenderPipelineState(self.bgPipelineState)
        bgRenderEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, atIndex: 0)
        bgRenderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)
        
        bgRenderEncoder.endEncoding()
        
        let computeEncoder = commandBuffer.computeCommandEncoder()
        computeEncoder.label = "Compute"
        let computeTotal: MTLSize = MTLSizeMake(Int(self.size.width), 1, 1)
        computeEncoder.setComputePipelineState(self.rayPipelineState)
        //computeEncoder.setBuffer(<#T##buffer: MTLBuffer?##MTLBuffer?#>, offset: <#T##Int#>, atIndex: <#T##Int#>)
        computeEncoder.setTexture(self.computeTexOut, atIndex: 3)
        
        computeEncoder.dispatchThreadgroups(computeTotal, threadsPerThreadgroup: self.computeSize)
        computeEncoder.endEncoding()
        
        bgRenderEncoder.label = "Composite"
        
        bgRenderEncoder.setRenderPipelineState(self.fgPipelineState)
        bgRenderEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, atIndex: 0)
        bgRenderEncoder.setFragmentTexture(self.computeTexOut, atIndex: 0)
        bgRenderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)
        
        bgRenderEncoder.endEncoding()
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }
    
    
    func view(view: MTKView, willLayoutWithSize size: CGSize) {
        self.size = size
    }
}
