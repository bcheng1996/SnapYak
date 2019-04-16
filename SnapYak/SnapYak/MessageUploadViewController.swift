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
    @IBAction func uploadButtonAction(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
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
        textField.backgroundColor=#colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.4980392157, alpha: 1)
        self.view.addSubview(textField)
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
    
}




