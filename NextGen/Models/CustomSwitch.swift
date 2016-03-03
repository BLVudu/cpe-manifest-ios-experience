//
//  Switch.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/15/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit


class CustomSwitch: UISwitch {
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
         self.updateSwitch()
        
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
         self.updateSwitch()
        
    }
    
    
    func updateSwitch() {
        
        self.tintColor = UIColor.redColor()
        self.onTintColor = UIColor.greenColor()
        self.layer.cornerRadius = 16
        self.backgroundColor = UIColor.redColor()

    }
    
    
}
