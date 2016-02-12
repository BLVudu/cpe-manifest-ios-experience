//
//  SettingsCell.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 2/11/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell{
    
    
    @IBOutlet weak var cellSetting: UILabel!
    @IBOutlet weak var currentSetting: UILabel!
    @IBOutlet weak var radioBtn: RadioButton!
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            
            self.radioBtn.backgroundColor = UIColor.yellowColor()
               
            
        } else {
            
            self.radioBtn.backgroundColor = UIColor.clearColor()
            
        }


    }


}

