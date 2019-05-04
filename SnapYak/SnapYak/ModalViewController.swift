//
//  ModalViewController.swift
//  SnapYak
//
//  Created by Noah Fichter on 5/4/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit
import CoreLocation

class ModalViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goToSettingsButtonPressed(_ sender: Any) {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func clickWhenCompleteButtonPressed(_ sender: Any) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            dismiss(animated: true, completion: nil)
        }
    }
}
