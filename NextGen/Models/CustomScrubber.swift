//
//  CustomScrubber.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
class CustomScrubber: UISlider{
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
        self.initScrubber()
        
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.initScrubber()
        
    }

    
    func initScrubber(){
        
        
        self.setThumbImage(UIImage(named: "Scrubber Image"), forState: .Normal)
        
        print(self.frame)
        
    }
    
    
    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        
        return CGRectMake(0,15, self.frame.size.width, 5)
    }
    
    
}