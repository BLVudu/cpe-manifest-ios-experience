//
//  TalentDetailView.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/8/16.
//  Copyright © 2016 Sedinam Gadzekpo. All rights reserved.
//

import UIKit

class TalentDetailView: UIView {

    @IBOutlet weak var talentImageView: UIImageView!
    @IBOutlet weak var talentNameLabel: UILabel!
    
    var talent: Talent? = nil {
        didSet {
            talentNameLabel.text = talent?.name
            talentImageView.image = talent?.fullImage != nil ? UIImage(named: talent!.fullImage!) : nil
        }
    }

}
