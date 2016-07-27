//
//  ViewController.swift
//  HelloMetal
//
//  Created by Felix ITs 01 on 27/07/16.
//  Copyright © 2016 Aashish Tamsya. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class ViewController: UIViewController {

    
    var device : MTLDevice! = nil
    var metalLayer : CAMetalLayer! = nil
    var vertexBuffer : MTLBuffer! = nil
    var pipelineState : MTLRenderPipelineState! = nil
    var commanQueue : MTLCommandQueue! = nil
    
    //Rendering the triangle
    var timer : CADisplayLink! = nil
    var drawable: CAMetalDrawable {
        return (metalLayer as! CAMetalLayer).nextDrawable()!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        let vertexData : [Float] = [0.0,1.0,0.0,-1.0,-1.0,0.0,1.0,-1.0,0.0]
        
        let dataSize = vertexData.count * sizeofValue(vertexData[0])
        
        vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: .CPUCacheModeDefaultCache)
        
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentFunction = defaultLibrary?.newFunctionWithName("basic_fragment")
        let vertexFunction = defaultLibrary?.newFunctionWithName("basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        do {
            pipelineState = try device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        }
        catch {
            print("Failed to create pipeline state")
        }
        
        commanQueue = device.newCommandQueue()
        
        
            
        
        timer = CADisplayLink.init(target: self, selector: #selector(ViewController.gameloop))
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func render() {
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor.init(red: 75.0/255/0, green: 226.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        
        let commandBuffer = commanQueue.commandBuffer()
        
        let renderEncodedOptional = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        
        if let renderEncoder : MTLRenderCommandEncoder = renderEncodedOptional {
            
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
            renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
            renderEncoder.endEncoding()
        }
        
        let fps : CFTimeInterval = 30.0
        commandBuffer.presentDrawable(drawable, atTime: fps)
        commandBuffer.commit()
        
    }

    func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
    
    

}

