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
    
    override func viewWillAppear(_ animated: Bool) {
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = true
        }
    }
    
    // Goes back to list view
    @IBAction func toListViewAction(_ sender: Any) {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 0
            tabBarController.tabBar.isHidden = false
        }
    }
    @IBAction func toMapViewAction(_ sender: Any) {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 2
            tabBarController.tabBar.isHidden = false
        }
    }
    @IBAction func switchCameraAction(_ sender: Any) {
        do {
            try self.cameraController.switchCameras()
        } catch  {
            print("ERROR!", error)
        }
    }
    
    @IBAction func captureButtonAction(_ sender: Any) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error)
                return
            }
            self.capturedImage = image
            let dvc = self.storyboard?.instantiateViewController(withIdentifier: "MessageUploadViewController") as! MessageUploadViewController
            dvc.capturedIamge = self.capturedImage
            let navigationVC = UINavigationController(rootViewController: dvc)
            self.present(navigationVC, animated: true, completion: nil)
            
            // self.performSegue(withIdentifier: "showMessageUploadView", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showMessageUploadView"){
            let dvc = segue.destination as! MessageUploadViewController
            dvc.capturedIamge = self.capturedImage
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let screenSize = self.view.bounds.size
        if let touchPoint = touches.first {
            let x = touchPoint.location(in: self.view).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: self.view).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
     

            if let device = cameraController.rearCamera {
                do {
                    try device.lockForConfiguration()
                    
                    device.focusPointOfInterest = focusPoint
                    //device.focusMode = .continuousAutoFocus
                    device.focusMode = .autoFocus
                    //device.focusMode = .locked
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                }
                catch {
                    // just ignore
                }
            }
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
