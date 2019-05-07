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
    @IBOutlet var segmentedControl: UISegmentedControl!
    var radius: Double = 10000000
    var messages: [Yak]! // This will be where our message data is held
    var imageCache: [String: Data]!
    var locManager: CLLocationManager!
    var db: Database!
    var storage: StorageReference!
    var refresher: UIRefreshControl!
    
    override func viewDidAppear(_ animated: Bool) {
        self.radius = UserDefaults.standard.double(forKey: "radius")
        if self.radius == 0 {
            self.radius = 10000000
            UserDefaults.standard.set(10000000, forKey: "radius")
        }
        checkForNewYaks()
    }
    
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
        
        self.refresher.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        self.refresher.tintColor = UIColor(red: 1.00, green: 0.20, blue: 0.50, alpha: 1.0)
        self.refresher.addTarget(self, action: #selector(checkForNewYaks), for: .valueChanged)
        
        self.segmentedControl.addTarget(self, action: #selector(handleSort), for: UIControl.Event.valueChanged)
    
        self.radius = UserDefaults.standard.double(forKey: "radius")
        if self.radius == 0 {
            self.radius = 10000000
            UserDefaults.standard.set(10000000, forKey: "radius")
        }
        
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
                self.handleSort()
                self.tableView.reloadData()
                self.refresher.endRefreshing()
            }
        } else {
            self.refresher.endRefreshing()
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
            
            self.present(newVC, animated: true) {
                // Once the view returns from presenting, unselect the row that was
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            
        } else {
            self.db.fetchImage(imageURL: data.image_url) { (imageData) in
                self.imageCache[data.image_url] = imageData
                newVC.cachedImage = imageData
                self.present(newVC, animated: true) {
                    // Once the view returns from presenting, unselect the row that was
                    // previously selected and cache the image
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
            }
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
        cell.votesLabel.text = "\(yak1.likes)"
        cell.upVoteButton.tag = indexPath.row
        cell.downVoteButton.tag = indexPath.row
        
        if yak1.likes >= 0 {
            cell.votesLabel.textColor = UIColor(hue: 0.3472, saturation: 1, brightness: 0.57, alpha: 1.0)
        } else {
            cell.votesLabel.textColor = UIColor(hue: 0, saturation: 1, brightness: 0.53, alpha: 1.0)
        }
        
        let upvoted:[String] = (UserDefaults.standard.array(forKey: "upvoted") ?? []) as! [String]
        let downvoted:[String] = (UserDefaults.standard.array(forKey: "downvoted") ?? []) as! [String]
        
        if upvoted.contains(yak1.image_url) {
            if let img = UIImage(named: "upgreen") {
                cell.upVoteButton.setImage(img, for: .normal)
            }
        } else {
            if let img = UIImage(named: "up") {
                cell.upVoteButton.setImage(img, for: .normal)
            }
        }
        
        if downvoted.contains(yak1.image_url) {
            if let img = UIImage(named: "downred") {
                cell.downVoteButton.setImage(img, for: .normal)
            }
        } else {
            if let img = UIImage(named: "down") {
                cell.downVoteButton.setImage(img, for: .normal)
            }
        }
        
        cell.upVoteButton.addTarget(self, action: #selector(upVote), for: .touchUpInside)
        cell.downVoteButton.addTarget(self, action: #selector(downVote), for: .touchUpInside)
        
        return cell
    }
    
    @objc
    func upVote(sender: UIButton) {
        var upvoted:[String] = (UserDefaults.standard.array(forKey: "upvoted") ?? []) as! [String]
        var downvoted:[String] = (UserDefaults.standard.array(forKey: "downvoted") ?? []) as! [String]
        var yak = self.messages[sender.tag]
        var unupvoted = false
        
        if upvoted.contains(yak.image_url) {
            yak.likes = yak.likes - 1
            upvoted = upvoted.filter { $0 != yak.image_url }
            UserDefaults.standard.set(upvoted, forKey: "upvoted")
            unupvoted = true
            self.messages[sender.tag] = yak
            let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! MessageCell
            cell.votesLabel.text = "\(yak.likes)"
            
            if yak.likes >= 0 {
                cell.votesLabel.textColor = UIColor(hue: 0.3472, saturation: 1, brightness: 0.57, alpha: 1.0)
            } else {
                cell.votesLabel.textColor = UIColor(hue: 0, saturation: 1, brightness: 0.53, alpha: 1.0)
            }
            
            db.updateYakVote(targetYak: yak)
        }
        if !upvoted.contains(yak.image_url) && !unupvoted {
            if downvoted.contains(yak.image_url) {
                yak.likes = yak.likes + 1
                downvoted = downvoted.filter { $0 != yak.image_url }
            }
            yak.likes = yak.likes + 1
            // Since this is swift and the var is a struct
            // we need to replace the old yak with the new yak
            // with the updated vote count
            // otherwise the original in the array wont update
            self.messages[sender.tag] = yak
            let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! MessageCell
            cell.votesLabel.text = "\(yak.likes)"
            
            if yak.likes >= 0 {
                cell.votesLabel.textColor = UIColor(hue: 0.3472, saturation: 1, brightness: 0.57, alpha: 1.0)
            } else {
                cell.votesLabel.textColor = UIColor(hue: 0, saturation: 1, brightness: 0.53, alpha: 1.0)
            }
            
            db.updateYakVote(targetYak: yak)
            
            upvoted.append(yak.image_url)
            UserDefaults.standard.set(upvoted, forKey: "upvoted")
            UserDefaults.standard.set(downvoted, forKey: "downvoted")
        }
        
        self.tableView.reloadData()
    }
    
    @objc
    func downVote(sender: UIButton) {
        var upvoted:[String] = (UserDefaults.standard.array(forKey: "upvoted") ?? []) as! [String]
        var downvoted:[String] = (UserDefaults.standard.array(forKey: "downvoted") ?? []) as! [String]
        var yak = self.messages[sender.tag]
        var undownvoted = false
        
        if downvoted.contains(yak.image_url) {
            yak.likes = yak.likes + 1
            downvoted = downvoted.filter { $0 != yak.image_url }
            UserDefaults.standard.set(downvoted, forKey: "downvoted")
            undownvoted = true
            self.messages[sender.tag] = yak
            let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! MessageCell
            cell.votesLabel.text = "\(yak.likes)"
            
            if yak.likes >= 0 {
                cell.votesLabel.textColor = UIColor(hue: 0.3472, saturation: 1, brightness: 0.57, alpha: 1.0)
            } else {
                cell.votesLabel.textColor = UIColor(hue: 0, saturation: 1, brightness: 0.53, alpha: 1.0)
            }
            
            db.updateYakVote(targetYak: yak)
        }
        if !downvoted.contains(yak.image_url) && !undownvoted {
            if upvoted.contains(yak.image_url) {
                yak.likes = yak.likes - 1
                upvoted = upvoted.filter { $0 != yak.image_url }
            }
            yak.likes = yak.likes - 1
            self.messages[sender.tag] = yak
            let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! MessageCell
            cell.votesLabel.text = "\(yak.likes)"
        
            if yak.likes >= 0 {
                cell.votesLabel.textColor = UIColor(hue: 0.3472, saturation: 1, brightness: 0.57, alpha: 1.0)
            } else {
                cell.votesLabel.textColor = UIColor(hue: 0, saturation: 1, brightness: 0.53, alpha: 1.0)
            }
        
            db.updateYakVote(targetYak: yak)
        
            downvoted.append(yak.image_url)
            UserDefaults.standard.set(upvoted, forKey: "upvoted")
            UserDefaults.standard.set(downvoted, forKey: "downvoted")
        }
        
        self.tableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        db.fetchYaks(currentLocation: locations.first!, radius: self.radius) { (yaks) in
            self.messages = yaks
            self.handleSort()
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
    
    func sortMessagesByLocation(loc: CLLocation){
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
    
    func sortMessagesByLikes(){
        self.messages = messages.sorted(by: { (yak1, yak2) -> Bool in
            if (yak1.likes > yak2.likes){
                return true
            } else {
                return false
            }
        })
    }
    
    @objc func handleSort() {
        if (self.segmentedControl.selectedSegmentIndex == 0){
            if let loc = self.locManager.location {
                self.sortMessagesByLocation(loc: loc)
            }
        } else {
            self.sortMessagesByLikes()
        }
        self.tableView.reloadData()
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
