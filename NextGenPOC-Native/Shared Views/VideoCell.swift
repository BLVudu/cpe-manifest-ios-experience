//
//  VideoCell.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/21/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit


class VideoCell: UITableViewCell{
    
    
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var playBtn: UIImageView!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            
        UIView.animateWithDuration(1.5, animations:{
            self.thumbnail.alpha = 1
            self.caption.alpha = 1
            self.playBtn.hidden = true
            self.thumbnail.layer.borderWidth = 2
            self.thumbnail.layer.borderColor = UIColor.whiteColor().CGColor
            
            }, completion: { (Bool) -> Void in
            
            })
            
            
        } else {
            self.playBtn.hidden = false
            self.thumbnail.alpha = 0.5
            self.caption.alpha = 0.5
            self.thumbnail.layer.borderWidth = 0
        }

    }
    
    
}
