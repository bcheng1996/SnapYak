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
    var db: Database!
    var yak: Yak?

    override func viewWillAppear(_ animated: Bool) {
        db = Database()
        if let yak = yak {
            self.messageLabel.text = "Location: \(yak.location)"
            self.db.fetchImage(imageURL: yak.image_url) { (imageData) in
                self.imageView.image = UIImage(data: imageData)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeViewController(){
        self.dismiss(animated: true, completion: nil)
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
