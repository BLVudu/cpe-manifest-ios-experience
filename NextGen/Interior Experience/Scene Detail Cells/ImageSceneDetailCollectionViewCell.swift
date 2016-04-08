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
    
    private var _setImageSessionDataTask: NSURLSessionDataTask?
    
    private var _imageURL: NSURL? {
        didSet {
            if let url = _imageURL {
                if url != oldValue {
                    _setImageSessionDataTask = imageView.setImageWithURL(url)
                }
            } else {
                imageView.image = UIImage(named: "MOSDefault")
                imageView.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    override func timedEventDidChange() {
        super.timedEventDidChange()
        
        if let timedEvent = timedEvent, experience = experience {
            _imageURL = timedEvent.getImageURL(experience)
        } else {
            _imageURL = nil
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let task = _setImageSessionDataTask {
            task.cancel()
            _setImageSessionDataTask = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
    }
    
}
