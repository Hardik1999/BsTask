//
//  Mytextfield.swift
//  Alpha Estate Vault
//
//  Created by Raj Shukla on 05/03/20.
//  Copyright © 2020 Raj Shukla. All rights reserved.
//

import UIKit

class EdgeRoundRectButton: UIButton {
    override func awakeFromNib() {
        self.layer.cornerRadius = 5
//        self.setTitleColor(UIColor.colorFromHex(hexString: "#2C828B"), for: .normal)
    }
}

class RoundRectButton: UIButton {
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.height/2
    }
}

class RoundRectView: UIView {
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.height/2
    }
}

class RoundRectImageView: UIImageView {
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.height/2
    }
}

//class LeftBubbleView: UIView {
//    override func awakeFromNib() {
//        self.layoutIfNeeded()
//        self.makeCustomRound(topLeft: 6, topRight: 30, bottomLeft: 30, bottomRight: 30)
//    }
//}

class curvedView: UIView {
    override func draw(_ rect: CGRect) {
        let color = UIColor.white
        let y:CGFloat = rect.height
        let myBezier = UIBezierPath()
        myBezier.move(to: CGPoint(x: 0, y: y))
        myBezier.addQuadCurve(to: CGPoint(x: rect.width, y: y), controlPoint: CGPoint(x: rect.width / 2, y: rect.height / 3))
        myBezier.addLine(to: CGPoint(x: rect.width , y: rect.height))
//        myBezier.addLine(to: CGPoint(x: 10, y: rect.height))
        
//        myBezier.move(to: CGPoint(x:0, y:bounds.height))
//        myBezier.addQuadCurve(to: CGPoint(x:bounds.width, y:bounds.height), controlPoint: CGPoint(x:bounds.width/2, y:4*bounds.height/5))
//        myBezier.addLine(to: CGPoint(x:bounds.width, y:0))
//        myBezier.addLine(to: CGPoint(x:0, y:0))
        
        myBezier.close()
        color.setFill()
        myBezier.fill()
        
        
        
        

    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear

    }
}

//bsport1#5
class TranparentcurvedView: UIView {
    override func draw(_ rect: CGRect) {
        let color = UIColor.white.withAlphaComponent(0.8)
        let y:CGFloat = rect.height
        let myBezier = UIBezierPath()
        myBezier.move(to: CGPoint(x: 0, y: y))
        myBezier.addQuadCurve(to: CGPoint(x: rect.width, y: y), controlPoint: CGPoint(x: rect.width / 2, y: rect.height / 3))
        myBezier.addLine(to: CGPoint(x: rect.width , y: rect.height))
        myBezier.addLine(to: CGPoint(x: 10, y: rect.height))

//        myBezier.move(to: CGPoint(x:0, y:bounds.height))
//        myBezier.addQuadCurve(to: CGPoint(x:bounds.width, y:bounds.height), controlPoint: CGPoint(x:bounds.width/2, y:4*bounds.height/5))
//        myBezier.addLine(to: CGPoint(x:bounds.width, y:0))
//        myBezier.addLine(to: CGPoint(x:0, y:0))

        myBezier.close()
        color.setFill()
        myBezier.fill()





    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear

    }
}
