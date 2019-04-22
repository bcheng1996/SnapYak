//
//  FirebaseModel.swift
//  SnapYak
//
//  Created by Brian Guevara on 4/15/19.
//  Copyright © 2019 group34. All rights reserved.
//

import Foundation

import Firebase

class Database {
    var db: Firestore!
    
    init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
}





//struct YakLocation {
//    var latitude: Decimal
//    var longitude: Decimal
//}
//
//class Yaks {
//    var image_url: String
//    var comments: [String]
//    var location: YakLocation
//
//    init(snap: )
//}


