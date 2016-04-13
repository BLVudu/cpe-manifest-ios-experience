//
//  ImageSceneDetailCollectionViewCell.swift
//  NextGen
//
//  Created by Alec Ananian on 2/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

class ImageSceneDetailCollectionViewCell: SceneDetailCollectionViewCell {
    
    static let ReuseIdentifier = "ImageSceneDetailCollectionViewCellReuseIdentifier"
    
    @IBOutlet weak private var _imageView: UIImageView!
    @IBOutlet weak private var _playButton: UIButton!
    @IBOutlet weak private var _extraDescriptionLabel: UILabel!
    
    private var _setImageSessionDataTask: NSURLSessionDataTask?
    
    private var _imageURL: NSURL? {
        didSet {
            if let url = _imageURL {
                if url != oldValue {
                    _setImageSessionDataTask = _imageView.setImageWithURL(url)
                }
            } else {
                _imageView.image = UIImage(named: "MOSDefault")
                _imageView.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    override func timedEventDidChange() {
        super.timedEventDidChange()
        
        if let timedEvent = timedEvent, experience = experience {
            _imageURL = timedEvent.getImageURL(experience)
            _playButton.hidden = !timedEvent.isAudioVisual()
        } else {
            _imageURL = nil
            _playButton.hidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let task = _setImageSessionDataTask {
            task.cancel()
            _setImageSessionDataTask = nil
        }
        
        _imageURL = nil
        _playButton.hidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _imageView.contentMode = UIViewContentMode.ScaleAspectFill
    }
    
}
