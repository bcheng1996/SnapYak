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
    let radius: Double = 5000
    var messages: [Yak]! // This will be where our message data is held
    var locManager: CLLocationManager!
    var db: Database!
    var storage: StorageReference!
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.messages = []
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
        
        // TODO: Retrieve messages from server or file
    }
    
    @objc func checkForNewYaks() {
        if let loc = self.locManager.location {
            db.fetchYaks(currentLocation: loc, radius: self.radius) { (yaks) in
                self.messages = yaks
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
        
        self.present(newVC, animated: true) {
            // Once the view returns from presenting, unselect the row that was
            // previously selected
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageCell
        cell.headlineLabel.text = self.messages[indexPath.row].image_url
        cell.usernameLabel.text = "TODO: ADD USERNAME DATA"
        cell.votesLabel.text = "TODO: ADD VOTES DATA"
        
        return cell
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        db.fetchYaks(currentLocation: locations.first!, radius: self.radius) { (yaks) in
            self.messages = yaks
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
