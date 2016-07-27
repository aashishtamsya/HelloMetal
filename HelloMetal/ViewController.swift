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
        
        
        
        
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

