//
//  FirebaseViewController.swift
//  SnapYak
//
//  Created by Benny Cheng on 4/22/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit
import Firebase

class FirebaseViewController: UIViewController {

    var db: Firestore!
    var Yaks = [Yak]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func composeYak(_ sender: UIButton) {
        var ref:DocumentReference? = nil
        let yakLoc = GeoPoint(latitude: 38.996319, longitude: -76.933629)
        let newYak = Yak(user_id: "B1WRIde8IPTZuWoTsiBU", image_url: "http://thestamp.umd.edu/portals/1/Images/library2.jpg", location: yakLoc, time_stamp: Date())
        print(newYak)
        ref = self.db.collection("Yaks").addDocument(data: newYak.dictionary) {
            error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
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
