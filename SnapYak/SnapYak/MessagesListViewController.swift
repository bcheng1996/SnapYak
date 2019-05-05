//
//  MessagesListViewController.swift
//  SnapYak
//
//  Created by Brian Guevara on 4/15/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class MessagesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet var tableView: UITableView!
    let radius: Double = 10000000
    var messages: [Yak]! // This will be where our message data is held
    var imageCache: [String: Data]!
    var locManager: CLLocationManager!
    var db: Database!
    var storage: StorageReference!
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.messages = []
        self.imageCache = [:]
        self.locManager = CLLocationManager()
        self.locManager.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.db = Database()
        self.refresher = UIRefreshControl()
        self.tableView.addSubview(refresher)
        refresher.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refresher.tintColor = UIColor(red: 1.00, green: 0.20, blue: 0.50, alpha: 1.0)
        refresher.addTarget(self, action: #selector(checkForNewYaks), for: .valueChanged)
        
        self.locManager.requestLocation()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            locManager.requestLocation()
        } else{
            locManager.requestWhenInUseAuthorization()
        }
        checkForNewYaks()
    }
    
    @objc func checkForNewYaks() {
        if let loc = self.locManager.location {
            db.fetchYaks(currentLocation: loc, radius: self.radius) { (yaks) in
                // Sort the incoming yaks by distance to current location
                self.messages = yaks
                self.sortMessages(loc: loc)
                self.fillImageCache()
                self.tableView.reloadData()
                self.refresher.endRefreshing()
            }
        } else {
            self.refresher.endRefreshing()
        }
    }
    
    func fillImageCache() {
        for yak in self.messages {
            if (self.imageCache[yak.image_url] == nil){
                db.fetchImage(imageURL: yak.image_url) { (data) in
                    self.imageCache[yak.image_url] = data
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Basically click on the message row and we want to get the data for the message
        // Display it in another VC
        let data = messages[indexPath.row]
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "messageViewController") as! MessageViewController
        newVC.yak = data
        
        if (self.imageCache[data.image_url] != nil){
            newVC.cachedImage = self.imageCache[data.image_url]
        }
        
        self.present(newVC, animated: true) {
            // Once the view returns from presenting, unselect the row that was
            // previously selected
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func hoursBetweenDate(pastDate: Date) -> Double {
        let currDate = Date()
        let timeInterval = currDate.timeIntervalSince(pastDate)
        
        let secondsInHour: Double = 3600
        let hourSincePast = timeInterval / secondsInHour
        
        return hourSincePast
    }
    
    func minutesBetweenDate(pastDate: Date) -> Double {
        let currDate = Date()
        let timeInterval = currDate.timeIntervalSince(pastDate)
        
        let secondsInMinute: Double = 60
        let hourSincePast = timeInterval / secondsInMinute
        
        return hourSincePast
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageCell
        
        // Calculate the distance of the yak (in meters) for the headline label
        let yak1 = self.messages[indexPath.row]
        let yak1Coord = CLLocation(latitude: yak1.location.latitude, longitude: yak1.location.longitude)
        var timeScale = "hour(s)"
        var timeElapsed = hoursBetweenDate(pastDate: yak1.time_stamp)
        var yakDistance = 0.0
        
        if let location = self.locManager.location {
            yakDistance = location.distance(from: yak1Coord)
        }
        if timeElapsed < 1.0 {
            timeElapsed = minutesBetweenDate(pastDate: yak1.time_stamp)
            timeScale = "minute(s)"
        }
        
        let yakDistanceString = String(format: "%.2f", yakDistance)
        let timePassedString = String(format: "%.0f", timeElapsed)
        
        cell.headlineLabel.text = "\(yakDistanceString) meters away."
        cell.usernameLabel.text = "\(timePassedString) \(timeScale) ago"
        cell.votesLabel.text = "100%"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Nearby Yaks"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        db.fetchYaks(currentLocation: locations.first!, radius: self.radius) { (yaks) in
            self.messages = yaks
            self.sortMessages(loc: locations.first!)
            self.fillImageCache()
            self.tableView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        return
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status != CLAuthorizationStatus.authorizedWhenInUse &&
            status != CLAuthorizationStatus.authorizedAlways) {
            performSegue(withIdentifier: "ShowModalView", sender: self)
        }
    }
    
    func sortMessages(loc: CLLocation){
        self.messages = messages.sorted(by: { (yak1, yak2) -> Bool in
            let yak1Coord = CLLocation(latitude: yak1.location.latitude, longitude: yak1.location.longitude)
            let yak2Coord = CLLocation(latitude: yak2.location.latitude, longitude: yak2.location.longitude)
            let distanceToYak1 = loc.distance(from: yak1Coord)
            let distanceToYak2 = loc.distance(from: yak2Coord)
            
            if (distanceToYak1 < distanceToYak2){
                return true
            } else {
                return false
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ShowModalView" {
                if let viewController = segue.destination as? ModalViewController {
                    viewController.modalPresentationStyle = .overFullScreen
                }
            }
        }
    }
}
