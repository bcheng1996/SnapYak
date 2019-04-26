//
//  MessageUploadViewController.swift
//  SnapYak
//
//  Created by Benny Cheng on 4/22/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit
import Photos
import CoreLocation
import Firebase

class MessageUploadViewController: UIViewController {
    
    var storage: Storage!
    var db: Database!
    
    var takenPhoto: UIImage?
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var capturedIamge: UIImage!
    var textFields: [UITextField] = []
    var previousTextFieldY: CGFloat?
    var keyboardIsVisible: Bool = false
    
    @IBOutlet weak var uploadButtonOutlet: UIButton!
    @IBOutlet weak var imageOutlet: UIImageView!
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    // Saves View as Image to user's document, will need to change to Firebase Cloud Storage
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        imageOutlet.isUserInteractionEnabled = true;
        imageOutlet.image = capturedIamge
        let tap = UITapGestureRecognizer(target: self, action: #selector(wasTapped))
        self.imageOutlet.addGestureRecognizer(tap)
        storage = Storage.storage()
        db = Database()
        locManager.delegate = self
        
        if let takenPhoto = takenPhoto {
            imageOutlet.image = takenPhoto
        }
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            locManager.requestLocation()
        }else{
            locManager.requestWhenInUseAuthorization()
        }
    }
    
    @objc func wasTapped(sender: UITapGestureRecognizer) {
        if(!keyboardIsVisible){
            let someFrame = CGRect(x: 0, y: sender.location(in: self.view).y, width: self.view.frame.width, height: 30.0)

            let textField = UITextField(frame: someFrame)
            self.imageOutlet.addSubview(textField)
            textFields.append(textField)
            previousTextFieldY = sender.location(in: self.view).y
            textField.becomeFirstResponder()
            textField.delegate = self
        }else{
            self.view.endEditing(true)
        }
    }

    private func generateUniqueFilename (myFileName: String) -> String {
        
        let guid = ProcessInfo.processInfo.globallyUniqueString
        let uniqueFileName = ("\(myFileName)_\(guid)")
        
        print("uniqueFileName: \(uniqueFileName)")
        
        return uniqueFileName
    }
    
    
    @IBAction func uploadButtonAction(_ sender: Any) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            locManager.requestLocation()
        }else{
            locManager.requestWhenInUseAuthorization()
        }
        let image = UIImage(view: self.imageOutlet)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        let fileName = generateUniqueFilename(myFileName: "image") + ".jpg"
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = image.jpegData(compressionQuality:  1.0),
            !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                let imagesRef = storage.reference().child("images")
                let imageUploadRef = imagesRef.child(fileName)
                imageUploadRef.putData(data, metadata:nil) { (metadata, error) in
                    if let error = error {
                        print("Error uploading image: \(error.localizedDescription)")
                    } else {
                        let newYak = Yak(user_id: "B1WRIde8IPTZuWoTsiBU", image_url: fileName, location: GeoPoint(latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude), time_stamp: Date())
                        self.db.uploadYak(yak: newYak)
                        
                        print("image uploaded")
                    }
                }
                print("file saved" + fileURL.absoluteString)
                
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        self.keyboardIsVisible = true
        if let info = notification.userInfo {
            let rect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            
            let targetY  = view.frame.size.height - rect.height - 40
            if let textField = self.textFields.last{
                textField.frame.origin.y = targetY
                textField.backgroundColor = #colorLiteral(red: 0.1841630342, green: 0.1981908197, blue: 0.2178189767, alpha: 0.6)
                textField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                textField.becomeFirstResponder()
                textField.delegate = self
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.keyboardIsVisible = false
        if let textField = textFields.last {
            textField.frame.origin.y = previousTextFieldY!
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showCameraView") {
        }
    }
    
}


// Delegate for UITextField
extension MessageUploadViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.invalidateIntrinsicContentSize()
        return true
    }
}

// Delegate for CoreLocations
extension MessageUploadViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find location")
    }
}

// Converts UIView to an Image
extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}

