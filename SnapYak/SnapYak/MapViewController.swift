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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let userLocation = locManager.location {
            db.fetchYaks(currentLocation: userLocation, radius: self.radius) { (yaks) in
                self.messages = yaks
                self.displayYaks()
            }
        } else {
            self.messages = []
        }
        
    }
    
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
            self.displayYaks()
        }
    }
    
    func displayYaks() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        var index = 0
        for yak in self.messages {
            let coord = CLLocationCoordinate2D(latitude: yak.location.latitude, longitude: yak.location.longitude)
            let annotation = MessageAnnotation(coordinate: coord, yak: yak, index: index)
            mapView.addAnnotation(annotation)
            index += 1
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MessageAnnotationView(annotation: annotation, reuseIdentifier: "Message")
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MessageAnnotation {
            if let data = messages?[annotation.index ?? -1] {
                let storyboard = UIStoryboard(name: "List", bundle: nil)
                let newVC = storyboard.instantiateViewController(withIdentifier: "messageViewController") as! MessageViewController
                newVC.yak = data
                
                self.present(newVC, animated: true)
            }
        }
    }
}
