//
//  MenuSectionCell.swift
//  NextGen
//
//  Created by Alec Ananian on 3/25/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import QuartzCore

class MenuSectionCell: UITableViewCell {
    
    static let NibName = "MenuSectionCell"
    static let ReuseIdentifier = "MenuSectionCellReuseIdentifier"
    
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var dropDownImageView: UIImageView!
    
    var menuSection: MenuSection? {
        didSet {
            primaryLabel.text = menuSection?.title
            secondaryLabel.text = menuSection?.value
            dropDownImageView.hidden = (menuSection == nil || !menuSection!.expandable)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        menuSection = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let section = menuSection {
            dropDownImageView.transform = CGAffineTransformMakeRotation(section.expanded ? CGFloat(-M_PI) : 0.0)
        }
    }
    
    func toggleDropDownIcon() {
        if let section = menuSection {
            let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
            rotate.fromValue = section.expanded ? 0.0 : CGFloat(-M_PI)
            rotate.toValue = section.expanded ? CGFloat(-M_PI) : 0.0
            rotate.duration = 0.25
            rotate.autoreverses = true
            rotate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            dropDownImageView.layer.addAnimation(rotate, forKey: nil)
        }
    }
    
}
