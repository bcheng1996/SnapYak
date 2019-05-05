//
//  MapViewController.swift
//  SnapYak
//
//  Created by Brian Guevara on 4/15/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    var locManager: CLLocationManager!
    let radius: Double = 5000
    var messages: [Yak]!
    var db: Database!
    var storage: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.locManager = CLLocationManager()
        mapView.delegate = self
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        self.db = Database()
        
        if let userLocation = locManager.location {
            let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: false)
            
            db.fetchYaks(currentLocation: userLocation, radius: self.radius) { (yaks) in
                self.messages = yaks
                self.displayYaks()
            }
        } else {
            self.messages = []
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        db.fetchYaks(currentLocation: locations.first!, radius: self.radius) { (yaks) in
            self.messages = yaks
        }
        
        displayYaks()
    }
    
    func displayYaks() {
        for yak in self.messages {
            NSLog(yak.image_url)
            let lat = yak.location.latitude
            let lon = yak.location.longitude
            var coord: [CLLocationCoordinate2D] = []
            coord.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
            coord.append(CLLocationCoordinate2D(latitude: lat + 1, longitude: lon))
            coord.append(CLLocationCoordinate2D(latitude: lat + 1, longitude: lon + 1))
            coord.append(CLLocationCoordinate2D(latitude: lat, longitude: lon + 1))
            
            mapView.addOverlay(MKPolygon(coordinates: coord, count: 4))
        }
    }
}
