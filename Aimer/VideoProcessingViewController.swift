//
//  VideoProcessingViewController.swift
//  Venus
//
//  Created by Theresa on 2017/11/28.
//  Copyright © 2017年 Carolar. All rights reserved.
//

import UIKit
import MetalKit
import MetalPerformanceShaders

class VideoProcessingViewController: UIViewController {

    @IBOutlet weak var mtkView: MTKView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    let dict: [String : [SACRenderPipelineStateType]] = [
        "None" : [],
        "Grayscale" : [.grayscale],
        "Gradient" : [.gradient],
        "gamma2.0" : [.gamma]
    ]
    
    let settings = ["None", "Grayscale", "Gradient", "gamma2.0"]
    var filters = [SACRenderPipelineStateType]()
    
    let device = SACMetalCenter.shared.device
    var commandQueue = SACMetalCenter.shared.commandQueue
    var sourceTexture: MTLTexture?
    
    lazy var videoProvider: VideoProvider? = {
        return VideoProvider(device: self.device, delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetal()
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoProvider?.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoProvider?.stopRunning()
    }

    private func setupMetal() {
        SACMetalCenter.shared.renderingSize = CGSize(width: 1080.0, height: 1920.0)
        mtkView.depthStencilPixelFormat = .invalid
        mtkView.framebufferOnly = false
        mtkView.isPaused = true
        mtkView.delegate = self
        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm
    }
}

extension VideoProcessingViewController: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        SACMetalCenter.shared.filters = filters
        SACMetalCenter.shared.render(sourceTexture: sourceTexture!, renderView: mtkView)
    }
}

extension VideoProcessingViewController: VideoProviderDelegate {
    
    func videoProvider(_: VideoProvider, didProvideTexture texture: MTLTexture) {
        sourceTexture = texture
        mtkView.draw()
    }
    
}

extension VideoProcessingViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        filters = dict[settings[row]]!
    }
}

extension VideoProcessingViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return settings.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return settings[row]
    }
}
