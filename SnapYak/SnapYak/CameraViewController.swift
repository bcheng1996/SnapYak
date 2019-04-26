//
//  CameraViewController.swift
//  SnapYak
//
//  Created by Benny Cheng on 4/22/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    let cameraController = CameraController()
    var capturedImage: UIImage?
    @IBOutlet weak var capturePreviewOutlet: UIView!

    
    override func viewDidLoad() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.capturePreviewOutlet)
        }
        
        // Hide tabbar item when using camera view
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = true
        }
    }
    
    
    @IBAction func captureButtonAction(_ sender: Any) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error)
                return
            }
            self.capturedImage = image
            self.performSegue(withIdentifier: "showMessageUploadView", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showMessageUploadView"){
            let dvc = segue.destination as! MessageUploadViewController
            dvc.capturedIamge = self.capturedImage
        }
        
    }
    
//    let captureSession = AVCaptureSession()
//    var previewLayer: CALayer!
//
//    var captureDevice: AVCaptureDevice!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        prepareCamera()
//        // Do any additional setup after loading the view.
//    }
//
//
//    func prepareCamera() {
//        captureSession.sessionPreset = AVCaptureSession.Preset.photo
//
//        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
//        captureDevice = availableDevices.first
//        beginSession()
//
//    }
//
//    func beginSession() {
//        do {
//            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
//
//            captureSession.addInput(captureDeviceInput)
//        }catch {
//            print(error.localizedDescription)
//        }
//
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        self.previewLayer = previewLayer
//        self.view.layer.addSublayer(self.previewLayer)
//        self.previewLayer.frame = self.view.layer.frame
//        captureSession.startRunning()
//
//        let dataOutput = AVCaptureVideoDataOutput()
//        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]
//
//        dataOutput.alwaysDiscardsLateVideoFrames = true
//        if captureSession.canAddOutput(dataOutput) {
//            captureSession.addOutput(dataOutput)
//        }
//
//        captureSession.commitConfiguration()
//
//
//        // Add captureButton
//        let captureButton = UIButton(type: .custom)
//        captureButton.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
//        captureButton.layer.cornerRadius = 0.5
//        captureButton.clipsToBounds = true
//        captureButton.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
//
//
//    }
//
//    @objc func captureImage() {
//        print("capturing image")
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
