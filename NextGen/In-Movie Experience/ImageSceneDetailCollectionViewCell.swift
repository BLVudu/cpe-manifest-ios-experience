//
//  ImageSceneDetailCollectionViewCell.swift
//

import Foundation
import UIKit

class ImageSceneDetailCollectionViewCell: SceneDetailCollectionViewCell {
    
    static let ReuseIdentifier = "ImageSceneDetailCollectionViewCellReuseIdentifier"
    static let ClipShareReuseIdentifier = "ClipShareSceneDetailCollectionViewCellReuseIdentifier"
    
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
                _imageView.image = UIImage.themeDefaultImage16By9()
                _imageView.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    override func timedEventDidChange() {
        super.timedEventDidChange()
        
        _imageURL = timedEvent?.imageURL
        _playButton.hidden = timedEvent == nil || (!timedEvent!.isType(.AudioVisual) && !timedEvent!.isType(.ClipShare))
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
