//
//  MessageCell.swift
//  SnapYak
//
//  Created by Brian Guevara on 4/21/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet var headlineLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var votesLabel: UILabel!
    @IBOutlet var upVoteButton: UIButton!
    @IBOutlet var downVoteButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
