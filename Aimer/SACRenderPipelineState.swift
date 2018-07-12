//
//  SACRenderPipelineState.swift
//  Venus
//
//  Created by Theresa on 2018/7/9.
//  Copyright © 2018年 Carolar. All rights reserved.
//

import Metal
import Foundation

enum SACRenderPipelineStateType: String {
    case mapping = "mapping"
    case grayscale = "grayscale"
    case gradient = "gradient"
    case gamma = "gamma"
}

class SACRenderPipelineState {
    
    private static let dict : [ SACRenderPipelineStateType : MTLRenderPipelineState] = [
        .mapping : SACRenderPipelineState.mappingRenderPipelineState,
        .grayscale : SACRenderPipelineState.grayscaleRenderPipelineState,
        .gradient : SACRenderPipelineState.gradientRenderPipelineState,
        .gamma : SACRenderPipelineState.gammaRenderPipelineState
    ]
    
    static func fetch(type: SACRenderPipelineStateType) -> MTLRenderPipelineState {
        return dict[type]!
    }
    
    private static func create(type: SACRenderPipelineStateType) -> MTLRenderPipelineState {
        let vertex = type.rawValue + "Vertex"
        let fragment = type.rawValue + "Fragment"
        guard let library = SACMetalCenter.shared.device.makeDefaultLibrary() else {
            fatalError("Failed creating a library.")
        }
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat      = .invalid
        pipelineDescriptor.vertexFunction                  = library.makeFunction(name: vertex)
        pipelineDescriptor.fragmentFunction                = library.makeFunction(name: fragment)
        
        do {
            return try SACMetalCenter.shared.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Failed creating a render state pipeline. Can't render the texture without one.")
        }
    }
    
    private static var mappingRenderPipelineState: MTLRenderPipelineState = {
        return SACRenderPipelineState.create(type: .mapping)
    }()
    
    private static var grayscaleRenderPipelineState: MTLRenderPipelineState = {
        return SACRenderPipelineState.create(type: .grayscale)
    }()
    
    private static var gradientRenderPipelineState: MTLRenderPipelineState = {
        return SACRenderPipelineState.create(type: .gradient)
    }()
    
    private static var gammaRenderPipelineState: MTLRenderPipelineState = {
        return SACRenderPipelineState.create(type: .gamma)
    }()
        
}
