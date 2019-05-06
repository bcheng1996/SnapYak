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
    var cachedImage: Data?

    override func viewWillAppear(_ animated: Bool) {
        db = Database()
        if let yak = yak {
            if cachedImage != nil {
                self.imageView.contentMode = .scaleAspectFill
                self.imageView.image = UIImage(data: cachedImage!)
            } else {
                self.db.fetchImage(imageURL: yak.image_url) { (imageData) in
                    self.imageView.contentMode = .scaleAspectFill
                    self.imageView.image = UIImage(data: imageData)
                }
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
