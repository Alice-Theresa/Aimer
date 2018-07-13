//
//  SACMetalCenter.swift
//  Venus
//
//  Created by Theresa on 2018/7/9.
//  Copyright © 2018年 Carolar. All rights reserved.
//

import Metal
import MetalKit
import Foundation
import UIKit

class SACMetalCenter {
    
    static let shared = SACMetalCenter()
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    
    var firstTexture: MTLTexture!
    var secondTexture: MTLTexture!
    
    var currentFilter: Filter = Filter.setting.first!
    
    var passParam: Float?
    
    var renderingSize: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            let sampleDesc = MTLTextureDescriptor()
            sampleDesc.width = Int(renderingSize.width)
            sampleDesc.height = Int(renderingSize.height)
            sampleDesc.pixelFormat = .bgra8Unorm
            sampleDesc.usage = .renderTarget
            firstTexture = device.makeTexture(descriptor: sampleDesc)
            secondTexture = device.makeTexture(descriptor: sampleDesc)
        }
    }
    
    private init() {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
    }
    
    func render(sourceTexture: MTLTexture, renderView: MTKView) {
        check()
        
        for (index, filter) in currentFilter.filters.enumerated() {
            
            var inputTexture, targetTexture: MTLTexture
            if index == 0 {
                inputTexture = sourceTexture
                targetTexture = firstTexture
            } else if index % 2 == 0 {
                inputTexture = secondTexture
                targetTexture = firstTexture
            } else {
                inputTexture = firstTexture
                targetTexture = secondTexture
            }
            
            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].texture = targetTexture
            
            guard let buffer = commandQueue.makeCommandBuffer(),
                let encoder = buffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
                else { return }
            
            let state = SACRenderPipelineState.fetch(type: filter)
            
            let size: [Float] = [Float(renderingSize.width), Float(renderingSize.height)]
            let sizeBuffer = device.makeBuffer(bytes: size, length: size.count * MemoryLayout.size(ofValue: size[0]), options: [])
            
            encoder.setRenderPipelineState(state)
            encoder.setVertexBuffer(sizeBuffer, offset: 0, index: 0)
            
            if let param = passParam {
                let paramBuffer = device.makeBuffer(bytes: [param], length: MemoryLayout.size(ofValue: param), options: [])
                encoder.setFragmentBuffer(paramBuffer, offset: 0, index: 0)
            }
            
            encoder.setFragmentTexture(inputTexture, index: 0)
            encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
            encoder.endEncoding()
            
            buffer.commit()
            buffer.waitUntilCompleted()
        }
        
        guard let currentRenderPassDescriptor = renderView.currentRenderPassDescriptor,
            let currentDrawable = renderView.currentDrawable,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)
            else { return }
        
        let state = SACRenderPipelineState.fetch(type: .mapping)
        encoder.setRenderPipelineState(state)
        var texture: MTLTexture
        if currentFilter.filters.count == 0 {
            texture = sourceTexture
        } else if currentFilter.filters.count % 2 == 0 {
            texture = secondTexture
        } else {
            texture = firstTexture
        }
        encoder.setFragmentTexture(texture, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
        encoder.endEncoding()
        
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
    func check() {
        if renderingSize.width == 0 || renderingSize.height == 0 {
            fatalError("you should set rendering size first")
        }
    }
}
