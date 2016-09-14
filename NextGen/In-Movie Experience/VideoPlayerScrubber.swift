//
//  CustomScrubber.swift
//

import UIKit

class VideoPlayerScrubber: UISlider {
    
    /*private struct Constants {
        static let ThumbRectAdjustment: CGFloat = 0
    }*/
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
        
        setup()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        
        setup()
    }
    
    fileprivate func setup() {
        let scrubberImage = UIImage(named: "Scrubber Image")
        self.setThumbImage(scrubberImage, for: UIControlState())
        self.setThumbImage(scrubberImage, for: .highlighted)
        self.minimumTrackTintColor = UIColor.themePrimaryColor()
    }
    
    /*override func thumbRectForBounds(bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        var thumbRect = super.thumbRectForBounds(bounds, trackRect: rect, value: value)
        thumbRect.origin.x -= Constants.ThumbRectAdjustment
        thumbRect.size.width += Constants.ThumbRectAdjustment * 2
        
        return thumbRect
    }*/
    
}
