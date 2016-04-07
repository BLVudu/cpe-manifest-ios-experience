//
//  ImageSceneDetailCollectionViewCell.swift
//  NextGen
//
//  Created by Alec Ananian on 2/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

class ImageSceneDetailCollectionViewCell: SceneDetailCollectionViewCell {
    
    static let ReuseIdentifier = "ImageSceneDetailCollectionViewCellReuseIdentifier"
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var _imageURL: NSURL!
    var imageURL: NSURL? {
        get {
            return _imageURL
        }
        
        set {
            if _imageURL != newValue {
                _imageURL = newValue
                
                if let url = _imageURL {
                    imageView.contentMode = UIViewContentMode.ScaleAspectFill
                    imageView.setImageWithURL(url)
                } else {
                    imageView.image = nil
                    imageView.backgroundColor = UIColor.clearColor()
                }
            }
        }
    }
    
    override func timedEventDidChange() {
        super.timedEventDidChange()
        
        if let timedEvent = timedEvent, experience = experience {
            imageURL = timedEvent.getImageURL(experience)
        } else {
            imageURL = nil
        }
    }
    
}
