//
//  ViewController.swift
//  Path Mapper
//
//  Created by Richard Zhang on 2018-01-08.
//  Copyright © 2018 Richard Zhang. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var vidPrevLayer:AVCaptureVideoPreviewLayer!
    var cameraView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let session = AVCaptureSession()
        session.sessionPreset = .high
        vidPrevLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraView = UIView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraView = UIView(frame: CGRect(x: UIApplication.shared.keyWindow!.safeAreaInsets.left, y: UIApplication.shared.keyWindow!.safeAreaInsets.top, width: self.view.frame.size.width, height: self.view.frame.size.height - UIApplication.shared.keyWindow!.safeAreaInsets.top - UIApplication.shared.keyWindow!.safeAreaInsets.bottom))
        self.view.addSubview(cameraView)
        let session = AVCaptureSession()
        vidPrevLayer = AVCaptureVideoPreviewLayer(session: session)
        let queue = DispatchQueue(label:"Image Queue")
        if let cam = AVCaptureDevice.default(for: .video) {
            session.sessionPreset = .medium
            cameraView.layer.addSublayer(vidPrevLayer)
            do{
                let camInput = try AVCaptureDeviceInput(device: cam)
                let vidOutput = AVCaptureVideoDataOutput()
                vidOutput.alwaysDiscardsLateVideoFrames = true
                vidOutput.setSampleBufferDelegate(self, queue: queue)
                vidOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                session.addInput(camInput)
                session.addOutput(vidOutput)
                let connection = vidOutput.connection(with: .video)
                connection?.videoOrientation = .portrait
                session.startRunning()
            } catch {
                print("Camera Error")
            }
            
        } else {
            print("ERROR: No Video Camera Found.")
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        vidPrevLayer.frame = cameraView.bounds;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }

}


