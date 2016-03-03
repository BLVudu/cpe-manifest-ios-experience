//
//  VideoCell.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/21/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {
    
    static let ReuseIdentifier = "VideoCellReuseIdentifier"
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var playBtn: UIImageView!
    
    var isGallery = false
    
    override func layoutSubviews() {
        thumbnail.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.playBtn.hidden = true
            self.thumbnail.layer.borderWidth = 2
            
            UIView.animateWithDuration(0.25, animations: {
                self.thumbnail.alpha = 1
                self.caption.alpha = 1
            }, completion: nil)
        }else {
            if isGallery == true{
                self.playBtn.hidden = true
                
            } else {
            self.playBtn.hidden = false
            }
            self.thumbnail.layer.borderWidth = 0
            
            UIView.animateWithDuration(0.25, animations: {
                self.thumbnail.alpha = 0.5
                self.caption.alpha = 0.5
            }, completion: nil)
        }
    }
    
}
