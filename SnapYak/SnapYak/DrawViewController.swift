//
//  DrawViewController.swift
//  SnapYak
//
//  Created by Benny Cheng on 5/5/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit

class DrawViewController: UIViewController {
    var drawViewControllerDelegate: DrawViewControllerDelegate!
    let drawColors: [UIColor] = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), #colorLiteral(red: 0.1725490196, green: 0.6156862745, blue: 0.8980392157, alpha: 1)]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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


protocol DrawViewControllerDelegate: class {
    func changeDrawColor(_ color: UIColor)
}
