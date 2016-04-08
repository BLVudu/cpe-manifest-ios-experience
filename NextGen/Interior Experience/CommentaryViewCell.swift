//
//  CommentaryViewCell.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 2/18/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class CommentaryViewCell: UITableViewCell {
    
    @IBOutlet weak var option: UILabel!
   
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var radioBtn: RadioButton!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if (selected){
            
            
            self.radioBtn.selected = true
            self.option.textColor = UIColor.init(red: 255/255, green: 205/255, blue: 77/255, alpha: 1)
            //self.subtitle.textColor = UIColor.init(red: 255/255, green: 205/255, blue: 77/255, alpha: 1)
            
            
            
        } else {
            
            self.radioBtn.selected = false
            self.option.textColor = UIColor.whiteColor()
            //self.subtitle.textColor = UIColor.whiteColor()
            
            
        }
        
        
}
}

   