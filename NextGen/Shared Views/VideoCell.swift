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
    
    @IBOutlet weak private var thumbnailContainerView: UIView!
    @IBOutlet weak private var thumbnailImageView: UIImageView!
    @IBOutlet weak private var playIconImageView: UIImageView!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak private var captionLabel: UILabel!
    
    private var _setImageSessionDataTask: NSURLSessionDataTask?
    
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
                _setImageSessionDataTask = thumbnailImageView.setImageWithURL(imageURL)
            } else {
                thumbnailImageView.image = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        experience = nil
        
        if let task = _setImageSessionDataTask {
            task.cancel()
            _setImageSessionDataTask = nil
        }
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
                self.runtimeLabel.text = String.localize("label.playing")
            }, completion: nil)
        } else {
            UIView.animateWithDuration(0.25, animations: {
                self.thumbnailImageView.alpha = 0.5
                self.captionLabel.alpha = 0.5
                self.runtimeLabel.text = self.experience?.videoRuntime.formattedTime()
            }, completion: nil)
        }
    }
    
    func updateCellStyle() {
        thumbnailContainerView.layer.borderColor = UIColor.whiteColor().CGColor
        thumbnailContainerView.layer.borderWidth = (self.selected ? 2 : 0)
        captionLabel.textColor = (self.selected ? UIColor.themePrimaryColor() : UIColor.whiteColor())
        playIconImageView.hidden = self.selected
    }
    
}
