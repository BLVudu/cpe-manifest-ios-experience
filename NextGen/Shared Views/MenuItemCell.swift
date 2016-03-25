//
//  MenuItemCell.swift
//  NextGen
//
//  Created by Alec Ananian on 3/25/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import QuartzCore

class MenuItemCell: UITableViewCell {
    
    static let NibName = "MenuItemCell"
    static let ReuseIdentifier = "MenuItemCellReuseIdentifier"
    
    @IBOutlet weak var valueLabel: UILabel!
    
    var menuItem: MenuItem? {
        didSet {
            valueLabel.text = menuItem?.value
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        menuItem = nil
    }

}
