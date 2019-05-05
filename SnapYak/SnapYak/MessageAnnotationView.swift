//
//  MessageAnnotationView.swift
//  SnapYak
//
//  Created by Noah Fichter on 5/5/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit
import MapKit

class MessageAnnotationView: MKAnnotationView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = UIImage(named: "Yak")
        rightCalloutAccessoryView = UIButton(type: .infoLight)
    }
}
