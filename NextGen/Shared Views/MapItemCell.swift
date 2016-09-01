//
//  MapItemCell.swift
//

import UIKit
import NextGenDataManager

class MapItemCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "MapItemCellReuseIdentifier"
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var playButton: UIButton!
    
    var title: String? {
        set {
            titleLabel.text = newValue
        }
        
        get {
            return titleLabel.text
        }
    }
    
    var imageURL: NSURL? {
        set {
            if let imageURL = newValue {
                imageView.af_setImageWithURL(imageURL)
            } else {
                imageView.af_cancelImageRequest()
                imageView.image = nil
            }
        }
        
        get {
            return nil
        }
    }
    
    var playButtonVisible: Bool {
        set {
            playButton.hidden = !newValue
        }
        
        get {
            return !playButton.hidden
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        title = nil
        imageURL = nil
        playButton.hidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !DeviceType.IS_IPAD {
            titleLabel.font = UIFont(name: titleLabel.font.fontName, size: 12)
        }
    }
    
}