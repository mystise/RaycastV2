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

struct Player {
    var posx: Float
    var posy: Float
    var fov: Float
    var rot: Float
    
    func getData() -> [Float] {
        return [self.posx, self.posy, self.fov, self.rot]
    }
}

class GameViewController:UIViewController, MTKViewDelegate {
    let device: MTLDevice = MTLCreateSystemDefaultDevice()!
    
    var size: CGSize = CGSizeZero
    var renderPassDescriptor: MTLRenderPassDescriptor! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    var renderPipelineState: MTLRenderPipelineState! = nil
    var rayPipelineState: MTLComputePipelineState! = nil
    var vertexBuffer: MTLBuffer! = nil
    var playerBuffer: MTLBuffer! = nil
    
    var computeTexOut: MTLTexture! = nil
    var computeSize = 64
    var player: Player = Player(posx: 1.0, posy: 1.0, fov: 80.0, rot: 0.0)
    
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
        //let metalLayer = view.layer as! CAMetalLayer
        //metalLayer.framebufferOnly = false
        
        self.commandQueue = device.newCommandQueue()
        self.commandQueue.label = "main command queue"
        
        let defaultLibrary = self.device.newDefaultLibrary()!
        let fragmentProgram = defaultLibrary.newFunctionWithName("fragmentTransform")!
        let vertexProgram = defaultLibrary.newFunctionWithName("vertexTransform")!
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineStateDescriptor.sampleCount = view.sampleCount
        
        do {
            try self.renderPipelineState = self.device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error \(error)")
        }
        
        self.vertexBuffer = self.device.newBufferWithLength(ConstantBufferSize, options: [])
        self.vertexBuffer.label = "vertices"
        
        self.renderPassDescriptor = MTLRenderPassDescriptor()
        let bgAttach = self.renderPassDescriptor.colorAttachments[0] as MTLRenderPassColorAttachmentDescriptor
        bgAttach.loadAction = .DontCare
        
        let pData = vertexBuffer.contents()
        let vData = UnsafeMutablePointer<Float>(pData)
        
        vData.initializeFrom(vertexData)
        
        let rayProgram = defaultLibrary.newFunctionWithName("raycast")!
        
        do {
            try self.rayPipelineState = self.device.newComputePipelineStateWithFunction(rayProgram)
        } catch let error {
            print("Failed to create ray pipeline state, error \(error)")
        }
        
        self.playerBuffer = self.device.newBufferWithLength(ConstantBufferSize, options: [])
        self.playerBuffer.label = "uniforms"
    }
    
    func update() {
        //Move player, move enemies, do collision detection
        
        //Create list of all enemies and place in billboard buffer, also place all other billboards
        
        let playerData = playerBuffer.contents()
        let playerMPData = UnsafeMutablePointer<Float>(playerData)
        
        playerMPData.initializeFrom(player.getData())
    }
    
    func drawInView(view: MTKView) {
        self.update()
        
        let commandBuffer = commandQueue.commandBuffer()
        commandBuffer.label = "Frame command buffer"
        
        let computeEncoder = commandBuffer.computeCommandEncoder()
        computeEncoder.label = "Compute"
        let computeTotal: MTLSize = MTLSizeMake(Int(self.size.width)/self.computeSize, 1, 1)
        computeEncoder.setComputePipelineState(self.rayPipelineState)
        //computeEncoder.setBuffer(<#T##buffer: MTLBuffer?##MTLBuffer?#>, offset: <#T##Int#>, atIndex: <#T##Int#>)
        computeEncoder.setTexture(self.computeTexOut, atIndex: 3)
        
        computeEncoder.dispatchThreadgroups(computeTotal, threadsPerThreadgroup: MTLSizeMake(self.computeSize, 1, 1))
        computeEncoder.endEncoding()
        
        if view.currentDrawable == nil {
            print("No drawable!")
            return
        }
        
        let drawable = view.currentDrawable!
        let bgAttach = self.renderPassDescriptor.colorAttachments[0] as MTLRenderPassColorAttachmentDescriptor
        bgAttach.texture = drawable.texture
        
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(self.renderPassDescriptor)
        
        renderEncoder.label = "Render to screen"
        
        renderEncoder.setRenderPipelineState(self.renderPipelineState)
        renderEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, atIndex: 0)
        renderEncoder.setFragmentTexture(self.computeTexOut, atIndex: 0)
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)
        
        renderEncoder.endEncoding()
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }
    
    
    func view(view: MTKView, willLayoutWithSize size: CGSize) {
        self.size = size
        
        let texDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.RGBA8Unorm, width: Int(self.size.width), height: Int(self.size.height), mipmapped: false)
        self.computeTexOut = self.device.newTextureWithDescriptor(texDescriptor)
    }
}
