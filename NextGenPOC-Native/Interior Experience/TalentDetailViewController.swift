//
//  TalentDetailViewController.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/13/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

class TalentDetailViewController: UIViewController {
    
    @IBOutlet weak var talentImageView: UIImageView!
    @IBOutlet weak var talentNameLabel: UILabel!
    
    var talent: Talent? = nil {
        didSet {
            talentNameLabel.text = talent?.name
            talentImageView.image = talent?.fullImage != nil ? UIImage(named: talent!.fullImage!) : nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
