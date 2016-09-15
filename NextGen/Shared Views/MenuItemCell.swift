//
//  MenuItemCell.swift
//

import UIKit
import QuartzCore

class MenuItemCell: UITableViewCell {
    
    static let ReuseIdentifier = "MenuItemCellReuseIdentifier"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var titleLabelLargePaddingConstraint: NSLayoutConstraint!
    
    var menuItem: MenuItem? {
        didSet {
            titleLabel.text = menuItem?.title
        }
    }
    
    var active = false {
        didSet {
            updateCellStyle()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        menuItem = nil
        active = false
        titleLabelLargePaddingConstraint.isActive = true
    }
    
    func updateCellStyle() {
        titleLabel.textColor = (self.active ? UIColor.themePrimaryColor() : UIColor.white)
    }

}
