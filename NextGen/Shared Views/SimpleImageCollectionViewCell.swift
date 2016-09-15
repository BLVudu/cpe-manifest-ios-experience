//
//  SimpleImageCollectionViewCell.swift
//

import UIKit

class SimpleImageCollectionViewCell: UICollectionViewCell {
    
    static let BaseReuseIdentifier = "SimpleImageCollectionViewCellReuseIdentifier"
    
    @IBOutlet weak fileprivate var imageView: UIImageView!
    @IBOutlet weak fileprivate var playButton: UIButton?
    
    fileprivate var setImageSessionDataTask: URLSessionDataTask?
    
    var showsSelectedBorder = false
    
    var imageURL: URL? {
        set {
            if let task = setImageSessionDataTask {
                task.cancel()
                setImageSessionDataTask = nil
            }
            
            if let url = newValue {
                imageView.sd_setImage(with: url)
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
            playButton?.isHidden = !newValue
        }
        
        get {
            return playButton != nil && !playButton!.isHidden
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected && showsSelectedBorder {
                self.layer.borderWidth = 2
                self.layer.borderColor = UIColor.white.cgColor
            } else {
                self.layer.borderWidth = 0
                self.layer.borderColor = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.isSelected = false
        
        imageURL = nil
        playButtonVisible = false
    }

}
