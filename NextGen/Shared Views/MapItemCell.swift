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
    private var setImageSessionDataTask: NSURLSessionDataTask?
    
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
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self] in
                    if let strongSelf = self {
                        strongSelf.setImageSessionDataTask = strongSelf.imageView.setImageWithURL(imageURL, completion: nil)
                    }
                }
            } else {
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
        
        if let task = setImageSessionDataTask {
            task.cancel()
            setImageSessionDataTask = nil
        }
    }
    
}