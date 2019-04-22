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
        db = Firestore.firestore()
    }
    
    
    public func uploadYak(yak: Yak) {
        var ref:DocumentReference? = nil
        ref = self.db.collection("Yaks").addDocument(data: yak.dictionary) {
            error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
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


