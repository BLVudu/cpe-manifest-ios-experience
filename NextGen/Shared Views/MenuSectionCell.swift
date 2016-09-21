//
//  MenuSectionCell.swift
//

import UIKit
import QuartzCore

class MenuSectionCell: UITableViewCell {
    
    static let ReuseIdentifier = "MenuSectionCellReuseIdentifier"
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var dropDownImageView: UIImageView!
    
    var menuSection: MenuSection? {
        didSet {
            titleLabel.text = menuSection?.title
            dropDownImageView.isHidden = (menuSection == nil || !menuSection!.expandable)
        }
    }
    
    var active = false {
        didSet {
            updateCellStyle()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        menuSection = nil
        active = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let section = menuSection {
            dropDownImageView.transform = CGAffineTransform(rotationAngle: section.expanded ? CGFloat(-M_PI) : 0.0)
        }
    }
    
    func updateCellStyle() {
        titleLabel.textColor = self.active ? UIColor.themePrimaryColor() : UIColor.white
    }
    
    func toggleDropDownIcon() {
        if let section = menuSection {
            let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
            rotate.fromValue = section.expanded ? 0.0 : CGFloat(-M_PI)
            rotate.toValue = section.expanded ? CGFloat(-M_PI) : 0.0
            rotate.duration = 0.25
            rotate.autoreverses = true
            rotate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            dropDownImageView.layer.add(rotate, forKey: nil)
        }
    }
    
}
