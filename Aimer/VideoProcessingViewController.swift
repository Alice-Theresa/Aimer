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
    @IBOutlet weak var paramsPickerView: UIPickerView!
    
    var selectedFilter = Filter.setting[0]
    
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
        paramsPickerView.delegate = self
        paramsPickerView.dataSource = self
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
        SACMetalCenter.shared.currentFilter = selectedFilter
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
        if pickerView == self.pickerView {
            selectedFilter = Filter.setting[row]
            paramsPickerView.reloadComponent(0)
            if let param = selectedFilter.params.first {
                SACMetalCenter.shared.passParam = param
            }
        } else {
            SACMetalCenter.shared.passParam = selectedFilter.params[row]
        }
    }
}

extension VideoProcessingViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerView {
            return Filter.setting.count
        } else {
            return selectedFilter.params.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.pickerView {
            return Filter.setting[row].name
        } else {
            return String(selectedFilter.params[row])
        }
    }
}
