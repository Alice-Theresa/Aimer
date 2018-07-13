//
//  Filters.swift
//  Aimer
//
//  Created by Theresa on 2018/7/13.
//  Copyright © 2018年 Carolar. All rights reserved.
//

import Foundation

class Filter {
    
    let name: String
    let filters: [SACRenderPipelineStateType]
    let params: [Float]
    
    init(name: String, filters: [SACRenderPipelineStateType], params: [Float]) {
        self.name = name
        self.filters = filters
        self.params = params
    }
    
    static var setting: [Filter] = [
        Filter(name: "None", filters: [], params: []),
        Filter(name: "Grayscale", filters: [.grayscale], params: []),
        Filter(name: "Gradient", filters: [.gradient], params: []),
        Filter(name: "Gamma", filters: [.gamma], params: [0.5, 1.0, 1.5, 2.0]),
        ]
}
