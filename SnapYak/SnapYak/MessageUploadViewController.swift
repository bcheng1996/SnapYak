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
    var currentLocation: CLLocation! {
        didSet {
            if(self.currentLocation != nil) {
                self.sendButton.isEnabled = true
                self.sendButton.setTitleColor(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), for: .normal)
            }
        }
    }
    @IBOutlet weak var drawViewOutlet: DrawView!
    @IBOutlet weak var textViewOutlet: TextView!
    var capturedIamge: UIImage!
    var textFields: [UITextField] = []
    var previousTextFieldY: CGFloat?
    var keyboardIsVisible: Bool = false
    let textColors: [UIColor] = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), #colorLiteral(red: 0.1725490196, green: 0.6156862745, blue: 0.8980392157, alpha: 1)]
    let drawColors: [UIColor] = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), #colorLiteral(red: 0.1725490196, green: 0.6156862745, blue: 0.8980392157, alpha: 1)]
    var currentTextColor: UIColor!
    var activeTextField: UITextField!
    
    @IBOutlet weak var createTextOutlet: UIButton!
    @IBOutlet weak var uploadButtonOutlet: UIButton!
    @IBOutlet weak var imageOutlet: UIImageView!
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    // Saves View as Image to user's document, will need to change to Firebase Cloud Storage
    @IBAction func createTextAcction(_ sender: Any) {
        self.drawViewOutlet.isUserInteractionEnabled = false
        self.textViewOutlet.isUserInteractionEnabled = true
        createDrawingOutlet.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        createTextMessage(x: 0, y: self.view.frame.maxY/2)
    }
    
    
    @IBOutlet weak var createDrawingOutlet: UIButton!
    
    @IBAction func createDrawingAction(_ sender: Any) {
        drawViewOutlet.isUserInteractionEnabled = !drawViewOutlet.isUserInteractionEnabled
        if(drawViewOutlet.isUserInteractionEnabled) {
            createTextOutlet.isHidden = true
            drawColorButtonsStack.isHidden = false
            self.textViewOutlet.isUserInteractionEnabled = false
            createDrawingOutlet.setTitleColor(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), for: .normal)
        }else{
            createTextOutlet.isHidden = false
            drawColorButtonsStack.isHidden = true
            self.textViewOutlet.isUserInteractionEnabled = true
            createDrawingOutlet.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        }
    }
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet var textColorButtons: [UIButton]!
    @IBOutlet var drawColorButtons: [UIButton]!
    
    @IBOutlet weak var drawColorButtonsStack: UIStackView!
    @IBOutlet weak var textColorButtonsStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadColorButtons(buttons: self.textColorButtons, type:"text")
        self.loadColorButtons(buttons: self.drawColorButtons, type:"draw")
        self.sendButton.isEnabled = false
        self.currentTextColor = textColors[0]
        self.textColorButtonsStack.isHidden = true
        self.sendButton.setTitleColor(UIColor.gray, for: .normal)
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        imageOutlet.isUserInteractionEnabled = true;
        imageOutlet.contentMode = .scaleAspectFill
        imageOutlet.image = capturedIamge
        imageOutlet.center = self.view.center
        self.drawViewOutlet.isUserInteractionEnabled = false
        self.textViewOutlet.isUserInteractionEnabled = true
        

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
//        createTextMessage(x: sender.location(in: self.view).x, y: sender.location(in: self.view).y)
    }
    
    @objc func dragged(gesture: UIPanGestureRecognizer
        ) {
        let loc = gesture.location(in: view)
        gesture.view?.frame.origin.y = loc.y
        gesture.view?.layoutIfNeeded()
    }
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        activeTextField = sender.view as? UITextField
        
    }
    
    
    private func createTextMessage(x: CGFloat, y: CGFloat) {
        if(!keyboardIsVisible){
            let someFrame = CGRect(x: 0, y: y, width: self.view.frame.width, height: 30.0)
            
            let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragged))
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
            
            let textField = UITextField(frame: someFrame)
            textField.addGestureRecognizer(dragGesture)
            textField.addGestureRecognizer(tapGesture)
            activeTextField = textField
            
            self.textViewOutlet.addSubview(textField)
            textField.textColor = currentTextColor
            textFields.append(textField)
            previousTextFieldY = y
            textField.becomeFirstResponder()
            textField.delegate = self
            createTextOutlet.setTitleColor(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), for: .normal)
            createDrawingOutlet.isHidden = true
        }else{
            createDrawingOutlet.isHidden = false
            createTextOutlet.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            self.view.endEditing(true)
        }
    }

    private func generateUniqueFilename (myFileName: String) -> String {
        
        let guid = ProcessInfo.processInfo.globallyUniqueString
        let uniqueFileName = ("\(myFileName)_\(guid)")
        
        print("uniqueFileName: \(uniqueFileName)")
        
        return uniqueFileName
    }
    
    private func loadColorButtons(buttons: [UIButton], type: String) {
        var count = 0
        for button in buttons {
            button.frame.size = CGSize(width: 50, height: 50)
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1.5
            button.layer.borderColor = UIColor.gray.cgColor
            button.setTitle("", for: .normal)
            if(type == "text"){
             button.addTarget(self, action: #selector(self.setTextColorAction(_:)), for: .touchUpInside)
            }else if(type == "draw"){
                 button.addTarget(self, action: #selector(self.setDrawColorAction(_:)), for: .touchUpInside)
            }
            switch(count){
            case 0:
                button.backgroundColor = textColors[0]
                button.tag = 0
               
            case 1:
                button.backgroundColor = textColors[1]
                button.tag = 1
              
            case 2:
                button.backgroundColor = textColors[2]
                button.tag = 2
               
            case 3:
                button.backgroundColor = textColors[3]
                button.tag = 3
                
            
            default:
                button.backgroundColor = textColors[3]
                button.tag = 4
                button.addTarget(self, action: #selector(self.setTextColorAction(_:)), for: .touchUpInside)
            }
            count+=1
        }
    }
    
    
    
    
    @objc func setTextColorAction(_ sender: UIButton) {
        for button in textColorButtons {
            button.layer.borderColor = UIColor.gray.cgColor
        }
        
        switch(sender.tag) {
        case 0:
            currentTextColor = textColors[0]
            textColorButtons[0].layer.borderColor = UIColor.white.cgColor
        case 1:
            currentTextColor = textColors[1]
            textColorButtons[1].layer.borderColor = UIColor.white.cgColor

        case 2:
            currentTextColor = textColors[2]
            textColorButtons[2].layer.borderColor = UIColor.white.cgColor

        case 3:
            currentTextColor = textColors[3]
            textColorButtons[3].layer.borderColor = UIColor.white.cgColor

        default:
            currentTextColor = textColors[3]
            textColorButtons[3].layer.borderColor = UIColor.white.cgColor

        }
        
        if(keyboardIsVisible) {
            activeTextField.textColor = currentTextColor
        }
    }
    
    @objc func setDrawColorAction(_ sender: UIButton) {
        for button in drawColorButtons {
            button.layer.borderColor = UIColor.gray.cgColor
        }
        switch(sender.tag) {
        case 0:
            self.drawViewOutlet.drawColor = drawColors[0]
            drawColorButtons[0].layer.borderColor = UIColor.white.cgColor
        case 1:
            self.drawViewOutlet.drawColor = drawColors[1]
            drawColorButtons[1].layer.borderColor = UIColor.white.cgColor

        case 2:
            self.drawViewOutlet.drawColor = drawColors[2]
            drawColorButtons[2].layer.borderColor = UIColor.white.cgColor

        case 3:
            self.drawViewOutlet.drawColor = drawColors[3]
            drawColorButtons[3].layer.borderColor = UIColor.white.cgColor

        default:
            self.drawViewOutlet.drawColor = drawColors[3]
            drawColorButtons[3].layer.borderColor = UIColor.white.cgColor

        }
        
    }
    
    func combineImages(image1: UIImage, image2: UIImage, image3: UIImage) -> UIImage?{
        UIGraphicsBeginImageContextWithOptions(self.imageOutlet.frame.size, false, 0.0)
        image1.draw(in: CGRect(origin: CGPoint.zero, size: self.view.frame.size))
        image2.draw(in: CGRect(origin: CGPoint.zero, size: self.view.frame.size))
        image3.draw(in: CGRect(origin: CGPoint.zero, size: self.view.frame.size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    @IBAction func uploadButtonAction(_ sender: Any) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            locManager.requestLocation()
        }else{
            locManager.requestWhenInUseAuthorization()
        }
        
        let image1 = UIImage(view: imageOutlet)
        let image2 = UIImage(view: self.drawViewOutlet)
        let image3 = UIImage(view: self.textViewOutlet)
        
        let image = combineImages(image1: image1, image2: image2, image3: image3)!

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
                        let newYak = Yak(user_id: "B1WRIde8IPTZuWoTsiBU", image_url: fileName, location: GeoPoint(latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude), time_stamp: Date(), likes: 0)
                        self.db.uploadYak(yak: newYak)
                        
                        print("image uploaded")
                    }
                }
                print("file saved" + fileURL.absoluteString)
                self.dismiss(animated: true, completion: nil)
                
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        self.keyboardIsVisible = true
        self.textColorButtonsStack.isHidden = false
        self.createTextOutlet.setTitleColor(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), for: .normal)
        self.createDrawingOutlet.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        if let info = notification.userInfo {
            let rect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            
            let targetY  = view.frame.size.height - rect.height - 40
            if let textField = activeTextField{
                textField.frame.origin.y = targetY
                textField.backgroundColor = #colorLiteral(red: 0.1841630342, green: 0.1981908197, blue: 0.2178189767, alpha: 0.6)
                textField.textColor = currentTextColor
                textField.becomeFirstResponder()
                textField.delegate = self
            }
        }
        view.layoutIfNeeded()

    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.keyboardIsVisible = false
        self.createTextOutlet.setTitleColor(UIColor.white, for: .normal)
        self.createDrawingOutlet.setTitleColor(UIColor.white, for: .normal)
        self.createTextOutlet.isHidden=false
        self.createDrawingOutlet.isHidden=false
        self.textColorButtonsStack.isHidden = true
        if let textField = activeTextField, textField.text != ""{
            textField.frame.origin.y = previousTextFieldY!
            textField.textAlignment = .center
        }
        
        if let textField = textFields.last {
            if(textField.text == ""){
                textField.isHidden = true
            }
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
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}

