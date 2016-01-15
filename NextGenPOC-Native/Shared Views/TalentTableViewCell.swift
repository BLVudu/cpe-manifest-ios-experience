//
//  TalentTableViewCell.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

class TalentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var talentImageView: RoundImageView!
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var roleLabel: UILabel?
    
    var talent: Talent? = nil {
        didSet {
            nameLabel?.text = talent?.name
            roleLabel?.text = talent?.role
            if talent?.thumbnailImage != nil {
                talentImageView.image = UIImage(named: talent!.thumbnailImage!)
            } else {
                talentImageView.image = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        talent = nil
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
