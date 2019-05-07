//
//  MessageViewController.swift
//  SnapYak
//
//  Created by Brian Guevara on 4/15/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet weak var upvoteButton:
    UIButton!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var downvoteButton: UIButton!
    var db: Database!
    var yak: Yak?
    var cachedImage: Data?

    override func viewWillAppear(_ animated: Bool) {
        db = Database()
        if cachedImage != nil {
            self.imageView.contentMode = .scaleAspectFill
            self.imageView.image = UIImage(data: cachedImage!)
        }  else {
            // This shouldn't be needed. The caller of the VC should
            // supply the image from a fetch or cache but this is here
            // for redundancy. Be careful to not over-fetch. It will
            // use up all Firebase quotas
            db.fetchImage(imageURL: self.yak!.image_url) { (data) in
                self.imageView.contentMode = .scaleAspectFill
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let inputYak = yak {
            self.votesLabel.text = "\(inputYak.likes)"
            self.upvoteButton.addTarget(self, action: #selector(upVote), for: .touchUpInside)
            self.downvoteButton.addTarget(self, action: #selector(downVote), for: .touchUpInside)
            
            // color the label depending on votes
            if inputYak.likes >= 0 {
                self.votesLabel.textColor = UIColor(hue: 0.3472, saturation: 1, brightness: 0.57, alpha: 1.0)
            } else {
                self.votesLabel.textColor = UIColor(hue: 0, saturation: 1, brightness: 0.53, alpha: 1.0)
            }
            
            colorButtons()
        }
    }
    
    // Colors the upvote buttons appropriately
    func colorButtons() {
        if let inputYak = self.yak {
            let upvoted:[String] = (UserDefaults.standard.array(forKey: "upvoted") ?? []) as! [String]
            let downvoted:[String] = (UserDefaults.standard.array(forKey: "downvoted") ?? []) as! [String]
            
            if upvoted.contains(inputYak.image_url) {
                if let img = UIImage(named: "upgreen") {
                    self.upvoteButton.setImage(img, for: .normal)
                }
            } else {
                if let img = UIImage(named: "up") {
                    self.upvoteButton.setImage(img, for: .normal)
                }
            }
            
            if downvoted.contains(inputYak.image_url) {
                if let img = UIImage(named: "downred") {
                    self.downvoteButton.setImage(img, for: .normal)
                }
            } else {
                if let img = UIImage(named: "down") {
                    self.downvoteButton.setImage(img, for: .normal)
                }
            }
        }
    }
    
    @objc func upVote() {
        var upvoted:[String] = (UserDefaults.standard.array(forKey: "upvoted") ?? []) as! [String]
        var downvoted:[String] = (UserDefaults.standard.array(forKey: "downvoted") ?? []) as! [String]
        var unupvoted = false
        
        if upvoted.contains(self.yak!.image_url) {
            self.yak!.likes = yak!.likes - 1
            upvoted = upvoted.filter { $0 != yak!.image_url }
            UserDefaults.standard.set(upvoted, forKey: "upvoted")
            unupvoted = true
            self.votesLabel.text = "\(self.yak!.likes)"
            
            if yak!.likes >= 0 {
                self.votesLabel.textColor = UIColor(hue: 0.3472, saturation: 1, brightness: 0.57, alpha: 1.0)
            } else {
                self.votesLabel.textColor = UIColor(hue: 0, saturation: 1, brightness: 0.53, alpha: 1.0)
            }
            
            db.updateYakVote(targetYak: yak!)
        }
        if !upvoted.contains(self.yak!.image_url) && !unupvoted {
            if downvoted.contains(self.yak!.image_url) {
                self.yak!.likes = self.yak!.likes + 1
                downvoted = downvoted.filter { $0 != self.yak!.image_url }
            }
            self.yak!.likes = self.yak!.likes + 1
            // Since this is swift and the var is a struct
            // we need to replace the old yak with the new yak
            // with the updated vote count
            // otherwise the original in the array wont update
            self.votesLabel.text = "\(self.yak!.likes)"
            
            if self.yak!.likes >= 0 {
                self.votesLabel.textColor = UIColor(hue: 0.3472, saturation: 1, brightness: 0.57, alpha: 1.0)
            } else {
                self.votesLabel.textColor = UIColor(hue: 0, saturation: 1, brightness: 0.53, alpha: 1.0)
            }
            
            db.updateYakVote(targetYak: self.yak!)
            
            upvoted.append(self.yak!.image_url)
            UserDefaults.standard.set(upvoted, forKey: "upvoted")
            UserDefaults.standard.set(downvoted, forKey: "downvoted")
        }
        colorButtons()
    }
    
    @objc func downVote() {
        var upvoted:[String] = (UserDefaults.standard.array(forKey: "upvoted") ?? []) as! [String]
        var downvoted:[String] = (UserDefaults.standard.array(forKey: "downvoted") ?? []) as! [String]
        var undownvoted = false
        
        if downvoted.contains(self.yak!.image_url) {
            self.yak!.likes = self.yak!.likes + 1
            downvoted = downvoted.filter { $0 != self.yak!.image_url }
            UserDefaults.standard.set(downvoted, forKey: "downvoted")
            undownvoted = true
    
            self.votesLabel.text = "\(self.yak!.likes)"
            
            if self.yak!.likes >= 0 {
                self.votesLabel.textColor = UIColor(hue: 0.3472, saturation: 1, brightness: 0.57, alpha: 1.0)
            } else {
                self.votesLabel.textColor = UIColor(hue: 0, saturation: 1, brightness: 0.53, alpha: 1.0)
            }
            
            db.updateYakVote(targetYak: yak!)
        }
        if !downvoted.contains(self.yak!.image_url) && !undownvoted {
            if upvoted.contains(self.yak!.image_url) {
                self.yak!.likes = self.yak!.likes - 1
                upvoted = upvoted.filter { $0 != self.yak!.image_url }
            }
            self.yak!.likes = self.yak!.likes - 1
            self.votesLabel.text = "\(self.yak!.likes)"
            
            if self.yak!.likes >= 0 {
                self.votesLabel.textColor = UIColor(hue: 0.3472, saturation: 1, brightness: 0.57, alpha: 1.0)
            } else {
                self.votesLabel.textColor = UIColor(hue: 0, saturation: 1, brightness: 0.53, alpha: 1.0)
            }
            
            db.updateYakVote(targetYak: self.yak!)
            
            downvoted.append(self.yak!.image_url)
            UserDefaults.standard.set(upvoted, forKey: "upvoted")
            UserDefaults.standard.set(downvoted, forKey: "downvoted")
        }
        colorButtons()
    }
    
    @IBAction func closeViewController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openComments(_ sender: Any) {
        performSegue(withIdentifier: "ShowComments", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ShowComments" {
                if let viewController = segue.destination as? CommentsViewController {
                    viewController.modalPresentationStyle = .overFullScreen
                    viewController.yak = yak
                }
            }
        }
    }
}
