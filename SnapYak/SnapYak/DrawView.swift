//
//  DrawView.swift
//  SnapYak
//
//  Created by Benny Cheng on 5/5/19.
//  Copyright © 2019 group34. All rights reserved.
//

import UIKit

class Line {
    var start: CGPoint
    var end: CGPoint
    var color: CGColor
    
    init(start: CGPoint, end: CGPoint, color: CGColor) {
        self.start = start
        self.end = end
        self.color = color
    }
}

class DrawView: UIView {
    var lines: [[Line]] = [[]]
    var currentLine: [Line] = []
    var lastPoint: CGPoint!
    var drawColor: UIColor! = UIColor.black
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("TOUCH BEGAN")
        if let touch = touches.first {
            lastPoint = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let newPoint = touch.location(in: self)
            currentLine.append(Line(start: lastPoint, end: newPoint, color: self.drawColor.cgColor))
            lastPoint = newPoint
            
            self.setNeedsDisplay()
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        lines.append(currentLine)
//        currentLine = []
//        self.setNeedsDisplay()

    }

//
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        for subview in subviews {
//            print(subview)
//            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
//                print("TRUE")
//                return true
//            }
//        }
//        return false
//    }
    
    override func draw(_ rect: CGRect) {
        self.backgroundColor = UIColor(white: 1, alpha: 0.0)
        if let context = UIGraphicsGetCurrentContext(){
            
            context.setLineWidth(3.0)
            context.setLineCap(.round)
            for l in self.currentLine {
                context.beginPath()
                context.move(to: CGPoint(x: l.start.x, y: l.start.y))
                context.addLine(to: CGPoint(x: l.end.x, y: l.end.y))
                context.setStrokeColor(l.color)
                
                context.strokePath()
            }

            
//            for line in lines {
//                context.beginPath()
//                for currline in line {
//                    context.move(to: CGPoint(x: currline.start.x, y: currline.start.y))
//                    context.addLine(to: CGPoint(x: currline.end.x, y: currline.end.y))
//                    context.setStrokeColor(currline.color)
//                }
//                context.setLineWidth(3.0)
//                context.strokePath()
//            }
        }
    }

}
