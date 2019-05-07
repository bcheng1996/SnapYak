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
    var radius: Double!
    var messages: [Yak]!
    var db: Database!
    var storage: StorageReference!
    var imageCache: [String: Data]!
    
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
        self.radius = UserDefaults.standard.double(forKey: "radius")
        if self.radius == 0 {
            self.radius = 10000000
            UserDefaults.standard.set(10000000, forKey: "radius")
        }
        self.locManager = CLLocationManager()
        mapView.delegate = self
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        self.db = Database()
        self.imageCache = [:]
        
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
                
                if (self.imageCache[data.image_url] != nil){
                    newVC.cachedImage = self.imageCache[data.image_url]
                    
                    print("Pulling from image cache: \(data.image_url)")
                    self.present(newVC, animated: true, completion: nil)
                } else {
                    
                    print("Making Request to database for image")
                    db.fetchImage(imageURL: data.image_url) { (imgData) in
                        newVC.cachedImage = imgData
                        print("Caching Image: \(data.image_url)")
                        self.imageCache[data.image_url] = imgData
                        
                        self.present(newVC, animated: true, completion: nil)
                    }
                }
               
            }
        }
    }
}
