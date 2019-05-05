//
//  MessageAnnotation.swift
//  SnapYak
//
//  Created by Noah Fichter on 5/5/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit
import MapKit

func dateToString(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
    
    let myString = formatter.string(from: date) // string purpose I add here
    let myDate = formatter.date(from: myString)
    //then again set the date format whhich type of output you need
    formatter.dateFormat = "MM-dd-yyyy"
    // again convert your date to string
    let resString = formatter.string(from: myDate!)
    
    return resString
}

class MessageAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var index: Int?
    
    init(coordinate: CLLocationCoordinate2D, yak: Yak, index: Int) {
        self.coordinate = coordinate
        self.title = dateToString(date: yak.time_stamp)
        self.index = index
    }
}
