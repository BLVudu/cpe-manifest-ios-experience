//
//  ImageSceneDetailCollectionViewCell.swift
//

import Foundation
import UIKit

class ImageSceneDetailCollectionViewCell: SceneDetailCollectionViewCell {
    
    static let ReuseIdentifier = "ImageSceneDetailCollectionViewCellReuseIdentifier"
    static let ClipShareReuseIdentifier = "ClipShareSceneDetailCollectionViewCellReuseIdentifier"
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var playButton: UIButton!
    @IBOutlet weak private var extraDescriptionLabel: UILabel!
    
    private var imageURL: NSURL? {
        set {
            if let url = newValue {
                imageView.af_setImageWithURL(url)
            } else {
                imageView.af_cancelImageRequest()
                imageView.image = nil
                imageView.backgroundColor = UIColor.clearColor()
            }
        }
        
        get {
            return nil
        }
    }
    
    override func timedEventDidChange() {
        super.timedEventDidChange()
        
        imageURL = timedEvent?.imageURL
        playButton.hidden = timedEvent == nil || (!timedEvent!.isType(.AudioVisual) && !timedEvent!.isType(.ClipShare))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageURL = nil
        playButton.hidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
    }
    
}
