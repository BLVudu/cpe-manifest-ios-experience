//
//  CircularProgressView.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 4/13/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import CoreText

class CircularProgressView: UIView{
    
    let progressPath = CAShapeLayer()
    let time = CATextLayer()
    var radius = CGFloat()

    var countdownString: String{
        get{
            return time.string as! String
        }
        
        set{
            time.string = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    
    func configure(){

    let basicFont = UIFont.themeCondensedFont(20)
    time.backgroundColor = UIColor.clearColor().CGColor
    time.foregroundColor = UIColor.whiteColor().CGColor
    time.font = basicFont.fontName
    time.fontSize = 17
    time.wrapped = true
    time.frame = CGRectMake(bounds.origin.x-2, bounds.origin.y+12, 25, bounds.size.height)
    time.string = "  5 sec"
        
    radius = 22.0
        
    progressPath.frame = bounds
    progressPath.lineWidth = 3
    progressPath.fillColor = UIColor.clearColor().CGColor
    progressPath.strokeColor = UIColor(netHex:0xffcd4d).CGColor
    progressPath.strokeEnd = 0
    self.layer.addSublayer(progressPath)
    self.layer.addSublayer(time)

        
    }
    
  
    func animateTimer(){
        let timerAnim = CABasicAnimation.init(keyPath: "strokeEnd")
        timerAnim.duration = 5.0
        timerAnim.fromValue = 1.0
        timerAnim.toValue = 0.0
        timerAnim.repeatCount = 0
        timerAnim.delegate = self
        progressPath.addAnimation(timerAnim, forKey: "strokeEnd")

    }
     override func layoutSubviews() {
        super.layoutSubviews()
        progressPath.frame = bounds
        let point = CGPointMake(CGRectGetMidX(progressPath.bounds)+10, CGRectGetMidY(progressPath.bounds)+10)
        progressPath.path = UIBezierPath(arcCenter:point, radius:radius, startAngle: CGFloat(M_PI_2) * 3.0, endAngle:CGFloat(M_PI_2) * 3.0 + CGFloat(M_PI) * 2.0, clockwise: false).CGPath
    }
}