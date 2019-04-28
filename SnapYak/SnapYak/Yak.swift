//
//  Yak.swift
//  SnapYak
//
//  Created by Benny Cheng on 4/22/19.
//  Copyright © 2019 group34. All rights reserved.
//

import Foundation
import Firebase

protocol DocumentSerializable {
    init?(dictionary: [String: Any])
}

struct Yak {
    var user_id: String
    var image_url: String
    var location: GeoPoint
    var time_stamp: Date
    
    var dictionary: [String: Any] {
        return [
            "user_id": user_id,
            "image_url": image_url,
            "location": location,
            "time_stamp": time_stamp
        ]
    }
}


extension Yak : DocumentSerializable {
    init?(dictionary: [String : Any]) {
        guard let user_id = dictionary["user_id"] as? String,
            let image_url = dictionary["image_url"] as? String,
            let location = dictionary["location"] as? GeoPoint,
            let time_stamp = dictionary["time_stamp"] as? Timestamp
            else{return nil}
        self.init(user_id: user_id, image_url: image_url, location: location, time_stamp: time_stamp.dateValue())
    }
}

