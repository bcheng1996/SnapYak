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
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    @IBOutlet weak var uploadButtonOutlet: UIButton!
    @IBOutlet weak var imageOutlet: UIImageView!
    
    // Saves View as Image to user's document, will need to change to Firebase Cloud Storage
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageOutlet.isUserInteractionEnabled = true;
        let tap = UITapGestureRecognizer(target: self, action: #selector(wasTapped))
        self.imageOutlet.addGestureRecognizer(tap)
        storage = Storage.storage()
        db = Database()
       locManager.delegate = self
       
    }
    
    @objc func wasTapped(sender: UITapGestureRecognizer) {
        print("tapped")
        let someFrame = CGRect(x: sender.location(in: self.view).x, y: sender.location(in: self.view).y, width: 100.0, height: 30.0)
        
        let textField = UITextField(frame: someFrame)
        textField.placeholder = "placeholderText"
        self.imageOutlet.addSubview(textField)
        textField.becomeFirstResponder()
        textField.delegate = self
    }
 
    
    @IBAction func uploadAction(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
        
    }
    
    private func generateUniqueFilename (myFileName: String) -> String {
        
        let guid = ProcessInfo.processInfo.globallyUniqueString
        let uniqueFileName = ("\(myFileName)_\(guid)")
        
        print("uniqueFileName: \(uniqueFileName)")
        
        return uniqueFileName
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

// Delegate for UIImagePicker
extension MessageUploadViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        // print out the image size as a test
        imageOutlet.image = image
    }
}

// Delegate for UITextField
extension MessageUploadViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

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

