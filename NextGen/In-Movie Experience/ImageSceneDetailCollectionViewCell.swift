//
//  ImageSceneDetailCollectionViewCell.swift
//

import Foundation
import UIKit

class ImageSceneDetailCollectionViewCell: SceneDetailCollectionViewCell {
    
    static let ReuseIdentifier = "ImageSceneDetailCollectionViewCellReuseIdentifier"
    static let ClipShareReuseIdentifier = "ClipShareSceneDetailCollectionViewCellReuseIdentifier"
    
    @IBOutlet weak fileprivate var imageView: UIImageView!
    @IBOutlet weak fileprivate var playButton: UIButton!
    @IBOutlet weak fileprivate var extraDescriptionLabel: UILabel!
    
    fileprivate var imageURL: URL? {
        set {
            if let url = newValue {
                imageView.sd_setImage(with: url)
            } else {
                imageView.sd_cancelCurrentImageLoad()
                imageView.image = nil
                imageView.backgroundColor = UIColor.clear
            }
        }
        
        get {
            return nil
        }
    }
    
    override func timedEventDidChange() {
        super.timedEventDidChange()
        
        imageURL = timedEvent?.imageURL
        playButton.isHidden = timedEvent == nil || (!timedEvent!.isType(.audioVisual) && !timedEvent!.isType(.clipShare))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageURL = nil
        playButton.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.contentMode = .scaleAspectFill
    }
    
}
