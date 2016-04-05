//
//  CustomScrubber.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 3/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class VideoPlayerScrubber: UISlider {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
        
        self.initScrubber()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        
        self.initScrubber()
    }
    
    func initScrubber() {
        self.setThumbImage(UIImage(named: "Scrubber Image"), forState: .Normal)
        self.setThumbImage(UIImage(named: "Scrubber Image"), forState: .Highlighted)
    }
    
}