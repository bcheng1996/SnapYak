//
//  TextView.swift
//  SnapYak
//
//  Created by Benny Cheng on 5/5/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit

class TextView: UIView {

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("TAPPED TOUCHES BEGAN!")
        for subview in self.subviews {
            print(subview)
        }
    }
}
