//
//  TalentTableViewCell.swift
//  NextGen
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

class TalentTableViewCell: UITableViewCell {
    
    static let ReuseIdentifier = "TalentTableViewCell"
    
    @IBOutlet weak var talentImageView: RoundImageView!
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var roleLabel: UILabel?
    
    var talent: Talent? = nil {
        didSet {
            nameLabel?.text = talent?.name?.uppercaseString
            roleLabel?.text = talent?.role
            if let imageURL = talent?.thumbnailImageURL {
                talentImageView.setImageWithURL(imageURL)
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
            nameLabel?.textColor = UIColor(netHex: 0xffcd14)
            roleLabel?.textColor = UIColor(netHex: 0xffcd14)
        } else {
            talentImageView.layer.borderWidth = 0
            nameLabel?.textColor = UIColor.whiteColor()
            roleLabel?.textColor = UIColor(netHex: 0x999999)
        }
    }

}
