//
//  MapItemCell.swift
//

import UIKit
import NextGenDataManager

class MapItemCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "MapItemCellReuseIdentifier"
    
    @IBOutlet weak fileprivate var titleLabel: UILabel!
    @IBOutlet weak fileprivate var imageView: UIImageView!
    @IBOutlet weak fileprivate var playButton: UIButton!
    
    var title: String? {
        set {
            titleLabel.text = newValue
        }
        
        get {
            return titleLabel.text
        }
    }
    
    var imageURL: URL? {
        set {
            if let imageURL = newValue {
                imageView.sd_setImage(with: imageURL)
            } else {
                imageView.sd_cancelCurrentImageLoad()
                imageView.image = nil
            }
        }
        
        get {
            return nil
        }
    }
    
    var playButtonVisible: Bool {
        set {
            playButton.isHidden = !newValue
        }
        
        get {
            return !playButton.isHidden
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        title = nil
        imageURL = nil
        playButton.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !DeviceType.IS_IPAD {
            titleLabel.font = UIFont(name: titleLabel.font.fontName, size: 12)
        }
    }
    
}
