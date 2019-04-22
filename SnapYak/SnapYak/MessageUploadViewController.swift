//
//  MessageUploadViewController.swift
//  SnapYak
//
//  Created by Brian Guevara on 4/15/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit
import Photos

class MessageUploadViewController: UIViewController {

    @IBOutlet weak var uploadButtonOutlet: UIButton!
    
    // Saves View as Image to user's document, will need to change to Firebase Cloud Storage
    @IBAction func uploadButtonAction(_ sender: Any) {
        let image = UIImage(view: self.imageOutlet)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        let fileName = "image3.jpg"
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = image.jpegData(compressionQuality:  1.0),
            !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("file saved" + fileURL.absoluteString)
                
            } catch {
                print("error saving file:", error)
            }
        }
    }
    @IBOutlet weak var imageOutlet: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageOutlet.isUserInteractionEnabled = true;
        let tap = UITapGestureRecognizer(target: self, action: #selector(wasTapped))
        self.imageOutlet.addGestureRecognizer(tap)
    
        // Do any additional setup after loading the view.
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

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

extension MessageUploadViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
