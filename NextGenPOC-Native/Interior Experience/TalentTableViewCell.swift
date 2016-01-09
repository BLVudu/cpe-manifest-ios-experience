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
    @IBOutlet weak var talentNameLabel: UILabel!
    @IBOutlet weak var talentRoleLabel: UILabel!
    
    var talent: Talent? = nil {
        didSet {
            talentNameLabel.text = talent?.name
            talentRoleLabel.text = talent?.role
        }
    }
    
    override func layoutSubviews() {
        self.backgroundColor = UIColor.clearColor()
    }

}
