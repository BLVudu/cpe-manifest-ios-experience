//
//  ContentCell.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/21/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit


class ContentCell: UICollectionViewCell {
    
    @IBOutlet var extraImg: UIImageView!
    
    @IBOutlet weak var extrasTitle: UILabel!
    
    override var selected:Bool{
        get {
            return super.selected
        }
        
        set{
            if newValue{
                self.layer.borderWidth = 2
                self.layer.borderColor = UIColor.whiteColor().CGColor
            } else{
                self.layer.borderWidth = 0
            }
            
        }
    }
    
}