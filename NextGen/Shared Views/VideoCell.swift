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
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var playIconImageView: UIImageView!
    @IBOutlet weak var runtimeLabel: UILabel!
    
    var experience: NGDMExperience? {
        didSet {
            captionLabel.text = experience?.metadata?.title
            if let runtime = experience?.videoRuntime {
                if runtime > 0 {
                    runtimeLabel.hidden = false
                    runtimeLabel.text = runtime.formattedTime()
                } else {
                    runtimeLabel.hidden = true
                }
            } else {
                runtimeLabel.hidden = true
            }
            
            if let imageURL = experience?.imageURL {
                thumbnailImageView.setImageWithURL(imageURL)
            } else {
                thumbnailImageView.image = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        experience = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCellStyle()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        updateCellStyle()
        
        if selected {
            UIView.animateWithDuration(0.25, animations: {
                self.thumbnailImageView.alpha = 1
                self.captionLabel.alpha = 1
            }, completion: nil)
        } else {
            UIView.animateWithDuration(0.25, animations: {
                self.thumbnailImageView.alpha = 0.5
                self.captionLabel.alpha = 0.5
            }, completion: nil)
        }
    }
    
    func updateCellStyle() {
        thumbnailImageView.layer.borderColor = UIColor.whiteColor().CGColor
        thumbnailImageView.layer.borderWidth = (self.selected ? 2 : 0)
        captionLabel.textColor = (self.selected ? UIColor(netHex: 0xffcd14) : UIColor.whiteColor())
        playIconImageView.hidden = self.selected
    }
    
}
