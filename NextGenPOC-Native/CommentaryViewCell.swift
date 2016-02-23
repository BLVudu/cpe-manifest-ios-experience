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
            
            
        } else {
            
            self.radioBtn.selected = false
            
            
        }
        
        
    }

    
}
