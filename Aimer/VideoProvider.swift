//
//  VideoProvider.swift
//  Venus
//
//  Created by Theresa on 2017/11/28.
//  Copyright © 2017年 Carolar. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoProviderDelegate: class {
    
    func videoProvider(_: VideoProvider, didProvideTexture texture: MTLTexture)
    
}

class VideoProvider: NSObject {
    
    var textureCache : CVMetalTextureCache?
    let captureSession = AVCaptureSession()
    let videoProcessingQueue = DispatchQueue(label: "com.video.processing")
    weak var delegate: VideoProviderDelegate!
    
    required init?(device: MTLDevice, delegate: VideoProviderDelegate) {
        super.init()
        
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
        self.delegate = delegate
        
        if (!initializeCaptureSessionSuccess()) {
            return nil
        }
        
    }
    
    func initializeCaptureSessionSuccess() -> Bool {
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Unable to access camera.")
            return false
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
            } else {
                print("Unable to add camera input.")
                return false
            }
        } catch let error as NSError {
            print("Error accessing camera input: \(error)")
            return false
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        videoOutput.setSampleBufferDelegate(self, queue: videoProcessingQueue)
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            print("Unable to add camera onput.")
            return false
        }
        return true
    }
    
    func startRunning() {
        videoProcessingQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    func stopRunning() {
        videoProcessingQueue.async {
            self.captureSession.stopRunning()
        }
    }
    
}

extension VideoProvider: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        
        guard let cameraTextureCache = textureCache,
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        var cameraTexture: CVMetalTexture?
        let cameraTextureWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
        let cameraTextureHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                  cameraTextureCache,
                                                  pixelBuffer,
                                                  nil,
                                                  MTLPixelFormat.bgra8Unorm,
                                                  cameraTextureWidth,
                                                  cameraTextureHeight,
                                                  0,
                                                  &cameraTexture)
        if
            let cameraTexture = cameraTexture,
            let metalTexture = CVMetalTextureGetTexture(cameraTexture)
        {
            delegate.videoProvider(self, didProvideTexture: metalTexture)
        }
    }
    
}

