//
//  FirebaseModel.swift
//  SnapYak
//
//  Created by Brian Guevara on 4/15/19.
//  Copyright © 2019 group34. All rights reserved.
//

import Foundation

import Firebase
import CoreLocation

class Database {
    var db: Firestore!
    var storageRef: StorageReference!
    
    init() {
        db = Firestore.firestore()
        storageRef = Storage.storage().reference()
    }
    
    
    public func uploadYak(yak: Yak) {
        var ref: DocumentReference? = nil
        ref = self.db.collection("Yaks").addDocument(data: yak.dictionary) {
            error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    public func fetchImage(imageURL: String, completion: ((Data) -> ())?) {
        // check if the image is a firebase resoruce or http resource
        if imageURL.contains("http"){
            let resource = URL(string: imageURL)
            
            if let targetURL = resource {
                let task = URLSession.shared.dataTask(with: targetURL) { (data, response, error) in
                    if error != nil {
                        print("Error Fetching HTTP image data")
                    } else {
                        if let imageData = data {
                            if completion != nil {
                                completion!(imageData)
                            }
                        }
                    }
                }
                task.resume()
            }
        }
        else {
            // It is a firebase storage image
            let fbStoragePathRef = storageRef.child("images/\(imageURL)")
            
            fbStoragePathRef.getData(maxSize: 15 * 1024 * 1024) { (data, error) in
                if error != nil {
                    print("Error downloading image from Firebase Storage")
                } else {
                    if let imageData = data {
                        if completion != nil {
                            completion!(imageData)
                        }
                    }
                }
            }
        }
        
    }
    
    // Fetches the yaks within a certain radius. Returns the yaks through an optional
    // completion handler
    public func fetchYaks(currentLocation: CLLocation, radius: Double, completion: (([Yak]) -> ())?){
        var result: [Yak] = []
        
        // Collect all Yaks
        self.db.collection("Yaks").getDocuments { (rawSnapshot, error) in
            if error != nil {
                print("Error fetching yaks, check connection")
            } else {
                if let snapshot = rawSnapshot {
                    // Filter Yaks one by one
                    for doc in snapshot.documents {
                        let rawYak = doc.data()
                        let coordinate = rawYak["location"] as! GeoPoint
                        let lat: CLLocationDegrees = coordinate.latitude
                        let long: CLLocationDegrees = coordinate.longitude
                        let location = CLLocation(latitude: lat, longitude: long)
                        
                        // If this yak is within radius add it to results
                        let dist = location.distance(from: currentLocation)
                        if (dist <= radius){
                            let yak = Yak(dictionary: rawYak)
                            
                            if let parsedYak = yak {
                                result.append(parsedYak)
                            }
                        }
                        
                    }
                    if completion != nil {
                        completion!(result)
                    }
                }
            }
        }
    }
    
    public func updateYakVote(targetYak: Yak){
        // Collect all Yaks
        self.db.collection("Yaks").getDocuments { (rawSnapshot, error) in
            if error != nil {
                print("Error fetching yaks, check connection")
            } else {
                if let snapshot = rawSnapshot {
                    // Filter Yaks
                    for doc in snapshot.documents {
                        let rawYak = doc.data()
                        let yak = Yak(dictionary: rawYak)
                        
                        if (targetYak.image_url == yak?.image_url){
                            self.db.collection("Yaks")
                                .document(doc.documentID)
                                .updateData(["likes" : targetYak.likes])
                            break
                        }
                        
                        
                    }
                }
            }
        }
    }
    
    public func updateComments(targetYak: Yak) {
        self.db.collection("Yaks").getDocuments { (rawSnapshot, error) in
            if error != nil {
                print("Error fetching yaks, check connection")
            } else {
                if let snapshot = rawSnapshot {
                    for doc in snapshot.documents {
                        let rawYak = doc.data()
                        let yak = Yak(dictionary: rawYak)
                        
                        if (targetYak.image_url == yak?.image_url){
                            self.db.collection("Yaks")
                                .document(doc.documentID)
                                .updateData(["comments" : targetYak.comments])
                            break
                        }
                    }
                }
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


