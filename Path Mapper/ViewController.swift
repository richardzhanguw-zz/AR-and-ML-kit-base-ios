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
    var requests = [VNRequest] ()
    var session: AVCaptureSession!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else {
            print("model is not loading")
            fatalError()
        }
        requests = [VNCoreMLRequest(model: model, completionHandler: handleRequests)]
        cameraView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraView = UIView(frame: CGRect(x: UIApplication.shared.keyWindow!.safeAreaInsets.left, y: UIApplication.shared.keyWindow!.safeAreaInsets.top, width: self.view.frame.size.width, height: self.view.frame.size.height - UIApplication.shared.keyWindow!.safeAreaInsets.top - UIApplication.shared.keyWindow!.safeAreaInsets.bottom))
        self.view.addSubview(cameraView)
        session = AVCaptureSession()
        vidPrevLayer = AVCaptureVideoPreviewLayer(session: session)
        vidPrevLayer.frame = cameraView.bounds;
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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session.stopRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        var options:[VNImageOption: Any] = [:]
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            options = [.cameraIntrinsics: cameraIntrinsicData]
        }
        let imgReqHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .upMirrored, options: options)
        do {
            try imgReqHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    func handleRequests(request: VNRequest , error: Error?) {
        if let currentError = error {
            print(currentError.localizedDescription)
            return
        }
        guard let observations = request.results else {
            print("nothing has been received from the model")
            return
        }
        let observation = observations [0] as! VNClassificationObservation
        let result = "\(observation.identifier)"
        print(result)
    }
}


