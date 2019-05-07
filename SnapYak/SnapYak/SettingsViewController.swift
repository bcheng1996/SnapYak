//
//  SettingsViewController.swift
//  SnapYak
//
//  Created by Noah Fichter on 5/6/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    var radius: Double = 0
    @IBOutlet weak var textField: UITextField!
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
    
    @IBAction func saveRadius(_ sender: Any) {
        if let rad = Double(textField.text!) {
            UserDefaults.standard.set(rad, forKey: "radius")
        }
        self.textField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        self.radius = UserDefaults.standard.double(forKey: "radius")
        if self.radius == 0 {
            self.radius = 10000000
            UserDefaults.standard.set(10000000, forKey: "radius")
        }
        textField.text = String(Double(radius))
    }
}
