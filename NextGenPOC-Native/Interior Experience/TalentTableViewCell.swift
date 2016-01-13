//
//  TalentTableViewCell.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Sedinam Gadzekpo. All rights reserved.
//

import UIKit

class TalentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var talentImageView: RoundImageView!
    
    var talent: Talent? = nil {
        didSet {
            if talent?.thumbnailImage != nil {
                talentImageView.image = UIImage(named: talent!.thumbnailImage!)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        talentImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            talentImageView.layer.borderWidth = 2
            talentImageView.layer.borderColor = UIColor.whiteColor().CGColor
        } else {
            talentImageView.layer.borderWidth = 0
        }
    }

}
