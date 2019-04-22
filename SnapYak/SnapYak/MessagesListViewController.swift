//
//  MessagesListViewController.swift
//  SnapYak
//
//  Created by Brian Guevara on 4/15/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit

class MessagesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var messages: [String]! // This will be where our message data is held
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.messages = ["Test1", "Test2", "Test3"]
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // TODO: Retrieve messages from server or file
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Basically click on the message row and we want to get the data for the message
        // Display it in another VC
        let data = messages[indexPath.row]
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "messageViewController") as! MessageViewController
        
        self.present(newVC, animated: true) {
            // Once the view returns from presenting, unselect the row that was
            // previously selected
            
            // TODO: retrieve image data from server
            newVC.messageLabel.text = data
            newVC.imageView.backgroundColor = UIColor.black
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageCell
        cell.headlineLabel.text = self.messages[indexPath.row]
        cell.usernameLabel.text = "TODO: ADD USERNAME DATA"
        cell.votesLabel.text = "TODO: ADD VOTES DATA"
        
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
