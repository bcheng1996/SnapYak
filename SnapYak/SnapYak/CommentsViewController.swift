//
//  CommentsViewController.swift
//  SnapYak
//
//  Created by Noah Fichter on 5/5/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var yak: Yak!
    var db: Database!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func reply(_ sender: Any) {
        let comment = textField.text!
        yak.comments.append(comment)
        db.updateComments(targetYak: yak)
        textField.text = ""
        tableView.reloadData()
    }
    @IBAction func closeComments(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.backgroundColor = UIColor.lightGray
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.backgroundColor = UIColor.white
        return true
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let yak = self.yak {
            return yak.comments.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CommentCell",
            for: indexPath) as! CommentsTableViewCell
        if let yak = self.yak {
            let comment = yak.comments[indexPath.row]
            cell.commentText.text = comment
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.textField.delegate = self
        self.db = Database()
    }
}
